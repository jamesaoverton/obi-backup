package obi;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Set;
import java.util.HashSet;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLAxiom;

import obi.Builder;

/**
 * Get the differences between two ontology files.
 *  
 * @author <a href="mailto:james@overton.ca">James A. Overton</a>
 */
public class Differ {
  /**
   * Given the paths to two ontologies and a report path,
   * write a report on the differences between them.
   *
   * @param args 1. the path to the first ontology
   *             2. the path to the second ontology
   *             3. the output path for the report
   */
  public static void main(String[] args) throws Exception {
    try {
      System.out.println("Loading ontology 1: " + args[0]);
      OWLOntology ontology1 = Builder.loadLocalOntology(new File(args[0]));
      System.out.println("Loading ontology 2: " + args[1]);
      OWLOntology ontology2 = Builder.loadLocalOntology(new File(args[1]));
      System.out.println("Writing differences: " + args[2]);
      FileWriter writer = new FileWriter(new File(args[2]));
      writer.write("Comparing:\n"+ args[0] +"\n"+ args[1] +"\n\n");
      compareOntologies(ontology1, ontology2, writer);
      writer.close();
    } catch (Exception e) {
      System.out.println("ERROR: Could not diff ontologies with arguments:");
      for (String arg: args) System.out.println ("  " + arg);
      System.out.println(e.getMessage());
      //throw e;
    }
  }

  /**
   * Given two ontologies and a FileWriter, get the differences between
   * axiom strings and write then to the writer.
   *
   * @param ontology1 the first ontology
   * @param ontology2 the second ontology
   * @param writer the FileWriter for the report
   */
  public static void compareOntologies(OWLOntology ontology1,
      OWLOntology ontology2, FileWriter writer)
      throws IOException {

    Set<String> strings1 = getAxiomStrings(ontology1);
    Set<String> strings2 = getAxiomStrings(ontology2);

    Set<String> strings1minus2 = new HashSet<String>(strings1);
    strings1minus2.removeAll(strings2);
    Set<String> strings2minus1 = new HashSet<String>(strings2);
    strings2minus1.removeAll(strings1);

    if(strings1minus2.size() == 0 && strings2minus1.size() == 0) {
      writer.write("Ontologies are identical\n");
      return;
    }

    writer.write(strings1minus2.size() +
        " axioms in Ontology 1 but not in Ontology 2:\n");
    for(String axiom: strings1minus2) {
      writer.write("- " + axiom + "\n");
    }

    writer.write("\n");

    writer.write(strings2minus1.size() +
        " axioms in Ontology 2 but not in Ontology 1:\n");
    for(String axiom: strings2minus1) {
      writer.write("+ " + axiom + "\n");
    }
  }

  /**
   * Given an ontology, reurn a list of all the strings for that ontology.
   *
   * @param ontology the ontology to use
   * @return a set of strings, one for each axiom in the ontology
   */
  public static Set<String> getAxiomStrings(OWLOntology ontology) {
    Set<OWLAxiom> axioms = ontology.getAxioms();
    Set<String> strings = new HashSet<String>();
    for(OWLAxiom axiom: axioms) {
      strings.add(axiom.toString());
    }
    return strings;
  }


}
