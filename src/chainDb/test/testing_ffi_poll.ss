(display "working with ffi")


(import (chezscheme))
(load-shared-object #f)

(display "=== СТАРТ ТЕСТА СИСТЕМНОГО ПОЛЛИНГА ===\n")

(define my-endian (native-endianness))

;; 1. Точное объявление системных функций (исключаем люфт типов в регистрах)
(define c-open
  (foreign-procedure "open" (string int) int))

(define c-poll
  (foreign-procedure "poll" (u8* unsigned-long int) int))

(define c-read
  (foreign-procedure "read" (int u8* size_t) ssize_t))

;; 2. Открываем пайп в режиме Чтения/Записи + Неблокирующий (2 + 2048 = 2050)
;; Теперь этот вызов выполнится МГНОВЕННО, файл не зависнет при запуске!
(define pipe-fd (c-open "my_test_pipe" 2050))
(format #t "Пайп успешно открыт. Получен дескриптор fd: ~A\n" pipe-fd)

;; 3. Готовим структуру pollfd (8 байт)
(define pollfd-struct (make-bytevector 8 0))
(bytevector-s32-set! pollfd-struct 0 pipe-fd my-endian) ; пишем fd
(bytevector-s16-set! pollfd-struct 4 1 my-endian)       ; пишем маску POLLIN (1)

;; 4. Делаем мгновенный неблокирующий опрос (таймаут 0)
(define poll-result (c-poll pollfd-struct 1 0))
(format #t "Результат первого опроса (должен быть 0, так как данных нет): ~A\n" poll-result)

;; 5. Читаем статус revents из байтвектора (байты 6-7)
(define revents-result (bytevector-s16-ref pollfd-struct 6 my-endian))
(format #t "Статус флагов из ядра (revents): ~A\n" revents-result)


;; Выделяем 128 байт памяти, заполненных нулями
(define read-buffer (make-bytevector 128 0))

;; Проверяем длину созданного буфера (должно вернуть 128)
(bytevector-length read-buffer)


(define bytes-read (c-read pipe-fd read-buffer 127))

;;(define buf-addr (object->address read-buffer))
;;(display buf-addr)

(display "=== ТЕСТ ЗАВЕРШЕН УСПЕШНО ===\n")
