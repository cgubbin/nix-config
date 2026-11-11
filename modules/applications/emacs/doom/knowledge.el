;;; knowledge.el -*- lexical-binding: t; -*-
(defun kit/org-ensure-layout ()
  "Create missing note destinations, preserving every existing file."
  (dolist (directory '("agenda" "roam" "journal"))
    (make-directory (expand-file-name directory org-directory) t))
  (dolist (relative '("inbox.org" "agenda/tasks.org" "agenda/projects.org"))
    (let ((file (expand-file-name relative org-directory)))
      (unless (file-exists-p file)
        (write-region "" nil file nil 'silent nil 'excl)))))

(defun kit/org-new-node-file ()
  "Return a unique knowledge-note destination for ordinary Org capture."
  (require 'org-id)
  (expand-file-name (concat "roam/" (org-id-new) ".org") org-directory))

(after! org
  (kit/org-ensure-layout)
  (setq org-confirm-babel-evaluate t
        org-default-notes-file (expand-file-name "inbox.org" org-directory)
        org-agenda-files (list org-default-notes-file
                               (expand-file-name "agenda" org-directory))
        org-roam-directory (expand-file-name "roam/" org-directory)
        org-roam-db-location (doom-profile-cache-dir t "org-roam.db")
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
          ("m" "Meeting" entry
           (file+olp+datetree ,(expand-file-name "journal/meetings.org" org-directory))
           "* Meeting %U\n%?\n\n** Actions\n")))
  (map! :leader
        :desc "Capture" "n c" #'org-capture
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
           :unnarrowed t))
        ;; Dailies are transient activity notes, separate from durable nodes.
        org-roam-dailies-directory "../journal/"
        org-roam-dailies-capture-templates
        '(("d" "Daily note" entry "* %<%H:%M> %?"
           :target (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n")))))
