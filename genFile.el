(defvar explicit-shell-file-name "~/.zshrc")
(defvar cwd default-directory)
(defvar workdir "./")
(setq file "resume.org")
(add-to-list 'load-path cwd)
(require 'ox-kishvanchee)

;; Install org
(use-package org
	:config
	(setq org-latex-pdf-process '("latexmk -pdf -outdir=%o %f"))
	(setq org-export-with-smart-quotes t)
    ;; export citations
    (require 'ox-bibtex)
    ;; manage citations
    (require 'org-bibtex-extras)
    ;; ignore headline but include content when exporting
    (require 'ox-extra)
    (ox-extras-activate '(ignore-headlines))
    :custom (org-startup-indented t))


(defun set-exec-path-from-shell-PATH ()
  "Set up Emacs' `exec-path' and PATH environment variable to match
that used by the user's shell.

This is particularly useful under Mac OS X and macOS, where GUI
apps are not started from a shell."
  (interactive)
  (let ((path-from-shell (replace-regexp-in-string
			  "[ \t\n]*$" "" (shell-command-to-string
					  "$SHELL --login -i -c 'echo $PATH'"
							))))
	(setenv "PATH" path-from-shell)
	(setq exec-path (split-string path-from-shell path-separator))))


(defun ox/delete-temp-files ()
  (interactive)
  (setq tempfiles
		(mapcar (lambda (d)
				  (concat (file-name-sans-extension file) d))
				'(".pdf" ".log" ".tex" ".out" ".aux" ".bbl" ".blg")))
  (mapcar (lambda (d) (delete-file d)) tempfiles)
  (setq refs_tempfiles
		(mapcar (lambda (d)
				  (concat "refs" d))
				'(".html" "_bib.html")))
  (mapcar (lambda (d) (delete-file d)) refs_tempfiles)
  )


(defun ox/export-org-to-pdf ()
  (interactive)
  (ox/delete-temp-files)
  (let ((outfile (concat workdir (file-name-sans-extension file) ".tex"))
		(workfile (concat workdir file)))
	(message (format "%s exists: %s" workfile (file-exists-p workfile)))
	(find-file workfile)
	(org-mode)
	(org-export-to-file 'kishvanchee outfile)
	(setq org-latex-pdf-process '("texi2dvi -p -b -V %f"))
	(shell-command (format "pdflatex %s" outfile) "*Messages*" "*Messages*")
	(message (format "Executing bibtex on %s" (file-name-sans-extension file)))
	(shell-command (format "bibtex %s" (file-name-sans-extension outfile) ))
	(shell-command (format "pdflatex %s" outfile) "*Messages*" "*Messages*")
	(org-md-export-to-markdown)))


(set-exec-path-from-shell-PATH)
