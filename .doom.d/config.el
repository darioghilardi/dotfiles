;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; refresh' after modifying this file!


;; These are used for a number of things, particularly for GPG configuration,
;; some email clients, file templates and snippets.
(setq user-full-name "Dario Ghilardi"
      user-mail-address "darioghilardi@webrain.it")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "FuraCode Nerd Font" :size 13))
(setq doom-unicode-font (font-spec :name "DejaVu Sans Mono" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. These are the defaults.
(setq doom-theme 'doom-one)

;; If you intend to use org, it is recommended you change this!
(setq org-directory "~/org/")

;; If you want to change the style of line numbers, change this to `relative' or
;; `nil' to disable it:
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', where Emacs
;;   looks when you load packages with `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.

;; Disable meta key on the right alt, to be able to type special
;; chars on MacOS
(setq ns-right-alternate-modifier 'none)

;; Exit insert mode the Spacemacs way
(setq-default evil-escape-key-sequence "fd")

;; TODO: Split window teh Spacemacs way

;; Bind a new key chord to kill buffer, delete frame and window,
;; Follow the Spacemacs way.
(map!
 (:leader
   (:prefix "b" :desc "Kill buffer" "d" #'kill-this-buffer)
   (:prefix ("k" . "kill")
     :desc "Save and kill" "e" 'save-buffers-kill-terminal
     :desc "Kill buffer" "b" 'my-kill-this-buffer
     :desc "Delete frame" "f" 'delete-frame
    (:prefix ("o" . "Other")
      :desc "Frames" "f" 'delete-other-frames
      :desc "Windows" "w" 'delete-other-windows)
    )))

;; Treemacs
(map! :leader
      :nv "o n" nil
      :desc "Open treemacs pane"
      :n "o n" #'+treemacs/toggle)
;; Remap finding stuff
(map! :leader
      :nv "o N" nil
      :desc "Treemacs find file"
      :n "o N" 'treemacs-find-file)

;; Elixir configuration
;; Start by configuring Alchemist for some tasks.
(def-package! alchemist
  :hook (elixir-mode . alchemist-mode)
  :config
  (set-lookup-handlers! 'elixir-mode
    :definition #'alchemist-goto-definition-at-point
    :documentation #'alchemist-help-search-at-point)
  (set-eval-handler! 'elixir-mode #'alchemist-eval-region)
  (set-repl-handler! 'elixir-mode #'alchemist-iex-project-run)
  (setq alchemist-mix-env "dev")
  (setq alchemist-hooks-compile-on-save t)
  (map! :map elixir-mode-map :nv "m" alchemist-mode-keymap))

;; Now configure LSP mode and set the client filepath.
(def-package! lsp-mode
  :commands lsp
  :config
  (setq lsp-enable-file-watchers nil)
  :hook
  (elixir-mode . lsp))

(after! lsp-clients
  (lsp-register-client
   (make-lsp-client :new-connection
    (lsp-stdio-connection
        (expand-file-name
          "~/elixir-ls/release/language_server.sh"))
        :major-modes '(elixir-mode)
        :priority -1
        :server-id 'elixir-ls
        :initialized-fn (lambda (workspace)
            (with-lsp-workspace workspace
             (let ((config `(:elixirLS
                             (:mixEnv "dev"
                                     :dialyzerEnabled
                                     :json-false))))
             (lsp--set-configuration config)))))))

;; Configure LSP-ui to define when and how to display informations.
(after! lsp-ui
  (setq lsp-ui-doc-max-height 20
        lsp-ui-doc-max-width 80
        lsp-ui-sideline-ignore-duplicate t
        lsp-ui-doc-header t
        lsp-ui-doc-include-signature t
        lsp-ui-doc-position 'bottom
        lsp-ui-doc-use-webkit nil
        lsp-ui-flycheck-enable t
        lsp-ui-imenu-kind-position 'left
        lsp-ui-sideline-code-actions-prefix "💡"
        ;; fix for completing candidates not showing after “Enum.”:
        company-lsp-match-candidate-predicate #'company-lsp-match-candidate-prefix
        ))

;; Configure exunit
(def-package! exunit)

;; Enable credo checks on flycheck
(def-package! flycheck-credo
  :after flycheck
  :config
    (flycheck-credo-setup)
    (after! lsp-ui
      (flycheck-add-next-checker 'lsp-ui 'elixir-credo)))

;; Enable format and iex reload on save
(after! lsp
  (add-hook 'elixir-mode-hook
            (lambda ()
              (add-hook 'before-save-hook 'elixir-format nil t)
              (add-hook 'after-save-hook 'alchemist-iex-reload-module))))

;; Setuo some keybindings for exunit and lsp-ui
(map! :mode elixir-mode
        :leader
        :desc "iMenu" :nve  "c/"    #'lsp-ui-imenu
        :desc "Run all tests"   :nve  "ctt"   #'exunit-verify-all
        :desc "Run all in umbrella"   :nve  "ctT"   #'exunit-verify-all-in-umbrella
        :desc "Re-run tests"   :nve  "ctx"   #'exunit-rerun
        :desc "Run single test"   :nve  "cts"   #'exunit-verify-single)

