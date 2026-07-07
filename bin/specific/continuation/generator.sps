(display "trying to reproduce generator")



(set! generator-user-cc #f)
(set! generator-cc #f)

(define my-loop
  (lambda (n)
    (let loop [(i n)]
      (call/cc
       (lambda (yield-to-user)
	 (if (= 0 i) i
	     ( begin
	       (display "%\n")
	       ( loop (- i 1)
		 ))))))))


(define generator-user
  (lambda ()
    (begin
      (display "\nuser started\n")
      (my-loop 5)
      )))

;;(my-loop 10)

(generator-user)
