/**
 * 
 */
package ca.bccrc.obi;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import com.hp.hpl.jena.ontology.AnnotationProperty;
import com.hp.hpl.jena.ontology.Individual;
import com.hp.hpl.jena.ontology.OntClass;
import com.hp.hpl.jena.ontology.OntModel;
import com.hp.hpl.jena.ontology.OntModelSpec;
import com.hp.hpl.jena.ontology.OntResource;
import com.hp.hpl.jena.ontology.Ontology;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.Statement;
import com.hp.hpl.jena.rdf.model.StmtIterator;
import com.hp.hpl.jena.util.iterator.ExtendedIterator;
import com.hp.hpl.jena.vocabulary.RDFS;


/**
 * @author melanie
 *
 */
/**
 * @author melanie
 *
 */
/**
 * @author melanie
 *
 */
public class BranchesReporter {
	private static String obiPath = "http://purl.obofoundry.org/obo/obi/";

	private static String xmlbase = "http://purl.obofoundry.org/obo/";

	private static List<OntClass> listObsolete = new ArrayList<OntClass>();


	//declaration of the OBI namespace
	private static String OBINs = "http://purl.obofoundry.org/obo/";



	/*
	 * Declare annotation property objects
	 */
	private static AnnotationProperty prefTermAnnPropObj;
	private static AnnotationProperty defAnnPropObj;
	private static AnnotationProperty defSourceAnnPropObj;
	private static AnnotationProperty exampleAnnPropObj;
	private static AnnotationProperty curationStatusAnnPropObj;
	private static AnnotationProperty defEditorAnnPropObj;
	private static AnnotationProperty editorNoteAnnPropObj;
	private static OntClass curationStatusClass;
	private static Individual uncuratedInstance;






	/**
	 * Gets the annotation properties from the file containing them
	 * @param theAnnotationsFile
	 */
	public static void getAnnotationsPropertiesObjects (OntModel owlModel)	{
		//read the annotations file into an OWL model 
		//OntModel annotationsModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);	


		/*try {
			annotationsModel.read(new FileInputStream(theAnnotationsFile), OBINs);
		}
		catch (Exception ex) {
			ex.printStackTrace();
			System.exit(1);
		}*/
		prefTermAnnPropObj = owlModel.getAnnotationProperty(OBINs+"OBI_0000288");	
		defAnnPropObj = owlModel.getAnnotationProperty(OBINs+"OBI_0000291");	
		defSourceAnnPropObj = owlModel.getAnnotationProperty(OBINs+"OBI_0000279");	
		exampleAnnPropObj = owlModel.getAnnotationProperty(OBINs+"OBI_0000287");
		//the curation status annotation property has id 281
		curationStatusAnnPropObj = owlModel.getAnnotationProperty(OBINs+"OBI_0000281");	
		defEditorAnnPropObj = owlModel.getAnnotationProperty(OBINs+"OBI_0000274");	
		editorNoteAnnPropObj = owlModel.getAnnotationProperty(OBINs+"OBI_0000275");	
		//instances of the class curation status, id 266, are used to populate the annotation property
		curationStatusClass= owlModel.getOntClass(OBINs+"OBI_0000266");
		uncuratedInstance = owlModel.getIndividual(OBINs+"OBI_0000328");

	}


	public static String checkComment(Resource term){
		String report ="";
		if(term.getProperty(RDFS.comment)!=null)
		{//System.out.println("literal "+term.getProperty(RDFS.comment).getLiteral());
			if (!(term.getProperty(RDFS.comment).getObject().toString().trim()).equals("@en") && !(term.getProperty(RDFS.comment).getObject().toString().trim()).equals("^^http://www.w3.org/2001/XMLSchema#string") )
				report = "<div class=\"warning\">Warning: rdfs:comment field not empty." +
				"Current value: " + term.getProperty(RDFS.comment).getObject().toString()+ "</div>";
		}
		return report;
	}

