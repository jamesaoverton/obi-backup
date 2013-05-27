package obi;

import java.io.File;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.util.Scanner;
import java.io.FileWriter;

import java.util.Set;
import java.util.List;
import java.util.ArrayList;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.Date;
import java.text.SimpleDateFormat;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.util.AutoIRIMapper;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.OWLOntologyCreationException;
import org.semanticweb.owlapi.model.OWLOntologyStorageException;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.expression.ParserException;

import org.semanticweb.owlapi.reasoner.OWLReasoner;
import org.semanticweb.owlapi.reasoner.OWLReasonerFactory;
import org.semanticweb.owlapi.reasoner.structural.StructuralReasonerFactory;
import org.semanticweb.owlapi.reasoner.InferenceType;
import org.semanticweb.owlapi.util.InferredOntologyGenerator;
import org.semanticweb.owlapi.util.InferredAxiomGenerator;
import org.semanticweb.owlapi.util.InferredEquivalentClassAxiomGenerator;
import org.semanticweb.owlapi.util.InferredSubClassAxiomGenerator;

import org.obolibrary.macro.ManchesterSyntaxTool;

import com.hp.hpl.jena.util.FileManager;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.ontology.OntModel;
import com.hp.hpl.jena.ontology.OntModelSpec;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.query.QuerySolution;

import obi.DLTest;
import obi.SPARQLTest;
import obi.Builder;

/**
 * A test harness for reading and running automated ontology tests.
 *  
 * @author <a href="mailto:james@overton.ca">James A. Overton</a>
 */
public class Tester {

  protected static String baseIRI = "http://purl.obolibrary.org/obo/obi/test.owl";

  /**
   * The list of Manchester keywords that mark the start of a line.
   */
  private static List<String> manchesterPrefixes = getManchesterPrefixes();
  
  /**
   */
  private static List<String> getManchesterPrefixes() {
    List<String> list = new ArrayList<String>();
    list.add("Prefix:");
    list.add("Ontology:");
    list.add("Import:");
    list.add("ObjectProperty:");
    list.add("AnnotationProperty:");
    list.add("Datatype:");
    list.add("Class:");
    list.add("Individual:");
    return list;
  };

  /**
   * These lines are added to the head of all Manchester files.
   */
  private static String manchesterBase =
    "Prefix: obo: <http://purl.obolibrary.org/obo/>\n" +
    "Prefix: : <" + baseIRI + "#>\n" +
    "Ontology: <" + baseIRI + ">\n";

  /**
   * The list of keywords for DL Query facts.
   */
  private static List<String> queryPrefixes = getQueryPrefixes();
  
  /**
   */
  private static List<String> getQueryPrefixes() {
    List<String> list = new ArrayList<String>();
    list.add("Fact:");
    list.add("Query:");
    list.add("Subclasses:");
    list.add("Superclasses:");
    list.add("Descendants:");
    list.add("Ancestors:");
    list.add("Equivalents:");
    list.add("Individuals:");
    return list;
  };

  /**
   * These lines are added to the head of all Turtle files.
   */
  private static String turtleBase =
    "@prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .\n" +
    "@prefix owl:  <http://www.w3.org/2002/07/owl#> .\n" +
    "@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .\n" +
    "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .\n" +
    "@prefix obo:  <http://purl.obolibrary.org/obo/> .\n" +
    "@prefix : <" + baseIRI + "#> .\n" +
    "@base     <" + baseIRI + "#> .\n";


  /**
   * The list of keywords for SPARQL facts.
   */
  private static List<String> sparqlPrefixes = getSPARQLPrefixes();
  
  /**
   */
  private static List<String> getSPARQLPrefixes() {
    List<String> list = new ArrayList<String>();
    list.add("FACT");
    list.add("PREFIX");
    list.add("SELECT");
    list.add("WHERE");
    list.add("ORDER");
    list.add("LIMIT");
    list.addAll(SPARQLTest.sparqlChecks);
    return list;
  };

