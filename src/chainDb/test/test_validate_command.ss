(import
 (chezscheme)
 )

(define (test-yield str)
  (display str))

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
    )
)
;;((get-key-closure "direct call" test-yield ))

(let [(procedure (create-get-key-closure-procedure "call via closure" test-yield))]
  (procedure)
  )

(define (decode-cmd-fake msg)
  ( cons "get" "1"))

(define( run-cmd msg yield)
   (let [(opcode (car (decode-cmd-fake msg))) (key (cdr (decode-cmd-fake msg))) ] 
   ((create-get-key-closure-procedure key yield))
   ))


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
 
;;((run-cmd "test" test-yield))


(car  (decode-op (string->list "!get::1#") '()))
(cdr  (decode-op (string->list "!get::1#") '()))
 ;;(decode-arg (string->list ":123#") '())
(decode-arg (cdr  (decode-op (string->list "!get::1#") '())) '())

(car (decode-cmd (string->list "!get::1#") '() '()))
(cdr (decode-cmd (string->list "!get::1#") '() '()))
