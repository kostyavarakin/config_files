;;; mode-line.el - code for including abbreviated file paths in mode line

(defconst mode-line-version (substring "$Revision: 2.34 $" 11 -2)
  "$Id: mode-line.el,v 2.34 1992/12/08 13:55:28 dodd Beta $")

;;; Copyright (C) 1992 Free Software Foundation, Inc.
;;;
;;; This program is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 1, or (at your option)
;;; any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program; if not, write to the Free Software
;;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;; LCD Archive Entry:
;; mode-line|Lawrence R. Dodd|dodd@roebling.poly.edu|
;; code for including abbreviated file paths in mode line|
;; $Date: 1992/12/08 13:55:28 $|$Revision: 2.34 $|~/????/mode-line.el.Z|

;;; Derived from Gaynor's prettymodeln.el (call that version 1.1 of
;;; mode-line.el). This is a cleaned and debugged version of that original
;;; code with more documentation and also with (some) support for view-mode.

;;; AUTHOR OF prettymodeln.el:
;;;
;;; Andy Gaynor (a.k.a., Silver)
;;; gaynor@paul.rutgers.edu ...!rutgers!paul.rutgers.edu!gaynor
;;; [Splthlt...Ahckthph! Ptooey!]
;;;
;;; Created: 13 Sep 87 18:34:59 GMT

;;; CONTRIBUTORS TO mode-line.el:
;;;
;;; Lawrence R. Dodd
;;; dodd@roebling.poly.edu
;;;
;;; Robert McLay
;;; mclay@cfdlab.ae.utexas.edu
;;;
;;; Crys Rides (a.k.a., James C. Ghering)
;;; crys@cave.tcp.com
;;; (for suggesting view-mode support)

;;; MAINTAINER OF mode-line.el:
;;;
;;; Lawrence R. Dodd
;;; dodd@roebling.poly.edu
;;;
;;; Please send bug reports, comments, suggestions, and any smart remarks
;;; concerning this code to the above e-mail address. Please mention the value
;;; of the variable `mode-line-version' *or* simply type `M-x
;;; mode-line-submit-report'.

;;; $LastEditDate:     "Mon Dec  7 17:48:53 1992"$
;;; Last RCS Check In: $Date: 1992/12/08 13:55:28 $
;;;
;;; $Id: mode-line.el,v 2.34 1992/12/08 13:55:28 dodd Beta $
;;; $Source: /home/dodd/lisp/RCS/mode-line.el,v $
;;; $Revision: 2.34 $

