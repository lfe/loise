(defmodule loise-sup
  (beehaviour supervisor)
  ;; supervisor implementation
  (export
   (start_link 0)
   (stop 0))
  ;; callback implementation
  (export
   (init 1)))

;;; ----------------
;;; config functions
;;; ----------------

(defun SERVER () (MODULE))
(defun supervisor-opts () '())
(defun sup-flags ()
  `#M(strategy one_for_one
      intensity 3
      period 60))

;;; -------------------------
;;; supervisor implementation
;;; -------------------------

(defun start_link ()
  (supervisor:start_link `#(local ,(SERVER))
                         (MODULE)
                         (supervisor-opts)))

(defun stop ()
  (gen_server:call (SERVER) 'stop))

;;; -----------------------
;;; callback implementation
;;; -----------------------

(defun init (_args)
  `#(ok #(,(sup-flags)
          (,(child 'loise-state 'start_link 'worker)
           ,(child 'loise-traver-sup 'start_link 'supervisor)))))

;;; -----------------
;;; private functions
;;; -----------------

(defun child (mod fun type)
  `#M(id ,mod
      start #(,mod ,fun ())
      restart permanent
      shutdown 2000
      type ,type
      modules (,mod)))
