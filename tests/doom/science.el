;;; science.el -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'org)
(require 'org-capture)
(require 'org-roam)
(require 'org-roam-capture)
(require 'ob-python)
(require 'ob-shell)
(require 'ob-emacs-lisp)
(require 'ox-html)
(require 'ox-latex)
(require 'citar)
(require 'citar-org)
(require 'org-download)
(require 'org-noter)
(require 'pdf-tools)
(require 'forge)

(cl-assert (eq org-download-method 'directory))
(let ((blocked nil))
  (condition-case nil
      (kit/org-noter-start-graphical)
    (user-error (setq blocked t)))
  (cl-assert blocked))

;; Linear and GitHub references remain normal external Org links.
(with-temp-buffer
  (org-mode)
  (insert "[[https://linear.app/workspace/issue/TEAM-123][TEAM-123]]")
  (goto-char (point-min))
  (let ((opened nil))
    (cl-letf (((symbol-function 'browse-url) (lambda (url &rest _) (setq opened url))))
      (org-open-at-point))
    (cl-assert (equal opened "https://linear.app/workspace/issue/TEAM-123"))))

;; A zathura: link decodes spaces, keeps arguments separate, and gives WSLg
;; environment to the viewer process without mutating daemon state.
(let* ((root (expand-file-name "zathura-link-test" (getenv "HOME")))
       (note (expand-file-name "reading notes.org" root))
       (pdf (expand-file-name "paper with spaces.pdf" root))
       (frame (selected-frame))
       (old-context (frame-parameter frame 'kit-org-pdf-launch-context))
       (captured-command nil)
       (captured-wayland nil))
  (make-directory root t)
  (with-temp-file note (insert "#+title: Zathura link test\n"))
  (with-temp-file pdf (insert "%PDF-1.4\n"))
  (unwind-protect
      (progn
        (set-frame-parameter frame 'kit-org-pdf-launch-context
                             "{\"display\":\"\",\"wayland\":\"/mnt/wslg/runtime-dir/wayland-0\",\"authority\":\"\",\"runtime\":\"/run/user/1000\"}")
        (with-current-buffer (find-file-noselect note)
          (cl-letf (((symbol-function 'executable-find) (lambda (_) "/nix/store/mock-org-open-pdf"))
                    ((symbol-function 'make-process)
                     (lambda (&rest arguments)
                       (setq captured-command (plist-get arguments :command)
                             captured-wayland (getenv "WAYLAND_DISPLAY"))
                       'mock-process)))
            (kit/org-zathura-follow "paper%20with%20spaces.pdf::page=12"))
          (cl-assert (equal captured-command
                            (list "/nix/store/mock-org-open-pdf" pdf "12")))
          (cl-assert (equal captured-wayland "/mnt/wslg/runtime-dir/wayland-0"))
          (cl-assert (not (getenv "WAYLAND_DISPLAY")))
          (kill-buffer (current-buffer))))
    (set-frame-parameter frame 'kit-org-pdf-launch-context old-context)))

;; Image links: a terminal frame opens a tiled Zellij pane in the client's session, with the
;; client's zellij and the configured protocol; without Zellij it fails naming the file; a
;; graphical frame visits the file; other links are unaffected.
(let* ((root (expand-file-name "image-link-test" (getenv "HOME")))
       (bin (expand-file-name "client-bin" root))
       (zellij (expand-file-name "zellij" bin))
       (image (expand-file-name "a figure.png" root))
       (text (expand-file-name "notes.txt" root))
       (frame (selected-frame))
       (old-environment (frame-parameter frame 'environment))
       (open (lambda (file) (org-link-open-from-string (format "[[file:%s]]" file))))
       (captured nil))
  (make-directory bin t)
  (with-temp-file zellij (insert "#!/bin/sh\n"))
  (set-file-modes zellij #o755)
  (with-temp-file image (insert "png"))
  (with-temp-file text (insert "text"))
  (cl-assert (equal (car org-file-apps) (cons kit/org-image-file-regexp #'kit/org-open-image)))
  (cl-assert (member kit/org-image-protocol '("sixels" "kitty" "symbols")))
  (unwind-protect
      (cl-letf (((symbol-function 'make-process)
                 (lambda (&rest arguments) (setq captured (plist-get arguments :command)) 'mock-process))
                ((symbol-function 'display-graphic-p) (lambda (&rest _) nil)))
        ;; The session comes from the frame's client, not the daemon's environment.
        (set-frame-parameter frame 'environment (list "ZELLIJ_SESSION_NAME=dev" (concat "PATH=" bin)))
        (let ((process-environment (cons "ZELLIJ_SESSION_NAME=daemon" process-environment)))
          (funcall open image))
        (cl-assert (equal captured
                          (list zellij "--session" "dev" "action" "new-pane" "--close-on-exit"
                                "--name" "a figure.png" "--"
                                kit/org-image-viewer kit/org-image-protocol image))
                   nil "Unexpected pane command: %S" captured)
        (cl-assert (not (member "--floating" captured)))
        (cl-assert (not (get-file-buffer image)))
        ;; No Zellij session: a user-error naming the file, no process, no buffer.
        (setq captured nil)
        (set-frame-parameter frame 'environment (list (concat "PATH=" bin)))
        (let ((message (condition-case err (progn (funcall open image) nil)
                         (user-error (error-message-string err)))))
          (cl-assert (and message (string-match-p (regexp-quote image) message)) nil
                     "Expected a user-error naming %s, got %S" image message))
        (cl-assert (null captured))
        (cl-assert (not (get-file-buffer image)))
        ;; Session but no zellij on the client's PATH: the same failure.
        (set-frame-parameter frame 'environment (list "ZELLIJ_SESSION_NAME=dev" "PATH=/nonexistent"))
        (cl-assert (condition-case nil (progn (funcall open image) nil) (user-error t)))
        (cl-assert (null captured))
        ;; A non-image link in a terminal frame opens in Emacs as before.
        (set-frame-parameter frame 'environment (list "ZELLIJ_SESSION_NAME=dev" (concat "PATH=" bin)))
        (funcall open text)
        (cl-assert (null captured))
        (cl-assert (get-file-buffer text))
        (kill-buffer (get-file-buffer text))
        ;; A graphical frame visits the image itself. Called directly: the sandbox has no window
        ;; system, so the rest of Org's link path cannot run with a stubbed graphical frame.
        (let (visited)
          (cl-letf (((symbol-function 'display-graphic-p) (lambda (&rest _) t))
                    ((symbol-function 'find-file) (lambda (file &rest _) (setq visited file))))
            (kit/org-open-image image))
          (cl-assert (equal visited image))
          (cl-assert (null captured))))
    (set-frame-parameter frame 'environment old-environment)))

;; Image capture is writable and produces a relocatable path beside its note.
(let* ((directory (expand-file-name "note-assets-test" (getenv "HOME")))
       (note (expand-file-name "paper.org" directory))
       (image (expand-file-name "source.png" directory))
       (copy (expand-file-name "relocated" (getenv "HOME"))))
  (make-directory directory t)
  (with-temp-file note (insert "#+title: Image link test\n\n"))
  (with-temp-file image (insert "test image bytes"))
  (with-current-buffer (find-file-noselect note)
    (org-mode)
    (kit/org-download-use-note-assets)
    (let ((org-download-display-inline-images nil))
      (org-download-image (concat "file://" image)))
    (save-buffer)
    (let* ((tree (org-element-parse-buffer))
           (path (org-element-map tree 'link
                   (lambda (link) (org-element-property :path link)) nil t)))
      (cl-assert (and path (not (file-name-absolute-p path))))
      (cl-assert (file-exists-p (expand-file-name path directory)))
      (make-directory copy t)
      (let ((content (buffer-string))
            (destination (expand-file-name path copy)))
        (with-temp-file (expand-file-name "paper.org" copy)
          (insert content))
        (make-directory (file-name-directory destination) t)
        (copy-file (expand-file-name path directory) destination))
      (cl-assert (file-exists-p
                  (expand-file-name path (file-name-directory
                                          (expand-file-name "paper.org" copy))))))
    (kill-buffer (current-buffer))))

(defun kit/test-render (formula file options)
  (condition-case err
      (org-create-formula-image formula file options nil 'dvisvgm)
    (error (error "%s; TeX log: %s" (error-message-string err)
                  (if-let ((buffer (get-buffer "*Org Preview LaTeX Output*")))
                      (with-current-buffer buffer (buffer-string)) "missing")))))

;; These tests deliberately exercise the real confirmation path after Doom's
;; lazy Org setup. Answering prompts here affects only isolated test buffers.
(let* ((root (expand-file-name "scientific-example" (getenv "HOME")))
       (example (expand-file-name "dispersion.org" root))
       (side-effect (expand-file-name "executed" root))
       (untrusted (expand-file-name "untrusted.org" root))
       (default-directory (file-name-as-directory root)))
  (cl-assert org-confirm-babel-evaluate)
  (cl-assert (null org-export-use-babel))
  (with-temp-file untrusted
    (insert (format "#+begin_src emacs-lisp\n(write-region \"executed\" nil %S)\n#+end_src\n" side-effect)))
  (with-current-buffer (find-file-noselect untrusted)
    (org-mode)
    (cl-assert (not (file-exists-p side-effect)))
    (org-html-export-to-html)
    (cl-assert (not (file-exists-p side-effect)))
    (goto-char (point-min))
    (re-search-forward "^#\\+begin_src")
    (let ((asked nil))
      (cl-letf (((symbol-function 'yes-or-no-p) (lambda (&rest _) (setq asked t) nil)))
        (ignore-errors (org-babel-execute-src-block)))
      (cl-assert asked)
      (cl-assert (not (file-exists-p side-effect))))
    (cl-letf (((symbol-function 'yes-or-no-p) (lambda (&rest _) t)))
      (org-babel-execute-src-block))
    (cl-assert (file-exists-p side-effect)))

  ;; Opening and exporting untrusted blocks in every supported language must
  ;; remain inert, even when the blocks request ordinary result collection.
  (dolist (item `(("python" . ,(format "open(%S, 'w').write('bad')" (concat side-effect "-python")))
                  ("shell" . ,(format "touch %s" (shell-quote-argument (concat side-effect "-shell"))))
                  ("emacs-lisp" . ,(format "(write-region \"bad\" nil %S)" (concat side-effect "-elisp")))))
    (with-temp-file untrusted
      (insert (format "#+begin_src %s\n%s\n#+end_src\n" (car item) (cdr item))))
    (when-let ((buffer (get-file-buffer untrusted))) (with-current-buffer buffer (set-buffer-modified-p nil)) (kill-buffer buffer))
    (with-current-buffer (find-file-noselect untrusted)
      (org-mode)
      (org-html-export-to-html))
    (dolist (suffix '("-python" "-shell" "-elisp"))
      (cl-assert (not (file-exists-p (concat side-effect suffix))))))

  ;; Standard library backends and separate :python commands keep execution
  ;; choice local to a block, rather than mutating the daemon's global PATH.
  (dolist (language '(python shell emacs-lisp))
    (cl-assert (fboundp (intern (format "org-babel-execute:%s" language)))))
  (let* ((marker (expand-file-name "interpreter-log" root))
         (one (expand-file-name "python-one" root))
         (two (expand-file-name "python-two" root)))
    (dolist (pair `((,one . "one") (,two . "two")))
      (with-temp-file (car pair)
        (insert (format "#!/bin/sh\nprintf '%%s\\n' %s >> %s\nexec python3 \"$@\"\n"
                        (shell-quote-argument (cdr pair)) (shell-quote-argument marker))))
      (set-file-modes (car pair) #o700))
    (dolist (program (list one two))
      (with-temp-buffer
        (setq default-directory (file-name-as-directory root))
        (org-mode)
        (insert (format "#+begin_src python :python %s :results output\nprint('ok')\n#+end_src\n" program))
        (goto-char (point-min))
        (cl-letf (((symbol-function 'yes-or-no-p) (lambda (&rest _) t)))
          (org-babel-execute-src-block))))
    (cl-assert (equal (kit/test-file-text marker) "one\ntwo\n")))
    ;; Both tools run a dependency-free scratch project inside the Nix sandbox.
    (let ((python (executable-find "python3")))
      (with-temp-file (expand-file-name "pixi.toml" root)
        (insert "[workspace]\nname = \"test\"\nversion = \"0.1.0\"\nchannels = []\nplatforms = [\"linux-64\"]\n"))
      (dolist (command (list (format "uv run --offline --no-project --no-python-downloads --python %s python3" python)
                             (format "pixi run --manifest-path %s %s" (expand-file-name "pixi.toml" root) python)))
        (with-temp-buffer
          (setq default-directory (file-name-as-directory root))
          (org-mode)
          (insert (format "#+begin_src python :python \"%s\" :results output\nprint('environment-ok')\n#+end_src\n" command))
          (goto-char (point-min))
          (cl-letf (((symbol-function 'yes-or-no-p) (lambda (&rest _) t)))
            (org-babel-execute-src-block))
          ;; Match the result, not the source line, which also contains the marker.
          (cl-assert (string-match-p "^#\\+RESULTS:\n: environment-ok$" (buffer-string)) nil
                     "Block did not run with %s: %s\nBabel errors: %s" command (buffer-string)
                     (when-let ((errors (get-buffer "*Org-Babel Error Output*")))
                       (with-current-buffer errors (buffer-string)))))))


  ;; Real TeX + SVG conversion, including regeneration after an edit.
  (let ((first (expand-file-name "inline.svg" root))
        (display (expand-file-name "display.svg" root))
        (options '(:foreground "Black" :background "Transparent" :scale 1.0)))
    (kit/test-render "\\(\\beta\\)" first options)
    (kit/test-render "\\[ E(z) = E(0)\\exp(i\\beta z), \\qquad \\phi(z) = \\beta z. \\]" display options)
    (cl-assert (and (file-exists-p first) (file-exists-p display)))
    (let ((before (secure-hash 'sha256 (kit/test-file-text first))))
      (kit/test-render "\\(x^3\\)" first options)
      (cl-assert (not (equal before (secure-hash 'sha256 (kit/test-file-text first)))))))

  ;; Actual example: resolve the synthetic bibliography and link, explicitly
  ;; execute its Python block, then export without implicit re-execution.
  (let ((org-roam-directory root)
        (org-roam-db-location (expand-file-name "example-roam.db" root))
        (citar-bibliography (list (expand-file-name "references.bib" root))))
    (org-roam-db-sync)
    (cl-assert (org-roam-node-from-id "4e416ea0-dcf1-4bb6-bc8e-5d953292119a"))
    (with-current-buffer (find-file-noselect example)
      (org-mode)
      (cl-assert (citar-get-entry "example-waveguide"))
      (let* ((paper (expand-file-name "example-waveguide.pdf" root))
             (citar-library-paths (list root)))
        (with-temp-file paper (insert "%PDF-1.4\n"))
        (cl-assert (member paper (gethash "example-waveguide" (citar-get-files "example-waveguide"))))
        (with-temp-buffer
          (org-mode)
          (citar-insert-citation '("example-waveguide"))
          (cl-assert (string-match-p "example-waveguide" (buffer-string)))
          (goto-char (point-min))
          (search-forward "example-waveguide") (backward-char 3)
          (let ((followed nil)
                (citar-at-point-function 'kit/test-citation-follow))
            (cl-letf (((symbol-function 'kit/test-citation-follow)
                       (lambda () (interactive) (setq followed t))))
              (org-open-at-point))
            (cl-assert followed))))
      (goto-char (point-min))
      (re-search-forward "^#\\+begin_src python")
      (let ((org-babel-python-command 'auto))
        (cl-letf (((symbol-function 'yes-or-no-p) (lambda (&rest _) t)))
          (org-babel-execute-src-block)))
      (cl-assert (file-exists-p (expand-file-name "phase.svg" root)))
      (goto-char (point-min))
      (re-search-forward "^#\\+begin_src shell")
      (cl-letf (((symbol-function 'yes-or-no-p) (lambda (&rest _) t)))
        (org-babel-execute-src-block))
      (let ((figure (expand-file-name "phase.pdf" root)))
        (cl-assert (file-exists-p figure))
      (save-buffer)
      (let ((before (file-attribute-modification-time (file-attributes (expand-file-name "phase.svg" root))))
            (figure-before (file-attribute-modification-time (file-attributes figure))))
        (org-html-export-to-html)
        (cl-assert (equal before (file-attribute-modification-time (file-attributes (expand-file-name "phase.svg" root)))))
        (cl-assert (equal figure-before (file-attribute-modification-time (file-attributes figure)))))
      (let ((html (kit/test-file-text (expand-file-name "dispersion.html" root))))
        (cl-assert (string-match-p "phase.svg" html))
        (cl-assert (string-match-p "phase.pdf" html))
        (cl-assert (string-match-p "example-waveguide.pdf" html))
        (cl-assert (string-match-p "Waveguide propagation" html))
        (unless (and (string-match-p "Synthetic Introduction to Waveguides" html)
                     (string-match-p "Example" html))
          (error "Export did not include the reference: %s" html)))
      (condition-case err
          (org-latex-export-to-pdf)
        (error
         (error "PDF export failed: %s\n%s"
                (error-message-string err)
                (if-let ((log (get-buffer "*Org PDF LaTeX Output*")))
                    (with-current-buffer log (buffer-string)) "missing log")))
      (let ((pdf (expand-file-name "dispersion.pdf" root)))
        (cl-assert (and (file-exists-p pdf)
                        (> (file-attribute-size (file-attributes pdf)) 1000)))
        (with-temp-buffer
          (unless (zerop (call-process "pdftotext" nil t nil pdf "-"))
            (error "Could not extract exported PDF text"))
          (let ((text (buffer-string)))
            (dolist (expected '("A Synthetic Introduction to Waveguides"
                                "Normalized phase accumulation" "Example"))
              (unless (string-match-p (regexp-quote expected) text)
                (error "PDF text missing %s: %s" expected text)))))
        (with-temp-buffer
          (unless (zerop (call-process "pdfimages" nil t nil "-list" pdf))
            (error "Could not inspect exported PDF images"))
          (unless (string-match-p "image" (buffer-string))
            (error "PDF export did not embed the generated figure")))))))))

;; Exercise every template using the standard Org-roam capture lifecycle.
;; Concepts, algorithms and papers moved to the learning templates (tests/doom/learning.el).
(dolist (key '("m" "x"))
  (let ((title (concat "Scientific template " key)))
    (org-roam-capture- :keys key :node (org-roam-node-create :title title))
    (let ((buffer (seq-find (lambda (b) (buffer-local-value 'org-capture-mode b)) (buffer-list))))
      (cl-assert buffer)
      (with-current-buffer buffer (insert "Test content") (org-capture-finalize)))
    (org-roam-db-sync)
    (let ((node (org-roam-node-from-title-or-alias title)))
      (cl-assert (and node (org-roam-node-id node))))))
(dolist (key '("d" "e"))
  (cl-assert (assoc key org-roam-capture-templates)))
(dolist (key '("c" "p" "a" "r"))
  (cl-assert (not (seq-some (lambda (entry) (and (equal (car entry) key)
                                                 (string-match-p "concept\\|Algorithm\\|Paper" (cadr entry))))
                            org-roam-capture-templates))))

;; SPC m l i previews links with Org's current command; the obsolete one is bound nowhere in
;; this configuration.
(with-temp-buffer
  (org-mode)
  (evil-normal-state)
  (let ((binding (key-binding (kbd (concat doom-localleader-key " l i")))))
    (cl-assert (eq binding #'org-link-preview) nil "SPC m l i runs %S" binding)))
(dolist (file (directory-files doom-user-dir t "\\.el\\'"))
  (cl-assert (not (string-match-p "org-toggle-inline-images" (kit/test-file-text file))) nil
             "%s still refers to org-toggle-inline-images" file))

;; PDF export of an ordinary note: no LaTeX headers, Greek typed in prose, maths and a citation.
;; The maintained example above brings its own lmodern, so it cannot catch a default-header failure.
(let* ((root (expand-file-name "plain-note-export" (getenv "HOME")))
       (bib (expand-file-name "references.bib" root))
       (export (lambda (name body)
                 (let ((file (expand-file-name (concat name ".org") root)))
                   (with-temp-file file (insert body))
                   (with-current-buffer (find-file-noselect file)
                     (prog1 (condition-case err (expand-file-name (org-latex-export-to-pdf) root)
                              (error (list 'failed (error-message-string err))))
                       (set-buffer-modified-p nil)
                       (kill-buffer)))))))
  (make-directory root t)
  (with-temp-file bib
    (insert "@article{plainkey,\n  author = {Doe, Jane},\n  title = {A plain fixture reference},\n"
            "  journal = {Fixture Letters},\n  year = {2026},\n}\n"))
  (let ((org-cite-global-bibliography (list bib)))
    ;; 2.1: a PDF is produced, with the Greek letters and the resolved citation in it.
    (let ((pdf (funcall export "plain"
                        (concat "#+title: Plain note\n\n"
                                "The permittivity ε and the susceptibility χ(ω) are related [cite:@plainkey].\n"
                                "Inline \\(E = \\epsilon_0 \\epsilon E\\) and displayed:\n"
                                "\\begin{equation}\n\\nabla \\cdot \\mathbf{D} = \\rho_f\n\\end{equation}\n\n"
                                "#+print_bibliography:\n"))))
      (cl-assert (and (stringp pdf) (file-exists-p pdf)) nil "Plain note did not export: %S" pdf)
      (let ((text (with-temp-buffer
                    (call-process "pdftotext" nil t nil (expand-file-name pdf root) "-")
                    (buffer-string))))
        (dolist (expected '("ε" "χ" "ω" "A plain fixture reference"))
          (cl-assert (string-match-p (regexp-quote expected) text) nil
                     "Exported PDF lacks %s:\n%s" expected text))))
    ;; 2.3: a character outside the map is reported, not dropped silently: the PDF is produced
    ;; (latexmk runs non-stop), Org warns about unsupported Unicode, and the log names the character.
    (let* ((warned nil)
           (result (cl-letf (((symbol-function 'display-warning)
                              (lambda (_type message &rest _) (push message warned))))
                     (funcall export "unmapped" "#+title: Unmapped\n\nThe operator ∇ in prose.\n"))))
      (cl-assert (and (stringp result) (file-exists-p result)) nil "No PDF for the unmapped note: %S" result)
      (cl-assert (seq-some (lambda (m) (string-match-p "produced with warnings.*∇ (U\\+2207)" m)) warned)
                 nil "Org did not name the unsupported character: %S" warned))))

;; 2.2: a LaTeX preview with kit-unicode loaded renders a fragment that contains Greek.
(let ((image (expand-file-name "greek-preview.svg" (getenv "HOME"))))
  (kit/test-render "\\(χ(ω) = ε - 1\\)" image '(:foreground "Black" :background "Transparent" :scale 1.0))
  (cl-assert (file-exists-p image)))

;; LaTeX in notes is coloured, so equations stay readable in terminal frames (no previews there).
(cl-assert (equal org-highlight-latex-and-related '(native script entities)))
(with-temp-buffer
  (insert "* Note\nInline \\(\\nabla \\cdot \\mathbf{D} = \\rho_f\\) and displayed:\n"
          "\\begin{equation}\n\\epsilon(\\omega) = 1 + \\chi(\\omega)\n\\end{equation}\n")
  (org-mode)
  (font-lock-ensure)
  (dolist (target '("\\nabla" "\\begin{equation}" "\\chi"))
    (goto-char (point-min))
    (search-forward target)
    (cl-assert (get-text-property (match-beginning 0) 'face) nil
               "LaTeX %s has no face; org-highlight-latex-and-related is %S"
               target org-highlight-latex-and-related)))
t
