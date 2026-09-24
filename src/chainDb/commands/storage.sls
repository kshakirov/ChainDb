(library (chainDb commands storage)
  (export put-k-value  get-k-value)
  (import
   (chezscheme)
   )

  (define db (make-hashtable string-hash string=?))
  (define put-k-value
    (lambda (k v)
     (hashtable-set!  db k v)
      #t)
    )
 (define get-k-value
    (lambda (k)
      (hashtable-ref db k #f))
    )
  )



;; (define store (make-hashtable string-hash string=?))
;; (hashtable-set! store "1" value)
;; (hashtable-ref  store "1" #f)   ; →
;; (define store (make-eq-hashtable))

;; (eq-hashtable-set! store 'foo 42)          ; положить
;; (eq-hashtable-ref  store 'foo #f)          ; достать => 42
;; (eq-hashtable-contains? store 'foo)        ; есть? => #t
;; (eq-hashtable-delete! store 'foo)          ; удалить
