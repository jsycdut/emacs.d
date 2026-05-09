;; 把emacs搞成一个ide

;; macOS 从 GUI 启动时不继承 shell 环境变量，手动设置 JAVA_HOME
;; 使用 sdkman 的 current 软链接，自动跟随当前激活的 Java 版本
(setenv "JAVA_HOME" (expand-file-name "~/.sdkman/candidates/java/current"))


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
        (js-mode . js-ts-mode)
        (typescript-mode . typescript-ts-mode)
        (tsx-mode . tsx-ts-mode)
        (json-mode . json-ts-mode)
        (html-mode . html-ts-mode)
        (mhtml-mode . html-ts-mode)
	(bash-mode . bash-ts-mode)
	(sh-mode . bash-ts-mode)))

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
	  typescript-ts-mode
	  tsx-ts-mode
	  java-ts-mode
	  go-ts-mode
	  html-ts-mode
	  bash-ts-mode) . eglot-ensure) ; 进这些模式自动开启
  :bind (:map eglot-mode-map
              ("C-c r" . eglot-rename)        ; 重构变量名
              ("C-c f" . eglot-format-buffer) ; 格式化代码
              ("M-." . xref-find-definitions) ; Xref 跳转定义 (通常默认就是这个)
              ("M-?" . xref-find-references)  ; Xref 查找引用
              ("M-s d" . my/consult-lsp-file-symbols)) ; 通过解析lsp返回的信息，构建自己的文件结构符号列表
  :config
  (setq eglot-extend-to-xref t) ; 有助于保持索引完整
  ;; eglot 默认会接管 imenu，产生平铺的 LSP 符号列表，导致 consult-imenu 无法按类型窄化
  ;; 禁用后改由 tree-sitter 提供 imenu
  (add-to-list 'eglot-stay-out-of 'imenu)
  ;; java-ts-mode 默认不包含字段（静态变量）到 imenu
  ;; 追加 field_declaration 节点，并用自定义函数从 variable_declarator -> identifier 子节点中提取字段名
  (add-hook 'java-ts-mode-hook
            (lambda ()
              (setq-local treesit-simple-imenu-settings
                          (append treesit-simple-imenu-settings
                                  `(("Field" "\\`field_declaration\\'" nil
                                     ,(lambda (node)
                                        (let ((declarator (treesit-node-child-by-field-name node "declarator")))
                                          (when declarator
                                            (treesit-node-text
                                             (treesit-node-child-by-field-name declarator "name") t))))))))))
  ;; 让 eglot 配合 company 使用
  (add-hook 'eglot-managed-mode-hook (lambda ()
                                       (add-to-list 'completion-at-point-functions #'eglot-completion-at-point)))
  ;; 配置对应模式的lsp服务器信息
  (add-to-list 'eglot-server-programs '((c++-mode c-mode) "clangd"))
  (add-to-list 'eglot-server-programs '(python-mode . ("pyright-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs '(go-mode . ("gopls")))
  ;; JavaScript / TypeScript LSP，使用 typescript-language-server
  ;; 安装：npm install -g typescript-language-server typescript
  (add-to-list 'eglot-server-programs
               '((js-ts-mode typescript-ts-mode tsx-ts-mode) .
                 ("typescript-language-server" "--stdio")))
  ;; HTML LSP，使用 vscode-html-language-server
  ;; 安装：npm install -g vscode-langservers-extracted
  (add-to-list 'eglot-server-programs
               '(html-ts-mode . ("vscode-html-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               `(java-ts-mode . ("jdtls"
                                 "--java-home" "/Users/pg/.sdkman/candidates/java/25.0.2-tem"
                                 "--jvm-arg=-Xms512m"
                                 "--jvm-arg=-Xmx4g"
				 :initializationOptions
				 ;; 支持类文件内容
				 (:extendedClientCapabilities (:classFileContentsSupport t)
							      :settings (:java (:home "/Users/pg/.sdkman/candidates/java/25.0.2-tem")))))))

