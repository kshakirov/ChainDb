
(library (chainDb commands)
  ;;  (export  test-cmd execute-get  execute-heavy-scan execute-very-heavy-scan)
  (export  run-cmd )
  (import
   (rnrs)
   ;;(chainDb dispatcher)
   (chainDb storage)
   )

  (define (get-key-closure key yield)
    (lambda()
      (begin 
	(display (string-append "procedure get-kye " key " -> the parameter, before yielding ..\n"))
	(yield (string-append "yielding : test_validate key -> ["  key " ]\n" ))
	(display "After yield \n")
	)
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
	  (let [(opcode (car (decode-cmd-fake msg))) (key (cdr (decode-cmd-fake msg))) ] 
	    ((create-get-key-closure-procedure key yield))
	    ))))
  )


  
