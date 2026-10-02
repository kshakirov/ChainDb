
(define freqs '((one . 10) (two . 15) (three . 25)))
(define empiric-distribution 
  (lambda (d)
    (let ([fs (map (lambda (l) (cdr l)) d)])
      (let ([sum (fold-left + 0 fs)])
	(display sum)))))

;;(empiric-distribution freqs)



(define process-directory-list-element
	 (lambda ( elem f)
	   (if (file-regular? elem)
	       (begin
		 (display (format #f "File [~a] ~%" elem))
		 1
		 )
	       (begin
		 (display (format #f "Directory [~a] ~%" elem))
		 (f elem)
	       )
	       )))

(define process-directory
  (lambda (dir-name files)
    (map (lambda(elem)  (process-directory-list-element  (path-build dir-name elem)  walk-dir)) files)))



(define walk-dir
  (lambda (dir-name)
    (let ([ files (directory-list dir-name)])

(      process-directory dir-name files)
      )))

(walk-dir "/Users/kiryloshakirov/Documents/repos/scheme_coding/")
    
