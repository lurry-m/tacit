#lang scribble/manual

@(require scribble/eval
          (for-label tacit
                     racket/base
                     racket/contract
                     racket/function
                     racket/list))

@title{Useful Tacit function}

@(define the-eval (make-base-eval))
@(the-eval '(require "main.rkt"
                     racket/function
                     racket/list))

@defmodule[tacit]

@author[@author+email["Laurent Müller" "loeru@pm.me"]]

Useful functions

source code: @url["https://github.com/lurry-m/tacit"]

@section{Fork}


@defform[(fork (first ...) second ...)]{
  Returns the a unary function that applies the all the second arguments to the input and then the first arguments on the result.
     @examples[#:eval the-eval
     (define sum (curry apply +))
     (define average (fork1 (/) sum length))
     (average (range 10))]}

@defform[(fork2 (first ...) second ...)]{
  Returns the a binary function that applies the all the second arguments to the input and then the first arguments on the result.
     @examples[#:eval the-eval
     ((fork2 (list) + *) 5 7)]}