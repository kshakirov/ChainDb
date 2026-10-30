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
    (data_limit unsigned-64)
    (node_next unsigned-32)
    (root_idx unsigned-32)
    ))

;; we create a pointer to point to the node as an arena-node our usual only node
(define (arena-at arena-base index)
  (make-ftype-pointer arena-node (+ arena-base  (* (ftype-sizeof arena-node) index))))


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

  (let* [(arena-ptr (make-ftype-pointer  arena-header base ))
	 (usable (- size 32))
	 (data-next (floor (/ size 2)))
	 (node-limit (floor (/ usable 64)))
	 (data-limit size)
	 (root-ptr (make-ftype-pointer arena-node (+ base (ftype-sizeof arena-header))))
	 ]
    (ftype-set! arena-header (node_next) arena-ptr 2)
    (ftype-set! arena-header (root_idx) arena-ptr 1)
    (ftype-set! arena-header (data_limit) arena-ptr data-limit)
    (ftype-set! arena-header (node_limit) arena-ptr node-limit)
    (ftype-set! arena-header (data_next) arena-ptr data-next)
    (ftype-set! arena-node (flags) root-ptr #x00) ;;explicilty empty
    
    ;; здесь буде инициализация арены и создание первого узла держащего всю инфу про арену 
    ))

;; just get index for the new node and change root next node to its value д
(define (alloc-node  arena-base)

  (let* [
	 (header (make-ftype-pointer arena-header arena-base))
	 (next-node (ftype-ref arena-header (node_next) header ))
	 (node-limit (ftype-ref arena-header (node_limit) header))
	 ]
    (if (>  next-node node-limit) #f 
	(begin
	  (ftype-set! arena-header (node_next) header (+ next-node 1))
	  next-node
	  )
	;; будет выделять следующий узел по  arena-header и записывать туда же новый индекс
	
	)))

;; the same as above we get from the root - 1st node the counter of bytes allocated for data, return it and increase the current root data -next by the length of data vector 
(define (alloc-bytes arena-base vector)
  (let* [
  	 (header (make-ftype-pointer arena-header arena-base))
	 (data-next (ftype-ref arena-header (data_next) header ))
	 (data-limit (ftype-ref arena-header (data_limit) header))
	 (current-data-size (bytevector-length vector))
	 ]
    (if (>  (+ data-next current-data-size) data-limit) #f
	(begin
	  (ftype-set! arena-header (data_next) header (+ data-next current-data-size))
	  (c-memcpy (+ arena-base data-next) vector current-data-size)
	  data-next 
	  )
	
	;; будет выделять место для байт вектора по размеру этого вектора и копировать его туда  по индексу из arena-header затем туда занести измненение
	)))






(define (create-node arena-base segment-vector value-vector)
  (let* [
	 (node-idx (alloc-node arena-base))
	 (data-offset (alloc-bytes arena-base segment-vector))
	 (node (arena-at arena-base  node-idx))
	 (prefix-len (bytevector-length segment-vector))
	 (value-offset (alloc-bytes arena-base value-vector))
	 (value-len (bytevector-length value-vector))
	 
	 ]
    (display "Adding  Node \n")
    (ftype-set! arena-node (prefix_off) node data-offset)
    (ftype-set! arena-node (prefix_len) node prefix-len)
    (ftype-set! arena-node (value_off) node value-offset)
    (ftype-set! arena-node (value_len) node value-len)
    (ftype-set! arena-node (flags) node 1)
    
    node-idx
    ;;	 (ftype-set! arena-node (first_child) node prefix-len)
    
    
    
    ))



(define (put-simple arena-base segment-vector value-vector)
  (let* [
	 (header (make-ftype-pointer arena-header arena-base))
	 (root-idx (ftype-ref arena-header (root_idx) header))
	 (root (arena-at arena-base root-idx))
	 (first-child (ftype-ref arena-node (first_child_idx) root))

	 ]
    (if (= 0 first-child) (begin
			    (let [(new-node-idx (create-node arena-base segment-vector value-vector))]
			      (display "added")
			      (ftype-set! arena-node (first_child_idx) root  new-node-idx)
			      new-node-idx
			      ))
	-1 
	)
    
    ))

