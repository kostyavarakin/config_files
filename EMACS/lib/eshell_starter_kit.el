;;; starter-kit-eshell.el --- Making the defaults a bit saner
;;
;; Part of the Emacs Starter Kit
  ;;   (set-face-attribute 'eshell-prompt nil :foreground "turquoise1")
;;     (add-to-list 'eshell-output-filter-functions 'eshell-handle-ansi-color))) 
(setq eshell-cmpl-cycle-completions nil
      eshell-save-history-on-exit t
      eshell-cmpl-dir-ignore "\\`\\(\\.\\.?\\|CVS\\|\\.svn\\|\\.git\\)/\\'")
 
(eval-after-load 'esh-opt
  '(progn
     (require 'em-prompt)
     (require 'em-term)
     (require 'em-cmpl)

     ;; TODO: for some reason requiring this here breaks it, but
     ;; requiring it after an eshell session is started works fine.
     ;; (require 'eshell-vc)
     (setenv "PAGER" "cat")
     (add-hook 'eshell-mode-hook ;; for some reason this needs to be a hook
   '(lambda () (define-key eshell-mode-map "\C-a" 'eshell-bol)))
     (add-to-list 'eshell-visual-commands "ssh")
     (add-to-list 'eshell-visual-commands "tail")
     (add-to-list 'eshell-visual-commands "mutt")
     (add-to-list 'eshell-visual-commands "vim")
     (add-to-list 'eshell-visual-commands "screen")
     (add-to-list 'eshell-visual-commands "lftp")
     (add-to-list 'eshell-visual-commands "ipython")
     (add-to-list 'eshell-visual-commands "telnet")
     (add-to-list 'eshell-visual-commands "tclsh8.4")

     (add-to-list 'eshell-command-completions-alist
                  '("gunzip" "gz\\'"))
     (add-to-list 'eshell-command-completions-alist
                  '("tar" "\\(\\.tar|\\.tgz\\|\\.tar\\.gz\\)\\'"))
))

(provide 'starter-kit-eshell)
;;; starter-kit-eshell.el ends here