  /**
   * These are added to all SPARQL queries.
   */
  protected static String sparqlBase =
    "PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
    "PREFIX owl:  <http://www.w3.org/2002/07/owl#>\n" +
    "PREFIX xsd:  <http://www.w3.org/2001/XMLSchema#>\n" +
    "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
    "PREFIX obo:  <http://purl.obolibrary.org/obo/>\n" +
    "PREFIX :     <" + baseIRI + "#>\n";

  /**
   * Pattern for matching rdfs:label annotations in Manchester blocks.
   */
  private static Pattern rdfsLabel = Pattern.compile("rdfs:label\\s+\"([^\"]+)\"");

  /**
   * Given an input path and an output path,
   * for each *.txt file in the input directory (recursive),
   * parse and run its tests, storing results to the output path.
   *
   * @param args 1. the input path, 2. the output path
   */
  public static void main(String[] args) throws Exception {
    String inputPath = args[0];
    String outputPath = args[1];
    try {
      boolean allPassed = true;
      List<File> files = walk(new ArrayList<File>(), new File(inputPath));
      for(File file: files) {
        String newPath = file.getParent().replaceAll(inputPath, outputPath);
        File newDir = new File(newPath);
        newDir.mkdirs();
        makeCatalog(newPath);
        boolean pass = testOne(file, newPath);
        if(!pass) { allPassed = false; }
      }

      if(allPassed) {
        System.out.println("ALL PASSED");
      } else {
        System.out.println("SOME TESTS FAILED");
      }

    } catch (Exception e) {
      System.out.println("ERROR: Could not test with arguments:");
      for (String arg: args) System.out.println ("  " + arg);
      System.out.println(e.getMessage());
      throw e;
    }
  }

  /**
   * Walk a directory of files recursively and return a list of all the *.txt files.
   *
   * @param files the list of files
   * @param dir the directory to search
   * @return a list of all the *.txt files found
   */
  public static List<File> walk(List<File> files, File dir) {
    String pattern = ".txt";
    for(File file: dir.listFiles()) {
      if (file.isDirectory()) {
        walk(files, file);
      } else if (file.getName().endsWith(pattern)) {
        files.add(file);
      }
    }
    return files;
  }

  /**
   * Given an output path, write a copy of the catalog-v100.xml file
   * to redirect to the `dist` folder.
   *
   * @param outputPath the new path to use
   */
  private static void makeCatalog(String outputPath)
      throws FileNotFoundException, IOException {
    File templateFile = new File("src/main/resources/catalog-v001.xml");
    File catalogFile = new File(outputPath, "catalog-v001.xml");
    String text = new Scanner(templateFile).useDelimiter("\\A").next();
    String baseDir = new File("").getAbsolutePath();
    text = text.replaceAll("BUILD_PATH", baseDir);
    FileWriter writer = new FileWriter(catalogFile);
    writer.write(text);
    writer.close();
  }

