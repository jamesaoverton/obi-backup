package obi;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.Set;
import java.util.HashSet;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyID;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLEntity;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.model.OWLClassExpression;
import org.semanticweb.owlapi.model.OWLNamedIndividual;
import org.semanticweb.owlapi.model.OWLDataProperty;
import org.semanticweb.owlapi.model.OWLObjectProperty;
import org.semanticweb.owlapi.model.OWLObjectPropertyExpression;
import org.semanticweb.owlapi.model.OWLAnnotation;
import org.semanticweb.owlapi.model.OWLAnnotationProperty;
import org.semanticweb.owlapi.model.OWLAnnotationValue;
import org.semanticweb.owlapi.model.OWLAnnotationAssertionAxiom;
import org.semanticweb.owlapi.model.OWLLiteral;

/**
 * This class is used to check every term in OBI and ensure that it meets
 * the minimum metadata standards and other quality checks.
 *
 * http://obi-ontology.org/page/OBI_Minimal_metadata
 *  
 * @author <a href="mailto:james@overton.ca">James A. Overton</a>
 */
public class TermUpdater {
  /**
   * The base for an OBO term IRI.
   */
  private static String oboBase = "http://purl.obolibrary.org/obo/";

  /**
   * The regular expression pattern for an OBO term ID.
   */
  private static Pattern idPattern = Pattern.compile("^([A-Za-z]{2,10})(_)([0-9]{1,9})$");

  /**
   * A FileWriter for the log file.
   */
  private static FileWriter logWriter = null;

  /**
   * The ontology being worked on.
   */
  private static OWLOntology ontology = null;

  /**
   * The manager for the current ontology.
   */
  private static OWLOntologyManager manager = null;

  /**
   * The data factory for the current manager.
   */
  private static OWLDataFactory dataFactory = null;

  /**
   * Holds set of IRI strings that will be ignored by the TermUpdater.
   */
  private static Set<String> ignoreExact = ignoreExactSet();

  /**
   * Generates a set of IRI strings to ignore.
   */
  private static Set<String> ignoreExactSet() {
    Set<String> set = new HashSet<String>();
    set.add("mailto:obi-users@googlegroups.com");
    set.add("http://purl.obolibrary.org/obo/obi");
    set.add("http://purl.obolibrary.org/obo/obi.owl");
    set.add("http://purl.obolibrary.org/obo/obi/wiki");
    set.add("http://purl.obolibrary.org/obo/obi/project");
    set.add("http://purl.obolibrary.org/obo/obi/repository");
    set.add("http://purl.obolibrary.org/obo/obi/browse");
    set.add("http://purl.obolibrary.org/obo/obi/tracker");
    set.add("http://code.google.com/p/information-artifact-ontology/");
    return set;
  }

  /**
   * Holds set of IRI string prefixes that will be ignored by the TermUpdater.
   */
  private static Set<String> ignorePrefix = ignorePrefixSet();

  /**
   * Generates a set of IRI string prefixes to ignore.
   */
  private static Set<String> ignorePrefixSet() {
    Set<String> set = new HashSet<String>();
    set.add("http://purl.obolibrary.org/obo/obi/version-");     // OBI versions
    set.add("http://purl.obolibrary.org/obo/obi/wiki/Releases");// OBI releases
    set.add("http://usefulinc.com/ns/doap");                    // DOAP
    set.add("http://www.w3.org/1999/02/22-rdf-syntax-ns");      // RDF
    set.add("http://www.w3.org/2000/01/rdf-schema");            // RDFS
    set.add("http://www.w3.org/2002/07/owl");                   // OWL
    set.add("http://www.w3.org/2001/XMLSchema");                // XSD 
    set.add("http://protege.stanford.edu/plugins/owl/protege"); // Protege
    set.add("http://purl.org/dc/");                             // Dublin Core
    return set;
  }
  
