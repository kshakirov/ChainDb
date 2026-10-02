
(define make-generator
  (lambda(body)
    (letrec* ([sum (lambda (x)
		     (if (zero? x)
			 0
			 (+ x (sum (- x 1)))))]
	      [f (lambda () (cons n n-sum))]
	      [ resume-cont #f]
	      [ yield (lambda (arg)
			(call/cc
			 (lambda (cont)
			   (set! resume-cont cont)  ; Запомнили точку внутри генератора
			   (return-cont arg))))]
	      [ next  (lambda ()
			(display "\n herea iam\n")
			(call/cc
			 (lambda (cont)
			   (set! return-cont cont)  ; Запомнили точку ожидания пользователя
			   (cond
			    ((eq? resume-cont 'dead) #f)
			    ((eq? #f resume-cont) ; Ваша строгая проверка первого старта
			    (begin  ;; здесь мы вывалимся при пустышке
			      (body yield)
			      (display "you've called next on cold start\n")
			      (set! resume-cont  'dead)
			      ) )
			    (else   (begin 
				      (resume-cont #t)
				      (display "you've called next on hot start \n")
				      (set! resume-cont  'dead)
				      )));; здесь вывалимся при горячем плохом старте
			    )))]


	      [n 15]
	      [n-sum (sum n)])
      next)))

(define generator-body
  (lambda (yield)
    (let [(arg 100)] (yield arg))
    ;; (let [(arg 200)] (yield arg))
    ;; (let [(arg 300)] (yield arg)))
    (display yield)
    (display "body")
    ))

(let [(next (make-generator generator-body))]
  (display next)
  (display "\nnow\n")
  (next)
   (next)
  ;;  (next)
  )
