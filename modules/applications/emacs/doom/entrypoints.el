;;; entrypoints.el -*- lexical-binding: t; -*-
(defun kit/org-open (payload)
  "Open an Org workflow from a JSON PAYLOAD supplied by a packaged launcher."
  (let* ((data (json-parse-string payload :object-type 'alist))
         (action (alist-get 'action data))
         (key (alist-get 'key data))
         (wayland (alist-get 'wayland data))
         (display (alist-get 'display data))
         (parameters '((window-system . pgtk))))
    (unless (member action '("capture" "agenda" "notes"))
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
    (if (equal action "capture")
        (let ((+org-capture-frame-parameters
               (append '((name . "doom-capture") (transient . t)
                         (kit-org-capture . t) (width . 80) (height . 24))
                       parameters)))
          (condition-case nil
              (+org-capture/open-frame nil key)
            (quit (+org-capture-cleanup-frame-h))))
      (let ((frame (make-frame (append '((name . "Org")) parameters))))
        (select-frame-set-input-focus frame)
        (condition-case err
            (with-selected-frame frame
              (if (equal action "agenda")
                  (org-agenda nil "a")
                (make-directory (expand-file-name "roam" org-directory) t)
                (require 'org-roam)
                (org-roam-node-find)))
          ((error quit)
           (delete-frame frame t)
           (signal (car err) (cdr err)))))))
  t)
