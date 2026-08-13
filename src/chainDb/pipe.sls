(load-shared-object #f)
(library (chainDb pipe)
  (export run-stupid)
  (import (chezscheme))
  (define my-endian (native-endianness))
  
  (define c-open
    (foreign-procedure "open" (string int) int))

  (define c-poll
    (foreign-procedure "poll" (u8* unsigned-long int) int))

  (define c-read
    (foreign-procedure "read" (int u8* size_t) ssize_t))
  (define pollfd-struct (make-bytevector 8 0))


  (define (run-stupid)
    (define pipe-fd (c-open "my_test_pipe" 2050))
    (format #t "Пайп успешно открыт. Получен дескриптор fd: ~A\n" pipe-fd)


    (display "=== СТАРТ ТЕСТА СИСТЕМНОГО ПОЛЛИНГА ===\n")
    (bytevector-s32-set! pollfd-struct 0 pipe-fd my-endian) ; пишем fd
    (bytevector-s16-set! pollfd-struct 4 1 my-endian)       ; пишем маску POLLIN (1)
    (let [( poll-result (c-poll pollfd-struct 1 0))]
      (format #t "Результат первого опроса (должен быть 0, так как данных нет): ~A\n" poll-result)
      (let [( revents-result (bytevector-s16-ref pollfd-struct 6 my-endian))]
	(format #t "Статус флагов из ядра (revents): ~A\n" revents-result)
	)

      )

    )
  )


