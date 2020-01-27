;;;; matrix-clim-client.asd

(asdf:defsystem #:matrix-clim-client
  :description "Describe matrix-clim-client here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (#:mcclim
	       #:matrix-query
	       #:slim)
  :components ((:file "package")
               (:file "matrix-clim-client")
	       (:file "commands")
	       (:file "presentations")))
