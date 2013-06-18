(defmodule loise_tests
  (export all)
  (import
    (from lfeunit-util
      (check-failed-assert 2)
      (check-wrong-assert-exception 2))
    (from lfeunit
      (assert 1)
      (assert-not 1)
      (assert-equal 2)
      (assert-not-equal 2)
      (assert-exception 3)
      (assert-error 2)
      (assert-throw 2)
      (assert-exit 2))
    (from erlang
      (integer_to_list 1)
      (round 1))
    (from string
      (join 2))
    (from lists
      (foreach 2)
      (map 2)
      (seq 2)
      (zipwith 3)
      (zipwith3 4))
    (from loise
      (add-tuples 1)
      (dot 4)
      (dot-product 2)
      (fade 1)
      (fast-floor 1)
      (get-gradient-index 3)
      (get-noise-contribution 4)
      (mix 3)
      (perlin 1) (perlin 2) (perlin 3)
      (remainder 2)
      (round 2)
      (simplex 3)
      (vector-ref 2)
      (which-simplex 3))))

(defun list->string (data)
  `(quote
    ,(join
      (map (lambda (x) (integer_to_list x)) data)
      '"")))

(defun add-tuples_test ()
  (let ((data (list (tuple 1 2 3) (tuple 2 3 4))))
    (assert-equal #(1 2 3 2 3 4) (add-tuples data))))

(defun fast-floor_test ()
  (assert-equal 0 (fast-floor 0.0))
  (assert-equal 1 (fast-floor 1.0))
  (assert-equal -5 (fast-floor -4.3))
  (assert-equal 3 (fast-floor 3.1))
  (assert-equal 3 (fast-floor 3.4))
  (assert-equal 3 (fast-floor 3.5))
  (assert-equal 3 (fast-floor 3.9)))

(defun round_test ()
  (assert-equal 2 (round 2 2))
  (assert-equal 2.11 (round 2.11 2))
  (assert-equal 2.11 (round 2.111 2))
  (assert-equal 2.12 (round 2.115 2))
  (assert-equal 2.99985 (round 2.999849 5))
  (let* ((inputs (seq 1 10))
         (results (map (lambda (x) (round (/ x 11) 3)) inputs))
         (expected (list 0.091 0.182 0.273 0.364 0.455
                         0.545 0.636 0.727 0.818 0.909)))
    (zipwith (lambda (a b) (assert-equal a b)) expected results))
  )

(defun vector-ref_test ()
  (assert-equal 42 (vector-ref #(99 4 7 42 13) 3)))

(defun remainder_test ()
  (assert-equal 0 (remainder 5 1))
  (assert-equal 1 (remainder 5 2))
  (assert-equal 2 (remainder 5 3))
  (assert-equal 1 (remainder 5 4))
  (assert-equal 0 (remainder 5 5))
  (assert-equal -2 (remainder -5 3)))

(defun dot-product_test ()
  (assert-equal 32 (dot-product '(1 2 3) '(4 5 6)) )
  (assert-equal 122 (dot-product '(9 2 7) '(4 8 10))))

(defun dot_test ()
  (assert `'true))

(defun mix_test ()
  (assert-equal 4.0 (mix 1 2 3))
  (assert-equal 90010.0 (mix 10 100 1000))
  (assert-equal 11.0 (mix 1 2 10))
  (assert-equal 31.0 (mix 1 2 30))
  (assert-equal 71.0 (mix 1 2 70))
  (assert-equal 1.23 (mix 1.1 1.2 1.3)))

(defun fade_test ()
  (assert-equal 0.103515625 (fade 0.25))
  (assert-equal 0.5 (fade 0.5))
  (assert-equal 0.896484375 (fade 0.75))
  (assert-equal 0.0 (fade 0.0))
  (assert-equal 1.0 (fade 1.0))
  (assert-equal 3.375 (fade 1.5))
  (assert-equal 32.0 (fade 2.0))
  (assert-equal 156.25 (fade 2.5))
  (assert-equal 10625.0 (fade 5.0)))

(defun get-gradient-index_test ()
  (assert-equal 0 (get-gradient-index 0 0 0))
  (assert-equal 2 (get-gradient-index 0 0 1))
  (assert-equal 0 (get-gradient-index 0 1 0))
  (assert-equal 8 (get-gradient-index 0 1 1))
  (assert-equal 7 (get-gradient-index 1 0 0))
  (assert-equal 8 (get-gradient-index 1 0 1))
  (assert-equal 2 (get-gradient-index 1 1 0))
  (assert-equal 3 (get-gradient-index 1 1 1))
  (assert-equal 8 (get-gradient-index 1 10 100))
  (assert-equal 6 (get-gradient-index 100 10 1)))

(defun get-noise-contribution_test ()
  (assert-equal 0 (get-noise-contribution 0 0 0 0))
  (assert-equal 0 (get-noise-contribution 1 0 0 0))
  (assert-equal 0 (get-noise-contribution 1 0 0 1))
  (assert-equal 0 (get-noise-contribution 1 1 1 1))
  (assert-equal 0 (get-noise-contribution 2 1 1 1))
  (assert-equal 2 (get-noise-contribution 4 1 1 1))
  (assert-equal 20 (get-noise-contribution 4 5 10 15))
  (assert-equal 101 (get-noise-contribution 4 1 10 100))
  (assert-equal 2 (get-noise-contribution 8 1 1 1))
  (assert-equal 25 (get-noise-contribution 8 5 10 15))
  (assert-equal 110 (get-noise-contribution 8 1 10 100)))

(defun perlin_test ()
  (assert-equal -0.3772216257243449 (perlin 3.14 1.59 2.65))
  (let ((expected (list 0.0 0.11 0.23 0.37 0.46 0.5 0.46 0.37 0.23 0.11))
        (input (map (lambda (x) (/ x 10)) (seq 0 9))))
    (zipwith
      (lambda (a b)
        (assert-equal a (round (perlin b) 2)))
      expected
      input)))

(defun which-simplex_test ()
  (assert-equal '"100110" (list->string (which-simplex 0 0 0)))
  (assert-equal '"001101" (list->string (which-simplex 0 0 1)))
  (assert-equal '"010110" (list->string (which-simplex 0 1 0)))
  (assert-equal '"010011" (list->string (which-simplex 0 1 1)))
  (assert-equal '"100101" (list->string (which-simplex 1 0 1)))
  (assert-equal '"001011" (list->string (which-simplex 1 2 3)))
  )

(defun simplex_test ()
  (assert-equal -0.3772216257243449 (simplex 3.14 1.59 2.65))

  )
