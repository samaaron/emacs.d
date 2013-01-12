;;; theme.el --- Appearance matters

;; Let's see what we're running on
(setq on-console (null window-system))

;; No splash screen
(setq inhibit-startup-message t)

;; Don't defer screen updates when performing operations
(setq redisplay-dont-pause t)

;; Some X11 setup
(when window-system
  (setq frame-title-format '(buffer-file-name "%f" ("%b")))
  (tooltip-mode -1)
  (mouse-wheel-mode t)
  (blink-cursor-mode -1))

;; Show line numbers in buffers
(global-linum-mode t)
(setq linum-format (if on-console "%4d " "%4d"))

;; Show column numbers in modeline
(setq column-number-mode t)

;; Redefine linum-on to ignore terminal buffers, because just turning
;; it off in term-mode-hook doesn't work.
(setq linum-disabled-modes
      '(term-mode slime-repl-mode magit-status-mode help-mode))
(defun linum-on ()
  (unless (or (minibufferp) (member major-mode linum-disabled-modes))
    (linum-mode 1)))

;; Highlight current line
;(global-hl-line-mode)

;; Highlight matching parens
(show-paren-mode 1)

;; Set custom theme path
(setq custom-theme-directory (concat dotfiles-dir "themes"))
(dolist
    (path (directory-files custom-theme-directory t "\\w+"))
  (when (file-directory-p path)
    (add-to-list 'custom-theme-load-path path)))

;; Install themes
(package-require 'zenburn-theme)
(package-require 'anti-zenburn-theme)

;; Prepare colour themes
(defun theme-light ()
  (interactive)
  (load-theme 'anti-zenburn)
  (set-face-background 'default "#ffffff")
  (set-face-foreground 'default "#000000")
  (set-face-background 'region "#d4d4d4")
  (set-face-foreground 'region nil)
  (set-face-background 'linum "#f0f0f0")
  (set-face-background 'fringe "#f0f0f0")
  (setq ansi-term-color-vector ['unspecified
                                "#ffffff" "#f5666d" "#4cb64a" "#ce5c00"
                                "#00578e" "#a020f0" "#6799cc" "#000000"]))
(defun theme-dark ()
  (interactive)
  ;; (load-theme 'bubbleberry t)
  (load-theme 'zenburn t)
  (set-face-background 'default "#222")
  (set-face-background 'region "#374186")
  (set-face-background 'fringe "#191919")
  (set-face-background 'hl-line "#191919")
  (set-face-background 'linum nil)
  (set-face-foreground 'linum "#3f5f3f")
  (setq ansi-term-color-vector ['unspecified
                                "#3f3f3f" "#cc9393" "#7f9f7f" "#f0dfaf"
                                "#8cd0d3" "#dc8cc3" "#93e0e3" "#dcdccc"]))
(theme-dark)

;; Set default and presentation mode fonts
(setq default-frame-font "-unknown-Ubuntu Mono-normal-normal-normal-*-17-*-*-*-m-0-iso10646-1")
(set-frame-font default-frame-font)
(setq presentation-frame-font "-unknown-Ubuntu Mono-normal-normal-normal-*-21-*-*-*-m-0-iso10646-1")

(defun toggle-presentation-mode ()
  (interactive)
  (if (string= (frame-parameter nil 'font) default-frame-font)
      (progn
        (set-frame-font presentation-frame-font)
        (theme-light))
    (progn
      (set-frame-font default-frame-font)
      (theme-dark))))
(global-set-key (kbd "C-<f9>") 'toggle-presentation-mode)

;; Engage!
(package-require 'nyan-mode)
(nyan-mode 1)

(provide 'bodil-theme)
