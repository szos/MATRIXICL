

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
		    :menu '(("New" :command com-new-room)))

(make-command-table 'matrixicl-user-menu
		    :errorp nil
		    :menu '(("Login" :command com-login)
			    ("Logout" :command com-logout)))

(define-matrixicl-command (com-quit :name t) ()
  (frame-exit *application-frame*))

(define-matrixicl-command (com-exit :name t) ()
  (frame-exit *application-frame*))

