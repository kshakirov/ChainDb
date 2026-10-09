(load-shared-object #f)
(library (chainDb arena )
  (export c-mmap c-munmap PROT_READ PROT_WRITE MAP_PRIVATE MAP_ANON)
  (import (chezscheme))
  (define c-mmap
    (foreign-procedure "mmap" (void* size_t int int int integer-64) void*))
  (define c-munmap
    (foreign-procedure "munmap" (void* size_t) int))
  (define PROT_READ  1)
  (define PROT_WRITE 2)
  (define MAP_SHARED  1)
  (define MAP_PRIVATE 2)
  (define MAP_ANON    #x1000)

  )
