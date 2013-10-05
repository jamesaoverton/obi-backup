package obi;

import java.io.File;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.util.Scanner;

import java.util.Set;
import java.util.HashSet;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.OWLOntologyCreationException;
import org.semanticweb.owlapi.model.OWLAxiom;
import org.semanticweb.owlapi.model.OWLSubAnnotationPropertyOfAxiom;
import org.semanticweb.owlapi.model.OWLEntity;
import org.semanticweb.owlapi.model.AxiomType;
import org.semanticweb.owlapi.model.OWLNamedIndividual;
import org.semanticweb.owlapi.model.OWLIndividualAxiom;

import uk.ac.manchester.cs.owlapi.modularity.SyntacticLocalityModuleExtractor;
import uk.ac.manchester.cs.owlapi.modularity.ModuleType;


/**
 * Extract a list of classes from an ontology.
 * Based on "Modularization example" in "The Rough Guide to the OWLAPI".
 * 
 * @author <a href="mailto:james@overton.ca">James A. Overton</a>
 */
public class Extractor {
  /**
   * Given a source ontology and a file with a list of IRIs,
   * extract those IRIs as a module from the source ontology,
   * and save a new ontology with the given IRI to the given target file.
   *
   * @param args Four strings:
   *   1. the name of the source ontology file
   *   2. the name of the file containing a line-separated list of IRIs
   *   3. the name of the extracted ontology (output) file
   *   4. the IRI of the extracted ontology
   */
  public static void main(String[] args) {
    try {
      File sourceFile = new File(args[0]);
      OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
      System.out.println("Loading ontology from "+ args[0]);
      OWLOntology source = manager.loadOntologyFromOntologyDocument(sourceFile);
      cleanOntology(source);

      System.out.println("Extracting terms from "+ args[1]);
      File iriFile = new File(args[1]);
      Set<IRI> iris = getIRIs(iriFile);
      Set<OWLEntity> entities = getEntities(source, iris);

      File extractedFile = new File(args[2]);
      IRI extractedIRI = IRI.create(args[3]);
      OWLOntology extracted = extractModule(source, entities, extractedIRI);
      System.out.println("Saving extracted ontology to "+ args[2]);
      manager.saveOntology(extracted, IRI.create(extractedFile.toURI()));
    } catch (Exception e) {
      System.out.println("ERROR: Could not extract module with arguments:");
      for (String arg: args) System.out.println ("  " + arg);
      System.out.println(e.getMessage());
    }
  }

  /**
   * Given a file, extract just the IRIs and return a list of IRI objects.
   *
   * @param file a file containing a line-separated list of IRIs
   * @return the list of the IRIs found
   */
  public static Set<IRI> getIRIs(File file) throws FileNotFoundException {
    Set<IRI> iris = new HashSet<IRI>();
    Scanner scanner = new Scanner(file);
    while (scanner.hasNextLine()) {
      String iri = scanner.nextLine().trim();
      if(iri.startsWith("http")) {
        iris.add(IRI.create(iri));
      }
    }
    return iris;
  }

  /**
   * Given an ontology and a list of IRIs, get a set of entities with
   * those IRIs.
   *
   * @param ontology the ontology to search
   * @param iris the set of IRIs to collect entities for
   * @return the set of entities
   */
  public static Set<OWLEntity> getEntities(OWLOntology ontology, Set<IRI> iris) {
    Set<OWLEntity> entities = new HashSet<OWLEntity>();
    for (IRI iri: iris) {
      entities.addAll(ontology.getEntitiesInSignature(iri));
    }
    return entities;
  }

  /**
   * Remove unwanted axioms from the ontology before extraction.
   * 1. A bug in older versions of OWLAPI throws an error when trying to 
   * extract a module from an ontology that includes subAnnotationPropertyOf
   * axioms.
   * 2. We also remove individuals.
   *
   * @param ontology the ontology to remove the axioms from
   */
  public static void cleanOntology(OWLOntology ontology) {
    Set<OWLSubAnnotationPropertyOfAxiom> axioms = ontology.getAxioms(AxiomType.SUB_ANNOTATION_PROPERTY_OF);
    ontology.getOWLOntologyManager().removeAxioms(ontology, axioms);
    Set<OWLNamedIndividual> individuals = ontology.getIndividualsInSignature(true);
    for (OWLNamedIndividual individual: individuals) {
      Set<OWLIndividualAxiom> axioms2 = ontology.getAxioms(individual);
      ontology.getOWLOntologyManager().removeAxioms(ontology, axioms2);
    }
  }

  /**
   * Now we use the SyntacticLocalityModuleExtractor to extract the given
   * set of entities (and all related entities, recursively) into a
   * new ontology with the given IRI.
   *
   * @param ontology the source ontology for the extraction
   * @param entities the entities to extract
   * @param iri the IRI for the new ontology
   * @return the new ontology, with the given entities and IRI
   */
  public static OWLOntology extractModule(OWLOntology ontology,
      Set<OWLEntity> entities, IRI iri) throws OWLOntologyCreationException {
    SyntacticLocalityModuleExtractor extractor =
      new SyntacticLocalityModuleExtractor(
          ontology.getOWLOntologyManager(), ontology, ModuleType.STAR);
    return extractor.extractAsOntology(entities, iri);
  }
}
