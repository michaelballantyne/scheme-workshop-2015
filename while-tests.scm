(load "mk/test-check.scm")
(load "mk/extras/numbers.scm")
(load "while.scm")

(time
  (test "symbolic-execution"
    (run 1 (alpha beta gamma)
      (fresh (s)
        (->o
          `((seq
             (if (not (= ,(num 0) a))
                 (:= x ,(num 5))
                 (skip))
             (seq
              (if (<= b ,(num 4))
                  (seq
                   (if (and (= ,(num 0) a) (not (= ,(num 0) c)))
                       (:= y ,(num 1))
                       (skip))
                   (:= z ,(num 2)))
                  (skip))
              (if (= (+ x (+ y z)) ,(num 3))
                  (raise)
                  (skip))))
            ((a . ,alpha)
             (b . ,beta)
             (c . ,gamma)))
          `(exn ,s))))
    '((((num ())                              ; alpha = 0
        (num (0 0 1))                         ; beta = 4
        (num _.0))                            ; gamma != 0
       (=/= ((_.0 ())))
       (absento (exn _.0))))))

(define fact
  `(seq (:= y ,(num 1))
        (while (and (not (= x ,(num 0)))
                    (not (= x ,(num 1))))
          (seq (:= y (* y x))
               (:= x (- x ,(num 1)))))))

(time
  (test "fact-5"
    (run* (q)
      (->o `(,fact ((x . ,(num 5))))
           q))
    `(((y . ,(num 120))
       (x . ,(num 1))))))

(time
  ;; run 2 diverges
  (test "fact-5-backwards"
    (run 1 (q)
      (->o `(,fact ((x . ,q)))
           `((y . ,(num 120))
             (x . ,(num 1)))))
    `(,(num 5))))

(time
  (test "fact 13c-no-absento-multiple-calls-g"
    (run 1 (q)
      (fresh (prog)
        (== `(seq (:= y ,(num 1))
                  (while ,q
                    (seq (:= y (* y x))
                         (:= x (- x ,(num 1))))))
            prog)
        (->o `(,prog
               ((x . ,(num 2))))
             `((y . ,(num 2))
               (x . ,(num 1))))
        (->o `(,prog
               ((x . ,(num 3))))
             `((y . ,(num 6))
               (x . ,(num 1))))
        (->o `(,prog
               ((x . ,(num 4))))
             `((y . ,(num 24))
               (x . ,(num 1))))
        (->o `(,prog
               ((x . ,(num 0))))
             `((y . ,(num 1))
               (x . ,(num 0))))
        (->o `(,prog
               ((x . ,(num 1))))
             `((y . ,(num 1))
               (x . ,(num 1))))
        ))
    `((<= ,(num 2) x))))

(time
  (test "fact-test-synthesis-only-two-examples"
    (run 1 (q)
      (fresh (prog)
        (== `(seq (:= y ,(num 1))
                  (while ,q
                    (seq (:= y (* y x))
                         (:= x (- x ,(num 1))))))
            prog)
        (->o `(,prog ((x . ,(num 0))))
             `((y . ,(num 1)) (x . ,(num 0))))
        (->o `(,prog ((x . ,(num 4))))
             `((y . ,(num 24)) (x . ,(num 1))))))    
    '((<= (num (0 1)) x))))

(exit)
