
(library (chainDb commands)
  ;;  (export  test-cmd execute-get  execute-heavy-scan execute-very-heavy-scan)
  (export  execute-get   run-cmd )
  (import
   (rnrs)
   ;;(chainDb dispatcher)
   (chainDb storage)
   )

  (define (get-key-closure key yield)
    (lambda()
      (begin 
	(display (string-append "procedure get-kye " key " -> the parameter, before yielding ..\n"))
	(yield (string-append "yielding : test_validate key -> ["  key " ]\n" ))
	(display "After yield \n")
	)
      ))


  (define (create-get-key-closure-procedure param yield)
    (lambda()
      (get-key-closure param yield)
      ))

  (define (decode-cmd-fake msg)
    ( cons "get" "1")) 

  (define( run-cmd msg yield)
    (if (= (bytevector-length msg) 0) #f
	(begin
    (let [(opcode (car (decode-cmd-fake msg))) (key (cdr (decode-cmd-fake msg))) ] 
      (create-get-key-closure-procedure key yield)
      ))))


  
  (define (get-key key)
    (lambda(async-yield)
      (begin 
	(display (string-append "procedure get-kye " key " -> the parameter\n"))
	(display "test-cmd: Before yielding the control\n")
	(async-yield "test-cmd")
	(display "test-cmd: After  yielding the control\n")
	(display (string-append "anothoer string " async-yield " async-call\n"))
	)
      ))


  (define (create-get-key-procedure param)
    (lambda()
      (get-key param)
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
