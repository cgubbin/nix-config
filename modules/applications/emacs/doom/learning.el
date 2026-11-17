;;; learning.el -*- lexical-binding: t; -*-
;; Capture templates for the learning notes: subject notes written by the owner, from basics to
;; current research. Emacs owns each type's key, filename and filetag. The body is read from
;; templates/<type>.org in the notes repository at capture time, so layouts change there without a
;; rebuild.

(defconst kit/learning-note-types
  '(("lc" "concept" "Concept")
    ("lp" "paper" "Paper")
    ("lg" "algorithm" "Algorithm")
    ("lm" "moc" "Map of content")
    ("la" "arch" "Architecture"))
  "Learning capture keys, note types and descriptions.")

(defun kit/learning-template-file (type)
  "Return the notes repository's template file for learning note TYPE."
  (expand-file-name (concat "templates/" type ".org") org-directory))

(defun kit/learning-template-body (type)
  "Return the body for learning note TYPE, read now from the notes repository.
Signal an error naming the file when it is missing. Org's own (file ...) template would
instead create the note with a \"not found\" heading."
  (let ((file (kit/learning-template-file type)))
    (unless (file-readable-p file)
      (user-error "Learning template for %s notes is missing: %s" type file))
    (with-temp-buffer
      (insert-file-contents file)
      (buffer-string))))

(defun kit/learning-capture-templates ()
  "Return the Org-roam capture templates for the learning notes."
  (cons '("l" "Learning notes")
        (mapcar (lambda (spec)
                  (pcase-let ((`(,key ,type ,description) spec))
                    `(,key ,description plain
                      (function ,(apply-partially #'kit/learning-template-body type))
                      :target (file+head ,(concat "%<%Y%m%d%H%M%S>-" type "-${slug}.org")
                                         ,(concat "#+title: ${title}\n#+filetags: :" type ":\n"))
                      :unnarrowed t)))
                kit/learning-note-types)))

(after! org-roam
  (dolist (entry (kit/learning-capture-templates))
    (add-to-list 'org-roam-capture-templates entry t)))
