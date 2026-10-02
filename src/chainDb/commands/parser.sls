(library (chainDb commands parser)
  ;;  (export  test-cmd execute-get  execute-heavy-scan execute-very-heavy-scan)
  (export  decode-cmd )
   (import
   (chezscheme)
   )
  (define decode-op
    (lambda (fragment op)
      (if (null? fragment) (cons op '())
	  (begin (let   [(ch (car fragment) ) (tail (cdr fragment)) ]
		   (cond
		    (( = ch 33) (decode-op tail op))
;;		    ((= ch  58)   (cons (list->string (reverse op)) tail ))
		    ((= ch 58)
		     (cons (string->symbol
			    (utf8->string (u8-list->bytevector (reverse op))))
			   tail))
		    (else (decode-op tail (cons ch op)))))))))


  (define decode-arg
  (lambda (fragment arg opt)
    (if (null? fragment) (cons arg '())
	(begin (let   [(ch (car fragment) ) (tail (cdr fragment)) ]
		 (cond
		  (( = ch 58)
		   ( if (null? opt)
				     (decode-arg tail arg opt)
				     (decode-arg tail (cons (reverse opt) arg) '()))
		   )
		  ((= ch  35)  (cons  (reverse (cons (reverse opt) arg)) tail))
		  (else (decode-arg tail arg (cons ch opt)))))))))
  
  (define decode-cmd
    (lambda (msg op args)
      (if (null? msg) (cons op args)
	  (begin
	    (let [(ch (car msg)) (tail (cdr msg)) ]
	      (cond
	       ((= ch 33)(begin
				 (let [(tuple  (decode-op tail '() ))]
				   (decode-cmd (cdr tuple) (car tuple) args)
				   )))
	       ((= ch 58)(begin
				 (let [(tuple  (decode-arg tail '() '()))]
				   (decode-cmd (cdr tuple) op (car tuple))
				   ))))
	      )))))

  )
