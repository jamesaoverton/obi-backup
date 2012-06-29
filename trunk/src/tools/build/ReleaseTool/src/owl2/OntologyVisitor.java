package owl2;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashSet;
import java.util.Iterator;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.model.OWLEntity;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyManager;

public class OntologyVisitor {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		String path = "C:/Documents and Settings/Jie/My Documents/Ontology/obi-webservice/";
        OWLOntologyManager manager = OWLManager.createOWLOntologyManager();	 
        OWLOntology ont = OntologyManipulator.load(path + "ontology/webService.owl", manager);

        HashSet<String> termIDs = getTermsIRIStrings(manager, ont);
		
        try {
        	BufferedWriter out = new BufferedWriter(new FileWriter(path + "ids.txt"));
        	
        	Iterator<String> iterator = termIDs.iterator(); 
        	while (iterator.hasNext()){
        		out.write(iterator.next() + "\n");  
        	}
        	
        	out.close();
        }
        catch (IOException e) {
        	System.out.println("Exception ");
        }
	}
	
	public static HashSet<String> getTermsIRIStrings (OWLOntologyManager manager, OWLOntology ont) {
		HashSet<String> iriStrs = new HashSet<String> ();
	
	    for (OWLEntity ent : ont.getSignature()) {
	    	IRI iri = ent.getIRI();
	    	iriStrs.add(iri.toString());
	    }
		
		return iriStrs;
	}
}
