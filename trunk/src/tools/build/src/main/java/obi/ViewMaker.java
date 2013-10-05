package obi;

import java.io.File;
import java.io.IOException;
import java.util.Set;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLEntity;
import org.semanticweb.owlapi.model.OWLAnnotation;
import org.semanticweb.owlapi.model.OWLAnnotationProperty;
import org.semanticweb.owlapi.model.OWLLiteral;

/**
 * This class relabels terms using 'alternative term' annotations.
 *  
 * @author <a href="mailto:james@overton.ca">James A. Overton</a>
 */
public class ViewMaker {
  /**
   * Given input and output ontology paths and the IRI of an annotation property,
   * load the input ontology, update each term, and save to the output ontology.
   * If a term has the given annotation, copy it to the RDFS Label.
   *
   * @param args 1. the path to the input ontology file
   *             2. the path to the output ontology file
   *             3. the IRI of the 'alternative term' property to use
   */
  public static void main(String[] args) {
    try {
      File inFile = new File(args[0]);
      File outFile = new File(args[1]);
      System.out.println("Loading ontology: " + args[0]);
      OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
      OWLDataFactory dataFactory = manager.getOWLDataFactory();
      OWLOntology ontology = manager.loadOntologyFromOntologyDocument(inFile);
      OWLAnnotationProperty prop = dataFactory.getOWLAnnotationProperty(IRI.create(args[2]));
      relabelTerms(ontology, prop);
      System.out.println("Saving ontology to: " + args[1]);
      manager.saveOntology(ontology, IRI.create(outFile.toURI()));
      manager.removeOntology(ontology);
    } catch (Exception e) {
      System.out.println("ERROR: Could not make view with arguments:");
      for (String arg: args) System.out.println ("  " + arg);
      System.out.println(e.getMessage());
    }
  }

  /**
   * Given an ontology and an annotation property, update all the terms in this ontology.
   */
  public static void relabelTerms(OWLOntology ontology, OWLAnnotationProperty prop) {
    for (OWLEntity entity: ontology.getSignature()) {
      relabelTerm(ontology, entity, prop);
    }
  }

  /**
   * Given an ontology, and OWLEntity, and an annotation property,
   * if the entity has the annotation, remove all its RDFS Labels and replace them
   * with the annotation.
   *
   * @param ontology the ontology to use
   * @param entity the entity to update
   * @param prop the annotation property to check
   */
  public static void relabelTerm(OWLOntology ontology, OWLEntity entity, OWLAnnotationProperty prop) {
    Set<OWLAnnotation> anns = entity.getAnnotations(ontology, prop);
    if(anns.iterator().hasNext()) {
      OWLAnnotation ann = anns.iterator().next();
      if(!((OWLLiteral) ann.getValue()).getLiteral().equals("")) {
        OWLOntologyManager manager = ontology.getOWLOntologyManager();
        OWLDataFactory dataFactory = manager.getOWLDataFactory();
        Set<OWLAnnotation> labels = entity.getAnnotations(ontology, dataFactory.getRDFSLabel());
        for(OWLAnnotation label: labels) {
          manager.removeAxiom(ontology, dataFactory.getOWLAnnotationAssertionAxiom(
            dataFactory.getRDFSLabel(), entity.getIRI(), label.getValue()));
        }
        manager.addAxiom(ontology, dataFactory.getOWLAnnotationAssertionAxiom(
          dataFactory.getRDFSLabel(), entity.getIRI(), ann.getValue()));
      }
    }
  }

}

