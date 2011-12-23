package owl2;

import java.util.Iterator;
import java.util.Set;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.RemoveImport;
import org.semanticweb.owlapi.reasoner.OWLReasoner;

public class OBIrelease {
	
	/* SVN check out
	 * 
	 * get SVN log
	 * 
	 * assign new IDs
	 * 
	 * quality check
	 * - redundant rdfs:label
	 * - curation status, any missing, any in uncurated status, any incorrect status, missing required annotations for stated status
	 * - inconsistent rdfs:label with editor preferred labels
	 * - check any terms without rdfs:label with given IRI pattern (not include BFO) 
	 * 
	 * 
	 * 
	 * add disjoint axioms
	 * 
	 * 
	 * 
	 * reasoning and remove duplicated upper classes
	 * 
	 * merge all imported terms except IAO and BFO
	 * 
	 * remove branches, _defined_material, _defined_process, 
	 */
	public static void main(String[] args) {
		/*
		 *This part to merge disjoint.owl to obi.owl and generate inferred version of obi with superclasses cleaned
		 
		 
		String disjointFilename = "C:/Documents and Settings/Jie/My Documents/Ontology/obi/trunk/src/ontology/branches/disjoints.owl";
		String targetFilename = "C:/Documents and Settings/Jie/My Documents/Ontology/obi/trunk/src/ontology/branches/obi.owl";
		String saveFilename = "C:/Documents and Settings/Jie/My Documents/Ontology/obi/trunk/src/ontology/branches/inferred_obi.owl";
		String reasonerName = "hermit";
		// Get hold of an ontology manager
        OWLOntologyManager manager = OWLManager.createOWLOntologyManager();	
    	
    	// load ontology
     	OWLOntology targetOnt = OntologyManipulator.loadFromFile(targetFilename, manager);
     	OWLOntology ont = OntologyManipulator.loadFromFile(disjointFilename, manager);
     	// merge disjoint.owl to the obi.owl
     	targetOnt = OntologyManipulator.mergeToTargetOnt(manager, targetOnt, ont);
     	
     	// generate the inferred hierarchy and clean the super classes
     	OWLReasoner reasoner = OWLReasonerRunner.runReasoner(manager, targetOnt, reasonerName);
    	String mergeURIstr = "http://purl.obolibrary.org/obi_merged.owl";
    	targetOnt = OWLReasonerRunner.getCleanedOntologyWithInferredSuperClasses(manager, targetOnt, mergeURIstr, reasoner);
		*/   
		
		
		/* 
		 * This part is used to merge the MIREOT terms
		 */
		
		/*
		String targetFilename = "C:/Documents and Settings/Jie/My Documents/Ontology/obi/trunk/src/ontology/branches/inferred_obi.owl";
        String externalByHand = "http://purl.obolibrary.org/obo/obi/external-byhand.owl";
        String external = "http://purl.obolibrary.org/obo/obi/external.owl";
        String externalDerived = "http://purl.obolibrary.org/obo/obi/externalDerived.owl";
		String saveFilename = "C:/Documents and Settings/Jie/My Documents/Ontology/obi/trunk/src/ontology/branches/merged_obi2.owl";		
		
		// Get hold of an ontology manager
        OWLOntologyManager manager = OWLManager.createOWLOntologyManager();	     
    	
    	// load ontology
     	OWLOntology targetOnt = OntologyManipulator.loadFromFile(targetFilename, manager);
 
     	// get all directly imported ontologies
     	Set<OWLOntology> importOnts = targetOnt.getDirectImports();
 
     	// remove import declarations from loaded target ontology
		OWLDataFactory df = manager.getOWLDataFactory();
        RemoveImport ri = new RemoveImport(targetOnt, df.getOWLImportsDeclaration(IRI.create(external)));
        manager.applyChange(ri);
        ri = new RemoveImport(targetOnt, df.getOWLImportsDeclaration(IRI.create(externalByHand)));
        manager.applyChange(ri);
        ri = new RemoveImport(targetOnt, df.getOWLImportsDeclaration(IRI.create(externalDerived)));
        manager.applyChange(ri);
     	
        // merge directly imported ontologies into the target ontology
     	for(OWLOntology importOnt: importOnts) {
     		IRI importOntIRI = importOnt.getOntologyID().getOntologyIRI();
     		if (importOntIRI.equals(IRI.create(external)) || importOntIRI.equals(IRI.create(externalByHand)) || importOntIRI.equals(IRI.create(externalDerived))) {
     			targetOnt = OntologyManipulator.mergeToTargetOnt(manager, targetOnt, importOnt);
     		}
     	}
     	*/
		
		
		// merge iao-main before merge IAO to OBI
	    String iaoFilename = "C:/Documents and Settings/Jie/My Documents/Ontology/obi/releases/2011-12-13/external/iao/IAO.owl";
	    String saveIaoFilename = "C:/Documents and Settings/Jie/My Documents/Ontology/obi/releases/2011-12-13/merged/merged_iao.owl";	
	    
	    // Get hold of an ontology manager
        OWLOntologyManager manager = OWLManager.createOWLOntologyManager();	     
    	OWLOntology iaoOnt = OntologyManipulator.loadFromFile(iaoFilename, manager);
 		OWLDataFactory df = manager.getOWLDataFactory();

	    // get all directly imported ontologies
     	Set<OWLOntology> importOnts = iaoOnt.getDirectImports();

     	for(OWLOntology importOnt: importOnts) {
     		IRI importOntIRI = importOnt.getOntologyID().getOntologyIRI();
     		RemoveImport ri = new RemoveImport(iaoOnt, df.getOWLImportsDeclaration(importOntIRI));
     		manager.applyChange(ri);
     	}

     	for(OWLOntology importOnt: importOnts) {
     		iaoOnt = OntologyManipulator.mergeToTargetOnt(manager, iaoOnt, importOnt);
     	}
     	
     	OntologyManipulator.saveToFile(manager, iaoOnt, saveIaoFilename);
     	
     	
		// merge obi with merged iao.owl
		String targetFilename = "C:/Documents and Settings/Jie/My Documents/Ontology/obi/releases/2011-12-13/merged/Copy of cleaned_merged_obi.owl";
  		String saveFilename = "C:/Documents and Settings/Jie/My Documents/Ontology/obi/releases/2011-12-13/merged/merged_obi_iao2.owl";		
		
    	// load ontology
     	OWLOntology targetOnt = OntologyManipulator.loadFromFile(targetFilename, manager);
      	targetOnt = OntologyManipulator.mergeToTargetOnt(manager, targetOnt, iaoOnt);
		
     	// targetOnt = OntologyManipulator.setOntologyID(manager, targetOnt, "http://purl.obolibrary.org/obo/obi_merged.owl");
    	OntologyManipulator.saveToFile(manager, targetOnt, saveFilename);		
	}
}
