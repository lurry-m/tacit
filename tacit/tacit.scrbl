#lang scribble/manual

@(require scribble/eval
          (for-label tacit
                     racket/base
                     racket/contract
                     racket/function
                     racket/list
                     math/base))

@title{Useful Tacit function}

@(define the-eval (make-base-eval))
@(the-eval '(require "main.rkt"
                     racket/contract
                     racket/function
                     racket/list
                     math/base))

@defmodule[tacit]

@author[@author+email["Laurent Müller" "loeru@pm.me"]]

source code: @url["https://github.com/lurry-m/tacit"]

@section{The different variant of the fork-macros}

These macros are inspired by @hyperlink["https://en.wikipedia.org/wiki/Tacit_programming#APL_family"]{APL (J)}.


@defform[(fork (first ...) second ...)]{
 Returns the a unary function that applies the all the second arguments to the input and then the first arguments on the result.
 @racket[fork] can be used in various ways, because the content of the fork is not restricted to procedures. 
  
 @examples[#:eval the-eval
           (define average (fork (/) sum length))
           (average (range 10))
           (define euler-form (fork (make-rectangular) cos sin))
           (euler-form 3.141592653589793)
           (define positive-even-number? (fork (and) number? positive? even?))
           (map (fork (cons) identity positive-even-number?)
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
           (define sqr-and-subtract (fork* (-) sqr sqr sqr))
           (procedure-arity sqr-and-subtract)
           (define pythagorean-triple? (compose zero? sqr-and-subtract))
           (pythagorean-triple? 5 4 3)
           (pythagorean-triple? 6 4 3)]}


@section{Syntactic sugar for mutable objects}

Vectors and hashes are useful but they can be a bit verbose. These two definitions provide a few helpful 
procedures out of the box wich are similar to @racket[struct].

@defform[(define-vector identifier my-vector)]{
 This will create a few extra procedures, which might be useful. These are @racket[identifier-set!],
 @racket[identifier-ref], @racket[identifier-update!], @racket[identifier++], @racket[identifier--] and  
 @racket[identifier-length].

 @examples[#:eval the-eval
           (define-vector v (make-vector 5 5))
           (v-set! 1 17)
           (v-ref 1)
           (v-update! 2 sqr)
           (v++ 3)
           (v-- 4)
           (v-length)
           v]}

@defform[(define-mutable-hash identifier my-hash)]{
 This will create a few extra procedures, which might be useful. These are 
 @racket[identifier-set!], @racket[identifier-ref], @racket[identifier-ref!], 
 @racket[identifier-update!], @racket[identifier++], @racket[identifier--], 
 @racket[identifier-count], @racket[identifier-map] and @racket[identifier-for-each] and  @racket[identifier-has-key?].

 @examples[#:eval the-eval
           (define-mutable-hash ht (make-hash (list (cons 1 1) (cons 2 2))))
           (ht-set! 3 30)
           (procedure-arity ht-ref)
           (ht-ref 3)
           (ht-ref 4 16)
           (ht-ref! 4 12)
           (ht-ref 4 16)
           (ht-update! 3 sqr)
           (ht++ 1)
           (ht-- 2)
           (ht-count)
           (ht-map cons)
           (ht-for-each (compose displayln list))
           (ht-has-key? 5)
           ht]}

@section{Showcase: Y-Combinator}

The @racket[fork]-macro is actually similar to the @racket[S] function in 
the @hyperlink["https://en.wikipedia.org/wiki/SKI_combinator_calculus"]{SKI-calculus}.

@examples[#:eval the-eval
          (define K const)
          (define I (fork () K K))
          (define P
            (fork (fork (fork ()) K) K))
          (define C
            (fork (fork (fork ()))
                  (fork (K) K)
                  (K I)))
          (define E
            (fork (fork (I))
                  (fork () I I)))

          (I 5)    
          (((P add1) sqr) 10)
          (((C add1) sqr) 10)

          (define Y ((C E) (P E)))]

Then we can define a factorial function like that:

@examples[#:eval the-eval
          (define fac
            (fork (fork (if) zero? add1)
                  (fork (fork (*) I)
                        (P sub1))))
          ((Y fac) 5)]

Alternatively, the fibonacci function:

@examples[#:eval the-eval
          (define fib
            (fork (fork (if)
                        (fork (or) zero? ((C zero?) sub1))
                        I)
                  (fork (fork (+))
                        (P sub1)
                        (P ((C sub1) sub1)))))
          (map (Y fib) (range 10))]

@section{Showcase: Easy Racket}

This section is inspired by an article of @hyperlink["https://wiki.jsoftware.com/wiki/Vocabulary/Unreadability"]{The alleged unreadability of J}.
The last section showcased some of the power of the @racket[fork], but it is barely readable. Here is a showcase of how it can also
be used to make the code more readable, especially in combination with contracts.

@examples[#:eval the-eval
          (struct triangle (a b c))
          (define the identity)
          (define on identity)
          (define of identity)
          (define squares (curry map sqr))
          (define hypotenuse triangle-c)
          (define other-two-sides (fork (list) triangle-a triangle-b))
          (define are-equal? =)
          (define calculate compose)
          (define/contract triangle-is-pythagorean?
            (-> triangle? boolean?)
            (fork (are-equal?)
                  (calculate the sqr on the hypotenuse)
                  (calculate the sum of the squares on the other-two-sides)))
          (triangle-is-pythagorean? (triangle 3 4 5))
          (triangle-is-pythagorean? (triangle 3 4 6))]