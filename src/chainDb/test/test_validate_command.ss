(import
 (chezscheme)
 (chainDb commands parser)
 )



;;((run-cmd "test" test-yield))



(assert (string=? (car (decode-cmd (string->list "!get::1#") '() '())) "get"))
(cdr (decode-cmd (string->list "!put::1#") '() '()))
(assert(equal? (cdr (decode-cmd (string->list "!get::1#") '() '())) '((#\1))))
(assert(equal? (cdr (decode-cmd (string->list "!get::1::2#") '() '())) '((#\1) (#\2))))
(assert(equal? (cdr (decode-cmd (string->list "!get::1::25::63#") '() '())) '((#\1) (#\2 #\5) (#\6 #\3) )))

;; (assert (string=? (car (decode-cmd (string->list "!put::1::23#") '() '())) "put"))
(cdr (decode-cmd (string->list "!put::1::45#") '() '()))

;;(assert (string=?(cdr (decode-cmd (string->list "!put::1::45#") '() '())) "45"))


;; (define decode-arg
;;   (lambda (fragment arg opt)
;;     (if (null? fragment) (cons arg '())
;; 	(begin (let   [(ch (car fragment) ) (tail (cdr fragment)) ]
;; 		 (cond
;; 		  (( char=? ch #\:)( if (null? opt)(decode-arg tail arg opt) (decode-arg tail (cons opt arg) '())))
;; 		  ((char=? ch  #\#)  (cons  (reverse (cons opt arg)) tail))
;; 		  (else (decode-arg tail arg (cons ch opt)))))))))

;;(decode-arg (string->list ":1::3::5::6#A") '() '())
