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

import obi.Test;

/**
 * Represent a single DL Query test.
 *  
 * @author <a href="mailto:james@overton.ca">James A. Overton</a>
 */
public class DLTest extends Test {

  /**
   * Construct a test from a block of text.
   *
   * @param block the string definition of the test.
   */
  public DLTest(String block) {
    try {
      String[] lines = block.split("\n");
      fact = lines[0].replaceAll("^Fact:", "").trim();
      query = lines[1].replaceAll("^Query:", "").trim();
      String check = "";
      checks = new ArrayList<String>();
      for(int i=2; i < lines.length; i++) {
        String line = lines[i];
        if(!line.startsWith("  ")) {
          if(!check.trim().isEmpty()) {
            checks.add(check);
            check = "";
          }
        }
        check += line;
      }
      if(!check.trim().isEmpty()) { checks.add(check); }

      //System.out.println("Fact: " + fact);
      //System.out.println("Query: " + query);
      //for(String c: checks) {
      //  System.out.println("Check: " + c);
      //}
    } catch (Exception e) {
      System.out.println("ERROR creating test: " + e.getMessage());
    }
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
  protected boolean checkOne(FileWriter writer, OWLReasoner reasoner,
      ManchesterSyntaxTool parser, OWLClassExpression queryObject,
      String check) throws IOException {

    // Get the method, comparison, and tokens.
    List<String> tokens = getTokens(check);
    String method = tokens.get(0);
    String compare = tokens.get(1);
    tokens = tokens.subList(2, tokens.size());

    // Use the method to get the node set.
    Set<? extends OWLObject> got;
    if (method.equals("Subclasses:")) {
      got = reasoner.getSubClasses(queryObject, true).getFlattened();
    }
    else if (method.equals("Descendants:")) {
      got = reasoner.getSubClasses(queryObject, false).getFlattened();
    }
    else if (method.equals("Superclasses:")) {
      got = reasoner.getSuperClasses(queryObject, true).getFlattened();
    }
    else if (method.equals("Ancestors:")) {
      got = reasoner.getSuperClasses(queryObject, false).getFlattened();
    }
    else if (method.equals("Equivalents:")) {
      got = reasoner.getEquivalentClasses(queryObject).getEntities();
    }
    else if (method.equals("Individuals:")) {
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
        writer.write("     EXPECTED ANYTHING\n");
        writer.write("     GOT NOTHING\n");
        return false;
      }
    }
    else if (compare.equals("nothing")) {
      if (got.size() == 0) {
        writer.write("PASS " + check + "\n");
        return true;
      } else {
        writer.write("FAIL " + check + "\n");
        writer.write("     EXPECTED NOTHING\n");
        writer.write("     GOT\n");
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
        writer.write("     EXPECTED " + number + " \n");
        writer.write("     GOT " + got.size() + "\n");
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
      writer.write("     " + e.getMessage());
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

}