;; java项目中，使用lsp，比如jdtls，建立了项目索引之后，是可以进行源码跳转的
;; 但是，如果碰到目标是jar包或者jdk中的代码，就无法跳转了
;; 此时需要开启jdtls的配置，使其可以向客户端返回类文件信息，即上方启动jdtls的参数中的的(:extendedClientCapabilities (:classFileContentsSupport t)
;; jdtls 返回的类文件信息是jdt:// 自定义 URI，eglot客户端不支持展示该内容
;; 需要手动写一个函数，向jdtls请求这个URI中的内容，jdtls会返回对应的内容文本，将这个文本展示到文件里面并打开就行了
;; eglot--xref-make-match 调用的是 eglot-uri-to-path（单横线公开 API）
;; advise 它：遇到 jdt:// 时向 jdtls 请求类文件内容写入临时文件，返回路径
;; eglot--xref-make-match 会 insert-file-contents 读取该文件，跳转到正确行列
(defun my/eglot-jdt-uri-handler (orig-fn uri)
  "向jdtls请求class的文件内容，然后把文件内容写入到一个临时文件中，然后跳转过去"
  (when (keywordp uri) (setq uri (substring (symbol-name uri) 1)))
  (if (string-prefix-p "jdt://" uri)
      ;; 请求类文件内容
      (let* ((content (jsonrpc-request (eglot-current-server)
                                       :java/classFileContents
                                       `(:uri ,uri)))
             (path-part (car (split-string uri "?")))
             (base-name (file-name-sans-extension (file-name-nondirectory path-part)))
             (tmp-file (make-temp-file "jdt-" nil (concat "-" base-name ".java"))))
	;; 把类文件内容写入临时文件
        (with-temp-file tmp-file
          (insert (or content "")))
        tmp-file)
    (funcall orig-fn uri)))
;;加入切面
(advice-add 'eglot-uri-to-path :around #'my/eglot-jdt-uri-handler)

;; typescript-language-server 在 rename 时会把 node_modules 里的文件也返回
;; 过滤掉 changes 中路径含 node_modules 的条目
(defun my/eglot-filter-node-modules-edit (orig-fn wedit origin)
  (when-let* ((changes (plist-get wedit :changes)))
    (let ((filtered '()))
      (cl-loop for (uri edits) on changes by #'cddr
               unless (string-match-p "node_modules" (symbol-name uri))
               do (setq filtered (append filtered (list uri edits))))
      (setq wedit (plist-put (copy-sequence wedit) :changes filtered))))
  (funcall orig-fn wedit origin))
(advice-add 'eglot--apply-workspace-edit :around #'my/eglot-filter-node-modules-edit)

;; 基于 LSP textDocument/documentSymbol 的当前文件符号导航
;; 递归处理 children，支持 Java 等将成员放在类的 children 中的语言
;; 过滤掉局部变量（kind 13），子符号显示父级前缀（如 App.main）
;; 支持 consult 预览：上下移动候选项时光标跟随跳转
(defun my/--lsp-collect-symbols (symbols parent-name kind-names buf)
  "递归收集符号列表，PARENT-NAME 为父符号名，用于拼接显示名称。"
  (mapcan
   (lambda (sym)
     (let* ((kind (plist-get sym :kind))
            (kind-name (alist-get kind kind-names))
            (name (plist-get sym :name))
            (children (append (plist-get sym :children) nil))
            ;; 有父级时显示为 "ParentName.SymbolName"
            (display-name (if parent-name (format "%s.%s" parent-name name) name))
            ;; 当前符号在对照表中才生成候选项
            (current
             (when kind-name
               (let* ((line (1+ (plist-get
                                 (plist-get (plist-get sym :selectionRange) :start)
                                 :line)))
                      (marker (with-current-buffer buf
                                (save-excursion
                                  (goto-line line)
                                  (point-marker)))))
                 (list (cons (format "%-12s %s" kind-name display-name) marker)))))
            ;; 当前符号有意义则用它的名字作为子符号的父级，否则继承上级父级
            (next-parent (if kind-name name parent-name))
            ;; 递归处理子符号
            (child-results
             (when children
               (my/--lsp-collect-symbols children next-parent kind-names buf))))
       (append current child-results)))
   symbols))

(defun my/consult-lsp-file-symbols ()
  "用 LSP textDocument/documentSymbol 指令导航当前文件符号。"
  (interactive)
  (let* ((buf (current-buffer))
         (symbols (append (eglot--request (eglot--current-server-or-lose)
                                          :textDocument/documentSymbol
                                          `(:textDocument (:uri ,(eglot--path-to-uri (buffer-file-name)))))
                          nil))
         ;; LSP SymbolKind 对照表，排除 Variable(13) 局部变量
         (kind-names '((5  . "Class")       (6  . "Method")      (8  . "Field")
                       (9  . "Constructor") (10 . "Enum")         (11 . "Interface")
                       (12 . "Function")    (14 . "Constant")))
         (candidates (my/--lsp-collect-symbols symbols nil kind-names buf)))
    (consult--read
     candidates
     :prompt "File Symbol: "
     :sort nil
     :require-match t
     :lookup #'consult--lookup-cdr
     :state (consult--jump-state))))

