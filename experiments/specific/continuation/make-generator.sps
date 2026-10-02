(define make-generator
  (lambda (body)

    (letrec* [ ( resume-cont #f) (return-cont #f)] ; Тут засыпает пользователь

       [ (yield (lambda (arg)
			  (call/cc
			   (lambda (cont)
			     (set! resume-cont cont)  ; Запомнили точку внутри генератора
			     (return-cont arg)))))]
	

	;; Тело генератора — линейная последовательность шагов

	[( nn  (lambda ()
			(call/cc
			 (lambda (cont)
			   (set! return-cont cont)  ; Запомнили точку ожидания пользователя
			   
			   (if (eq? #f resume-cont) ; Ваша строгая проверка первого старта
			       (body yield)     ; Стартуем мотор с нуля
			       (resume-cont #t))))))])


	
	(displaty "next")
      (+ 3 7)
      ))

;; Пользователь генератора — поочерёдно дёргает за ниточки
;; (define generator-user
;;   (lambda ()
;;     (let [(result1 (next))]
;;       (display "User got: ") (display result1) (newline))
;;     (let [(result2 (next))]
;;       (display "User got: ") (display result2) (newline))
;;     (let [(result3 (next))]
;;       (display "User got: ") (display result3) (newline))))

(define generator-body
  (lambda (yield)
    (let [(arg 100)] (yield arg))
    (let [(arg 200)] (yield arg))
    (let [(arg 300)] (yield arg))))

;; (define use-generator
;;   (lambda ()
;;     (let [(next (make-generator generator-body) )]
;;       (display next))))

;;(use-generator)
(display (make-generator generator-body))
