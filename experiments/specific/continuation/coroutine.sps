
(display "this is coroutine \n")

(define yield-to #f)
(define caller #f)


(define (coroutine )
  ( display "Coroutine A:  starting, saving own state and passing control to caller \n")
  (call/cc
   (lambda (cont)
     (set! yield-to cont)
     (caller)
     ))
  (display "Coroutine B: getting back the control, stage 2, doing somehthing and passing control back to caller for good\n")
  (call/cc
   (lambda (cont)
     (set! yield-to cont)
     (caller)
     )
   )
  )

(define (coroutine-user)
  (display "User: starting, calling coroutinte, saving the state before calling  Croutine \n")
  (call/cc
   (lambda (cont)
     (set! caller cont)
     (coroutine)))
  (display "Getting control from coroutine A back, again calling it\n")
  (call/cc
   (lambda (cont)
     (set! caller cont)
     (coroutine)))
  (display "Finising\n"))


(coroutine-user)
