(display "working with continutations")

(define loop-with-break
  (lambda (l)
    (call/cc
     (lambda (cont-n)
       (let f ([l l])
	 (if (null? l)
	     (display "Finished")
	     ( f (cdr l))
	     )
	 )
       )
     )))


(loop-with-break (list 1 2 3 4))
