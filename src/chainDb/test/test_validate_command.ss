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
    ))
((get-key-closure "direct call" test-yield ))

(let [(procedure (create-get-key-closure-procedure "call via closure" test-yield))]
  ((procedure))
  )

(define (decode-cmd-fake msg)
  ( cons "get" "1"))

(define( run-cmd msg yield)
   (let [(opcode (car (decode-cmd-fake msg))) (key (cdr (decode-cmd-fake msg))) ] 
   (create-get-key-closure-procedure key yield)
   ))
 
(define cmd "get::1::#")
;; (define (decode-cmd msg)
;;   (let [(chars (string->list msg) (op "") (key "")]
;; 	( let loop [(letter (car chars) (rest (cdr chars))] )
;; 	  (cond ( 
;;   ))
 
(((run-cmd "test" test-yield)))
