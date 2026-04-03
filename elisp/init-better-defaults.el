;; emacs图形化设置的内容，分发到custom.el去
(setq custom-file (expand-file-name "~/.emacs.d/custom.el"))
(load custom-file 'no-error 'no-message)

;; 不要自动备份文件
(setq make-backup-files nil)

;;最近文件, buffer之类的东西
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-item 10)
(global-set-key (kbd "C-x C-r") 'recentf-open-files)

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
(provide 'init-better-defaults)
