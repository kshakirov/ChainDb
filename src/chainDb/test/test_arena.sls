(import (chezscheme)
	(chainDb arena))

(define-ftype arena-node
  (struct
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

p;; p — указатель, или (void*)-1 = ошибк это указатель на начало памяти выделенной ммаз
;; арена ноде ввверху это структура или как интерпретировать 32 байта этой памяти, они конечно должы их начало кратно 32 
(assert (not (= p #xffffffffffffffff)))
(foreign-set! 'unsigned-8  p 0 8)
(let [(read-from-arena (foreign-ref 'unsigned-8  p 0))]
  (display read-from-arena)
  (assert (= read-from-arena 8)))

;; устанавливаем указатель на начало арены это наш логический ноль
;; и интерпретируем следующие 32 байта размер узла как узел, просто накладываем пока шаблон это ничего не создает там
(define node  (make-ftype-pointer arena-node p))

;; а вот теперь через этот шаблон начинаем заполнять поля структуры и вот они то и пишутся физически в арену
(ftype-set!  arena-node (flags) node #x01)
(assert (= (ftype-sizeof arena-node) 32))
;; а вот теперь читаем это поле из арены
(assert (= (ftype-ref arena-node (flags) node) #x01))
(assert (not (= p #xffffffffffffffff)))


(define (arena-at arena-base index)
  (make-ftype-pointer arena-node (+ arena-base (* (ftype-sizeof arena-node) index))))


(define node-2 (make-ftype-pointer arena-node (+  p (ftype-sizeof arena-node))))
(ftype-set! arena-node (flags) node-2 #x02)

(assert (= (ftype-ref arena-node (flags) node-2) #x02))

(let [(arena-ptr (arena-at p 10)) ]
  (ftype-set! arena-node (prefix_len) arena-ptr #x08)
  (assert (= (ftype-ref  arena-node (prefix_len) arena-ptr) #x08)))
  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CLEAN UP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(assert (= (c-munmap p 4096) 0))


