;;; bodil-revealjs.el -- Reveal.js integration, because we can.

(when (require 'xwidget nil t)

  (defun xwidget-event-handler ()
    "Receive xwidget event."
    (interactive)
    (xwidget-log "stuff happened to xwidget %S" last-input-event)
    (let*
        ((xwidget-event-type (nth 1 last-input-event))
         (xwidget (nth 2 last-input-event)))
      (funcall 'revealjs-webkit-callback xwidget xwidget-event-type)))

  (defun revealjs-webkit-callback (xwidget xwidget-event-type)
    (save-excursion
      (cond ((buffer-live-p (xwidget-buffer xwidget))
             (set-buffer (xwidget-buffer xwidget))
             (let* ((strarg  (nth 3 last-input-event)))
               (cond ((eq xwidget-event-type 'document-load-finished)
                      (xwidget-log "webkit finished loading: '%s'" (xwidget-webkit-get-title xwidget))
                      (xwidget-adjust-size-to-content xwidget))
                     ((eq xwidget-event-type 'navigation-policy-decision-requested)
                      (if (string-match ".*#\\(.*\\)" strarg)
                          (xwidget-webkit-show-id-or-named-element xwidget (match-string 1 strarg))))
                     (t (xwidget-log "unhandled event:%s" xwidget-event-type)))))
            (t (xwidget-log "error: callback called for xwidget with dead buffer")))))

  (defun revealjs-open (url &optional new-window-flag)
    (interactive
     (browse-url-interactive-arg "Slide deck URL: "
                                 "http://localhost:1337/"))
    (let*
        ((bufname "*revealjs*")
         (buf (get-buffer-create bufname))
         xw)
      (setq xwidget-webkit-last-session-buffer (switch-to-buffer buf))
      (insert " ")
      (setq xw (xwidget-insert 1 'webkit-osr  bufname 1000 1000))
      (xwidget-put xw 'callback 'revealjs-webkit-callback)
      (revealjs-mode)
      (xwidget-webkit-goto-uri (xwidget-webkit-last-session) url)
      (xwidget-webkit-fit-width)))

  (defun revealjs-reload ()
    (interactive)
    (let ((url (xwidget-webkit-current-url))
          (ses (xwidget-webkit-current-session)))
      (xwidget-webkit-goto-uri ses "http://example.com/")
      (xwidget-webkit-goto-uri ses url)))

  ;; Need to disable "kill buffer with xwidgets" question for smooth reload.
  (remove-hook 'kill-buffer-query-functions 'xwidget-kill-buffer-query-function)

  (defmacro revealjs-exec (script)
    `(xwidget-webkit-execute-script
      (xwidget-webkit-current-session)
      ,script))

  (defun revealjs-next-slide ()
    (interactive)
    (revealjs-exec "Reveal.navigateNext();"))

  (defun revealjs-prev-slide ()
    (interactive)
    (revealjs-exec "Reveal.navigatePrev();"))

  (defun revealjs-navigate-up ()
    (interactive)
    (revealjs-exec "Reveal.navigateUp();"))

  (defun revealjs-navigate-down ()
    (interactive)
    (revealjs-exec "Reveal.navigateDown();"))

  (defun revealjs-navigate-left ()
    (interactive)
    (revealjs-exec "Reveal.navigateLeft();"))

  (defun revealjs-navigate-right ()
    (interactive)
    (revealjs-exec "Reveal.navigateRight();"))

  (defun revealjs-overview ()
    (interactive)
    (revealjs-exec "Reveal.toggleOverview();"))

  (defvar revealjs-mode-map
    (let ((map (make-sparse-keymap)))
      (define-key map (kbd "<next>") 'revealjs-next-slide)
      (define-key map (kbd "<prior>") 'revealjs-prev-slide)
      (define-key map (kbd "<up>") 'revealjs-navigate-up)
      (define-key map (kbd "<down>") 'revealjs-navigate-down)
      (define-key map (kbd "<left>") 'revealjs-navigate-left)
      (define-key map (kbd "<right>") 'revealjs-navigate-right)
      (define-key map (kbd "SPC") 'revealjs-overview)
      (define-key map (kbd "r") 'revealjs-reload)
      map))

  (global-set-key (kbd "C-c g") 'revealjs-reload)

  (define-derived-mode revealjs-mode
    xwidget-webkit-mode "Reveal.js" "Webkit mode adapted for Reveal.js slides"))

(provide 'bodil-revealjs)