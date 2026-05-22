;;#!/usr/bin/env scheme-script
;; -*- mode: scheme; coding: utf-8 -*- !#
;; Copyright (c) 2026 kshakirov
;; SPDX-License-Identifier: MIT
;;#!r6rs

(import (rnrs (6)) (scheme_coding))

(display (hello "World, freaking freakn"))
(newline)
(call/cc
 (lambda (k)
   (+ 2 4)))

(call/cc
 (lambda (k)
   (* 5 (k 4))))

(call/cc
 (lambda (k)
   ( k ( * 5  4))))


