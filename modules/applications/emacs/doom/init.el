;;; init.el -*- lexical-binding: t; -*-
(doom! :completion vertico
       :ui doom dashboard modeline (popup +defaults) hl-todo
       :editor (evil +everywhere) file-templates fold snippets
       :emacs dired electric undo vc
       :tools magit
       :lang emacs-lisp (org +roam)
       :config (default +bindings +smartparens))
