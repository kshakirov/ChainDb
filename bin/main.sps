;;(library-directories (cons "../src" (library-directories)))


(import (chezscheme)
	(chainDb dispatcher)
	(chainDb pipe)
	(chainDb commands))




;; Главная точка входа для входящих запросов
(define (dispatch-query query-type query-data)
  (display (string-append "\n[FRONTEND] Принят новый сетевой запрос. Тип: [" query-type "], Данные: <" query-data ">\n"))
  
  (cond
   ((string=? query-type "GET")
    (display "[FRONTEND] Создаю легкую задачу для GET и ставлю в очередь.\n")
    (spawn (lambda () (execute-get query-data))))
   
   ((string=? query-type "KEYS")
    (display "[FRONTEND] Создаю тяжелую задачу для SCAN и ставлю в очередь.\n")
    (spawn (lambda () (execute-very-heavy-scan))))
   
   (else
    (display "[FRONTEND] Ошибка: Неизвестная команда!\n"))))

;; ===================================================================
;; ЗАПУСК СИМУЛЯЦИИ (Эмуляция жизни базы ChainDB)
;; ===================================================================

(display "===================================================================\n")
(display "                ЗАПУСК ЭМУЛЯТОРА ЯДРА ChainDB                     \n")
(display "===================================================================\n")

;; 1. Симулируем приход запросов от клиентов (забиваем очередь)
;;(dispatch-query "KEYS" "*")        ; Первым прилетает страшный тяжелый запрос сканирования
;;(dispatch-query "GET" "user:100")  ; Следом за ним летит быстрый GET
;;(dispatch-query "GET" "user:200")  ; И еще один быстрый GET

(display "\n[BOOT] Очередь запросов сформирована. Запускаю Event Loop ядра...\n")


(call-with-input-file "bin/instructions.txt"
  (lambda (port)
    (let loop []
    (let  ([line (get-line port)])
      (if (eof-object? line)
          (display "End of file reached.\n")
          (begin
	    (printf "Read line: ~a\n" line)
	    (dispatch-query "GET" line)
	    (loop)

	    ))))))

;; 1. Подключаем системное пространство macOS
;; 1. Подключаем системное пространство macOS
(load-shared-object #f)

;; 2. Объявляем select с правильным типом u8* для маски

;; 1. Объявляем select, где второй и пятый аргументы — это массивы байт (u8*)
(define c-select 
  (foreign-procedure "select" (int u8* void* void* u8*) int))

;; 2. Создаём маску для клавиатуры (8 байт)
(define read-mask (make-bytevector 8 0))
(bytevector-u8-set! read-mask 0 1)

;; 3. Создаём структуру тайм-аута (16 байт, все нули = 0 наносекунд ожидания)
(define timeout (make-bytevector 16 0))

;; 4. МГНОВЕННЫЙ ВЫЗОВ: передаём маску и тайм-аут
(define select-result (c-select 1 read-mask 0 0 timeout))




(display select-result)
;;(run-stupid)

(run-dispatcher)
