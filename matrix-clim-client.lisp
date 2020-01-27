;;;; matrix-clim-client.lisp

(in-package #:matrix-clim-client)

(defmacro bold ((stream) &body body)
  `(with-text-face (,stream :bold)
     ,@body))

(define-application-frame matrixicl ()
  ((current-room :initform nil
		 :initarg :current-room
		 :accessor current-room)
   (main-display :initform "Nothing selected to display"
		 :initarg :main-display
		 :accessor main-display
		 :documentation "what to display in the main window")
   (current-user :initform nil
		 :initarg :current-user
		 :accessor current-user))
  ;; (:pointer-documentation t)
  (:menu-bar matrixicl-menubar)
  (:panes
   (room-list :application
	      :display-function #'display-room-list-text
              :display-time :command-loop
	      :width 300
	      ;; :width* 300
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
	      	     (1/4 int)))
	      ;; room-list
	      ;; (6/8
	      ;; 	 (vertically ()
	      ;; 	   (3/4 room)
	      ;; 	   (1/4 int)))
	      ))))

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
  ;; (setf *temp-display-chat-text* room)
  (setf (main-display *application-frame*) room))

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
  ;;(setf *temp-display-chat-text* event)
  (setf (main-display *application-frame*) event))

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
  (bold (pane) (princ "Select a Room"))
  (fresh-line)
  (slim:with-table (pane :x-spacing 10)
    (loop for room in matrix-query::*rooms*
       do (with-end-of-line-action (pane :wrap*)
	    (with-output-as-presentation (pane ;; (matrix-query::room-id room)
					  room
					  'access-room
					  :single-box t)
	      (slim:with-table (pane)
		(slim:row (slim:cell (bold (pane) (princ (matrix-query::name room)))))
		(slim:row (slim:cell (princ "  ")
				     (princ (matrix-query::topic room)))))
	      (fresh-line))))))

(defparameter *temp-display-chat-text* "hoho2")

(defgeneric set-main-display (item frame pane))

(defmethod set-main-display ((item matrix-query::matrix-room) (frame matrixicl) pane)
  (slim:with-table (pane :x-spacing 10)
    (with-end-of-line-action (pane :wrap*)
      (loop for event in (matrix-query::timeline item)
	 do (with-output-as-presentation (pane event 'pres-tester :single-box t)
	      (slim:with-table (pane)
		(slim:row (slim:cell (bold (pane)
				       (with-drawing-options (pane :ink clim:+dark-violet+)
					 (princ (matrix-query::sender event)))
				       (princ " says:  "))
				     (princ (matrix-query::generate-text event))))))))))

(defmethod set-main-display ((item matrix-query::text-message-event) (frame matrixicl) pane)
  (slim:with-table (pane :x-spacing 10)
    (slim:row (slim:cell (bold (pane) (princ "Here is the content form of the selected event: "))))
    (slim:row (slim:cell (princ (matrix-query::content item))))
    (fresh-line)
    (slim:row (slim:cell (bold (pane) (princ "Here is the body data member of the event object"))))
    (slim:row (slim:cell (princ (matrix-query::body item))))))

(defmethod set-main-display ((item matrix-query::event) (frame matrixicl) pane)
  (slim:with-table (pane :x-spacing 10)
    (slim:row (slim:cell (bold (pane) (princ "Here is the content form of the selected event: "))))
    (slim:row (slim:cell (princ (matrix-query::content item))))))

(defmethod set-main-display ((item string) (frame matrixicl) pane)
  (slim:with-table (pane :x-spacing 10)
    (slim:row (slim:cell (bold (pane) (princ item))))))

(defmethod display-chat ((frame matrixicl) pane)
  (let ((item (main-display frame)))
    (set-main-display item frame pane)))

