(import
 (chezscheme)
 (chainDb commands)
 (chainDb commands parser)
 )




(assert (string=? (car (decode-cmd (string->list "!get::1#") '() '())) "get"))
(assert(equal? (cdr (decode-cmd (string->list "!get::1#") '() '())) '((#\1))))
(assert(equal? (cdr (decode-cmd (string->list "!get::1::2#") '() '())) '((#\1) (#\2))))
(assert(equal? (cdr (decode-cmd (string->list "!get::1::25::63#") '() '())) '((#\1) (#\2 #\5) (#\6 #\3) )))

;;;;;;;;;;;;;;;;;;;;;; commands ;;;;;;;;;;;;;;;;;;;;;;


(let* [(put-payload (string->bytevector "!put::a::2#" (native-transcoder)))
       (get-payload (string->bytevector "!get::a#" (native-transcoder)))
       (yield-lambda (lambda (x) (format #t"~n Result is ~a ~n" x)))
       (get-cmd (run-cmd get-payload yield-lambda))
       (put-cmd (run-cmd put-payload #t))]
  (begin
    (put-cmd)
    (assert (equal? (get-cmd) "2"))
    ))
  


