
(in-package :matrixicl)

(make-command-table 'matrixicl-menubar
		    :errorp nil
		    :menu '(("App" :menu matrixicl-application-menu)
			    ("User" :menu matrixicl-user-menu)
			    ("Rooms" :menu matrixicl-room-menu)))

(make-command-table 'matrixicl-application-menu
		    :errorp nil
		    :menu '(("Manual Redisplay" :command com-manual-redisplay)
			    ("Select File" :command com-select-file)
			    ("Quit" :command com-quit)))

(make-command-table 'matrixicl-room-menu
		    :errorp nil
		    :menu '(("New" :command com-new-room)
			    ("Update-rooms-from-state" :command com-temp-update-room)
			    ("Resync" :command com-temp-resync)
			    ;; ("Get prior events" :command com-get-prior-events)
			    ))

(make-command-table 'matrixicl-user-menu
		    :errorp nil
		    :menu '(("Login" :command com-login)
			    ("Logout" :command com-logout)))

(define-matrixicl-command (com-quit :name t) ()
  (frame-exit *application-frame*))

(define-matrixicl-command (com-exit :name t) ()
  (frame-exit *application-frame*))

(defun restart-app ()
  (frame-exit *application-frame*)
  (sleep 1)
  (app-main))

(define-matrixicl-command (com-restart :name t) ()
  (restart-app))

(define-matrixicl-command (com-manual-redisplay :name t) ()
  (redisplay-frame-panes *application-frame*))

(define-matrixicl-command (com-temp-update-room :name t) ()
  (matrix-query::update-sync-threaded)
  (matrix-query::setup-rooms-from-state))

(define-matrixicl-command (com-temp-resync :name t) ()
  (matrix-query::initial-sync-threaded)
  ;; (matrix-query::setup-rooms-from-state)
  )

(define-matrixicl-command (com-testing-resync :name t)
    ()
  (matrix-query::threaded-interface
   (matrix-query::initial-sync)))

(define-matrixicl-command (com-get-prior-events :name t)
    ((room matrix-query::matrix-room :prompt "enter a room id"))
  (setf (scroll-to-bottom *application-frame*) nil)
  (matrix-query::get-prior-events room))

(define-matrixicl-command (com-get-many-prior-events :name t)
    ((room matrix-query::matrix-room :prompt "enter a room id"))
  (setf (scroll-to-bottom *application-frame*) nil)
  (matrix-query::get-prior-events room 30))

(define-matrixicl-command (com-select-file :name t)
    ()
  (matrixicl.file-selector::app-main))

(define-matrixicl-command (com-send-text-message :name "Testing Send Text Message")
    ((message string :prompt "Compose Message"))
  (matrix-query::test/send-text-message (current-room *application-frame*)
					message))

(define-condition no-current-room-error (error)
  ())

(define-matrixicl-command (com-send-file :name "testing send file")
    ()
  (unless (equal (type-of (current-room *application-frame*))
		 'matrix-query::matrix-room)
    (error 'no-current-room-error))
  (unless (selected-file *application-frame*)
    (com-select-file))
  (matrix-query::test/send-file
   (matrix-query::room-id ;; (current-room *application-frame*)
			  )
   (selected-file *application-frame*)))

;; (define-matrixicl-command (com-set-theme :name "Set Theme")
;; this doesnt work - it requrires an application restart
;;     ((theme keyword :prompt "Theme: "))
;;   (set-theme theme))

(defparameter *clim-command-thread-lock* (bt:make-lock))

(defun threaded-login (un pw)
  (if (current-user *application-frame*)
      (print "there is already a user logged in")
      (progn
	(setf (current-user *application-frame*) t)
	(bt:make-thread
	 (lambda ()
	   (bt:with-lock-held (*clim-command-thread-lock*)
	     (setf (current-user *application-frame*)
		   (matrix-query::login un pw)))))
	:name "login thread")))

(defun threaded-initial-sync ()
  (bt:make-thread
   (lambda ()
     (bt:with-lock-held (*clim-command-thread-lock*)
       (matrix-query::initial-sync)))
   :name "initial sync thread"))

(defun login-initial-sync-threaded (un pw)
  (if (current-user *application-frame*)
      (print "there is already a user logged in")
      (progn
	(setf (current-user *application-frame*) t)
	(let ((app-frame *application-frame*))
	  (bt:make-thread
	   (lambda ()
	     (bt:with-lock-held (*clim-command-thread-lock*)
	       (let ((cuser (matrix-query::login un pw)))
		 (print cuser)
		 (setf (current-user app-frame) cuser)
		 (print "set current user")
		 (matrix-query::initial-sync)
		 (redisplay-frame-panes app-frame)))))))))

(define-matrixicl-command (com-login :name t)
    ((username 'string :prompt "Username") (password 'string :prompt "Password"))
  (login-initial-sync-threaded username password)
  ;; (threaded-login username password)
  ;; (if (current-user *application-frame*)
  ;;     (print "there is already a user logged in")
  ;;     (progn (setf (current-user *application-frame*)
  ;; 		   (matrix-query::login username password))
  ;; 	     (matrix-query::initial-sync-threaded)
  ;; 	     (redisplay-frame-panes *application-frame*)))
  )

(define-matrixicl-command (com-logout :name t) ()
  (bt:make-thread
   (lambda ()
     (bt:with-lock-held (*clim-command-thread-lock*)
       (matrix-query::logout)))))

(define-matrixicl-command (com-select-event  :name t)
    ((event matrix-query::text-message-event))
  ;;(setf *temp-display-chat-text* event)
  (setf (main-display *application-frame*) event))

(define-matrixicl-command (com-select-room :name t)
    ((room matrix-query::matrix-room :prompt "enter a string"))
  ;; (setf *temp-display-chat-text* room)
  (setf (main-display *application-frame*) room)
  (setf (current-room *application-frame*) room))

(define-matrixicl-command (com-return-to-room :name t)
    ((filler 'matrix-query::matrix-room))
  (setf *temp-event-info* filler)
  (setf *temp-display-chat-text*
	(current-room *application-frame*))
  (setf (main-display *application-frame*)
	(current-room *application-frame*)))

;;;;;;;;;;;;;;;;;;;;;
;;; SEND MESSAGES ;;;
;;;;;;;;;;;;;;;;;;;;;

(define-matrixicl-command (com-send-text-message :name t)
    ((message string :prompt "Enter your message: "))
  (matrix-query::test/send-text-message
   (current-room *application-frame*)
   message))
