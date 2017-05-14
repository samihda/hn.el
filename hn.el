(require 'url)
(require 'json)

(defvar hn-url "https://hacker-news.firebaseio.com/v0/topstories.json")
(defvar hn-item-url "https://hacker-news.firebaseio.com/v0/item/%s.json")
(defvar hn-stories-limit 30)

(defun hn-request (url)
  (let (json)
    (with-current-buffer (url-retrieve-synchronously url)
      (goto-char (point-min))
      (re-search-forward "^$" nil 'move)
      (setq json (buffer-substring-no-properties (point) (point-max)))
      (kill-buffer (current-buffer)))
    json))

(defun hn-parse-stories (json)
  (append (json-read-from-string json) nil))

(defun hn-get-top-stories (n list)
  (reverse (last (reverse list) n)))

(defun hn-get-item-url (id)
  (format hn-item-url id))

(defun hn-render-post (post)
  (let ((title (decode-coding-string (encode-coding-string (cdr (assoc 'title post)) 'utf-8) 'utf-8))
        (url (cdr (assoc 'url post)))
        (score (cdr (assoc 'score post))))
    (insert (format "[%s] %s\n%s\n\n" score title url))))

(defun hn-request-top-stories-list (hn-url)
  (hn-get-top-stories hn-stories-limit (hn-parse-stories (hn-request hn-url))))

(defun hn-get-item-urls (stories)
  (mapcar 'hn-get-item-url stories))

(defun hn-request-news-items (urls)
  (mapcar 'hn-request urls))

(defun hn-print (stories)
  (mapcar 'hn-render-post
	  (mapcar 'json-read-from-string stories)))

(defun hn ()
  "main function"
  (interactive)
  (let* ((hn-buffer "*hn*")
         (buf (get-buffer hn-buffer)))
    (with-output-to-temp-buffer hn-buffer
      (switch-to-buffer hn-buffer)
      (hn-print (hn-request-news-items (hn-get-item-urls (hn-request-top-stories-list hn-url)))))))

(provide 'hn)
