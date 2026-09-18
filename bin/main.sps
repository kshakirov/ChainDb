;;(library-directories (cons "../src" (library-directories)))


(import (chezscheme)
	(chainDb dispatcher)
	(chainDb pipe)
	(chainDb storage)
	(chainDb commands))




;; Главная точка входа для входящих запросов
;;(poll-fifo-source)
(put-k-value "1"  "first test")
(run-dispatcher)
