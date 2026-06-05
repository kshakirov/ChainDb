
(define my-k #f) ; Переменная для сохранения продолжения
(define r1 #f)

(display "Шаг 1: До вызова call/cc\n")
(let ((result (call/cc (lambda (k)
                         (set! my-k k) ; Сохраняем продолжение в глобальную переменную
                         "Шаг 2: Внутри call/cc, мы пошли дальше"))))
  (string-append "Результат: " result "\n"))

(if my-k
    (my-k "here I am"))


;; this has been just a test how I can start from the continuation


;; now the cycle

(define get-continuation-with-values
  (lambda (values)
    (call/cc
     (lambda (continuation)
       (cons continuation values)))))

(define loop-with-continuation-and-values
  (lambda (num)
    (let ((continuation-with-values (get-continuation-with-values num)))
      (let ((continuation (car continuation-with-values))
	    (current-values (cdr continuation-with-values)))
	(write current-values)
	(if (<  current-values 100) 
	    (continuation (cons continuation (+ 1 current-values)))
	    (write "Done")
	    )))))

(loop-with-continuation-and-values 0)
	

