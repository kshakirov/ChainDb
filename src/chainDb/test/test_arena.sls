(load-shared-object #f)
(import (chezscheme))
(define c-strlen
  (foreign-procedure "strlen" (string) integer-64))
(define c-mmap
  (foreign-procedure "mmap" (void* size_t int int int integer-64) void*))
(define c-munmap
  (foreign-procedure "munmap" (void* size_t) int))
(c-strlen "hello")   ; => 5
(define PROT_READ  1)
(define PROT_WRITE 2)
(define MAP_SHARED  1)
(define MAP_PRIVATE 2)
(define MAP_ANON    #x1000)

(define p (c-mmap 0 4096
                  (+ PROT_READ PROT_WRITE)
                  (+ MAP_PRIVATE MAP_ANON)
                  -1 0))

p;; p — указатель, или (void*)-1 = ошибка


(assert (not (= p #xffffffffffffffff)))
(assert (= (c-munmap p 4096) 0))
