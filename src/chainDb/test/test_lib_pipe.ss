;; 1. Пути к библиотекам
;;(library-directories '("." ("src" . ".")))

;; 2. Системные C-символы для FFI
;;(load-shared-object #f)

;; 3. Импорт модулей
(import (chezscheme)
	(chainDb pipe))

(display (run-stupid))
