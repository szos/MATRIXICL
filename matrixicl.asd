;;;; matrix-clim-client.asd

(asdf:defsystem #:matrixicl
  :description "Describe matrixicl here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (#:mcclim
	       #:matrix-query
	       #:slim
	       #:cl-fad)
  :components ((:file "package")
               (:file "matrixicl")
	       (:file "commands")
	       (:file "presentations")
	       (:file "file-selector")))
