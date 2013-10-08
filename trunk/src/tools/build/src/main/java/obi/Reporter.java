package obi;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import java.util.Set;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.OWLOntologyCreationException;
import org.semanticweb.owlapi.model.OWLAnnotation;
import org.semanticweb.owlapi.model.OWLAnnotationProperty;
import org.semanticweb.owlapi.model.OWLAnnotationValue;
import org.semanticweb.owlapi.model.OWLEntity;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.model.OWLLiteral;

import obi.TermUpdater;

/**
 * Generate reports for an OWL ontology.
 * 
 * @author <a href="mailto:james@overton.ca">James A. Overton</a>
 */
public class Reporter {

  /**
   * Store a map from namespace strings to standard prefix strings.
   */
  public static Map<String,String> prefixMap = getPrefixMap();

  /**
   * Generate a map from namespace strings to standard prefix strings.
   */
  public static Map<String,String> getPrefixMap() {
    Map<String,String> map = new HashMap<String,String>();

    map.put("http://usefulinc.com/ns/doap",                    "DOAP");
    map.put("http://www.w3.org/1999/02/22-rdf-syntax-ns",      "RDF");
    map.put("http://www.w3.org/2000/01/rdf-schema",            "RDFS");
    map.put("http://www.w3.org/2002/07/owl",                   "OWL");
    map.put("http://www.w3.org/2001/XMLSchema",                "XSD");
    map.put("http://www.geneontology.org/formats/oboInOwl",    "oboInOwl");
    map.put("http://protege.stanford.edu/plugins/owl/protege", "Protege");
    map.put("http://purl.org/dc/",                             "DC");

    return map;
  }

  /**
   * Given an ontology path and an output path, collect information about
   * the ontology and write it.
   *
   * @param args Three strings:
   *   1. the name of the input OWL file
   *   2. the name of the output report
   *   3. the name of the output summary
   */
  public static void main(String[] args) {
    try {
      File ontologyFile = new File(args[0]);
      OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
      OWLOntology ontology = manager.loadOntologyFromOntologyDocument(ontologyFile);
      System.out.println("Writing entity report to: " + args[1]);
      reportEntities(ontology, args[1]);
      System.out.println("Writing summary report to: " + args[2]);
      reportSummaries(ontology, args[2]);
    } catch (Exception e) {
      System.out.println("ERROR: Could not build OBI with arguments:");
      for (String arg: args) System.out.println ("  " + arg);
      System.out.println(e.getMessage());
    }
  }

  /**
   * For each entity in the ontology, write its IRI and label to the writer.
   *
   * @param ontology the ontology to search
   * @param path the path to write the report to
   */
  public static void reportEntities(OWLOntology ontology, String path)
      throws IOException {
    FileWriter writer = new FileWriter(path);
    writer.write("Type\tIRI\tLabel\n");
    OWLAnnotationProperty rdfsLabel = ontology.getOWLOntologyManager().getOWLDataFactory().getRDFSLabel();
    for (OWLEntity entity: ontology.getSignature()) {
      if(TermUpdater.filterTerm(entity)) { continue; }
      String iri = entity.getIRI().toString();
      String label = ""; 
      Set<OWLAnnotation> annotations = entity.getAnnotations(ontology, rdfsLabel);
      if(annotations.iterator().hasNext()) {
        OWLAnnotationValue value = annotations.iterator().next().getValue();
        if(value instanceof OWLLiteral) {
          label = ((OWLLiteral) value).getLiteral();
        }
      }
      writer.write(entity.getEntityType() +"\t"+ iri + "\t" + label + "\n");
    }
    writer.close();
  }

  /**
   * Given a string representation of an IRI, determine the right prefix to use.
   *
   * @param iri the IRI string to check
   * @return the prefix string, could be empty
   */
  public static String getPrefix(String iri) {
    for(String key: prefixMap.keySet()) {
      if(iri.startsWith(key)) {
        return prefixMap.get(key);
      }
    }
    String oboBase = "http://purl.obolibrary.org/obo/";
    if(iri.startsWith(oboBase)) {
      return iri.substring(oboBase.length(), iri.lastIndexOf("_"));
    }
    return "";
  }
  
  /**
   * Write a report summarizing the sources for all the classes and properties.
   *
   * @param ontology the ontology to search
   * @param path the path to write the report to
   */
  public static void reportSummaries(OWLOntology ontology, String path)
      throws IOException {
    FileWriter writer = new FileWriter(path);
    writer.write("Classes\n");
    reportSummary(ontology.getClassesInSignature(true), writer);
    writer.write("\nObject Properties\n");
    reportSummary(ontology.getObjectPropertiesInSignature(true), writer);
    writer.write("\nAnnotation Properties\n");
    reportSummary(ontology.getAnnotationPropertiesInSignature(), writer);
    writer.write("\nData Properties\n");
    reportSummary(ontology.getDataPropertiesInSignature(true), writer);
    writer.close();
  }

  /**
   * For each class in the ontology, write its IRI and label to the writer.
   *
   * @param ontology the ontology to search
   * @param writer the report writer
   */
  public static void reportSummary(Set<? extends OWLEntity> entities, FileWriter writer)
      throws IOException {
    Map<String,Integer> count = new HashMap<String,Integer>();
    for (OWLEntity entity: entities) {
      String prefix = getPrefix(entity.getIRI().toString());
      if(!count.containsKey(prefix)) {
        count.put(prefix, 0);
      }
      count.put(prefix, count.get(prefix) + 1);
    }

    List<String> prefixList = new ArrayList<String>();
    prefixList.addAll(count.keySet());
    java.util.Collections.sort(prefixList);

    int max = "TOTAL".length();
    for(String prefix: prefixList) {
      if(prefix.length() > max) { max = prefix.length(); }
    }

    int sum = 0;
    for(String prefix: prefixList) {
      writer.write(String.format("%-"+ max +"s %d\n", prefix, count.get(prefix)));
      sum += count.get(prefix);
    }
    writer.write(String.format("%-"+ max +"s %d\n", "TOTAL", sum));
  }

}
