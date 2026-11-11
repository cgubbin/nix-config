;;; entrypoints.el -*- lexical-binding: t; -*-
(defun kit/org-open (payload)
  "Open an Org workflow from a JSON PAYLOAD supplied by a packaged launcher."
  (let* ((data (json-parse-string payload :object-type 'alist))
         (action (alist-get 'action data))
         (key (alist-get 'key data))
         (wayland (alist-get 'wayland data))
         (display (alist-get 'display data))
         (parameters '((window-system . pgtk))))
    (unless (member action '("capture" "agenda" "notes" "project"
                             "project-todo" "project-agenda"))
      (user-error "Unknown Org workflow: %s" action))
    ;; Refresh an already-running daemon too. The client runtime/socket remains
    ;; owned by systemd; only the GUI connection environment is changed here.
    (dolist (pair '(("WAYLAND_DISPLAY" . wayland) ("DISPLAY" . display)
                    ("XAUTHORITY" . authority) ("GDK_BACKEND" . backend)))
      (let ((value (alist-get (cdr pair) data)))
        (setenv (car pair) (unless (string-empty-p value) value))))
    (when (and (string-empty-p wayland) (string-empty-p display))
      (user-error "No graphical display in launch request"))
    (require 'org)
    (if (member action '("capture" "project" "project-todo"))
        (let ((+org-capture-frame-parameters
               (append '((name . "doom-capture") (transient . t)
                         (kit-org-capture . t) (width . 80) (height . 24))
                       `((kit-org-project-context . ,(alist-get 'projectContext data)))
                       parameters)))
          (condition-case nil
              (if (equal action "project-todo")
                  (let* ((context (json-parse-string (alist-get 'projectContext data)
                                                     :object-type 'alist))
                         (root (kit/org-register-project (alist-get 'root context)))
                         (default-directory root))
                    (+org-capture/open-frame nil "p"))
                (+org-capture/open-frame nil (if (equal action "project") "P" key)))
            (quit (+org-capture-cleanup-frame-h))))
      (let ((frame (make-frame (append '((name . "Org")) parameters))))
        (select-frame-set-input-focus frame)
        (condition-case err
            (with-selected-frame frame
              (if (equal action "agenda")
                  (org-agenda nil "a")
                (if (equal action "project-agenda")
                    (let* ((context (json-parse-string (alist-get 'projectContext data)
                                                       :object-type 'alist))
                           (root (kit/org-register-project (alist-get 'root context))))
                      (kit/org-project-agenda-at-root root))
                  (make-directory (expand-file-name "roam" org-directory) t)
                  (require 'org-roam)
                  (org-roam-node-find))))
          ((error quit)
           (delete-frame frame t)
           (signal (car err) (cdr err)))))))
  t)

(defun kit/org-terminal-quit ()
  "Close the terminal Org client and return to its invoking shell."
  (interactive)
  (let ((frame (selected-frame)))
    (when (frame-live-p frame)
      (delete-frame frame t))))

(defun kit/org-agenda-quit-or-close ()
  "Close a terminal agenda client, or quit a regular graphical agenda."
  (interactive)
  (if (frame-parameter (selected-frame) 'kit-org-terminal-client)
      (kit/org-terminal-quit)
    (org-agenda-quit)))

(defvar kit/org-terminal-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "q") #'kit/org-terminal-quit)
    map))

(define-minor-mode kit/org-terminal-mode
  "Minor mode for closing terminal Org clients with q."
  :lighter ""
  :keymap kit/org-terminal-mode-map)

(with-eval-after-load 'evil
  (evil-define-key 'normal kit/org-terminal-mode-map (kbd "q") #'kit/org-terminal-quit))

(with-eval-after-load 'org-agenda
  (define-key org-agenda-mode-map (kbd "q") #'kit/org-agenda-quit-or-close)
  (with-eval-after-load 'evil
    (evil-define-key 'normal org-agenda-mode-map (kbd "q") #'kit/org-agenda-quit-or-close)))

(defun kit/org-terminal-enable-mode (frame)
  "Enable the terminal quit key on FRAME's current buffer."
  (let ((buffer (window-buffer (frame-selected-window frame))))
    (with-current-buffer buffer
      (kit/org-terminal-mode 1))
    (set-frame-parameter
     frame 'kit-org-terminal-buffers
     (cons buffer (frame-parameter frame 'kit-org-terminal-buffers)))))

(defvar kit/org-terminal-capture-frame nil)

(defun kit/org-terminal-capture-finished ()
  "Close the terminal client frame after capture completes or is cancelled."
  (when (frame-live-p kit/org-terminal-capture-frame)
    (let ((frame kit/org-terminal-capture-frame))
      (setq kit/org-terminal-capture-frame nil)
      (set-frame-parameter frame 'kit-org-terminal-capture nil)
      (delete-frame frame t))))

(defun kit/org-terminal-dispatch ()
  "Start the Org workflow named by the selected client frame parameters."
  (let* ((frame (selected-frame))
         (action (frame-parameter frame 'kit-org-action))
         (key (frame-parameter frame 'kit-org-capture-key)))
    (when action
      (set-frame-parameter frame 'kit-org-action nil)
      (set-frame-parameter frame 'kit-org-terminal-client t)
      (unless (member action '("capture" "agenda" "notes" "project"
                               "project-todo" "project-agenda"))
        (user-error "Unknown Org workflow: %s" action))
      (require 'org)
      (pcase action
        ("capture"
         (setq kit/org-terminal-capture-frame frame)
         (set-frame-parameter frame 'kit-org-terminal-capture t)
         (org-capture nil (unless (equal key "") key)))
        ("project"
         (setq kit/org-terminal-capture-frame frame)
         (set-frame-parameter frame 'kit-org-terminal-capture t)
         (org-capture nil "P"))
        ((or "project-todo" "project-agenda")
         (let* ((context (json-parse-string
                          (frame-parameter frame 'kit-org-project-context)
                          :object-type 'alist))
                (root (kit/org-register-project (alist-get 'root context))))
           (setq default-directory root)
           (if (equal action "project-todo")
               (progn
                 (setq kit/org-terminal-capture-frame frame)
                 (set-frame-parameter frame 'kit-org-terminal-capture t)
                 (org-project-capture-capture-for-current-project
                  :capture-template "* TODO %?\n%U\n%i\n"))
             (kit/org-project-agenda-at-root root)
             (kit/org-terminal-enable-mode frame))))
        ("agenda"
         (org-agenda nil "a")
         (kit/org-terminal-enable-mode frame))
        ("notes"
         (make-directory (expand-file-name "roam" org-directory) t)
         (require 'org-roam)
         (org-roam-node-find)
         (kit/org-terminal-enable-mode frame))))))

(defun kit/org-terminal-cleanup-frame (frame)
  "Remove terminal-only key bindings from buffers shown in FRAME."
  (when (frame-parameter frame 'kit-org-terminal-client)
    (dolist (buffer (frame-parameter frame 'kit-org-terminal-buffers))
      (when (buffer-live-p buffer)
        (with-current-buffer buffer
          (kit/org-terminal-mode -1))))
    (when (eq frame kit/org-terminal-capture-frame)
      (setq kit/org-terminal-capture-frame nil))))

(require 'server)
(add-hook 'server-after-make-frame-hook #'kit/org-terminal-dispatch)
(add-hook 'org-capture-after-finalize-hook #'kit/org-terminal-capture-finished)
(add-hook 'delete-frame-functions #'kit/org-terminal-cleanup-frame)
