(defmodule loise-perlin-tests
  (behaviour ltest-unit)
  (export all))

(include-lib "ltest/include/ltest-macros.lfe")

(deftest perlin
  (let ((opts (loise-perlin:options)))
    (is-equal 0.11 (lutil-math:round (loise-perlin:1d 0.1 opts) 2))
    (is-equal 0.2 (lutil-math:round (loise-perlin:2d 0.1 0.1 opts) 2))
    (is-equal 0.01 (lutil-math:round (loise-perlin:2d 0.9 0.9 opts) 2))
    (is-equal 0.25 (lutil-math:round (loise-perlin:2d 0.1 0.2 opts) 2))
    (is-equal -0.14 (lutil-math:round (loise-perlin:3d 0.1 0.2 0.9 opts) 2))))


(deftest perlin-via-api
  (let ((opts (loise-perlin:options)))
    (let ((expected (list 0.0 0.11 0.23 0.37 0.46 0.5 0.46 0.37 0.23 0.11))
          (input (lists:map (lambda (x) (/ x 10)) (lists:seq 0 9))))
      (lists:zipwith
       (lambda (a b)
         (is-equal a (lutil-math:round (loise:perlin b opts) 2)))
       expected
       input))
    (is-equal 0.11 (lutil-math:round (loise:perlin 0.1 opts) 2))
    (is-equal 0.2 (lutil-math:round (loise:perlin 0.1 0.1 opts) 2))
    (is-equal 0.01 (lutil-math:round (loise:perlin 0.9 0.9 opts) 2))
    (is-equal 0.25 (lutil-math:round (loise:perlin 0.1 0.2 opts) 2))
    (is-equal -0.14 (lutil-math:round (loise:perlin 0.1 0.2 0.9 opts) 2))))

(deftest perlin-via-api-without-opts
  (is-equal 0.11 (lutil-math:round (loise:perlin 0.1) 2))
  (is-equal 0.2 (lutil-math:round (loise:perlin 0.1 0.1) 2))
  (is-equal 0.01 (lutil-math:round (loise:perlin 0.9 0.9) 2))
  (is-equal 0.25 (lutil-math:round (loise:perlin 0.1 0.2) 2))
  (is-equal -0.14 (lutil-math:round (loise:perlin 0.1 0.2 0.9) 2)))

(deftest point-without-opts
  (is-equal 0.0
            (lutil-math:round (loise-perlin:point '(0 0) '(256 256) 1) 2))
  (is-equal 0.5
            (lutil-math:round (loise-perlin:point '(127) '(256) 1) 2))
  (is-equal 0.56
            (lutil-math:round (loise-perlin:point '(127 64) '(256 256) 1) 2))
  (is-equal 0.49
            (lutil-math:round
             (loise-perlin:point '(127 64 32) '(256 256 256) 1) 2)))
