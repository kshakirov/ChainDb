

(import (chezscheme))
(load-shared-object "libc.dylib")
;; Загружаем системную библиотеку libuv
(case (machine-type)
  [(a6le ta6le i3le ti3le) (load-shared-object "libuv.so")]
  [(a6osx ta6osx) (load-shared-object "libuv.dylib")]
  [else (load-shared-object "libuv.so")])

;; =====================================================================
;; 1. FFI ОПРЕДЕЛЕНИЯ (Привязки к С-функциям libuv)
;; =====================================================================
;; Было: (define uv-listen (foreign-procedure "uv_listen" (void* int foreign) int))
(define uv-listen (foreign-procedure "uv_listen" (void* int void*) int))

;; Было: (define uv-read-start (foreign-procedure "uv_read_start" (void* foreign foreign) int))
(define uv-read-start (foreign-procedure "uv_read_start" (void* void* void*) int))

;; Было: (define uv-close (foreign-procedure "uv_close" (void* foreign) void))
(define uv-close (foreign-procedure "uv_close" (void* void*) void))

;; Базовые функции цикла (Event Loop)
(define uv-default-loop (foreign-procedure "uv_default_loop" () void*))
(define uv-run (foreign-procedure "uv_run" (void* int) int))

;; TCP операции
(define uv-tcp-init (foreign-procedure "uv_tcp_init" (void* void*) int))
(define uv-ip4-addr (foreign-procedure "uv_ip4_addr" (string int void*) int))
(define uv-tcp-bind (foreign-procedure "uv_tcp_bind" (void* void* unsigned-int) int))

(define uv-accept (foreign-procedure "uv_accept" (void* void*) int))

;; Чтение и управление потоками данных



;; Выделение памяти на стороне C (для буферов libuv)
(define malloc (foreign-procedure "malloc" (size_t) void*))
(define free (foreign-procedure "free" (void*) void))

;; Константы libuv
(define UV_RUN_DEFAULT 0)

;; =====================================================================
;; 2. КОЛЛБЭКИ (Callbacks) С ИСПОЛЬЗОВАНИЕМ FOREIGN-CALLABLE
;; =====================================================================

;; Сигнатура C: void (*uv_alloc_cb)(uv_handle_t* handle, size_t suggested_size, uv_buf_t* buf)
;; libuv вызывает это, чтобы Scheme выделил буфер под входящие данные
(define on-alloc
  (foreign-callable
    (lambda (handle suggested-size buf-ptr)
      ;; Выделяем "сырую" память под данные
      (let ([base-ptr (malloc suggested-size)])
        ;; Записываем адрес буфера и его размер в структуру uv_buf_t
        ;; (Предполагаем стандартное смещение структур uv_buf_t: base на 0, len на размер указателя)
        (foreign-set! 'void* base-ptr 0)
        (foreign-set! 'size_t suggested-size (foreign-sizeof 'void*))))
    (void* size_t void*) void))

;; Сигнатура C: void (*uv_read_cb)(uv_stream_t* stream, ssize_t nread, const uv_buf_t* buf)
;; Срабатывает, когда от клиента пришли асинхронные данные
(define on-read
  (foreign-callable
    (lambda (client-stream nread buf-ptr)
      (let* ([base-ptr (foreign-ref 'void* buf-ptr 0)]
             [len (foreign-ref 'size_t buf-ptr (foreign-sizeof 'void*))])
        (cond
          ;; nread > 0: Данные успешно прочитаны
          [(> nread 0)
           (display (string-append "Успешно получено байт: " (number->string nread) "\n"))
           ;; Здесь данные находятся в памяти по адресу base-ptr. Их можно распарсить.
           ;; Для простого эхо-сервера мы могли бы вызвать uv_write, но пока просто освободим буфер.
           (free base-ptr)]
          
          ;; nread < 0: Ошибка или клиент закрыл соединение (EOF)
          [(< nread 0)
           (display "Клиент отключился. Закрываем сокет...\n")
           (free base-ptr)
           (uv-close client-stream (integer->foreign-label 0))] ; Передаем NULL как on_close
          
          [else (free base-ptr)])))
    (void* ptrdiff_t void*) void))

;; Сигнатура C: void (*uv_connection_cb)(uv_stream_t* server, int status)
;; Срабатывает при каждом новом TCP-подключении (аналог сервера в Node.js)
(define on-new-connection
  (foreign-callable
    (lambda (server-stream status)
      (if (< status 0)
          (display "Ошибка входящего подключения!\n")
          (let* ([loop (uv-default-loop)]
                 ;; Выделяем память под структуру клиента (размер uv_tcp_t обычно около 248 байт, берем с запасом 512)
                 [client-stream (malloc 512)]) 
            
            (uv-tcp-init loop client-stream)
            
            (if (= 0 (uv-accept server-stream client-stream))
                (begin
                  (display "Новый клиент успешно подключен асинхронно!\n")
                  ;; Начинаем слушать входящие данные от этого клиента
                  (uv-read-start client-stream 
                                 (object->foreign-entry on-alloc) 
                                 (object->foreign-entry on-read)))
                (uv-close client-stream (integer->foreign-label 0))))))
    (void* int) void))

;; =====================================================================
;; 3. ТОЧКА ВХОДА (Запуск сервера)
;; =====================================================================

(define (start-async-server port)
  (let* ([loop (uv-default-loop)]
         ;; Выделяем структуры в куче C
         [server-handle (malloc 512)]
         [addr (malloc 32)]
         [backlog 128])
    
    ;; Инициализируем TCP на нашем Event Loop
    (uv-tcp-init loop server-handle)
    
    ;; Настраиваем IP/Порт
    (uv-ip4-addr "0.0.0.0" port addr)
    
    ;; Биндим сокет
    (uv-tcp-bind server-handle addr 0)
    
    ;; Активируем коллбэки для прослушивания входящих соединений
    (let ([r (uv-listen server-handle backlog (object->foreign-entry on-new-connection))])
      (if (< r 0)
          (display "Не удалось запустить прослушивание порта.\n")
          (begin
            (display (string-append "Асинхронный Node.js-style сервер запущен на порту " (number->string port) "...\n"))
            ;; Запускаем бесконечный Event Loop. Этот вызов заблокирует поток Chez Scheme
            ;; и будет крутить цикл обработки событий libuv.
            (uv-run loop UV_RUN_DEFAULT))))))

;; Запускаем наш неблокирующий сервер
(start-async-server 8080)




(import (chezscheme))
(load-shared-object "libc.dylib")
(define malloc (foreign-procedure "malloc" (size_t) void*))
