
(library (chainDb commands)
;;  (export  test-cmd execute-get  execute-heavy-scan execute-very-heavy-scan)
  (export  test-cmd execute-get  validate-cmd )
  (import
   (rnrs)
   ;;(chainDb dispatcher)
   (chainDb storage)
   )

  (define (validate-cmd candidate)
    (begin
     ;;(display "Validating cmd")
     ;;(display candidate)
     (if (= (bytevector-length candidate) 0)
	 #f
	 test-cmd)
    ))
  (define (test-cmd async-yield) (
			begin
			 (display "test-cmd: Before yielding the control\n")
			 (async-yield "test-cmd")
			 (display "test-cmd: After  yielding the control\n")
			 )
    )
  (define (execute-get key)
    (display (string-append "   [API EXECUTOR] Выполняю GET для ключа: '" key "'\n"))
    (display (string-append "   [API EXECUTOR] Значение найдено в памяти за O(1). Результат отправлен.\n")))

  ;; Имитация тяжелого запроса (KEYS * / SCAN), требующего квантования
  ;; (define (execute-heavy-scan)
  ;;   (display "   [API EXECUTOR] Стартую тяжелое сканирование индексов...\n")
  ;;   (display "   [API EXECUTOR] Просканировано первые 1000 ключей...\n")
  ;;   (async-yield "KEYS *") ; Первая пауза
    
  ;;   (display "   [API EXECUTOR] Курсор проснулся точно в той же точке. Сканирую следующие 1000 ключей...\n")
  ;;   (async-yield "KEYS *") ; Вторая пауза
    
  ;;   (display "   [API EXECUTOR] Финал сканирования. Индекс полностью обработан.\n"))


  ;; (define (execute-very-heavy-scan)
  ;; ;;  (lambda ()
  ;;     (display "   [API EXECUTOR] Стартую тяжелое сканирование индексов...\n")
  ;;     (let loop ((i 0))
  ;; 	(when ( < i 1000000)
  ;; 	  (when (= (mod i 5000) 0)
  ;; 	    (display "   [API EXECUTOR] Просканировано первые 50000 ключей...\n")
  ;; 	    (async-yield "KEYS *") ; Первая пауза
  ;; 	    (display "   [API EXECUTOR] Курсор проснулся точно в той же точке. Сканирую следующие 1000 ключей...\n")

  ;; 	    (display i )
  ;; 	    (display "\n")

  ;; 	    )
  ;; 	  (loop (+ i 1))))
  ;;     (display "   [API EXECUTOR] Финал сканирования. Индекс полностью обработан.\n")
  ;;     )
;;    )

  )
