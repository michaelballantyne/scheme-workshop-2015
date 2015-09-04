(load "scheme.scm")
(load "mk/test-check.scm")

(test "backwards"
  (run 10 (q)
     (evalo `(letrec ([ones (lambda (l)
                              (match l
                                [`() #t]
                                [`(1 . ,r)
                                  (twos r)]
                                [else #f]))]
                      [twos (lambda (l)
                              (match l
                                [`() #t]
                                [`(2 . ,r)
                                  (ones r)]
                                [else #f]))])
               (ones (quote ,q)))
            #t))
  '(() (1) (1 2) (1 2 1) (1 2 1 2) (1 2 1 2 1) (1 2 1 2 1 2) (1 2 1 2 1 2 1) (1 2 1 2 1 2 1 2) (1 2 1 2 1 2 1 2 1)))

(test "not matching"
  (run 10 (q)
     (evalo `(letrec ([ones (lambda (l)
                              (match l
                                [`() #t]
                                [`(1 . ,r)
                                  (twos r)]
                                [else #f]))]
                      [twos (lambda (l)
                              (match l
                                [`() #t]
                                [`(2 . ,r)
                                  (ones r)]
                                [else #f]))])
               (ones (quote ,q)))
            #f))
  '((_.0 (num _.0)) (_.0 (=/= ((_.0 closure))) (sym _.0)) #f #t ((_.0 . _.1) (=/= ((_.0 1))) (absento (closure _.0) (closure _.1))) ((1 . _.0) (num _.0)) ((1 . _.0) (=/= ((_.0 closure))) (sym _.0)) (1 . #f) (1 . #t) ((1 _.0 . _.1) (=/= ((_.0 2))) (absento (closure _.0) (closure _.1)))))

(test "multiple examples"
  (run 1 (q)
     (evalo `(letrec ([ones (lambda (l)
                              (match l
                                [`() #t]
                                [`(1 . ,r)
                                  (twos r)]
                                [else #f]))]
                      [twos (lambda (l)
                              (match l
                                [`() #t]
                                [`(2 . ,r)
                                  (ones r)]
                                [else #f]))])
               (list (ones '(1))
                     (ones '(1 2 1))
                     (ones '(1 2 1 2 1 2 1 2))
                     (ones '(1 2 3))
                     (ones '(2 1 2))))
            '(#t #t #t #f #f)))
  '(_.0))

(test "synthesizing a bit"
  (run 1 (a b)
       (evalo `(letrec ([ones (lambda (l)
                                (match l
                                  [`() #t]
                                  [`(1 . ,r)
                                    (,a r)]
                                  [else #f]))]
                        [twos (lambda (l)
                                (match l
                                  [`() #t]
                                  [`(2 . ,r)
                                    (,b r)]
                                  [else #f]))])
                 (list (ones '(1))
                       (ones '(1 2 1))
                       (ones '(1 2 1 2 1 2 1 2))
                       (ones '(1 2 3))
                       (ones '(2 1 2))))
              '(#t #t #t #f #f)))
  '((twos ones)))


; Too slow. :(
;
;(run 1 (q)
     ;(evalo `(letrec ([ones (lambda (l)
                              ;(match l
                                ;[`() #t]
                                ;[`(1 . ,r)
                                  ;(twos r)]
                                ;[else #f]))]
                      ;[twos (lambda (l)
                              ;,q)])
               ;(list (ones '(1 2))
                     ;(ones '(1 3 1 4))
                     ;(ones '(1 4))
                     ;(ones '(1 2 1 2 1 2 1 2))
                     ;(ones '(1 2 1 2 1 3))))
            ;'(#t #f #f #t #f)))

