package owl2;

import java.io.File;
import java.util.ArrayList;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.util.AutoIRIMapper;

public class GetTermIRIs {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// file contains a list of terms in column 1
		String fileName="C:/Documents and Settings/Jie/My Documents/Ontology/MO/Mapping-txt/MO2OBI.txt";

		// locations of ontology file (OBI development version)
 		String path = "C:/Documents and Settings/Jie/My Documents/Ontology/obi/releases/2012-01-18/";

 		// Get hold of an ontology manager
        OWLOntologyManager manager = OWLManager.createOWLOntologyManager();	 
    	AutoIRIMapper mapper = new AutoIRIMapper(new File(path + "branches/"), false);
       	AutoIRIMapper mapper2 = new AutoIRIMapper(new File(path + "external/"), false);
       	AutoIRIMapper mapper3 = new AutoIRIMapper(new File(path + "external/iao/"), false);
       	manager.addIRIMapper(mapper);
    	manager.addIRIMapper(mapper2);
    	manager.addIRIMapper(mapper3);
		
		
		// load a list of terms

		
 		String disjointFilename = path + "branches/disjoints.owl";
	    String saveFilename = path + "merged/obi_merged_cleaned.owl";	
		String inferOntURIStr = "http://purl.obolibrary.org/obo/obi/obi_inferredSuperClasses.owl";
	    String saveInferFilename = path + "branches/obi_inferredSuperClasses.owl";	
		
                         
    	// load obi ontology
        OWLOntology ont = OntologyManipulator.load(path + "merged/obi_merged.owl", manager);
    	//OntologyManipulator.printPrefixNSs(manager, ont);

		
		
		
		
		
		
		
		
		TextFileReader x=new TextFileReader(fileName);
		//x.ReadInLines();
		//x.findPositionFromLine();
		// x.displayArrayList();
		x.ReadInMatrix();
		x.findPositionFromMatrix();
		
		System.out.println("URI pos " + x.getUriPos());
		System.out.println("Label pos " + x.getLabelPos());
		System.out.println("tag pos " + x.getTagPos());
		System.out.println("preferrred label pos " + x.getPreferredLabelPos());
		
		ArrayList <String[]> matrix = x.getFileMatrix();

		for (int i = 0; i < matrix.size(); i++) {
			String[] row = matrix.get(i);
			if (row.length > x.getUriPos())
				System.out.println("URI pos " + row[x.getUriPos()]);
			if (row.length > x.getLabelPos())
				System.out.println("Label pos " + row[x.getLabelPos()]);
			if (row.length > x.getTagPos())
				System.out.println("tag pos " + row[x.getTagPos()]);
			if (row.length > x.getPreferredLabelPos())
				System.out.println("preferrred label pos " + row[x.getPreferredLabelPos()]);			
		}
	}

}
