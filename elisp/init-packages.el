;; 包管理，设置为子龙山人的配置
;; 代理，直连外网配置
(setq url-proxy-services
      '(("http" . "localhost:8118")
	("https" . "localhost:8118")))
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")
			 ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

(assq-delete-all 'org package--builtins)
(assq-delete-all 'org package--builtin-versions)

;; 刷新包内容

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(use-package restart-emacs
  :ensure t)  

(use-package savehist
  :ensure nil
  :hook (after-init . savehist-mode)
  :init (setq enable-recursive-minibuffers t ; Allow commands in minibuffers
              history-length 1000
              savehist-additional-variables '(mark-ring
                                              global-mark-ring
                                              search-ring
                                              regexp-search-ring
                                              extended-command-history)
              savehist-autosave-interval 300)
  )

(use-package saveplace
  :ensure nil
  :hook (after-init . save-place-mode))


(use-package simple
  :ensure nil
  :hook (after-init . size-indication-mode)
  :init
  (progn
    (setq column-number-mode t)
    ))

;;modeline上显示我的所有的按键和执行的命令
;;(package-install 'keycast)
;;(add-to-list 'global-mode-string '("" keycast-mode-line))
;;(keycast-mode t)
(use-package keycast
  :ensure t
  :commands (+toggle-keycast)
  :config
  (defun +toggle-keycast()
    (interactive)
    (if (member '("" keycast-mode-line " ") global-mode-string)
        (progn (setq global-mode-string (delete '("" keycast-mode-line " ") global-mode-string))
               (remove-hook 'pre-command-hook 'keycast--update)
               (message "Keycast OFF"))
      (add-to-list 'global-mode-string '("" keycast-mode-line " "))
      (add-hook 'pre-command-hook 'keycast--update t)
      (message "Keycast ON"))))


;; 这里的执行顺序非常重要，doom-modeline-mode 的激活时机一定要在设置global-mode-string 之后‘
(use-package doom-modeline
  :ensure t

  :init
  (doom-modeline-mode t))

;; keycast包，记录按键信息展示在bar中
;;(use-package keycast :ensure t)
;;(keycast-mode-line-mode t)

;;垂直展示补全等信息，比横向的好看些，而且结合marginalia
(use-package vertico :ensure t)
(vertico-mode t)

;; 支持模糊搜索，不用管多个单词的命令的顺序
(use-package orderless :ensure t)
(setq completion-styles '(orderless))

;; 解释候选项
(use-package marginalia :ensure t)
(marginalia-mode t)

;; 增强插件
(use-package embark :ensure t)
(global-set-key (kbd "C-;") 'embark-act)
(setq prefix-help-command 'embark-prefix-help-command)
(use-package consult :ensure t)
(use-package embark-consult :ensure t)
(global-set-key (kbd "C-s") 'consult-line)
(global-set-key (kbd "M-s i") 'consult-imenu)

(use-package doom-themes
  :ensure t)
;; which-key插件用于在你按下某个快捷键的一部分的时候，弹窗提示你后面还有可选项
(use-package which-key
  :ensure t
  :init (which-key-mode)
  :config (setq which-key-idle-delay 0.1))


;; ripgrep的可执行命令保存在/opt/homebrew/bin中，需要加入到emacs的可执行程序路径
;; 否则会报告找不到rg命令
(add-to-list 'exec-path "/opt/homebrew/bin")
(add-to-list 'exec-path "/Users/pg/go/bin")

(use-package wgrep :ensure t)
(setq wgrep-auto-save-buffer t)
(eval-after-load 'consult
  '(eval-after-load 'embark
     '(progn
	(require 'embark-consult)
	(add-hook 'embark-collect-mode-hook #'consult-preview-at-point-mode))))

;; 批量替换 先调用consult-ripgrep，输入要查询的内容， 然后执行C-c C-e
;; 在跳出来的buffer中，使用query-replace-regexp命令，之后分别填入要被替换的值，替换之后的目标值，替换掉之后，使用C-c C-c保存
;; 普通搜索C-s出来的结果，也可以这么操作
(define-key minibuffer-local-map (kbd "C-c C-e") 'embark-export-write)
(defun embark-export-write ()
  "Export the current vertico results to a writable buffer if possible.
Supports exporting consult-grep to wgrep, file to wdeired, and consult-location to occur-edit"
  (interactive)
  (require 'embark)
  (require 'wgrep)
  (pcase-let ((`(,type . ,candidates)
               (run-hook-with-args-until-success 'embark-candidate-collectors)))
    (pcase type
      ('consult-grep (let ((embark-after-export-hook #'wgrep-change-to-wgrep-mode))
                       (embark-export)))
      ('file (let ((embark-after-export-hook #'wdired-change-to-wdired-mode))
               (embark-export)))
      ('consult-location (let ((embark-after-export-hook #'occur-edit-mode))
                           (embark-export)))
      (x (user-error "embark category %S doesn't support writable export" x)))))

;; 自定义函数，支持使用macos的open打开Finder展示文件
(defun consult-directory-externally (file)
  "Open FILE's directory externally using the default application on macOS."
  (interactive "fOpen directory externally: ")
  (call-process "open" nil 0 nil
                (file-name-directory (expand-file-name file))))
;; 在embark增加一个快捷键E，在Finder中打开选中的文件
(with-eval-after-load "embark"
  (define-key embark-file-map (kbd "E") #'consult-directory-externally))
;;;打开当前文件的目录
(defun my-open-current-directory ()
  "打开当前文件的目录"
  (interactive)
  (consult-directory-externally default-directory))

;; 使用fd来搜索文件，使用命令consult-locate，然后输入你的文件名以及路径
;; 在搜索结果中，可以继续添加#内容进行继续的过滤
;; 接着使用embark来使用系统内置应用程序将其打开 (C-; x)
;; 注意embark的翻页，可以在弹出buffer之后，使用C-h将其变为可以使用C-n C-p C-v M-v之类的普通buffer
(setq consult-locate-args "fd")


(eval-after-load 'consult
  (progn
    (setq
     consult-narrow-key "<"
     consult-line-numbers-widen t
     consult-async-min-input 2
     consult-async-refresh-delay  0.15
     consult-async-input-throttle 0.2
     consult-async-input-debounce 0.1)
    ))

;; 使用拼音搜索
(use-package pyim :ensure t)

(defun eh-orderless-regexp (orig_func component)
  (let ((result (funcall orig_func component)))
    (pyim-cregexp-build result)))


(defun toggle-chinese-search ()
  (interactive)
  (if (not (advice-member-p #'eh-orderless-regexp 'orderless-regexp))
      (advice-add 'orderless-regexp :around #'eh-orderless-regexp)
    (advice-remove 'orderless-regexp #'eh-orderless-regexp)))

(defun disable-py-search (&optional args)
  (if (advice-member-p #'eh-orderless-regexp 'orderless-regexp)
      (advice-remove 'orderless-regexp #'eh-orderless-regexp)))

;; (advice-add 'exit-minibuffer :after #'disable-py-search)
(add-hook 'minibuffer-exit-hook 'disable-py-search)

(global-set-key (kbd "s-p") 'toggle-chinese-search)

;; C++ LSP配置
(require 'eglot)
(add-to-list 'eglot-server-programs '((c++-mode c-mode) "clangd"))
(add-hook 'c-mode-hook #'eglot-ensure)
(add-hook 'c++-mode-hook #'eglot-ensure)

;; 配置成ide的几大组合技
;; eglot是lsp客户端，提供补全建议，需要一个jsp服务端配合他一起工作
;; xref时emacs自带的定义跳转框架
;; treesitter是自带的，但是需要下载对应的动态库才能工作，用于提供语法建议
;; company提供补全ui
;; 1. 开启内置的 Tree-sitter 自动映射 (将旧模式映射到新 ts 模式，ts就是treesit)
(setq major-mode-remap-alist
      '((c-mode . c-ts-mode)
        (c++-mode . c++-ts-mode)
	(go-mode . go-ts-mode)
	(java-mode . java-ts-mode)
        (python-mode . python-ts-mode)
        (javascript-mode . js-ts-mode)
        (typescript-mode . typescript-ts-mode)
        (json-mode . json-ts-mode)))

;; 2. 配置 Company-mode (需先安装: M-x package-install RET company)
(use-package company
  :ensure t
  :init (global-company-mode)
  :config
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.0)) ; 立即弹出补全

;; 3. 配置 Eglot (Emacs 29 内置)
(use-package eglot
  :hook ((c-ts-mode
	  c++-ts-mode
	  python-ts-mode
	  js-ts-mode
	  java-ts-mode
	  go-ts-mode) . eglot-ensure) ; 进这些模式自动开启
  :bind (:map eglot-mode-map
              ("C-c r" . eglot-rename)        ; 重构变量名
              ("C-c f" . eglot-format-buffer) ; 格式化代码
              ("M-." . xref-find-definitions) ; Xref 跳转定义 (通常默认就是这个)
              ("M-?" . xref-find-references)) ; Xref 查找引用
  :config
  ;; 让 eglot 配合 company 使用
  (add-hook 'eglot-managed-mode-hook (lambda ()
                                       (add-to-list 'completion-at-point-functions #'eglot-completion-at-point))))


;; 设置treesit版本
(setq treesit-language-source-alist
      '((go . ("https://github.com/tree-sitter/tree-sitter-go" "v0.20.0" ))
	(gomod  . ("https://github.com/camdencheek/tree-sitter-go-mod" "v1.0.0"))
	(gosum . ("https://github.com/tree-sitter-grammars/tree-sitter-go-sum" "stable"))
	(java . ("https://github.com/tree-sitter/tree-sitter-java" "v0.20.0"))))

;(setq treesit-language-source-alist
;      '((go "https://github.com/tree-sitter/tree-sitter-go" "v0.20.0")
;	(gomod "https://github.com/camdencheek/tree-sitter-go-mod" "v1.0.0")))

;; 需要安装对应的treesit动态库 treesit-install-language-grammer

(use-package quickrun
  :ensure t
  :commands (quickrun)
  :init
  (quickrun-add-command "c++/c1z"
    '((:command . "g++")
      (:exec . ("%c -std=c++1z %o -o %e %s"
                "%e %a"))
      (:remove . ("%e")))
    :default "c++"))

(use-package realgud
  :ensure t
  )

(use-package realgud-lldb
  :ensure t
  )

(use-package benchmark-init
  :ensure t
  :demand t
  :config
  (add-hook 'after-init-hook 'benchmark-init/deactivate))
(provide 'init-packages)


