;;; theming.lisp
;;; this file handles all constants and variables used for theming the matrixicl
;;; application
(in-package :matrixicl)

(defmacro defcolor (name type-or-color &rest color-spec)
  "this macro generates a color and either binds it to `name` or if `name` is nil
returns the color. type-or-color must either be a keyword specifying the type of 
color to generate or a variable naming a color [eg +white+]. color spec must be
one of several things: 

1. a hex string 6 characters in length, which specifies 3 colors
2. a list of color numbers, ranging either from 0 to 1, or from 1 to 255. the 
   order is Red Green Blue OR intensity hue saturation. this must be coupled with 
   the appropriate type keyword, either :rgb or :ihs. When using :ihs the values 
   must be [between 0 and √3], and the other two must be between 0 and 1.
3. a luminosity value, which must be paired with :grey or :gray type keyword. 

example usage: 
;; (defcolor +my-red+ :rgb 0.92 0 0)
;; (defcolor nil :ihs 1 1 1)v"
  (check-type type-or-color (or symbol keyword))
  (let ((color (if (stringp (car color-spec))
		   (list
		    (parse-integer (subseq (car color-spec) 0 2) :radix 16)
		    (parse-integer (subseq (car color-spec) 2 4) :radix 16)
		    (parse-integer (subseq (car color-spec) 4 6) :radix 16))
		   color-spec)))
    `(let ((real-color ,(if (not color)
			    type-or-color
			    (cond ((eq type-or-color :ihs)
				   `(make-ihs-color ,(first color)
						    ,(second color)
						    ,(third color)))
				  ((eq type-or-color :rgb)
				   `(make-rgb-color ,(if (< 1 (first color))
							 (/ (first color) 255)
							 (first color))
						    ,(if (< 1 (second color))
							 (/ (second color) 255)
							 (second color))
						    ,(if (< 1 (third color))
							 (/ (third color) 255)
							 (third color))))
				  ((or (eq type-or-color :grey)
				       (eq type-or-color :gray))
				   `(make-gray-color ,(first color)))))))
       ,(if name
	    `(defparameter ,name real-color)
	    'real-color))))

(defcolor +display-background+ clim:+white+)
(defcolor +display-foreground+ clim:+black+)

(defcolor +info-background+ clim:+black+)
(defcolor +info-foreground+ clim:+white+)

(defcolor +sender-foreground+ +dark-violet+)
(defcolor +message-contents+ +display-foreground+)

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
    (eval `(progn ,@bod))
    theme-name))

(defun list-themes ()
  (loop for theme in *themes*
	collect (car theme)))

;;; Default themes:

(deftheme :light
  (+display-background+ clim:+white+)
  (+display-foreground+ +black+)
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
  (+display-foreground+ ;; +medium-sea-green+ ;;
			+pale-green+)
  ;; (+display-foreground+ +medium-sea-green+)
  ;; 0.2353 0.7020 0.4431
  ;; (+display-foreground+ (defcolor nil :rgb  0.2553 0.7520 0.4431))
  ;; (+display-foreground+ (defcolor nil :rgb #x3e #xa3 #x3a))
  (+display-background+ (defcolor nil :rgb #x3e #xa3 #x3a))
  (+info-background+ +medium-sea-green+)
  (+info-foreground+ +pale-green+)
  (+sender-foreground+ (defcolor nil :rgb #xbd #x1e #x23))
  (+message-contents+ +black+))
