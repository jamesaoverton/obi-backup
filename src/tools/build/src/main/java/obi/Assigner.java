package obi;

import java.io.File;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.Set;
import java.util.HashSet;
import java.util.List;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.OWLEntity;
import org.semanticweb.owlapi.util.OWLEntityRenamer;
import org.semanticweb.owlapi.model.OWLOntologyChange;

/**
 * This class searches for terms in the OBO namespace that are not valid
 * OBO IRIs, and assigns them new OBI IRIs.
 *  
 * @author <a href="mailto:james@overton.ca">James A. Overton</a>
 */
public class Assigner {
  /**
   * The base for an OBO term IRI.
   */
  private static String oboBase = "http://purl.obolibrary.org/obo/";

  /**
   * The regular expression pattern for an OBO term ID.
   */
  private static Pattern idPattern = Pattern.compile("^([A-Za-z]{2,10})(_)([0-9]{1,9})$");
  
  /**
   * A format string for generating new OBI IRIs.
   */
  private static String obiPattern = oboBase + "OBI_%07d";

  /**
   * The ID number at which to begin searching for new IRIs.
   */
  private static int currentID = 1900;

  /**
   * Given an ontology path, load the ontology and assign new OBI IRIs to
   * every entity in the OBO namespace that does not have a valid OBO IRI.
   * Then save the ontology to the same location.
   *
   * @param args the path to the input OWL file.
   */
  public static void main(String[] args) {
    try {
      File ontologyFile = new File(args[0]);
      System.out.println("Loading ontology: " + args[0]);
      OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
      OWLOntology ontology = manager.loadOntologyFromOntologyDocument(ontologyFile);
      boolean changed = assignIDs(ontology);
      if(changed) {
        System.out.println("Saving ontology to: " + args[0]);
        manager.saveOntology(ontology, IRI.create(ontologyFile.toURI()));
      } else {
        System.out.println("No changes made to: " + args[0]);
      }
      manager.removeOntology(ontology);
    } catch (Exception e) {
      System.out.println("ERROR: Could not assign OBI IDs with arguments:");
      for (String arg: args) System.out.println ("  " + arg);
      System.out.println(e.getMessage());
    }
  }

  /**
   * Given an ontology, find the next OBI IRI that is not already in use,
   * starting at the currentID.
   *
   * @param ontology the ontology file to search
   * @return an OBI IRI that is not already in use
   */
  public static IRI nextFreeIRI(OWLOntology ontology) {
    while(true) {
      String iriString = String.format(obiPattern, ++currentID);
      IRI iri = IRI.create(iriString);
      if(!ontology.containsEntityInSignature(iri)) {
        return iri;
      }
    }
  }

  /**
   * Given an ontology, check the IRIs of all the entities.
   * If the IRI starts with the OBO base, but is not a valid OBO IRI,
   * then assign it a new OBI IRI.
   *
   * @param ontology the ontology file to work with
   */
  public static boolean assignIDs(OWLOntology ontology) {
    Set<OWLOntology> ontologies = new HashSet<OWLOntology>();
    ontologies.add(ontology);
    OWLOntologyManager manager = ontology.getOWLOntologyManager();
    OWLEntityRenamer renamer = new OWLEntityRenamer(manager, ontologies);
    boolean changed = false;

    for (OWLEntity entity: ontology.getSignature()) {
      String iri = entity.getIRI().toString();
      if(iri.startsWith(oboBase)) { // this IRI starts with the OBO base
        String id = iri.replaceFirst(oboBase, "");
        Matcher matchID = idPattern.matcher(id);
        if(!matchID.find()) { // this is NOT an OBO IRI, so rename this entity
          System.out.println("Not an OBO IRI: " + iri);
          IRI newIRI = nextFreeIRI(ontology);
          System.out.println("Assigning new OBI IRI: " + newIRI);
          changed = true;
          List<OWLOntologyChange> changes = renamer.changeIRI(entity, newIRI);
          for (OWLOntologyChange change: changes) {
            manager.applyChange(change);
          } 
        }
      }
    }

    return changed;
  }

}