  /**
   * Given a source file and an output directory,
   * parse the file and run the tests, storing results to the output path.
   *
   * @param sourceFile the test file
   * @param outputPath the path for storing generated files
   * @return true if all tests pass, false otherwise
   */
  public static boolean testOne(File sourceFile, String outputPath)
      throws FileNotFoundException, IOException, ParserException,
             OWLOntologyCreationException, OWLOntologyStorageException {
    System.out.println("Testing " + sourceFile.getPath());

    String name = sourceFile.getName().replaceAll(".txt$", "");
    String base = new File(outputPath, name).toString();
    String logPath        = base + ".log";
    String manchesterPath = base + ".omn";
    String turtlePath     = base + ".ttl";
    String queriesPath    = base + ".dl.txt";
    String sparqlPath     = base + ".rq.txt";
    String namesPath      = base + ".names.omn";
    String owlPath        = base + ".owl";
    String reasonedPath   = base + ".reasoned.owl";

    FileWriter logWriter      = new FileWriter(new File(logPath));
    logWriter.write("Test log for " + sourceFile.getPath() + "\n");
    Date myDate = new Date();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    logWriter.write(sdf.format(myDate) + "\n\n");

    parseSourceFile(logWriter, sourceFile, manchesterPath, turtlePath, queriesPath, sparqlPath);
    buildNamesFile(logWriter, manchesterPath, namesPath);
    OWLReasoner reasoner = loadOntologies(logWriter, manchesterPath, namesPath, owlPath);

    boolean allPassed = true;

    if(allPassed && reasoner.isConsistent()) {
      logWriter.write("PASS The ontology is consistent\n");
    } else {
      logWriter.write("FAIL The ontology is inconsistent\n");
      allPassed = false;
    }

    Set<OWLClass> unsatisfiable = reasoner.getUnsatisfiableClasses().getEntities();
    if(allPassed && unsatisfiable.size() == 1) { // Just owl:nothing
      logWriter.write("PASS The ontology is satisfiable\n");
    } else {
      logWriter.write("FAIL The ontology is unsatisfiable\n");
      allPassed = false;
    }

    // Parse and run the tests.
    if (allPassed) {
      allPassed = loadDLQueries(logWriter, reasoner, queriesPath);
    }

    // Reason and save
    if (allPassed) {
      allPassed = loadSPARQLQueries(logWriter, reasoner, turtlePath, sparqlPath, reasonedPath);
    }

    if(allPassed) {
      logWriter.write("\nALL PASSED");
      //System.out.println("All tests passed");
    } else {
      logWriter.write("\nSOME TESTS FAILED");
      System.out.println("    FAILURES: See " + logPath);
    }

    logWriter.close();
    return allPassed;
  }

  /**
   * Given a log writer, a source file, and paths,
   * parse the source file into several results files.
   *
   * @param logWriter a FileWriter for logging
   * @param sourceFile the test file
   * @param manchesterPath the path to the Manchester file
   * @param turtlePath the path to the Turtle file
   * @param queriesPath the path to the DL Queries file
   * @param sparqlPath the path to the SPARQL file
   */
  private static void parseSourceFile(FileWriter logWriter, File sourceFile,
      String manchesterPath, String turtlePath, String queriesPath,
      String sparqlPath)
        throws IOException {
    // Break the file into parts.
    FileWriter manchesterWriter = new FileWriter(new File(manchesterPath));
    FileWriter turtleWriter     = new FileWriter(new File(turtlePath));
    FileWriter queriesWriter    = new FileWriter(new File(queriesPath));
    FileWriter sparqlWriter     = new FileWriter(new File(sparqlPath));

    manchesterWriter.write(manchesterBase + "\n");
    turtleWriter.write(turtleBase + "\n");

    Scanner scanner = new Scanner(sourceFile);
    int status = 0;
    while (scanner.hasNextLine()) {
      String line = scanner.nextLine();
      line = line.replaceAll("\t", "    "); // replace tabs with four spaces
      if(line.startsWith("      ")) {} // don't change status for indented lines
      else if(line.trim().isEmpty()) {} // don't change status for blank lines
      else if(isManchesterLine(line)) { status = 1; } // Manchester
      else if(isTurtleLine(line))     { status = 2; } // Turtle
      else if(isQueryLine(line))      { status = 3; } // DLQuery
      else if(isSPARQLLine(line))     { status = 4; } // SPARQL
      else { status = 0; } // documentation

      // Write code
      line = line.replaceFirst("    ", "");
      if(status == 1) {
        manchesterWriter.write(line + "\n");
      }
      else if(status == 2) {
        turtleWriter.write(line + "\n");
      }
      else if(status == 3) {
        queriesWriter.write(line + "\n");
      }
      else if(status == 4) {
        sparqlWriter.write(line + "\n");
      }
    }

    manchesterWriter.close();
    turtleWriter.close();
    queriesWriter.close();
    sparqlWriter.close();
  }


