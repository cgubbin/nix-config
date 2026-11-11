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
  ;; Require explicit confirmation for interactive Babel execution. Exported
  ;; documents never execute blocks implicitly; users run chosen blocks first.
  (setq org-confirm-babel-evaluate t
        org-export-use-babel nil)
  (map! :map org-mode-map :localleader
        :desc "Insert citation" "i c" #'org-cite-insert
        :desc "Toggle equation preview" "l p" #'org-latex-preview
        :desc "Toggle inline images" "l i" #'org-toggle-inline-images))

(after! oc
  (require 'citar)
  (require 'citar-org))

(after! org-roam
  (dolist (entry
           '(("p" "Physics concept" plain "* Assumptions\n%?\n\n* Derivation\n\n* Validation\n\n* References\n\n* Related concepts\n"
              :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: :physics:\n") :unnarrowed t)
             ("m" "Mathematical derivation" plain "* Assumptions\n%?\n\n* Derivation\n\n* Validation\n\n* References\n\n* Related concepts\n"
              :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: :mathematics:\n") :unnarrowed t)
             ("a" "Algorithm" plain "* Problem and assumptions\n%?\n\n* Method\n\n* Validation\n\n* References\n\n* Related concepts\n"
              :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: :algorithm:\n") :unnarrowed t)
             ("r" "Paper" plain "* Citation and claims\n%?\n\n* Method and assumptions\n\n* Validation\n\n* References\n\n* Related concepts\n"
              :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: :paper:\n") :unnarrowed t)
             ("x" "Numerical experiment" plain "* Question and assumptions\n%?\n\n* Method\n\n* Validation\n\n* References\n\n* Related concepts\n"
              :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: :experiment:\n") :unnarrowed t)))
    (add-to-list 'org-roam-capture-templates entry t)))
