#lang scribble/manual

@(require scribble/eval
          (for-label tacit
                     racket/base
                     racket/contract
                     racket/function
                     racket/list))

@title{point-free}

@(define the-eval (make-base-eval))
@(the-eval '(require "main.rkt"
                     racket/function
                     racket/list))

@defmodule[tacit]

@author[@author+email["Laurent Müller" "loeru@pm.me"]]

Useful functions

source code: @url["https://github.com/lurry-m/tacit"]

@section{Fork}


@defform[(fork1 (first ...) second ...)]{
  Returns the a unary function that applies the first function to the second functions.
    ((fork1 (/) (curry apply +) length))
    (range 10)}