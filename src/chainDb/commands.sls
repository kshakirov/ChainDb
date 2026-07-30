
(library (chainDb commands)
  (export  test-cmd execute-get  execute-heavy-scan) 
  (import
   (rnrs)
   (chainDb dispatcher)
   )

  (define (test-cmd t) (display "testing module"))
  (define (execute-get key)
  (display (string-append "   [API EXECUTOR] Выполняю GET для ключа: '" key "'\n"))
  (display (string-append "   [API EXECUTOR] Значение найдено в памяти за O(1). Результат отправлен.\n")))

;; Имитация тяжелого запроса (KEYS * / SCAN), требующего квантования
(define (execute-heavy-scan)
  (display "   [API EXECUTOR] Стартую тяжелое сканирование индексов...\n")
  (display "   [API EXECUTOR] Просканировано первые 1000 ключей...\n")
  (async-yield "KEYS *") ; Первая пауза
  
  (display "   [API EXECUTOR] Курсор проснулся точно в той же точке. Сканирую следующие 1000 ключей...\n")
  (async-yield "KEYS *") ; Вторая пауза
  
  (display "   [API EXECUTOR] Финал сканирования. Индекс полностью обработан.\n"))


)
