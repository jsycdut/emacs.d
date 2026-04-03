(use-package org
  :ensure t
  :pin elpa
  :config
  (require 'org-tempo))

(global-set-key (kbd "C-c a") 'org-agenda)
(setq org-agenda-files '("~/.emacs.d/gtd.org"))
(setq org-agenda-span 'week)

;; 记录事项内容
(setq org-capture-templates
      '(("t" "TODO-待办事项" entry (file+headline "~/.emacs.d/gtd.org" "Workspace")
	 ;; 
	 "* TODO [#B] %?\n %i\n %U"
	 :empty-lines 1)))
(global-set-key (kbd "C-c c") 'org-capture)

;; 设置org-agenda自定义命令
(setq org-agenda-custom-commands
      '(("c" "重要且紧急的事情" ((tags-todo "+PRIORITY=\"A\"")))
	;;其他命令
	("d" "每日仪表盘"
         ((agenda "" ((org-agenda-span 1)))           ; 1. 显示今天的日程
          (tags-todo "+PRIORITY=\"A\""                ; 2. 显示所有优先级为 A 的任务
                     ((org-agenda-overriding-header "🔥 高优先级待办")))
          (tags-todo "PROJECT"                        ; 3. 显示所有标记为 PROJECT 的任务
                     ((org-agenda-overriding-header "🚀 重点项目")))
          (todo "STARTED"                             ; 4. 显示正在进行中的任务
                ((org-agenda-overriding-header "🏗️ 推进中...")))))
	))

;; 用于checkbox的处理
(use-package org-contrib
  :pin "nongnu"
  :ensure t
  :init
  :after org
  :config
  (require 'org-checklist))

(add-to-list 'org-modules 'org-checklist)

(setq org-log-done t)
(setq org-log-into-drawer t)

;; 自定义org标题栏状态切换
;; C-h-v 查看这个变量的复制逻辑
(setq org-todo-keywords
      ;; 基础格式是(关键字(快捷键 进入此状态动作/离开此状态动作))， |符号后面的是终态
      ;; !符号会记录时间戳 @符号会弹出笔记备注
      (quote ((sequence "TODO(t!/@)" "STARTED(s!/!)" "|" "DONE(d!/!)")
	      (sequence "WAITING(w@/!)" "SOMEDAY(S)" "|" "CANCELED(c@/!)" "MEETING(m)" "PHONE(p)"))))

;; 用于将org导出为markdown，最终放到hugo博客目录中(org文件中定义了导出位置)
(use-package ox-hugo
  :ensure t
  :after ox)

;; 为org-capture增加一个自定义命令，用于写hugo博客
(with-eval-after-load 'org-capture
  (defun org-hugo-new-subtree-post-capture-template ()
    "Returns `org-capture' template string for new Hugo post.
See `org-capture-templates' for more information."
    (let* ((title (read-from-minibuffer "Post Title: ")) ;Prompt to enter the post title
           (fname (org-hugo-slug title)))
      (mapconcat #'identity
                 `(
                   ,(concat "* TODO " title)
                   ":PROPERTIES:"
                   ,(concat ":EXPORT_FILE_NAME: " fname)
                   ":END:"
                   "\n\n")          ;Place the cursor here finally
                 "\n")))

  (add-to-list 'org-capture-templates
               '("h"                ;`org-capture' binding + h
                 "Hugo post"
                 entry
                 ;; It is assumed that below file is present in `org-directory'
                 ;; and that it has a "Blog Ideas" heading. It can even be a
                 ;; symlink pointing to the actual location of all-posts.org!
                 (file+headline "/Users/pg/github/jsycdut.github.io/all-blogs.org" "发布于Github Pages上的静态博客")
                 (function org-hugo-new-subtree-post-capture-template))))



(provide 'init-org)
