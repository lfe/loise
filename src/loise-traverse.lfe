(defmodule loise-traverse
  (export all))

(defun sup () 'loise-traver-sup)
(defun default-start-point () #(0 0))
(defun default-count () 100)
(defun default-type () 'random-neighbor)
(defun default-radius () 1)
(defun default-include-center? () 'false)

(defun options ()
  (options #m()))

(defun options (overrides)
  (maps:merge `#m(start ,(default-start-point)
                  end undefined
                  count ,(default-count)
                  type ,(default-type)
                  duration undefined
                  radius ,(default-radius)
                  include-center? ,(default-include-center?))
              overrides))

(defun neighbors (point opts)
  (let ((result (lists:map (lambda (p) (neighbor-check point p opts))
                           (lists:flatten
                            (neighbors point (mref opts 'radius) opts)))))
    (lists:filter (lambda (r) (not (== r 'false)))
                  (lists:usort result))))

(defun neighbors
  (((= `#(,x ,y) point) radius opts)
   (let ((center? (maps:get 'include-center? opts (default-include-center?))))
     (list-comp ((<- xn (lists:seq (- x radius) (+ x radius))))
       (list-comp ((<- yn (lists:seq (- y radius) (+ y radius))))
         (let ((pn `#(,xn ,yn)))
           (if (and (== pn point) (not center?))
             'false
             pn)))))))

(defun neighbor-check
  ((center point _) (when (== center point))
   'false)
  ((p0 `#(,x ,y) opts) (when (< x 0))
   (neighbor-check p0 `#(0 ,y) opts))
  ((p0 `#(,x ,y) opts) (when (< y 0))
   (neighbor-check p0 `#(,x 0) opts))
  ((p0 `#(,x ,y) (= `#m(width ,w) opts)) (when (>= x w))
   (neighbor-check p0 `#(,(- w 1) ,y) opts))
  ((p0 `#(,x ,y) (= `#m(height ,h) opts)) (when (>= y h))
   (neighbor-check p0 `#(,x ,(- h 1)) opts))
  ((_ point _) point))

(defun random-step
  ((_ `#(,acc ,p1 ,st1 ,opts))
   (let* ((neighbs (neighbors p1 opts))
          (`#(,p2 ,st2) (loise-rand:choose neighbs st1)))
     `#(,(cons p2 acc) ,p2 ,st2 ,opts))))

(defun random-walk (point opts)
  (let* ((count (mref opts 'count))
         (st0 (loise-rand:state opts))
         (`#(,steps ,_ ,st1 ,_) (lists:foldl #'random-step/2
                                             `#(() ,point ,st0 ,opts)
                                             (lists:seq 1 count))))
    (loise-rand:set-state st1)
    steps))

(defun brownian (layer-name)
  (brownian layer-name #m(type random-neighbor)))

(defun brownian (layer-name overrides)
  (let ((`#(ok ,pid) (supervisor:start_child
                      (sup)
                      (list layer-name
                            (loise-state:get-layer layer-name)
                            (options overrides)))))
    (prog1
      (list
       (loise-traver-work:ping pid)
       (loise-traver-work:get pid))
      (supervisor:terminate_child
       (sup)
       pid))))
