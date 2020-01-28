
(in-package :matrix-clim-client)

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

(define-matrixicl-command (com-temp-update-room :name t) ()
  (matrix-query::update-sync-threaded)
  (matrix-query::setup-rooms-from-state))

(define-matrixicl-command (com-temp-resync :name t) ()
  (matrix-query::initial-sync-threaded)
  ;; (matrix-query::setup-rooms-from-state)
  )

(define-matrixicl-command (com-get-prior-events :name t)
    ((room matrix-query::matrix-room :prompt "enter a room id"))
  
  (matrix-query::get-prior-events room))

(define-matrixicl-command (com-get-many-prior-events :name t)
    ((room matrix-query::matrix-room :prompt "enter a room id"))
  (matrix-query::get-prior-events room 30))

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
