

(define max
  (lambda (v)
    (let ([upto (- (vector-length v) 2)] )        
      (let get-max ([ i 0]  [max 0])
	(if (= i upto )
	    max
	    (get-max (+ i 1)
		     (if ( > max   (vector-ref v (+ i 1)))
			 max
			 (vector-ref v (+ i 1)))))))))
(max (vector 1 3 2))
				 
				   
