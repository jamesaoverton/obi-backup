package owl2;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.AddAxiom;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLAnnotation;
import org.semanticweb.owlapi.model.OWLAnnotationProperty;
import org.semanticweb.owlapi.model.OWLAxiom;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLLiteral;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.RemoveAxiom;

public class ExtractAnnotProp {
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// Get hold of an ontology manager
        OWLOntologyManager manager = OWLManager.createOWLOntologyManager();	
    	
    	// load ontology
    	OWLOntology ont = OntologyManipulator.loadFromFile("C:/Documents and Settings/Jie/My Documents/Ontology/obi/releases/2011-12-13/merged/cleaned_merged_obi.owl", manager);

    	// Create factory to obtain a reference to a class
        OWLDataFactory df = manager.getOWLDataFactory();   	 
        //Set the annotation properties
    	OWLAnnotationProperty annotProp = df.getOWLAnnotationProperty(IRI.create("http://purl.obolibrary.org/obo/OBI_9991118"));
       	OWLAnnotationProperty subsetProp = df.getOWLAnnotationProperty(IRI.create("http://www.geneontology.org/formats/oboInOwl#inSubset"));
       	
       	String inSubsetVal = "IEDB";

    	// Create a new ontology that holds application layer annotation property
    	OWLOntology annotOnt = OntologyManipulator.create(manager, "http://purl.obolibrary.org/obo/IEDB_annot.owl");
    	OWLOntology subsetOnt = OntologyManipulator.create(manager, "http://purl.obolibrary.org/obo/IEDB_inSubset.owl");
      	
    	// go through the ontology, find IEDB property, delete the axioms from original ontology and add them in the new ontology
        for (OWLClass cls : ont.getClassesInSignature()) {
            for (OWLAnnotation annotation : cls.getAnnotations(ont, annotProp)) {
            	// get community view label
            	if (annotation.getValue() instanceof OWLLiteral) {
            		OWLLiteral val = (OWLLiteral) annotation.getValue();                        
                    OWLAnnotation annotLabel = df.getOWLAnnotation(annotProp, val);
        		    OWLAxiom ax = df.getOWLAnnotationAssertionAxiom(cls.getIRI(), annotLabel);

        		    // remove axiom from the original ontology
        		    manager.applyChange(new RemoveAxiom(ont, ax));
        		    
        		    // add axioms in the inSubset ontology
                    OWLAnnotation subsetAnnot = df.getOWLAnnotation(subsetProp, df.getOWLLiteral(inSubsetVal));
        		    OWLAxiom subAx = df.getOWLAnnotationAssertionAxiom(cls.getIRI(), subsetAnnot);
        		    manager.applyChange(new AddAxiom(subsetOnt, subAx));
        		    
        		    // add axiom in the user preferred label ontology if value is not empty
        		    if (val.getLiteral().length() > 0) {
        		    	manager.applyChange(new AddAxiom(annotOnt, ax));
        		    } else {
        		    	System.out.println(cls.getIRI().toString() + " " + OBIentity.getLabel(cls,ont,df));
        		    }
            	}
            } 
        } 
        
		OntologyManipulator.saveToFile(manager, ont, "C:/Documents and Settings/Jie/My Documents/Ontology/obi/releases/2011-12-15/merged/merged_obi_woIEDB.owl");

		OntologyManipulator.saveToFile(manager, annotOnt, "C:/Documents and Settings/Jie/My Documents/Ontology/obi/releases/2011-12-15/merged/IEDB_annot.owl");
		
		OntologyManipulator.saveToFile(manager, subsetOnt, "C:/Documents and Settings/Jie/My Documents/Ontology/obi/releases/2011-12-15/merged/IEDB_inSubset.owl");
		
		OWLOntology viewOnt = OntologyManipulator.mergeToTargetOnt(manager, ont, subsetOnt);
		viewOnt = OntologyManipulator.mergeToTargetOnt(manager, viewOnt, annotOnt);
		OntologyManipulator.saveToFile(manager, viewOnt, "C:/Documents and Settings/Jie/My Documents/Ontology/obi/releases/2011-12-15/merged/obi_IEDBview.owl");		
	}
}
