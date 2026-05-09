;; emacs图形化设置的内容，分发到custom.el去
(setq custom-file (expand-file-name "~/.emacs.d/custom.el"))
(load custom-file 'no-error 'no-message)

;; 不要自动备份文件
(setq make-backup-files nil)

;;最近文件, buffer之类的东西
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-item 10)

;; 自动加载外部修改过的文件
(global-auto-revert-mode t)

;; tab宽度
(setq tab-width 2)

;; 关闭自动保存文件
(setq auto-save-default nil)

;; 关闭错误声音
(setq ring-bell-function 'ignore)

;; yes-or-no别名改为y-n
(fset 'yes-or-no-p 'y-or-n-p)

;; 选中当前内容后可以删除之
(delete-selection-mode t)

;; 自动加载外部修改过的文件
(global-auto-revert-mode)

;; 使gui启动的emacs能够用到shell中的PATH变量，否则很多需要执行的shell命令会找不到对应的命令
(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

;; 更强的终端模拟器，我需要它+tmux
;; https://github.com/akermu/emacs-libvterm readme中写了shell eshell ansi-term和vterm的区别
;; 学习下这些区别
(use-package vterm
  :ensure t)

;; json压缩成一行
(defun my/json-to-single-line (beg end)
  "Collapse prettified json in region between BEG and END to a single line"
  (interactive "r")
  (if (use-region-p)
      (save-excursion
        (save-restriction
          (narrow-to-region beg end)
          (goto-char (point-min))
          (while (re-search-forward "[ \t\n\r]+" nil t)
            (replace-match ""))))
    (print "This function operates on a region")))

(provide 'init-better-defaults)