  /**
   * Given an ontology path, load the ontology and update each term it contains.
   * Then save the ontology to a new location.
   *
   * @param args 1. the path to the input OWL file
   *             2. the path to the log file
   *             3. the path to the output OWL file
   */
  public static void main(String[] args) throws IOException {
    try {
      File ontologyFile = new File(args[0]);
      System.out.println("Loading ontology: " + args[0]);
      OWLOntologyManager mng = OWLManager.createOWLOntologyManager();
      OWLOntology ont = mng.loadOntologyFromOntologyDocument(ontologyFile);
      updateTerms(ont, args[1]);
      System.out.println("Saving ontology to: " + args[2]);
      File outputFile = new File(args[2]);
      mng.saveOntology(ont, IRI.create(outputFile.toURI()));
      mng.removeOntology(ont);
    } catch (Exception e) {
      System.out.println("ERROR: Could update terms with arguments:");
      for (String arg: args) System.out.println ("  " + arg);
      e.printStackTrace();
      System.out.println(e.getMessage());
    }
  }

  /**
   * Given an OWLEntity and an Annotation Property, get the first textual value.
   *
   * @param entity the OWLEntity to use
   * @param prop the OWLAnnotationProperty to use
   * @return a String, may be empty
   */
  public static String getText(OWLEntity entity, OWLAnnotationProperty prop) {
    Set<OWLAnnotation> anns = entity.getAnnotations(ontology, prop);
    if(anns.iterator().hasNext()) {
      return getText(anns.iterator().next());
    } else {
      return "";
    }
  }

  /**
   * Given an OWLAnnotation, return a textual value.
   *
   * @param ann the OWLAnnotation to check;
   * @return a String, may be empty
   */
  public static String getText(OWLAnnotation ann) {
    OWLAnnotationValue value = ann.getValue();
    String text = "";
    if(value instanceof OWLLiteral) {
      text = ((OWLLiteral) value).getLiteral();
    }
    return text;
  }

  /**
   * Given an OWLEntity, get the first RDFS label.
   *
   * @param entity the OWLEntity to use
   * @return a String, may be empty
   */
  public static String getLabel(OWLEntity entity) {
    return getText(entity, dataFactory.getRDFSLabel());
  }

  /**
   * Given an OWLEntity, get the first editor preferred term.
   *
   * @param entity the OWLEntity to use
   * @return a String, may be empty
   */
  public static String getPreferred(OWLEntity entity) {
    OWLAnnotationProperty preferred = dataFactory.getOWLAnnotationProperty(
        IRI.create("http://purl.obolibrary.org/obo/IAO_0000111"));
    return getText(entity, preferred);
  }

  /**
   * Log a message for this entity to the tab-separated log file.
   *
   * @param entity the entity the message is about
   * @param message the message to log
   */
  public static void log(OWLEntity entity, String message) throws IOException {
    logWriter.write(entity.getEntityType() + "\t"
                  + entity.getIRI().toString() + "\t"
                  + getLabel(entity) + "\t"
                  + message + "\n");
  }

  /**
   * Check whether this term has an IRI in OBI's ID space.
   *
   * @param entity the OWLEntity to check
   * @return true if the entity is in OBI, false otherwise
   */
  public static boolean inOBI(OWLEntity entity) {
    String iri = entity.getIRI().toString();
    if(iri.startsWith(oboBase + "OBI_")) {
      String id = iri.replaceFirst(oboBase, "");
      Matcher matchID = idPattern.matcher(id);
      if(matchID.find()) {
        return true;
      }
    }
    return false;
  }

