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
	 :display-function #'display-chat
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
    (pres-tester com-select-room matrixicl :gesture :select)
    (obj)
  ;;(com-exit)
  ;;(setf *temp-display-chat-text* obj)
  (list obj))


;; command to select a room: 
;; (define-matrixicl-command (com-select-room :name t)
;;     ((room 'matrix-query::matrix-room))
;;   ())

(define-matrixicl-command (com-select-room :name t)
    ((room matrix-query::matrix-room :prompt "enter a string"))
  (setf *temp-display-chat-text* room))

(define-presentation-type room-select-presentation-type ())

(define-presentation-to-command-translator invoke-room-select
    (room-select-presentation-type ;; com-select-room
     com-exit
     matrixicl :gesture :select)
    (obj)
  ;; (com-select-room ;;obj
  ;; 		   )
  ;;(com-exit)
  )

(define-presentation-to-command-translator invoke-room-select
    (pres-tester com-select-room matrixicl :gesture :select)
    (obj)
  ;;(com-exit)
  ;;(setf *temp-display-chat-text* obj)
  (list obj))

(defparameter *temp-event-info* nil)

(define-matrixicl-command (com-select-event  :name t)
    ((event matrix-query::text-message-event))
  (setf *temp-display-chat-text* event))

(define-presentation-type event-setter ())

(define-presentation-to-command-translator invoke-event-setter
    (pres-tester com-select-event matrixicl :gesture :select)
    (obj)
  (list obj))


;; (defmethod display-room-list-text ((frame matrixicl) pane)
;;   (with-output-as-presentation)
;;   (let ((rooms (matrix-query::joined-rooms))
;; 	(y 15))
;;     (loop for room in rooms
;;        for i from 1
;;        do (format stream "placeholder name (~a)" ;; (matrix-query::name room)
;; 		  (matrix-query::room-id room)))))

(defmethod display-room-list-text ((frame matrixicl) pane)
  ;; (with-output-as-presentation (pane "room-something" 'pres-tester :single-box t)
  ;;   (slim:with-table (pane)
  ;;     (slim:row (slim:cell (bold (pane) (princ "desc: ")))
  ;; 		(slim:cell (princ "hihi")))))
  (bold (pane) (princ "Select a Room"))
  (fresh-line)
  (slim:with-table (pane :x-spacing 10)
    (with-end-of-line-action (pane :wrap*)
      (loop for room in matrix-query::*rooms*
	 do ;; (with-output-as-presentation (pane (matrix-query::room-id room) ))
	 ;;(print (matrix-query::name room)))
	 ;; (format pane "~a~%  ~a" (matrix-query::name room) (matrix-query::topic room))
	   (with-output-as-presentation (pane ;; (matrix-query::room-id room)
					 room
					 ;; 'invoke-room-select
					 ;; 'matrix-query::matrix-room
					 'pres-tester
					 :single-box t)
	     (slim:with-table (pane)
	       (slim:row (slim:cell (bold (pane) (princ "room: ")))
			 (slim:cell (princ (matrix-query::name room))))
	       (slim:row (slim:cell (bold (pane) (princ "  Topic: ")))
			 (slim:cell (princ (matrix-query::topic room)))))
	     (fresh-line))))))

(defparameter *temp-display-chat-text* "hoho2")

(defmethod display-chat ((frame matrixicl) pane)
  (cond ((equal (type-of *temp-display-chat-text*) 'matrix-query::matrix-room)
	 (slim:with-table (pane :x-spacing 10)
	   (with-end-of-line-action (pane :wrap*)
	     (loop for event in (matrix-query::timeline *temp-display-chat-text*)
		do (with-output-as-presentation (pane event 'pres-tester :single-box t)
		     (slim:with-table (pane)
		       (slim:row (slim:cell (bold (pane)
					      (princ (matrix-query::sender event))
					      (princ " Says:  "))
					    ;; (princ (matrix-query::content event))
					    (princ (matrix-query::generate-text event))
					    ))
		       ;;(slim:row (slim:cell (print (matrix-query::content event))))
		       ))
		;; (with-output-as-presentation (pane event 'exter :single-box t)
		;; 	(slim:with-table (pane)
		;; 	  (slim:row (slim:cell (bold (pane)
		;; 				 (princ (matrix-query::sender event))
		;; 				 (princ ": ")))
		;; 		    (slim:cell (print (matrix-query::content event)))))
		;; 	(fresh-line))
		  ))))
	;; ((equal (type-of *temp-display-chat-text*) 'matrix-query::event)
	;;  (bold (pane) (princ (matrix-query::content *temp-display-chat-text*))))
	(t
	 (slim:with-table (pane :x-spacing 10)
	   (slim:row (slim:cell (bold (pane) (princ "Here is the form of the selected event: "))))
	   (slim:row (slim:cell (princ (matrix-query::content *temp-display-chat-text*))
				;; (princ (inspect *temp-display-chat-text*))
		       ))))))

;; (app-main)

;; (define-matrixicl-command (com-print-rooms :name "Print Rooms") ()
;;   (matrix-query::update-joined-rooms))

;; (define-matrixicl-command (com-login :name t)
;;     ()
;;   (when matrix-query::*session-user-auth*
;;     (com-login-helper)))

(define-matrixicl-command (com-login-helper :name t)
    ((Username 'string) (Password 'string))
  (matrix-query::login username password)
  (matrix-query::initial-sync)
  (matrix-query::setup-rooms-from-state))

(define-matrixicl-command (com-logout :name t) ()
  (matrix-query::logout)
  "logged out")

