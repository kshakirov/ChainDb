(import
 (chezscheme)
 (chainDb parser)
 )


 
;;((run-cmd "test" test-yield))



(assert (string=? (car (decode-cmd (string->list "!get::1#") '() '())) "get"))

(assert (string=?(cdr (decode-cmd (string->list "!get::1#") '() '())) "1"))
