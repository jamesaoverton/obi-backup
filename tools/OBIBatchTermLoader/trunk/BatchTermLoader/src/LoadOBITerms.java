import edu.stanford.smi.protegex.owl.model.*;
import edu.stanford.smi.protegex.owl.ProtegeOWL;
import edu.stanford.smi.protegex.owl.jena.*;

import java.util.*;
import java.io.*;
import java.util.Properties;
import java.lang.Integer;

public class LoadOBITerms{
	/**
	 * @param args
	 * First arg=ontology file location
	 * Second arg=term file name
	 * Third arg=outputFileName
	 * Fourth arg=code function 
	 */

	public static void main(String[] args) {
		
		if(null == args || args.length != 5) {
			System.out.println("Not all args found");
			System.exit(1);
		}

		//Debug - print out commandline arguements
		System.out.println("FIRST-ARG: Ontology file location: "+args[0]+
				"\nSECOND-ARG: Term file name/location: "+args[1]+
				"\nTHIRD-ARG: Output file name/location: "+args[2]+
				"\nFOURTH-ARG: OBI Identifier value: "+args[3]+
				"\nFIFTH ARG: Properties file location: "+args[4]);
		
		//File uri = new File(args[0]);
		File uri = new File("/Users/whetzel/eclipseWorkspace/OBIBatchTermLoader/OBI_v0.6.4-TEST.owl");
		JenaOWLModel model = openOWLFile(uri);
		
		String inputFile = args[1];
		BufferedReader reader = openReader(inputFile);
		
		String propsFileLocation = args[4];  //"/Users/whetzel/eclipseWorkspace/BatchTermLoader/filename.properties";
		Properties props = getProps(propsFileLocation);
		
		Collection allClassTermsInModel = getAllTerms(model);
		
		HashMap<String,String> map = createMap(model, allClassTermsInModel);
		
		String obiIntValue = args[3];
		
//		FROM CreateTree CODE, replaces in part 'processTextFile'
//		May need 'map' to get parentIdentifier to create Term object with this value		
		HashMap allClassTermsInFile = readTextFile(reader, obiIntValue, props); //read and store contents of inputFile as Term objects
		
		buildTreeAllTerms(allClassTermsInFile);
		loadAllTerms(allClassTermsInFile, map, model);
		
		LoadOBITerms lt = new LoadOBITerms();
		String outputFileName = args[2];
		lt.saveNewModel(model, outputFileName);
		System.out.println("\n=-=-=-= End of program =-=-=-=");
	
	} //End of main
	
	
	/**
	 * Open OWL file and create JenaOWLModel object
	 * @param owlFileName
	 * @return
	 */
	public static JenaOWLModel openOWLFile(File owlFileName) {
		JenaOWLModel owlModel = ProtegeOWL.createJenaOWLModel();
		try {
			owlModel = ProtegeOWL.createJenaOWLModelFromInputStream(new FileInputStream(owlFileName));
			return owlModel;
	      }
	      catch (Exception ex) {
	    	  ex.printStackTrace();
	    	  System.exit(1);
	      }
	      return  null;
	}
	

	/**
	 * Create object to read in term file containing ontology terms 
	 * and annotation information
	 * @param inputFile
	 * @return
	 */
	public static BufferedReader openReader (String inFile) {
		BufferedReader input = null;
		try {
			input = new BufferedReader(new FileReader(inFile));
		}
		catch (FileNotFoundException ex) {
			ex.printStackTrace();
			System.exit(1);
		}
		return input;
	}


	/**
	 * Read in properties file, this file specifies the mapping 
	 * of column headers to the annotation property names
	 * @param propsFile
	 * @return
	 */
	public static Properties getProps(String propsFile)  {
		Properties defaultProps = new Properties();
		FileInputStream in = null;
		try {
			in = new FileInputStream(propsFile);
			
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			System.exit(1);
		}
		try {
			defaultProps.load(in);
			String value = defaultProps.getProperty("curation_status");  //DEBUG statement
			System.out.println("PropValue: "+value);
		} catch (IOException e) {
			e.printStackTrace();
			System.exit(1);
		}
		try {
			in.close();
		} catch (IOException e) {
			e.printStackTrace();
			System.exit(1);
		}
		return defaultProps;
	}
	
	
	
