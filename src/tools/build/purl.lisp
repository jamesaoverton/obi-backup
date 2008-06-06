;; functions for interacting with purl.org

;; returns t if successful

(defun create-new-purl (purl url user password maintainers)
  (let* ((answer 
	  (get-url "http://purl.oclc.org/maint/new.pl.cgi"
		   :force-refetch t
		   :dont-cache t
		   :persist nil
		   :post `(("confirm" "true")
			   ("id" ,user)
			   ("password" ,password)
			   ("purl" ,purl)
			   ("url" ,url)
			   ("inst" ,(format nil "~{~a~^ ~}" maintainers))
			   ))))
    (#"matches" answer "(?s).*Added:.*")))

;; returns (list purl url), if successful
(defun update-purl (purl url user password maintainers comment)
  (let* ((answer 
	  (get-url "http://purl.oclc.org/maint/modify.pl.cgi"
		   :force-refetch t
		   :dont-cache t
		   :persist nil
		   :post `(("confirm" "true")
			   ("id" ,user)
			   ("password" ,password)
			   ("purl" ,purl)
			   ("url" ,url)
			   ("inst" ,(format nil "~{~a~^ ~}" maintainers))
			   ("public" ,comment)
			   ))))
    (car (all-matches answer "(?s).*Replaced:\\s*<a href=\"(.*?)\">(.*?)</a>\\s*=&gt; (.*?)\\s+" 1 3))))
    

;; returns (list purl url)
(defun get-purl (purl)
  (let* ((answer 
	  (get-url (format nil "http://purl.org/maint/display.pl.cgi?purlreg=~a&url=&maint=&inst=&noedit=on&id=nobody" purl)
		   :force-refetch t
		   :dont-cache t
		   :referer "http://purl.org/maint/display.html"
		   :persist nil)))
    (let ((did (all-matches  
		answer
		"(?s)PURL\\s*</b><a href=\"(.*?)\">.*?</a>\\s*<b>URL\\s*</b><a href=\".*?\">(.*?)</a>" 1 2)))
      (car did))))
      
