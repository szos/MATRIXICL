;;;; matrix-clim-client.lisp

(in-package #:matrixicl)

(defmacro bold ((stream) &body body)
  `(with-text-face (,stream :bold)
     ,@body))

(defparameter *selected-file* nil)

(defparameter *matrixicl-class-instance* nil)

(define-application-frame matrixicl ()
  ((current-room :initform nil
		 :initarg :current-room
		 :accessor current-room)
   (selected-file :initform nil
		  :initarg :selected-file
		  :accessor selected-file)
   (main-display :initform "Nothing selected to display"
		 :initarg :main-display
		 :accessor main-display
		 :documentation "what to display in the main window")
   (current-user :initform nil
		 :initarg :current-user
		 :accessor current-user)
   (scroll-to-bottom :initform t
		     :initarg :scroll-to-bottom
		     :accessor scroll-to-bottom))
  ;; (:pointer-documentation t)
  (:menu-bar matrixicl-menubar)
  (:panes
   (room-list :application
	      :display-function #'display-room-list-text
              :display-time :command-loop
	      :width 200
	      ;; :width* 300
	      ;; :scroll-bars t
	      )
   (room :application
	 :display-function #'display-chat
	 :display-time :command-loop
	 ;;:scroll-bars t
	 )
   (event-viewer-pane :application
   		      ;; :display-function #'display-event-pane
   		      ;; :scroll-bars t
		      )
   (int :interactor))
  (:layouts
   (default (horizontally ()
	      room-list
	      (:fill (vertically ()
		       (3/4 room)
		       (1/4 int)))))
   (room-view (horizontally ()
		(1/4 room-list)
		(3/4 (vertically ()
		       (3/4 room)
		       (1/4 int)))))
   (event-view )))

(defun app-main ()
  (let ((f (make-application-frame 'matrixicl)))
    (setf *matrixicl-class-instance* f)
    (run-frame-top-level f)))

(defun select-file (path)
  (setf (selected-file *matrixicl-class-instance*)  path))

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
		(slim:row (slim:cell (bold (pane)
				       (princ (matrix-query::name room)))))
		(slim:row (slim:cell (princ "  ")
				     (princ (matrix-query::topic room)))))
	      (fresh-line))))))

(defparameter *temp-display-chat-text* "hoho2")

;;; (defgeneric make-event-text (event))

;;; (defmethod make-event-text ((event matrix-query::text-message-event)))

(defgeneric print-event-text (event frame pane))

(defmethod print-event-text ((event matrix-query::event) (frame matrixicl) pane)
  (with-end-of-page-action (pane :scroll)
    (with-output-as-presentation (pane event 'access-event :single-box t)
      (slim:with-table (pane)
	(slim:row (slim:cell (bold (pane)
			       (with-drawing-options
				   (pane :ink clim:+dark-violet+)
				 (princ (matrix-query::sender event)))
			       (princ " says:  "))
			     (princ (matrix-query::generate-text event))))))))

(defmethod print-event-text ((event matrix-query::text-message-event)
			     (frame matrixicl) pane)
  (with-end-of-page-action (pane :scroll)
    (with-output-as-presentation (pane event 'access-event :single-box t)
      (slim:with-table (pane)
	(slim:row (slim:cell (bold (pane)
			       (with-drawing-options
				   (pane :ink clim:+dark-violet+)
				 (princ (matrix-query::sender event)))
			       (princ " says:  "))
			     (princ (matrix-query::generate-text event))))))))

(defmethod print-event-text ((event matrix-query::create-room-event)
			     (frame matrixicl) pane)
  (with-end-of-page-action (pane :scroll)
    (with-output-as-presentation (pane event 'access-event :single-box t)
      (slim:with-table (pane)
	(slim:row (slim:cell (bold (pane)
			       (with-drawing-options
				   (pane :ink clim:+dark-violet+)
				 (princ (matrix-query::creator event)))
			       (princ " created the room"))))))))

(defgeneric print-main-display (item frame pane))

(defmethod print-main-display ((item matrix-query::matrix-room)
			       (frame matrixicl) pane)
  (with-end-of-page-action (pane :scroll)
    (slim:with-table (pane :x-spacing 10)
      (with-end-of-line-action (pane :wrap*)
	(slim:with-table (pane)
	  (slim:row
	    (slim:cell
	      (bold (pane)
		(with-drawing-options (pane :ink clim:+green4+)
		  (with-output-as-presentation (pane
						item
						'update-with-prior-events
						:single-box t)
		    (princ "Fetch 10"))
		  (with-output-as-presentation (pane
						item
						'update-with-many-prior-events
						:single-box t)
		    (princ " (or 30) "))
		  (with-output-as-presentation (pane
						item
						'update-with-prior-events
						:single-box t)
		    (princ "earlier messages")))))))
	(loop for event in (matrix-query::timeline item)
	   do ;; (with-output-as-presentation (pane event 'pres-tester :single-box t)
	   ;;   (slim:with-table (pane)
	   ;; 	(slim:row (slim:cell (bold (pane)
	   ;; 			       (with-drawing-options (pane :ink clim:+dark-violet+)
	   ;; 				 (princ (matrix-query::sender event)))
	   ;; 			       (princ " says:  "))
	   ;; 			     (princ (matrix-query::generate-text event))))))
	     ;; (print-event-text event frame pane)
	     (display-event-in-pane event frame pane))))
    ;; (format pane " ")
    ))

(defmethod print-main-display ((item matrix-query::matrix-room)
			       (frame matrixicl) pane)
  ;; (princ "heyo" pane)
  (with-end-of-page-action (pane :scroll)
    (with-end-of-line-action (pane :wrap*)
      (with-drawing-options (pane :ink clim:+green4+)
  	(bold (pane)
	  (with-output-as-presentation (pane item 'update-with-prior-events)
  	    (princ "Fetch 10" pane))
  	  (with-output-as-presentation (pane item 'update-with-many-prior-events)
  	    (princ " (or 30) " pane))
  	  (with-output-as-presentation (pane item 'update-with-prior-events)
  	    (princ "earlier messages" pane))))
      (terpri pane)
      (loop :for event :in (matrix-query::timeline item)
  	 do (display-event-in-pane event frame pane))))
  )

(defgeneric display-event-in-pane (event frame pane))

(defmethod display-event-in-pane ((event matrix-query::event)
				  (frame matrixicl) pane)
  (with-output-as-presentation (pane event 'access-event :single-box t)
    (bold (pane)
      (with-drawing-options (pane :ink clim:+dark-violet+)
	(princ (matrix-query::sender event) pane))
      (princ " says: " pane))
    (terpri pane)
    (princ "    " pane)
    (princ (matrix-query::generate-text event) pane)
    (terpri pane)))

(defmethod display-event-in-pane ((event matrix-query::text-message-event)
				  (frame matrixicl) pane)
  (with-output-as-presentation (pane event 'access-event :single-box t)
    (bold (pane)
      (with-drawing-options (pane :ink clim:+dark-violet+)
	(princ (matrix-query::sender event) pane))
      (princ " says: " pane))
    (terpri pane)
    (princ "    " pane)
    (princ (matrix-query::generate-text event) pane)
    (terpri pane)))

(defmethod print-main-display ((item matrix-query::text-message-event)
			       (frame matrixicl) pane)
  (slim:with-table (pane :x-spacing 10)
    (with-output-as-presentation (pane (current-room *application-frame*)
				       'room-return-presentation
				       :single-box t)
      (slim:row (slim:cell (bold (pane)
			     (with-drawing-options (pane :ink clim:+green4+)
			       (princ "RETURN TO ROOM"))))))
    (slim:row (slim:cell
		(bold (pane)
		  (princ "Here is the content form of the selected event: "))))
    (slim:row (slim:cell (princ (matrix-query::content item))))
    (fresh-line)
    (slim:row (slim:cell
		(bold (pane)
		  (princ "Here is the body data member of the event object"))))
    (slim:row (slim:cell (princ (matrix-query::body item))))))

(defun get-slots (object)
  ;; thanks to cl-prevalence
  #+openmcl
  (mapcar #'ccl:slot-definition-name
      (#-openmcl-native-threads ccl:class-instance-slots
       #+openmcl-native-threads ccl:class-slots
       (class-of object)))
  #+cmu
  (mapcar #'pcl:slot-definition-name (pcl:class-slots (class-of object)))
  #+sbcl
  (mapcar #'sb-pcl:slot-definition-name (sb-pcl:class-slots (class-of object)))
  #+lispworks
  (mapcar #'hcl:slot-definition-name (hcl:class-slots (class-of object)))
  #+allegro
  (mapcar #'mop:slot-definition-name (mop:class-slots (class-of object)))
  #+sbcl
  (mapcar #'sb-mop:slot-definition-name (sb-mop:class-slots (class-of object)))
  #+clisp
  (mapcar #'clos:slot-definition-name (clos:class-slots (class-of object)))
  #-(or openmcl cmu lispworks allegro sbcl clisp)
  (error "not yet implemented"))

(defun print-object-slots (object stream)
  (format stream "{ ~s ~s}" (type-of object)
      (loop for i in (get-slots object)
	 collect (cons i (handler-case (slot-value object i)
			   (unbound-slot nil ;; "UNBOUND SLOT"
			     ))))))

(defun print-object-slots (object pane)
  (slim:with-table (pane)
    (slim:row (slim:cell (bold (pane)
			   (princ "Event Type:  ")
			   (with-drawing-options (pane :ink clim:+red+)
			     (princ (type-of object))))))
    (loop for i in (get-slots object)
       do (slim:row (slim:cell (bold (pane)
				 (with-drawing-options
				     (pane :ink clim:+dark-violet+)
				   (princ i))))
		    (slim:cell (princ (handler-case (slot-value object i)
					;;(unbound-slot (UNBOUND-SLOT))
					(unbound-slot nil)
					)))))))


(defmethod print-main-display ((item matrix-query::event) (frame matrixicl) pane)
  (slim:with-table (pane :x-spacing 10)
    (with-output-as-presentation (pane (current-room *application-frame*)
				       'room-return-presentation
				       :single-box t)
      (slim:row (slim:cell (bold (pane)
			     (with-drawing-options (pane :ink clim:+green4+)
			       (princ "RETURN TO ROOM"))))))
    (slim:row (slim:cell (bold (pane)
			   (format pane "~a, ~a" (matrix-query::event-type item)
				   (type-of item)))))
    (slim:row (slim:cell
		(bold (pane)
		  (princ "Here is the content form of the selected event: "))))
    (slim:row (slim:cell (princ (matrix-query::content item))))

    (slim:row (slim:cell (bold (pane) (princ "here is the event"))))
    ;;(slim:row (slim:cell (princ (inspect item))))
    (with-end-of-line-action (pane :scroll)
      (print-object-slots item pane))))

(defmethod print-main-display ((item string) (frame matrixicl) pane)
  (slim:with-table (pane :x-spacing 10)
    (slim:row (slim:cell (bold (pane) (princ item))))))

(defmethod display-chat ((frame matrixicl) pane)
  (with-end-of-page-action (pane :scroll)
    (let ((item (main-display frame)))
      (print-main-display item frame pane)
      ;; (fresh-line)
      ;; we need this line to ensure that we scroll to the bottom of the pane
      ;; (when (scroll-to-bottom *application-frame*)
      ;; 	(formaT pane " "))
      ;; TODO: figure out how to control scroll position.
      )))

;; (defmethod display-chat ((frame matrixicl) pane)
;;   (with-end-of-page-action (pane :scroll)
;;     (loop for x from 1 to 100
;;        do (slim:with-table (pane)
;; 	    (slim:row (slim:cell (princ x))))
;; 	 (fresh-line))
;;     (format pane "heyo")))

;;; (setf frame-current-layout default *application-frame*)

