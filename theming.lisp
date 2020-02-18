;;; theming.lisp
;;; this file handles all constants and variables used for theming the matrixicl
;;; application
(in-package :matrixicl)

(defmacro defcolor-testing (name color)
  (check-type color (or symbol list))
  `(let ((real-color ,(if (atom color)
			  color
			  `(progn
			     ,(cond ((eq (car color) :ihs)
				     `(apply 'make-ihs-color
					     (second ',color)
					     (third ',color)
					     (fourth ',color)))
				    ((eq (car color) :rgb)
				     `(apply 'make-rgb-color
					     (second ',color)
					     (third ',color)
					     (fourth ',color)))
				    ((or (eq (car color) :grey)
					 (eq (car color) :gray))
				     `(apply 'make-gray-color
					     (second ',color))))))))
     ,(if name
	  `(defparameter ,name real-color)
	  'real-color)))

(defmacro defcolor (name color)
  (check-type color (or symbol list))
  `(let ((real-color ,(if (atom color)
			  color
			  `(progn
			     ,(cond ((eq (car color) :ihs)
				     `(make-ihs-color (eval (second ',color))
						      (eval (third ',color))
						      (eval (fourth ',color))))
				    ((eq (car color) :rgb)
				     `(make-rgb-color (eval (second ',color))
						      (eval (third ',color))
						      (eval (fourth ',color))))
				    ((or (eq (car color) :grey)
					 (eq (car color) :gray))
				     `(make-gray-color (eval (second ',color)))))))))
     ,(if name
	  `(defparameter ,name real-color)
	  'real-color)))

;; (defcolor nil clim:+white+)

(defcolor +display-background+ clim:+white+)
(defcolor +display-foreground+ clim:+black+)

(defcolor +info-background+ clim:+black+)
(defcolor +info-foreground+ clim:+white+)

(defvar *themes* nil)

(defmacro deftheme (theme-name &body variables)
  "this takes a theme name and all variable pairs for the theme. "
  `(let ((theme? (assoc ,theme-name *themes*)))
     (if theme?
	 (setf (cdr theme?) ',variables)
	 (setf *themes* (cons '(,theme-name ,@variables) *themes*)))))

(defun set-theme (theme-name)
  "this is a giant hack because I cant be arsed to fix a macro for this yet."
  (let ((bod (loop for (var color) in (cdr (assoc theme-name *themes*))
		   collect `(setf ,var ,color))))
    (eval `(progn ,@bod))))

;;; Default themes:

(deftheme :light
  (+display-background+ clim:+white+)
  (+display-foreground+ (defcolor nil (:ihs 1.2 (/ 1 3) 0.247)))
  (+info-background+ +black+)
  (+info-foreground+ +white+))

(deftheme :dark
  (+display-background+ +grey3+)
  (+display-foreground+ +grey80+))

(deftheme :violet-lemon
  (+display-background+ +lemon-chiffon+)
  (+display-foreground+ +violet-red+)
  (+info-background+ +violet-red+)
  (+info-foreground+ +lemon-chiffon+))

(deftheme :peachy-keen
  (+display-background+ +peachpuff1+)
  (+display-foreground+ +peachpuff4+)
  (+info-background+ +peachpuff4+)
  (+info-foreground+ +peachpuff1+))

(deftheme :red-white-and-blue
  (+display-background+ +white+)
  (+display-foreground+ +red+)
  (+info-background+ +blue+)
  (+info-foreground+ +red+))

(deftheme :greenie
  (+display-background+ +pale-green+)
  (+display-foreground+ +medium-sea-green+)
  (+info-background+ +medium-sea-green+)
  (+info-foreground+ +pale-green+))

