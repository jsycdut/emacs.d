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
(set-face-attribute 'default nil :height 152)


;;;;;;;;;;;;;;;;;; Package System

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
;; mirror for Chinese user
;;(setq package-archives '(("gnu"   . "http://elpa.emacs-china.org/gnu/")
;;                         ("melpa" . "http://elpa.emacs-china.org/melpa/"))
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
