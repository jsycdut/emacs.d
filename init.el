;; jsy's emacs configuration since 202603
;;                                                                _             
;;                                                               | |            
;;   ___ _ __ ___   __ _  ___ ___    _____   _____ _ __ _   _  __| | __ _ _   _ 
;;  / _ \ '_ ` _ \ / _` |/ __/ __|  / _ \ \ / / _ \ '__| | | |/ _` |/ _` | | | |
;; |  __/ | | | | | (_| | (__\__ \ |  __/\ V /  __/ |  | |_| | (_| | (_| | |_| |
;;  \___|_| |_| |_|\__,_|\___|___/  \___| \_/ \___|_|   \__, |\__,_|\__,_|\__, |
;;                                                       __/ |             __/ |
;;                                                      |___/             |___/ 
;;
;; 所有的配置都可以写在init.el中
;; 但是这样会导致init.el很臃肿
;; 此处按照功能维度把配置分散到不同文件中，在这里统一加载
;; 将配置文件放入加载路径中
(add-to-list 'load-path "~/.emacs.d/elisp")
;; 加载插件包 
(require 'init-packages)
;; 加载UI配置
(require 'init-ui)
;; 加载emacs内置功能增强
(require 'init-better-defaults)
;; 加载自动补全配置
(require 'init-completions)
;; 加载按键映射
(require 'init-keybindings)
;; 加载org配置
(require 'init-org)
;; 加载evil配置
(require 'init-evil)



