

(in-package :matrix-clim-client)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Presentation types   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-presentation-type access ())

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
    (access com-select-room matrixicl :gesture :select)
    (obj)
  (list obj))

(define-presentation-to-command-translator invoke-inspect-event
    (access com-select-event matrixicl :gesture :select)
    (obj)
  (list-obj))


