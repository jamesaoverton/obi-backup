/**
 * @author Melanie
 * Feb 21, 2008
 * 
 * Filename    : OBIMerger.java
 * Copyright (C)  Melanie Courtot 2008
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more
 * details. http://www.gnu.org/licenses/gpl.txt
 * Melanie Courtot
 * Terry Fox Laboratory, BC Cancer Research Centre. Vancouver, BC V5Z 1L3  Canada. mcourtot@bccrc.ca
 */

package ca.bccrc.obi;



import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;


import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;


import org.mindswap.pellet.jena.OWLReasoner;
import org.mindswap.pellet.jena.PelletReasonerFactory;


//import com.hp.hpl.jena.ontology.OntDocumentManager;
import com.hp.hpl.jena.ontology.OntModel;
import com.hp.hpl.jena.ontology.OntModelSpec;
import com.hp.hpl.jena.ontology.Ontology;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.RDFWriter;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.StmtIterator;
import com.hp.hpl.jena.rdf.model.impl.StatementImpl;
import com.hp.hpl.jena.reasoner.ValidityReport;




public class OBIMerger {

	//declaration of the variables
	//TODO externalize those (properties file)
	//the OBI namespace
	//private static String OBINs = "http://obi.sourceforge.net/ontology/OBI.owl#";
	private static String OBINs = "http://purl.obofoundry.org/obo/";
	//the OBI xmlbase element
	//private static String xmlbase = "http://obi.sourceforge.net/ontology/OBI.owl";
	private static String xmlbase = "http://purl.obofoundry.org/obo/obi.owl";
	//the name of the file containing the declaration of all the imports
	private static String obi = "obi.owl";
	//the obiPath - this is the path for the branches files
	//private static String obiPath = "http://obi.sourceforge.net/ontology/OBI/";
	private static String obiPath = "http://purl.obofoundry.org/obo/obi/";



	/**
	 * Returns list of branches names as referenced in the OBI file
	 * @param obi - the file containing the imports of all the branches, e.g. obi.owl
	 * @param physicalURI - the physical path to the directory containing the files
	 * @return - a list of the branches names, e.g. "Biomaterial"
	 */
	public static List<String> getBranchesNames(String obi, String physicalURI){
		List<String> branchesNames = new ArrayList<String>();
		try{
			branchesNames.add("Biomaterial");
			branchesNames.add("externalDerived");
			branchesNames.add("external");
			branchesNames.add("Role");
			branchesNames.add("InstrumentAndPart");
			branchesNames.add("TheRest");
			branchesNames.add("Relations");
			branchesNames.add("PlanAndPlannedProcess");
			branchesNames.add("AnnotationProperty");

			branchesNames.add("OBI-Function");
			branchesNames.add("DataTransformation");

			branchesNames.add("Quality");
			branchesNames.add("Obsolete");

			branchesNames.add("DigitalEntityPlus");
			//branchesNames.add("disjoints");

			//instances
			branchesNames.add("DataFormatSpecification");

		}catch (Exception e){
			System.err.println("Error: " + e.getMessage());
		}


		return branchesNames;
	}

