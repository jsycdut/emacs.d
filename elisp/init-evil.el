;; evil模拟vim按键行为，拯救我的小拇指，Ctrl按键我真的痛惨了
(use-package evil
  :ensure t
  :init
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  ;; 默认启用evil
  (evil-mode)
  (with-eval-after-load 'evil-maps
    ;; 解决org模式下链接不跟随的问题
    (define-key evil-motion-state-map (kbd "RET") nil)))

;; general用于绑定按键
(use-package general
  :ensure t
  :init
  (with-eval-after-load 'evil
    (general-add-hook 'after-init-hook
		      ;; 找个buffer强制刷一下映射
                      (lambda (&rest _)
                        (when-let ((messages-buffer (get-buffer "*Messages*")))
                          (with-current-buffer messages-buffer
                            (evil-normalize-keymaps)))) nil nil t))


  ;; 定义一个leader key，用于发起快捷键
  (general-create-definer global-definer
    ;; override意思是最高级别的映射
    :keymaps 'override
    ;; 对所有模式都生效
    :states '(insert emacs normal hybrid motion visual operator)
    ;; 默认使用空格作为快捷键首位触发键
    :prefix "SPC"
    ;; 其他模式用Ctrl+空格触发快捷键
    :non-normal-prefix "C-SPC")

  ;; 这里就是定义快捷键了，前面定义的leader key 加上这里的按键序列，就可以执行后面对应的命令
  (global-definer
    "!" 'shell-command
    "SPC" 'execute-extended-command
    "'" 'vertico-repeat
    "+" 'text-scale-increase
    "-" 'text-scale-decrease
    "u" 'universal-argument
    "hdf" 'describe-function
    "hdv" 'describe-variable
    "hdk" 'describe-key
    )
  ;; 我对宏定义还不熟悉，缺乏理解，注意 `是构建一个列表，,代表要对里面的变量进行求值
  ;; 这是一段宏，用于定义一组快捷键，其实这里面调用了 general-create-definer 用于定义快捷键
  ;; name 展示给which-key的名称，infix-key是中缀键，即它下面还有按键序列,body就是按键序列了
  (defmacro +general-global-menu! (name infix-key &rest body)
    "Create a definer named +general-global-NAME wrapping global-definer.
Create prefix map: +general-global-NAME. Prefix bindings in BODY with INFIX-KEY."
    (declare (indent 2))
    `(progn
       ;; 创建一个子定义器 xxx
       (general-create-definer ,(intern (concat "+general-global-" name))
	 ;; 继承global-definer（延续其快捷键）
         :wrapping global-definer
	 ;; 定义内部模式map
         :prefix-map ',(intern (concat "+general-global-" name "-map"))
	 ;; 中缀键
         :infix ,infix-key
	 ;; 不要全路径提示
         :wk-full-keys nil
	 ;; 默认啥也不做，因为后面还要加后续快捷键，即body部分的内容
         "" '(:ignore t :which-key ,name))
       ;; 立马调用上面定义的子定义器 xxx 绑定快捷键和命令
       (,(intern (concat "+general-global-" name))
        ,@body)))


  ;; 利用上面的宏，定义一组快捷键
  (+general-global-menu! "buffer缓冲区" "b"
    "d" 'kill-current-buffer
    "b" '(consult-buffer :which-key "consult buffer")
    "B" 'switch-to-buffer
    "p" 'previous-buffer
    "R" 'rename-buffer
    "M" '((lambda () (interactive) (switch-to-buffer "*Messages*"))
          :which-key "messages-buffer")
    "n" 'next-buffer
    "i" 'ibuffer
    "f" 'my-open-current-directory
    "k" 'kill-buffer
    "y" 'copy-buffer-name
    "K" 'kill-other-buffers))
(provide 'init-evil)
