(load "mk/test-check.scm")
(load "scheme.scm")

(define member? (lambda (x ls) (not (not (member x ls)))))

(time
  (test "append-synthesize-and-run-backwards-1"
    (run 1 (x y)
        (evalo
         `(letrec ((append (lambda (l s)
                             (if (null? l)
                                 s
                                 (cons ,x (append (cdr l) s))))))
            (list (append ,y '(h i j))
                  (append '(a b c) '(d e))))
         `((f g h i j)
           (a b c d e))))
    '(((car l) '(f g)))))


(test "append-variable-in-s-position-cheating-1"
  (run 5 (q)
    (evalo
     `(letrec ((append (lambda (l s)
                         (if (null? l)
                             ,q
                             (cons (car l) (append (cdr l) s))))))
        (append '(a b c) '(d e)))
     '(a b c d e)))
  '(s (quote (d e)) (list (quote d) (quote e)) ((lambda () s)) ((lambda () (quote (d e))))))



(let ()

  (define (rember x ls)
    (if (null? ls)
        '()
        (if (equal? (car ls) x)
            (cdr ls)
            (cons (car ls) (rember x (cdr ls))))))

  (printf "rember, in Scheme\n")

  (time
    (test "rember-1"
      (rember 'b '(a b c b d))
      '(a c b d)))
  )

(let ()

  ;; rembero, bad goal ordering
  (define (rembero x ls out)
    (conde
      ((== '() ls) (== '() out))
      ((fresh (a d)
         (== (cons a d) ls)
         (conde
           ((== a x) (== d out))
           ((fresh (res)
              (=/= a x)
              (rembero x d res)
              (== (cons a res) out))))))))

  (printf "rembero, bad goal ordering\n")

  (time
    (test "rembero forward, bad goal ordering"
      (run* (q) (rembero 'b '(a b c b d) q))
      '((a c b d))))  

  (time
    (test "rembero infer first arg, bad goal ordering"
      (run* (q) (rembero q '(a b c b d) '(a c b d)))
      '(b)))

  (time
    (test "rembero infer second arg, run3, bad goal ordering"
      (run 3 (q) (rembero 'b q '(a c b d)))
      '((b a c b d) (a b c b d) (a c b b d))))

  ;; (time
  ;;   ;; diverges
  ;;   (test "rembero infer second arg, run*, bad goal ordering"
  ;;     (run* (q) (rembero 'b q '(a c b d)))
  ;;     '((b a c b d) (a b c b d) (a c b b d))))

  )

(let ()

  ;; rembero, good goal ordering
  (define (rembero x ls out)
    (conde
      ((== '() ls) (== '() out))
      ((fresh (a d)
         (== (cons a d) ls)
         (conde
           ((== a x) (== d out))
           ((fresh (res)
              (=/= a x)
              (== (cons a res) out)
              (rembero x d res))))))))

  (printf "rembero, good goal ordering\n")

  (time
    (test "rembero forward, good goal ordering"
      (run* (q) (rembero 'b '(a b c b d) q))
      '((a c b d))))  

  (time
    (test "rembero infer first arg, good goal ordering"
      (run* (q) (rembero q '(a b c b d) '(a c b d)))
      '(b)))
  
  (time
    (test "rembero infer second arg, run3, good goal ordering"
      (run 3 (q) (rembero 'b q '(a c b d)))
      '((b a c b d) (a b c b d) (a c b b d))))

  (time
    (test "rembero infer second arg, run*, good goal ordering"
      (run* (q) (rembero 'b q '(a c b d)))
      '((b a c b d) (a b c b d) (a c b b d))))  

  )

(time
  (test "rember - generate one expression that evaluates to the list (b b d)"
    (run 1 (q)
      (evalo `(letrec ((rember
                        (lambda (x ls)
                          (if (null? ls)
                              '()
                              (if (equal? (car ls) x)
                                  (cdr ls)
                                  (cons (car ls) (rember x (cdr ls))))))))
                (rember 'b ,q))
             '(b d)))
    '('(b b d))))


(define rember-hundred-ls
  (begin
    (printf "rember - generating one hundred answers that evaluate to the list (b b d)\n")
    (printf "this takes a minute...\n")
    (time (run 100 (q)
            (evalo `(letrec ((rember
                              (lambda (x ls)
                                (if (null? ls)
                                    '()
                                    (if (equal? (car ls) x)
                                        (cdr ls)
                                        (cons (car ls) (rember x (cdr ls))))))))
                      (rember 'b ,q))
                   '(b d))))))

(time
  (test "emulate rembero, run*"
    (run* (q)
      (evalo `(letrec ((rember
                        (lambda (x ls)
                          (if (null? ls)
                              '()
                              (if (equal? (car ls) x)
                                  (cdr ls)
                                  (cons (car ls) (rember x (cdr ls))))))))
                (rember 'b ',q))
             '(b d)))
    '((b b d))))

(time
  (test "rember - synthesize outer if test"
    (run 1 (q)
      (evalo `(letrec ((rember
                        (lambda (x ls)
                          (if ,q
                              '()
                              (if (equal? (car ls) x)
                                  (cdr ls)
                                  (cons (car ls) (rember x (cdr ls))))))))
                (list (rember 'a '(b)) 
                      (rember 'd '(c d e d f))))
             '((b)
               (c e d f))))
    '((null? ls))))



;(exit)
(time
  (test "proof-backwards-explicit-member?"
    (run 1 (prf)
      (fresh (rule assms ants)
        ;; We want to prove that C holds...
        (== `(,rule ,assms ,ants C) prf)
        ;; ...given the assumptions A, A => B, and B => C.
        (== `(A (if A B) (if B C)) assms)
        (evalo
          `(letrec ((member? (lambda (x ls)
                               (if (null? ls)
                                   #f
                                   (if (equal? (car ls) x)
                                       #t
                                       (member? x (cdr ls)))))))
             (letrec ((proof? (lambda (proof)
                                (match proof
                                  [`(assumption ,assms () ,A)
                                   (member? A assms)]
                                  [`(modus-ponens
                                     ,assms
                                     ((,r1 ,assms ,ants1 (if ,A ,B))
                                      (,r2 ,assms ,ants2 ,A))
                                     ,B)
                                   (and (proof? (list r1 assms ants1 (list 'if A B)))
                                        (proof? (list r2 assms ants2 A)))]))))
               (proof? ',prf)))
         #t)))
    '((modus-ponens (A (if A B) (if B C))
                    ((assumption (A (if A B) (if B C)) () (if B C))
                     (modus-ponens (A (if A B) (if B C))
                                   ((assumption (A (if A B) (if B C)) () (if A B))
                                    (assumption (A (if A B) (if B C)) () A))
                                   B))
                    C))))


(time
  (test "HO CBV LC - identity 1"
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
    '(5)))


#|
(time
  (test "HO CBV LC - divergent due to looking up unbound variable"
    (run 1 (q)
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
           (eval-expr '(((lambda (y) w) (lambda (z) z)) 5) ; expr
                      (lambda (y) ; initial env evaluates omega
                        ((lambda (x) (x x)) (lambda (x) (x x))))))
       q))))
|#

(time
  (test "HO CBV LC - symbol? match guard example-based synthesis 1"
    (run 1 (q)
      (evalo
       `(letrec
            ((eval-expr
              (lambda (expr env)
                (match expr
                  [(? number? n) n]
                  [,q (env x)]
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
    '((? symbol? x))))

(exit)
