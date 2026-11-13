(import (chezscheme)
	(chainDb arena))


(define resume-cont #f)
(define loop-yield
  (lambda ()
    (let loop [(i 0)]
    (call/cc
     (lambda(cont)

	 (display (string-append (number->string i) "\n") )
	 (set! resume-cont cont)
	 (cont i)))
  
	  (display "HERE ")
	  
          
	  (if (= i 10) 
	      (loop i)
	      ))))


(let [ (i    (loop-yield))]
  (display (string-append "got from cont "  "\n") )
  (resume-cont))  
