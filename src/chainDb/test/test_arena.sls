(import (chezscheme)
	(chainDb arena))

(define-ftype arena-node
  (struct
    (id unsigned-64)
    (flags     unsigned-16)
    (prefix_len        unsigned-16)
    (prefix_off        unsigned-32 );; от arena_base
    (value_len         unsigned-32)
    (value_off         unsigned-32 );; от arena_base
    (first_child_idx   unsigned-32 );; 0 = NULL
    (next_sibling_idx  unsigned-32 );; 0 = NULL
    (reserved          unsigned-64)
    ))


(define p (c-mmap 0 4096
                  (+ PROT_READ PROT_WRITE)
                  (+ MAP_PRIVATE MAP_ANON)
                  -1 0))

p;; p — указатель, или (void*)-1 = ошибка

(foreign-set! 'unsigned-8  p 0 8)
(let [(read-from-arena (foreign-ref 'unsigned  p 0))]
  (display read-from-arena)
  (assert (= read-from-arena 8)))

;; (define pointer-to-arena (make-ftype-pointer arena-node p))
;; (ftype-set!  arena-node (id pointer-to-arena) 42)
(assert (not (= p #xffffffffffffffff)))
(assert (= (c-munmap p 4096) 0))
