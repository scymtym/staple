#|
 This file is a part of Staple
 (c) 2014 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.staple)

(defvar *xref-resolvers* (make-hash-table :test 'eq))

(defun xref-resolver (name)
  (gethash name *xref-resolvers*))

(defun (setf xref-resolver) (function name)
  (setf (gethash name *xref-resolvers*) function))

(defun remove-xref-resolver (name)
  (remhash name *xref-resolvers*))

(defmacro define-xref-resolver (name args &body body)
  `(progn (setf (xref-resolver ',name)
                (lambda ,args ,@body))
          ',name))

(defun resolve-xref (definition)
  (loop for resolver being the hash-values of *xref-resolvers*
        for xref = (funcall resolver definition)
        when xref do (return xref)))

(define-xref-resolver current-page (definition)
  (when (find (definitions:package definition) (packages *page*))
    (format NIL "#~a" (url-encode (definition-id definition)))))

(define-xref-resolver other-pages (definition)
  (dolist (page (pages (project *page*)))
    (when (and (typep page 'definitions-index-page)
               (find (definitions:package definition) (packages page)))
      (return (format NIL "~a#~a" (relative-path page *page*) (url-encode (definition-id definition)))))))

(define-xref-resolver common-lisp (definition)
  (when (eql (definitions:package definition) (find-package "CL"))
    (format NIL "http://l1sp.org/cl/~a" (url-encode (string-downcase (definitions:name definition))))))

(defun parse-lisp-token (string)
  (with-output-to-string (out)
    (with-input-from-string (in string)
      (loop for char = (read-char in NIL)
            while char
            do (case char
                 (#\\ (write-char (read-char in NIL) out))
                 (#\| (loop for char = (read-char in NIL)
                            until (char= char #\|)
                            do (write-char char out)))
                 (T (write-char (char-upcase char) out)))))))

(defun parse-symbol (identifier)
  (let (package (name identifier))
    (loop with escaped = NIL
          for i from 0 below (length identifier)
          for char = (aref identifier i)
          do (case char
               (#\| (setf escaped (not escaped)))
               (#\\ (incf i))
               (#\:
                (unless escaped
                  (setf name (subseq identifier (+ i (if (eql #\: (aref identifier (1+ i))) 2 1))))
                  (setf package (cond ((= 0 i)
                                       "KEYWORD")
                                      ((and (= 1 i) (char= #\# (aref identifier 0)))
                                       :gensym)
                                      (T
                                       (subseq identifier 0 i))))))))
    (values (parse-lisp-token name)
            (etypecase package
              (string (parse-lisp-token package))
              ((eql :gensym) :gensym)
              (null NIL)))))

(defun find-definitions-for-identifier (name &key package (type T))
  (let ((packages (if package
                      (list package)
                      (append (packages *page*) (list "CL")))))
    (loop for package in packages
          append (ignore-errors
                  (let* ((package (ensure-package package))
                         (symbol (find-symbol name package)))
                    (when symbol
                      (definitions:find-definitions symbol :package package :type type)))))))

(defgeneric xref (thing))

(defmethod xref ((definition definitions:definition))
  (resolve-xref definition))

(defmethod xref ((identifier string))
  (multiple-value-bind (name package) (parse-symbol identifier)
    (unless (eql package :gensym)
      (let ((defs (find-definitions-for-identifier name :package package)))
        (loop for def in (preferred-definition defs)
              for xref = (resolve-xref def)
              do (when xref (return xref)))))))