;;; USAGE:
;;;
;;;   o  save as mode-line.el in the GNU emacs load-path
;;;   o  stick this .emacs:
;;;
;;;                (require 'mode-line)

;;; ADVANCED USAGE:
;;;
;;;   o  save as mode-line.el in the GNU emacs load-path
;;;   o  stick something like the following inside your .emacs:
;;;
;;; (setq file-name-abbreviation-alist
;;;       (list
;;;        (cons  (concat "^" (expand-file-name "~")
;;;                       "/" "special/")  "special:")
;;;        (cons  (concat "^" (expand-file-name "~") "/")  "~/")
;;;        '("^/dodd@roebling.poly.edu:/home/dodd/" . "Roebling:")
;;;        '("^/joe@\\([a-zA-Z0-9.]*\\).\\(edu\\|gov\\):/home/joe/" . "\\1:")
;;;        '("^.*/\\([^/]*/\\)" . "\\1")))
;;;
;;; (require 'mode-line)
;;;
;;; The explanation of above is as follows. If I am editing a file called
;;; `filename' these associations will be attempted: if the full path to
;;; `filename' is
;;;
;;; (1) `/myhomedirectory/special/filename' display as `special:filename'
;;; (2) `/myhomedirectory/filename' display as `~/filename'
;;; (3) `/user@machine.edu:/anything/filename' display as `Machine:filename'
;;;     (this is _extremely_ useful with ange-ftp)
;;; (4) `/user@regexp.edu:/anything/filename' display as `regexp:filename'
;;; (5) `/snafu/barfoo/filename' display as `barfoo:filename'
;;;     (this is done for any path that does not match one of the above)

;;; ALSO: For more information on the filename associations list, after
;;; loading, do `M-x describe-variable file-name-abbreviation-alist'

;;; we need to load the default `view' package so that the variable
;;; `view-hook' will be defined when appended to below.

(require 'view)

;;; GENERAL DISPLAY STUFF

;;; This makes the mode-line display the day, date, time of day, and average
;;; number of processes. The increment for time update is 30 seconds, also
;;; `Mail' appears if there is any unread mail. Users may wish to comment this
;;; stuff out.

;;(setq display-time-interval 30)
;;(setq display-time-day-and-date t)
;;(display-time)

;;; MOTIVATION:
;;;
;;; Long file names (i.e. /u2/luser/foobar/bletch/src/0.1/global.h) in the
;;; mode line are a pain in the ass.  They suck up the whole mode line, and
;;; are a strain on the eyes to differentiate.  To avoid this problem, you can
;;; just display the buffer name.  But that's a little too uninformative.
;;;
;;; You will find here a mode-line-format scheme that is fairly nice.  It
;;; displays the buffer name if the buffer is not associated with a file.
;;; Otherwise, it displays the file name, but only after abbreviating it as
;;; per a list of abbreviations that you provide.

;;; LOGIC:
;;;
;;; Set up mode-line, by making mode-line-buffer-identification local to every
;;; buffer.  A find-file-hooks abbreviates the buffer-file-name to something a
;;; little easier to read.

;;; file name, originally = buffer-file-name
;;; abbreviations         = file-name-abbreviation-alist
;;; means of abbreviation = string-replace-regexp-in-alist
;;; find-file-hooks       = abbreviate-mode-line-buffer-identification

;;; Make sure you use mode-line-buffer-identification to identify the buffer
;;; in your mode-line-format.  This variable must be buffer-local (if it is
;;; not already).  Otherwise, the rest of the stuff is up to you - I've
;;; included my stuff to keep things in perspective.

;;; Customize mode-line-format and it's constituents.  Note that
;;; mode-line-buffer-identification must be used to identify the buffer.
;;; mode-line-modified is retained because it is in emacs's own default
;;; mode-line-format, and emacs might do some clever tricks with it.

(make-variable-buffer-local 'mode-line-buffer-identification)

;;; The next line was not present in the original.  I don't think it matters a
;;; whole lot (it should already be buffer-local, I think), but just in
;;; case...

(make-variable-buffer-local 'mode-line-modified)
(setq-default mode-line-buffer-identification '("%b"))
;; (setq-default mode-line-modified '("%*%*-"))

;;; now the define the organization of the mode-line-format

;; Set a Mode Line that tells me which machine, which directory,
;; and which line I am on, plus the other customary information.
(setq default-mode-line-format
      (list
       " "
       mode-line-mule-info
       mode-line-modified
       mode-line-frame-identification
       " "
       (getenv "HOST")
       ":"
       'default-directory
       mode-line-buffer-identification
       "   %[("
       'mode-line-process
       'minor-mode-alist
       "%n"
       ")%] "
       '(line-number-mode
	 (column-number-mode
	  (10 " (%l,%c) ")))
      '(-3 . "%p") ; make string at most 3 chars: `Top', `Bot', or `nn%' - LRD
      " "
      '(which-func-mode ("" which-func-format "--"))
      "-%-")
)

;;; A big thankyou to Robert McLay (mclay@cfdlab.ae.utexas.edu) for help with
;;; the following - LRD.

;;; Form home directory with a leading `^' and trailing `/' so if your home
;;; directory is /home/machine/user-name then home-dir is
;;; `^/home/machine/user-name/' (without the quotes) The leading `^' is need
;;; to match the leading end of the string.

;;; (originally was not a user option because it was missing the `*' - LRD)

(defvar file-name-abbreviation-alist
      (list
       (cons  (concat "^" (expand-file-name "~") "/")  "~/")
       (\"^.*/\\([^/]*/\\)\" . \"\\1\")
       )

  "*Alist of embedded filename patterns versus the corresponding desired
abbreviations. Each element is of the form (<regexp> . <to-string>).
mode-line.el goes down this list until it finds a regular expression <regexp>
that matches the full pathname of the file a replaces it with <to-string>.
Note, since it searches top-down, special cases should be put at the head of
the list.

Example:

If the user often plays with the files in /u2/luser/foobar/bletch.  What the
user may want to do is replace leading instances of this path with just
\"bletch\".  To do this stick the association

     (\"^/u2/luser/foobar/bletch\" . \"bletch\")

into the alist.

Another good association is to display only the last directory in the path if
no other special case applies. This is done with the following association

     (\"^.*/\\([^/]*/\\)\" . \"\\1\")

Default: simply removes home directory path and replaces it with ~/")

;;; the function that makes the substitutions

(defun string-replace-regexp-in-alist (string replacement-list)

  "Given a string STRING, replace each instance of regexp (cars of elements in
REPLACEMENT-LIST) with to-string (cdrs of elements in REPLACEMENT-LIST)."

  (let (new-string)

    (save-excursion

      (let

          ;; VARLIST - generate a unique name for temporary buffer
          ;; (originally code just used `!@#$%^&*' which, believe or not,
          ;; might not be unique - LRD)

          ((temp-buffer (make-temp-name "!@#$%^&*"))
           (temp-list replacement-list))

        ;; BODY

        (set-buffer (get-buffer-create temp-buffer))

        (insert string)

        ;; Walk down `replacement-list' as `temp-list', replacing instances of
        ;; (car (car temp-list)) with (cdr (car temp-list)).

        (while temp-list
          (goto-char (point-min))

          ;; search and replace using while loop (originally used
          ;; replace-regexp - LRD)

          (while (re-search-forward (car (car temp-list)) nil t)
            (replace-match (cdr (car temp-list))))
          (setq temp-list (cdr temp-list)))

        (setq new-string (buffer-string))
        (kill-buffer temp-buffer)))

    new-string))

;;; function that defines abbreviated identification (originally did not
;;; return nil for plain buffers - LRD)

(defun abbreviate-mode-line-buffer-identification ()

  "Abbreviates mode-line-buffer-identification locally using the function
string-replace-regexp-in-alist and the alist file-name-abbreviation-alist.
Returns nil if the current buffer is not visiting a file. This is needed for
view-mode since it will call this function even if it is not visiting a file
and its return value needs to be predictable (as opposed to garbage)."

  (if buffer-file-name
      (setq mode-line-buffer-identification
	    (list
	     (string-replace-regexp-in-alist buffer-file-name
					     file-name-abbreviation-alist)))
    nil))

;;; Add abbreviate-mode-line-buffer-identification to find-file-hooks and
;;; view-hook (originally overwrote find-file-hooks - LRD).

(setq find-file-hooks (append find-file-hooks
                              '(abbreviate-mode-line-buffer-identification)))

(setq view-hook (append view-hook
			'(abbreviate-mode-line-buffer-identification)))

;;; provide the package

(provide 'mode-line)
