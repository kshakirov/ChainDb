(import (chezscheme)
	(chainDb arena))


(define resume #f)
(define yield #f)
(define loop-yield
  (lambda ()
    (let loop [(i 0)]
    (call/cc
     (lambda(cont)

	 (display (string-append (number->string i) "\n") )
	 (set! resume cont)
	 (yield i)))
  
	  (display "HERE \n")
	  
          
	  (if (> i 10)
	      i
	      (loop (+ i 1))
	      ))))

(let [ (ret  (call/cc(lambda(c) (set! yield c) )))]
  (if (eq? #f resume)

(let [ (i    (loop-yield))]
  (display (string-append "got from cont "  "\n") )
  ;;(resume)
  )
(begin
  (display (string-append "resuming: got " (number->string ret) "\n"))
  (resume )
       )))
