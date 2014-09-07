(defmodule loise-util-tests
  (behaviour ltest-unit)
  (export all))

(include-lib "ltest/include/ltest-macros.lfe")

(defun get-grad (index)
  (loise-util:index (loise-const:gradient-matrix) index))

(deftest get-seed
  (is-equal '#(1 0 0) (loise-util:get-seed 1))
  (is-equal '#(1 0 0) (loise-util:get-seed '(1)))
  (is-equal '#(1 2 0) (loise-util:get-seed '(1 2)))
  (is-equal '#(1 2 3) (loise-util:get-seed '(1 2 3))))

(defun tiny-opts ()
  `(#(width 2) #(height 2)))

(deftest get-ascii-map
  (is-equal
    '(#(0 "A") #(51.0 "^") #(102.0 "n") #(153.0 "*") #(204.0 "~") #(255.0 "~"))
    (loise-util:get-ascii-map (loise-ascii:default-options))))

(deftest get-dimensions
  (is-equal '(56 36) (loise-util:get-dimensions (loise-ascii:default-options)))
  (is-equal '(2 2) (loise-util:get-dimensions (tiny-opts))))

(deftest index
  (is-equal 42 (loise-util:index '(99 4 7 42 13) 3))
  (is-equal '(-1.0 -1.0 0.0) (get-grad 3)))

(deftest dot
  (is-equal 3.0 (loise-util:dot (get-grad 0) 1 2 3))
  (is-equal 1.0 (loise-util:dot (get-grad 1) 1 2 3))
  (is-equal -1.0 (loise-util:dot (get-grad 2) 1 2 3))
  (is-equal 4.0 (loise-util:dot (get-grad 4) 1 2 3)))

(defun do-things (m x y w h)
  (list m x y w h))

(deftest partial
  (let ((func-1 (loise-util:partial #'do-things/5 1))
        (func-2 (loise-util:partial #'do-things/5 '(1 1))))
    (is-equal '(1 1 2 6 24) (funcall func-1 '(1 2 6 24)))
    (is-equal '(1 1 2 6 24) (funcall func-2 '(2 6 24)))))