	/**
	 * @param term
	 * @return
	 */
	public static String checkPreferredTermAndLabel(Resource term)	{
		String report ="";
		//only one label allowed
		StmtIterator stmtIterLabel = term.listProperties(RDFS.label);
		if (stmtIterLabel.toList().size() >1)
		{
			report = "<div class=\"critical\">CRITICAL: only one label allowed</div>";
		}
		StmtIterator stmtIterPrefTerm = term.listProperties(prefTermAnnPropObj);
		if (stmtIterPrefTerm.toList().size() >1)
		{
			report = "<div class=\"critical\">CRITICAL: only one preferred term allowed</div>";
		}
		//term doesn't have a label
		if(term.getProperty(RDFS.label)==null)
		{
			//if term as a preferred name we copy that as a label
			if(term.hasProperty(prefTermAnnPropObj))
			{
				//term.addLabel(term.getPropertyValue(prefTermAnnPropObj).toString(),"en");
				return report += "<div class=\"warning\">Warning: No label - will be defaulted to the preferred term value</div>";
			}
			else 
			{
				return report += "<div class=\"critical\">CRITICAL: No label or preferred term</div>";
			}
		}
		else //term has a label
		{

			//term doesn't have a preferred term: we copy the label as preferred term
			if(!term.hasProperty(prefTermAnnPropObj))
			{
				//null literals are forbidden since jena 2.0
				//if(term.getLabel(null)!=null)
				//term.addProperty(prefTermAnnPropObj,term.getProperty(RDFS.label).getString().trim());
				return report += "<div class=\"warning\">Warning: No preferred term - will be defaulted to the label value</div>";
			}
			//term has label and preferred term
			else return report;


		}



	}

	/**
	 * @param term
	 * @return
	 */
	public static String checkDefinition(Resource term)
	{

		if(!term.hasProperty(defAnnPropObj))
		{
			//term.addProperty(defAnnPropObj,"definition pending");
			return "<div class=\"critical\">CRITICAL: No definition</div>";

		}
		else {
			StmtIterator stmtIterDef = term.listProperties(defAnnPropObj);
			if (stmtIterDef.toList().size() >1){
				return "<div class=\"critical\">CRITICAL: only one definition allowed</div>";
			}
			else return "";
		}
	}


	/**
	 * @param term
	 * @return
	 */
	public static String checkCurationStatus(Resource term)	{

		if(!term.hasProperty(curationStatusAnnPropObj))
		{
			//term.addProperty(curationStatusAnnPropObj,uncuratedInstance);
			return "<div class=\"warning\">Warning: No curation_status - will be defaulted to uncurated</div>";

		}
		else {
			StmtIterator stmtIterCuration = term.listProperties(curationStatusAnnPropObj);
			/*for (StmtIterator stmtIterCuration = term.listProperties(curationStatusAnnPropObj); stmtIterCuration.hasNext(); ) 
			{
				Statement curationStatus = (Statement) stmtIterCuration.next();
				System.out.println("curation: "+ curationStatus.getObject().toString());
			}*/
			int sizeIterator = stmtIterCuration.toList().size();
			if (sizeIterator >1){
				//System.out.println ("size = "+sizeIterator );
				return "<div class=\"critical\">CRITICAL: only one curation status allowed</div>";
			}
			else return "";
		}

	}

	/**
	 * @param term
	 * @return
	 */
	public static String checkDefinitionEditor(Resource term)
	{

		if(!term.hasProperty(defEditorAnnPropObj))

		{
			//term.addProperty(defEditorAnnPropObj,"OBI");
			return "<div class=\"critical\">CRITICAL: No definition editor</div>";	

		}
		else return "";
	}


	public static String checkDefinitionSource(Resource term)
	{

		if(!term.hasProperty(defSourceAnnPropObj))
		{
			//term.addProperty(defSourceAnnPropObj,"source pending");
			return "<div class=\"critical\">CRITICAL: No definition source</div>";	

		}
		else return "";
	}
	/**
	 * @param term the OntClass to annotate
	 */
	//TODO list of required annotations and default values to be externalized
	/**
	 * @param term
	 * @return
	 */
	public static String checkAnnotations(Resource term){
		String report = "";
		if (checkPreferredTermAndLabel(term) != "")
			report += checkPreferredTermAndLabel(term);		

		if (checkCurationStatus(term) != "")
			report += checkCurationStatus(term);
		if (checkDefinitionEditor(term) != "")
			report += checkDefinitionEditor(term);
		if (checkDefinitionSource(term) != "")
			report+=checkDefinitionSource(term);
		if (checkDefinition(term) != "")
			report+= checkDefinition(term);
		if (checkComment(term) != "")
			report+= checkComment(term);
		return report;


	}


