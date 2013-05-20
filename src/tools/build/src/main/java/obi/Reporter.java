package obi;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import java.util.Set;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.OWLOntologyCreationException;
import org.semanticweb.owlapi.model.OWLAnnotation;
import org.semanticweb.owlapi.model.OWLAnnotationProperty;
import org.semanticweb.owlapi.model.OWLClass;


/**
 * Generate reports for an OWL ontology.
 * 
 * @author <a href="mailto:james@overton.ca">James A. Overton</a>
 */
public class Reporter {
  /**
   * Given an ontology path and an output path, collect information about
   * the ontology and write it.
   * Right now we just get IRIs and label for each class.
   *
   * @param args Two strings:
   *   1. the name of the input OWL file
   *   2. the name of the output report
   */
  public static void main(String[] args) {
    try {
      File ontologyFile = new File(args[0]);
      FileWriter reportWriter = new FileWriter(args[1]);
      reportWriter.write("IRI,Label\n");
      OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
      OWLOntology ontology = manager.loadOntologyFromOntologyDocument(ontologyFile);
      reportClasses(ontology, reportWriter);
      reportWriter.close();
      manager.removeOntology(ontology);
    } catch (Exception e) {
      System.out.println("ERROR: Could not build OBI with arguments:");
      for (String arg: args) System.out.println ("  " + arg);
      System.out.println(e.getMessage());
    }
  }

  /**
   * For each class in the ontology, write its IRI and label to the writer.
   *
   * @param ontology the ontology to search
   * @param writer the report writer
   */
  public static void reportClasses(OWLOntology ontology, FileWriter writer)
      throws IOException, OWLOntologyCreationException {
    Set<OWLClass> owlClasses = ontology.getClassesInSignature(true);
    OWLAnnotationProperty rdfsLabel = ontology.getOWLOntologyManager().getOWLDataFactory().getRDFSLabel();
    for (OWLClass owlClass: owlClasses) {
      Set<OWLAnnotation> annotations = owlClass.getAnnotations(ontology, rdfsLabel);
      try {
        String iri = owlClass.getIRI().toString();
        String label = annotations.iterator().next().getValue().toString();
        String name = label.replaceAll("@en", "").replaceAll("\"", "")
          .replaceAll("\\^\\^xsd:string", "");
        writer.write(iri + ",\"" + name + "\"\n");
      } catch (Exception e) {
        //System.out.println("ERROR: reporting on " + owlClass);
      }
    }
  }

}
