package obi;

import java.io.File;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.util.Scanner;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.util.Iterator;
import java.util.Set;
import java.util.TreeSet;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.OWLAxiom;

import org.semanticweb.owlapi.reasoner.OWLReasoner;
import org.semanticweb.owlapi.reasoner.OWLReasonerFactory;
import org.semanticweb.HermiT.Reasoner.ReasonerFactory;
import org.semanticweb.owlapi.reasoner.InferenceType;
import org.semanticweb.owlapi.util.InferredOntologyGenerator;
import org.semanticweb.owlapi.util.InferredAxiomGenerator;
import org.semanticweb.owlapi.util.InferredEquivalentClassAxiomGenerator;
import org.semanticweb.owlapi.util.InferredSubClassAxiomGenerator;

/**
 * Reason over an ontology and output the results.
 *  
 * @author <a href="mailto:james@overton.ca">James A. Overton</a>
 */
public class Reasoner {
  /**
   * Given an input path and an output path,
   * load the input ontology, reason it, 
   * and save a sorted list of axioms to the output path.
   *
   * @param args 1. the input path, 2. the output path
   */
  public static void main(String[] args) throws Exception {
    String inputPath = args[0];
    String outputPath = args[1];
    try {
      OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
      OWLOntology ontology = manager.loadOntologyFromOntologyDocument(new File(inputPath));
      System.out.println("Loaded ontology: " + inputPath);
      reason(ontology);
      printAxioms(ontology, outputPath);
    } catch (Exception e) {
      System.out.println("ERROR: Could not reason with arguments:");
      for (String arg: args) System.out.println ("  " + arg);
      System.out.println(e.getMessage());
      //throw e;
    }
  }

  /**
   * Given an ontology, reason and add the reasoned axioms to the ontology.
   *
   * @param ontology the OWLOntology to reason over
   */
  public static void reason(OWLOntology ontology) {
    System.out.println("Ontology has " + ontology.getAxioms().size() + " axioms.");
    System.out.println("Starting reasoning...");
    int seconds;
    long elapsedTime;
    long startTime = System.currentTimeMillis();

    OWLOntologyManager manager = ontology.getOWLOntologyManager();
    OWLReasonerFactory reasonerFactory = new ReasonerFactory();
    OWLReasoner reasoner = reasonerFactory.createReasoner(ontology);
    reasoner.precomputeInferences(InferenceType.CLASS_HIERARCHY);
    InferredOntologyGenerator generator = new InferredOntologyGenerator(reasoner);
    generator.addGenerator(new InferredSubClassAxiomGenerator());
    generator.addGenerator(new InferredEquivalentClassAxiomGenerator());

    elapsedTime = System.currentTimeMillis() - startTime;
    seconds = (int) Math.ceil(elapsedTime / 1000);
    System.out.println("Reasoning took " + seconds + " seconds.");

    System.out.println("Storing results...");
    startTime = System.currentTimeMillis();
    generator.fillOntology(manager, ontology);

    elapsedTime = System.currentTimeMillis() - startTime;
    seconds = (int) Math.ceil(elapsedTime / 1000);
    System.out.println("Storage took " + seconds + " seconds.");
    System.out.println("Ontology has " + ontology.getAxioms().size() + " axioms.");
  }

  /**
    * Print string representations of all the axioms in an ontology,
    * one axiom statement per line, sorted by string value.
    *
    * @param ontology the ontology to print
    * @param outputPath the path for the output file
    * @throws IOException if it cannot write to the outputPath
    */
  public static void printAxioms(OWLOntology ontology, String outputPath)
      throws IOException {
    Set<OWLAxiom> axioms = ontology.getAxioms();
    TreeSet<String> lines = new TreeSet<String>();
    Iterator<OWLAxiom> iterator = axioms.iterator();

    FileWriter fw = new FileWriter(outputPath);
    BufferedWriter bw = new BufferedWriter(fw);

    for(OWLAxiom axiom: axioms) {
      lines.add(axiom.toString().replaceAll("\\n", "\\n"));
    }
    for(String line: lines) {
      bw.write(line + "\n");
    }

    bw.close();
    fw.close();
  }
  

}
