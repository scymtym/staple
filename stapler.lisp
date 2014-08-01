#|
 This file is a part of Staple
 (c) 2014 TymoonNET/NexT http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.tymoonnext.staple)

(defvar *default-template* (merge-pathnames "default.html" (asdf:system-source-directory :staple)))
(defvar *root-clipboard*)

(defun root (field)
  (clip *root-clipboard* field))

(defun to-out (pathname)
  (merge-pathnames (format NIL "~a.out.~a" (pathname-name pathname) (pathname-type pathname)) pathname))

(defun system-out (system)
  (merge-pathnames "about.html" (asdf:system-source-directory (asdf:find-system system))))

(defun staple (in &key (out (to-out in)) (if-exists :supersede) clip-args)
  (let ((*package* (find-package "STAPLE"))
        (*root-clipboard* (apply #'make-clipboard clip-args))
        (document (plump:parse in)))
    (let ((document (apply #'clip:process document clip-args)))
      (with-open-file (stream out :direction :output :if-exists if-exists)
        (plump:serialize document stream)))
    out))

(defun generate (asdf-system &key
                               (packages (list asdf-system))
                               (name asdf-system)
                               documentation logo
                               (out (system-out asdf-system))
                               (template *default-template*)
                               (if-exists :error))
  (when (typep asdf-system 'asdf:system)
    (setf asdf-system (asdf:component-name asdf-system)))
  (let* ((asdf (or (asdf:find-system asdf-system)
                   (error "No such ASDF system: ~a" asdf-system)))
         (name (string name))
         (packages (mapcar #'string packages))
         (documentation (prepare-documentation asdf documentation))
         (*current-packages* packages))
    (staple
     template
     :out out :if-exists if-exists
     :clip-args (list 'asdf asdf-system 'name name 'packages packages 'documentation documentation 'logo logo))))
