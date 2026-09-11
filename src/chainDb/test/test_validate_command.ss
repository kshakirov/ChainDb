(import
 (chezscheme)
 (chainDb parser)
 )


 
;;((run-cmd "test" test-yield))



(car (decode-cmd (string->list "!get::1#") '() '()))
(cdr (decode-cmd (string->list "!get::1#") '() '()))
