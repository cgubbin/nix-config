;;; config.el -*- lexical-binding: t; -*-
(load! "host")
;; Prebuilt profiles skip Doom's CLI directory setup. Create only writable
;; runtime directories so first shutdown cannot prompt while saving bookmarks.
(dolist (directory (list (doom-profile-data-dir t)
                        (doom-profile-cache-dir t)
                        (doom-profile-state-dir t)))
  (make-directory directory t))
(load! "entrypoints")
(when-let ((theme-file (locate-library "catppuccin-theme")))
  (add-to-list 'custom-theme-load-path (file-name-directory theme-file)))
(setq catppuccin-flavor 'mocha
      doom-theme 'catppuccin
      display-line-numbers-type nil)
;; Doom's frame hook handles client frames, but a terminal-only daemon may have
;; no graphical frame at init time. Load the selected theme on every startup too.
(add-hook 'after-init-hook #'doom-init-theme-h)
(setq +dashboard-menu-sections
      '(("Capture a thought" :icon "✎" :action org-capture :key "SPC n c")
        ("Open agenda" :icon "◷" :action org-agenda-list :key "SPC n a")
        ("Find a knowledge note" :icon "◇" :action org-roam-node-find :key "SPC n f")
        ("Open today's journal" :icon "☼" :action org-roam-dailies-goto-today :key "SPC n j")
        ("Recent files" :icon "↺" :action recentf-open-files)))
;; Doom's Org defaults are installed lazily; enforce confirmation afterwards.
(after! org
  (setq org-confirm-babel-evaluate t))
(load! "knowledge")
(load! "science")