	/**
	 * @param branchName
	 * @param listClasses
	 * @return
	 */
	public static String buildReport(String branchName, List<OntResource> listClasses)	{

		String reportTotal = writeHeader(branchName);
		for (Iterator<OntResource> it = listClasses.iterator(); it.hasNext(); ) {

			OntResource thisClass = it.next();

			//only for OBI classes
			int index = thisClass.getLocalName().indexOf("OBI");
			if (index != -1)
			{
				String classReport = checkAnnotations(thisClass);
				if (classReport != ""){
					reportTotal += "<div class=\"termreport\">\n"+
					"<div class=\"termid\">\n" +
					"<span class=\"id\"><a href=\"http://purl.obofoundry.org/obo/"+thisClass.getLocalName()+"\">"+thisClass.getLocalName()+"</a>: </span>\n";
					reportTotal +="<span class=\"name\">"+((OntResource) thisClass).getLabel(null)+"</span>\n";
					reportTotal+="</div>\n";
					reportTotal += classReport;
					reportTotal += "</div>\n"; 

				}
			}

		}

		reportTotal += "</body>"+
		"</html>";

		return reportTotal;
	}


	/**
	 * Writes the report to a file
	 * @param reportPath - where to write the report
	 * @param report - the string to be written
	 */
	public static void writeReport(String reportPath, String report)	{
		File newReportFile = new File(reportPath);


		try {

			//delete the file if it already exists  - otherwise we could run into trouble :-)
			if (newReportFile.exists())	{
				newReportFile.delete();
			}

			FileWriter fw = new FileWriter(newReportFile);

			fw.write(report);
			fw.flush();
			fw.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * given a class, puts its subclasses in listObsolete
	 * calls itself recursively until the end of the obsolete classes
	 * @param obsoleteClassRoot - the class of which we want to list subclasses
	 */
	public static void getObsoleteSubclasses(OntClass obsoleteClassRoot)  {

		try {
			for (Iterator allClassTermsInModel = obsoleteClassRoot.listSubClasses(true); allClassTermsInModel.hasNext();)  {
				OntClass obsoleteClass = (OntClass) allClassTermsInModel.next();
				listObsolete.add(obsoleteClass);
				getObsoleteSubclasses(obsoleteClass);
			}
		}
		catch (Exception e) {
			e.printStackTrace();
			System.exit(1);
		}


	}



	/**
	 * @param branchModel - the OntModel representing the current branch
	 * @param branchName - the name of the current branch
	 * @param owlModel - the merged OntModel
	 * @return the string representing the report to be written for this branch
	 */
	public static String checkBranchAnnotations(OntModel branchModel, String branchName, OntModel owlModel){

		//get the list of named classes
		ExtendedIterator classes = branchModel.listNamedClasses();
		List<OntResource> listClasses = classes.toList();


		//get the list of object properties
		ExtendedIterator classes1 = branchModel.listObjectProperties();
		List<OntResource> listClasses1 = classes1.toList();

		//add both lists
		listClasses.addAll(listClasses1);

		//get the list of annotation properties
		ExtendedIterator classes2 = branchModel.listAnnotationProperties();
		List<OntResource> listClasses2 = classes2.toList();

		//add to the previous list
		listClasses.addAll(listClasses2);

		//get dtatatype properties
		ExtendedIterator classes3 = branchModel.listDatatypeProperties();
		List<OntResource> listClasses3 = classes3.toList();

		//add to the previous list
		listClasses.addAll(listClasses3);


		//we don't want to list oboslete terms: we need to get all the children of obsolete and remove them from the list
		//we need to explicitly load the imports
		//obsoleteClass is defined by OBO_REL, which is in turn imported
		owlModel.loadImports();

		//get list of all obsolete classes recursively
		OntClass obsoleteClassRoot = owlModel.getOntClass("http://www.geneontology.org/formats/oboInOwl#ObsoleteClass");
		getObsoleteSubclasses(obsoleteClassRoot);

		//remove obsolete classes from the total list
		listClasses.removeAll(listObsolete);
		//now that we have the list of OntResources to be checked, we go ahead and pass that list to the checking script
		String reportTotal = buildReport(branchName,listClasses);
		return reportTotal;
	}



	/**
	 * Writes the report per branch
	 * @param branchName - the name of the branch we are writing the report about
	 * @return the HTML code generating the header of the report page
	 */
	public static String writeHeader (String branchName){
		return "<html><head><title>"+branchName+" Report</title>"+
		"<style type=\"text/css\">"+
		".id { font-weight:bold; font-size:large}"+
		".name { font-style:italic; font-size:large}"+
		".critical { font-style:bold;color:#f00;margin-left:5px}"+
		".warning { color:#333;margin-left:5px}"+
		".termreport { margin-left:5px;margin-bottom:20px }"+
		".branchreport { font-size:x-large;margin-bottom:20px }"+
		"</style>"+
		"</head>"+
		"<body>"+
		"<table width=\"100%\" BACKGROUND='http://ashby.csail.mit.edu/303-images/header-main-b-blue.png' > "+
		"<td align=\"left\">	 <a href=\"http://obi.sourceforge.net/\"><img src=\"http://ashby.csail.mit.edu/303-images/obi-blue.png\" alt=\"The Ontology for Biomedical Investigations\" id=\"cc-title\" border=\"0\"/></a></td><td align=\"right\">"+
		"<a href=\"http://sciencecommons.org\"><img src=\"http://ashby.csail.mit.edu/303-images/sciencecommonsblue.gif\" alt=\"science commons\" id=\"cc-title\" border=\"0\"/></a></td></table>"+
		"<div class=\"branchreport\">"+branchName+"</div>";

	}

	/**
	 * @param branchesNames - the array containing the names of the branches
	 * @param physicalURI - the physical location where to fetch the branch files
	 * @param theAnnotationsFileName - the name of the file containing the annotations Properties
	 * @param reportPath - where to write the report
	 * @param owlModel - the merged OntModel
	 */
	public static void produceBranchReport (List<String> branchesNames, String physicalURI, String theAnnotationsFileName, String reportPath, OntModel owlModel)	{

		for(String s : branchesNames) {

			try {
				String branchPath = physicalURI +s+".owl";

				OntModel branchModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);	
				branchModel.read(new FileInputStream(branchPath), obiPath+s+".owl");

				String report = checkBranchAnnotations(branchModel,s, owlModel);
				String reportFilePath = reportPath + s + "_report.html";
				writeReport(reportFilePath, report);

			}
			catch (Exception ex) {
				ex.printStackTrace();
				System.exit(1);
			}
		}
	}


	/**
	 * Gets a list of instances in an OntModel
	 * @param owlModel - the merged model: we can get instances only when the class is declared, so we have to do it on the merged file
	 * @param reportPath - where to write the report
	 */
	public static void getInstances(OntModel owlModel, String reportPath){
		ExtendedIterator instances = owlModel.listIndividuals();

		String reportTotal = buildReport("Instances",instances.toList());

		String reportFilePath = reportPath + "Instances" + "_report.html";
		writeReport(reportFilePath, reportTotal);

	}





	/* testing purposes */
	public final static void main(String[] args) throws Exception  {

		String physicalURI = "/Users/melanie/Desktop/OBI/SVN/obi/trunk/src/ontology/branches/";
		String theAnnotationsFileName = "AnnotationProperty.owl";


		String theAnnotationsFilePath = physicalURI + theAnnotationsFileName;

		//the file containing the declaration of the annotation properties
		File theAnnotationsFile = new File(theAnnotationsFilePath);

		
		
		
		List<String> branchesNames = new ArrayList<String>();
		branchesNames.add("Biomaterial");
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

		//instances
		//branchesNames.add("DataFormatSpecification");


		String reportPath = "/Users/melanie/Desktop/reports/";

		//some things need to be done on the whole OBI
		//e.g. get obsolete list of classes
		//get instances
		OntModel owlModel = OBIMerger.buildMergedFiles(physicalURI,false);
	
		
		for (ExtendedIterator classes2 = owlModel.listAnnotationProperties(); classes2.hasNext(); ) 
		{
			Property annotation = (Property) classes2.next();
			if (annotation.getProperty(RDFS.label)!=null)
			{
			System.out.println("annotation: "+ annotation.getURI() + " "+ annotation.getProperty(RDFS.label).getObject().toString());
			}
			else System.out.println("annotation: "+ annotation.getURI());
		}
		
		
		//retrieves annotations properties objects - we should get them from the whole model, they don't have to be defined in the AnnotationProperty.owl file
		getAnnotationsPropertiesObjects(owlModel);

		getInstances(owlModel, reportPath);

		produceBranchReport (branchesNames, physicalURI, theAnnotationsFileName, reportPath, owlModel);



		System.out.println("Done");


	}



}



