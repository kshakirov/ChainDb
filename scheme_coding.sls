;; -*- mode: scheme; coding: utf-8 -*-
;; Copyright (c) 2026 kshakirov
;; SPDX-License-Identifier: MIT
#!r6rs

(library (scheme_coding)
  (export hello)
  (import (rnrs))

(define (hello whom)
  (string-append "Hello " whom "!")))
