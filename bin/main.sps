;;(library-directories (cons "../src" (library-directories)))


(import (chezscheme)
	(chainDb dispatcher)
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
    

;; 2. Стартуем наш Диспетчер
(run-dispatcher)
