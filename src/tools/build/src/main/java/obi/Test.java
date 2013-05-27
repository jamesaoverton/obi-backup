package obi;

import java.io.File;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.util.Scanner;
import java.io.FileWriter;

import java.util.Set;
import java.util.HashSet;
import java.util.List;
import java.util.ArrayList;
import java.util.regex.Pattern;
import java.lang.IllegalArgumentException;

import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLObject;
import org.semanticweb.owlapi.model.OWLEntity;
import org.semanticweb.owlapi.model.OWLIndividual;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.model.OWLClassExpression;
import org.semanticweb.owlapi.model.OWLAnnotation;
import org.semanticweb.owlapi.model.OWLAnnotationValue;
import org.semanticweb.owlapi.model.OWLLiteral;
import org.semanticweb.owlapi.expression.ParserException;

import org.semanticweb.owlapi.reasoner.Node;
import org.semanticweb.owlapi.reasoner.NodeSet;
import org.semanticweb.owlapi.reasoner.OWLReasoner;

import org.obolibrary.macro.ManchesterSyntaxTool;

/**
 * Represent a single DL Query test.
 *  
 * @author <a href="mailto:james@overton.ca">James A. Overton</a>
 */
public class Test {

  protected String fact;
  protected String query;
  protected List<String> checks;

  /**
   * Pattern for matching tokens in lists of OWL entities.
   */
  protected Pattern pattern = Pattern.compile(
    "\"[^\"]*\"" +
    "|'[^']*'" +
    "|[^,\\s]+"
  );

  /**
   * Parse a check string into a list of tokens.
   *
   * @param check the string to parse
   * @return a list of token strings
   */
  protected List<String> getTokens(String check) {
    Scanner scanner = new Scanner(check);
    List<String> tokens = new ArrayList<String>();
    String token;
    while ((token = scanner.findInLine(pattern)) != null) {
        //System.out.println("[" + token + "]");
        tokens.add(token);
    }
    return tokens;
  }

  /**
   * Given a log writer and a reasoner, run all tests.
   *
   * @param writer a FileWriter for the log
   * @param reasoner the initalized reasoner for the ontology
   * @return true if all tests pass, false otherwise
   */
  public boolean run(FileWriter writer, OWLReasoner reasoner)
      throws IOException {
    System.out.println("Test.run is not implemented");
    return true;
  }

  /**
   * Given a writer, an ontology, and a set of OWL objects,
   * write the names of the objects to the writer.
   *
   * @param writer a FileWriter for the log
   * @param ontology the ontology to get names from
   * @param objects the list of objects to get names for
   */
  protected void writeNames(FileWriter writer, OWLOntology ontology,
      Set<? extends OWLObject> objects) throws IOException {
    List<String> names = new ArrayList<String>();
    for(OWLObject o: objects) {
      names.add(getName(ontology, o));
    }
    java.util.Collections.sort(names);
    for(String name: names) {
      writer.write("        " + name + "\n");
    }
  }

  /**
   * Given an ontology and an OWL object, try to find an rdfs:label.
   * This should be easier, but we have to search all imports.
   *
   * @param baseOntology the base ontology to search
   * @param object the OWL object to find a label for
   * @return the first rdfs:label found, 
   *  or just the string representation of the object
   */
  protected String getName(OWLOntology baseOntology, OWLObject object) {
    OWLDataFactory df = baseOntology.getOWLOntologyManager().getOWLDataFactory();
    if(object instanceof OWLEntity) {
      OWLEntity entity = (OWLEntity) object;

      // Return the first label for this entity from any imported ontology.
      Set<OWLOntology> ontologies = baseOntology.getImportsClosure();
      for (OWLOntology ontology : ontologies) {
        Set<OWLAnnotation> annotations = entity.getAnnotations(ontology, df.getRDFSLabel());
        if(annotations.size() > 0) {
          OWLAnnotation annotation = annotations.iterator().next();
          OWLAnnotationValue value = annotation.getValue();
          if(value instanceof OWLLiteral) {
            OWLLiteral literal = (OWLLiteral) value;
            return "'" + literal.getLiteral() + "'";
          }
        }
      }
    }
    return object.toString();
  }

  /**
   * Given a parser and a list of token strings, 
   * return a list of the resolved OWL objects.
   *
   * @param parser the Manchester parser for resolving references
   * @param tokens the list of string tokens to resolve
   * @throws IllegalArgumentException if a token cannot be resolved
   * @return a list of OWL objects
   */
  protected Set<OWLObject> getObjects(ManchesterSyntaxTool parser,
      List<String> tokens)
      throws IllegalArgumentException {
    Set<OWLObject> objects = new HashSet<OWLObject>();
    for (String token: tokens) {
      try {
        OWLClassExpression c = parser.parseManchesterExpression(token);
        objects.add((OWLObject) c);
      } catch(ParserException e) {
        try {
          OWLIndividual i = parser.parseManchesterIndividualExpression(token);
          objects.add((OWLObject) i);
        } catch(ParserException e2) {
          throw new IllegalArgumentException("ERROR unknown entity: " + token + "\n");
        }
      }
    }
    return objects;
  }


}