  /**
   * Check whether this term has an IRI in the NCBITaxon ID space.
   *
   * @param entity the OWLEntity to check
   * @return true if the entity is in NCBITaxon, false otherwise
   */
  public static boolean inNCBITaxon(OWLEntity entity) {
    String iri = entity.getIRI().toString();
    if(iri.startsWith(oboBase + "NCBITaxon_")) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * Given an ontology, check and update every term.
   *
   * @param ont the ontology file to work with
   * @param logPath the path for the log file
   */
  public static void updateTerms(OWLOntology ont, String logPath) throws IOException {
    ontology = ont;
    manager = ontology.getOWLOntologyManager();
    dataFactory = manager.getOWLDataFactory();
    logWriter = new FileWriter(new File(logPath));
    logWriter.write("Type\tIRI\tLabel\tError\n");

    OWLOntologyID id = ontology.getOntologyID();
    ignoreExact.add(id.getOntologyIRI().toString());
    //ignoreExact.add(id.getVersionIRI().toString());

    //int counter = 0;
    for (OWLEntity entity: ontology.getSignature()) {
      updateTerm(entity);
      //counter++;
      //if(counter > 1000) { break; }
    }

    logWriter.close();
  }


  /**
   * Given an OWL Entity, return true if we should ignore this entity
   * and false if we should consider it.
   *
   * @param entity the entity to check
   * @return true if the entity should be filtered out, false otherwise
   */
  public static boolean filterTerm(OWLEntity entity) {
    // Ignore certain IRIs.
    String iri = entity.getIRI().toString();
    if(ignoreExact.contains(iri)) { return true; }
    for(String prefix: ignorePrefix) {
      if(iri.startsWith(prefix)) { return true; }
    }
    return false;
  }

  /**
   * Given an OWLEntity, check it for OBI's minimal metadata and update it.
   *
   * @param entity the OWLEntity to check and update
   */
  public static void updateTerm(OWLEntity entity) throws IOException {
    if(filterTerm(entity)) return;

    Set<Boolean> results = new HashSet<Boolean>();
    results.add(checkOBOID(entity));
    results.add(checkLabel(entity));
    results.add(checkTextualDefinition(entity));
    results.add(checkLogicalDefinition(entity));
    results.add(checkObsolete(entity));
    if(inOBI(entity)) {
      results.add(checkTermEditors(entity));
      results.add(checkDefinitionSource(entity));
      checkCurationStatus(entity, !results.contains(Boolean.FALSE));
    }
  }

  /**
   * Given an OWLEntity, check that it has an OBO IRI.
   *
   * @param entity the OWLEntity to check and update
   * @return true if the entity has an OBO ID
   */
  public static boolean checkOBOID(OWLEntity entity) throws IOException {
    String iri = entity.getIRI().toString();
    if(iri.startsWith(oboBase)) { // this IRI starts with the OBO base
      String id = iri.replaceFirst(oboBase, "");
      Matcher matchID = idPattern.matcher(id);
      if(!matchID.find()) {
        log(entity, "Not an OBO IRI");
        return false;
      }
      return true;
    } else {
      log(entity, "Not an OBO IRI");
      return false;
    }
  }

  /**
   * Given an OWLEntity, check that it has:
   * - exactly one RDFS Label
   * - exactly one editor preferred term, the same as the RDFS Label
   *
   * @param entity the OWLEntity to check and update
   * @return true if the updated term has the required labels
   */
  public static boolean checkLabel(OWLEntity entity) throws IOException {
    String firstLabel = getLabel(entity);
    Set<OWLAnnotation> rdfsLabels = entity.getAnnotations(ontology, dataFactory.getRDFSLabel());
    OWLAnnotationProperty preferred = dataFactory.getOWLAnnotationProperty(
        IRI.create("http://purl.obolibrary.org/obo/IAO_0000111"));
    Set<OWLAnnotation> prefLabels = entity.getAnnotations(ontology, preferred);

    // Check RDFS Labels
    if(rdfsLabels.size() == 0) {
      if (prefLabels.size() == 1) {
        // Copy the editor preferred term to the RDFS label.
        manager.addAxiom(ontology, dataFactory.getOWLAnnotationAssertionAxiom(
          dataFactory.getRDFSLabel(), entity.getIRI(), prefLabels.iterator().next().getValue()));
        return true;
      } else {
        log(entity, "Missing RDFS Label");
      }
    } else if (rdfsLabels.size() > 1) {
      Boolean allEqual = true;
      for(OWLAnnotation rdfsLabel: rdfsLabels) {
        if(!firstLabel.equals(getText(rdfsLabel))) {
          allEqual = false;
        }
      }

      if(!allEqual) {
        log(entity, "Multiple different RDFS Labels");
      } else {
        log(entity, "Multiple identical RDFS Labels merged into one");
        rdfsLabels = entity.getAnnotations(ontology, dataFactory.getRDFSLabel());
        for(OWLAnnotation ann: rdfsLabels) {
          manager.removeAxiom(ontology, dataFactory.getOWLAnnotationAssertionAxiom(
                dataFactory.getRDFSLabel(), entity.getIRI(), ann.getValue()));
        }
        OWLAnnotationAssertionAxiom axiom = dataFactory.getOWLAnnotationAssertionAxiom(
            dataFactory.getRDFSLabel(), entity.getIRI(),
            dataFactory.getOWLLiteral(firstLabel, "en"));
        manager.addAxiom(ontology, axiom);
      }
    }

    // Check editor preferred terms
    if(prefLabels.size() == 1) {
      if(!getLabel(entity).equals(getPreferred(entity))) {
        log(entity, "RDFS Label and editor preferred term do not match; using RDFS label");
      }
    }
    if(prefLabels.size() > 1) {
      log(entity, "Multiple editor preferred terms; replaced with one from RDFS Label");
    }


    // Remove editor preferred terms
    for(OWLAnnotation prefLabel: prefLabels) {
      manager.removeAxiom(ontology, dataFactory.getOWLAnnotationAssertionAxiom(
            entity.getIRI(), prefLabel));
    }
    
    // Copy RDFS label to the editor preferred term
    rdfsLabels = entity.getAnnotations(ontology, dataFactory.getRDFSLabel());
    if(rdfsLabels.iterator().hasNext()) {
      manager.addAxiom(ontology, dataFactory.getOWLAnnotationAssertionAxiom(
        preferred, entity.getIRI(), rdfsLabels.iterator().next().getValue()));
    }

    // Exactly one RDFS Label, exactly one editor preferred term, and they match.
    if(entity.getAnnotations(ontology, dataFactory.getRDFSLabel()).size() == 1 &&
       entity.getAnnotations(ontology, preferred).size() == 1 &&
       getLabel(entity).equals(getPreferred(entity))) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * Given an OWLEntity, check that it has exactly one textual definition.
   * NCBITaxon entities are excluded.
   *
   * @param entity the OWLEntity to check and update
   * @return true if the updated term has one definition
   */
  public static boolean checkTextualDefinition(OWLEntity entity) throws IOException {
    if(inNCBITaxon(entity)) { return true; } // NCBI doesn't provide definitions

    OWLAnnotationProperty definition = dataFactory.getOWLAnnotationProperty(
        IRI.create("http://purl.obolibrary.org/obo/IAO_0000115"));
    Set<OWLAnnotation> definitions = entity.getAnnotations(ontology, definition);

    if(definitions.size() == 0) {
      log(entity, "Missing textual definition");
      return false;
    } else if(definitions.size() == 1) {
      return true;
    } else {
      String firstDef = getText(entity, definition);
      Boolean allEqual = true;
      for(OWLAnnotation def: definitions) {
        if(!firstDef.equals(getText(def))) {
          allEqual = false;
        }
      }

      if(!allEqual) {
        log(entity, "Multiple different textual definitions");
        return false;
      } else {
        log(entity, "Multiple identical textual definitions merged into one");
        definitions = entity.getAnnotations(ontology, definition);
        for(OWLAnnotation ann: definitions) {
          manager.removeAxiom(ontology, dataFactory.getOWLAnnotationAssertionAxiom(
            definition, entity.getIRI(), ann.getValue()));
        }
        OWLAnnotationAssertionAxiom axiom = dataFactory.getOWLAnnotationAssertionAxiom(
          definition, entity.getIRI(), dataFactory.getOWLLiteral(firstDef, "en"));
        manager.addAxiom(ontology, axiom);
        return false;
      }
    }
  }

  /**
   * Given an OWLEntity, check that it has exactly a logical definition.
   * For an OWLClass, this means one equivalentTo axiom OR one or more subClassAxioms OR both.
   * For an OWLObjectProperty, this means one or more supers, domains, and ranges.
   *
   * @param entity the OWLEntity to check and update
   * @return true if the updated term has a logical definition
   */
  public static boolean checkLogicalDefinition(OWLEntity entity) throws IOException {
    if(entity instanceof OWLClass) {
      Set<OWLClassExpression> equivs = entity.asOWLClass().getEquivalentClasses(ontology);
      Set<OWLClassExpression> supers = entity.asOWLClass().getSuperClasses(ontology);

      if(equivs.size() > 1) {
        log(entity, "Class has multiple equivalentTo axioms");
      }

      if(equivs.size() + supers.size() == 0) {
        log(entity, "Class does not have any logical axioms");
        return false;
      }
    } else if(entity instanceof OWLObjectProperty) {
      if(entity.asOWLObjectProperty().getSuperProperties(ontology).size() +
         entity.asOWLObjectProperty().getDomains(ontology).size() +
         entity.asOWLObjectProperty().getRanges(ontology).size() == 0) {
        log(entity, "ObjectProperty has no domain, range, or super properties.");
        return false;
      }
    }

    return true;
  }

  /**
   * Given an OWLEntity, check that it has one or more term editors.
   *
   * @param entity the OWLEntity to check and update
   * @return true if the term has one or more term editors
   */
  public static boolean checkTermEditors(OWLEntity entity) throws IOException {
    OWLAnnotationProperty editor = dataFactory.getOWLAnnotationProperty(
        IRI.create("http://purl.obolibrary.org/obo/IAO_0000117"));
    Set<OWLAnnotation> editors = entity.getAnnotations(ontology, editor);

    if(editors.size() == 0) {
      log(entity, "Missing term editors");
      return false;
    } else {
      return true;
    }
  }

  /**
   * Given an OWLEntity, check that it has one or more definition sources.
   *
   * @param entity the OWLEntity to check and update
   * @return true if the term has one or more definition sources
   */
  public static boolean checkDefinitionSource(OWLEntity entity) throws IOException {
    OWLAnnotationProperty source = dataFactory.getOWLAnnotationProperty(
        IRI.create("http://purl.obolibrary.org/obo/IAO_0000117"));
    Set<OWLAnnotation> sources = entity.getAnnotations(ontology, source);

    if(sources.size() == 0) {
      log(entity, "Missing definition source");
      return false;
    } else {
      return true;
    }
  }

  /**
   * Given an OWLEntity, check whether it is obsolete or deprecated and update it.
   * An obsolete term should be:
   * - marked as deprecated
   * - have an obsolescence reason
   * - label starts with "obsolete"
   * - has no logical axioms
   *
   * @param entity the OWLEntity to check and update
   * @return true if the term is not obsolete, or is obsolete but has the right properties
   */
  public static boolean checkObsolete(OWLEntity entity) throws IOException {
    OWLAnnotationProperty deprecated = dataFactory.getOWLAnnotationProperty(
        IRI.create("http://www.w3.org/2002/07/owl#deprecated"));
    Set<OWLAnnotation> deps = entity.getAnnotations(ontology, deprecated);
    OWLAnnotationProperty obsolescenceReason = dataFactory.getOWLAnnotationProperty(
        IRI.create("http://purl.obolibrary.org/obo/IAO_0000231"));
    Set<OWLAnnotation> obs = entity.getAnnotations(ontology, obsolescenceReason);

    boolean obsolete = false;
    boolean markedDeprecated = false;

    if(deps.size() == 0) {
      // No problem.
    } else if(deps.size() == 1) {
      OWLLiteral value = (OWLLiteral) deps.iterator().next().getValue();
      if(value.isBoolean()) {
        if(value.getLiteral().equals("true")) {
          markedDeprecated = true;
          obsolete = true;
        } else {
          log(entity, "Deprecation annotation is not 'true'");
        }
      } else {
        log(entity, "Deprecation annotation is not boolean");
      }
    } else {
      log(entity, "Multiple deprecation annotations, replaced by one");
    }

    if(obs.size() == 0) {
      if(obsolete) {
        log(entity, "Term marked deprecated but no obsolescence reason given");
      }
    } else if(obs.size() == 1) {
      obsolete = true;
    } else {
      log(entity, "Multiple obsolescence reason annotations");
    }

    String label = getLabel(entity);
    if(label.startsWith("obsolete")) {
      obsolete = true;
    } else if(obsolete) {
      log(entity, "Obsolete term's name does not start with 'obsolete'");
    }

    if(obsolete && !markedDeprecated) {
      manager.addAxiom(ontology, dataFactory.getOWLAnnotationAssertionAxiom(
        deprecated, entity.getIRI(), dataFactory.getOWLLiteral(true)));
    }

    if(obsolete) {
      if(!inOBI(entity)) {
        log(entity, "OBI should not import obsolete terms");
      }

      // An obsolete Class should have exactly one subClassOf ObsoleteClass,
      // and no equivalentClasses
      if(entity instanceof OWLClass) {
        Set<OWLClassExpression> equivs = entity.asOWLClass().getEquivalentClasses(ontology);
        Set<OWLClassExpression> supers = entity.asOWLClass().getSuperClasses(ontology);
        if(equivs.size() != 0) {
          log(entity, "Obsolete Class should not have equivalentTo axiom");
        }
        if(supers.size() == 0) {
          log(entity, "Obsolete Class should subClassOf ObsoleteClass");
        } else if(supers.size() == 1) {
          OWLClassExpression sup = supers.iterator().next();
          if(sup.isAnonymous() ||
             !sup.asOWLClass().getIRI().toString().equals(
               "http://www.geneontology.org/formats/oboInOwl#ObsoleteClass")) {
            log(entity, "Obsolete Class should only be subClassOf ObsoleteClass");
          }
        } else {
          log(entity, "Obsolete Class should only be subClassOf ObsoleteClass");
        }
      // An obsolete ObjectProperty should have exactly one subClassOf ObsoleteProperty,
      // and no domain or range
      } else if(entity instanceof OWLObjectProperty) {
        Set<OWLObjectPropertyExpression> supers =
          entity.asOWLObjectProperty().getSuperProperties(ontology);
        if(supers.size() == 0) {
          log(entity, "Obsolete ObjectProperty should be subPropertyOf ObsoleteProperty");
        } else if(supers.size() == 1) {
          OWLObjectPropertyExpression sup = supers.iterator().next();
          if(sup.isAnonymous() ||
             !sup.getNamedProperty().getIRI().toString().equals(
               "http://www.geneontology.org/formats/oboInOwl#ObsoleteProperty")) {
            log(entity, "Obsolete ObjectProperty should only be subPropertyOf ObsoleteProperty");
          }
        } else {
          log(entity, "Obsolete ObjectProperty should only be subPropertyOf ObsoleteProperty");
        }
        if(entity.asOWLObjectProperty().getDomains(ontology).size() != 0) {
          log(entity, "Obsolete ObjectProperty should not have any domains");
        }
        if(entity.asOWLObjectProperty().getRanges(ontology).size() != 0) {
          log(entity, "Obsolete ObjectProperty should not have any ranges");
        }
      }
    }

    return true;
  }

  /**
   * Given an OWLEntity, check for exactly one curation status annotation.
   * Add a "metadata complete" or "metadata incomplete" annotation as required.
   *
   * @param entity the OWLEntity to check
   * @param complete true if the minimal metadata criteria have been met
   * @return true if there is exactly one curation status annotation
   */
  public static boolean checkCurationStatus(OWLEntity entity, Boolean complete) throws IOException {
    OWLAnnotationProperty status = dataFactory.getOWLAnnotationProperty(
        IRI.create("http://purl.obolibrary.org/obo/IAO_0000114"));
    Set<OWLAnnotation> statuses = entity.getAnnotations(ontology, status);
    OWLNamedIndividual metadataComplete = dataFactory.getOWLNamedIndividual(
        IRI.create("http://purl.obolibrary.org/obo/IAO_0000120"));
    OWLNamedIndividual metadataIncomplete = dataFactory.getOWLNamedIndividual(
        IRI.create("http://purl.obolibrary.org/obo/IAO_0000123"));
    OWLNamedIndividual uncurated = dataFactory.getOWLNamedIndividual(
        IRI.create("http://purl.obolibrary.org/obo/IAO_0000124"));

    if(statuses.size() == 0) {
      if(complete) {
        log(entity, "No curation status given, but metadata is complete");
        manager.addAxiom(ontology, dataFactory.getOWLAnnotationAssertionAxiom(
            status, entity.getIRI(), metadataComplete.getIRI()));
        return true;
      } else {
        log(entity, "No curation status given, metadata is not complete");
        manager.addAxiom(ontology, dataFactory.getOWLAnnotationAssertionAxiom(
            status, entity.getIRI(), metadataIncomplete.getIRI()));
        return false;
      }
    } else if(statuses.size() == 1) {
      OWLAnnotationValue value = statuses.iterator().next().getValue();
      if(value instanceof IRI && value.compareTo(uncurated.getIRI()) == 0) {
        log(entity, "Curation status is 'uncurated'");
        return false;
      }
      return true;
    } else {
      log(entity, "Multiple curation status annotations");
      return false;
    }
  }

}