  /**
   * Given a log writer, an ontology path, and a names file path,
   * extract just the declarations and the rdfs:label annotations
   * from the ontology and save them to the names file.
   * This trick allows the Manchester parser to recognize all the rdfs:labels.
   *
   * @param logWriter the FileWriter for the log
   * @param manchesterPath the path to the Manchester file
   * @param namesPath the path to the stripped down Manchester file
   */
  private static void buildNamesFile(FileWriter logWriter,
      String manchesterPath, String namesPath)
      throws IOException {
    // Make a stripped version of the ontology file with just rdfs:labels.
    FileWriter namesWriter = new FileWriter(new File(namesPath));
    Scanner scanner = new Scanner(new File(manchesterPath));
    while (scanner.hasNextLine()) {
      String line = scanner.nextLine();
      if(line.startsWith("  ")) {
        Matcher m = rdfsLabel.matcher(line);
        if(m.find()) {
          String label = m.group(1);
          namesWriter.write("  Annotations: rdfs:label \"" + label + "\"\n");
        }
      } else if (line.startsWith("Ontology:")) {
        namesWriter.write("Ontology: <http://example.com/" +
            System.currentTimeMillis() + ">\n"); // Make a unique temporary IRI.
      } else {
        namesWriter.write(line + "\n");
      }
    }
    namesWriter.close();
  }


  /**
   * Given a log writer and some paths
   * use the names file to parse the Manchester file,
   * save the results to the OWL file,
   * then initialize and return a reasoner.
   *
   * @param logWriter a FileWriter for the log
   * @param manchesterPath the path to the Manchester file
   * @param namesPath the path to the stripped Manchester file
   * @param owlPath the path to save the RDF/XML OWL results
   * @return the initialized reasoner
   */
  private static OWLReasoner loadOntologies(FileWriter logWriter,
      String manchesterPath, String namesPath, String owlPath)
        throws OWLOntologyCreationException, OWLOntologyStorageException,
          FileNotFoundException, ParserException, IOException {
    // Load the names ontology.
    OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
    AutoIRIMapper mapper = new AutoIRIMapper(new File("dist"), false);
    manager.addIRIMapper(mapper);
    OWLOntology names = manager.loadOntologyFromOntologyDocument(new File(namesPath));

    // Parse the test ontology with a special Manchester parser.
    String text = new Scanner(new File(manchesterPath)).useDelimiter("\\A").next();
    ManchesterSyntaxTool parser = new ManchesterSyntaxTool(names);
    OWLOntology ontology = parser.parseOntology(manager, text);
    logWriter.write("PASS Loaded ontology file\n");
    manager.saveOntology(ontology, IRI.create(new File(owlPath)));

    OWLReasonerFactory reasonerFactory = new StructuralReasonerFactory();
    OWLReasoner reasoner = reasonerFactory.createReasoner(ontology);
    logWriter.write("PASS Initialized the reasoner\n");

    return reasoner;
  }

  /**
   * Given a log writer, q reasoner, and the queries path
   * parse the queries file to create tests, then run the tests.
   * 
   * @param logWriter a FileWriter for the log
   * @param reasoner the OWL reasoner for the ontology
   * @param queriesPath the path to the queries file
   * @return true if all tests pass, false otherwise
   */
  private static boolean loadDLQueries(FileWriter logWriter, 
      OWLReasoner reasoner, String queriesPath)
        throws FileNotFoundException, IOException {
    boolean allPassed = true;
    DLTest test;
    String text = new Scanner(new File(queriesPath)).useDelimiter("\\A").next();
    String[] blocks = text.split("Fact:");
    for(String block: blocks) {
      if(!block.trim().isEmpty()) {
        test = new DLTest(block);
        boolean pass = test.run(logWriter, reasoner);
        if(!pass) { allPassed = false; }
      }
    }

    return allPassed;
  }

