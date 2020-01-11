;;;; matrix-clim-client.lisp

(in-package #:matrix-clim-client)

(defmacro bold ((stream) &body body)
  `(with-text-face (,stream :bold)
     ,@body))

(define-application-frame matrixicl ()
  ()
  ;; (:pointer-documentation t)
  (:menu-bar matrixicl-menubar)
  (:panes
   (room-list :application
	      :display-function #'display-room-list-text
              :display-time :command-loop
	      ;; :scroll-bars t
	      )
   (room :application
	 ;; :display-function #'display-chat
	 :display-time :command-loop
	 ;; :scroll-bars t
	 )
   (int :interactor))
  (:layouts
   (default (horizontally ()
	      (1/4 room-list)
	      (3/4 (vertically ()
		     (3/4 room)
		     (1/4 int)))))))

(defun app-main ()
  (run-frame-top-level (make-application-frame 'matrixicl)))

(make-command-table 'matrixicl-menubar
		    :errorp nil
		    :menu '(("App" :menu matrixicl-application-menu)
			    ("User" :menu matrixicl-user-menu)
			    ("Rooms" :menu matrixicl-room-menu)))

(make-command-table 'matrixicl-application-menu
		    :errorp nil
		    :menu '(("Quit" :command com-quit)))

(make-command-table 'matrixicl-room-menu
		    :errorp nil
		    :menu '(("New" :command com-new-room)))

(make-command-table 'matrixicl-user-menu
		    :errorp nil
		    :menu '(("Login" :command com-login)
			    ("Logout" :command com-logout)))

(define-matrixicl-command (com-quit :name t) ()
  (frame-exit *application-frame*))

(define-matrixicl-command (com-exit :name t) ()
  (frame-exit *application-frame*))

;; (define-matrixicl-command (com-write-string :name t) ()
;;   (write-string "test string" ))

;; (defmethod display-room-list-text ((frame matrixicl) stream)
;;   (with-end-of-line-action (stream :wrap*)
;;     (let ((rooms (matrix-query::joined-rooms))
;;     	  (y 15))
;;       (loop for room in rooms
;;     	 for i from 1
;;     	 do (format stream "placeholder name (~a)" ;; (matrix-query::name room)
;; 		    (matrix-query::room-id room))))
;;     (format stream "here is a text test for wrapping hihihihi how are you?!!!!?")))

(define-presentation-type pres-tester ())

(define-presentation-to-command-translator invoke-test-pres
    (pres-tester com-quit matrixicl :gesture :select)
    (obj)
  (com-exit))

;; (defmethod display-room-list-text ((frame matrixicl) pane)
;;   (with-output-as-presentation)
;;   (let ((rooms (matrix-query::joined-rooms))
;; 	(y 15))
;;     (loop for room in rooms
;;        for i from 1
;;        do (format stream "placeholder name (~a)" ;; (matrix-query::name room)
;; 		  (matrix-query::room-id room)))))

(defmethod display-room-list-text ((frame matrixicl) pane)
  (slim:with-table (pane)
    (slim:row (slim:cell (bold (pane) (princ "desc: ")))
	      (slim:cell (princ "hihi"))))
  (fresh-line)
  (slim:with-table (pane :x-spacing 10)
    (with-output-as-presentation (pane "testytest" 'pres-tester :single-box t)
      ;; (slim:row
      ;; 	(bold (pane)
      ;; 	  (slim:cell (format pane "n")))
      ;; 	(slim:cell
      ;; 	  (clim:with-drawing-options (pane :ink clim:+dark-violet+)
      ;; 	    (princ "restart name r")))
      ;; 	(slim:cell (princ "r ")))
      (format pane "exit"))))



;; (defmethod display-chat ((frame matrixicl) pane)
;;   (with-end-of-line-action (pane :wrap*)
;;     (let ((room-timeline (matrix-query::timeline (matrix-query::current-room))))
;;       (loop for event in room-timeline
;; 	 do (format pane "~a" (matrix-query::generate-text event))))))

;; (draw-text* stream "Document:" 10 15)
;; (draw-text* stream "Untitled" 10 30)
;; (draw-text* stream "Untitled" 20 10000)
;; (draw-text* stream "jk" 20 10010)

(define-matrixicl-command (com-print-rooms :name "Print Rooms") ()
  (matrix-query::update-joined-rooms))

(define-matrixicl-command (com-login :name t)
    ()
  (when matrix-query::*session-user-auth*
    (com-login-helper)))

(define-matrixicl-command (com-login-helper :name t)
    ((Username 'string) (Password 'string))
  (matrix-query::login username password))

(define-matrixicl-command (com-logout :name t) ()
  (matrix-query::logout)
  "logged out")


;; (define-matrixicl-command (com-draw-add-string :menu t :name "Add String")
;;     ((string 'string) (x 'integer) (y 'integer))
;;   (push (cons (make-point x y) string)
;; 	(strings *application-frame*))
;;   ;; (update-draw-pane)
;;   )


