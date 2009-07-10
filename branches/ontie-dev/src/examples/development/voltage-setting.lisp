(with-ontology voltage-setting ()
    ((class !material-entity "see obi" :partial)
     (class !device "see obi" :partial !material-entity)
     (class !quality "see bfo" :partial)
     (class !relational-quality "see pato" :partial !quality)
     (class !monadic-quality "see pato" :partial !quality)
     (class !information-content-entity "see iao" :partial)
     (class !objective-specification "see iao" :partial !information-entity-about-a-realizable)
     (object-property "see ro" !inheres-in)
     (object-property "see ro proposed" !towards)
     (object-property "see ro" !part-of)
     (object-property "see iao" !is-about)
     (object-property "see ro proposed" !is-realized-in)
     (class !quantifiable-monadic-quality "A quantifiable monadic quality is a quality that has a magnitude that can be expressed as a number"  :partial !monadic-quality)
     (class !quantifiable-relational-quality "A quantifiable relational quality is a quality that has a magnitude that can be expressed as a number" :partial !relational-quality)
     (class !information-entity-about-a-realizable "see iao" :partial !information-content-entity)
     (object-property "see ro" !has-participant)
     (class !label "see iao" :partial !information-content-entity)

     (class !charge "Quality inhering in charged particles, and in materials by virtual of the charged particles which are part of it not being balanced equally between positive and negative charged" :partial !quantifiable-monadic-quality)
     (class !positive-charge "A quality of charge inhering in certain charged particles such as protons and in portions of material by virtual of their being an excess of such positively charged particles. Charge can be quantified in units of coulombs, among others." :partial !charge)
     (class !negative-charge "A quality of charge inhering in certain charged particles such as protons and in portions of material by virtual of their being an excess of such positively charged particles" :partial !charge)
     (class !voltage "A relational quality between two portions of material that have different charges, responsible for the dispositon of charges to flow from one point to the other. Can be quantified in units of volts among others" :partial !quantifiable-relational-quality
	    )
     (class !device-setting "A device setting is an objective specification that specifies what an device should do" :partial !objective-specification)
     (class !quantitative-device-setting "A quantitative device setting is a device setting that has a part that denotes a number" :partial !device-setting)
     (object-property !has-label "An information content entity I has-label l when l is a label and part of I" (super !has-part) (inverse-of !label-of) (domain !information-content-entity) (range !label))
     (object-property !has-units-label "An information content entity I has-units-label l when l is a units label and part of I" (super !has-label))
     (datatype-property !has-magnitude "An information content entity I has-magnitude m when m denotes a number and is part of I")
     (class !unit-label "A unit-label is an information content entity that denotes a unit, the nature of which is not yet resolved in the IAO" :partial !label)
     (class !voltage-unit-label "A unit-label is a unit label that denotes a unit of voltage" :partial !unit-label)
     (individual !volts-label (comment "The label 'volts' shown after a quantitative value is intended to denote a voltage in units of volts")
		 (type !voltage-unit-label) (label "volts"))
     (class !voltage-setting "A voltage setting is a quantitative device setting that specifies an objective have the the voltage between two parts of the device be the specified amount. The realization of the objective specified is a process in which the voltage specified inheres in the device (more precisely two parts have a voltage between them)"
	    :partial 
	    (manch (and !quantitative-device-setting
			(some !is-about (some !is-realized-in
					      (and !process (some !has-participant
								  (and !voltage
								       (some !inheres-in (some !part-of !device))
								       (some !towards (some !part-of !device)))))))
			(exactly !has-magnitude 1)
			(some !has-units-label !voltage-unit-label)
			(exactly !has-units-label 1))))
     (individual "An instance of a voltage setting - .2 volts. Note that we haven't specified what device the setting is of, although it is implied that it is the setting of something"
       !example-voltage-setting (label "Setting of .2 volts")
       (type !voltage-setting)
       (value !has-units-label !volts-label)
       (value !has-magnitude (literal 0.200 !xsd:float)))
     )
  (show-classtree voltage-setting :include-instances t :depth 10)
  (show-propertytree voltage-setting :include-instances t :depth 10)
  (write-rdfxml voltage-setting)
  (get-owl-species  voltage-setting t)
  )

