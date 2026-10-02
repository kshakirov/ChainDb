
(library (chainDb commands)
  ;;  (export  test-cmd execute-get  execute-heavy-scan execute-very-heavy-scan)
  (export  run-cmd )
  (import
   (chezscheme)
   (chainDb commands storage)
   (chainDb commands parser)
   )

  (define (get-key-closure key yield)
    (lambda()
      (begin 
	(display (string-append "procedure get-kye "  " -> the parameter, before yielding ..\n"))
	(let ((found (get-k-value key) ))
	  (if  found (display (string-append "Found value " "\n"))
	     (display (string-append "Not found by" "\n")))
	  (yield (string-append "yielding : \n" "\n" ))
	  (display "After yield \n")
	  found))
      ))

  (define (put-key-value-closure key value)
    (lambda()
      (begin 
;;	(display (string-append "procedure put-key " key " -> value " value ))
	(put-k-value key value)
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

  (define( run-cmd msg yield)
    (if (= (bytevector-length msg) 0) #f
	(begin
	  (let* ((cmd ( bytevector->u8-list msg))
		 (parsed-cmd (decode-cmd cmd  '() '()))
		 (opcode (car parsed-cmd ))
		 (args (cdr parsed-cmd))
		 (key (u8-list->bytevector (car args))))
	    (case opcode 
		((get) ((create-get-key-closure-procedure key yield)))
		((put)((create-put-key-value-closure-procedure key  (u8-list->bytevector (cadr args)))))
	  ))))
  ))
