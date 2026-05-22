(define (my-length lst)
  (call/cc
   (lambda (cont)
     (let loop ((remaining lst)
		(acc 0))
       (if (null? remaining)
           acc
           (begin
	     (display (car remaining))
	     (newline)
	     (if (= 0 (car remaining))
		 (cont "Exiting ..n")
		 (display "all is okay\n")
		 )
	     (loop (cdr remaining) (+ acc 1))
	     
	     )
	   ))
     )
   ))
;; Example usage:
(my-length '(1 2 3 4 0 5 6))
;; => 4
