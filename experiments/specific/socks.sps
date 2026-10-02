(import (chezscheme))

(define (start-server port)
  (let ((listener (make-tcp-server-socket port)))
    (display (string-append "Сервер запущен на порту " (number->string port) "\n"))
    (let loop ()
      ;; Принимаем входящее соединение от клиента
      (let ((client-socket (accept listener)))
        ;; Обрабатываем запрос в фоновом потоке или блокирующем режиме
        (let ((input-port (car client-socket))
              (output-port (cdr client-socket)))
          
          ;; Читаем заголовки (просто считываем строку запроса)
          (let ((request-line (get-line input-port)))
            (display (string-append "Запрос: " request-line "\n"))
            
            ;; Формируем HTTP-ответ
            (let ((body "<html><body><h1>Привет от Chez Scheme!</h1></body></html>"))
              (display "HTTP/1.1 200 OK\r\n" output-port)
              (display "Content-Type: text/html; charset=UTF-8\r\n" output-port)
              (display (string-append "Content-Length: " (number->string (string-length body)) "\r\n") output-port)
              (display "\r\n" output-port)
              (display body output-port))
            
            ;; Очищаем буфер и закрываем соединение
            (flush-output-port output-port)
            (close-port input-port)
            (close-port output-port)))
        (loop)))))

;; Запуск сервера на порту 8080
(start-server 8080)
