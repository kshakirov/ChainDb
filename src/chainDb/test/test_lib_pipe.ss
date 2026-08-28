;; 1. Пути к библиотекам
;;(library-directories '("." ("src" . ".")))

;; 2. Системные C-символы для FFI
;;(load-shared-object #f)

;; 3. Импорт модулей
;; 1. Configure library search directories (relative to project root)
;;(library-directories '(("." ("src" . "."))))

;; 2. Load system C symbols for FFI
;;(load-shared-object #f)

;; 3. Import project modules

(import (chezscheme)
(chainDb pipe)
(chainDb dispatcher)
;;(import (chainDb storage))
(chainDb commands))
(define fd (c-open "/Users/kiryloshakirov/Documents/repos/scheme_coding/my_test_pipe" 6))

(format #t "Пайп для чтения успешно открыт. Получен дескриптор fd: ~A\n" fd)

(define c-write (foreign-procedure "write" (int u8* size_t) ssize_t))
(define c-close (foreign-procedure "close" (int) int ))
(define data-to-write(make-bytevector 1028 31))
(define written-bytes (c-write fd data-to-write 1028))

(define  list-of-vectors (run-stupid))
(define v1 #vu8( 1 2 3))
(define v2 #vu8( 4 5 6))
(define (append-bytevector v1 v2)
  (let [ (v1size (bytevector-length v1)) (v2size (bytevector-length v2))]
    ( let [(nbv (make-bytevector (+ v1size v2size)))]
      (bytevector-copy! v1 0 nbv 0 v1size)
      (bytevector-copy! v2 0 nbv v1size v2size)
      nbv)))
    

(display (utf8->string list-of-vectors))
(if (= (bytevector-length list-of-vectors) written-bytes)
    (display "test ok")
    (display "test failed")
    )
(c-close  fd)
;;(append-bytevector v1 v2)

