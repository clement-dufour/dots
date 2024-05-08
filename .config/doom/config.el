;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Clément Dufour"
      user-mail-address "clementdufour@fastmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
;;(setq display-line-numbers-type t)
;;(setq display-line-numbers-type nil)
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Documents/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(setq visible-bell t)

(setq undo-limit 400000
      evil-want-fine-undo t)

(setq scroll-margin 2)

;; Implicit /g flag on evil ex substitution
(setq evil-ex-substitute-global t)

(setq +zen-text-scale 0.5)

(setq evil-vsplit-window-right t
      evil-split-window-below t)

(defadvice! prompt-for-buffer (&rest _)
  :after '(evil-window-split evil-window-vsplit)
  (consult-buffer))

(map! :map evil-window-map
      "SPC" #'evil-window-rotate-upwards)

(setq frame-title-format "%b - Emacs")

(setq fancy-splash-image (concat doom-user-dir "gnu-logo.png"))

(setq +doom-dashboard-functions
      (list #'doom-dashboard-widget-banner
            #'doom-dashboard-widget-loaded)
      +doom-dashboard-name "Doom Emacs")

(map! :after ibuffer
      :map ibuffer-mode-map
      :n "h" #'kill-current-buffer
      :n "l" #'+ibuffer/visit-workspace-buffer)

(map! :after dired
      :map dired-mode-map
      :n "h" #'dired-up-directory
      :n "l" #'dired-find-file)

(map! :leader
      (:prefix ("d" . "dired")
       :desc "dired" "d" #'dired
       :desc "dired-jump" "j" #'dired-jump))

(setq select-enable-clipboard nil)

(after! which-key
  (setq which-key-allow-multiple-replacements t)
  (pushnew! which-key-replacement-alist
   '(("" . "\\`+?evil[-:]?\\(?:a-\\)?\\(.*\\)") . (nil . "◂\\1"))
   '(("\\`g s" . "\\`evilem--?motion-\\(.*\\)") . (nil . "◃\\1"))))

(after! ispell
  ;; Configure `LANG`, otherwise ispell.el cannot find a 'default
  ;; dictionary' even though multiple dictionaries will be configured
  ;; in next line.
  (setenv "LANG" "en_US.UTF-8")
  (setq ispell-program-name "hunspell"
        ispell-dictionary "en_US,fr_FR")
  ;; ispell-set-spellchecker-params has to be called
  ;; before ispell-hunspell-add-multi-dic will work
  (ispell-set-spellchecker-params)
  (ispell-hunspell-add-multi-dic "en_US,fr_FR"))

(after! company
  (setq company-show-quick-access t))

(add-hook! 'python-mode-hook
  (setq prettify-symbols-alist '(("lambda" . 955))))

(after! org
  (add-hook! 'org-mode-hook #'+org-pretty-mode)
  (remove-hook! 'org-mode-hook #'flyspell-mode)
  (setq org-startup-folded 'show2levels
        org-ellipsis " [...] "
        org-log-done 'time))

(use-package! org-modern
  :hook (org-mode . org-modern-mode))

(after! doom-ui
  (setq auto-dark-dark-theme 'doom-one
        auto-dark-light-theme 'doom-tomorrow-day)
  (auto-dark-mode 1))
