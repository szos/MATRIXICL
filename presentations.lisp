

(in-package :matrix-clim-client)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Presentation types   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-presentation-type access-event ())
(define-presentation-type access-room ())
(define-presentation-type room-return-presentation ())
(define-presentation-type update-with-prior-events ())
(define-presentation-type update-with-many-prior-events ())

;;;;;;;;;;;;;;;;;;;;
;;;   Gestures   ;;;
;;;;;;;;;;;;;;;;;;;;

(define-gesture-name :prev    :keyboard (#\p :meta))
(define-gesture-name :next    :keyboard (#\n :meta))
;; (define-gesture-name :next-room :keyboard (#\))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Command translators   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-presentation-to-command-translator invoke-select-room
    (access-room com-select-room matrixicl :gesture :select)
    (obj)
  (list obj))

(define-presentation-to-command-translator invoke-inspect-event
    (access-event com-select-event matrixicl :gesture :select)
    (obj)
  (list obj))

(define-presentation-to-command-translator invoke-room-return
    (room-return-presentation com-return-to-room matrixicl :gesture :select)
    (obj)
  (list obj))

(define-presentation-to-command-translator update-events-prior
    (update-with-prior-events com-get-prior-events matrixicl :gesture :select)
    (obj)
  (list obj))

(define-presentation-to-command-translator update-many-events-prior
    (update-with-many-prior-events com-get-many-prior-events matrixicl :gesture :select)
    (obj)
  (list obj))
