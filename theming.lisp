;;; theming.lisp
;;; this file handles all constants and variables used for theming the matrixicl
;;; application
(in-package :matrixicl)

;; (defparameter *themes* '((:light . ((+display-background+ clim:+white+)
;; 				    (+display-foreground+ clim:+black+)))
;; 			 (:dark . ((+display-background+ clim:+black+)
;; 				   (+display-foreground+ clim:+white+)))))

(defparameter *themes* nil)

(defvar +display-background+ clim:+white+)
(defvar +display-foreground+ clim:+black+)

(defvar +info-background+ clim:+black+)
(defvar +info-foreground+ clim:+white+)

(defun set-theme (theme-name)
  "this is a giant hack because I cant be arsed to fix a macro for this yet."
  (let ((bod (loop for (var color) in (cdr (assoc theme-name *themes*))
		   collect `(setf ,var ,color))))
    (eval `(progn ,@bod))))

(defmacro deftheme (theme-name &body variables)
  "this takes a theme name and all variable pairs for the theme. "
  `(let ((theme? (assoc ,theme-name *themes*)))
     (if theme?
	 (setf (cdr theme?) ',variables)
	 (setf *themes* (cons '(,theme-name ,@variables) *themes*)))))

;;; Default themes:

(deftheme :light
  (+display-background+ clim:+black+)
  (+display-foreground+ clim:+black+)
  (+info-background+ +black+)
  (+info-foreground+ +white+))

(deftheme :dark
  (+display-background+ +grey3+)
  (+display-foreground+ +grey80+))

(deftheme :peachy-keen
  (+display-background+ +lemon-chiffon+)
  (+display-foreground+ +midnight-blue+)
  (+info-background+ +midnight-blue+)
  (+info-foreground+ +lemon-chiffon+))

