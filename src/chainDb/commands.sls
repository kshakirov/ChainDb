
(library (chainDb commands)
  ;;  (export  test-cmd execute-get  execute-heavy-scan execute-very-heavy-scan)
  (export  run-cmd )
  (import
   (chezscheme)
   ;;(chainDb dispatcher)
   (chainDb storage)
   (chainDb parser)
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


  (define (create-get-key-closure-procedure param yield)
    (lambda()
      (get-key-closure param yield)
      ))

  (define (decode-cmd-fake msg)
    ( cons "get" "1"))

  (define( run-cmd msg yield)
    (if (= (bytevector-length msg) 0) #f
	(begin
	  (let* ((cmd (string->list (utf8->string msg)))
		 (parsed-cmd (decode-cmd cmd  '() '()))
		 (opcode (car parsed-cmd ))
		 (key (cdr parsed-cmd)) )
	    ((create-get-key-closure-procedure key yield))
	  ))))
  )


  
