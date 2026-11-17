;;; learning.el -*- lexical-binding: t; -*-
;; Learning capture templates: key, filename and filetag come from Emacs; the body comes from
;; templates/<type>.org in the org directory and is read at capture time.
(require 'cl-lib)
(require 'org-roam)
(require 'org-roam-capture)

(defun kit/test-learning-capture (key title)
  "Capture an Org-roam note with KEY and TITLE; return its file."
  (org-roam-capture- :keys key :node (org-roam-node-create :title title))
  (let ((buffer (seq-find (lambda (b) (buffer-local-value 'org-capture-mode b)) (buffer-list))))
    (cl-assert buffer nil "No capture buffer for key %s" key)
    (with-current-buffer buffer
      (let ((file (buffer-file-name (or (buffer-base-buffer) (current-buffer)))))
        (org-capture-finalize)
        file))))

(defun kit/test-learning-write-fixture (type body)
  (let ((file (kit/learning-template-file type)))
    (make-directory (file-name-directory file) t)
    (write-region body nil file nil 'silent)))

;; Every learning key is present under the "l" group.
(cl-assert (assoc "l" org-roam-capture-templates))
(dolist (spec kit/learning-note-types)
  (cl-assert (assoc (car spec) org-roam-capture-templates) nil "Missing learning key %s" (car spec)))

;; Each key makes <timestamp>-<type>-<slug>.org, tagged with its type, with the fixture body.
(dolist (spec kit/learning-note-types)
  (pcase-let* ((`(,key ,type ,_) spec)
               (title (concat "Learning " type " smoke")))
    (kit/test-learning-write-fixture type (format "* Fixture body for %s\n" type))
    (let ((file (kit/test-learning-capture key title)))
      (cl-assert (string-match-p (format "\\`[0-9]\\{14\\}-%s-learning_%s_smoke\\.org\\'" type type)
                                 (file-name-nondirectory file))
                 nil "Unexpected filename for %s: %s" key file)
      (cl-assert (equal (file-name-directory (file-truename file)) (file-truename org-roam-directory)))
      (let ((text (kit/test-file-text file)))
        (cl-assert (string-match-p (regexp-quote (format "#+filetags: :%s:" type)) text))
        (cl-assert (string-match-p (regexp-quote (format "* Fixture body for %s" type)) text)
                   nil "Body for %s was not the fixture: %s" key text)))))

;; Editing a template takes effect on the next capture, without reloading anything.
(kit/test-learning-write-fixture "concept" "* Edited concept body\n")
(cl-assert (string-match-p "\\* Edited concept body"
                           (kit/test-file-text (kit/test-learning-capture "lc" "Learning concept edited"))))

;; A missing template stops the capture with an error naming the file, and creates no note.
(let ((missing (kit/learning-template-file "paper")))
  (delete-file missing)
  (let ((message (condition-case err
                     (progn (kit/test-learning-capture "lp" "Learning paper missing") nil)
                   (error (error-message-string err)))))
    (cl-assert message nil "Capture with a missing template did not fail")
    (cl-assert (string-match-p (regexp-quote missing) message) nil "Error does not name %s: %s" missing message))
  (when-let ((buffer (seq-find (lambda (b) (buffer-local-value 'org-capture-mode b)) (buffer-list))))
    (with-current-buffer buffer (org-capture-kill)))
  (cl-assert (null (directory-files org-roam-directory nil "paper-learning_paper_missing")))
  (org-roam-db-sync)
  (cl-assert (null (org-roam-node-from-title-or-alias "Learning paper missing"))))

;; A template's leading property drawer becomes the note's file-level drawer, beside :ID:, so
;; Org-roam reads it (e.g. ROAM_REFS); it is not repeated in the body.
(cl-assert (equal (kit/learning-split-drawer ":PROPERTIES:\n:STATUS: stub\n:PREREQ:\n:END:\n* Body\n")
                  '((("STATUS" . "stub") ("PREREQ" . "")) . "* Body\n")))
(cl-assert (equal (kit/learning-split-drawer "* Body\n") '(nil . "* Body\n")))
(kit/test-learning-write-fixture
 "paper" ":PROPERTIES:\n:STATUS: stub\n:ROAM_REFS: @fixturekey2026\n:CITEKEY:\n:END:\n* Summary (mine)\n")
(let* ((file (kit/test-learning-capture "lp" "Learning paper with properties"))
       (text (kit/test-file-text file)))
  (org-roam-db-sync)
  (let ((node (org-roam-node-from-title-or-alias "Learning paper with properties")))
    (cl-assert node)
    (cl-assert (member "fixturekey2026" (org-roam-node-refs node)) nil
               "ROAM_REFS not read from the file-level drawer: %S\n%s" (org-roam-node-refs node) text)
    (cl-assert (equal (cdr (assoc "STATUS" (org-roam-node-properties node))) "stub") nil
               "STATUS is not a file-level property:\n%s" text))
  (cl-assert (= 1 (1- (length (split-string text "^:PROPERTIES:")))) nil "Expected one drawer:\n%s" text)
  (cl-assert (string-match-p "\\`:PROPERTIES:\n\\(?::[A-Z_]+:.*\n\\)*:END:\n#\\+title: " text) nil
             "Drawer is not at the top of the file:\n%s" text)
  (cl-assert (string-match-p "^:CITEKEY:" text))
  (cl-assert (string-match-p "^\\* Summary (mine)" text)))
;; The next capture, from a non-learning template, gets none of those properties.
(let ((text (kit/test-file-text (kit/test-learning-capture "d" "Plain note after learning"))))
  (cl-assert (not (string-match-p ":STATUS:" text)) nil "Properties leaked into a plain note:\n%s" text))

;; Template identity: each key selects the template it is documented for, judged by the note's
;; filetags. A shadowed template, or a template not listed here, fails.
(defconst kit/test-capture-key-tags
  '(("d") ("e" "investigation") ("p" "project") ("i" "investigation") ("b" "benchmark")
    ("a" "adr") ("f" "process") ("F" "process" "platform") ("m" "mathematics") ("x" "experiment")
    ("lc" "concept") ("lp" "paper") ("lg" "algorithm") ("lm" "moc") ("la" "arch"))
  "Every Org-roam capture key and the filetags its note must carry.")

(defun kit/test-file-tags (file)
  (let ((text (kit/test-file-text file)))
    (when (string-match "^#\\+filetags: *\\(.*\\)$" text)
      (split-string (match-string 1 text) ":" t "[ \t]*"))))

(dolist (entry org-roam-capture-templates)
  (when (> (length entry) 2)
    (cl-assert (assoc (car entry) kit/test-capture-key-tags) nil
               "Capture key %S has no expected tags in tests/doom/learning.el" (car entry))))
(dolist (spec kit/learning-note-types)
  (kit/test-learning-write-fixture (nth 1 spec) (format "* Fixture body for %s\n" (nth 1 spec))))
(dolist (expected kit/test-capture-key-tags)
  (let* ((key (car expected))
         (file (kit/test-learning-capture key (format "Identity %s %s" key (if (equal key (downcase key)) "lower" "upper"))))
         (tags (kit/test-file-tags file)))
    (cl-assert (equal (sort (copy-sequence tags) #'string<) (sort (copy-sequence (cdr expected)) #'string<))
               nil "Key %S made a note tagged %S, expected %S (%s)" key tags (cdr expected) file)))

;; Babel blocks run in a pixi workspace with the documented header: `pixi run --as-is` plus :dir.
;; The sandbox has no network, so the workspace has no dependencies; a pixi-only environment
;; variable shows the block ran inside the workspace. An empty workspace has no interpreter of its
;; own (a real lab gets python from conda-forge), so for the installed case the sandbox's python3
;; is passed by path. The uninstalled case uses the documented `python', which only an installed
;; workspace provides.
(let* ((pixi (executable-find "pixi"))
       (python (executable-find "python3"))
       (installed (make-temp-file "learning-lab-" t))
       (fresh (make-temp-file "learning-lab-fresh-" t))
       (manifest "[workspace]\nname = \"learning-lab\"\nversion = \"0.1.0\"\nchannels = []\nplatforms = [\"linux-64\"]\n")
       (block (lambda (dir interpreter)
                (with-temp-buffer
                  (org-mode)
                  (insert (format "#+begin_src python :python \"pixi run --as-is %s\" :dir %s :results output\nimport os\nprint('workspace=' + os.environ.get('PIXI_PROJECT_NAME', 'none'))\n#+end_src\n" interpreter dir))
                  (goto-char (point-min))
                  (cl-letf (((symbol-function 'yes-or-no-p) (lambda (&rest _) t)))
                    (ignore-errors (org-babel-execute-src-block)))
                  (buffer-string)))))
  (cl-assert pixi nil "pixi is not on Emacs's exec-path")
  (dolist (dir (list installed fresh))
    (write-region manifest nil (expand-file-name "pixi.toml" dir) nil 'silent))
  (let ((default-directory (file-name-as-directory installed)))
    (cl-assert (zerop (call-process pixi nil nil nil "install")) nil "pixi install failed in %s" installed))
  (let ((output (funcall block installed python)))
    (cl-assert (string-match-p "workspace=learning-lab" output) nil
               "Block did not run in the workspace (pixi %s): %s\nBabel errors: %s"
               pixi output
               (when-let ((errors (get-buffer "*Org-Babel Error Output*")))
                 (with-current-buffer errors (buffer-string)))))
  ;; Hide the sandbox's python so, as on a host, only an installed workspace provides one.
  (let* ((process-environment
          (cons (concat "PATH=" (string-join (seq-remove (lambda (dir) (string-match-p "-python3-" dir))
                                                         (split-string (getenv "PATH") ":"))
                                             ":"))
                process-environment))
         (output (funcall block fresh "python")))
    (cl-assert (not (string-match-p "workspace=learning-lab" output)) nil "Uninstalled workspace ran: %s" output)
    (cl-assert (not (file-exists-p (expand-file-name ".pixi/envs" fresh))) nil "--as-is installed into %s" fresh)))

;; Only the learning templates set the concept, paper and algorithm tags.
(dolist (entry org-roam-capture-templates)
  (when (> (length entry) 2)
    (let* ((target (plist-get (nthcdr 4 entry) :target))
           (head (and (eq (car-safe target) 'file+head) (nth 2 target))))
      (when (and head (string-match-p ":\\(concept\\|paper\\|algorithm\\):" head))
        (cl-assert (assoc (car entry) kit/learning-note-types) nil
                   "Non-learning template %S sets a learning tag: %s" (car entry) head)))))
t
