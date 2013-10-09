package obi;

import java.io.File;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.util.Scanner;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.util.Iterator;
import java.util.Set;
import java.util.HashSet;
import java.util.TreeSet;
import java.util.List;
import java.util.ArrayList;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.model.OWLClassExpression;
import org.semanticweb.owlapi.model.OWLAxiom;
import org.semanticweb.owlapi.model.ClassExpressionType;
import org.semanticweb.owlapi.model.OWLSubClassOfAxiom;

import org.semanticweb.owlapi.reasoner.OWLReasoner;
import org.semanticweb.owlapi.reasoner.OWLReasonerFactory;
import org.semanticweb.HermiT.Reasoner.ReasonerFactory;
import org.semanticweb.owlapi.reasoner.InferenceType;
import org.semanticweb.owlapi.reasoner.Node;
import org.semanticweb.owlapi.util.InferredOntologyGenerator;
import org.semanticweb.owlapi.util.InferredAxiomGenerator;
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
   * and save it to the output path.
   *
   * @param args 1. the input path, 2. the output path
   */
  public static void main(String[] args) throws Exception {
    String inputPath = args[0];
    String outputPath = args[1];
    try {
      System.out.println("Loading ontology: " + inputPath);
      OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
      OWLOntology ontology = manager.loadOntologyFromOntologyDocument(new File(inputPath));
      if(reason(ontology)) {
        System.out.println("Saving inferred ontology to: " + inputPath);
        manager.saveOntology(ontology, IRI.create(new File(outputPath).toURI()));
        //printAxioms(ontology, outputPath);
      }
    } catch (Exception e) {
      System.out.println("ERROR: Could not reason with arguments:");
      for (String arg: args) System.out.println ("  " + arg);
      System.out.println(e.getMessage());
      //throw e;
    }
  }

  /**
   * Given an ontology, reason and add the reasoned axioms to the ontology.
   * Unnecessary asserted subClassOf axioms will be removed.
   *
   * @param ontology the OWLOntology to reason over
   */
  public static boolean reason(OWLOntology ontology) {
    System.out.println("Ontology has " + ontology.getAxioms().size() + " axioms.");
    System.out.println("Starting reasoning...");
    int seconds;
    long elapsedTime;
    long startTime = System.currentTimeMillis();

    OWLOntologyManager manager = ontology.getOWLOntologyManager();
    OWLDataFactory dataFactory = manager.getOWLDataFactory();
    OWLReasonerFactory reasonerFactory = new ReasonerFactory();
    OWLReasoner reasoner = reasonerFactory.createReasoner(ontology);
    if(!reasoner.isConsistent()) {
      System.out.println("Ontology is not consistent!");
      return false;
    }

    reasoner.precomputeInferences(InferenceType.CLASS_HIERARCHY);
    Node<OWLClass> unsatisfiableClasses = reasoner.getUnsatisfiableClasses();
    if (unsatisfiableClasses.getSize() > 1) {
      System.out.println("There are " + unsatisfiableClasses.getSize() +
          " unsatisfiable classes in the ontology: ");
      for(OWLClass cls : unsatisfiableClasses) {
        if (!cls.isOWLNothing()) {
          System.out.println("    unsatisfiable: " + cls.getIRI());
        }
      }
    } 

    // Make sure to add the axiom generators in this way!!!
    List<InferredAxiomGenerator<? extends OWLAxiom>> gens =
        new ArrayList<InferredAxiomGenerator<? extends OWLAxiom>>();
    gens.add(new InferredSubClassAxiomGenerator());
    InferredOntologyGenerator generator = new InferredOntologyGenerator(reasoner, gens);
    System.out.println("Using these axiom generators:");
    for(InferredAxiomGenerator inf: generator.getAxiomGenerators()) {
      System.out.println("    "+ inf);
    }

    elapsedTime = System.currentTimeMillis() - startTime;
    seconds = (int) Math.ceil(elapsedTime / 1000);
    System.out.println("Reasoning took " + seconds + " seconds.");

    startTime = System.currentTimeMillis();
    generator.fillOntology(manager, ontology);
    //System.out.println("Ontology now has " + ontology.getAxioms().size() + " axioms.");
    
    // Remove asserted subClassAxioms where there is a more direct inferred axiom.
    // Example: genotyping assay
    // - asserted in dev: assay
    // - inferred by reasoner: analyte assay
    // - asserted after fill: assay, analyte assay
    // - asserted after cleaning: analyte assay
    for (OWLClass thisClass: ontology.getClassesInSignature()) {
      if(thisClass.isOWLNothing() || thisClass.isOWLThing()) { continue; }

      // Use the reasoner to get all the direct superclasses of this class.
      Set<OWLClass> inferredSuperClasses = new HashSet<OWLClass>();
      for (Node<OWLClass> node : reasoner.getSuperClasses(thisClass, true)) {
        for (OWLClass inferredSuperClass : node) {
          inferredSuperClasses.add(inferredSuperClass);
        }
      }

      // For each subClassAxiom, if the super class is not in the set
      // of inferred super classes, remove that axiom.
      for(OWLSubClassOfAxiom subClassAxiom:
          ontology.getSubClassAxiomsForSubClass(thisClass)) {
        if (!subClassAxiom.getSuperClass().isAnonymous()) {
          OWLClass assertedSuperClass = subClassAxiom.getSuperClass().asOWLClass();
          if(!inferredSuperClasses.contains(assertedSuperClass)) {
            manager.removeAxiom(ontology,
                dataFactory.getOWLSubClassOfAxiom(thisClass, assertedSuperClass));
          }
        }
      }
    }

    System.out.println("Ontology now has " + ontology.getAxioms().size() + " axioms.");

    elapsedTime = System.currentTimeMillis() - startTime;
    seconds = (int) Math.ceil(elapsedTime / 1000);
    System.out.println("Storage took " + seconds + " seconds.");
    return true;
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
