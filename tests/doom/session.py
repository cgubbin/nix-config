import shlex

start_all()
machine.wait_for_unit("multi-user.target")
machine.wait_for_unit("home-manager-consumer.service")
machine.wait_for_unit("user@1000.service")


def user(command):
    return (
        "runuser -u consumer -- env XDG_RUNTIME_DIR=/run/user/1000 "
        "TERM=xterm-256color "
        "PATH=/etc/profiles/per-user/consumer/bin:/run/current-system/sw/bin "
        "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus "
        "DISPLAY=:1 GDK_BACKEND=x11 bash -c " + shlex.quote(command)
    )


def evaluate(expression):
    return user("emacsclient -a false -e " + shlex.quote(expression))


machine.fail(user("systemctl --user is-active --quiet emacs"))
machine.succeed(user("systemctl --user set-environment DISPLAY=:999 WAYLAND_DISPLAY=stale GDK_BACKEND=wayland"))
machine.succeed(user("systemctl --user start emacs & a=$!; systemctl --user start emacs & b=$!; wait $a; wait $b"))
pid = machine.succeed(user("systemctl --user show emacs -p MainPID --value")).strip()
machine.succeed(evaluate('(null (getenv "DISPLAY"))'))
machine.succeed(evaluate("(and doom-profile evil-mode)"))
machine.succeed(evaluate('(and (fboundp \'kit/org-terminal-dispatch) (eq (lookup-key kit/org-terminal-mode-map (kbd "q")) \'kit/org-terminal-quit))'))
machine.succeed(evaluate("(progn (require 'org-roam) (fboundp 'org-roam-node-find))"))
machine.succeed(user("systemctl --user start emacs"))
assert machine.succeed(user("systemctl --user show emacs -p MainPID --value")).strip() == pid

# The terminal-only daemon stays available independently from client launchers.
machine.succeed(user("systemctl --user is-active --quiet emacs"))
machine.succeed(user("timeout 15 systemctl --user restart emacs"))
assert machine.succeed(user("systemctl --user show emacs -p MainPID --value")).strip() != pid
machine.fail(user("org-capture a b"))

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
