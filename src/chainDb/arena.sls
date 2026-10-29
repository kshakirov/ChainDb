(load-shared-object #f)
(library (chainDb arena )
  (export c-mmap c-munmap PROT_READ PROT_WRITE MAP_PRIVATE MAP_ANON c-memcpy c-memcmp)
  (import (chezscheme))
  (define c-mmap
    (foreign-procedure "mmap" (void* size_t int int int integer-64) void*))
  (define c-munmap
    (foreign-procedure "munmap" (void* size_t) int))
  (define c-memcpy
    (foreign-procedure "memcpy" (void* u8* size_t) void*))

  (define c-memcmp
  (foreign-procedure "memcmp" (void* u8* size_t) int))

  (define PROT_READ  1)
  (define PROT_WRITE 2)
  (define MAP_SHARED  1)
  (define MAP_PRIVATE 2)
  (define MAP_ANON    #x1000)

  )