(define (get-value-or-else-false arena-base node )
  (let [(flags (ftype-ref arena-node (flags) node))]
    (if (= flags #x01)
	(begin
	  (let* [
		 (value-off (ftype-ref arena-node (value_off) node))
		 (value-len (ftype-ref arena-node (value_len) node))
		 (value-vector (make-bytevector value-len 0))
		 
		 ]
		 (c-memcpy-rev  value-vector (+ arena-base value-off)  value-len)
		 value-vector
	    ))
	  
	#f))
  )

(define (get arena-base segment-vector)
  (let* [
	 (header (make-ftype-pointer arena-header arena-base))
	 (root-idx (ftype-ref arena-header (root_idx) header))
	 (root (arena-at arena-base root-idx))
	 (first-child (ftype-ref arena-node (first_child_idx) root))
	 ]
    (if ( = first-child 0) #f
	(begin 
	  (let [(node (arena-at arena-base first-child)) ]
	    (let loop [(key-position 0) (n node)]
	      (if (segment-matches-key? arena-base n  segment-vector key-position)
		  (begin
		    (let* [
			   (prefix-len  (ftype-ref arena-node (prefix_len) n))
			   (new-key-position ( + key-position  prefix-len))
			   (next-first-child-idx (ftype-ref arena-node (first_child_idx) n))
			   ]
		      (if (= (bytevector-length segment-vector) new-key-position) (get-value-or-else-false arena-base n)
			  (if (= next-first-child-idx 0 ) #f
			      (let [(next-first-child (arena-at arena-base next-first-child-idx))]
				(loop new-key-position next-first-child)
				)
			      )
			  )
		      )
		    )
		  
		  (begin
		    (let [(next-sibling-idx (ftype-ref arena-node (next_sibling_idx) n))]
		      (if (= next-sibling-idx 0) #f
			  (let [(next-sibling  (arena-at arena-base next-sibling-idx))]
			    (loop key-position next-sibling )))
			  )))
	      )) )))

  )

(define (update-value arena-base node value-vector )
    (let* [
	 (value-offset (alloc-bytes arena-base value-vector))
	 (value-len (bytevector-length value-vector))
	 
	 ]
    (display "Updating value \n")
    (ftype-set! arena-node (value_off) node value-offset)
    (ftype-set! arena-node (value_len) node value-len)
    (ftype-set! arena-node (flags) node 1)
    ))

(define (add-brother arena-base node segment-part value-vector)
  (let* [
	 (brother-idx (create-node arena-base segment-part value-vector))
	 
	 ]
    (ftype-set! arena-node (next_sibling_idx) node brother-idx)
    brother-idx
    )
  )

(define (put  arena-base segment-vector value-vector)
  (let* [
	 (header (make-ftype-pointer arena-header arena-base))
	 (root-idx (ftype-ref arena-header (root_idx) header))
	 (root (arena-at arena-base root-idx))
	 (first-child (ftype-ref arena-node (first_child_idx) root))
	 ]
    (if ( = first-child 0) #f
	(begin 
	  (let [(node (arena-at arena-base first-child)) ]
	    (let loop [(key-position 0) (n node)]
	      (if (segment-matches-key? arena-base n  segment-vector key-position)
		  (begin
		    (let* [
			   (prefix-len  (ftype-ref arena-node (prefix_len) n))
			   (new-key-position ( + key-position  prefix-len))
			   (next-first-child-idx (ftype-ref arena-node (first_child_idx) n))
			   ]
		      (if (= (bytevector-length segment-vector) new-key-position) (update-value arena-base n value-vector)
			  (if (= next-first-child-idx 0 ) #f
			      (let [(next-first-child (arena-at arena-base next-first-child-idx))]
				(loop new-key-position next-first-child)
				)
			      )
			  )
		      )
		    )
		  
		  (begin
		    (let [(next-sibling-idx (ftype-ref arena-node (next_sibling_idx) n))]
		      (if (= next-sibling-idx 0) (add-brother arena-base n (bytevector-copy segment-vector key-position (bytevector-length segment-vector)) value-vector)   ; копия [start, end)))
			  (let [(next-sibling  (arena-at arena-base next-sibling-idx))]
			    (loop key-position next-sibling )))
			  )))
	      )) )))

  )


(define (arena-subvector-cmp arena-base prefix-off prefix-len key key-position)
  (let loop( (i 0) )
    (if (= i prefix-len) #t
	(begin
	  (display "")
	  (if (= (foreign-ref 'unsigned-8  (+ arena-base prefix-off i ) 0) (bytevector-u8-ref key (+ key-position i)) ) (loop (+ 1 i))
	      #f  )
	  
	  ))))



(define (segment-matches-key? arena-base  node  key  key-position)
  (let* [
	 (prefix-off (ftype-ref arena-node (prefix_off) node))
	 (prefix-len (ftype-ref arena-node (prefix_len) node ))
	 ]
    (if(>  prefix-len ( - (bytevector-length key ) key-position)) #f
       (begin
	 
	 (if (arena-subvector-cmp arena-base prefix-off prefix-len key key-position) #t
	     #f
	     ))

       )))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ASSERTS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
p;; p — указатель, или (void*)-1 = ошибк это указатель на начало памяти выделенной ммаз
;; арена ноде ввверху это структура или как интерпретировать 32 байта этой памяти, они конечно должы их начало кратно 32 
(assert (not (= p #xffffffffffffffff)))
(foreign-set! 'unsigned-8  p 0 8)
(let [(read-from-arena (foreign-ref 'unsigned-8  p 0))]
  ;;  (display read-from-arena)
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
(define arena-size 4096)

(define arena (create-arena arena-size))

(assert (= (ftype-sizeof arena-header) 32))

(arena-init arena 4096)
(define arena-header-ptr (make-ftype-pointer arena-header arena))
(assert (= (ftype-ref  arena-header (node_next) arena-header-ptr) 2))
(assert (= (ftype-ref  arena-header (root_idx) arena-header-ptr) 1))
(display (ftype-ref  arena-header (data_next) arena-header-ptr))
(assert (= (ftype-ref  arena-header (node_limit) arena-header-ptr) 63))
(assert (= (ftype-ref  arena-header (data_limit) arena-header-ptr) 4096))
(assert (= (ftype-ref  arena-header (data_next) arena-header-ptr) 2048))
(assert(= 2  (alloc-node arena)))
(assert ( =  2048 (alloc-bytes arena #vu8(1 2 3))))
(assert (= (foreign-ref 'unsigned-8 arena 2048) 1))
(create-node arena (string->bytevector "node/1" (native-transcoder)) (string->bytevector "some value " (native-transcoder)))
(assert (= 4 (put-simple arena (string->bytevector "node/1" (native-transcoder)) (string->bytevector "some value " (native-transcoder)))))

(let* [(root (arena-at arena (ftype-ref arena-header (root_idx) arena-header-ptr)))
       (first-child-idx (ftype-ref arena-node (first_child_idx) root))
       (first-child (arena-at arena first-child-idx))]
  (assert (segment-matches-key?
	   arena first-child
	   (string->bytevector "node/1" (native-transcoder)) 0))
  (assert (segment-matches-key?
	   arena first-child
	   (string->bytevector "xxnode/1" (native-transcoder)) 2))
  (assert (not (segment-matches-key?
		arena first-child
		(string->bytevector "node/2" (native-transcoder)) 0)))
  (assert (not (segment-matches-key?
		arena first-child
		(string->bytevector "node/" (native-transcoder)) 0))))
(assert (get arena  (string->bytevector "node/1" (native-transcoder))))
(assert(not (get arena  (string->bytevector "node/2" (native-transcoder)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CLEAN UP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(assert (= (c-munmap arena arena-size) 0))
