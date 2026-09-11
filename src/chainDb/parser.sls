(library (chainDb parser)
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
		    (( char=? ch #\!) (decode-op tail op))
		    ((char=? ch  #\:)   (cons (list->string (reverse op)) tail ))
		    (else (decode-op tail (cons ch op)))))))))

  (define decode-arg
    (lambda (fragment arg)
      (if (null? fragment) (cons arg '())
	  (begin (let   [(ch (car fragment) ) (tail (cdr fragment)) ]
		   (cond
		    (( char=? ch #\:) (decode-arg tail arg))
		    ((char=? ch  #\#)  (cons  (list->string (reverse arg)) tail))
		    (else (decode-arg tail (cons ch arg)))))))))


  (define cmd "!!get::1#")

  (define decode-cmd
    (lambda (msg op args)
      (if (null? msg) (cons op args)
	  (begin
	    (let [(ch (car msg)) (tail (cdr msg)) ]
	      (cond
	       ((char=? ch #\!)(begin
				 (let [(tuple  (decode-op tail '()))]
				   (decode-cmd (cdr tuple) (car tuple) args)
				   )))
	       ((char=? ch #\:)(begin
				 (let [(tuple  (decode-arg tail '()))]
				   (decode-cmd (cdr tuple) op (car tuple))
				   ))))
	      )))))

  )
