(defun system-is-linux ()
    "Linux system checking."
    (interactive)
    (string-equal system-type "gnu/linux"))

(defun system-is-mac ()
    "Mac OS X system checking."
    (interactive)
    (string-equal system-type "darwin"))

(defun system-is-windows ()
    "MS Windows system checking."
    (interactive)
    (string-equal system-type "windows-nt"))

 ;; Start Emacs server. Require Midnight
(unless (system-is-windows)
    (require 'server)
    (unless (server-running-p)
        (server-start)))
(require 'midnight)

;; User name and e-mail
(setq user-full-name   "Warlock_29A")
(setq user-mail-adress "avatar29A@gmail.com")

;; Paths (for Common Lisp compiler - SBCL)
(setq unix-sbcl-bin    "/usr/bin/sbcl")
(setq windows-sbcl-bin "C:/sbcl/sbcl.exe")

;; Package list
(defvar required-packages
  '(neotree
    smartparens
    zenburn-theme
    srefactor))

(defun packages-installed-p ()
    "Packages availability checking."
    (interactive)
    (loop for package in required-packages
          unless (package-installed-p package)
            do (return nil)
          finally (return t)))
                              
;; Auto-install packages
(unless (packages-installed-p)
    (message "%s" "Emacs is now refreshing it's package database...")
    (package-refresh-contents)
    (message "%s" " done.")
    (dolist (package required-packages)
        (unless (package-installed-p package)
            (package-install package))))

;; Org-mode
(require 'org)

;; Delete selection
(delete-selection-mode t)

;; Disable GUI components
(tooltip-mode      -1)
(menu-bar-mode     -1)
(tool-bar-mode     -1)
(scroll-bar-mode   -1)
;;(blink-cursor-mode -1)
(setq use-dialog-box     nil)
(setq redisplay-dont-pause t)
(setq ring-bell-function 'ignore)

;; Fringe
(fringe-mode '(8 . 0))
(setq-default indicate-empty-lines t)
(setq-default indicate-buffer-boundaries 'left)

;; Disable backup/auto-save files
(setq make-backup-files        nil)
(setq auto-save-default        nil)
(setq auto-save-list-file-name nil)

;; Linum plug-in
(require 'linum)
(line-number-mode   t)
(global-linum-mode  t)
(column-number-mode t)
(setq linum-format " %d")

;; Display file size/time in mode-line
(setq display-time-24hr-format t)
(display-time-mode             t)
(size-indication-mode          t)

;; Line wrapping. Fill column
(setq word-wrap          t)
(global-visual-line-mode t)
(setq-default fill-column 80)

;; IDO plug-in
(require 'ido)
(ido-mode                      t)
(icomplete-mode                t)
(ido-everywhere                t)
(setq ido-vitrual-buffers      t)
(setq ido-enable-flex-matching t)


; Buffer selection and Ibuffer
(require 'bs)
(require 'ibuffer)
(defalias 'list-buffers 'ibuffer)

;; Syntax highlighting
(require 'font-lock)
(global-hl-line-mode               t)
(global-font-lock-mode             t)
(setq font-lock-maximum-decoration t)

;; Indentation
(defalias 'perl-mode 'cperl-mode)
(setq-default indent-tabs-mode nil)
(setq-default tab-width            4)
(setq-default python-indent        4)
(setq-default c-basic-offset       4)
(setq-default standart-indent      4)
(setq-default lisp-body-indent     4)
(setq-default cperl-indent-level   4)
(setq-default python-indent-offset 4)
(setq lisp-indent-function 'common-lisp-indent-function)

;; Scrolling
(setq scroll-step               1)
(setq scroll-margin            10)
(setq scroll-conservatively 10000)

;; Short messages
(defalias 'yes-or-no-p 'y-or-n-p)

;; Global clipboard
(setq x-select-enable-clipboard t)

;; File end newlines
(setq require-final-newline    t)
(setq next-line-add-newlines nil)

;; Highlight search results
(setq search-highlight        t)
(setq query-replace-highlight t)

;; Easy transition between buffers: M-{arrow keys}
(unless (equal major-mode 'org-mode)
    (windmove-default-keybindings 'meta))

(defun format-buffer ()
    "Format buffer."
    (interactive)
    (save-excursion (delete-trailing-whitespace)
                    (unless (equal major-mode 'python-mode)
                        (indent-region (point-min) (point-max)))
                    (unless indent-tabs-mode
                        (untabify (point-min) (point-max)))) nil)
(add-to-list 'write-file-functions 'format-buffer)


;; Bookmarks
(require 'bookmark)
(setq bookmark-save-flag t)
(when (file-exists-p (concat user-emacs-directory "bookmarks"))
    (bookmark-load bookmark-default-file t))
(setq bookmark-default-file (concat user-emacs-directory "bookmarks"))


;; Auto-insert mode
(require 'autoinsert)
(auto-insert-mode)
(setq auto-insert-query nil)
(define-auto-insert "\\.py\\'" 'python-skeleton)
(define-auto-insert "\\.\\(pl\\|pm\\)\\'" 'perl-skeleton)

;; Plug-ins:
(when (packages-installed-p)

    ;; Zenburn color theme
    ;;(load-theme 'zenburn t)

    ;; Smartparens
    (require 'smartparens-config)
    (smartparens-global-mode t)

    ;; Auto-complete
    (require 'auto-complete)
    (require 'auto-complete-config)
    (ac-config-default)
    (setq ac-auto-start        t)
    (setq ac-auto-show-manu    t)
    (global-auto-complete-mode t)
    (add-to-list 'ac-modes 'lisp-mode)

    ;; SLIME
    (require 'slime)
    (require 'slime-autoloads)
    (slime-setup '(slime-asdf
                   slime-fancy
                   slime-indentation))
    (setq slime-net-coding-system 'utf-8-unix)
    (if (or (file-exists-p unix-sbcl-bin) (file-exists-p windows-sbcl-bin))
        (if (system-is-windows)
            (setq inferior-lisp-program windows-sbcl-bin)
            (setq inferior-lisp-program unix-sbcl-bin))
        (message "%s" "SBCL not found..."))
    (add-to-list 'auto-mode-alist '("\\.cl\\'" . lisp-mode)))

;; Key-bindings:
;; Stop using the arrow keys
(global-unset-key [up])
(global-unset-key [down])
(global-unset-key [left])
(global-unset-key [right])

;; Motion between window:
(global-set-key (kbd "C-x <up>") 'windmove-up)
(global-set-key (kbd "C-x <down>") 'windmove-down)
(global-set-key (kbd "C-x <right>") 'windmove-right)
(global-set-key (kbd "C-x <left>") 'windmove-left)

;; Motion keys:
(defvar motion-keys-minor-mode-map (make-keymap) "motion-keys-minor-mode keymap.")
;; Go to previous line
(define-key motion-keys-minor-mode-map (kbd "M-i") 'previous-line)
;; Backward char
(define-key motion-keys-minor-mode-map (kbd "M-j") 'backward-char)
;; Forward char
(define-key motion-keys-minor-mode-map (kbd "M-l") 'forward-char)
;; Go to next line
(define-key motion-keys-minor-mode-map (kbd "M-k") 'next-line)
;; Backward word
(define-key motion-keys-minor-mode-map (kbd "M-u") 'backward-word)
;; Forward word
(define-key motion-keys-minor-mode-map (kbd "M-o") 'forward-word)
;; Window move up
(define-key motion-keys-minor-mode-map (kbd "C-i") 'windmove-up)
;; Window move down
(define-key motion-keys-minor-mode-map (kbd "C-k") 'windmove-down)
;; Window move left
(define-key motion-keys-minor-mode-map (kbd "C-j") 'windmove-left)
;; Window move right
(define-key motion-keys-minor-mode-map (kbd "C-l") 'windmove-right)

(define-minor-mode motion-keys-minor-mode "Fix conflict motion bindings with ather modes." t "motion-keys" 'motion-keys-minor-mode-map)
(motion-keys-minor-mode 1)


;; Go to line beginning
(global-set-key (kbd "M-a") 'beginning-of-visual-line)
;; Go to line end
(global-set-key (kbd "M-e") 'end-of-visual-line)
;; Go to function beginning
(global-set-key (kbd "C-a") 'beginning-of-defun)
;; Go to function end
(global-set-key (kbd "C-e") 'end-of-defun)
;; Scroll up
(global-set-key (kbd "M-n") 'scroll-up-command)
;; Scroll down
(global-set-key (kbd "M-h") 'scroll-down-command)
;; Beginning of buffer
(global-set-key (kbd "M-,") 'beginning-of-buffer)
;; End of buffer
(global-set-key (kbd "M-.") 'end-of-buffer)
;; Backward list
(global-set-key (kbd "M-[") 'backward-list)
;; Forward list
(global-set-key (kbd "M-]") 'forward-list)

;; Killing and Deleting:
;; Kill region
(global-set-key (kbd "M-x") 'kill-region)
;; Kill ring and save
(global-set-key (kbd "M-c") 'kill-ring-save)
;; Yank
(global-set-key (kbd "M-v") 'yank)
;; Delete backward char
(global-set-key (kbd "M-;") 'delete-backward-char)
;; Delete forward char
(global-set-key (kbd "M-'") 'delete-forward-char)
;; Kill whole line
(global-set-key (kbd "M-d") 'kill-whole-line)
;; Kill visual line
(global-set-key (kbd "M-f") 'kill-visual-line)
;; Kill word
(global-set-key (kbd "M-w") 'kill-word)
;; Transpose words
(global-set-key (kbd "M-t") 'transpose-words)

;; Files and Buffers:
;; Find or create file
(global-set-key (kbd "C-f") 'ido-find-file)
;; Switch buffer
(global-set-key (kbd "M-b") 'ido-switch-buffer)
;; Ido kill buffer
(global-set-key (kbd "C-d") 'ido-kill-buffer)
;; Save file
(global-set-key (kbd "M-g") 'save-buffer)
;; Ido write file
(global-set-key (kbd "C-w") 'ido-write-file)
;; Save buffers and kill terminal
(global-set-key (kbd "C-q") 'save-buffers-kill-terminal)
;; Delete other window
(global-set-key (kbd "C-1") 'delete-other-windows)
;; Split window bellow
(global-set-key (kbd "C-2") 'split-window-below)
;; Split window right
(global-set-key (kbd "C-3") 'split-window-right)
;; Delete window
(global-set-key (kbd "C-0") 'delete-window)
;; Window move up
(global-set-key (kbd "C-i") 'windmove-up)
;; Window move down
(global-set-key (kbd "C-k") 'windmove-down)
;; Window move left
(global-set-key (kbd "C-j") 'windmove-left)
;; Window move right
(global-set-key (kbd "C-l") 'windmove-right)

;; Commands:
;; Undo
(global-set-key (kbd "M-z") 'undo)
;; Keyboard quit
(global-set-key (kbd "M-q") 'keyboard-quit)
;; Newline and indent
(global-set-key (kbd "RET") 'newline-and-indent)

(defun function-newline-and-indent ()
    "Clever newline."
    (interactive)
    (end-of-visual-line)
    (newline-and-indent))
(global-set-key (kbd "M-RET") 'function-newline-and-indent)

(defun add-line-above ()
    "Add line above."
    (interactive)
    (previous-line)
    (function-newline-and-indent))
(global-set-key (kbd "C-o") 'add-line-above)

;; Add comment according major mode
(global-set-key (kbd "M-/") 'comment-dwim)
;; Set mark command
(global-set-key (kbd "M-m") 'set-mark-command)
;; Back to indentation
(global-set-key (kbd "M-\\") 'back-to-indentation)

;; Functional keys:
;; Buffer selection
(global-set-key (kbd "<f2>") 'bs-show)

;; Bookmark key-bindings
(global-set-key (kbd "<f3>") 'bookmark-set)
(global-set-key (kbd "<f4>") 'bookmark-jump)
(global-set-key (kbd "<f5>") 'bookmark-bmenu-list)

;; Imenu key-bindings
(global-set-key (kbd "<f6>") 'imenu)

;; Keyboard macros
(global-set-key (kbd "<f7>") 'kmacro-start-macro)
(global-set-key (kbd "<f8>") 'kmacro-end-macro)
(global-set-key (kbd "<f9>") 'kmacro-call-macro)

;; Menu bar
(global-set-key (kbd "<f10>") 'menu-bar-open)

;; Ido dired
(global-set-key (kbd "<f11>") 'ido-dired)

;; Execute command
(global-set-key (kbd "<f12>") 'execute-extended-command)

;; Org key-bindings:
(global-set-key (kbd "\C-ca") 'org-agenda)
(global-set-key (kbd "\C-cb") 'org-iswitchb)
(global-set-key (kbd "\C-cc") 'org-capture)
(global-set-key (kbd "\C-cl") 'org-store-link)

;; ac-slime
(add-hook 'slime-mode-hook 'set-up-slime-ac)
(add-hook 'slime-repl-mode-hook 'set-up-slime-ac)
(eval-after-load "auto-complete"
                 '(add-to-list 'ac-modes 'slime-repl-mode))

;; NeoTree plugin
(require 'neotree)
(global-set-key [f8] 'neotree-toggle)

(setq-default lisp-body-indent 4)
(setq lisp-indent-function 'common-lisp-indent-function)
(put 'upcase-region 'disabled nil)

;; srefactor
(require 'srefactor)
(require 'srefactor-lisp)

;; srefactor key bindings:
;;(global-set-key (kbd "C-x RET o") 'srefactor-lisp-one-line)
;;(global-set-key (kbd "C-x RET m") 'srefactor-lisp-format-sexp)
(global-set-key (kbd "C-x p") 'srefactor-lisp-format-defun)
;;(global-set-key (kbd "C-x RET b") 'srefactor-lisp-format-buffer)

;; Nyan Mode
(require 'nyan-mode)
(nyan-mode 1)

;; slime-helper
(load (expand-file-name "~/.quicklisp/slime-helper.el"))
(setq inferior-lisp-program "sbcl")

;; Redshank mode
(paredit-mode 1)
(redshank-mode 1)

(provide 'init-local)