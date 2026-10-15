(load-shared-object #f)
(define SOCKET_PROTOCOL_DEFAULT 0)
(define AF_UNIX 1)
(define SOCK_STREAM 1)
(define c-socket
  (foreign-procedure "socket"( int int int) int))
(define c-bind
  (foreign-procedure "bind" (int  u8* unsigned-32) int))
(let [(s  (c-socket AF_UNIX SOCK_STREAM SOCKET_PROTOCOL_DEFAULT))]
  (assert (> s -1)))
