import shlex

start_all()
machine.wait_for_unit("multi-user.target")
machine.wait_for_unit("home-manager-consumer.service")
machine.wait_for_unit("user@1000.service")


def user(command):
    return (
        "runuser -u consumer -- env XDG_RUNTIME_DIR=/run/user/1000 "
        "PATH=/etc/profiles/per-user/consumer/bin:/run/current-system/sw/bin "
        "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus "
        "DISPLAY=:1 GDK_BACKEND=x11 bash -c " + shlex.quote(command)
    )


def evaluate(expression):
    return user("emacsclient -a false -e " + shlex.quote(expression))


machine.fail(user("systemctl --user is-active --quiet emacs"))
machine.succeed(user("Xvfb :1 -ac -screen 0 1280x800x24 </dev/null >/tmp/xvfb.log 2>&1 &"))
machine.wait_until_succeeds("test -S /tmp/.X11-unix/X1")
machine.succeed(user("systemctl --user set-environment DISPLAY=:1 GDK_BACKEND=x11"))
machine.succeed(user("systemctl --user start emacs & a=$!; systemctl --user start emacs & b=$!; wait $a; wait $b"))
pid = machine.succeed(user("systemctl --user show emacs -p MainPID --value")).strip()
machine.succeed(evaluate("(and doom-profile evil-mode)"))
machine.succeed(user("systemctl --user start emacs"))
assert machine.succeed(user("systemctl --user show emacs -p MainPID --value")).strip() == pid

# A real Xvfb-backed graphical frame checks frame lifecycle without touching
# the host user's display or services. Compositor focus remains a manual check.
machine.succeed(evaluate("(progn (make-frame '((window-system . pgtk) (name . \"ordinary\"))) t)"))
machine.succeed(evaluate("(let ((f (seq-find (lambda (x) (equal (frame-parameter x 'name) \"ordinary\")) (frame-list)))) (with-selected-frame f (+dashboard/open f) (with-current-buffer +dashboard-name (dolist (label '(\"Capture a thought\" \"Open agenda\" \"Find a knowledge note\" \"Open today's journal\")) (unless (string-match-p (regexp-quote label) (buffer-string)) (error \"Missing dashboard label: %s\" label))) t)))"))
machine.succeed(evaluate("(let ((f (seq-find (lambda (x) (equal (frame-parameter x 'name) \"ordinary\")) (frame-list))) (kit/dashboard-actions nil)) (with-selected-frame f (cl-letf (((symbol-function 'org-capture) (lambda () (interactive) (push 'capture kit/dashboard-actions))) ((symbol-function 'org-agenda-list) (lambda () (interactive) (push 'agenda kit/dashboard-actions))) ((symbol-function 'org-roam-node-find) (lambda () (interactive) (push 'notes kit/dashboard-actions))) ((symbol-function 'org-roam-dailies-goto-today) (lambda () (interactive) (push 'daily kit/dashboard-actions)))) (+dashboard/open f) (with-current-buffer +dashboard-name (dolist (label '(\"Capture a thought\" \"Open agenda\" \"Find a knowledge note\" \"Open today's journal\")) (goto-char (point-min)) (search-forward label) (button-activate (button-at (1- (point))))))) (unless (equal (nreverse kit/dashboard-actions) '(capture agenda notes daily)) (error \"Dashboard action mismatch\")) t))"))
# Verify an actual image overlay on a disposable graphical frame.
machine.succeed(user("mkdir -p ~/notes; printf '%s' '<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"20\"><rect width=\"20\" height=\"20\" fill=\"blue\"/></svg>' > ~/notes/image.svg; printf '%s\\n' '[[file:image.svg]]' > ~/notes/image.org"))
machine.succeed(evaluate("(let ((f (seq-find (lambda (x) (equal (frame-parameter x 'name) \"ordinary\")) (frame-list)))) (with-selected-frame f (with-current-buffer (find-file-noselect (expand-file-name \"~/notes/image.org\")) (org-mode) (org-display-inline-images) (unless (seq-some (lambda (o) (overlay-get o 'org-image-overlay)) (overlays-in (point-min) (point-max))) (error \"No inline image overlay\")) t)))"))
machine.succeed(user("org-agenda"))
machine.succeed(evaluate('(setq kit/test-picker-timer (run-at-time 1 1 (lambda () (when (active-minibuffer-window) (write-region "picker" nil "/tmp/notes-picker-seen") (cancel-timer kit/test-picker-timer) (abort-recursive-edit)))))'))
machine.fail(user("org-notes"))  # Abort the actual node picker after observing it.
machine.succeed("test -f /tmp/notes-picker-seen")
machine.succeed(evaluate('(progn (require \'org) (make-directory org-directory t) (setq org-capture-templates `(("t" "Task" entry (file ,(expand-file-name "tasks.org" org-directory)) "* TODO %?"))))'))
machine.succeed(user("systemctl --user set-environment DISPLAY=:999 WAYLAND_DISPLAY=stale GDK_BACKEND=wayland"))
machine.succeed(user("org-capture t"))
machine.succeed(evaluate('(with-selected-frame (seq-find (lambda (f) (frame-parameter f \'kit-org-capture)) (frame-list)) (with-current-buffer (window-buffer (selected-window)) (insert "VM task") (org-capture-finalize)) t)'))
machine.succeed(user("grep -q 'TODO VM task' ~/notes/tasks.org"))
assert machine.succeed(evaluate("(length (seq-filter (lambda (f) (frame-parameter f 'kit-org-capture)) (frame-list)))")).strip() == "0"
machine.succeed(user("org-capture t"))
machine.succeed(evaluate("(with-selected-frame (seq-find (lambda (f) (frame-parameter f 'kit-org-capture)) (frame-list)) (with-current-buffer (window-buffer (selected-window)) (org-capture-kill)) t)"))
assert machine.succeed(evaluate('(length (seq-filter (lambda (f) (equal (frame-parameter f \'name) "ordinary")) (frame-list)))')).strip() == "1"

