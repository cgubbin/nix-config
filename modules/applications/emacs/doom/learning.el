;;; learning.el -*- lexical-binding: t; -*-
;; Capture templates for the learning notes: subject notes written by the owner, from basics to
;; current research. Emacs owns each type's key, filename and filetag. The body is read from
;; templates/<type>.org in the notes repository at capture time, so layouts change there without a
;; rebuild.
;;
;; A template may start with a :PROPERTIES: drawer (e.g. :STATUS: stub, :ROAM_REFS:). Inserted as
;; body text it would land after #+title, where Org does not treat it as file-level, so Org-roam
;; would not read it. The drawer is removed from the body and its properties are put into the new
;; note's file-level drawer, beside :ID:.

(defconst kit/learning-note-types
  '(("lc" "concept" "Concept")
    ("lp" "paper" "Paper")
    ("lg" "algorithm" "Algorithm")
    ("lm" "moc" "Map of content")
    ("la" "arch" "Architecture"))
  "Learning capture keys, note types and descriptions.")

(defvar kit/learning--pending-properties nil
  "File-level properties from the template being captured, applied when its node is created.")

(defun kit/learning-template-file (type)
  "Return the notes repository's template file for learning note TYPE."
  (expand-file-name (concat "templates/" type ".org") org-directory))

(defun kit/learning-split-drawer (body)
  "Split a leading :PROPERTIES: drawer off BODY.
Return (PROPERTIES . REST), where PROPERTIES is an alist of (NAME . VALUE) in drawer order."
  (if (string-match "\\`[ \t\n]*:PROPERTIES:[ \t]*\n\\(\\(?:.*\n\\)*?\\)[ \t]*:END:[ \t]*\\(?:\n\\|\\'\\)" body)
      (let ((drawer (match-string 1 body))
            (rest (substring body (match-end 0)))
            properties)
        (dolist (line (split-string drawer "\n" t))
          (when (string-match "\\`[ \t]*:\\([^: \t]+\\):[ \t]*\\(.*?\\)[ \t]*\\'" line)
            (push (cons (match-string 1 line) (match-string 2 line)) properties)))
        (cons (nreverse properties) rest))
    (cons nil body)))

(defun kit/learning-template-body (type)
  "Return the body for learning note TYPE, read now from the notes repository.
Signal an error naming the file when it is missing. Org's own (file ...) template would
instead create the note with a \"not found\" heading. A leading property drawer is held back
for `kit/learning--apply-properties'."
  (let ((file (kit/learning-template-file type)))
    (unless (file-readable-p file)
      (user-error "Learning template for %s notes is missing: %s" type file))
    (pcase-let ((`(,properties . ,rest)
                 (kit/learning-split-drawer
                  (with-temp-buffer (insert-file-contents file) (buffer-string)))))
      (setq kit/learning--pending-properties properties)
      rest)))

(defun kit/learning--apply-properties ()
  "Put the pending template properties into the new node's drawer.
Runs from `org-roam-capture-new-node-hook', with point on the node."
  (let ((properties kit/learning--pending-properties))
    (setq kit/learning--pending-properties nil)
    (when (and properties (assoc (org-capture-get :key) kit/learning-note-types))
      (dolist (property properties)
        (org-entry-put (point) (car property) (cdr property))))))

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
    (add-to-list 'org-roam-capture-templates entry t))
  (add-hook 'org-roam-capture-new-node-hook #'kit/learning--apply-properties))
