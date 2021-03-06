(in-package :bknr.xml)

(defun node-children-nodes (xml)
  (remove-if-not #'consp (node-children xml)))

(defun find-child (xml node-name)
  (let ((children (node-children-nodes xml)))
    (find node-name children :test #'string-equal :key #'node-name)))

(defun find-children (xml node-name)
  (let ((children (node-children-nodes xml)))
    (find-all node-name children :test #'string-equal :key #'node-name)))

(defun node-string-body (xml)
  (let ((children (remove-if #'consp (node-children xml))))
    (if (every #'stringp children)
	(apply #'concatenate 'string children)
	(error "Some children are not strings"))))

(defun node-attribute (xml attribute-name)
  (cadr (assoc attribute-name (node-attrs xml) :test #'equal)))

(defun node-child-string-body (xml node-name)
  (let ((child (find-child xml node-name)))
    (if (and child (consp child))
	(node-string-body child)
	nil)))

(defun node-to-html (node &optional (stream *standard-output*))
  (when (stringp node)
    (write-string node)
    (return-from node-to-html))
  (write-char #\< stream)
  (when (node-ns node)
    (write-string (node-ns node) stream)
    (write-char #\: stream))
  (write-string (node-name node) stream)
  (loop for (key value) in (node-attrs node)
	do (write-char #\Space stream)
	(write-string key stream)
	(write-char #\= stream)
	(write-char #\" stream)
	(write-string value stream)
	(write-char #\" stream))
  (if (node-children node)
      (progn 
	(write-char #\> stream)
	(write-char #\Newline stream)
	(dolist (child (node-children node))
	  (node-to-html child stream))
	(write-char #\< stream)
	(write-char #\/ stream)
	(when (node-ns node)
	  (write-string (node-ns node) stream)
	  (write-char #\: stream))
	(write-string (node-name node) stream)
	(write-char #\> stream)
	(write-char #\Newline stream))
      (progn (write-char #\Space stream)
	     (write-char #\/ stream)
	     (write-char #\> stream)
	     (write-char #\Newline stream))))