	public static boolean checkConsistency(String ontologyPath)	{


		boolean toCommit = true;
		FileInputStream fstream = null;
		try {
			fstream = new FileInputStream(ontologyPath);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}

		//we create the model with Pellet spec
		OntModel model = ModelFactory.createOntologyModel(PelletReasonerFactory.THE_SPEC);

		// read in the ontology:
		model.read(fstream, xmlbase);



		//get the report
		ValidityReport report = model.validate();
		Iterator<?> it = report.getReports();
		while (it.hasNext()){
			System.out.println("report: "+it.next().toString());
			toCommit = false;
		}

		//we check the OWL level
		//if different from DL we don't commit
		OWLReasoner reasoner = new OWLReasoner();
		reasoner.load(model);
		String level = reasoner.getLevel();
		if (!level.equalsIgnoreCase("DL"))
		{
			toCommit = false;
			System.out.println("level"+level);
		}

		//return false if there has been any problem, or true if everything is fine
		return toCommit;
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

	public static void addImports(Ontology ont, OntModel owlModel)	{
		//we add the external imports
		//we add those as Ontology Resource, to get the proper syntax for the imports, otherwise Pellet complains OWL full
		//NOTE: this causes a display problem in Protege 3, see https://mailman.stanford.edu/pipermail/protege-owl/2007-December/004728.html
		ont.addImport(owlModel.createOntology("http://www.ifomis.org/bfo/1.1"));
		ont.addImport(owlModel.createOntology("http://purl.org/obo/owl/OBO_REL"));
		ont.addImport(owlModel.createOntology("http://purl.org/obo/owl/ro_bfo_bridge/1.1"));
		ont.addImport(owlModel.createOntology("http://protege.stanford.edu/plugins/owl/dc/protege-dc.owl"));



	}


	public static void addProtegeFriendlyImports(Ontology ont, OntModel owlModel)	{
		//we add the external imports
		//we add those as Resource, to get the proper syntax for the imports, and proper display in protege
		//NOTE: this will cause Pellet to classify as OWL Full (Untyped Ontology)
		ont.addImport(owlModel.createResource("http://www.ifomis.org/bfo/1.1"));
		ont.addImport(owlModel.createResource("http://purl.org/obo/owl/OBO_REL"));
		ont.addImport(owlModel.createResource("http://purl.org/obo/owl/ro_bfo_bridge/1.1"));
		ont.addImport(owlModel.createResource("http://protege.stanford.edu/plugins/owl/dc/protege-dc.owl"));
	}



	public static OntModel buildOWLModel (String physicalURI){
		//create the Jena model
		OntModel owlModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);	

		//we read all the branches into the owlModel to merge them
		List<String> branchesnames = getBranchesNames(obi,physicalURI);

		for(String s : branchesnames) {

			try {
				String branchPath = physicalURI +s+".owl";
				//System.out.println("branch names: "+ branchPath);
				String ontoURI = obiPath+s+".owl";
				Ontology ont = owlModel.createOntology(ontoURI);

				//we define alternative entry for the ontologies
				//this allows us to map for example purl.obofoundry.org/obo/obi/Biomaterial.owl to its physical location
				//needed in the case where for example Relations.owl imports Biomaterial.owl.
				//Interestingly, if I do that, the prefix are not removed anymore on the final version...
				//AND if I get the java exception I guess Jena skips the import and I'm not getting the namespace problem with Protege
				//OntDocumentManager OntDocumentManager = owlModel.getDocumentManager();
				//OntDocumentManager.addAltEntry(ontoURI, branchPath);


				//owlModel.read(new FileInputStream(branchPath), obiPath+s+".owl");

				//we read each branch into the model to merge them
				//problem if I do that is that then for the namespaces defined in branch files the prefixes are not kept.
				//for example xmlns:cell="http://purl.org/obo/owl/CL#" disappears from the final merge, which gives a p1 namespace in Protege.
				//other option is to read and write the branch file, and then read it in the total merged file
				OntModel branchModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);	
				branchModel.read(new FileInputStream(branchPath), obiPath+s+".owl");
				//System.out.println("reading : "+s);
				owlModel.add(branchModel);


				//we remove the individual properties per branch (e.g. version)
				ont.removeProperties();


			}
			catch (Exception ex) {
				ex.printStackTrace();
				System.exit(1);
			}
		}
		return owlModel;
	}
	
	public static OntModel buildMergedFiles(String physicalURI, boolean ProtegeFriendly){

	
		//creates the ontology model
		OntModel owlModel = buildOWLModel(physicalURI);
		//creates the ontology
		Ontology ont = owlModel.createOntology(xmlbase);
		//Protege-Friendly version?
		if(ProtegeFriendly) addProtegeFriendlyImports(ont, owlModel);
		else addImports(ont, owlModel);


		//we also add the AnnotationProperty for the defaultLanguage of Protege, otherwise Pellet complains OWL full
		owlModel.createAnnotationProperty("http://protege.stanford.edu/plugins/owl/protege#defaultLanguage");

		//we add the information regarding creators etc that is in the file TheRest.owl
		String theRestPath = physicalURI+"TheRest.owl";
		OntModel owlModel2 = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);
		Ontology ont2 = owlModel2.createOntology(obiPath +"TheRest.owl");

		try {
			owlModel2.read(new FileInputStream(theRestPath), obiPath +"TheRest.owl");
		} catch (FileNotFoundException e) {
			System.out.println("Can't read TheRest.owl");
			e.printStackTrace();
		}

		StmtIterator properties = ont2.listProperties();
		StatementImpl stmt;
		while (properties.hasNext())
		{
			stmt = (StatementImpl) properties.next();
			//we create a resource in the OBI namespace for these properties
			Resource obins = owlModel2.createResource(xmlbase);
			StatementImpl stmt2 = new StatementImpl(obins,stmt.getPredicate(),stmt.getObject());
			owlModel.add(stmt2);
		}



		//set the namespaces prefix mapping
		//we want to have "clean" namespaces declarations, and avoid for example the j:0 from Protege
		//TODO there is probably a way to set those via a Map
		owlModel.getGraph().getPrefixMapping().setNsPrefix("xsd", "http://www.w3.org/2001/XMLSchema#");
		owlModel.getGraph().getPrefixMapping().setNsPrefix("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#");

		owlModel.getGraph().getPrefixMapping().setNsPrefix("rdfs", "http://www.w3.org/2000/01/rdf-schema#");
		owlModel.getGraph().getPrefixMapping().setNsPrefix("owl", "http://www.w3.org/2002/07/owl#");
		owlModel.getGraph().getPrefixMapping().setNsPrefix("daml", "http://www.daml.org/2001/03/daml+oil#");

		owlModel.getGraph().getPrefixMapping().setNsPrefix("dcterms", "http://purl.org/dc/terms/");
		owlModel.getGraph().getPrefixMapping().setNsPrefix("dc", "http://purl.org/dc/elements/1.1/");
		owlModel.getGraph().getPrefixMapping().setNsPrefix("protege", "http://protege.stanford.edu/plugins/owl/protege#");
		owlModel.getGraph().getPrefixMapping().setNsPrefix("protege-dc", "http://protege.stanford.edu/plugins/owl/dc/protege-dc.owl#");
		owlModel.getGraph().getPrefixMapping().setNsPrefix("oboInOwl", "http://www.geneontology.org/formats/oboInOwl#");


		owlModel.getGraph().getPrefixMapping().setNsPrefix("bfo", "http://www.ifomis.org/bfo/1.1#");
		owlModel.getGraph().getPrefixMapping().setNsPrefix("robfo", "http://purl.org/obo/owl/ro_bfo_bridge/1.1#");
		owlModel.getGraph().getPrefixMapping().setNsPrefix("snap", "http://www.ifomis.org/bfo/1.1/snap#");
		owlModel.getGraph().getPrefixMapping().setNsPrefix("span", "http://www.ifomis.org/bfo/1.1/span#");
		owlModel.getGraph().getPrefixMapping().setNsPrefix("ro", "http://www.obofoundry.org/ro/ro.owl#");
		owlModel.getGraph().getPrefixMapping().setNsPrefix("rotoo", "http://purl.org/obo/owl/ro#");
		owlModel.getGraph().getPrefixMapping().setNsPrefix("pato", "http://purl.org/obo/owl/PATO#");
		owlModel.getGraph().getPrefixMapping().setNsPrefix("cell", "http://purl.org/obo/owl/CL#");
		owlModel.getGraph().getPrefixMapping().setNsPrefix("chebi", "http://purl.org/obo/owl/CHEBI#");
		owlModel.getGraph().getPrefixMapping().setNsPrefix("envo","http://purl.org/obo/owl/ENVO#");
		owlModel.getGraph().getPrefixMapping().setNsPrefix("ncbitax","http://purl.org/obo/owl/NCBITaxon#");
			

		//specific case: the empty string means default namespace
		owlModel.getGraph().getPrefixMapping().setNsPrefix("",OBINs);

		//we remove the branch specific namespaces declaration
		owlModel.removeNsPrefix("obi_func");   	
		owlModel.removeNsPrefix("obi_biomat");
		owlModel.removeNsPrefix("obi_denrie");
		owlModel.removeNsPrefix("obi_obsolete");
		owlModel.removeNsPrefix("obi_rest");
		owlModel.removeNsPrefix("obi_rel");
		owlModel.removeNsPrefix("obi_plan");
		owlModel.removeNsPrefix("obi_annot");
		owlModel.removeNsPrefix("obi_data_trans");
		owlModel.removeNsPrefix("obi_quality");
		owlModel.removeNsPrefix("obi_role");
		owlModel.removeNsPrefix("obi_instr");
		owlModel.removeNsPrefix("obi_ext");
		owlModel.removeNsPrefix("obi_extd");
		owlModel.removeNsPrefix("obi_owlfull");
		
		
		return owlModel;
	}
	/**
	 * The method merging the files
	 * @param newFilePath - the path to the file to be created
	 * @param physicalURI - the physical URI where to find the OBI branch files
	 */
	public static void mergeFiles(String newFilePath,String physicalURI, boolean ProtegeFriendly){

		//the output file
		File newFile = new File(newFilePath);

		//delete the file if it already exists  - otherwise we could run into trouble :-)
		if (newFile.exists())	{
			newFile.delete();
		}

		OntModel owlModel = buildMergedFiles(physicalURI,ProtegeFriendly);
		//writes the file
		try {
			writeFile(newFile,owlModel);
		}
		catch (Exception ex) {
			System.out.println("Unable to write the file");
			ex.printStackTrace();
			System.exit(1);
		}



	}



	//For testing purposes
/*
	public final static void main(String[] args) throws Exception  {
		String newFilePath = "/Users/mcourtot/Desktop/FINAL_MERGE.owl";
		//the physical URI of the files
		String physicalURI = "/Users/mcourtot/Desktop/releaseTest/20080529/build/newids/";

		//if we had modification of the branches that are to be kept, we need to give a destination path
		//String destinationURI="Users/melanie/OBIReleases/test/";


		//we check validity of the non-protege friendly version (last argument=false)
		mergeFiles(newFilePath,physicalURI,false);
		//check consistency
		boolean valid = checkConsistency(newFilePath);
		System.out.println("to be committed: "+ valid);
		//we create the protege-friendly version
		String newFilePathProtegeFriendly = "/Users/mcourtot/Desktop/FINAL_MERGE_PROTEGE_FRIENDLY.owl";
		mergeFiles(newFilePathProtegeFriendly,physicalURI,true);
		System.out.println("to be committed: ");



	}*/



}
