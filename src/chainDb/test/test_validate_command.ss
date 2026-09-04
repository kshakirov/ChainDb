(import (chezscheme))

(define (get-key key)
  (lambda(async-yield)
  (begin 
    (display (string-append "procedure get-kye " key " -> the parameter\n"))
    (display (string-append "anothoer string " async-yield " async-call\n"))
  )
  ))


(define (create-get-key-procedure param)
  (lambda()
    (get-key param)
    ))
((get-key "direct call") " first ")

(let [(procedure (create-get-key-procedure "call via closure"))]
  ((procedure) "second")
  )
