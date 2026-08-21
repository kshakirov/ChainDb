(library (chainDb storage)
  (export put-k-value )
  (import
   (chezscheme)
   )

  (define db (make-eq-hashtable))
  (define put-k-value
    (lambda (k v)
      (hashtable-set!  db k v)
      #t)
    )
 ;; (define get-k-value
 ;;    (lambda (k)
 ;;      (hashtable-ref db k))
 ;;    )
  )
