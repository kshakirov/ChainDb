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

;; node_next — следующий свободный индекс узла;
;; data_next — следующее свободное смещение в половине данных;
;; node_limit и data_limit;
;; root_idx.

(define-ftype arena-header
  (struct
    (data_next  unsigned-64)
    (node_limit unsigned-64)
    (data-limit unsigned-64)
    (node_next unsigned-32)
    (root_idx unsigned-32)
    ))

(define (arena-at arena-base index)
  (make-ftype-pointer arena-node (+ arena-base (* (ftype-sizeof arena-node) index))))


(define (create-arena size)
  (c-mmap 0 size
                  (+ PROT_READ PROT_WRITE)
                  (+ MAP_PRIVATE MAP_ANON)
                  -1 0))


(define p (c-mmap 0 4096
                  (+ PROT_READ PROT_WRITE)
                  (+ MAP_PRIVATE MAP_ANON)
                  -1 0))

(define (arena-init  base size)
  (display "size")
  (let [(arena-ptr (make-ftype-pointer  arena-header base ))]
    (ftype-set! arena-header (node_next) arena-ptr 1) 
  ;; здесь буде инициализация арены и создание первого узла держащего всю инфу про арену 
  ))

(define (alloc-node )
    (display "body")
;; будет выделять следующий узел по  arena-header и записывать туда же новый индекс
  
  )


(define (alloc-bytes)
    (display "body")
  ;; будет выделять место для байт вектора по размеру этого вектора и копировать его туда  по индексу из arena-header затем туда занести измненение
  )


(define(put)
    (display "body")
;; разместить по ключу
  )

(define (get)
    (display "body")
  ;;;найти по ключу 
    )



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ASSERTS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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




(define node-2 (make-ftype-pointer arena-node (+  p (ftype-sizeof arena-node))))
(ftype-set! arena-node (flags) node-2 #x02)

(assert (= (ftype-ref arena-node (flags) node-2) #x02))

(let [(arena-ptr (arena-at p 10)) ]
  (ftype-set! arena-node (prefix_len) arena-ptr #x08)
  (assert (= (ftype-ref  arena-node (prefix_len) arena-ptr) #x08)))



(assert (= (c-munmap p 4096) 0))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; arena -init ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define arena (create-arena 4096))

(assert (= (ftype-sizeof arena-header) 32))

(arena-init arena 4096)
(define arena-header-ptr (make-ftype-pointer arena-header arena))
(assert (= (ftype-ref  arena-header (node_next) arena-header-ptr) 1))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CLEAN UP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(assert (= (c-munmap arena 4096) 0))
