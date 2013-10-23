package obi;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.*;
import owltools.io.CatalogXmlIRIMapper;

import java.io.*;

/**
 * This class adds annotation axioms to an ontology for a particular annotation property and a set of annotations given
 * in a tabular file following the pattern:
 * IRI  Label   AnnotationValue
 *
 * Example use: to add 'ISA alternative term' annotations to OBI.
 *
 * @author <a href="mailto:alejandra.gonzalez.beltran@gmail.com">Alejandra Gonzalez-Beltran</a>
 */
public class TermAnnotator {

    /**
     * The manager for the current ontology.
     */
    private static OWLOntologyManager manager = null;

    /**
     * The data factory for the current manager.
     */
    private static OWLDataFactory dataFactory = null;

    /**
     * The ontology being worked on.
     */
    private static OWLOntology ontology = null;


    /**
     * Given an ontology path, an annotation property and a csv file with URIs and annotation information, it loads the ontology and updates each term with the annotation property.
     * Then save the ontology to a new location.
     *
     * @param args 1. the path to the input OWL file
     *             2. the URI of the annotation property
     *             3. the path to the annotations tsv file
     *             4. the path to the output OWL file
     */
    public static void main(String[] args) throws IOException {
        try {
            if (args.length<4) {
                System.err.println("Usage: <OWL file path> <annotation property URI> <annotations tsv file> <OWL output file>");
                System.exit(-1);
            }

            File ontologyFile = new File(args[0]);
            System.out.println("Loading ontology: " + args[0]);

            OWLOntology ont = loadLocalOntology(ontologyFile);

            OWLDataFactory dataFactory = manager.getOWLDataFactory();
            OWLAnnotationProperty annotationProperty = dataFactory.getOWLAnnotationProperty(IRI.create(args[1]));

            annotateTerms(ont, annotationProperty, args[2]);

            System.out.println("Saving ontology to: " + args[3]);
            File outputFile = new File(args[3]);

            manager.saveOntology(ont, IRI.create(outputFile.toURI()));
            manager.removeOntology(ont);
        } catch (Exception e) {
            System.out.println("ERROR: Could update terms with arguments:");
            for (String arg: args) System.out.println ("  " + arg);
            e.printStackTrace();
            System.out.println(e.getMessage());
        }
    }

    public static OWLOntology loadLocalOntology(File file)
            throws IOException, OWLOntologyCreationException {
        String path = file.getParent();
        String catalogPath = path + "/catalog-v001.xml";
        manager = OWLManager.createOWLOntologyManager();
        manager.addIRIMapper(new CatalogXmlIRIMapper(catalogPath));
        OWLOntology ontology = manager.loadOntologyFromOntologyDocument(file);
        return ontology;
    }

    /**
     *
     * @param ont
     * @param annotationProperty
     * @param annotationsFilename
     * @throws IOException
     */
    public static void annotateTerms(OWLOntology ont, OWLAnnotationProperty annotationProperty, String annotationsFilename)  {
        ontology = ont;
        manager = ontology.getOWLOntologyManager();
        dataFactory = manager.getOWLDataFactory();
        BufferedReader bufferedReader = null;

        try {
             bufferedReader = new BufferedReader(new FileReader(annotationsFilename));

            String line;

            while ((line = bufferedReader.readLine()) != null) {

                //IRI	Label	Alternative Term
                String data[] = line.split("\t");

                for(int i=0; i < data.length; i++){

                    IRI termIRI = IRI.create(data[0]);
                    OWLAnnotationSubject annotationSubject = termIRI;
                    OWLAnnotationValue annotationValue = dataFactory.getOWLLiteral(data[2]);
                    OWLAnnotationAssertionAxiom axiom = dataFactory.getOWLAnnotationAssertionAxiom(annotationProperty, annotationSubject, annotationValue);
                    manager.addAxiom(ontology, axiom);

                }

            }
           }catch(FileNotFoundException fnfex){

                System.err.println("ERROR: File "+annotationsFilename+" was not found!");

           }catch(IOException ioex){

                System.err.println("ERRO when reading the file "+annotationsFilename+"!");

           }finally{
            try {
                if (bufferedReader != null)
                    bufferedReader.close();
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        }
        }
}
