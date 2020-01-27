
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
			    ("Resync" :command com-temp-resync)))

(make-command-table 'matrixicl-user-menu
		    :errorp nil
		    :menu '(("Login" :command com-login)
			    ("Logout" :command com-logout)))

(define-matrixicl-command (com-quit :name t) ()
  (frame-exit *application-frame*))

(define-matrixicl-command (com-exit :name t) ()
  (frame-exit *application-frame*))

(define-matrixicl-command (com-temp-update-room :name t) ()
  (matrix-query::update-sync)
  (matrix-query::setup-rooms-from-state))

(define-matrixicl-command (com-temp-resync :name t) ()
  (matrix-query::initial-sync)
  (matrix-query::setup-rooms-from-state))

(define-matrixicl-command (com-login :name t)
    ((Username 'string :prompt "Username") (Password 'string :prompt "Password"))
  (if (current-user *application-frame*)
      (print "there is already a user logged in")
      (progn (setf (current-user *application-frame*)
		   (matrix-query::login username password))
	     (matrix-query::initial-sync)
	     (matrix-query::setup-rooms-from-state))))

(define-matrixicl-command (com-logout :name t) ()
  (matrix-query::logout)
  "logged out")
