;;(library-directories (cons "../src" (library-directories)))


(import (chezscheme)
	(chainDb dispatcher)
	(chainDb pipe)
	(chainDb commands))




;; Главная точка входа для входящих запросов
;;(run-stupid)

(run-dispatcher)
