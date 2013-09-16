(define (abs x) (if (< x 0) (- x) x))
(define (positive? x) (> x 0))
(define (negative? x) (< x 0))
(define (odd? n) (logbit? 0 n))
(define (even? n) (not (odd? n)))
(define (newline) (display "\n"))

(define (gcd a b)
  (if (= b 0)
    a
    (gcd b (remainder a b))))

(define (list-ref items n)
  (if (= n 0)
    (car items)
    (list-ref (cdr items) (- n 1))))

(define (length items)
  (if (null? items)
    0
    (+ 1 (length (cdr items)))))

(define (append lst1 lst2)
  (if (null? lst1)
    lst2
    (cons (car lst1) (append (cdr lst1) lst2))))

(define (map proc items)
  (if (null? items)
    ()
    (cons (proc (car items))
	  (map proc (cdr items)))))

(define (for-each proc items)
  (cond ((null? items) (undefined))
	(else (proc (car items)) (for-each proc (cdr items)))))
