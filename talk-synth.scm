; based on "Type-and-example-directed program synthesis"
; by 	Peter-Michael Osera	and Steve Zdancewic (http://dl.acm.org/citation.cfm?id=2738007)

; E = symbol | E I
; I includes everything else
;
; E is expected at match and (if (= E E) ...)



; Definition of append in the typed language. Note that `list` is the type of
; proper lists of numbers, match just pulls apart car and cdr or nil,
; and that our interpreter doesn't have the list constructor.

(run 1 (q)
     (evalo
       `(letrec ((append (lambda (l s) : ((list list) -> list)
                           (match l
                             ['() s]
                             [(cons a d) (cons a (append d s))]))))
          (append (cons 1 '()) (cons 2 (cons 3 '()))))
       q))









; Let's try inferring the function! But... we get an overspecialized answer.

(run 1 (q)
     (evalo
       `(letrec ((append (lambda (l s) : ((list list) -> list)
                           ,q)))
          (append (cons 1 '()) (cons 2 (cons 3 '()))))
       '(1 2 3)))








; More examples?

(let ([example (lambda (q l1 l2 out)
                 (evalo
                   `(letrec ((append (lambda (l s) : ((list list) -> list)
                                       ,q)))
                      (append ,l1 ,l2))
                   out))])
 (run 1 (q)
      (example q
               '(cons 1 '())
               '(cons 2 (cons 3 '()))
               '(1 2 3))
      (example q
               '(cons 5 (cons 1 (cons 2 (cons 3 '()))))
               '(cons 1 '())
               '(5 1 2 3 1))))









; How about an example for the base case?

(let ([example (lambda (q l1 l2 out)
                 (evalo
                   `(letrec ((append (lambda (l s) : ((list list) -> list)
                                       ,q)))
                      (append ,l1 ,l2))
                   out))])
 (run 1 (q)
      ; Base case
      (example q
               ''()
               '(cons 2 (cons 3 '()))
               '(2 3))
      ; Simple recursive case
      (example q
               '(cons 1 '())
               '(cons 2 (cons 3 '()))
               '(1 2 3))
      ; Big enough to prevent overspecialization
      (example q
               '(cons 5 (cons 1 (cons 2 (cons 3 '()))))
               '(cons 1 '())
               '(5 1 2 3 1))))