	/**
	 * Get all Class terms from JenaOWLModel object
	 * @param m
	 * @return
	 */
	public static Collection getAllTerms(JenaOWLModel m)  {
		try {
			String rootName = "bfo:Entity";
			OWLNamedClass rootObj = m.getOWLNamedClass(rootName);
			System.out.println("Root: "+rootObj);
			Collection allClassTermsInModel = rootObj.getSubclasses(true);
			int termSize = allClassTermsInModel.size();
			System.out.println("Number of Terms: "+termSize);
			return allClassTermsInModel;	
		}
		catch (Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
		return null;
	}

	
	/**
	 * Create HashMap of value of rdfs:label to value of rdf:ID field
	 * @param m the Jena OWL model
	 * @param terms the set of all OWL Class terms in the Jena OWL model
	 * @return
	 */
	public static HashMap<String,String> createMap(JenaOWLModel m, Collection terms) {
	//public static void createMap(JenaOWLModel m, Collection terms) {
		try {
			HashMap<String, String> map = new HashMap<String, String>(); //Commented out 4/21/2007
			//TermIDMap map = new TermIDMap(); //NEW STATEMENT
			for (Object term: terms) {
				//System.out.println("Debug-Term: "+term);
				RDFSClass termObj = (RDFSClass) term;			
				//System.out.println("Debug-RDFSClass: "+termObj);
				String termString = termObj.getBrowserText();
				//System.out.println("Term: "+termString);
				
				//Collection labels = termObj.getLabels();
			    //System.out.println("Labels: "+labels);
				for (Iterator i = termObj.getLabels().iterator(); i.hasNext();)  {
					String label = i.next().toString();
					//Assumption is that there is only "1" rdfs:label for each term based on the ontology design
					//System.out.println("Key: "+label);	
					map.put(label, termString);
					
					//Debug comments
					//Object value = map.get(label);
					//System.out.println("Value: "+value);
					//Collection mappedTerms = map.values();
					//System.out.println("MappedTerms: "+mappedTerms);
				}
			}
			int mapSize = map.size();
			System.out.println("Map Size: "+mapSize);
			return map;  //Commented out
		}
		catch (Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
		return null;
	}
	

	/**
	 * Read in contents of term file and store information as a Term object
	 * @param r
	 * @return
	 */
	public static HashMap readTextFile(BufferedReader r, String obiValue, Properties p) {
		/**
		 * Declare method variables for line number of term 
		 * file and to index the array of column headers
		 */
		int lineCount=0;
		int preferredNameIndex = -1;
		int parentTermIdentifierIndex = -1;
		int parentTermNameIndex = -1;
		int definitionIndex = -1;
		int definitionSourceIndex = -1;
		int curationStatusIndex = -1;  //multiple curationStatus columns may exist in input file
		int exampleOfUsageIndex = -1;
		int defEditorIndex = -1;
		int editorNoteIndex = 0; // multiple editorNote columns may exist in input file
		int externalClassIndex = -1;
		
		//Declare vars here since they are now in if/else and needed outside that scope
		String termName = null;
		String parentTerm = null;
		String definition = null;
		String definitionSource = null;
		String defEditor = null;
		String externalClass = null;
		String curationStatus = null;
		String exampleUsage = null;
		ArrayList<Integer> curationStatusList = new ArrayList<Integer>();
		String editorNote = null;
		ArrayList<Integer> editorNoteList = new ArrayList<Integer>();
		
		
		int obiInitialInt=Integer.parseInt(obiValue);
			System.out.println("***Value of obiInt: "+obiInitialInt);
		HashMap<String,Term> allTerms = new HashMap<String,Term>();
		
		try {
			String line = r.readLine();
			while (line != null) {
				lineCount++;
				System.out.println("\n=-=-=-=-=\nLineCount: "+lineCount);
				
				/**
				 * Map contents of column headers (first row) 
				 * in term file to property file
				 */
				//TODO: Add check that file contains column headers
				// 		and get the total num of cols specified in props file
				if (lineCount <= 1) {
					System.out.println("Processing Header line...");
					String[] header = line.split("\\t");
					int headerLength = header.length;
					System.out.println("First item in header: "+header[1]+"\n");
					for (int i = 0; i<headerLength; i++)  {
						System.out.println("In loop, headerValue: "+"\""+header[i]+"\"");
						if (header[i].equals(p.getProperty("preferred_term"))) {
							String preferredName = header[i];
							preferredNameIndex = i;
							System.out.println("preferredName: "+preferredName+
									", preferredNameIndex: "+preferredNameIndex+"\n");
						}
						if (header[i].equals(p.getProperty("parent_identifier"))) {
							String parentTermIdentifier = header[i];
							parentTermIdentifierIndex = i;
							System.out.println("parentTermIdentifier: "+parentTermIdentifier+
									", parentTermIdentifierIndex: "+parentTermIdentifierIndex+"\n");
						}
						if (header[i].equals(p.getProperty("parent_name"))) {
							String parentTermName = header[i];
							parentTermNameIndex = i;
							System.out.println("parentTermName: "+parentTermName+
									", parentTermNameIndex: "+parentTermNameIndex+"\n");
						}
						if (header[i].equals(p.getProperty("definition"))) {
							String definitionHeader = header[i];
							definitionIndex = i;
							System.out.println("definition: "+definitionHeader+
									", definitionIndex: "+definitionIndex+"\n");
						}
						if (header[i].equals(p.getProperty("definition_citation"))) {
							String definitionSourceHeader = header[i];
							definitionSourceIndex = i;
							System.out.println("definitionSource: "+definitionSourceHeader+
									", definitionSourceIndex: "+definitionSourceIndex+"\n");
						}
						
						if (header[i].equals(p.getProperty("definition_editor"))) {
							String defEditorHeader = header[i];
							defEditorIndex = i;
							System.out.println("defEditor: "+defEditorHeader+
									", defEditorIndex: "+defEditorIndex+"\n");
						}
						
						if (header[i].equals(p.getProperty("external_class"))) {
							String extClassHeader = header[i];
							externalClassIndex = i;
							System.out.println("extClass: "+extClassHeader+
									", extClassIndex: "+externalClassIndex+"\n");
						}
						
						if (header[i].equals(p.getProperty("example_of_usage"))) {
							String exampleOfUsageHeader = header[i];
							exampleOfUsageIndex = i;
							System.out.println("exampleOfUsage: "+exampleOfUsageHeader+
									", extClassIndex: "+exampleOfUsageIndex+"\n");
						}
						
						if (header[i].equals(p.getProperty("curation_status"))) {
							String curationStatusHeader = header[i];
							curationStatusIndex = i;
							System.out.println("curationStatus: "+curationStatusHeader+
									", curationStatusIndex: "+curationStatusIndex);
							//Since there can be more than 1 of these types of properties, add values to array
							curationStatusList.add(curationStatusIndex);
							System.out.println("Index values for curation_status: "+curationStatusList+
									", Size: "+curationStatusList.size()+"\n");
						}
						
						if (header[i].equals(p.getProperty("editor_note"))) {
							String editorNoteHeader = header[i];
							editorNoteIndex = i;
							System.out.println("editorNote: "+editorNoteHeader+
									", editorNoteIndex: "+editorNoteIndex);
							//Since there can be more than 1 of these types of properties, add values to array
							editorNoteList.add(editorNoteIndex);
							System.out.println("Index values for editor_note: "+editorNoteList+
									", Size: "+editorNoteList.size()+"\n");
						}
					} //End of for loop
				} //End of if loop for processing first line of file
				else {
					System.out.println("Processing data lines in file...");
					String[] cols = line.split("\\t");
					//TODO: Check that size of cols for each line is the same number of columns in props file
					//		Does this number match that in the first line, if not something is missed in the input line???
					
					/**
					 * Map Columns from input file to the corresponding object, term name or annotation property
					 */
					//Required annotation property
					if (preferredNameIndex >= 0) {
						termName = cols[preferredNameIndex].trim(); 	
					}
					else {
						System.out.println("ERROR: Column for preferred_name is either not in the " +
						"inputFile or not specified in the properties file. This error needs to be" +
						"before loading the file");
						System.out.println("=-=-=-= ENDING PROGRAM =-=-=-=-=");
						System.exit(1);
					}
					//Required annotation property
					if (parentTermNameIndex >= 0) {
						parentTerm = cols[parentTermNameIndex].trim();
						System.out.println("Mapped column: \'parent_name\' to: "+"'"+parentTerm+"'"); //use this with hashmap
					}
					else {
						System.out.println("ERROR: Column for parent_name is either not in the " +
								"inputFile or not specified in the properties file. This error needs to be" +
								"before loading the file");
						System.out.println("=-=-=-= ENDING PROGRAM =-=-=-=-=");
						System.exit(1);
					}
					//Required annotation property
					if (definitionIndex >= 0) {
						definition = cols[definitionIndex].trim();
						System.out.println("Mapped column: \'definition\' to: "+"'"+definition+"'");
					}
					else {
						System.out.println("ERROR: Column for definition is either not in the " +
								"inputFile or not specified in the properties file. This error needs to be" +
								"before loading the file");
						System.out.println("=-=-=-= ENDING PROGRAM =-=-=-=-=");
						System.exit(1);
					}
					//Required annotation property
					if (definitionSourceIndex >= 0) {
						definitionSource = cols[definitionSourceIndex].trim();
						System.out.println("Mapped column: \'definitionSource\' to: "+"'"+definitionSource+"'");
					}
					else {
						System.out.println("ERROR: Column for definition_source either not in the " +
								"inputFile or not specified in the properties file. This error needs to be" +
							"before loading the file");
						System.out.println("=-=-=-= ENDING PROGRAM =-=-=-=-=");
						System.exit(1);
					}
					//Required annotation property
					if (defEditorIndex >= 0) {
						defEditor = cols[defEditorIndex].trim();
						System.out.println("Mapped column: \'defEditor\' to: "+"'"+defEditor+"'");
					}
					else {
						System.out.println("Column for definition_source is either not in the " +
						"inputFile or not specified in the properties file.");
						System.exit(1);  //May need to add this field to term input file and props file
					}
					//Required annotation property
					if (exampleOfUsageIndex >= 0) {
						exampleUsage = cols[exampleOfUsageIndex].trim();
						System.out.println("Mapped column: \'example_of_usage\' to: "+"'"+exampleUsage+"'");
					}
					else {
						System.out.println("ERROR: Column for example_of_usage is either not in the " +
								"inputFile or not specified in the properties file. This error needs to be" +
								"before loading the file");
								System.exit(1);
					}
					//Optional annotation property
					if (externalClassIndex >= 0) {
						externalClass = cols[externalClassIndex].trim();
						System.out.println("Mapped column: \'externalClass\' to: "+"'"+externalClass+"'");
					}
					else {
						System.out.println("Column for external_class is either not in the " +
							"inputFile or not specified in the properties file.");
					}

					//TODO: Locate this further down in code?
					obiInitialInt++;
					String obiIdspace = "OBI_";
					String obiIdentifier = obiIdspace+obiInitialInt;
					System.out.println("****VALUE of obiInt after auto-increment: "+obiInitialInt+" OBI Identifier: "+obiIdentifier);
					
					//COPIED AND MODIFIED FROM LoadTerms.java
					//Required annotation property, term input file must have at least 1 column that maps to curation_status
					ArrayList<String> allCurationStatusValues = new ArrayList<String>();
					if (curationStatusIndex >=0) {
						for (int x=0; x<curationStatusList.size(); x++) {
							//OWLDatatypeProperty curationStatusAnnPropObj = m.getOWLDatatypeProperty(curationStatusAnnProp);
							int listIndex = curationStatusList.get(x);
							curationStatus = cols[listIndex].trim();
							allCurationStatusValues.add(curationStatus);
							System.out.println("CS: "+curationStatus+", Index: "+listIndex+", TotalSize:"+curationStatusList.size());
//							if (!curationStatus.equals(none)) {  //This case should not occur in the term file
//								childClass.addPropertyValue(curationStatusAnnPropObj, curationStatus);
//								System.out.println("\tAdded: "+curationStatus);
//							}
//							else {
//								System.out.println("\tCS value \"none\" not added for this term.");
//								System.out.println("ERROR: The value \"none\" is not an appropriate property. This error needs to be" +
//								"before loading the file");
//								System.out.println("=-=-=-= ENDING PROGRAM =-=-=-=-=");
//								System.exit(1);
//							}
						}
						System.out.println("All CS: "+allCurationStatusValues);
					}
					else {
						System.out.println("ERROR: Column for curation_status is either not in the " +
								"inputFile or not specified in the properties file. This error needs to be" +
								"before loading the file");
						System.out.println("=-=-=-= ENDING PROGRAM =-=-=-=-=");
						System.exit(1);
					}

					//Optional annotation property
					ArrayList<String> allEditorNoteValues = new ArrayList<String>();
					for (int x=0; x<editorNoteList.size(); x++) {
						//OWLDatatypeProperty editorNoteAnnPropObj = m.getOWLDatatypeProperty(editorNoteAnnProp);
						int listIndex = editorNoteList.get(x); 
						editorNote = cols[listIndex].trim();
						allEditorNoteValues.add(editorNote);
						System.out.println("ED: "+editorNote+", Index: "+listIndex+", TotalSize:"+editorNoteList.size());
//						if (!editorNote.equals(none))  {
//							childClass.addPropertyValue(editorNoteAnnPropObj, editorNote);
//							System.out.println("\tAdded value: "+"\""+editorNote+"\"");
//						}
//						else {
//							System.out.println("\tED value \"none\" not added for this term.");
//						}
					}
					System.out.println("All ED: "+allEditorNoteValues);
					
					/*
					 * Create Term object for the line read in from file
					 */
					Term term = new Term(termName, obiIdentifier, parentTerm, definition, definitionSource, defEditor, 
										exampleUsage, externalClass, allCurationStatusValues, allEditorNoteValues);
					allTerms.put(termName, term);
					System.out.println("Term: "+term.termName+" Parent: "+term.parentTermName+" Kids: "+term.kids);
				}
				line = r.readLine();
			}
			return allTerms;
		}
		catch (IOException e) {
			e.printStackTrace();
			System.exit(1);
		}
		return null;
	}
	
	
	/**
	 * Build tree
	 * @param allTerms
	 */
	@SuppressWarnings("unchecked")
	private static void buildTreeAllTerms(HashMap allTerms) {
		System.out.println("\nContents of allTerms: "+allTerms);
		//Iterate through allTerms, i.e. all values in HashMap allTerms
		Collection<Term> allTermsValues = allTerms.values();		
		for(Iterator itr = allTermsValues.iterator( ); itr.hasNext( );) {
			Term t = (Term) itr.next();
			System.out.println("\nTerm Info Before Setting Kids: "+t.termName+"\n\tParent: "+t.parentTermName+"\n\thasParent: "+t.hasParent+"\n\tTermObj: "+t);
			//Use parentTermName to find the parent object for this term in the allTerms HashMap
			Term parentTermObj = (Term)allTerms.get(t.parentTermName);
			System.out.println("\tparentTermObj: "+parentTermObj);
			if(!(parentTermObj==null)) {  //this means that the parent exists in the JenaOWLModel and is in the allClassTermsInModel HashMap
				t.hasParent=true;
				System.out.println("\tParentTermObj: "+parentTermObj+
									"\n\tThis is a child node");
				//Set parent-child relationship
				System.out.println("Set parent-child relationship");
				if (parentTermObj.kids == null) { //no kid terms have been set
					parentTermObj.kids = new Vector<Term>();
					parentTermObj.kids.add(t);  //the parent term now has one kid Term object	
					System.out.println("Term Info After Setting Kids: "+t.termName+"\n\tParent: "+t.parentTermName+"\n\thasParent: "+t.hasParent+"\n\tTermObj: "+t);
				}
				else { //add more kid terms
					parentTermObj.kids.add(t);  	
					System.out.println("Term Info After Setting Kids: "+t.termName+"\n\tParent: "+t.parentTermName+"\n\thasParent: "+t.hasParent+"\n\tTermObj: "+t);
				}
				System.out.println("Parent Term Object: "+parentTermObj.termName+", Kids of Parent Term Object"+parentTermObj.kids+"\n\n");
			}
			else {
				System.out.println("Term: "+t.parentTermName+" is a root node, i.e. exists in the OWL file");
			}
		}
	}

	
	/**
	 * Iterate through terms to find those with parent in the JenaOWLModel and add kids to JenaOWLModel
	 * @param allTerms
	 */
	@SuppressWarnings("unchecked")
	private static void loadAllTerms(HashMap allTerms, HashMap<String,String> map, JenaOWLModel model) {
		Collection<Term> allTermsValues = allTerms.values();
		for(Iterator itr = allTermsValues.iterator( ); itr.hasNext( );) {
			Term t = (Term) itr.next();
			if(t.hasParent==false)  {
				System.out.println("Term with parent in JenOWLModel: "+t.termName);
				addToFile(t,map,model);
			}
			else {
				System.out.println("\tThis is a child term: "+t.termName+" skip...");
			}
		}
	}
	
	
	/**
	 * Load terms into JenaOWLModel
	 * @param t
	 */
	private static void addToFile (Term t, HashMap<String,String> map,JenaOWLModel m) {
		/*
		 * Declare annotation property variables. Theese are the actual annotation 
		 * property names that are in the ontology file and therefore the JenaOWLModel.
		 */
		String prefTermAnnProp = "preferred_term";
		String defAnnProp = "definition";
		String defSourceAnnProp = "definition_citation";
		String exampleAnnProp = "example_of_usage";
		String curationStatusAnnProp = "curation_status";
		String defEditorAnnProp = "definition_editor";
		String editorNoteAnnProp = "editor_note";
		//String externalClassAnnProp = "external_class";
		
		/*
		 * Get annotation property object from JenaOWLModel
		 */
		OWLDatatypeProperty prefTermAnnPropObj = m.getOWLDatatypeProperty(prefTermAnnProp);
		OWLDatatypeProperty defAnnPropObj = m.getOWLDatatypeProperty(defAnnProp);
			//System.out.println("Property: "+defProp); //Debugging comment
		OWLDatatypeProperty defSourceAnnPropObj = m.getOWLDatatypeProperty(defSourceAnnProp);
		OWLDatatypeProperty exampleAnnPropObj = m.getOWLDatatypeProperty(exampleAnnProp);
		OWLDatatypeProperty defEditorAnnPropObj = m.getOWLDatatypeProperty(defEditorAnnProp);
		//OWLDatatypeProperty externalClassAnnPropObj = m.getOWLDatatypeProperty(externalClassAnnProp);
		//OWLDatatypeProperty curationStatusAnnPropObj = m.getOWLDatatypeProperty(curationStatusAnnProp);
		//OWLDatatypeProperty editorNoteAnnPropObj = m.getOWLDatatypeProperty(editorNoteAnnProp);
		
		String lang = "en";
		String none = "none";
		
		/*
		 * Load information into Jena OWL Model
		 */
		System.out.println("***ADD Term: "+t.termName+", "+ t.obiIdentifier+" to OWL file");
		String parentIdentifier = map.get(t.parentTermName).toString();
		System.out.println("OBI ParentIdentifier: "+parentIdentifier+" is in the HashMap");
		OWLNamedClass parentClass = m.getOWLNamedClass(parentIdentifier); //need larger scope
			System.out.println("\tParentClass: "+parentClass);
		OWLNamedClass childClass = m.createOWLNamedSubclass(t.obiIdentifier, parentClass);
		
		//Add annotation properties
		childClass.setPropertyValue(prefTermAnnPropObj, t.termName);
		childClass.addLabel(t.termName, lang); //TODO: Should code load rdfs:label, TW-yes, for use with general software;ObiDev-???
		childClass.setPropertyValue(defAnnPropObj, t.definition);
		childClass.setPropertyValue(defSourceAnnPropObj, t.definitionSource);
		childClass.setPropertyValue(exampleAnnPropObj, t.example);
		childClass.setPropertyValue(defEditorAnnPropObj, t.definitionEditor);
		
		//TODO: Should this check that CS is in file be in an earlier method??? 
		System.out.println("\tAll CS values: "+t.curationStatus);
		if (t.curationStatus.size() >=0) {
			for (int x=0; x<t.curationStatus.size(); x++) {
				OWLDatatypeProperty curationStatusAnnPropObj = m.getOWLDatatypeProperty(curationStatusAnnProp);
				String curationStatusSingleValue = t.curationStatus.get(x).trim();
				System.out.println("\tCS: "+curationStatusSingleValue);
				if (!curationStatusSingleValue.equals(none)) {  //this case should not occur
					childClass.addPropertyValue(curationStatusAnnPropObj, curationStatusSingleValue);
					System.out.println("\t\tAdded: "+curationStatusSingleValue);
				}
				else {
					System.out.println("\tCS value \"none\" not added for this term.");
					System.out.println("ERROR: The value \"none\" is not an appropriate property. This error needs to be" +
					"before loading the file");
					System.out.println("=-=-=-= ENDING PROGRAM =-=-=-=-=");
					System.exit(1);
				}
			}
		}
		else {
			System.out.println("ERROR: Column for curation_status is either not in the " +
					"inputFile or not specified in the properties file. This error needs to be" +
			"before loading the file");
			System.out.println("=-=-=-= ENDING PROGRAM =-=-=-=-=");
			System.exit(1);
		}
		
		//Optional annotation property, exists as ArrayList
		System.out.println("\tAll ED values: "+t.editorNote);
		if (t.editorNote.size() >=0) { 
			for (int x=0; x<t.editorNote.size(); x++) {
				OWLDatatypeProperty editorNoteAnnPropObj = m.getOWLDatatypeProperty(editorNoteAnnProp);
				String editorNoteSingleValue = t.editorNote.get(x).trim(); 
				System.out.println("\tED: "+editorNoteSingleValue);
				if (!editorNoteSingleValue.equals(none))  {
					childClass.addPropertyValue(editorNoteAnnPropObj, editorNoteSingleValue);
					System.out.println("\tAdded value: "+"\""+editorNoteSingleValue+"\"");
				}
				else {
					System.out.println("\tED value \"none\" listed for this term, therefore this " +
							"annotation property was not added.");
				}
			}
		}
		else {
			System.out.println("NOTE: Column for editor_note is either not in the " +
			"inputFile or not specified in the properties file.");
		}
		
		/*
		 * Add term into HashMap so that it will be there for the next round of depth first recursion 
		 */
		map.put(t.termName, t.obiIdentifier);
		
		//Get kids, iterate through and load kids for this term
		Vector<Term> kidTerms = t.kids;
		if(!(kidTerms==null)) {
			for (int i=0; i < kidTerms.size(); i++) {
				Term kid = kidTerms.elementAt(i);
				System.out.println("Child Term: "+kid.termName);
				addToFile(kid, map, m); //this needs to be recursive to do depth first pass, only pass Term Object
			}
		}
		else {
			System.out.println("\tTerm: "+t.termName+" has no children");
		}
	}
	
	
	/**
	 * 
	 * @param m updated JenaOWLModel containing new terms from inputFile
	 * @param savedFile new files of type .owl and .pprj
	 */
	public void saveNewModel (JenaOWLModel m, String savedFile) {
		try {
			String newFile = savedFile;
			System.out.println("\nSAVED FILE NAME: "+newFile);
			
			File file = new File(newFile);
			m.save(file.toURL().toURI());
		}
		catch (Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
	}
	

} //End of class
