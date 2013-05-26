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

  private String fact;
  private String query;
  private List<String> checks;

  /**
   * Pattern for matching tokens in lists of OWL entities.
   */
  private Pattern pattern = Pattern.compile(
    "\"[^\"]*\"" +
    "|'[^']*'" +
    "|[A-Za-z0-9'\\-]+"
  );

  /**
   * Construct a test from a block of text.
   *
   * @param block the string definition of the test.
   */
  public Test(String block) {
    try {
      String[] lines = block.split("\n");
      fact = lines[0].trim();
      query = lines[1].replaceAll("^Query:", "").trim();
      checks = new ArrayList<String>();
      for(int i=2; i < lines.length; i++) {
        String line = lines[i];
        checks.add(line);
      }
    } catch (Exception e) {
      System.out.println("ERROR creating test: " + e.getMessage());
    }
  }

  /**
   * Parse a check string into a list of tokens.
   *
   * @param check the string to parse
   * @return a list of token strings
   */
  private List<String> getTokens(String check) {
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
    writer.write("\nFACT " + fact +"\n");
    OWLOntology ontology = reasoner.getRootOntology();
    ManchesterSyntaxTool parser;
    OWLClassExpression queryObject;
    try {
      parser = new ManchesterSyntaxTool(ontology);
      queryObject = parser.parseManchesterExpression(query);
      writer.write("OK   Query: " + query + "\n");
      writer.write("OK   Query Object: " + queryObject + "\n");
    } catch(ParserException e) {
      writer.write("FAIL Error parsing query: " + query + "\n");
      System.out.println("ERROR PARSING QUERY: " + query); // TODO: make this informative
      return false;
    }

    int total = 0;
    int passed = 0;
    for(String check: checks) {
      total++;
      boolean pass = checkOne(writer, reasoner, parser, queryObject, check);
      if(pass) { passed++; }
    }

    writer.write("\nPassed " + passed + " of " +  total + " checks\n");

    return total == passed;
  }

  /**
   * Given a log writer, reasoner, parser, query object, and a check string,
   * run the check against the query object.
   *
   * @param writer a FileWriter for the log
   * @param reasoner the initalized reasoner for the ontology
   * @param parser used to resolve tokens
   * @param queryObject the class expression to check against
   * @param check the check string
   * @return true if the check passes, false otherwise
   */
  private boolean checkOne(FileWriter writer, OWLReasoner reasoner,
      ManchesterSyntaxTool parser, OWLClassExpression queryObject,
      String check) throws IOException {

    // Get the method, comparison, and tokens.
    List<String> tokens = getTokens(check);
    String method = tokens.get(0);
    String compare = tokens.get(1);
    tokens = tokens.subList(2, tokens.size());

    // Use the method to get the node set.
    Set<? extends OWLObject> got;
    if (method.equals("Subclasses")) {
      got = reasoner.getSubClasses(queryObject, true).getFlattened();
    }
    else if (method.equals("Descendants")) {
      got = reasoner.getSubClasses(queryObject, false).getFlattened();
    }
    else if (method.equals("Superclasses")) {
      got = reasoner.getSuperClasses(queryObject, true).getFlattened();
    }
    else if (method.equals("Ancestors")) {
      got = reasoner.getSuperClasses(queryObject, false).getFlattened();
    }
    else if (method.equals("Equivalents")) {
      got = reasoner.getEquivalentClasses(queryObject).getEntities();
    }
    else if (method.equals("Individuals")) {
      got = reasoner.getInstances(queryObject, false).getFlattened();
    }
    else {
      writer.write("FAIL Unknown checking method: " + method + "\n");
      System.out.println("ERROR: Unknown checking method: " + method);
      return false;
    }

    OWLOntology ontology = reasoner.getRootOntology();
    OWLDataFactory df = ontology.getOWLOntologyManager().getOWLDataFactory();
    got.remove(df.getOWLNothing());
    got.remove(df.getOWLThing());

    if (compare.equals("anything")) {
      if (got.size() > 0) {
        writer.write("PASS " + check + "\n");
        return true;
      } else {
        writer.write("FAIL " + check + "\n");
        writer.write("    EXPECTED ANYTHING\n");
        writer.write("    GOT NOTHING\n");
        return false;
      }
    }
    else if (compare.equals("nothing")) {
      if (got.size() == 0) {
        writer.write("PASS " + check + "\n");
        return true;
      } else {
        writer.write("FAIL " + check + "\n");
        writer.write("    EXPECTED NOTHING\n");
        writer.write("    GOT\n");
        writeNames(writer, ontology, got);
        return false;
      }
    }
    else if (compare.equals("number")) {
      int number = Integer.parseInt(tokens.get(0));
      if (got.size() == number) {
        writer.write("PASS " + check + "\n");
        return true;
      } else {
        writer.write("FAIL " + check + "\n");
        writer.write("    EXPECTED " + number + " \n");
        writer.write("    GOT " + got.size() + "\n");
        writeNames(writer, ontology, got);
        return false;
      }
    }

    // Get the expected objects.
    Set<OWLObject> expected;
    try {
      expected = getObjects(parser, tokens);
    } catch (IllegalArgumentException e) {
      writer.write("FAIL " + check + "\n");
      writer.write("    " + e.getMessage());
      return false;
    }

    // Compare sets.
    boolean passed = false;
    if (compare.equals("exactly")) {
      passed = got.equals(expected);
    }
    else if (compare.equals("include")) {
      passed = got.containsAll(expected);
    }
    else if (compare.equals("exclude")) {
      passed = true;
      for(OWLObject o: expected) {
        if(got.contains(o)) {
          passed = false;
          break;
        }
      }
    }
    else {
      System.out.println("ERROR: Unknown comparison: " + compare);
      return false;
    }

    // Write report on this check.
    if(passed) {
      writer.write("PASS " + check + "\n");
      return true;
    } else {
      writer.write("FAIL " + check + "\n");
      if(compare.equals("exclude")) {
        writer.write("    EXPECTED NONE OF\n");
      } else {
        writer.write("    EXPECTED\n");
      }
      writeNames(writer, ontology, expected);
      writer.write("    GOT\n");
      writeNames(writer, ontology, got);
      return false;
    }
  }

  /**
   * Given a writer, an ontology, and a set of OWL objects,
   * write the names of the objects to the writer.
   *
   * @param writer a FileWriter for the log
   * @param ontology the ontology to get names from
   * @param objects the list of objects to get names for
   */
  private void writeNames(FileWriter writer, OWLOntology ontology,
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
  private String getName(OWLOntology baseOntology, OWLObject object) {
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
  private Set<OWLObject> getObjects(ManchesterSyntaxTool parser,
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
