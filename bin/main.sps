;;(library-directories (cons "../src" (library-directories)))


(import (rnrs)
       (chainDb commands))



;; ===================================================================
;; ChainDB Core Engine Skeleton (Emulator File)
;; ===================================================================
(test-cmd "dd\n")
;; Глобальное состояние ядра (пока максимально простое)
(define *ready-queue* '())              ; Очередь готовых задач
(define *dispatcher-continuation* #f)    ; Точка аварийного возврата в диспетчер

;; -------------------------------------------------------------------
;; СЛОЙ 1: ДИСПЕТЧЕР (Event Loop) И ПЛАНИРОВАНИЕ
;; -------------------------------------------------------------------

;; Добавление задачи в хвост очереди
(define (spawn task-thunk)
  (set! *ready-queue* (append *ready-queue* (list task-thunk))))

;; Аварийный выход из текущей задачи обратно в цикл диспетчера
(define (dispatcher-abort)
  (*dispatcher-continuation* #t))

;; Кооперативная уступка дороги (Квантование времени)
(define (async-yield task-name)
  (call/cc
   (lambda (k-task)
     (display (string-append "   [YIELD] Задача <" task-name "> уступает дорогу. Сохраняем стек и уходим в хвост...\n"))
     ;; Упаковываем снимок стека в лямбду и кладем в конец очереди
     (spawn (lambda () (k-task #t)))
     ;; Выпрыгиваем в диспетчер
     (dispatcher-abort))))

;; Главный цикл обработки очереди
(define (run-dispatcher)
  (if (null? *ready-queue*)
      (begin
        (display "\n[ENGINE] === ВСЕ ЗАДАЧИ В ОЧЕРЕДИ ВЫПОЛНЕНЫ! БАЗА СТАБИЛЬНА ===\n")
        #t)
      (begin
        ;; Захватываем точку возврата в диспетчер
        (call/cc
         (lambda (k-dispatcher)
           (set! *dispatcher-continuation* k-dispatcher)
           
           ;; Извлекаем первую задачу (FIFO)
           (let ((next-task (car *ready-queue*)))
             (set! *ready-queue* (cdr *ready-queue*))
             
             (display "\n[DISPATCHER] Начинаю такт выполнения следующей задачи...\n")
             ;; Запускаем задачу
             (next-task)
             
             ;; Если задача дошла до конца и не сделала abort/yield — выкидываем её из ядра
             (display "[DISPATCHER] Задача успешно завершилась и стерта из памяти.\n")
             (dispatcher-abort))))
        
        ;; Рекурсивно крутим цикл на следующий такт
        (run-dispatcher))))

;; -------------------------------------------------------------------
;; СЛОЙ 2: БИЗНЕС-ЛОГИКА И ЭМУЛЯЦИЯ КОМАНД (API)
;; -------------------------------------------------------------------

;; Имитация быстрого атомарного запроса (GET)
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

;; -------------------------------------------------------------------
;; СЛОЙ 3: ИНТЕРФЕЙС ПРИЕМА ЗАПРОСОВ (Фронтенд-эмулятор)
;; -------------------------------------------------------------------

;; Главная точка входа для входящих запросов
(define (dispatch-query query-type query-data)
  (display (string-append "\n[FRONTEND] Принят новый сетевой запрос. Тип: [" query-type "], Данные: <" query-data ">\n"))
  
  (cond
   ((string=? query-type "GET")
    (display "[FRONTEND] Создаю легкую задачу для GET и ставлю в очередь.\n")
    (spawn (lambda () (execute-get query-data))))
   
   ((string=? query-type "KEYS")
    (display "[FRONTEND] Создаю тяжелую задачу для SCAN и ставлю в очередь.\n")
    (spawn (lambda () (execute-heavy-scan))))
   
   (else
    (display "[FRONTEND] Ошибка: Неизвестная команда!\n"))))

;; ===================================================================
;; ЗАПУСК СИМУЛЯЦИИ (Эмуляция жизни базы ChainDB)
;; ===================================================================

(display "===================================================================\n")
(display "                ЗАПУСК ЭМУЛЯТОРА ЯДРА ChainDB                     \n")
(display "===================================================================\n")

;; 1. Симулируем приход запросов от клиентов (забиваем очередь)
(dispatch-query "KEYS" "*")        ; Первым прилетает страшный тяжелый запрос сканирования
(dispatch-query "GET" "user:100")  ; Следом за ним летит быстрый GET
(dispatch-query "GET" "user:200")  ; И еще один быстрый GET

(display "\n[BOOT] Очередь запросов сформирована. Запускаю Event Loop ядра...\n")

;; 2. Стартуем наш Диспетчер
(run-dispatcher)
