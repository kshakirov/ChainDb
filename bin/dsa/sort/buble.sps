

;; (DEFINE FOR-LOOP
;;   (LAMBDA (N)
;;     (LET NAMED-LET ([ I N  ])
;;       (IF (= I 0)
;; 	  0
;; 	  (+ I  (NAMED-LET (- I 1)))))))
;; (FOR-LOOP 10)


;; (DEFINE FOR-LOOP-ITER
;;   (LAMBDA (N)
;;     (LET NAMED-LET ([I N] [R 0])
;;       (IF (= I 0)
;; 	  R
;; 	  (NAMED-LET (- I 1) (+ R I))))))

;; (FOR-LOOP-ITER 11)

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
				 
				   
