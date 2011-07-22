package org.obi.release;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;

import com.hp.hpl.jena.ontology.OntModel;
import com.hp.hpl.jena.ontology.OntModelSpec;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.RDFNode;
import com.hp.hpl.jena.rdf.model.RDFWriter;
import com.hp.hpl.jena.rdf.model.Statement;
import com.hp.hpl.jena.rdf.model.StmtIterator;
import com.hp.hpl.jena.vocabulary.RDFS;


public class PruneSubClasses {
	
	//declaration of the OBI namespace
	private static String OBINs = "http://purl.obolibrary.org/obo/";


	//Check change in ecternalDerived maybe
	private static String xmlbase = "http://purl.obolibrary.org/obo/";


	public final static void main(String[] args) throws Exception  {
		
		// ObiMergedDIr
		// String obimergedDir ="/Users/torniai/TestObiMerge/"; (used by Carlo)
		String obimergedDir = "C:/Documents and Settings/Jie/My Documents/Ontology/obi/releases/2011-04-12/branches/";
		
		// File names
		String new_inferredfile = "new_inferred-superclasses.owl";
		String obimerged = "obi.owl";
		String inferredsubclassfile = "inferred-superclasses.owl";

	    //Paths
		String newInferredFilePath = obimergedDir + new_inferredfile;
		String ObiMergedFilePath = obimergedDir + obimerged; 
		String CUrrentInferredFilePath = obimergedDir + inferredsubclassfile;
		
		//New Inferred File
		File newInferredSubclassesFile = new File(newInferredFilePath);
		
		//Current inferred File
		File inferredFile = new File(CUrrentInferredFilePath);
		
		
		//Current OBI File
		File OBIFile = new File(ObiMergedFilePath);
		
		
		// Create  Model for OBI  
		OntModel OBIModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);	
		try {
			OBIModel.read(new FileInputStream(OBIFile), OBINs);
		}
		catch (Exception ex) {
			ex.printStackTrace();
			System.exit(1);
		}
		
		// Create Model for inferredSuperclasses 
			OntModel inferresSuperclassesModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);	
			try {
				inferresSuperclassesModel.read(new FileInputStream(inferredFile), OBINs);
			}
			catch (Exception ex) {
				ex.printStackTrace();
				System.exit(1);
			}
		
			
			
		
		// List subclass statement for inferred-statements
		
			StmtIterator stmtIterator=  OBIModel.listStatements(null, RDFS.subClassOf, (RDFNode) null);
			  while (stmtIterator.hasNext()) {
				
				  Statement stmt = stmtIterator.nextStatement();
				  System.out.println(stmt.toString());
				  
				 // Remove stTEMENT form inferredsupertype model
				  inferresSuperclassesModel.remove(stmt);
				  
			}
			
			
			// Debug
			
			// OBIMOdel.write(System.out);
			  
			//InferresSUperclassesModel.write(System.out);
			 
				
		
				//delete the file if it already exists
				if (newInferredSubclassesFile.exists())	{
					newInferredSubclassesFile.delete();
				}
		
				try {
					writeFile(newInferredSubclassesFile,inferresSuperclassesModel);
				}
				catch (Exception ex) {
					System.out.println("Unable to write the file");
					ex.printStackTrace();
					System.exit(1);
				}
		
		
		
		
}



	/**
	 * Writes the OntModel in the newFile using an RDFWriter
	 * @param newFile the File to will be written
	 * @param model the OntModel to be written
	 */
	public static void writeFile(File newFile, OntModel model){
		//writes the file
		OutputStreamWriter out = null;
		try {
			out = new OutputStreamWriter(new FileOutputStream(newFile,true),"UTF8");
		} catch (UnsupportedEncodingException e) {
			System.out.println(e);
			throw new RuntimeException(e);
		} catch (FileNotFoundException e) {
			System.out.println(e);
			throw new RuntimeException(e);
		}
		//creates the RDF writer
		RDFWriter writer = model.getWriter("RDF/XML-ABBREV");

		//sets the writer properties
		writer.setProperty("xmlbase", xmlbase);
		writer.setProperty("showXmlDeclaration","true");
		//absolute uris: we want rdf:about http://purl.obofoundry.org and not ../
		writer.setProperty("relativeURIs","");
		//write the model into the out file
		writer.write(model, out, OBINs);

	
}

}