  /**
   * Given a log writer, q reasoner, and the queries path
   * parse the queries file to create tests, then run the tests.
   * 
   * @param logWriter a FileWriter for the log
   * @param reasoner the OWL reasoner for the ontology
   * @param turtlePath the path to the Turtle file
   * @param sparqlPath the path to the SPARQL queries file
   * @param reasonedPath the path to the output OWL file
   * @return true if all tests pass, false otherwise
   */
  private static boolean loadSPARQLQueries(FileWriter logWriter, 
      OWLReasoner reasoner,
      String turtlePath, String sparqlPath, String reasonedPath)
        throws FileNotFoundException, IOException,
          OWLOntologyCreationException, OWLOntologyStorageException {

    OWLOntology ontology = Builder.mergeOntology(reasoner.getRootOntology(), IRI.create("http://purl.obolibrary.org/obo/obi/test-merged.owl")); // TODO: Is this right?
    OWLOntologyManager manager = ontology.getOWLOntologyManager();
    reasoner.flush();
    reasoner.precomputeInferences(InferenceType.CLASS_HIERARCHY);
    InferredOntologyGenerator generator = new InferredOntologyGenerator(reasoner);
    generator.addGenerator(new InferredSubClassAxiomGenerator());
    generator.addGenerator(new InferredEquivalentClassAxiomGenerator());
    generator.fillOntology(manager, ontology);
    manager.saveOntology(ontology, IRI.create(new File(reasonedPath)));

    Model model = FileManager.get().loadModel(reasonedPath);
    FileManager.get().readModel(model, turtlePath);
    OntModel ontModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM, model);

    boolean allPassed = true;
    SPARQLTest test;
    String text = new Scanner(new File(sparqlPath)).useDelimiter("\\A").next();
    String[] blocks = text.split("FACT");
    for(String block: blocks) {
      if(!block.trim().isEmpty()) {
        test = new SPARQLTest(block);
        boolean pass = test.run(logWriter, reasoner, ontModel);
        if(!pass) { allPassed = false; }
      }
    }
    //boolean pass = test.run(logWriter, reasoner, ontModel);
    //if(!pass) { allPassed = false; }

    return allPassed;
  }


  /**
   * Check whether the given line starts with a Manchester keyword.
   *
   * @param line the string to check
   * @return true if the line starts with a keyword, false otherwise
   */
  private static boolean isManchesterLine(String line) {
    for(String prefix: manchesterPrefixes) {
      if(line.startsWith("    " + prefix)) {
        return true;
      }
    }
    return false;
  }

  /**
   * Check whether the given line starts with a Turtle statement.
   *
   * @param line the string to check
   * @return true if the line starts with a keyword, false otherwise
   */
  private static boolean isTurtleLine(String line) {
    if(!line.startsWith("    "))       { return false; }
    line = line.replaceFirst("    ", "");
    if(line.startsWith("@prefix"))     { return true; }
    if(line.startsWith("@base"))       { return true; }
    if(line.matches("^:\\S+"))         { return true; } // :foo
    if(line.matches("^[^\\s:]+:\\S+")) { return true; } // foo:bar
    if(line.matches("^<\\S+>"))        { return true; } // <foo>
    return false;
  }

  /**
   * Check whether the given line starts with a SPARQL keyword
   *
   * @param line the string to check
   * @return true if the line starts with a keyword, false otherwise
   */
  private static boolean isSPARQLLine(String line) {
    for(String prefix: sparqlPrefixes) {
      if(line.startsWith("    " + prefix)) {
        return true;
      }
    }
    return false;
  }


  /**
   * Check whether the given line starts with a DL Query test keyword.
   *
   * @param line the string to check
   * @return true if the line starts with a keyword, false otherwise
   */
  private static boolean isQueryLine(String line) {
    for(String prefix: queryPrefixes) {
      if(line.startsWith("    " + prefix)) {
        return true;
      }
    }
    return false;
  }

}
