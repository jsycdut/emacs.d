;; I used to be a vim user, but now I am using emacs :)
;;
;;   ___ | |__         ___ _ __ ___   __ _  ___ ___ 
;;  / _ \| '_ \ _____ / _ \ '_ ` _ \ / _` |/ __/ __|
;; | (_) | | | |_____|  __/ | | | | | (_| | (__\__ \
;;  \___/|_| |_|      \___|_| |_| |_|\__,_|\___|___/
;;

;;;;;;;;;;;;;;;;;; basic appearance
;; Okay, make it more geek, just remove those bars
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(setq inhibit-startup-message t)
(setq make-backup-files nil)

(column-number-mode)
(global-display-line-numbers-mode t)
(set-face-attribute 'default nil :height 140)
(setq visible-bell t)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;;;;;;;;;;;;;;;;;; misc
(setq browse-url-browser-function 'browse-url-chromium)

;;;;;;;;;;;;;;;;;; Package System

(require 'package)
;;(setq package-archives '(("melpa" . "https://melpa.org/packages/")
;;                         ("org" . "https://orgmode.org/elpa/")
;;                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; mirror for Chinese user
(setq package-archives '(("gnu"   . "http://elpa.emacs-china.org/gnu/")
                         ("melpa" . "http://elpa.emacs-china.org/melpa/")))
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

;; a package named use-package
;; it will manage my packages
;; maybe I should call it a package manager
;; just like vim-plug
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;;;;;;;;;;;;;;;;;; Packages
(use-package doom-themes
  :config
  (load-theme 'doom-gruvbox t)
  (setq doom-themes-enable-bold t
	doom-theme-enable-italic t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package command-log-mode
  :ensure t
  :init (command-log-mode 1))
(use-package all-the-icons)

;; for key sequency completion
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config (setq which-key-idle-delay 0.05))

;; enhencement for emacs original functions and command completion
(use-package swiper
  :diminish
  :bind (("C-s" . swiper)
	 ("C-r" . swiper)
         ("M-s b" . 'counsel-switch-buffer)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (counsel-mode 1)
  (ivy-mode 1))


(use-package ivy-rich
  :init
  (ivy-rich-mode 1))
;; 
;; (use-package helpful
;;   :custom
;;   (counsel-describe-function-function #'helpful-callable)
;;   (counsel-describe-variable-function #'helpful-variable)
;;   :bind
;;   ([remap describe-function] . counsel-describe-function)
;;   ([remap describe-command] . helpful-command)
;;   ([remap describe-variable] . counsel-describe-variable)
;;   ([remap describe-key] . helpful-key))
;;

(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("s-p" . projectile-command-map)
              ("C-c p" . projectile-command-map)))

(use-package evil
  :init
  :config
  (evil-mode 0))

(use-package org)
(use-package org-superstar
  :hook (org-mode . org-superstar-mode)
  :config
  (setq org-superstar-headline-bullets-list '("☰" "☷" "☯" "☭"))
  (setq org-indent-mode 1)
  (setq org-pretty-entities t))

;; great enhencements for nicer handle
;; window movement, better than default C-x o
(use-package ace-window
  :config
    (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
    (setq aw-dispatch-always t)
    :bind("C-x o" . ace-window))

(use-package helm
  :config (helm-mode))

;; (use-package company
;;   :bind (:map company-active-map
;;               ("M-n" . nil)
;;               ("M-p" . nil)
;;               ("C-n" . company-select-next)
;;               ("C-p" . company-select-previous)))

;; language server protocol(aka lsp) for development
(use-package lsp-mode
  :hook((java-mode . lsp)
	  (lsp-mode . lsp-enable-which-key-integration))
  :config
    (setq lsp-headerline-breadcrumb-segments '(symbols))
    (setq tab-width 2)
    (setq-default indent-tabs-mode nil)
  :commands lsp)

(setq lsp-keymap-prefix "s-l")

;;(use-package lsp-mode
;;    :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
;;           (java-mode . lsp)
;;           ;; if you want which-key integration
;;           (lsp-mode . lsp-enable-which-key-integration))
;;    :commands lsp)

;; optional lsp integration with other fantastic basic enhencement
;;(use-package lsp-ui
;;  :commands lsp-ui-mode
;;  :config
;;    (setq lsp-ui-doc-show-with-mouse nil)
;;    (setq lsp-ui-doc-show-with-cursor nil)
;;    (setq lsp-ui-doc-position "top")
;;    (setq lsp-ui-imenu-window-width 28)
;;  :bind
;;  ("M-s d" . lsp-ui-doc-show)
;;  ("M-s D" . lsp-ui-doc-hide)
;;  ("M-s f" . lsp-ui-doc-focus-frame)
;;  ("M-s F" . lsp-ui-doc-unfocus-frame)
;;  ("M-s m" . lsp-ui-imenu)
;;  ("M-s M" . lsp-ui-imenu--kill))

(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)
(use-package helm-lsp :commands helm-lsp-workspace-symbol)
;;(use-package flycheck
;;  :bind
;;  ("M-s n" . flycheck-next-error)
;;  ("M-s p" . flycheck-previous-error))
(use-package yasnippet
  :config (yas-global-mode))

;; Java
(use-package lsp-java
	:config
	(setq lsp-java-server-install-dir "/home/corona/github/emacs.d/lsp-servers/jdt/")
	(setq lsp-java-jdt-download-url  "https://download.eclipse.org/jdtls/milestones/0.57.0/jdt-language-server-0.57.0-202006172108.tar.gz")
	(setq lsp-java-format-settings-url "/home/corona/github/emacs.d/lsp-servers/format-settings/eclipse-java-google-style.xml")
	(setq lsp-java-format-settings-profile "GoogleStyle")
	(add-hook 'java-mode-hook 'lsp))

(use-package dap-java :ensure nil)

;;;;;;;;;;;;;;;;;; key bindings
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
 
