(display "trying to reproduce generator")


(define my-loop
  (lambda (n)
    (let loop [(i n)]
      (if (= 0 i) i
	  ( begin(display "%\n") ( loop (- i 1)
	    ))))))
	  

(my-loop 10)