;; 设置基于treesitter的高亮级别
(setq treesit-font-lock-level 4)
;; 需要安装对应的treesit动态库 treesit-install-language-grammer
(setq treesit-language-source-alist
      '((go . ("https://github.com/tree-sitter/tree-sitter-go" "v0.20.0" ))
	(gomod  . ("https://github.com/camdencheek/tree-sitter-go-mod" "v1.0.0"))
	(gosum . ("https://github.com/tree-sitter-grammars/tree-sitter-go-sum" "stable"))
	(java . ("https://github.com/tree-sitter/tree-sitter-java" "v0.20.0"))
	(python . ("https://github.com/tree-sitter/tree-sitter-python" "v0.25.0"))
	(javascript . ("https://github.com/tree-sitter/tree-sitter-javascript" "master" "src"))
	(typescript . ("https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src"))
	(tsx . ("https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src"))
	(html . ("https://github.com/tree-sitter/tree-sitter-html" "master"))
	(bash . ("https://github.com/tree-sitter/tree-sitter-bash.git" "master"))))

;; 快速运行代码
(use-package quickrun
  :ensure t
  :commands (quickrun)
  :init
  (quickrun-add-command "c++/c1z"
    '((:command . "g++")
      (:exec . ("%c -std=c++1z %o -o %e %s"
                "%e %a"))
      (:remove . ("%e")))
    :default "c++")
  (quickrun-add-command "python"
    '((:command . "python3")
      (:exec    . "%c %s"))
    :override t)
  )

;; 调试
(use-package realgud
  :ensure t
  )
(use-package realgud-lldb
  :ensure t
  )

;; 格式化代码
;; 如果是elisp，可以直接调用 mark-whole-buffer +  indent-region来进行格式化，其余的话需要采用插件+formatter程序的形式
(use-package apheleia
  :ensure t
  :init (apheleia-global-mode 1))

;; 项目管理，也许emacs自带的project是更好的未来的选择
;; 但我现在elisp水平还不够，无法理解某些需要自己实现的逻辑
;; 所以暂时还是使用这个三方插件
(use-package projectile
  :ensure t
  :config
  ;; 启用projectile
  (projectile-mode)
  ;; 让emacs内置的project.el能够使用projectile的项目查找函数
  ;; 有利于eglot识别项目，以及xref查找引用
  (add-hook 'project-find-functions #'project-projectile))

;; 用于projectile的搜索，但是这个搜索不如consule-ripgrep那么棒
;; 因为它是只是把结果放到一个buffer，而consult可以直接动态选择候选项并且在buffer展示对应的内容
(use-package ripgrep
  :ensure t)

;; 展示当前buffer的symbol信息（symbol指的是变量、函数、类等）
;; 它利用的是lsp服务端返回的信息，而非tree-sitter或者ctags提供的索引信息
;; 功能上，和imenu/consult-imenu类似，只是单独弹出来了一个窗口挂在那里，并且可以随着你的选择滚动buffer，而imenu/consult-imenu始终只在mini-buffer中，你需要手动的输入什么东西区过滤下或者滚动这个minibuffer来看到更多的内容
;; 这个功能在eclipse中被称之为outline，在jetbrains中被称之为structure
(use-package symbols-outline
  :ensure t
  :bind ("C-c i" . symbols-outline-show)
  :init
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
	      ;; 使用lsp的数据来当做符号
              (setq-local symbols-outline-fetch-fn #'symbols-outline-lsp-fetch)))
  :config
  ;; 窗口位置
  (setq symbols-outline-window-position 'left)
  ;; 展示变量信息，默认是不展示变量的
  (setq symbols-outline-ignore-variable-symbols nil)
  ;; 随着你选择符号信息，buffer对应滚到对应的内容
  (symbols-outline-follow-mode))

;; 这个包提供了整个workspace的symbol信息，一般不是很用得到，用于模糊搜索的场景吧
;; 我们imenu/consult-imenu，以及上方的symbols-outline提供的都是当前buffer的symbol信息
(use-package consult-eglot
  :ensure t)

;; TODO 考虑eglot-java是不是更好的插件


;; 我需要折叠代码
;; emacs内置的hs-minor-mode可以做到折叠函数代码块，结合evil的zc zo命令可以快捷使用，但是只限于当前光标位置
;; 如果要通过折叠所有函数定义，来观察整个文件定义了哪些函数的话， symbols-outline或者imenu可能更好
;; 但是我需要是在js文件中，函数和代码混一块的情况下，单独把function给折掉，但是它的调用我又能看的清楚
(use-package treesit-fold
  :ensure t)

;; 代码格式化
(use-package apheleia
  :ensure t
  :config
  (apheleia-global-mode +1))

(provide 'init-ide)
