(import
 (chezscheme)
 (chainDb commands)
 (chainDb commands parser)
 )




(assert (equal? (car (decode-cmd (bytevector->u8-list(string->bytevector "!get::1#"(native-transcoder))) '() '())) 'get))
(assert (equal? (cdr (decode-cmd (bytevector->u8-list(string->bytevector "!get::1#"(native-transcoder))) '() '())) '((49))))

(assert (equal? (cdr (decode-cmd (bytevector->u8-list(string->bytevector "!get::25::63#"(native-transcoder))) '() '())) '((50 53) (54 51))))

;;;;;;;;;;;;;;;;;;;;;; commands ;;;;;;;;;;;;;;;;;;;;;;


(let* [(put-payload (string->bytevector "!put::a::2#" (native-transcoder)))
       (get-payload (string->bytevector "!get::a#" (native-transcoder)))
       (yield-lambda (lambda (x) (format #t"~n Result is ~a ~n" x)))
       (get-cmd (run-cmd get-payload yield-lambda))
       (put-cmd (run-cmd put-payload #t))]
  (begin
    (put-cmd)
 (assert (equal? (get-cmd) #vu8(50)))
    ))





