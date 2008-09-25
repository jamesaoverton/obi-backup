(defvar *obi-uri-pattern* (#"compile" 'java.util.regex.pattern "^http://purl.obofoundry.org/obo/OBI_\\d+$"))

(defun is-obi-uri (uri)
  (#"matches" (#"matcher" *obi-uri-pattern* (uri-full uri))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (def-uri-alias "material-entity" !<http://purl.obofoundry.org/obo/OBI_0000141>)
  (def-uri-alias "ready-for-release" !<http://purl.obofoundry.org/obo/OBI_0000318>)
  (def-uri-alias "metadata-complete" !<http://purl.obofoundry.org/obo/OBI_0000319>)
  (def-uri-alias "metadata-incomplete" !<http://purl.obofoundry.org/obo/OBI_0000320>)
  (def-uri-alias "pending-final-vetting" !<http://purl.obofoundry.org/obo/OBI_0000323>)
  (def-uri-alias "uncurated" !<http://purl.obofoundry.org/obo/OBI_0000328>)
  (def-uri-alias "placeholder" !<http://purl.obofoundry.org/obo/OBI_0000366>)
  (def-uri-alias "obsolete-class" !<http://www.geneontology.org/formats/oboInOwl#ObsoleteClass>)
  (def-uri-alias "definition" !obi:OBI_0000291)
  (def-uri-alias "example-of-usage" !obi:OBI_0000287)
  )


