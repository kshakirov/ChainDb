(import (chezscheme)
	(chainDb arena))


;;(load-shared-object #f)
(define SOCKET_PROTOCOL_DEFAULT 0)
(define AF_UNIX 1)
(define SOCK_STREAM 1)
;;( define c-memcpy
 ;;  (foreign-procedure "memcpy" (void* u8* size_t) void*))
(define c-socket
  (foreign-procedure "socket"( int int int) int))

;; this one we now should build in scheme 
;; struct sockaddr_un {
;;     unsigned char sun_len;
;;     sa_family_t   sun_family;
;;     char          sun_path[104];
;; };


(define c-listen
  (foreign-procedure "listen" ( int int) int))
(define-ftype sockaddr-un
  (struct
    (sun_len    unsigned-8)
    (sun_family unsigned-8)
    (sun_path   (array 104 unsigned-8))))

;; this one below is just a draft

(define-ftype kevene
  (struct
    (indent  unsigned-int)
    (filter int )
    (flags int )
    ( fflags int)
    (data int)
    (udata void*)
    ))
;; this one shoud be added because we need a pointer
(define-ftype sockaddr-un*
  (* sockaddr-un))

(define addr-ptr
  (make-ftype-pointer sockaddr-un
  (foreign-alloc (ftype-sizeof sockaddr-un))))

(define (create-sockaddr-un path path-len)
  ( ftype-set! sockaddr-un (sun_len) addr-ptr (ftype-sizeof sockaddr-un))
  (ftype-set! sockaddr-un (sun_family) addr-ptr AF_UNIX)
  (c-memcpy (+ (ftype-pointer-address  addr-ptr) 2) path path-len)
 
  )

(define socket-path "/tmp/my_sock.sock")
(define c-bind
  (foreign-procedure "bind" (int  sockaddr-un*  unsigned-32) int))

(define c-kqueue
  (foreign-procedure "kqueue" () int))





(let*
    [
     (s  (c-socket AF_UNIX SOCK_STREAM SOCKET_PROTOCOL_DEFAULT))
     (sock-addr (string->bytevector "/tmp/my_sock.sock" (native-transcoder)))
     (sock-addr-len (bytevector-length sock-addr))

     ]
  (delete-file socket-path)
  (create-sockaddr-un sock-addr sock-addr-len)
  (unless (=  (c-bind s addr-ptr (ftype-sizeof sockaddr-un)) 0)
    (error 'bind "failed"))
  (unless  (= (c-listen s 64) 0)
    (error 'listen "failed" ))
  (unless  (>= (c-kqueue ) 0)
    (error 'kqueue "failed" ))
  
  (assert (> s -1)
	  ) 
  )

