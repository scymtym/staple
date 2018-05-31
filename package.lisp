#|
 This file is a part of Staple
 (c) 2014 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:cl-user)
(defpackage #:staple
  (:nicknames #:org.shirakumo.staple)
  (:use #:cl #:org.shirakumo.staple.recording)
  ;; code-format.lisp
  (:export
   #:markup-code-snippets
   #:markup-code-block
   #:markup-code-reference)
  ;; inference.lisp
  (:export
   #:*document-patterns*
   #:*image-patterns*
   #:*default-template*
   #:extract-language
   #:simple-page
   #:document
   #:simple-project
   #:logo
   #:documents
   #:images
   #:subsystems
   #:page-type
   #:output-directory
   #:output-file
   #:no-known-output-directory
   #:system)
  ;; page.lisp
  (:export
   #:*page*
   #:page
   #:title
   #:language
   #:output
   #:project
   #:generate
   #:input-page
   #:input
   #:static-page
   #:compiled-page
   #:templated-page
   #:template-data
   #:symbol-index-page
   #:packages
   #:format-documentation
   #:resolve-source-link
   #:definition-wanted-p
   #:definitions
   #:system-page
   #:system)
  ;; project.lisp
  (:export
   #:*load-prohibited-systems*
   #:project
   #:pages
   #:extension-file
   #:find-project
   #:load-extension
   #:infer-project
   #:generate)
  ;; recording.lisp
  (:export
   #:packages)
  ;; transform.lisp
  (:export
   #:pathname-type->type
   #:compile-source
   #:define-source-compiler)
  ;; toolkit.lisp
  (:export
   #:find-files
   #:read-file
   #:definition-id
   #:definition-order
   #:sort-definitions
   #:definition-importance
   #:preferred-definition
   #:url-encode
   #:ensure-package-defs
   #:ensure-package
   #:absolute-source-location
   #:maybe-lang-docstring
   #:ensure-stream
   #:finish-stream
   #:with-stream
   #:stream-designator)
  ;; xref.lisp
  (:export
   #:xref-resolver
   #:remove-xref-resolver
   #:define-xref-resolver
   #:resolve-xref
   #:find-definitions-for-identifier
   #:xref))
