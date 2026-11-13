(import (chezscheme)
	(chainDb arena))



(define (gen-loop-yield)
  (define return #f)
  (define resume #f)

  (define (yield x)
    (display "YIELD-IN\n")
    (call/cc (lambda (k) (set! resume k) (return x))))

    (lambda ()
      (call/cc
       (lambda (cont)
	 (display "TOP\n")
	 (set! return cont)
	 (if resume
	     (resume)
	 (let loop ((i 0))
           (display (string-append "i =" (number->string i) "\n"))
           (yield i)
           (display "AFTER-YIELD\n")
           (if (> i 10) i (loop (+ i 1)))))))))


(define gen (gen-loop-yield))
(display (gen))
(display (gen))
;;(resume #f)

;; (define generator
;;   (lambda()
;;     (let [ (ret  (call/cc(lambda(c) (set! yield c) )))]
;;       (if (eq? #f resume)

;; 	  (let [ (i    (loop-yield))]
;; 	    (display (string-append "got from cont "  "\n") )
;; 	    ;;(resume)
;; 	    )
;; 	  (begin
;; 	    (display (string-append "resuming: got " (if (number? ret) (number->string ret) "-1") "\n"))
;; 	    (display "stop\n" )
;; 	    )))
;;     ))
;; (generator)


;; --- генератор ---
;; (define (make-gen)
;;   (define return #f)
;;   (define resume #f)
;;   (define (yield x)
;;     (call/cc (lambda (k) (set! resume k) (return x))))
;;   (lambda ()
;;     (call/cc (lambda (k)
;;       (set! return k)
;;       (if resume
;;           (resume #f)
;;           (begin
;;             (yield 1)
;;             (yield 2)
;;             (yield 3)
;;             (return 'done)))))))

;; ;; --- вызывающий ---
;; (define g (make-gen))
;; (display (g)) (newline)   ; 1
;; (display (g)) (newline)   ; 2
;; (display (g)) (newline)   ; 3
;; (display (g)) (newline)   ; done
