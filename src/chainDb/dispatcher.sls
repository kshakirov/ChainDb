(library (chainDb dispatcher)
  (export  run-dispatcher async-yield spawn) 
  (import
;;   (rnrs)
   (chezscheme)
   )
  (define *ready-queue* '())              ; Очередь готовых задач
  (define *dispatcher-continuation* #f)    ; Точка аварийного возврата в диспетчер
  (define make-dispatcher-sleep
    (lambda (t)
      (sleep (make-time 'time-duration 0 t))
      (run-dispatcher)
      )
    )
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
          (display "\n[ENGINE] === ВСЕ ЗАДАЧИ В ОЧЕРЕДИ ВЫПОЛНЕНЫ! БАЗА СТАБИЛЬНА =ЗАСЫПАЮ ==\n")
	  (make-dispatcher-sleep 5)
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
  )
