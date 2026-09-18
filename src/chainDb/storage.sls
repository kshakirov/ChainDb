(library (chainDb storage)
  (export put-k-value )
  (import
   (chezscheme)
   )

  (define db (make-eq-hashtable))
  (define put-k-value
    (lambda (k v)
     (eq-hashtable-set!  db k v)
      #t)
    )
 (define get-k-value
    (lambda (k)
      (eq-hashtable-ref db k))
    )
  )


;; (define store (make-eq-hashtable))

;; (eq-hashtable-set! store 'foo 42)          ; положить
;; (eq-hashtable-ref  store 'foo #f)          ; достать => 42
;; (eq-hashtable-contains? store 'foo)        ; есть? => #t
;; (eq-hashtable-delete! store 'foo)          ; удалить
