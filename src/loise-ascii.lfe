(defmodule loise-ascii
  (export all)
  (import
    (from proplists
      (get_value 2))
    (from loise-util
      (get-perlin-for-point 3)
      (get-simplex-for-point 3))))

(defun get-default-options ()
  `(#(width 36)
    #(height 56)
    #(multiplier 4.0)
    #(grades ,(loise-util:get-gradations 6))
    #(ascii-map ("A" "^" "n" "*" "~" "~"))
    #(colors (,#'color:whiteb/1 ,#'color:yellow/1 ,#'color:green/1
              ,#'color:greenb/1 ,#'color:blue/1 ,#'color:blue/1))
    #(random false)
    #(seed 42)))

(defun get-ascii-map (options)
  (lists:zip
    (get_value 'grades options)
    (get_value 'ascii-map options)))

(defun get-color-map (options)
  (lists:zip
    (get_value 'ascii-map options)
    (get_value 'colors options)))

(defun get-dimensions (options)
  `(,(get_value 'width options)
    ,(get_value 'height options)))

(defun get-point (x y func options)
  (let* ((value (funcall func
                  `(,x ,y)
                  (get-dimensions options)
                  (get_value 'multiplier options)))
         (adjusted (lutil-math:color-scale value #(-1 1)))
         (graded (lutil-math:get-closest adjusted (get_value 'grades options)))
         (ascii-map (get-ascii-map options)))
    `#((,x ,y) ,(get_value graded ascii-map))))

(defun get-perlin-point (x y options)
  (get-point x y #'get-perlin-for-point/3 options))

(defun get-simplex-point (x y options)
  (get-point x y #'get-simplex-for-point/3 options))

(defun build-ascii (func options)
  "Builds an ASCII map of the specified size and shape by calling the specified
  function on the coordinates of each point.

  The function takes an x and y coordinate as agument and returns an x y
  coordinate as well as an egd color value."
  (list-comp ((<- x (lists:seq 0 (get_value 'width options)))
              (<- y (lists:seq 0 (get_value 'height options))))
             (funcall func x y options)))

(defun render-row (x data options)
  (let ((color-map (get-color-map options)))
    (string:join
      (list-comp ((<- y (lists:seq 0 (get_value 'height options))))
                  (let ((ascii (get_value `(,x ,y) data)))
                    (funcall (get_value ascii color-map) ascii)))
      " ")))

(defun render (data options)
  (string:join
    (list-comp ((<- x (lists:seq 0 (get_value 'width options))))
               (render-row x data options))
    "\n"))

(defun print (data options)
  (io:format "~s~n" (list (render data options))))

(defun write (filename data options)
  (file:write_file filename (render data options)))

(defun create-perlin ()
  (let ((options (get-default-options)))
    (print (build-ascii #'get-perlin-point/3 options) options)))

(defun create-perlin
  (((= (cons `#(,_ ,_) _) options)) ;; work harder, hello kitty!
   (print (build-ascii #'get-perlin-point/3 options) options))
  ((filename)
    (let ((options (get-default-options)))
      (write filename
             (build-ascii #'get-perlin-point/3 options)
             options))))

(defun create-perlin (filename options)
  (write filename
         (build-ascii #'get-perlin-point/3 options)
         options))

(defun create-simplex ()
  (let ((options (get-default-options)))
    (print (build-ascii #'get-simplex-point/3 options) options)))

(defun create-simplex
  (((= (cons `#(,_ ,_) _) options))
   (print (build-ascii #'get-simplex-point/3 options) options))
  ((filename)
    (let ((options (get-default-options)))
      (write filename
             (build-ascii #'get-simplex-point/3 options)
             options))))

(defun create-simplex (filename options)
  (write filename
         (build-ascii #'get-simplex-point/3 options)
         options))
