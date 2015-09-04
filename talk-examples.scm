(define my-append
  (lambda (l s)
    (cond
      ((null? l) s)
      (else (cons (car l) (my-append (cdr l) s))))))


(define appendo
  (lambda (l s out)
    (conde
      ((== '() l) (== s out))
      ((fresh (a d res)
         (== `(,a . ,d) l)
         (== `(,a . ,res) out)
         (appendo d s res))))))










(letrec ((append (lambda (l s)
                   (if (null? l)
                       s
                       (cons (car l) (append (cdr l) s))))))
  (append '(a b c) '(d e)))


;; Forward

;; We are asking the proof checker to check our proof of C, using the
;; assumptions A, A => B, and B => C.  Note that we give the entire
;; proof tree as the input to 'proof?'.

; A
; A -> B
; ------
; B

(run* (q)
  (eval-expo
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
        (proof? '(modus-ponens
                  (A (if A B) (if B C))
                  ((assumption (A (if A B) (if B C)) () (if B C))
                   (modus-ponens
                    (A (if A B) (if B C))
                    ((assumption (A (if A B) (if B C)) () (if A B))
                     (assumption (A (if A B) (if B C)) () A)) B))
                  C))))
   '()
   q))




;; The real test!  We are no longer unifying 'prf' with the answer.
;; The proof checker is now inferring the proof tree for the theorem
;; we are trying to prove (C) given a set of assumptions (A, A => B,
;; and B => C).  The proof checker *function* is now acting as a
;; *relation*, which lets us use it as a theorem prover.

(run 1 (prf)
  (fresh (rule assms ants)
    ;; We want to prove that C holds...
    (== `(,rule ,assms ,ants C) prf)
    ;; ...given the assumptions A, A => B, and B => C.
    (== `(A (if A B) (if B C)) assms)
    (eval-expo
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
     '()
     #t)))


; WHILE

(run 1 (alpha beta gamma)
    (fresh (s)
      (->o
       `(,symbolic-exec-prog-1
         ((a . (num ,alpha))
          (b . (num ,beta))
          (c . (num ,gamma))))
       `(abort ,s))))
(((() ; 0
   (0 0 1) ; 4
   _.0) ; positive int
  (=/= ((_.0 ()))) (absento (abort _.0))))




;;; symbolic execution example from slide 7 of Stephen Chong's slides
;;; on symbolic execution (contains contents from Jeff Foster's
;;; slides)
;;;
;;; http://www.seas.harvard.edu/courses/cs252/2011sp/slides/Lec13-SymExec.pdf

;;;  1. int a = α, b = β, c = γ
;;;  2.             // symbolic
;;;  3. int x = 0, y = 0, z = 0;
;;;  4. if (a) {
;;;  5.   x = -2;
;;;  6. }
;;;  7. if (b < 5) {
;;;  8.   if (!a && c)  { y = 1; }
;;;  9.   z = 2;
;;; 10. }
;;; 11. assert(x+y+z!=3)

;;; we will model the 'assert' using 'if' and 'abort'


;;; Slightly modified version that we are actually modelling:

;;;  1. int a = α, b = β, c = γ
;;;  2.             // symbolic
;;;  3. int x = 0, y = 0, z = 0;
;;;  4. if (a) {
;;;  5.   x = 5;
;;;  6. }
;;;  7. if (b <= 4) {
;;;  8.   if (!a && c)  { y = 1; }
;;;  9.   z = 2;
;;; 10. }
;;; 11. assert(x+y+z!=3)

;;;  1. int a := α, b := β, c := γ
;;;  4. if !(a = 0) {
;;;  5.   x := 5;
;;;  6. }
;;;  7. if (b <= 4) {
;;;  8.   if ((a = 0) && !(c = 0))  { y := 1; }
;;;  9.   z := 2;
;;; 10. }
;;; 11. if !(x+(y+z) = 3) {
;;;       abort
;;;     }


(define symbolic-exec-prog-1
  `(seq
     (if (not (= ,(num 0) a))
         (:= x ,(num 5)) ;; lol negative numbers!
         (skip))
     (seq
       (if (<= b ,(num 4)) ;; might want to use numbero to automatically convert numbers to Oleg form
           (seq
             (if (and (= ,(num 0) a)
                      (not
                        (= ,(num 0) c)))
                 (:= y ,(num 1))
                 (skip))
             (:= z ,(num 2)))
           (skip))
       (if (= (+ x (+ y z)) ,(num 3))
           (abort)
           (skip)))))

(run 1 (alpha beta gamma)
  (fresh (s)
    (->o
     `(,symbolic-exec-prog-1
       ((a . (num ,alpha))
        (b . (num ,beta))
        (c . (num ,gamma))))
     `(abort ,s))))
