
(defpackage #:matrixicl.file-selector
  (:use #:clim-lisp #:clim #:clim-tab-layout #:clim-extensions)
  (:export "app-main"))

(in-package #:matrixicl.file-selector)

(defparameter *display-hidden-files* nil)

(defmacro bold ((stream) &body body)
  `(with-text-face (,stream :bold)
     ,@body))

(define-application-frame file-selector ()
  ((original-directory :initarg :original-directory
		       :accessor original-directory
		       :initform (uiop:getcwd)))
  (:menu-bar file-selector-menubar)
  (:panes
   (int :interactor)
   (info :application
	 :display-function #'display-info-pane
	 :display-time :command-loop
	 :incremental-redisplay t
	 :height 20
	 :scroll-bar nil
	 :background +black+
	 :foreground +white+)
   (file-displayer :application
		   :display-function #'display-files
		   :display-time :command-loop
		   :width 1920))
  (:layouts
   (default
    (vertically ()
      info
      (:fill file-displayer)
      (100 int)))))

(make-command-table 'file-selector-menubar
		    :errorp nil
		    :menu '(("Quit" :command com-quit)
			    ("Directories" :menu file-selector-directory-menu)))

(make-command-table 'file-selector-directory-menu
		    :errorp nil
		    :menu '(("Up Directory" :command com-up-directory)))

(defun app-main ()
  (run-frame-top-level (make-application-frame 'file-selector)))

(defun file-or-directory-hidden-p (path)
  (let ((splits (reverse (str:split "/" (format nil "~a" path)))))
    (if (string-equal (car splits) "") ; its directory
	(string-equal (subseq (cadr splits) 0 1) ".") ; its hidden
	(string-equal (subseq (car splits) 0 1) "."))))

;; (app-main)

(define-file-selector-command (com-quit :name "Quit") ()
  (frame-exit *application-frame*))

(define-file-selector-command (com-up-directory :name t) ()
  (uiop:chdir ".."))

(define-file-selector-command (com-change-directory :name t)
    ((directory string :prompt "Enter a directory: "))
  (handler-case (cond ((uiop:directory-exists-p directory)
		       (uiop:chdir directory))
		      ((uiop:file-exists-p directory)
		       (matrixicl::select-file directory)
		       (uiop:chdir (original-directory *application-frame*))
		       (com-quit)))
    (sb-posix:syscall-error () nil)))

(define-presentation-type enter-directory ())

(define-presentation-to-command-translator invoke-directory-entry
    (enter-directory com-change-directory file-selector :gesture :select)
    (obj)
  (list obj))

(defmethod display-files ((frame file-selector) pane)
  (let ((current-directory (uiop:getcwd)))
    (format pane "~%~%here are files!~%~%")
    (with-output-as-presentation (pane ".." 'enter-directory
				       :single-box t)
      (format pane "Up One Directory (..)"))
    (with-end-of-line-action (pane :wrap*)
      (loop for file in (cl-fad:list-directory current-directory)
	    do (with-output-as-presentation (pane file 'enter-directory
						  :single-box t)
		 (if (file-or-directory-hidden-p file)
		     (when *display-hidden-files*
		       (format pane "~%~a" file))
		     (format pane "~%~a" file)))))
    (scroll-extent pane 0 0)))

(defmethod display-info-pane ((frame file-selector) pane)
  (format pane "Current Directory: ~a" (uiop:getcwd)))
