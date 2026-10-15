(load-shared-object #f)
(define SOCKET_PROTOCOL_DEFAULT 0)
(define AF_UNIX 1)
(define SOCK_STREAM 1)
(define c-socket
  (foreign-procedure "socket"( int int int) int))

;; this one we now should build in scheme 
;; struct sockaddr_un {
;;     unsigned char sun_len;
;;     sa_family_t   sun_family;
;;     char          sun_path[104];
;; };

(define-ftype sockaddr-un
  (struct
    (sun_len    unsigned-8)
    (sun_family unsigned-8)
    (sun_path   (array 104 unsigned-8))))


;; this one shoud be added because we need a pointer
(define-ftype sockaddr-un*
  (* sockaddr-un))
(define c-bind
  (foreign-procedure "bind" (int  sockaddr-un*  unsigned-32) int))
(let* [(s  (c-socket AF_UNIX SOCK_STREAM SOCKET_PROTOCOL_DEFAULT)) (sock-addr (string->bytevector "/tmp/my_sock.sock" (native-transcoder))) (sock-addr-len (bytevector-length sock-addr))]
  (assert (> s -1)))
