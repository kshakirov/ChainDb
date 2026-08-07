

(import (chezscheme))
(load-shared-object #f)

(define my-endian (native-endianness))

(define c-open
  (foreign-procedure "open" (string int) int))

(define c-poll
  (foreign-procedure "poll" (u8* unsigned-long int) int))

(define c-read
  (foreign-procedure "read" (int u8* size_t) ssize_t))

;; 1. Открываем пайп (O_RDWR + O_NONBLOCK = 2050)
(define pipe-fd (c-open "my_test_pipe" 2050))
(format #t "Пайп открыт. Дескриптор: ~A\n" pipe-fd)

;; 2. Готовим структуру pollfd (8 байт)
(define pollfd-struct (make-bytevector 8 0))
(bytevector-s32-set! pollfd-struct 0 pipe-fd my-endian) ; пишем fd
(bytevector-s16-set! pollfd-struct 4 1 my-endian)       ; маска POLLIN (1)

;; 3. МГНОВЕННЫЙ опрос poll (таймаут 0)
(define poll-result (c-poll pollfd-struct 1 0))
(format #t "Результат poll: ~A\n" poll-result)

;; 4. Проверяем, есть ли данные
(if (= poll-result 0)
    (display "В пайпе пусто! Пропускаем чтение, поток Свободен.\n")
    (begin
      (display "Данные найдены! Безопасно вызываем чтение.\n")
      ;; Используем let* вместо внутреннего define
      (let* ((read-buffer (make-bytevector 128 0))
             (bytes-read (c-read pipe-fd read-buffer 127)))
        (format #t "Прочитано байт: ~A\n" bytes-read)
        (when (> bytes-read 0)
          (let* ((codec (utf-8-codec))
                 (transcoder (make-transcoder codec))
                 (text (bytevector->string read-buffer transcoder 0 bytes-read)))
            (format #t "Полученный текст: ~A\n" text))))))
