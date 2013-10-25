package obi;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Set;
import java.util.HashSet;
import java.util.Map;
import java.util.HashMap;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLAxiom;
import org.semanticweb.owlapi.model.OWLEntity;
import org.semanticweb.owlapi.model.OWLAnnotation;
import org.semanticweb.owlapi.model.OWLAnnotationProperty;
import org.semanticweb.owlapi.model.OWLAnnotationValue;
import org.semanticweb.owlapi.model.OWLLiteral;

import obi.Builder;

/**
 * Get the differences between two ontology files.
 *  
 * @author <a href="mailto:james@overton.ca">James A. Overton</a>
 */
public class Differ {
  /**
   * The base IRI for OBO terms.
   */
  public static String oboBase = "http://purl.obolibrary.org/obo/";

  /**
   * A pattern for matching IRI strings.
   */
  public static Pattern iriPattern = Pattern.compile("<(http\\S+)>");

  /**
   * Given the paths to two ontologies and a report path,
   * write a report on the differences between them.
   * Use the Builder.loadLocalOntology() method to resolve local imports.
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

    Map<String,String> labels = getLabels(ontology1);
    labels.putAll(getLabels(ontology2));

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
      writer.write("- " + addLabels(labels, axiom) + "\n");
    }

    writer.write("\n");

    writer.write(strings2minus1.size() +
        " axioms in Ontology 2 but not in Ontology 1:\n");
    for(String axiom: strings2minus1) {
      writer.write("+ " + addLabels(labels, axiom) + "\n");
    }
  }

  /**
   * Given an ontology, return a map from IRIs to rdfs:labels.
   *
   * @param ontology the ontology to use
   * @return a map from IRI strings to label strings
   */
  public static Map<String,String> getLabels(OWLOntology ontology) {
    Map<String,String> results = new HashMap<String,String>();
    OWLAnnotationProperty rdfsLabel =
      ontology.getOWLOntologyManager().getOWLDataFactory().getRDFSLabel();
    for(OWLEntity entity: ontology.getSignature(true)) {
      for(OWLOntology ont: ontology.getImportsClosure()) {
        Set<OWLAnnotation> labels = entity.getAnnotations(ont, rdfsLabel);
        if(labels.isEmpty()) { continue; }
        OWLAnnotation label = labels.iterator().next();
        OWLAnnotationValue value = label.getValue();
        if(value instanceof OWLLiteral) {
          results.put(entity.getIRI().toString(),
                      ((OWLLiteral) value).getLiteral());
        }
      }
    }
    return results;
  }

  /**
   * Given a map from IRIs to labels and an axiom string,
   * add labels next to any IRIs in the string,
   * shorten OBO IRIs, and return the updated string.
   *
   * @param labels a map from IRI strings to label strings
   * @param axiom a string representation of an OWLAxiom
   * @return a string with labels inserted next to IRIs
   */
  public static String addLabels(Map<String,String> labels, String axiom) {
    Matcher matcher = iriPattern.matcher(axiom);
    StringBuffer sb = new StringBuffer();
    while (matcher.find()) {
      String iri = matcher.group(1);
      String id = iri;
      if(id.startsWith(oboBase)) {
        id = id.substring(oboBase.length());
      }
      String replacement = "<" + iri + ">";
      if(labels.containsKey(iri)) {
        replacement = "<" + id + ">[" + labels.get(iri) + "]";
      }
      matcher.appendReplacement(sb, replacement);
    }
    matcher.appendTail(sb);
    System.out.println(sb.toString());
    return sb.toString();
  }

  /**
   * Given an ontology, return a list of strings for 
   * all the axioms of that ontology.
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
