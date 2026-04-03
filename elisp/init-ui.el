;; 不要滚动条
(scroll-bar-mode -1)

;; 不要工具栏
(tool-bar-mode -1)

;; 不要启动欢迎页信息
(setq inhibit-startup-screen t)

;;展示行号
(global-display-line-numbers-mode t)

;;设置一下字体大小
(set-face-attribute 'default nil :height 160)

;;高亮当前行
(global-hl-line-mode t)
;; 设置一下半透明
;;(set-frame-parameter (selected-frame) 'alpha '(75 . 70))


;;主题
;;(use-package 'monokai-theme :ensure t)
;; 亮色主题
(load-theme 'doom-solarized-light 1)
;; 暗色主题
;;(load-theme 'doom-solarized-dark 1)
;; 高亮展示括号匹配
(show-paren-mode t)

;; 括号编辑自动配对
(electric-pair-mode t)
;; 没有将{}作为匹配字符，这里加上去
(add-hook 'prog-mode-hook
          (lambda ()
            (setq-local electric-pair-pairs
                        (append electric-pair-pairs
                                '((?\{ . ?\}))))))

(provide 'init-ui)
