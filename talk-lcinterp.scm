; Scheme meta-circular interpreter defined using higher-order functions

(run* (q)
      (evalo
        `(letrec ((eval-expr
                   (lambda (expr env)
                     (match expr
                       [(? number? n) n]
                       [(? symbol? x) (env x)]
                       [`(lambda (,(? symbol? x)) ,body)
                        (lambda (a)
                          (eval-expr body (lambda (y)
                                            (if (equal? x y)
                                                a
                                                (env y)))))]
                       [`(,rator ,rand)
                        ((eval-expr rator env) (eval-expr rand env))]))))

           (eval-expr '(((lambda (y) y) (lambda (z) z)) 5) ; expr

                      (lambda (y) ; initial env evaluates omega
                        ((lambda (x) (x x)) (lambda (x) (x x))))))
       q))




; Can we leave out part of the interpreter?

(run 1 (q)
      (evalo
       `(letrec
            ((eval-expr
              (lambda (expr env)
                (match expr
                  [(? number? n) n]
                  [(? symbol? x) (env x)]
                  [`(lambda (,(? symbol? x)) ,body)
                   (lambda (a)
                     (eval-expr body (lambda (y)
                                       (if (equal? x y)
                                           a
                                           (env y)))))]
                  [`(,rator ,rand)
                   ((eval-expr rator env) (eval-expr rand env))]))))
          (letrec
              ((eval (lambda (expr)
                       (eval-expr expr
                                  (lambda (y) ; initial environment
                                    ((lambda (x) (x x)) (lambda (x) (x x))))))))

            (cons (eval '(((lambda (x) (lambda (y) x)) 5) (lambda (z) z)))
                  (eval '(((lambda (w) (w w)) (lambda (v) v)) 6)))))

       '(5 . 6)))






