package obi;

import java.io.File;
import java.io.IOException;
import java.util.Scanner;

import java.util.Set;
import java.util.HashSet;
import java.util.List;
import java.util.ArrayList;
import java.util.regex.Pattern;

import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLObject;
import org.semanticweb.owlapi.model.OWLEntity;
import org.semanticweb.owlapi.model.OWLAnnotation;
import org.semanticweb.owlapi.model.OWLAnnotationValue;
import org.semanticweb.owlapi.model.OWLLiteral;

/**
 * Parent class for representing a single test.
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

}
