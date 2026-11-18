;;; science.el -*- lexical-binding: t; -*-

(after! org
  (let* ((bibliography-dir (expand-file-name "bibliography" org-directory))
         (bibliography (expand-file-name "references.bib" bibliography-dir)))
    (make-directory bibliography-dir t)
    (unless (file-exists-p bibliography)
      (write-region "" nil bibliography nil 'silent nil 'excl))
    (setq org-cite-global-bibliography (list bibliography)
          citar-bibliography (list bibliography)
          citar-library-paths (list (expand-file-name "papers" bibliography-dir))
          org-cite-insert-processor 'citar
          org-cite-follow-processor 'citar
          org-cite-activate-processor 'citar
          org-preview-latex-default-process 'dvisvgm
          org-startup-with-inline-images t
          org-image-actual-width '(700)))
  (require 'org-download)
  (setq org-download-method 'directory
        org-download-heading-lvl nil
        org-download-timestamp "%Y%m%dT%H%M%S-")
  (defun kit/org-download-use-note-assets ()
    "Store captured figures in an assets directory beside this Org note."
    (when buffer-file-name
      (setq-local org-download-image-dir
                  (expand-file-name "assets"
                                    (file-name-sans-extension buffer-file-name)))))
  (add-hook 'org-mode-hook #'kit/org-download-use-note-assets)
  (defun kit/org-noter-start-graphical ()
    "Start Org-noter only in a graphical Emacs frame."
    (interactive)
    (unless (display-graphic-p)
      (user-error "Org-noter needs a graphical PDF viewer; use a zathura: page link in terminal sessions"))
    (require 'org-noter)
    (org-noter))
  (setq org-noter-auto-save-last-location t
        org-noter-notes-search-path (list (expand-file-name "roam/papers" org-directory))
        org-noter-default-notes-file-names '("NOTES.org"))
  (defun kit/org-zathura-follow (link)
    "Open LINK, a local PDF path optionally suffixed by `::page=N', in Zathura."
    (require 'url-util)
    (let* ((page-marker (string-match "::page=\\([1-9][0-9]*\\)\\'" link))
           (page (and page-marker (match-string 1 link)))
           (path (url-unhex-string (if page-marker
                                       (substring link 0 page-marker)
                                     link)))
           (directory (file-name-directory (or buffer-file-name default-directory)))
           (pdf (expand-file-name path directory))
           (launcher (executable-find "org-open-pdf"))
           (context (frame-parameter (selected-frame) 'kit-org-pdf-launch-context)))
      (unless launcher
        (user-error "org-open-pdf is unavailable; rebuild the Home Manager profile"))
      (unless (and (file-regular-p pdf) (file-readable-p pdf)
                   (string-match-p "\\.pdf\\'" (downcase pdf)))
        (user-error "Zathura link does not point to a readable local PDF: %s" pdf))
      (let ((process-environment (copy-sequence process-environment)))
        (when context
          (let ((environment (json-parse-string context :object-type 'alist)))
            (dolist (pair `(("DISPLAY" . display)
                            ("WAYLAND_DISPLAY" . wayland)
                            ("XAUTHORITY" . authority)
                            ("XDG_RUNTIME_DIR" . runtime)))
              (setenv (car pair) (alist-get (cdr pair) environment)))))
        (make-process
         :name (generate-new-buffer-name "org-open-pdf")
         :buffer "*org-open-pdf*"
         :command (append (list launcher pdf) (when page (list page)))
         :noquery t
         :connection-type 'pipe))))
  (org-link-set-parameters "zathura" :follow #'kit/org-zathura-follow)
  ;; Image links. A terminal frame cannot draw images, so they open in a Zellij pane of the
  ;; client's session, drawn by org-view-image with the terminal's protocol (host.el sets
  ;; `kit/org-image-viewer' and `kit/org-image-protocol'). Graphical frames visit the file.
  (defconst kit/org-image-file-regexp "\\.\\(png\\|jpe?g\\|gif\\|svg\\|webp\\)\\'"
    "File names that `kit/org-open-image' handles.")
  (defun kit/org-open-image (file &optional _link)
    "Open image FILE from an Org link: in Emacs on a graphical frame, else in a Zellij pane.
The Zellij session and `zellij' itself come from the frame's client environment: the
daemon has neither, and the client's own `zellij' matches its server's version."
    (let ((image (expand-file-name file)))
      (if (display-graphic-p)
          (find-file image)
        (let* ((environment (frame-parameter nil 'environment))
               (session (getenv-internal "ZELLIJ_SESSION_NAME" environment))
               (path (getenv-internal "PATH" environment))
               (zellij (and session path
                            (let ((exec-path (split-string path path-separator t)))
                              (executable-find "zellij")))))
          (unless zellij
            (user-error "Cannot show image %s in this terminal frame (needs Zellij)" image))
          (make-process
           :name "org-view-image"
           :buffer "*org-view-image*"
           :command (list zellij "--session" session "action" "new-pane" "--close-on-exit"
                          "--name" (file-name-nondirectory image) "--"
                          kit/org-image-viewer kit/org-image-protocol image)
           :noquery t
           :connection-type 'pipe)))))
  (add-to-list 'org-file-apps (cons kit/org-image-file-regexp #'kit/org-open-image))
  ;; Require explicit confirmation for interactive Babel execution. Exported
  ;; documents never execute blocks implicitly; users run chosen blocks first.
  (setq org-confirm-babel-evaluate t
        org-export-use-babel nil)
  (map! :map org-mode-map :localleader
        :desc "Insert citation" "i c" #'org-cite-insert
        :desc "Toggle equation preview" "l p" #'org-latex-preview
        :desc "Preview links (graphical frames)" "l i" #'org-link-preview
        :desc "Start graphical Org-noter" "n" #'kit/org-noter-start-graphical))

(after! oc
  (require 'citar)
  (require 'citar-org))

;; Ordinary notes export to PDF with Org's default header. Its T1 fontenc needs the EC fonts unless
;; Latin Modern is loaded (the Nix TeX set has lm, not EC), and kit-unicode.sty, kept in this
;; directory, turns Greek letters typed in prose into maths symbols. Exports (latexmk) and LaTeX
;; previews both inherit TEXINPUTS; the trailing ":" keeps TeX's default search path.
(after! ox-latex
  (let ((here (file-name-as-directory (expand-file-name doom-user-dir))))
    (unless (string-prefix-p here (or (getenv "TEXINPUTS") ""))
      (setenv "TEXINPUTS" (concat here ":" (or (getenv "TEXINPUTS") "")))))
  (dolist (package '(("" "lmodern" t) ("" "kit-unicode" t)))
    (add-to-list 'org-latex-packages-alist package t))
  ;; Org 9.8's `org-latex--collect-warnings' excuses a "Unicode character" error, then looks for its
  ;; known warnings from after that line, so an unsupported character is dropped from the PDF with
  ;; only "PDF file produced." (and the .log is deleted). Name such characters in the warning.
  (defun kit/org-latex-name-unicode-errors (collect buffer)
    "Call COLLECT on BUFFER and add any unsupported Unicode characters it did not report."
    (let ((warnings (funcall collect buffer))
          (found nil))
      (with-current-buffer buffer
        (save-excursion
          (goto-char (point-min))
          (while (re-search-forward
                  "^! LaTeX Error: Unicode character \\(.\\) (\\(U\\+[0-9A-F]+\\))" nil t)
            (cl-pushnew (format "%s (%s)" (match-string 1) (match-string 2)) found :test #'equal))))
      (if (or (null found) (eq warnings 'error))
          warnings
        (string-join (delq nil (list warnings (concat "unsupported character(s) "
                                                      (string-join (nreverse found) ", "))))
                     " "))))
  (advice-add 'org-latex--collect-warnings :around #'kit/org-latex-name-unicode-errors))

;; Concepts, algorithms and papers are captured with the learning templates (learning.el), so each
;; of those tags has one layout.
(after! org-roam
  (dolist (entry
           '(("m" "Mathematical derivation" plain "* Assumptions\n%?\n\n* Derivation\n\n* Validation\n\n* References\n\n* Related concepts\n"
              :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: :mathematics:\n") :unnarrowed t)
             ("x" "Numerical experiment" plain "* Question and assumptions\n%?\n\n* Method\n\n* Validation\n\n* References\n\n* Related concepts\n"
              :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: :experiment:\n") :unnarrowed t)))
    (add-to-list 'org-roam-capture-templates entry t)))
