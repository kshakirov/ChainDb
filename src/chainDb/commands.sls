
(library (chainDb commands)
  ;;  (export  test-cmd execute-get  execute-heavy-scan execute-very-heavy-scan)
  (export  run-cmd )
  (import
   (chezscheme)
   ;;(chainDb dispatcher)
   (chainDb commands storage)
   (chainDb commands parser)
   )

  (define (get-key-closure key yield)
    (lambda()
      (begin 
	(display (string-append "procedure get-kye " key " -> the parameter, before yielding ..\n"))
	(let ((found (get-k-value key) ))
	  (if  found (display (string-append "Found value " found))
	     (display (string-append "Not found by  " key)))
	  (yield (string-append "yielding : test_validate key -> ["  key " ]\n" ))
	  (display "After yield \n")
	  ))
      ))

  (define (put-key-value-closure key value)
    (lambda()
      (begin 
	(display (string-append "procedure put-key " key " -> value " value ))
	(put-k-value key value)
	(display "Done")
	  ))
      )


  (define (create-get-key-closure-procedure param yield)
    (lambda()
      (get-key-closure param yield)
      ))

    (define (create-put-key-value-closure-procedure key value)
    (lambda()
      (put-key-value-closure key value)
      ))

  (define (decode-cmd-fake msg)
    ( cons "get" "1"))

  (define( run-cmd msg yield)
    (if (= (bytevector-length msg) 0) #f
	(begin
	  (let* ((cmd (string->list (utf8->string msg)))
		 (parsed-cmd (decode-cmd cmd  '() '()))
		 (opcode (car parsed-cmd ))
		 (args (cdr parsed-cmd))
		 (key (list->string (car args))))
	    ;; (key (cdr parsed-cmd)) )
	    (if (string=? opcode "get")
		((create-get-key-closure-procedure key yield))
		((create-put-key-value-closure-procedure key  (list->string (cadr args))))
	  ))))
  ))
