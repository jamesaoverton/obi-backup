(defvar *obi-uri-pattern* (#"compile" 'java.util.regex.pattern "^http://purl.obofoundry.org/obo/OBI_\\d+$"))

(defun is-obi-uri (uri)
  (#"matches" (#"matcher" *obi-uri-pattern* (uri-full uri))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (def-uri-alias "material-entity" !<http://purl.obofoundry.org/obo/IAO_0000018>)
  (def-uri-alias "ready-for-release" !<http://purl.obofoundry.org/obo/IAO_0000122>)
  (def-uri-alias "metadata-complete" !<http://purl.obofoundry.org/obo/IAO_0000120>)
  (def-uri-alias "metadata-incomplete" !<http://purl.obofoundry.org/obo/IAO_0000123>)
  (def-uri-alias "pending-final-vetting" !<http://purl.obofoundry.org/obo/IAO_0000125>)
  (def-uri-alias "uncurated" !<http://purl.obofoundry.org/obo/IAO_0000124>)
  (def-uri-alias "placeholder" !<http://purl.obofoundry.org/obo/IAO_0000121>)
  (def-uri-alias "obsolete-class" !<http://www.geneontology.org/formats/oboInOwl#ObsoleteClass>)
  (def-uri-alias "definition" !obi:IAO_0000115)
  (def-uri-alias "definition-source" !obi:IAO_0000119)
  (def-uri-alias "definition-editor" !obi:IAO_0000117)
  (def-uri-alias "preferred-term" !obi:IAO_0000111)
  (def-uri-alias "alternative-term" !obi:IAO_0000118)
  (def-uri-alias "example-of-usage" !obi:IAO_0000112)
  )


