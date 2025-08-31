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
  This can be used in various ways, because the content of the fork is not restricted to procedures.
     @examples[#:eval the-eval
     (define sum (curry apply +))
     (define average (fork (/) sum length))
     (average (range 10))
     (define my-identity (fork () const const))
     (my-identity 5)
     (define positive-even-number? (fork (and) number? positive? even?))
     (map (fork (cons) my-identity positive-even-number?)
          (range 5))
     (define displayln-and-negate
        (fork (begin) displayln -))
     (map displayln-and-negate (range 3))]}

@defform[(fork2 (first ...) second ...)]{
  Returns the a binary function that applies the all the second arguments to the input and then the first arguments on the result.
     @examples[#:eval the-eval
     ((fork2 (list) + * vector) 5 7)]}

@defform[(fork3 (first ...) second ...)]{
  Returns the a ternary function that applies the all the second arguments to the input and then the first arguments on the result.
     @examples[#:eval the-eval
     ((fork3 (list) + * vector) 5 7 11)]}