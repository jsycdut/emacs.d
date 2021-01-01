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
  (load-theme 'doom-one-light t)
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
         ("C-M-j" . 'counsel-switch-buffer)
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
  
;; language server protocol(aka lsp) for development
;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")

(setq lsp-java-server-install-dir "/home/corona/github/emacs.d/lsp-servers/jdt/")
(setq lsp-java-jdt-download-url  "https://download.eclipse.org/jdtls/milestones/0.57.0/jdt-language-server-0.57.0-202006172108.tar.gz")
(setq lsp-keymap-prefix "s-l")

(use-package lsp-mode
    :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
            (java-mode . lsp)
            ;; if you want which-key integration
            (lsp-mode . lsp-enable-which-key-integration))
    :commands lsp)

;; optionally
;;(use-package lsp-ui :commands lsp-ui-mode)
;; if you are helm user
;;(use-package helm-lsp :commands helm-lsp-workspace-symbol)
;; if you are ivy user
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

;; optionally if you want to use debugger
(use-package dap-mode)

;; (use-package dap-LANGUAGE) to load the dap adapter for your language
(use-package projectile)
;;(use-package flycheck)
;;(use-package yasnippet :config (yas-global-mode))
;;(use-package lsp-mode :hook ((lsp-mode . lsp-enable-which-key-integration))
;;  :config (setq lsp-completion-enable-additional-text-edit nil))
;;(use-package company)
;;(use-package lsp-ui)
(use-package lsp-java :config (add-hook 'java-mode-hook 'lsp))
;;(use-package dap-mode :after lsp-mode :config (dap-auto-configure-mode))
;;(use-package dap-java :ensure nil)
;;(use-package helm-lsp)
;;(use-package helm
;;  :config (helm-mode))
;;(use-package lsp-treemacs)


;;;;;;;;;;;;;;;;;; key bindings
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
