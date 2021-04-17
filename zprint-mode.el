;;; zprint-mode.el --- Reformat Clojure(Script) code using zprint

;; Author: Paulus Esterhazy (pesterhazy@gmail.com)
;; URL: https://github.com/pesterhazy/zprint-mode.el
;; Version: 0.3
;; Keywords: tools
;; Package-Requires: ((emacs "24.3"))

;; This file is NOT part of GNU Emacs.

;; zprint-mode.el is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; zprint-mode.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with zprint-mode.el.
;; If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Reformat Clojure(Script) code using zprint

;;; Code:

(defconst zprint-mode-dir (if load-file-name (file-name-directory load-file-name) default-directory))

;;;###autoload
(defun zprint (b e &optional display-error-buffer)
  "Reformat code using zprint.
If region is active, reformat it; otherwise reformat entire buffer.
When called interactively, or with prefix argument IS-INTERACTIVE,
show a buffer if the formatting fails"
  (interactive (if (region-active-p)
                   (list (region-beginning) (region-end))
                 (list 1 (buffer-end 1))))
  (let ((home (point))
        (error-buffer (get-buffer-create "*zprint-mode errors*")))
    (with-current-buffer error-buffer
      (read-only-mode 0)
      (erase-buffer))
    (let ((retcode (shell-command-on-region b e
                                            (concat zprint-mode-dir "bin/" "wrap-zprint")
                                            nil
                                            t
                                            error-buffer
                                            display-error-buffer)))
      (with-current-buffer error-buffer
        (special-mode))
      (if (eq retcode 0)
          (message "zprint applied")
        (message "zprint failed: see %s" (buffer-name error-buffer))))
    (goto-char home)))

(defun zprint-buffer ()
  (interactive)
  (zprint 1 (buffer-end 1)))

;;;###autoload
(define-minor-mode zprint-mode
  "Minor mode for reformatting Clojure(Script) code using zprint"
  :lighter " zprint"
  (if zprint-mode
      (add-hook 'before-save-hook 'zprint-buffer nil t)
    (remove-hook 'before-save-hook 'zprint-buffer t)))

(provide 'zprint-mode)

;;; zprint-mode.el ends here
