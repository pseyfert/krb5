;;; -*- mode: emacs-lisp; indent-tabs-mode: nil -*-
(if (not noninteractive)
    (error "to be used only with -batch"))
;; Avoid vc-mode interference.
(setq vc-handled-backends nil)

;; for debugging
(defun report-tabs ()
  (let ((tab-found (search-forward "\t" nil t)))
    (if tab-found
        (message "Tab found @%s." tab-found)
      (message "No tabs found."))))

(while command-line-args-left
  (let ((filename (car command-line-args-left))
        ;; No backup files; we have version control.
        (make-backup-files nil))
    (find-file filename)
    (message "Read %s." filename)

    (if (not indent-tabs-mode)
        (progn
          (message "Untabifying...")
          (untabify (point-min) (point-max))))

    ;; Only reindent if the file C style is guessed to be "krb5".
    ;; Note that krb5-c-style.el already has a heuristic for setting
    ;; the C style if the file has "c-basic-offset: 4;
    ;; indent-tabs-mode: nil".
    (if (equal c-indentation-style "krb5")
        (c-indent-region (point-min) (point-max)))

    ;; Sometimes whitespace-cleanup gets its internals confused
    ;; when whitespace-mode hasn't been activated on the buffer.
    (let ((whitespace-indent-tabs-mode indent-tabs-mode)
          (whitespace-style '(empty trailing)))
      ;; Only clean up tab issues if indent-tabs-mode is explicitly
      ;; set in the file local variables.
      (if (assq 'indent-tabs-mode file-local-variables-alist)
          (progn
            (message "Enabling tab cleanups.")
            (add-to-list 'whitespace-style 'indentation)
            (add-to-list 'whitespace-style 'space-before-tab)
            (add-to-list 'whitespace-style 'space-after-tab)))
;;      (message "indent-tabs-mode=%s" indent-tabs-mode)
      (setq tab-found (search-forward "\t" nil t))
      (message "Cleaning whitespace...")
      (whitespace-cleanup))

    (save-buffer)
    (kill-buffer)
    (setq command-line-args-left (cdr command-line-args-left))))
