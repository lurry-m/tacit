#lang racket

(provide (all-defined-out))

(define-syntax-rule
  (define-syntax-case*
    (identifier args ...)
    (transformer ...))
  (define-syntax (identifier stx)
    (syntax-case stx ()
      [(identifier args ...)
       #'(transformer ...)])))

(define-syntax-rule
  (define-syntax-case
    (identifier args ...)
    (transformer ...))
  (define-syntax (identifier stx)
    (syntax-case stx ()
      [(identifier args ...)
       (transformer ...)])))

(define-syntax-rule
  (fork1 (first ...) second ...)
  (lambda (x) (first ... (second x) ...)))

(define-syntax-rule
  (fork2 (first ...) second ...)
  (lambda (x y) (first ... (second x y) ...)))

(define-syntax-rule
  (fork (first ...) second ...)
  (lambda x (first ... (apply second x) ...)))

(define-syntax-case
  (fork* (first ...) second ...)
  (with-syntax ([(x ...) (generate-temporaries #'(second ...))])
    #'(lambda (x ...) (first ... (second x) ...))))

(define-syntax-rule
  (eval-with-values function my-values)
  (call-with-values (lambda () my-values) function))

(define-syntax-rule (my-require (evaluator) content ...)
  (begin (require content ... (for-label content ...))
         (define evaluator (make-base-eval))
         (evaluator '(require content ...))))

(begin-for-syntax
  (define (append-syntax stx identifier append-string)
    (datum->syntax
     stx
     (string->symbol
      (format "~a-~a" (syntax->datum identifier) append-string)))))

(define-syntax (define-vector stx)
  (syntax-case stx ()
    [(_ identifier args)
     (with-syntax ([set! (append-syntax stx #'identifier "set!")]
                   [ref (append-syntax stx #'identifier "ref")]
                   [update! (append-syntax stx #'identifier "update!")]
                   [length (append-syntax stx #'identifier "length")])
       #'(begin
           (define identifier args)
           (unless (vector? identifier)
             (error (format "The object ~a=~a is not a vector!" 'identifier identifier)))
           (define (set! x y)
             (vector-set! identifier x y))
           (define (ref x)
             (vector-ref identifier x))
           (define (update! x y)
             (vector-set! identifier x (y (vector-ref identifier x))))
           (define (length) (vector-length identifier))))]))

(define-syntax (define-mutable-hash stx)
  (syntax-case stx ()
    [(_ identifier args)
     (with-syntax ([set! (append-syntax stx #'identifier "set!")]
                   [ref (append-syntax stx #'identifier "ref")]
                   [map (append-syntax stx #'identifier "map")]
                   [for-each (append-syntax stx #'identifier "for-each")]
                   [ref! (append-syntax stx #'identifier "ref!")]
                   [update! (append-syntax stx #'identifier "update!")]
                   [count (append-syntax stx #'identifier "count")]
                   [has-key? (append-syntax stx #'identifier "has-key?")]
                   [ref-default (append-syntax stx #'identifier "ref-default")])
       #'(begin
           (define identifier args)
           (unless (and (hash? identifier)
                        (not (immutable? identifier)))
             (error (format "The object ~a=~a is not a mutable hash!" 'identifier identifier)))
           (define (set! x y)
             (hash-set! identifier x y))
           (define ref
             (case-lambda
               ((x) (hash-ref identifier x))
               ((x y) (hash-ref identifier x y))))
           (define (map x)
             (hash-map identifier x))
           (define (for-each x)
             (hash-for-each identifier x))
           (define (ref! x y)
             (hash-ref! identifier x y))
           (define (update! x y)
             (hash-update! identifier x y))
           (define (count)
             (hash-count identifier))
           (define (has-key? x)
             (hash-has-key? identifier x))
           (define ((ref-default my-default) x)
             (hash-ref identifier x my-default))))]))
