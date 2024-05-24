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
(setq doom-font (font-spec :family "Iosevka" :size 16)
      doom-variable-pitch-font (font-spec :family "Cantarell" :size 14 :weight 'regular))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one)
(after! doom-ui
  (setq auto-dark-dark-theme 'doom-one
        auto-dark-light-theme 'doom-tomorrow-day)
  (auto-dark-mode 1))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
;;(setq display-line-numbers-type t)
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Documents/org/"
      org-log-done 'time)

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

;; Frames
(setq frame-title-format "%b - Emacs")

;; Despite these settings allowing resizing with the mouse, resizing to the top
;; and to the left is not possible.
;; (add-to-list 'default-frame-alist '(undecorated . t))
;; (add-to-list 'default-frame-alist '(drag-internal-border . t))
;; (add-to-list 'default-frame-alist '(internal-border-width . 5))

;; If the daemon is not running, the frame is created and then centered by
;; Mutter before this alist is read/used.
;; (add-to-list 'default-frame-alist '(height . 50))
;; (add-to-list 'default-frame-alist '(width . 250))

(add-to-list 'default-frame-alist '(alpha-background . 95))

;; Dashboard
(setq fancy-splash-image (expand-file-name "emacs.svg" doom-user-dir))

;; https://discourse.doomemacs.org/t/how-to-change-your-splash-screen/57
(defun my/doom-dashboard-draw-ascii-banner-fn ()
  (let* ((banner
          '("______ _____ ____ ___ ___"
            "`  _  V  _  V  _ \\|  V  ´"
            "| | | | | | | | | |     |"
            "| | | | | | | | | | . . |"
            "| |/ / \\ \\| | |/ /\\ |V| |"
            "|   /   \\__/ \\__/  \\| | |"
            "|  /                ' | |"
            "| /     E M A C S     \\ |"
            "´´                     ``"))
         (longest-line (apply #'max (mapcar #'length banner))))
    (put-text-property
     (point)
     (dolist (line banner (point))
       (insert (+doom-dashboard--center
                +doom-dashboard--width
                (concat
                 line (make-string (max 0 (- longest-line (length line)))
                                   32)))
               "\n"))
     'face 'doom-dashboard-banner)))

(setq +doom-dashboard-ascii-banner-fn #'my/doom-dashboard-draw-ascii-banner-fn)

(setq +doom-dashboard-functions
      (list #'doom-dashboard-widget-banner
            #'doom-dashboard-widget-loaded)
      +doom-dashboard-name "Dashboard")

;; Emacs miscellaneous configuration
(setq confirm-kill-emacs nil)

(setq visible-bell t)

(setq undo-limit 400000
      evil-want-fine-undo t)

(setq scroll-margin 2)

;; Implicit /g flag on evil ex substitution
(setq evil-ex-substitute-global t)

(setq select-enable-clipboard nil)

(setq +zen-text-scale 0.8)

(setq evil-vsplit-window-right t
      evil-split-window-below t)

(defadvice! prompt-for-buffer (&rest _)
  :after '(evil-window-split evil-window-vsplit)
  (consult-buffer))

;; Keybindings
(defun my/org-tab-conditional ()
  (interactive)
  (if (yas-active-snippets)
      (yas-next-field-or-maybe-expand)
    (org-cycle)))

(map! :after evil-org
      :map evil-org-mode-map
      :i "<tab>" #'my/org-tab-conditional)

(map! :map evil-window-map
      "SPC" #'evil-window-rotate-upwards)

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

;; Package specific configuration
(after! company
  (setq company-show-quick-access t))

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

(after! org
  (add-hook! 'org-mode-hook
             #'+org-pretty-mode
             #'mixed-pitch-mode)
  (remove-hook! 'org-mode-hook #'flyspell-mode)
  (setq org-startup-folded 'overview
        org-ellipsis " [...] "))

(after! ox-pandoc
  (add-to-list 'org-pandoc-options-for-docx
               (cons 'reference-doc (expand-file-name "reference.docx" org-directory))))

(use-package! org-modern
  :hook (org-mode . org-modern-mode)
  :config
  (setq org-modern-todo nil
        org-modern-tag nil
        org-modern-fold-stars '(("" . ""))))

(add-hook! 'python-mode-hook
  (setq prettify-symbols-alist '(("lambda" . 955))))

;; Cisco mode
(define-generic-mode
    'cisco-mode
  '() ;; ! must be the first character, font-lock-comment-face used instead
  '("aaa"
    "access-class"
    "address"
    "address-family"
    "archive"
    "cdp"
    "channel-group"
    "clock"
    ;; "description"
    "enable"
    "errdisable"
    "exec-timeout"
    "exit-address-family"
    "fhrp"
    "hostname"
    "interface"
    "ip"
    "length"
    "line"
    "lldp"
    "log"
    "logging"
    "login"
    "maximum"
    ;; "name"
    "network"
    "ntp"
    "passive-interface"
    "path"
    "priority"
    "privilege"
    "ptp"
    "radius-server"
    "redistribute"
    "router"
    "router-id"
    "service"
    ;; "shutdown"
    "snmp-server"
    "spanning-tree"
    "stopbits"
    "storm-control"
    "switchport"
    "time-period"
    "transport"
    "username"
    "vlan"
    "vrf"
    "vrrp"
    "vtp")
  '(("^ *!.*" . font-lock-comment-face)
    ("^ *\\(description\\|name\\).*" . font-lock-string-face)
    ("\\([0-9]\\{1,3\\}\\.\\)\\{3\\}[0-9]\\{1,3\\}\\(/[0-9]\\{1,2\\}\\)?" . font-lock-variable-name-face) ;; ip address
    ("[A-Za-z]+ ?[0-9]/[0-9]/[0-9]+\\(-[0-9]+\\)?" . font-lock-variable-name-face) ;; interface name
    ("\\b[0-9]+" . font-lock-variable-name-face)
    ("^ *shutdown" . font-lock-warning-face)
    ("^ *no" . font-lock-negation-char-face))
  '("\\.ios$")
  nil
  "Generic mode for Cisco configuration files")
