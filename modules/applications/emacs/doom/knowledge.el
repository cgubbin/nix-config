;;; knowledge.el -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'projectile)
(require 'org-project-capture)
(require 'org-projectile)
(projectile-mode 1)

(defun kit/org-ensure-layout ()
  "Create missing note destinations, preserving every existing file."
  (dolist (directory '("agenda" "roam" "journal"))
    (make-directory (expand-file-name directory org-directory) t))
  (dolist (relative '("inbox.org" "agenda/tasks.org" "agenda/projects.org"))
    (let ((file (expand-file-name relative org-directory)))
      (unless (file-exists-p file)
        (write-region "" nil file nil 'silent nil 'excl)))))

(make-directory org-directory t)
(kit/org-ensure-layout)

(defun kit/org-project-root (&optional root)
  "Return canonical Git ROOT, or the project at `default-directory'."
  (let* ((candidate (or root (projectile-project-root)))
         (directory (and candidate (file-name-as-directory
                                     (file-truename candidate)))))
    (unless (and directory (file-directory-p directory)
                 (file-exists-p (expand-file-name ".git" directory)))
      (user-error "Project TODOs require a valid Git repository root"))
    directory))

(defun kit/org-project-id (root)
  "Return a stable collision-resistant identifier for Git ROOT.
Linked worktrees share the common Git directory and therefore one task file."
  (secure-hash 'sha256 (kit/org-project-common-dir root)))

(defun kit/org-project-common-dir (root)
  "Return the canonical Git common directory for worktree ROOT."
  (let* ((canonical (kit/org-project-root root))
         (default-directory canonical)
         (output (with-temp-buffer
                   (unless (zerop (process-file "git" nil t nil
                                                "rev-parse" "--git-common-dir"))
                     (user-error "Cannot resolve Git common directory for %s" canonical))
                   (string-trim (buffer-string))))
         (directory (file-truename (expand-file-name output canonical))))
    (unless (file-directory-p directory)
      (user-error "Git common directory does not exist: %s" directory))
    directory))

(defun kit/org-project-name (root)
  "Return a readable, collision-resistant Projectile name for ROOT."
  (let* ((canonical (kit/org-project-root root))
         (base (file-name-nondirectory (directory-file-name canonical))))
    (format "%s-%s" base (substring (kit/org-project-id canonical) 0 10))))

(defun kit/org-project-todo-file (root)
  "Return and initialize ROOT's private project TODO sidecar."
  (let* ((canonical (kit/org-project-root root))
         (common-dir (kit/org-project-common-dir canonical))
         (directory (expand-file-name
                     (kit/org-project-id canonical)
                     (expand-file-name "projects" org-directory)))
         (file (expand-file-name "tasks.org" directory)))
    (make-directory directory t)
    (unless (file-exists-p file)
      (let ((contents
             (format ":PROPERTIES:\n:PROJECT_ROOT: %s\n:GIT_COMMON_DIR: %s\n:WORKTREE: %s\n:PROJECT_NAME: %s\n:END:\n#+title: %s tasks\n\n* Tasks\n"
                     canonical common-dir canonical (kit/org-project-name canonical)
                     (file-name-nondirectory (directory-file-name canonical)))))
        (condition-case nil
            (write-region contents nil file nil 'silent nil 'excl)
          (file-already-exists nil))))
    file))

(defun kit/org-project-capture-filepath (root)
  "Return Org project-capture's relative sidecar path for ROOT."
  (let* ((canonical (kit/org-project-root root))
         (id (kit/org-project-id canonical)))
    (kit/org-project-todo-file canonical)
    (concat id "/tasks.org")))

(defun kit/org-register-project (root)
  "Register validated Git ROOT with Projectile and return its canonical path."
  (let ((canonical (kit/org-project-root root)))
    (unless (member canonical projectile-known-projects)
      (projectile-add-known-project canonical))
    canonical))

(defun kit/org-project-capture-current ()
  "Capture a TODO for the Projectile project in the current buffer."
  (interactive)
  (let* ((root (kit/org-register-project (projectile-project-root)))
         (default-directory root))
    (org-project-capture-capture-for-current-project
     :capture-template "* TODO %?\n%U\n%i\n")))

(defun kit/org-project-capture-at-root (root)
  "Capture a TODO for explicit Git ROOT, independent of the daemon buffer."
  (let* ((canonical (kit/org-register-project root))
         (default-directory canonical))
    (org-capture nil "p")))

(defun kit/org-project-agenda-at-root (root)
  "Show only TODOs for validated Git ROOT."
  (let* ((canonical (kit/org-register-project root))
         (file (kit/org-project-todo-file canonical))
         (org-agenda-files (list file))
         (kit/org-preserve-agenda-files t)
         (org-agenda-overriding-header
          (format "Project TODOs: %s" (kit/org-project-name canonical))))
    (org-todo-list)))

(defun kit/org-project-agenda-current ()
  "Show TODOs for the current Projectile project."
  (interactive)
  (kit/org-project-agenda-at-root (projectile-project-root)))

(defun kit/org-project-agenda-files ()
  "Return existing, registered task sidecars from this host's Org root."
  (let ((directory (expand-file-name "projects" org-directory)))
    (when (file-directory-p directory)
      (cl-loop for project-dir in (directory-files directory t "^[^.]")
               for task-file = (expand-file-name "tasks.org" project-dir)
               when (and (file-directory-p project-dir)
                         (file-readable-p task-file)
                         (file-in-directory-p (file-truename task-file)
                                              (file-name-as-directory
                                               (file-truename directory))))
               collect task-file))))

(defvar kit/org-preserve-agenda-files nil
  "When non-nil, keep a caller's dynamically selected agenda sources.")

(defun kit/org-refresh-agenda-files (&rest _)
  "Refresh agenda sources before an agenda is assembled."
  (unless kit/org-preserve-agenda-files
    (setq org-agenda-files
          (append (list org-default-notes-file
                        (expand-file-name "agenda" org-directory))
                  (kit/org-project-agenda-files)))))

(defun kit/org-new-node-file ()
  "Return a unique knowledge-note destination for ordinary Org capture."
  (require 'org-id)
  (expand-file-name (concat "roam/" (org-id-new) ".org") org-directory))

(defun kit/org-project-metadata ()
  "Format repository context passed by the `org-project-capture' launcher."
  (let* ((payload (frame-parameter (selected-frame) 'kit-org-project-context))
         (data (and payload (json-parse-string payload :object-type 'alist)))
         (field (lambda (key) (or (alist-get key data) "")))
         (root (funcall field 'root))
         (branch (funcall field 'branch))
         (commit (funcall field 'commit))
         (permalink (funcall field 'permalink))
         (file (funcall field 'file))
         (line (funcall field 'line)))
    (concat
     (format "#+property: REPOSITORY %s\n" (if (string-empty-p root) "" root))
     (format "#+property: BRANCH %s\n" branch)
     (format "#+property: COMMIT %s\n" commit)
     (if (string-empty-p file) ""
       (let* ((absolute (expand-file-name file root))
              (anchor (if (string-empty-p line) "" (concat "::" line)))
              (label (concat file (if (string-empty-p line) "" (concat ":" line)))))
         (format "#+property: SOURCE [[file:%s%s][%s]]\n" absolute anchor label)))
     (if (string-empty-p permalink) ""
       (format "#+property: PERMALINK [[%s][commit source]]\n" permalink)))))

(after! org
  (setq org-confirm-babel-evaluate t
        org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAITING(w@/!)" "|" "DONE(d!)" "CANCELLED(c@)"))
        org-default-notes-file (expand-file-name "inbox.org" org-directory)
        org-roam-directory (expand-file-name "roam/" org-directory)
        org-roam-db-location (doom-profile-cache-dir t "org-roam.db")
        org-latex-pdf-process
        '("latexmk -pdf -interaction=nonstopmode -output-directory=%o %f")
        org-cite-export-processors '((latex biblatex) (t basic))
        org-cite-biblatex-options "style=numeric,backend=biber"
        org-capture-templates
        `(("i" "Inbox" entry (file+headline ,org-default-notes-file "Inbox")
           "* %U %?\n%i\n")
          ("t" "TODO task" entry
           (file+headline ,(expand-file-name "agenda/tasks.org" org-directory) "Tasks")
           "* TODO %?\n%U\n%i\n")
          ("c" "Scientific concept" plain (file kit/org-new-node-file)
           ":PROPERTIES:\n:ID: %(org-id-new)\n:END:\n#+title: %?\n#+filetags: :concept:\n\n* Idea\n\n* References\n"
           :unnarrowed t)
          ("e" "Engineering investigation" plain (file kit/org-new-node-file)
           ":PROPERTIES:\n:ID: %(org-id-new)\n:END:\n#+title: %?\n#+filetags: :investigation:\n\n* Question\n\n* Evidence\n\n* Next steps\n"
           :unnarrowed t)
          ("P" "Project-context engineering note" plain (file kit/org-new-node-file)
           ":PROPERTIES:\n:ID: %(org-id-new)\n:END:\n#+title: %?\n#+filetags: :engineering:\n%(kit/org-project-metadata)\n* Context\n\n* Findings\n\n* Next steps\n"
           :unnarrowed t)
          ("m" "Meeting" entry
           (file+olp+datetree ,(expand-file-name "journal/meetings.org" org-directory))
           "* Meeting %U\n%?\n\n** Actions\n")))
  (setq projectile-project-name nil
        projectile-project-name-function #'kit/org-project-name
        projectile-auto-discover-projects nil
        org-project-capture-projects-directory
        (file-name-as-directory (expand-file-name "projects" org-directory))
        org-project-capture-per-project-filepath #'kit/org-project-capture-filepath
        org-project-capture-add-category-to-new-files nil
        org-project-capture-default-backend
        (make-instance 'org-project-capture-projectile-backend)
        org-project-capture-strategy
        (make-instance 'org-project-capture-per-project-strategy))
  (add-to-list 'org-capture-templates
               (org-project-capture-project-todo-entry
                :capture-character "p"
                :capture-heading "Project TODO"
                :capture-template "* TODO %?\n%U\n%i\n") t)
  (kit/org-refresh-agenda-files)
  (advice-add 'org-agenda :before #'kit/org-refresh-agenda-files)
  (map! :leader
        :desc "Capture" "n c" #'org-capture
        :desc "Capture project TODO" "n p" #'kit/org-project-capture-current
        :desc "Project agenda" "n P" #'kit/org-project-agenda-current
        :desc "Agenda" "n a" #'org-agenda
        :desc "Find knowledge node" "n f" #'org-roam-node-find
        :desc "Today's journal" "n j" #'org-roam-dailies-goto-today))

(after! org-roam
  (setq org-roam-capture-templates
        '(("d" "Note" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n")
           :unnarrowed t)
          ("c" "Scientific concept" plain "* Idea\n%?\n\n* References\n"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :concept:\n")
           :unnarrowed t)
          ("e" "Engineering investigation" plain "* Question\n%?\n\n* Evidence\n\n* Next steps\n"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :investigation:\n")
           :unnarrowed t)
          ("p" "Project overview" plain
           "* Overview\n%?\n\n* Architecture\n\n* Active work\n\n* References\n"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :project:\n")
           :unnarrowed t)
          ("i" "Engineering investigation" plain
           "* Question\n%?\n\n* Evidence\n\n* Findings\n\n* Next steps\n\n* References\n"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :investigation:\n")
           :unnarrowed t)
          ("b" "Benchmark" plain
           "* Question\n%?\n\n* Environment\n\n* Method\n\n* Results\n\n* Interpretation\n\n* Reproduction\n"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :benchmark:\n")
           :unnarrowed t)
          ("a" "Architecture decision record" plain
           "* Status\nProposed\n\n* Context\n%?\n\n* Decision\n\n* Alternatives\n\n* Consequences\n\n* References\n"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :adr:\n")
           :unnarrowed t)
          ;; One note per fab process manual; the body lives in the notes repository so it can
          ;; change without a rebuild.
          ("F" "Fab platform" plain (file "~/notes/work/templates/platform.org")
           :target (file+head "%<%Y%m%d%H%M%S>-platform-${slug}.org"
                              "#+title: Platform: ${title}\n#+filetags: :process:platform:\n")
           :unnarrowed t))
        ;; Dailies are transient activity notes, separate from durable nodes.
        org-roam-dailies-directory "../journal/"
        org-roam-dailies-capture-templates
        '(("d" "Daily note" entry "* %<%H:%M> %?"
           :target (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n")))))
