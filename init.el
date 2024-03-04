;; I used to be a vim user, but now I'm using emacs :)
;;
;;   ___ | |__         ___ _ __ ___   __ _  ___ ___ 
;;  / _ \| '_ \ _____ / _ \ '_ ` _ \ / _` |/ __/ __|
;; | (_) | | | |_____|  __/ | | | | | (_| | (__\__ \
;;  \___/|_| |_|      \___|_| |_| |_|\__,_|\___|___/
;;

;;;;;;;;;;;;;;;;;; basic appearance
;; Okay, make it more geek, just remove those bars

;; url代理配置
(setq url-proxy-services
  '(("no_proxy" . "^.*example.com")
  ("http" . "localhost:8118")
  ("https" . "localhost:8118")
  ))
;;(setq url-gateway-method 'socks)
;;(setq socks-server '("Default server" "127.0.0.1" 9998 5))

(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(electric-pair-mode)
(auto-revert-mode)
(setq inhibit-startup-message t)
(setq make-backup-files nil)
(setq x-select-enable-clipboard t)
(setq electric-pair-preserve-balance nil)



;; package: auctex 
(load "auctex.el" nil t t)
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)
;; xelatex编译配置
(add-hook 'LaTeX-mode-hook
  (lambda()
  (add-to-list 'TeX-command-list '("XeLaTeX" "%`xelatex%(mode)%' %t" TeX-run-TeX nil t))
  (setq TeX-command-default "xelatex")
  (setq TeX-save-querynil )
  (setq TeX-show-compilation t)
))
;;(add-hook 'org-pomodoro-finished-hook
;;	(lambda ()
;;		(call-process-shell-command "terminal-notifier -message 快休息下继续工作 -title ' 🍅 工作法'" )))


(column-number-mode)
(show-paren-mode 1)
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)
(global-visual-line-mode t)
(set-face-attribute 'default nil :height 140)
(setq visible-bell t)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(set-frame-parameter (selected-frame) 'alpha '(90 . 50))
;;(add-to-list 'default-frame-alist '(alpha . (80 . 50)))
;;;;;;;;;;;;;;;;;; misc
;;(setq browse-url-browser-function 'google-chrome)
(setq browse-url-browser-function 'browse-url-default-macosx-browser)

;;;;;;;;;;;;;;;;;; Package System

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; mirror for Chinese user
;(setq package-archives '(("gnu"   . "http://elpa.emacs-china.org/gnu/")
;			 ("org"   . "http://elpa.emacs-china.org/org/")
;			 ("elpa"  . "http://elpa.emacs-china.org/gnu/")
;                        ("melpa" . "http://elpa.emacs-china.org/melpa/")))
;(setq package-archives '(("gnu"    . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
;                         ("nongnu" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
;                         ("melpa"  . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
;(setq package-archives '(("gnu" . "https://mirrors.ustc.edu.cn/elpa/gnu/")
;                         ("melpa" . "https://mirrors.ustc.edu.cn/elpa/melpa/")
;                         ("nongnu" . "https://mirrors.ustc.edu.cn/elpa/nongnu/")))
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
(eval-and-compile
    (setq use-package-always-ensure t)
    (setq use-package-always-defer t)
    (setq use-package-always-demand nil)
    (setq use-package-expand-minimally t)
    (setq use-package-verbose t))

;;;;;;;;;;;;;;;;;; Packages

;;;;;;;;;;;;;;;;;;;;;;;nerd-icons
(use-package nerd-icons)
(use-package nerd-icons-dired
  :hook
  (dired-mode . nerd-icons-dired-mode))
(use-package nerd-icons-ivy-rich
  :ensure t
  :init
  (nerd-icons-ivy-rich-mode 1)
  (ivy-rich-mode 1))
(use-package nerd-icons-completion
  :config
  (nerd-icons-completion-mode))

;(use-package magit)
(use-package doom-themes
  :defer nil
  :config
  (load-theme 'doom-dracula t)
  (setq doom-themes-enable-bold t
	doom-theme-enable-italic t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; nyan cat, need mplayer installed
(use-package nyan-mode
  :init
  (nyan-mode 0)
  :config
  (setq nyan-animate-nyancat t)
  (setq nyan-wavy-trail t)
  (setq nyan-animate-nyancat t))

(use-package command-log-mode
  :init (command-log-mode 1))

;; for color like "\e[31m Hello World \e[0m"
(use-package ansi-color
  :config
  (defun my-colorize-compilation-buffer ()
    ;;(when (eq major-mode 'compilation-mode)
    ;;  (ansi-color-apply-on-region compilation-filter-start (point-max))))
    (toggle-read-only)
    (ansi-color-apply-on-region compilation-filter-start (point))
    (toggle-read-only))
  :hook (compilation-filter . my-colorize-compilation-buffer))

;; for key sequency completion
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config (setq which-key-idle-delay 0.05))

;; enhencement for emacs original functions and command completion
(use-package counsel)
(use-package ivy)
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
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("s-p" . projectile-command-map)
              ("C-c p" . projectile-command-map)))

(use-package dashboard
  :ensure t
  :after evil
  :defer nil
  :config
  ;(setq dashboard-banner-logo-title "请不要相信胜利就像山坡上的蒲公英一样唾手可得!!!")
  (setq dashboard-banner-logo-title "一切新的东西都是从艰苦斗争中锻炼出来的")
  (setq dashboard-set-file-icons t)
  (setq dashboard-display-icons-p t)
  (setq dashboard-icon-type 'nerd-icons)
  (setq dashboard-set-navigator t)
  (setq dashboard-center-content t)
  (setq dashboard-show-shortcuts t)
  (setq dashboard-footer-messages '("现在就打开日程表接受你今天的挑战吧！！！"))
  (dashboard-setup-startup-hook))

(use-package evil
  :ensure t
  :defer nil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode)
  )

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(use-package org
  :bind(("C-c a" . org-agenda)
	("C-c c" . org-capture))
  :config
  (setq org-agenda-files '("~/github/org/"))
  (setq org-todo-keywords
    '((sequence "BUG(b!)" "|" "FIXED(f!)")
      (sequence "TODO(t!)" "SOMEDAY(s)" "|" "DONE(d!)" "CANCELED(c @/!)")
      ))
  (setq org-agenda-custom-commands
    '(("w" . "任务安排")
      ("wa" "重要且紧急的任务" tags-todo "+PRIORITY=\"375\"")
      ("wb" "重要且不紧急的任务" tags-todo "-weekly-monthly-daily+PRIORITY=\"350\"")
      ("wc" "不重要且紧急的任务" tags-todo "+PRIORITY=\"325\"")
      ("W" "Weekly Review"
       ((stuck "") ;; review stuck projects as designated by org-stuck-projects
        (tags-todo "工作事项")
        (tags-todo "学习事项")
	      (tags-todo "个人爱好事项")
        (tags-todo "每日必做")
        (tags-todo "每周必做")
        (tags-todo "leetcode")
        (tags-todo "code")
        (tags-todo "theory")
	      (tags-todo "algorithm")
	      (tags-todo "emacs")
        ))))
;;  (defvar org-agenda-dir "" "gtd org files location")
  (setq-default org-agenda-dir "~/github/org/")
  (setq org-agenda-file-note (expand-file-name "notes.org" org-agenda-dir))
  (setq org-agenda-file-task (expand-file-name "task.org" org-agenda-dir))
  (setq org-agenda-file-learn (expand-file-name "learn.org" org-agenda-dir))
  (setq org-agenda-file-play (expand-file-name "play.org" org-agenda-dir))
  (setq org-agenda-file-other (expand-file-name "other.org" org-agenda-dir))
  (setq org-agenda-file-idea (expand-file-name "idea.org" org-agenda-dir))
  (setq org-agenda-file-calendar (expand-file-name "calendar.org" org-agenda-dir))
  (setq org-agenda-file-finished (expand-file-name "finished.org" org-agenda-dir))
  (setq org-agenda-file-canceled (expand-file-name "canceled.org" org-agenda-dir))
  (setq org-capture-templates
    '(
      ("w" "工作，高优先级" entry (file+headline org-agenda-file-task "工作事项")
       "* TODO [#375] %? :工作事项: \n  %i\n"
       :empty-lines 1)
      ("l" "学习，中优先级" entry (file+headline org-agenda-file-learn "学习事项")
       "* TODO [#350] %? :学习事项: \n  %i\n"
      :empty-lines 1)
      ("p" "玩，低优先级" entry (file+headline org-agenda-file-play "个人爱好事项")
       "* TODO [#325] %? :个人爱好事项: \n  %i\n"
       :empty-lines 1)
      ("o" "其他杂项，低优先级" entry (file+headline org-agenda-file-other "杂项")
       "* TODO [#325] %? :杂项: \n  %i\n"
       :empty-lines 1)
      ("n" "笔记记录，无优先级" entry (file+headline org-agenda-file-note "快速笔记")
       "* %? :快速笔记: \n  %i\n %U"
       :empty-lines 1)
      ("i" "点子速记，无优先级" entry (file+headline org-agenda-file-idea "闪现点子")
       "* %? :闪现点子: \n  %i\n %U"
       :empty-lines 1)
      )))

(use-package org-superstar
  :hook (org-mode . org-superstar-mode)
  :config
  (setq org-superstar-headline-bullets-list '("◉" "○" "●"))
  (setq org-indent-indentation-per-level 0)
  (setq org-indent-mode 1)
  (setq org-pretty-entities t))

;; great enhencements for nicer handle
;; window movement, better than default C-x o
(use-package ace-window
  :config
    (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
    (setq aw-dispatch-always t)
    (setq aw-ignore-on t)
;;    (setq aw-ignore-current t)
    (set-face-attribute 'aw-leading-char-face nil :height 250)
    :bind
    ("M-o" . ace-window)
    ("M-s 1" . treemacs-select-window)
    ("M-s !" . treemacs-quit)
    )

(use-package company
  :bind (:map company-active-map
              ("M-n" . nil)
              ("M-p" . nil)
              ("C-n" . company-select-next)
              ("C-p" . company-select-previous)))

;; language server protocol(aka lsp) for development
;;(use-package lsp-mode
;;  :hook((java-mode . lsp)
;;        (c-mod . lsp)
;;        (cc-mode . lsp)
;;        (sh-mode . lsp)
;;	(scala-mode . lsp)
;;	(go-mode . lsp)
;;        (lsp-mode . lsp-enable-which-key-integration))
;;  :config
;;    (setq lsp-headerline-breadcrumb-segments '(symbols))
;;    (setq tab-width 2)
;;    (setq-default indent-tabs-mode nil)
;;  :commands lsp)
;;
;;(use-package dap-mode
;;  :after lsp-mode
;;  :config
;;  (dap-mode t)
;;  (dap-ui-mode t)
;;  (dap-tooltip-mode t)
;;  (dap-auto-configure-mode)
;;  (tooltip-mode 1)
;;  )
;;
;;(use-package dap-java
;;  :ensure nil
;;  :config
;;  (dap-register-debug-template "My Runner"
;;                             (list :type "java"
;;                                   :request "launch"
;;                                   :args ""
;;                                   :vmArgs "-ea -Dmyapp.instance.name=myapp_1"
;;                                   :projectName "myapp"
;;                                   :mainClass "com.domain.AppRunner"
;;                                   :env '(("DEV" . "1")))))
;;
;;(setq lsp-keymap-prefix "s-l")
;;
;;;; optional lsp integration with other fantastic basic enhencement
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
;;
;;(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
;;(use-package lsp-treemacs
;;  :commands lsp-treemacs-errors-list
;;  :config
;;  (lsp-treemacs-sync-mode 1))
;;
;;(use-package flycheck
;;  :bind
;;  ("M-s n" . flycheck-next-error)
;;  ("M-s p" . flycheck-previous-error))
;;(use-package yasnippet
;;  :config (yas-global-mode))
;;
;;;; Java
;;(use-package lsp-java
;;	:config
;;;;	(setq lsp-java-server-install-dir "~/.emacs.d/lsp-servers/jdt/")
;;;;	(setq lsp-java-jdt-download-url  "https://download.eclipse.org/jdtls/milestones/0.57.0/jdt-language-server-0.57.0-202006172108.tar.gz")
;;;;	(setq lsp-java-format-settings-url "/home/corona/github/emacs.d/lsp-servers/format-settings/eclipse-java-google-style.xml")
;;;;	(setq lsp-java-format-settings-profile "GoogleStyle")
;;	(add-hook 'java-mode-hook 'lsp))
;;
;;;; Scala
;;;; Enable scala-mode for highlighting, indentation and motion commands
;;(use-package scala-mode
;;  :interpreter
;;    ("scala" . scala-mode))
;;
;;;; Enable sbt mode for executing sbt commands
;;(use-package sbt-mode
;;  :commands sbt-start sbt-command
;;  :config
;;  ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
;;  ;; allows using SPACE when in the minibuffer
;;  (substitute-key-definition
;;   'minibuffer-complete-word
;;   'self-insert-command
;;   minibuffer-local-completion-map)
;;   ;; sbt-supershell kills sbt-mode:  https://github.com/hvesalai/emacs-sbt-mode/issues/152
;;   (setq sbt:program-options '("-Dsbt.supershell=false"))
;;   )
;;;; Add metals backend for lsp-mode
;;;; do not forget to compile metals-emacs
;;;; see https://scalameta.org/metals/docs/editors/emacs.html
;;(use-package lsp-metals
;;  :ensure t)
;;
;;;; Python
;;(use-package lsp-python-ms
;;  :ensure t
;;  :init (setq lsp-python-ms-auto-install-server t)
;;  :hook (python-mode . (lambda ()
;;                          (require 'lsp-python-ms)
;;                          (lsp))))  ; or lsp-deferred
;;
;;;; go lang
;;(use-package go-mode)


;;;;;;;;;;;;;;;;;; key bindings
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;;;;;;;;;;;;;;;;;; chinese input method
;; seems I don't need it anymore, I use rime in my arch linux
;; and system input method toggle works well, so have a rest
;; 
;; (use-package pyim
;;   :demand t
;;   :config
;;   (use-package posframe)
;;   (use-package pyim-basedict
;;     :ensure nil
;;     :config (pyim-basedict-enable))
;;   (setq pyim-page-tooltip 'posframe)
;;   (setq default-input-method "pyim")
;;   (setq pyim-default-scheme 'quanpin)
;;   (setq pyim-page-length 5)
;;   :hook
;;   ((pyim-isearch-mode))
;;   :bind
;;   (("C-\\" . toggle-input-method)
;;    ("C-;" . pyim-delete-word-from-personal-buffer)))
;; 

;;;;;;;;;;;;;;;;;; slides
;;(use-package ox-ioslide)
;;(require 'ox-ioslide)

;;;;;;;;;;;;;;;;;; pomodoro technique
(use-package org-pomodoro
  :config
  ;; 音效是否开启
  (setq org-pomodoro-start-sound-p t)
  (setq org-pomodoro-ticking-sound-p nil)
  (setq org-pomodoro-audio-player "/opt/homebrew/bin/mpv")
  ;; 番茄钟长
  (setq org-pomodoro-length 25)
  (setq org-pomodoro-short-break-length 5)
  (setq org-pomodoro-long-break-length 20)
  ;; 番茄钟音效
  (setq org-pomodoro-start-sound "/Users/pg/workspace/sound-effects/soft-notice.mp3")
  (setq org-pomodoro-finished-sound "/Users/pg/workspace/sound-effects/我的未来不是梦.wav")
  ;;(setq org-pomodoro-finished-sound "/Users/pg/workspace/sound-effects/success.mp3")
  (setq org-pomodoro-short-break-sound "/Users/pg/workspace/sound-effects/soft-notice.mp3")
  (setq org-pomodoro-long-break-sound "/Users/pg/workspace/sound-effects/bell1.mp3")
  ;; 配置音量
  (setq org-pomodoro-start-sound-args "-volume 98")
  (setq org-pomodoro-finished-sound-args "-volume 98")
  (setq org-pomodoro-long-break-sound-args "-volume 98")
  (setq org-pomodoro-short-break-sound-args "-volume 98")
  (setq org-pomodoro-ticking-sound-args "-volume 98"))

;; defined function
(defun org-insert-code (src-code-type)
  "Insert a `SRC-CODE-TYPE' type source code block in org-mode."
  (interactive
   (let ((src-code-types
          '("emacs-lisp" "python" "C" "sh" "java" "js" "clojure" "C++" "css"
            "calc" "asymptote" "dot" "gnuplot" "ledger" "lilypond" "mscgen"
            "octave" "oz" "plantuml" "R" "sass" "screen" "sql" "awk" "ditaa"
            "haskell" "latex" "lisp" "matlab" "ocaml" "org" "perl" "ruby"
            "scheme" "sqlite")))
     (list (ido-completing-read "Source code type: " src-code-types))))
  (progn
    (newline-and-indent)
    (insert (format "#+BEGIN_SRC %s\n" src-code-type))
    (newline-and-indent)
    (insert "#+END_SRC\n")
    (previous-line 2)
    (org-edit-src-code)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(all-the-icons-nerd-fonts yasnippet with-editor which-key use-package scala-mode sbt-mode rainbow-delimiters projectile pfuture org-superstar org-pomodoro nyan-mode nerd-icons ivy-rich hydra ht go-mode flycheck evil doom-themes dashboard counsel company command-log-mode cfrs auctex all-the-icons ace-window)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
