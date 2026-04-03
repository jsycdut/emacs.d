;; 自定义快捷键F2打开这个emacs配置文件，懒得每次手动去打开这个文件
(defun open_init_file()
  (interactive)
  (find-file "~/.emacs.d/init.el"))
(global-set-key (kbd "<f2>") 'open_init_file)

;;绑定快捷键-找函数位置
(global-set-key (kbd "C-h C-f") 'find-function)
;;绑定快捷键-找变量位置
(global-set-key (kbd "C-h C-v") 'find-variable)
;;绑定快捷键-找快捷键绑定的函数
(global-set-key (kbd "C-h C-k") 'find-function-on-key)


(provide 'init-keybindings)
