(display "working with ffi")
;; 1. Выделяем 8 байт памяти под одну структуру pollfd
;; 1. Подключаем базовую библиотеку для работы с байтвекторами
(import (chezscheme))
(load-shared-object #f)
;; 2. Захватываем родной порядок байт твоего Мака
(define my-endian (native-endianness))

;; 3. Выделяем 8 байт памяти под одну структуру pollfd
(define pollfd-struct (make-bytevector 8 0))

;; 4. Записываем дескриптор (число 4) в первые 4 байта
(bytevector-s32-set! pollfd-struct 0 4 my-endian)

;; 5. Записываем маску POLLIN (число 1) в байты 4-5
(bytevector-s16-set! pollfd-struct 4 1 my-endian)




;; 1. Объявляем системную процедуру poll из libc твоего Макбука
;; Аргументы: (указатель на структуру, количество структур, тайм-аут в мс)
(define c-poll 
  (foreign-procedure "poll" (u8* unsigned-long int) int))

;; 2. Делаем мгновенный неблокирующий опрос (тайм-аут 0 миллисекунд)
(define poll-result (c-poll pollfd-struct 1 0))