# Client file opening, frame closure and a separately managed restart.
machine.succeed(user("emacsclient -a false -n -c ~/notes/tasks.org"))
machine.succeed(evaluate("(progn (mapc (lambda (f) (when (display-graphic-p f) (delete-frame f t))) (frame-list)) t)"))
machine.succeed(user("systemctl --user is-active --quiet emacs"))
machine.succeed(user("timeout 15 systemctl --user restart emacs"))
assert machine.succeed(user("systemctl --user show emacs -p MainPID --value")).strip() != pid
machine.fail(user("DISPLAY= WAYLAND_DISPLAY= org-capture 2>/tmp/no-display"))
machine.succeed("grep -q 'no usable graphical display' /tmp/no-display")
machine.fail(user("org-capture a b"))
# Quotes/newlines must remain data and must not turn into Lisp forms.
machine.succeed(user("org-capture " + shlex.quote('bad\") (write-region "oops" nil "/tmp/injected") ;\n')))
machine.fail("test -e /tmp/injected")

machine.succeed(user("systemctl --user stop emacs; mkdir -p ~/.config/systemd/user/emacs.service.d"))
machine.succeed(user("printf '[Service]\\nExecStart=\\nExecStart=/run/current-system/sw/bin/false\\nRestart=no\\n' > ~/.config/systemd/user/emacs.service.d/test.conf"))
machine.succeed(user("systemctl --user daemon-reload"))
machine.fail(user("org-agenda 2>/tmp/service-error"))
machine.succeed("grep -q 'journalctl --user' /tmp/service-error")

# A successful unit with no Emacs socket exercises bounded client readiness.
machine.succeed(user("printf '[Service]\\nType=simple\\nExecStart=\\nExecStart=/run/current-system/sw/bin/sleep infinity\\n' > ~/.config/systemd/user/emacs.service.d/test.conf"))
machine.succeed(user("systemctl --user daemon-reload"))
machine.fail(user("org-agenda 2>/tmp/readiness-error"))
machine.succeed("grep -q 'socket did not become ready' /tmp/readiness-error")
machine.succeed(user("systemctl --user stop emacs"))
