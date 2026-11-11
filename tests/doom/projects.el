;;; projects.el -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'ert)
(require 'org-capture)

(defun kit/test-project-init (directory)
  (make-directory directory t)
  (unless (zerop (call-process "git" nil nil nil "init" "-q" directory))
    (error "Could not initialise test repository %s" directory))
  (file-name-as-directory (file-truename directory)))

(defun kit/test-git-call (directory &rest arguments)
  (let ((default-directory (file-name-as-directory directory)))
    (unless (zerop (apply #'process-file "git" nil nil nil arguments))
      (error "Git command failed in %s: %S" directory arguments))))

(defun kit/test-finish-project-capture (text)
  (let ((buffer (seq-find (lambda (candidate)
                            (buffer-local-value 'org-capture-mode candidate))
                          (buffer-list))))
    (unless buffer (error "Project capture did not open an Org capture buffer"))
    (with-current-buffer buffer
      (insert text)
      (org-capture-finalize))))

(let* ((fixture (expand-file-name "project-fixtures" (getenv "HOME")))
       (repo-one (kit/test-project-init (expand-file-name "one/demo" fixture)))
       (repo-two (kit/test-project-init (expand-file-name "two/demo" fixture)))
       (bare-repo (expand-file-name "bare/demo.git" fixture))
       (linked-worktree (expand-file-name "worktree/demo" fixture))
       (second-worktree (expand-file-name "worktree/second-demo" fixture))
       (outside (expand-file-name "outside" fixture))
       (foreign-project (expand-file-name "foreign/project" fixture))
       (projects-root (expand-file-name "projects" org-directory)))
  (unwind-protect
      (progn
        (with-temp-file (expand-file-name "README" repo-one)
          (insert "bare-worktree fixture\n"))
        (make-directory (expand-file-name "src" repo-one) t)
        (with-temp-file (expand-file-name "src/main.c" repo-one)
          (insert "header\nsource line\n"))
        (kit/test-git-call repo-one "add" "README")
        (kit/test-git-call repo-one "add" "src/main.c")
        (kit/test-git-call repo-one "-c" "user.name=Org Test"
                           "-c" "user.email=org-test@example.invalid"
                           "commit" "-m" "fixture")
        (make-directory (file-name-directory bare-repo) t)
        (kit/test-git-call fixture "clone" "--bare" repo-one bare-repo)
        (make-directory (file-name-directory linked-worktree) t)
        (kit/test-git-call fixture "--git-dir" bare-repo "worktree" "add"
                           "--detach" linked-worktree "HEAD")
        (kit/test-git-call fixture "--git-dir" bare-repo "worktree" "add"
                           "--detach" second-worktree "HEAD")
        (setq linked-worktree (file-name-as-directory (file-truename linked-worktree)))
        (setq second-worktree (file-name-as-directory (file-truename second-worktree)))

        (let ((one-file (kit/org-project-todo-file repo-one))
              (two-file (kit/org-project-todo-file repo-two)))
          (cl-assert (not (equal one-file two-file)))
          (cl-assert (file-in-directory-p one-file
                                          (file-name-as-directory
                                           (expand-file-name "projects" org-directory))))
          (cl-assert (file-in-directory-p two-file
                                          (file-name-as-directory
                                           (expand-file-name "projects" org-directory))))
          (cl-assert (string-match-p (regexp-quote repo-one)
                                     (kit/test-file-text one-file)))
          (cl-assert (string-match-p (regexp-quote repo-two)
                                     (kit/test-file-text two-file))))
        ;; A `.git` file from linked worktrees resolves to their bare common
        ;; directory, so they share one sidecar. A separate clone is distinct.
        (cl-assert (file-regular-p (expand-file-name ".git" linked-worktree)))
        (cl-assert (equal (kit/org-project-todo-file linked-worktree)
                          (kit/org-project-todo-file second-worktree)))
        (cl-assert (not (equal (kit/org-project-id repo-one)
                               (kit/org-project-id linked-worktree))))

        ;; Engineering notes are stored below roam/, but source links resolve
        ;; against the recorded repository root rather than the note location.
        (let* ((frame (selected-frame))
               (old-context (frame-parameter frame 'kit-org-project-context))
               (note (expand-file-name "roam/project-source-link-test.org" org-directory))
               (source (expand-file-name "src/main.c" repo-one)))
          (unwind-protect
              (progn
                (set-frame-parameter
                 frame 'kit-org-project-context
                 (json-encode `((root . ,repo-one) (branch . "main")
                                (commit . "fixture-commit") (file . "src/main.c")
                                (line . "2"))))
                (with-temp-buffer
                  (insert "#+title: source link test\n"
                          (kit/org-project-metadata))
                  (org-mode)
                  (goto-char (point-min))
                  (search-forward "[[file:")
                  (beginning-of-line)
                  (search-forward "[[file:")
                  (org-open-at-point)
                  (cl-assert (equal (file-truename buffer-file-name)
                                    (file-truename source)))
                  (cl-assert (= (line-number-at-pos) 2)))
                (with-temp-file note
                  (insert "#+title: source link note under roam\n"
                          (kit/org-project-metadata)))
                (with-temp-buffer
                  (insert-file-contents note)
                  (org-mode)
                  (goto-char (point-min))
                  (search-forward "[[file:")
                  (beginning-of-line)
                  (search-forward "[[file:")
                  (org-open-at-point)
                  (cl-assert (equal (file-truename buffer-file-name)
                                    (file-truename source)))
                  (cl-assert (= (line-number-at-pos) 2))))
            (set-frame-parameter frame 'kit-org-project-context old-context)))
        (let ((default-directory repo-two))
          (kit/org-project-capture-at-root linked-worktree))
        (kit/test-finish-project-capture "Bare-worktree project task")
        (cl-assert (string-match-p "Bare-worktree project task"
                                   (kit/test-file-text
                                    (kit/org-project-todo-file linked-worktree))))

        ;; Exercise the terminal frame protocol while its visible buffer still
        ;; belongs to repo-two. Explicit context selects the bare worktree.
        (let* ((frame (selected-frame))
               (old-action (frame-parameter frame 'kit-org-action))
               (old-context (frame-parameter frame 'kit-org-project-context))
               (old-terminal (frame-parameter frame 'kit-org-terminal-client))
               (old-capture-frame kit/org-terminal-capture-frame)
               (daemon-buffer (get-buffer-create "*daemon-other-project*"))
               (old-default-directory (buffer-local-value 'default-directory daemon-buffer))
               (org-capture-after-finalize-hook nil))
          (unwind-protect
              (progn
                (with-current-buffer daemon-buffer
                  (setq default-directory repo-two)
                  (set-window-buffer (frame-selected-window frame) (current-buffer)))
                (set-frame-parameter frame 'kit-org-action "project-todo")
                (set-frame-parameter
                 frame 'kit-org-project-context
                 (json-encode `((root . ,linked-worktree))))
                (kit/org-terminal-dispatch)
                (kit/test-finish-project-capture "Terminal context task")
                (cl-assert (string-match-p "Terminal context task"
                                           (kit/test-file-text
                                            (kit/org-project-todo-file linked-worktree))))
                (cl-assert (not (string-match-p "Terminal context task"
                                                (kit/test-file-text
                                                 (kit/org-project-todo-file repo-two))))))
            (setq kit/org-terminal-capture-frame old-capture-frame)
            (with-current-buffer daemon-buffer
              (setq default-directory old-default-directory))
            (set-frame-parameter frame 'kit-org-action old-action)
            (set-frame-parameter frame 'kit-org-project-context old-context)
            (set-frame-parameter frame 'kit-org-terminal-client old-terminal)))

        ;; The terminal path carries repo-one explicitly even while the
        ;; daemon's current buffer belongs to a different same-named project.
        (let ((default-directory repo-two))
          (kit/org-project-capture-at-root repo-one))
        (kit/test-finish-project-capture "Explicit repository task")

        ;; The in-Emacs path discovers repo-two from the current buffer.
        (with-temp-buffer
          (setq default-directory repo-two)
          (kit/org-project-capture-current))
        (kit/test-finish-project-capture "Current project task")

        (let ((one-file (kit/org-project-todo-file repo-one))
              (two-file (kit/org-project-todo-file repo-two)))
          (cl-assert (string-match-p "Explicit repository task"
                                     (kit/test-file-text one-file)))
          (cl-assert (not (string-match-p "Current project task"
                                          (kit/test-file-text one-file))))
          (cl-assert (string-match-p "Current project task"
                                     (kit/test-file-text two-file)))
          (cl-assert (not (string-match-p "Explicit repository task"
                                          (kit/test-file-text two-file))))
          ;; A capture must leave each Git checkout clean.
          (dolist (repo (list repo-one repo-two))
            (let ((default-directory repo))
              (with-temp-buffer
                (unless (zerop (process-file "git" nil t nil "status" "--porcelain"))
                  (error "git status failed in %s" repo))
                (cl-assert (string-empty-p (buffer-string)))))))

        ;; Invalid project roots fail before a sidecar or registration appears.
        (make-directory outside t)
        (let ((before (directory-files projects-root nil "^[0-9a-f]+$")))
          (should-error (kit/org-project-capture-at-root outside) :type 'user-error)
          (cl-assert (equal before
                            (directory-files projects-root nil "^[0-9a-f]+$"))))

        (kit/org-refresh-agenda-files)
        (cl-assert (member (kit/org-project-todo-file repo-one) org-agenda-files))
        (cl-assert (member (kit/org-project-todo-file repo-two) org-agenda-files))
        (cl-assert (not (member (expand-file-name "tasks.org" outside)
                               org-agenda-files)))
        (kit/test-project-init foreign-project)
        (with-temp-file (expand-file-name "tasks.org" foreign-project)
          (insert "* TODO Must not be discovered\n"))
        (make-directory (expand-file-name "projects/missing" org-directory) t)
        (kit/org-refresh-agenda-files)
        (cl-assert (not (member (expand-file-name "tasks.org" foreign-project)
                                org-agenda-files)))
        (cl-assert (not (member (expand-file-name "tasks.org"
                                                  (expand-file-name "projects/missing"
                                                                    org-directory))
                                org-agenda-files)))
        (let ((org-agenda-files (list (kit/org-project-todo-file repo-one))))
          (org-todo-list)
          (with-current-buffer org-agenda-buffer-name
            (unless (string-match-p "Explicit repository task" (buffer-string))
              (error "Project agenda omitted task: %s" (buffer-string)))
            (cl-assert (not (string-match-p "Current project task" (buffer-string))))))

        ;; The launcher action itself stays scoped to its passed repository.
        (let* ((frame (selected-frame))
               (old-action (frame-parameter frame 'kit-org-action))
               (old-context (frame-parameter frame 'kit-org-project-context))
               (old-terminal (frame-parameter frame 'kit-org-terminal-client))
               (daemon-buffer (get-buffer-create "*daemon-other-project*"))
               (old-default-directory (buffer-local-value 'default-directory daemon-buffer)))
          (unwind-protect
              (progn
                (with-current-buffer daemon-buffer
                  (setq default-directory repo-two)
                  (set-window-buffer (frame-selected-window frame) (current-buffer)))
                (set-frame-parameter frame 'kit-org-action "project-agenda")
                (set-frame-parameter
                 frame 'kit-org-project-context
                 (json-encode `((root . ,repo-one))))
                (kit/org-terminal-dispatch)
                (with-current-buffer org-agenda-buffer-name
                  (cl-assert (string-match-p "Explicit repository task" (buffer-string)))
                  (cl-assert (not (string-match-p "Current project task" (buffer-string)))))
                (kit/org-terminal-mode -1))
            (with-current-buffer daemon-buffer
              (setq default-directory old-default-directory))
            (set-frame-parameter frame 'kit-org-action old-action)
            (set-frame-parameter frame 'kit-org-project-context old-context)
            (set-frame-parameter frame 'kit-org-terminal-client old-terminal)))

        ;; An empty non-project directory is not accepted as project context.
        (should-error
         (let ((default-directory (expand-file-name "not-a-project" fixture)))
           (make-directory default-directory t)
           (kit/org-project-capture-current))
         :type 'user-error))
    (dolist (buffer (buffer-list))
      (let ((directory (buffer-local-value 'default-directory buffer)))
        (when (and directory (file-in-directory-p directory fixture))
          (with-current-buffer buffer
            (setq default-directory (file-name-as-directory (getenv "HOME"))))))
      (when-let ((file (buffer-file-name buffer)))
        (when (file-in-directory-p file fixture) (kill-buffer buffer))))
    (setq projectile-known-projects
          (cl-remove-if (lambda (project) (file-in-directory-p project fixture))
                        projectile-known-projects))
    (delete-directory fixture t)))

t
