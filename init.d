;;; init.el --- Tulio's emacs configuration

;;; Commentary:

;; This is a simple Emacs configuration for working with Clojure

;;; Code:

;; Set threshold
(setq gc-cons-threshold 50000000)
(setq large-file-warning-threshold 100000000)

;; Encoding

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;;Package Manager

(setq url-proxy-services
   '(("no_proxy" . "^\\(localhost\\|10\\..*\\|192\\.168\\..*\\)")
     ("http" . "proxy.r-services.at:57165")
     ("https" . "proxy.r-services.at:57165")))

(setq package-check-signature nil)

(require 'package)
(setq package-enable-at-startup nil)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)

(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

;;Daemon Mode

(require 'server)
(if (not (server-running-p)) (server-start))

;; Visual Setup

(menu-bar-mode -1)
(toggle-scroll-bar -1)
(tool-bar-mode -1)
(blink-cursor-mode -1)
(global-hl-line-mode +1)
(line-number-mode +1)
(global-display-line-numbers-mode 1)
(column-number-mode t)
(size-indication-mode t)
(display-time-mode 1)
(fset 'yes-or-no-p 'y-or-n-p)
(global-auto-revert-mode t)

(setq inhibit-startup-screen t)
(org-agenda-list)
(delete-other-windows)

(add-hook 'before-save-hook 'whitespace-cleanup)
;(add-hook 'after-init-hook 'org-agenda-list)

(add-to-list 'default-frame-alist '(font . "Fira Code 10"))

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner "~/.emacs.d/img/avatar.png")
  (setq dashboard-banner-logo-title "Let's make Emacs great again!")
  (setq dashboard-items '((projects . 5)
                          (agenda . 5))))

(use-package smartparens
  :ensure t
  :diminish smartparens-mode
  :config
  (progn
    (require 'smartparens-config)
    (smartparens-global-mode 1)
    (show-paren-mode t)))

(use-package which-key
  :ensure t
  :diminish which-key-mode
  :config
  (which-key-mode +1))

;;Themes

(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-one t)
  (doom-themes-visual-bell-config))

(use-package smart-mode-line-powerline-theme
  :ensure t)

(use-package smart-mode-line
  :ensure t
  :config
  (setq sml/theme 'powerline)
  (add-hook 'after-init-hook 'sml/setup))

;; Backups

(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; Shortkeys

(define-key key-translation-map [dead-diaeresis]
  (lookup-key key-translation-map "\C-x8\""))
(define-key isearch-mode-map [dead-diaeresis] nil)
(global-set-key (kbd "M-u")
                (lookup-key key-translation-map "\C-x8\""))

;; Workstation for development

(use-package org
  :ensure t
  :bind (
         ("C-c o a" . org-agenda)
         ("C-c o l" . org-store-link)))

(add-hook 'org-mode-hook #'org-indent-mode)
(define-key global-map "\C-cc" 'org-capture)

(setq org-capture-templates nil)
(setq org-log-done t)

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

(use-package undo-tree
  :diminish undo-tree-mode
  :config
  (global-undo-tree-mode t))

(use-package magit
  :bind (("C-x g s" . magit-status)
         ("C-x g f" . magit-fetch)
         ("C-x g p" . magit-push)
         ("C-x g b" . magit-branch)))

(use-package projectile
  :ensure t
  :diminish projectile-mode
  :bind
  (("C-c p f" . helm-projectile-find-file)
   ("C-c p p" . helm-projectile-switch-project)
   ("C-c p s" . projectile-save-project-buffers))
  :config
  (projectile-mode +1)
)

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
  (helm-autoresize-mode 1)
  (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
  (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB work in terminal
  (define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z
  )

(use-package ag
  :ensure t
  :commands (ag ag-regexp ag-project)
  :bind ("C-c p a f" . ag-project))

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
  (add-hook 'clojure-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'clojure-mode-hook #'eldoc-mode)
  (add-hook 'clojure-mode-hook #'idle-highlight-mode))

(use-package cider
  :ensure t
  :defer t
  :init (add-hook 'cider-mode-hook #'clj-refactor-mode)
  :diminish subword-mode
  )

(defun cljfmt ()
  (when (or (eq major-mode 'clojure-mode)
            (eq major-mode 'clojurescript-mode))
    (shell-command-to-string (format "/opt/clojure/cljfmt.bin %s" buffer-file-name))
    (revert-buffer :ignore-auto :noconfirm)))

(add-hook 'after-save-hook #'cljfmt)

(use-package lsp-ui)
(add-hook 'lsp-mode-hook 'lsp-ui-mode)

(use-package company-lsp)
(add-hook 'cider-repl-mode-hook #'company-mode)
(add-hook 'cider-mode-hook #'company-mode)
(setq company-idle-delay nil) ; never start completions automatically
(global-set-key (kbd "C-M-i") #'company-complete)

(use-package lsp-mode
  :hook (XXX-mode . lsp)
  :commands lsp)

(setq cider-show-error-buffer nil)
(setq cider-auto-select-error-buffer nil)

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
 '(org-agenda-files
   (quote
    ("~/Org/Agenda/application.org" "~/Org/Agenda/lambda-services.org" "~/Org/Agenda/documentation.org")))
 '(package-selected-packages
   (quote
    (dashboard flycheck-plantuml kibit-helper plantuml-mode flycheck-clojure flycheck-clj-kondo yaml-mode docker org cider clojure-mode better-defaults undo-tree magit helm-c-yasnippet company-lsp lsp-ui flycheck helm-projectile helm projectile use-package ag)))
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
