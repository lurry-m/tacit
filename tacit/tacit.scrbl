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

source code: @url["https://github.com/lurry-m/tacit"]

@section{The different variant of the fork-macros}

These macros are inspired by @hyperlink["https://en.wikipedia.org/wiki/Tacit_programming#APL_family"]{@italic{APL (J)}}.


@defform[(fork (first ...) second ...)]{
 Returns the a unary function that applies the all the second arguments to the input and then the first arguments on the result.
 @racket[fork] can be used in various ways, because the content of the fork is not restricted to procedures. 
  
 This is the coolest macro according to the author.
 @examples[#:eval the-eval
           (define sum (curry apply +))
           (define average (fork (/) sum length))
           (average (range 10))
           (define euler-form (fork (make-rectangular) cos sin))
           (euler-form 3.141592653589793)
           (define my-identity (fork () const const))
           (my-identity 5)
           (define positive-even-number? (fork (and) number? positive? even?))
           (map (fork (cons) my-identity positive-even-number?)
                (range 5))
           (define displayln-and-negate
             (fork (begin) displayln -))
           (map displayln-and-negate (range 3))]}

@defform[(fork2 (first ...) second ...)]{
 Similar to  @racket[fork], returns the a binary function that applies the all the second arguments to the input and then the first arguments on the result.
 @examples[#:eval the-eval
           ((fork2 (list) + * vector) 5 7)]}

@defform[(fork3 (first ...) second ...)]{
 Similar to  @racket[fork], returns the a ternary function that applies the all the second arguments to the input and then the first arguments on the result.
 @examples[#:eval the-eval
           ((fork3 (list) + * vector) 5 7 11)]}

@defform[(fork* (first ...) second ...)]{
 Similar to  @racket[fork], but the @racket[procedure-arity] is identical to the arguments provided in @racket[second].
 @examples[#:eval the-eval
           (define (sqr x) (* x x))
           (define sqr-and-subtract (fork* (-) sqr sqr sqr))
           (procedure-arity sqr-and-subtract)
           (define pythagorean-triple? (compose zero? sqr-and-subtract))
           (pythagorean-triple? 5 4 3)
           (pythagorean-triple? 6 4 3)]}