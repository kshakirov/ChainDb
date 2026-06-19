
(define freqs '((one . 10) (two . 15) (three . 25)))
(define empiric-distribution 
  (lambda (d)
    (let ([fs (map (lambda (l) (cdr l)) d)])
      (let ([sum (fold-left + 0 fs)])
	(display sum)))))

;;(empiric-distribution freqs)

(define walk-dir
  (lambda (dir-name)
    (let ([ files (directory-list dir-name)])
      (display files)
      )))
(walk-dir "/Users/kiryloshakirov/Documents/repos/")
    
