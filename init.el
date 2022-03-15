;;; init.el --- Tulio's emacs configuration

;;; Commentary:

;; This is a simple Emacs configuration for working with Clojure

;;; Code:

;; Set threshold

(setq gc-cons-threshold 50000000
      gc-cons-percentage 0.7
      large-file-warning-threshold 100000000
      frame-inhibit-implied-resize t)

;; Encoding

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;;Package Manager

(setq package-check-signature nil
      package-enable-at-startup nil)

(require 'package)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/") t)
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)

(setq package-archive-priorities '(("gnu" . 30)
                                   ("melpa" . 25)
n                                   ("org" . 10)))

(setq package-selected-packages
      '(ag
        better-defaults
        cider
        cojure-mode
        dashboard
        docker
        flycheck
        flycheck-clj-kondo
        flycheck-clojure
        flycheck-plantuml
        helm
        helm-c-yasnippet
        helm-projectile
        kibit-helper
        lsp-mode
        lsp-ui
        magit
        org
        org-journal
        org-roam
        org-roam-server
        plantuml-mode
        projectile
        smartparens
        undo-tree
        use-package
        yaml-mode
        which-key))

(package-initialize)

(unless (package-installed-p 'use-package)
        (package-refresh-contents)
        (package-install 'use-package))

(eval-when-compile
 (require 'use-package))

;;Daemon Mode

(require 'server)
(if (not (server-running-p)) (server-start))

;; Themes
(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
(add-to-list 'default-frame-alist '(ns-appearance . dark))

(use-package doom-themes
  :ensure t
  :config (load-theme 'doom-molokai t))

;; (add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")

;; (load-theme 'spolsky t)

;; Visual Setup

(setq inhibit-startup-screen t)
(global-hl-line-mode +1)
(global-auto-revert-mode t)
(global-prettify-symbols-mode 1)
(global-display-line-numbers-mode)

(menu-bar-mode -1)
(toggle-scroll-bar -1)
(tool-bar-mode -1)
(blink-cursor-mode -1)
(line-number-mode +1)
(column-number-mode t)
(size-indication-mode t)
(display-time-mode 1)
(fset 'yes-or-no-p 'y-or-n-p)

(org-agenda-list)
(delete-other-windows)

(add-hook 'before-save-hook 'whitespace-cleanup)

(set-frame-font "-CTDB-FiraCode Nerd Font-light-normal-normal-11-16-*-*-*-d-0-iso10646-1")
(use-package fira-code-mode
  :custom (fira-code-mode-disabled-ligatures '("[]" "x"))  ; ligatures you don't want
  :hook prog-mode)                                         ; mode to enable fira-code-mode in

;; Shortkeys

(define-key key-translation-map [dead-diaeresis]
  (lookup-key key-translation-map "\C-x8\""))
(define-key isearch-mode-map [dead-diaeresis] nil)
(global-set-key (kbd "M-u")
                (lookup-key key-translation-map "\C-x8\""))

;; Backups

(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; Dashboard

(use-package dashboard
             :ensure t
             :config
             (dashboard-setup-startup-hook)
             (setq dashboard-startup-banner "~/.emacs.d/img/avatar.png")
             (setq dashboard-banner-logo-title "Let's make Emacs great again!")
             (setq dashboard-items '((projects . 5)
                                     (agenda . 5))))


;; Workstation for development

(use-package org
             :ensure t
             :bind (("C-c o a" . org-agenda)
                    ("C-c o l" . org-store-link)))

(define-key global-map "\C-cc" 'org-capture)

(setq org-todo-keyword-faces
      '(("TODO" . org-warning)
        ("BUG" . org-warning)
        ("IN_PROGRESS" . "yellow")
        ("ON_HOLD" . "yellow")
        ("DONE" . "blue")
        ("FIXED" . "blue")
        ("ANSWERED" . "blue")))

(setq org-todo-keywords
      '((sequence "TODO(t)" "|" "IN_PROGRESS(w)" "|" "ON_HOLD(h)" "DONE(d)")
        (sequence "BUG(b)" "|" "FIXED")
        (sequence "QUESTION" "|" "ANSWERED")))

(use-package org-bullets
  :ensure t
  :after org)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(use-package org-roam
             :after org
             :init (setq org-roam-v2-ack t)
             :custom (org-roam-directory (file-truename (concat (getenv "HOME") "/org/roam")))
             :config
             (org-roam-db-autosync-enable)
             (setq org-roam-db-location (concat org-roam-directory "org-roam.db")
                   org-roam-capture-templates '(("d" "default" plain "%?"
                                                     :if-new (file+head "${slug}.org"
                                                                        "#+title: ${title}\n#+date: %U\n\n")
                                                     :unnarrowed t
                                                     :immediate-finish t)))
             :bind (("C-c n f" . org-roam-node-find)
                    (:map org-mode-map
                          (("C-c n i" . org-roam-node-insert)
                           ("C-c n o" . org-id-get-create)
                           ("C-c n t" . org-roam-tag-add)
                           ("C-c n a" . org-roam-alias-add)
                           ("C-c n l" . org-roam-buffer-toggle)
                           ("C-c n g" . org-roam-graph)))))

(use-package magit
             :bind (("C-x g s" . magit-status)
                    ("C-x g f" . magit-fetch)
                    ("C-x g p" . magit-push)
                    ("C-x g b" . magit-branch)))

(use-package undo-tree
             :diminish undo-tree-mode
             :config
             (global-undo-tree-mode t))

 (use-package which-key
    :config
    (add-hook 'after-init-hook 'which-key-mode))

(use-package projectile
             :ensure t
             :diminish projectile-mode
             :bind
             (("C-c p f" . helm-projectile-find-file)
              ("C-c p p" . helm-projectile-switch-project)
              ("C-c p s" . projectile-save-project-buffers))
             :config
             (projectile-mode +1))

(use-package ag
             :ensure t
             :commands (ag ag-regexp ag-project)
             :bind ("C-c p a f" . ag-project))

(use-package helm
             :ensure t
             :defer 2
             :bind
             ("M-x" . helm-M-x)
             ("C-x C-f" . helm-find-files)
             ("M-y" . helm-show-kill-ring)
             ("C-x b" . helm-mini)
             :config
             (require 'helm-config)
             (helm-mode 1)
             (setq helm-split-window-inside-p t
                   helm-move-to-line-cycle-in-source t)
             (setq helm-autoresize-max-height 0)
             (setq helm-autoresize-min-height 20)
             (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
             (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB work in terminal
             (define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z
)

(use-package helm-projectile
             :ensure t
             :config
             (helm-projectile-on))

(require 'yasnippet)

(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))

(use-package scala-mode
             :mode "\\.s\\(cala\\|bt\\)$")

;; Clojure Mode
(use-package better-defaults
             :ensure t)

(use-package flycheck
             :ensure t
             :diminish flycheck-mode
             :config
             (add-hook 'after-init-hook #'global-flycheck-mode))

(use-package smartparens
             :config (add-hook 'prog-mode-hook 'smartparens-mode))

(use-package clojure-mode
             :ensure t
             :mode (("\\.clj\\'" . clojure-mode)
                    ("\\.cljs\\'" . clojure-mode)
                    ("\\.cljc\\'" . clojure-mode)
                    ("\\.edn\\'" . clojure-mode))
             :config (use-package flycheck-clj-kondo :ensure t)
             :init
             (add-hook 'clojure-mode-hook #'yas-minor-mode)
             (add-hook 'clojure-mode-hook #'linum-mode)
             (add-hook 'clojure-mode-hook #'subword-mode)
             (add-hook 'clojure-mode-hook #'smartparens-mode)
             (add-hook 'clojure-mode-hook #'eldoc-mode))

(use-package cider
             :ensure t
             :defer t
             :init (setq cider-show-error-buffer nil
                         cider-auto-select-error-buffer nil
                         cider-repl-wrap-history t
                         cider-repl-use-clojure-font-lock t
                         cider-repl-use-pretty-printing t
                         cider-repl-buffer-size-limit 100000)
             :diminish subword-mode)

(defun cljfmt ()
  (when (or (eq major-mode 'clojure-mode)
            (eq major-mode 'clojurescript-mode))
    (shell-command-to-string (format "/opt/clojure/cljfmt.bin %s" buffer-file-name))
    (revert-buffer :ignore-auto :noconfirm)))

(add-hook 'after-save-hook #'cljfmt)

(use-package lsp-mode
  :init (setq lsp-keymap-prefix "C-c l"
              lsp-eldoc-enable-hover nil
              lsp-ui-doc-enable t
              lsp-lens-enable t
              lsp-enable-indentation t
              lsp-ui-doc-show-with-cursor nil
              lsp-ui-sideline-show-code-actions nil
              lsp-modeline-diagnostics-enable t)
  :hook ((clojure-mode . lsp)
         (clojurec-mode-hook . lsp)
         (clojurescript-mode . lsp))
  :commands lsp)

(use-package lsp-ui :commands lsp-ui-mode)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#1e1e1e" "#D16969" "#579C4C" "#D7BA7D" "#339CDB" "#C586C0" "#85DDFF" "#d4d4d4"])
 '(custom-safe-themes
   (quote
    ("1c8171893a9a0ce55cb7706766e57707787962e43330d7b0b6b0754ed5283cda" "d1c7f2db070c96aa674f1d61403b4da1fff2154163e9be76ce51824ed5ca709c" "0736a8e34702a67d84e32e2af90145ed19824f661776a0e966cea62aa1943a6e" "d5f8099d98174116cba9912fe2a0c3196a7cd405d12fa6b9375c55fc510988b5" "e1ef2d5b8091f4953fe17b4ca3dd143d476c106e221d92ded38614266cea3c8b" "2cdc13ef8c76a22daa0f46370011f54e79bae00d5736340a5ddfe656a767fddf" "be9645aaa8c11f76a10bcf36aaf83f54f4587ced1b9b679b55639c87404e2499" "84d2f9eeb3f82d619ca4bfffe5f157282f4779732f48a5ac1484d94d5ff5b279" default)))
 '(fci-rule-color "#37474F")
 '(jdee-db-active-breakpoint-face-colors (cons "#171F24" "#237AD3"))
 '(jdee-db-requested-breakpoint-face-colors (cons "#171F24" "#579C4C"))
 '(jdee-db-spec-breakpoint-face-colors (cons "#171F24" "#777778"))
 '(objed-cursor-color "#D16969")
 '(pdf-view-midnight-colors (cons "#d4d4d4" "#1e1e1e"))
 '(rustic-ansi-faces
   ["#1e1e1e" "#D16969" "#579C4C" "#D7BA7D" "#339CDB" "#C586C0" "#85DDFF" "#d4d4d4"])
 '(vc-annotate-background "#1e1e1e")
 '(vc-annotate-color-map
   (list
    (cons 20 "#579C4C")
    (cons 40 "#81a65c")
    (cons 60 "#acb06c")
    (cons 80 "#D7BA7D")
    (cons 100 "#d8ab79")
    (cons 120 "#d99c76")
    (cons 140 "#DB8E73")
    (cons 160 "#d38b8c")
    (cons 180 "#cc88a6")
    (cons 200 "#C586C0")
    (cons 220 "#c97ca3")
    (cons 240 "#cd7286")
    (cons 260 "#D16969")
    (cons 280 "#ba6c6c")
    (cons 300 "#a37070")
    (cons 320 "#8d7374")
    (cons 340 "#37474F")
    (cons 360 "#37474F")))
 '(vc-annotate-very-old-color nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
)

(provide 'init)
;;; init.el ends here

;; Local Variables:
;; eval: (outline-minor-mode)
;; End:
