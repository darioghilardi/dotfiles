;; Set the load path
(add-to-list 'load-path "~/.emacs.d/packages")

;; MELPA Packages
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; Dependencies
(defvar my-packages '(evil
		      zenburn-theme
		      projectile
		      helm
		      helm-projectile
                      clojure-mode
                      cider
		      rainbow-delimiters))

(dolist (p my-packages)
  (unless (package-installed-p p)
    (package-install p)))

;; Set the page up as Evil command, otherwise Emacs uses it
(setq evil-want-C-u-scroll t)

;; Enable Evil-mode
(require 'evil)
(evil-mode 1)
(evil-set-initial-state 'term-mode 'emacs) ;; Use emacs mode in terminals

;; Maximize on startup
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Enable the zenburn theme
(load-theme 'zenburn t)

;; Always enable line number
(global-linum-mode 1)

;; Disable menubar, toolbar and scrollbar
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Disable the splash screen and banner
(setq inhibit-startup-message t
      inhibit-startup-echo-area t)

;; Enable Helm 
(require 'helm)
(require 'helm-config)

;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
(define-key helm-map (kbd "C-i")   'helm-execute-persistent-action) ; make TAB works in terminal
(define-key helm-map (kbd "C-z")   'helm-select-action) ; list actions using C-z

(when (executable-find "curl")
  (setq helm-google-suggest-use-curl-p t))

(setq helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
      helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
      helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
      helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
      helm-ff-file-name-history-use-recentf t)

(helm-mode 1)

(helm-autoresize-mode t)                           ;; Helm autoresize
(global-set-key (kbd "M-x") 'helm-M-x)             ;; Helm commands
(setq helm-M-x-fuzzy-match t)                      ;; Helm commands with fuzzy search
(global-set-key (kbd "M-y") 'helm-show-kill-ring)  ;; Helm kill ring, display what's in the cut history
(global-set-key (kbd "M-§ T") 'helm-find-files)    ;; Helm find files
(global-set-key (kbd "M-§ t") 'helm-projectile)    ;; Helm projectile

;; Enable Projectile
(projectile-global-mode)

;; Windmove configuration
(global-set-key (kbd "M-<left>")  'windmove-left)
(global-set-key (kbd "M-<right>") 'windmove-right)
(global-set-key (kbd "M-<up>")    'windmove-up)
(global-set-key (kbd "M-<down>")  'windmove-down)

;; Buffer rotator, saves my days, use shift + arrows
(windmove-default-keybindings)
(setq windmove-wrap-around t)

;; Rainbow delimiters for clojure mode
(require 'rainbow-delimiters)
(add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode)
(add-hook 'clojure-mode-hook 'rainbow-delimiters-mode)
(add-hook 'lisp-mode-hook 'rainbow-delimiters-mode)

;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
  `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
  `((".*" ,temporary-file-directory t)))
