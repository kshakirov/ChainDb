(import (chezscheme))

;; Загрузка библиотек (проверьте имена файлов под вашу ОС)
(load-shared-object "libc.dylib")
(load-shared-object "/usr/local/lib/libuv.dylib")



(define malloc (foreign-procedure "malloc" (size_t) void*))
(define free (foreign-procedure "free" (void*) void))

;; =====================================================================
;; Безопасное описание структуры uv_buf_t через ftype
;; =====================================================================
(define-ftype uv_buf_t
  (struct
    [base void*]
    [len size_t]))

;; FFI Объявления
(define uv-default-loop (foreign-procedure "uv_default_loop" () void*))
(define uv-run (foreign-procedure "uv_run" (void* int) int))
(define uv-tcp-init (foreign-procedure "uv_tcp_init" (void* void*) int))
(define uv-ip4-addr (foreign-procedure "uv_ip4_addr" (string int void*) int))
(define uv-tcp-bind (foreign-procedure "uv_tcp_bind" (void* void* unsigned-int) int))
(define uv-listen (foreign-procedure "uv_listen" (void* int void*) int))
(define uv-accept (foreign-procedure "uv_accept" (void* void*) int))
(define uv-read-start (foreign-procedure "uv_read_start" (void* void* void*) int))
(define uv-close (foreign-procedure "uv_close" (void* void*) void))

(define UV_RUN_DEFAULT 0)

;; =====================================================================
;; ИСПРАВЛЕННЫЕ КОЛЛБЭКИ
;; =====================================================================

(define on-alloc
  (foreign-callable
    (lambda (handle suggested-size buf-ptr)
      (let ([base-ptr (malloc suggested-size)]
            ;; Приводим сырой указатель buf-ptr к типизированному ftype-pointer
            [buf (make-ftype-pointer uv_buf_t buf-ptr)])
        ;; Безопасно заполняем поля структуры по именам
        (ftype-set! uv_buf_t (base) buf base-ptr)
        (ftype-set! uv_buf_t (len) buf suggested-size)))
    (void* size_t void*) void))

(define on-read
  (foreign-callable
    (lambda (client-stream nread buf-ptr)
      (let* ([buf (make-ftype-pointer uv_buf_t buf-ptr)]
             [base-ptr (ftype-ref uv_buf_t (base) buf)])
        (cond
          ;; Данные получены
          [(> nread 0)
           (display (string-append "Успешно получено байт: " (number->string nread) "\n"))
           (free base-ptr)]
          
          ;; Ошибка или отключение (EOF)
          [(< nread 0)
           (display "Клиент разорвал соединение.\n")
           (free base-ptr)
           (uv-close client-stream #f)]
          
          [else (free base-ptr)])))
    (void* ptrdiff_t void*) void))

(define on-new-connection
  (foreign-callable
    (lambda (server-stream status)
      (if (< status 0)
          (display "Ошибка соединения\n")
          ;; Выделяем память с запасом (1024 байта), чтобы избежать overflow структуры uv_tcp_t
          (let* ([loop (uv-default-loop)]
                 [client-stream (malloc 1024)]) 
            (uv-tcp-init loop client-stream)
            (if (= 0 (uv-accept server-stream client-stream))
                (begin
                  (display "Новый клиент подключен к Event Loop!\n")
                  (uv-read-start client-stream on-alloc on-read))
                (uv-close client-stream #f)))))
    (void* int) void))

;; =====================================================================
;; ЗАПУСК СЕРВЕРА
;; =====================================================================
(define (start-async-server port)
  ;; Выделяем под серверный хэндл 1024 байта во избежание повреждения памяти
  (let* ([loop (uv-default-loop)]
         [server-handle (malloc 1024)]
         [addr (malloc 128)]
         [backlog 128])
    (uv-tcp-init loop server-handle)
    (uv-ip4-addr "0.0.0.0" port addr)
    (uv-tcp-bind server-handle addr 0)
    (let ([r (uv-listen server-handle backlog on-new-connection)])
      (if (< r 0)
          (display "Не удалось вызвать uv_listen\n")
          (begin
            (display (string-append "Стабильный libuv сервер запущен на порту " (number->string port) "...\n"))
            (uv-run loop UV_RUN_DEFAULT))))))

(start-async-server 8080)
