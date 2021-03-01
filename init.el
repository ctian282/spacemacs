;;; init.el --- Spacemacs Initialization File -*- no-byte-compile: t -*-
;;
;; Copyright (c) 2012-2020 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;; Without this comment emacs25 adds (package-initialize) here
;; (package-initialize)

;; Avoid garbage collection during startup.
;; see `SPC h . dotspacemacs-gc-cons' for more info
(defconst emacs-start-time (current-time))
(setq gc-cons-threshold 402653184 gc-cons-percentage 0.6)
(load (concat (file-name-directory load-file-name)
              "core/core-versions.el")
      nil (not init-file-debug))
(load (concat (file-name-directory load-file-name)
              "core/core-load-paths.el")
      nil (not init-file-debug))
(load (concat spacemacs-core-directory "core-dumper.el")
      nil (not init-file-debug))

;; Remove compiled core files if they become stale or Emacs version has changed.
(load (concat spacemacs-core-directory "core-compilation.el")
      nil (not init-file-debug))
(load spacemacs--last-emacs-version-file t (not init-file-debug))
(when (or (not (string= spacemacs--last-emacs-version emacs-version))
          (spacemacs//dir-contains-stale-byte-compiled-files-p
           spacemacs-core-directory))
  (spacemacs//remove-byte-compiled-files-in-dir spacemacs-core-directory))
;; Update saved Emacs version.
(unless (string= spacemacs--last-emacs-version emacs-version)
  (spacemacs//update-last-emacs-version))

(if (not (version<= spacemacs-emacs-min-version emacs-version))
    (error (concat "Your version of Emacs (%s) is too old. "
                   "Spacemacs requires Emacs version %s or above.")
           emacs-version spacemacs-emacs-min-version)
  ;; Disable file-name-handlers for a speed boost during init
  (let ((file-name-handler-alist nil))
    (require 'core-spacemacs)
    (spacemacs/dump-restore-load-path)
    (configuration-layer/load-lock-file)
    (spacemacs/init)
    (configuration-layer/stable-elpa-init)
    (configuration-layer/load)
    (spacemacs-buffer/display-startup-note)
    (spacemacs/setup-startup-hook)
    (spacemacs/dump-eval-delayed-functions)
    (when (and dotspacemacs-enable-server (not (spacemacs-is-dumping-p)))
      (require 'server)
      (when dotspacemacs-server-socket-dir
        (setq server-socket-dir dotspacemacs-server-socket-dir))
      (unless (server-running-p)
        (message "Starting a server...")
        (server-start)))))



;; Personal settings

;;; packages.el ends here
(global-set-key [M-left] 'windmove-left)
(global-set-key [M-right] 'windmove-right)
(global-set-key [M-up] 'windmove-up)
(global-set-key [M-down] 'windmove-down)

;;(add-hook 'after-init-hook 'global-company-mode)

(global-set-key [(control ?\.)] 'ska-point-to-register)
(global-set-key [(control ?\,)] 'ska-jump-to-register)
(defun ska-point-to-register()
  "Store cursorposition _fast_ in a register. 
Use ska-jump-to-register to jump back to the stored 
position."
  (interactive)
  (setq zmacs-region-stays t)
  (point-to-register 8))

(defun ska-jump-to-register()
  "Switches between current cursorposition and position
that was stored with ska-point-to-register."
  (interactive)
  (setq zmacs-region-stays t)
  (let ((tmp (point-marker)))
    (jump-to-register 8)
    (set-register 8 tmp)))

;; (add-hook 'python-mode-hook
;;           (lambda ()
;;           (semantic-idle-summary-mode 0) ) )


(defun my-org-screenshot ()
  "Take a screenshot into a time stamped unique-named file in the
same directory as the org-buffer and insert a link to this file."
  (interactive)
  (org-display-inline-images)
  (setq filename
        (concat
         (make-temp-name
          (concat (file-name-nondirectory (buffer-file-name))
                  "_imgs/"
                  (format-time-string "%Y%m%d_%H%M%S_")) ) ".png"))
  (unless (file-exists-p (file-name-directory filename))
    (make-directory (file-name-directory filename)))
                                        ; take screenshot
  (if (eq system-type 'darwin)
      (call-process "screencapture" nil nil nil "-i" filename))
  (if (eq system-type 'gnu/linux)
      (call-process "import" nil nil nil filename))
                                        ; insert into file if correctly taken
  (if (file-exists-p filename)
      (insert (concat "[[file:" filename "]]"))))



;;(add-to-list 'auto-mode-alist '("\\.py\\'" . 'spacemacs//disable-semantic-idle-summary-mode))
