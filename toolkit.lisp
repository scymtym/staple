#|
 This file is a part of Staple
 (c) 2014 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.staple)

(defvar *language-code-map* (make-hash-table :test 'equalp))

(defun load-language-codes (file table)
  (with-open-file (stream file)
    (loop for line = (read-line stream NIL)
          while line
          do (let* ((tab (position #\Tab line))
                    (code (subseq line 0 tab)))
               (when tab
                 (setf (gethash code table) code))))
    table))

(load-language-codes
 (asdf:system-relative-pathname :staple "data/iso-639-1.csv")
 *language-code-map*)

(load-language-codes
 (asdf:system-relative-pathname :staple "data/iso-639-3.csv")
 *language-code-map*)

(defun read-value ()
  (format *query-io* "~&> Enter a new value: ~%")
  (multiple-value-list (eval (read))))

(defun with-value-restart (place &body body)
  (let ((value (gensym "VALUE")))
    `(loop (restart-case
               (return
                 (progn ,@body))
             (set-value (,value)
               :report "Set a new value."
               :interactive read-value
               (setf ,place ,value))))))

(defmethod system-name ((system asdf:system))
  (intern (string-upcase (asdf:component-name system)) "KEYWORD"))

(defmethod system-name (name)
  (system-name (asdf:find-system name T)))

(defun compact (node)
  (typecase node
    (plump:text-node
     (setf (plump:text node) (cl-ppcre:regex-replace-all "(^\\s+)|(\\s+$)" (plump:text node) " ")))
    (plump:element
     (unless (string-equal "pre" (plump:tag-name node))
       (loop for child across (plump:children node)
             do (compact child))))
    (plump:nesting-node
     (loop for child across (plump:children node)
           do (compact child))))
  node)

(defmacro case* (test value &body clauses)
  (let ((valg (gensym "VALUE")))
    `(let ((,valg ,value))
       (cond ,@(loop for (clause-value . body) in clauses
                     collect (cond ((listp clause-value)
                                    `((or ,@(loop for v in clause-value
                                                  collect `(,test ,valg ',v)))
                                      ,@body))
                                   ((find clause-value '(T otherwise))
                                    `(T ,@body))
                                   (T
                                    `((,test ,valg ',clause-value)
                                      ,@body))))))))

(defun map-directory-tree (function directory)
  (let ((to-scan (list directory)))
    (loop for directory = (pop to-scan)
          while directory
          do (dolist (file (directory (merge-pathnames "*.*" directory)))
               (funcall function file))
             (dolist (dir (directory (merge-pathnames "*/" directory)))
               (push dir to-scan)))))

(defmacro do-directory-tree ((file directory &optional result) &body body)
  `(progn (map-directory-tree (lambda (,file) ,@body) ,directory)
          ,result))

(defgeneric definition-id (definition))

(defmethod definition-id ((definition definitions:global-definition))
  (format NIL "~a-~a:~a"
          (definitions:type definition)
          (package-name (definitions:package definition))
          (definitions:name definition)))

(defun url-encode (thing &optional (external-format :utf-8))
  (with-output-to-string (out)
    (loop for octet across (babel:string-to-octets thing :encoding external-format)
          for char = (code-char octet)
          do (cond ((or (char<= #\0 char #\9)
                        (char<= #\a char #\z)
                        (char<= #\A char #\Z)
                        (find char "-._~" :test #'char=))
                    (write-char char out))
                   (T (format out "%~2,'0x" (char-code char)))))))