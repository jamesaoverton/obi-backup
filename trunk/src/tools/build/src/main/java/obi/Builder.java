package obi;

import java.io.File;
import java.io.IOException;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.OWLOntologyCreationException;
import org.semanticweb.owlapi.util.OWLOntologyMerger;

import owltools.io.CatalogXmlIRIMapper;
import obi.TermUpdater;


/**
 * This class takes OBI's development files and builds a self-contained
 * OWL file.
 * 
 * @author <a href="mailto:james@overton.ca">James A. Overton</a>
 */
public class Builder {
  /**
   * First obi.owl is loaded, using the import paths in catalog-v001.xml.
   * Then all the imported ontologies are merged into a single file and saved.
   * Then all terms are updated using the TermUpdater, and the result is saved.
   *
   * @param args Two strings:
   *   1. the name of the obi.owl development file
   *   2. the name of the obi_merged.owl output file
   *   3. the name of the obi.owl output file
   */
  public static void main(String[] args) {
    try {
      File devFile = new File(args[0]);
      File mergedFile = new File(args[1]);
      File obiFile = new File(args[2]);
      OWLOntology dev = loadLocalOntology(devFile);
      IRI iri = IRI.create("http://temporary.org");
      System.out.println("Merging ontology files for " + args[0]);
      OWLOntology merged = mergeOntology(dev, iri);
      OWLOntologyManager manager = merged.getOWLOntologyManager();
      System.out.println("Saving merged file to " + args[1]);
      manager.saveOntology(merged, IRI.create(mergedFile.toURI()));
      TermUpdater.updateTerms(merged, args[3]);
      System.out.println("Saving updated file to " + args[2]);
      manager.saveOntology(merged, IRI.create(obiFile.toURI()));
    } catch (Exception e) {
      System.out.println("ERROR: Could not build OBI with arguments:");
      for (String arg: args) System.out.println ("  " + arg);
      System.out.println(e.getMessage());
    }
  }

  /**
   * Load an ontology from a local file using the IRI mappings in the
   * catalog-v001.xml file contained in the same directory.
   *
   * @param file the ontology file to load
   * @return the loaded ontology
   */
  public static OWLOntology loadLocalOntology(File file)
      throws IOException, OWLOntologyCreationException {
    String path = file.getParent();
    String catalogPath = path + "/catalog-v001.xml";
    OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
    manager.addIRIMapper(new CatalogXmlIRIMapper(catalogPath));
    OWLOntology ontology = manager.loadOntologyFromOntologyDocument(file);
    return ontology;
  }

  /**
   * Use the OWLAPI's OWLOntologyMerger to merge all an ontology's imports
   * into a single ontology with a temporary IRI.
   *
   * @param ontology the ontology to merge
   * @param iri the IRI for the new ontology
   * @return the merged ontology
   */
  public static OWLOntology mergeOntology(OWLOntology ontology, IRI iri)
      throws OWLOntologyCreationException {
    OWLOntologyManager manager = ontology.getOWLOntologyManager();
    OWLOntologyMerger merger = new OWLOntologyMerger(manager);
    return merger.createMergedOntology(manager, iri);
  }

}
