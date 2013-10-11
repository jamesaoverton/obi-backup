package obi;

import java.io.File;
import java.io.IOException;
import java.io.FileWriter;

import java.util.Set;
import java.util.HashSet;
import java.util.List;
import java.util.ArrayList;
import java.lang.IllegalArgumentException;

import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLIndividual;
import org.semanticweb.owlapi.model.OWLNamedIndividual;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.model.OWLClassExpression;
import org.semanticweb.owlapi.expression.ParserException;

import org.semanticweb.owlapi.reasoner.OWLReasoner;

import org.obolibrary.macro.ManchesterSyntaxTool;

import com.hp.hpl.jena.rdf.model.RDFNode;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.query.QuerySolution;
import com.hp.hpl.jena.query.Dataset;

import obi.Tester;
import obi.Test;

/**
 * Represent a single SPARQL test.
 *  
 * @author <a href="mailto:james@overton.ca">James A. Overton</a>
 */
public class SPARQLTest extends Test {

  /**
   * The list of keywords for SPARQL facts.
   */
  protected static List<String> sparqlChecks = getSPARQLChecks();
  
  /**
   */
  private static List<String> getSPARQLChecks() {
    List<String> list = new ArrayList<String>();
    list.add("ANYTHING");
    list.add("NOTHING");
    list.add("NUMBER");
    list.add("EXACTLY");
    list.add("INCLUDE");
    list.add("EXCLUDE");
    return list;
  };

  /**
   * Construct a test from a block of text.
   *
   * @param block the string definition of the test.
   */
  public SPARQLTest(String block) {
    try {
      String[] lines = block.split("\n");
      fact = lines[0].replaceAll("^FACT", "").trim();
      boolean queryFlag = true;
      query = "";
      String check = "";
      checks = new ArrayList<String>();
      for(int i=1; i < lines.length; i++) {
        String line = lines[i];
        if(queryFlag) {
          for(String prefix: sparqlChecks) {
            if(line.startsWith(prefix)) {
              queryFlag = false;
            }
          }
        }
        if(queryFlag) {
          query += line + "\n";
        } else {
          if(!line.startsWith("  ")) {
            if(!check.trim().isEmpty()) {
              checks.add(check);
              check = "";
            }
          }
          check += line;
        }
      }
      if(!check.trim().isEmpty()) { checks.add(check); }

      //System.out.println("FACT " + fact);
      //System.out.println(query);
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
   * @param dataset the Jena Dataset
   * @return true if all tests pass, false otherwise
   */
  public boolean run(FileWriter writer, OWLReasoner reasoner, Dataset dataset)
      throws IOException {
    writer.write("\nFACT " + fact +"\n");

    OWLOntology ontology = reasoner.getRootOntology();
    ManchesterSyntaxTool parser;
    ResultSet results;
    try {
      parser = new ManchesterSyntaxTool(ontology);
      QueryExecution qexec = QueryExecutionFactory.create(
          Tester.sparqlBase + query, dataset);
      results = qexec.execSelect();
      String[] lines = query.split("\n");
      for(String line: lines) {
        writer.write("OK   " + line + "\n");
      }
    } catch(Exception e) {
      writer.write("FAIL Error parsing query: " + query + "\n");
      System.out.println("ERROR PARSING QUERY: " + query); // TODO: make this informative
      return false;
    }

    Set<String> gotIRIs = new HashSet<String>();
    Set<String> gotNames = new HashSet<String>();
    while(results.hasNext()) {
      QuerySolution solution = results.next();
      gotIRIs.add(getIRIs(results.getResultVars(), solution));
      gotNames.add(getNames(ontology, results.getResultVars(), solution));
    }

    int total = 0;
    int passed = 0;
    for(String check: checks) {
      total++;
      boolean pass = checkOne(writer, parser, results, gotIRIs, gotNames, check);
      if(pass) { passed++; }
    }

    writer.write("\nPassed " + passed + " of " +  total + " checks\n");

    return total == passed;
  }

  /**
   * Given a log writer, reasoner, parser, query results and rows,
   * and a check string, run the check against the results.
   *
   * @param writer a FileWriter for the log
   * @param reasoner the initalized reasoner for the ontology
   * @param parser used to resolve tokens
   * @param resultSet the set of query results
   * @param got a set of rows with IRIs and literals
   * @param gotNames a set of rows with labels and literals
   * @param check the check string
   * @return true if the check passes, false otherwise
   */
  protected boolean checkOne(FileWriter writer, ManchesterSyntaxTool parser,
      ResultSet results, Set<String> got, Set<String> gotNames, String check)
        throws IOException {

    // Get the method, comparison, and tokens.
    List<String> tokens = getTokens(check);
    String compare = tokens.get(0);
    tokens = tokens.subList(1, tokens.size());
    
    // Get the expected objects.
    Set<String> expected;
    Set<String> expectedNames;
    try {
      expected = getExpectedIRIs(writer, parser, results.getResultVars().size(), tokens);
      expectedNames = getExpectedNames(results.getResultVars().size(), tokens);
    } catch (IllegalArgumentException e) {
      writer.write("FAIL " + check + "\n");
      writer.write("     " + e.getMessage());
      return false;
    }

    if (compare.equals("ANYTHING")) {
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
    else if (compare.equals("NOTHING")) {
      if (got.size() == 0) {
        writer.write("PASS " + check + "\n");
        return true;
      } else {
        writer.write("FAIL " + check + "\n");
        writer.write("     EXPECTED NOTHING\n");
        writer.write("     GOT\n");
        writeRows(writer, gotNames);
        return false;
      }
    }
    else if (compare.equals("NUMBER")) {
      int number = Integer.parseInt(tokens.get(0));
      if (got.size() == number) {
        writer.write("PASS " + check + "\n");
        return true;
      } else {
        writer.write("FAIL " + check + "\n");
        writer.write("     EXPECTED " + number + " \n");
        writer.write("     GOT " + got.size() + "\n");
        writeRows(writer, gotNames);
        return false;
      }
    }
    
    // Compare sets.
    boolean passed = false;
    if (compare.equals("EXACTLY")) {
      passed = got.equals(expected);
    }
    else if (compare.equals("INCLUDE")) {
      passed = got.containsAll(expected);
    }
    else if (compare.equals("EXCLUDE")) {
      passed = true;
      for(String row: expected) {
        if(got.contains(row)) {
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
      writeRows(writer, expectedNames); // INFO: make this 'expected' for debugging
      writer.write("    GOT\n");
      writeRows(writer, gotNames); // INFO: make this 'got' for debugging
      return false;
    }
  }

  /**
   * Write a sorted set of rows.
   *
   * @param writer a FileWriter for the log
   * @param got a set of row string to write
   */
  private void writeRows(FileWriter writer, Set<String> got)
      throws IOException {
    List<String> rows = new ArrayList<String>(got);
    java.util.Collections.sort(rows);
    for(String row: rows) {
      writer.write("        " + row + "\n");
    }
  }

  /**
   * Given a parser and tokens, translate the tokens into IRIs and literals
   * and return a set of "rows" (string representations).
   *
   * @param writer a FileWriter for the log
   * @param parser the parser to find the IRIs
   * @param cols the number of columns
   * @param tokens the string tokens to get
   * @return a set of strings, where each string represents a row of results
   */
  private Set<String> getExpectedIRIs(FileWriter writer, 
      ManchesterSyntaxTool parser, int cols, List<String> tokens)
        throws IllegalArgumentException {
    Set<String> rows = new HashSet<String>();
    int counter = 0;
    String row = "";
    for(String token: tokens) {
      counter++;
      String value = token;
      // Try to match a class name, then an individual name.
      if(value.startsWith("'")) {
        String iri = null;
        try {
          OWLClassExpression ce = parser.parseManchesterExpression(token);
          if(ce instanceof OWLClass) {
            OWLClass c = (OWLClass) ce;
            iri = c.getIRI().toString();
          }
        } catch(ParserException e) {
          //System.out.println("CLASS ERROR: " + e.getMessage());
        }
        if(iri == null) {
          try {
            OWLIndividual ind = parser.parseManchesterIndividualExpression(token);
            if(ind instanceof OWLNamedIndividual) {
              OWLNamedIndividual named = (OWLNamedIndividual) ind;
              iri = named.getIRI().toString();
            }
          } catch(ParserException e) {
            //System.out.println("IND ERROR: " + e.getMessage());
          }
        }
        if(iri == null) {
          throw new IllegalArgumentException("ERROR unknown entity: " + token + "\n");
        } else {
          value = "<" + iri + ">";
        }
      } else if (token.startsWith(":")) {
        value = "<" + Tester.baseIRI + "#" + token.substring(1, token.length()) + ">";
      }

      row += value + " ";
      if(counter >= cols) {
        rows.add(row.trim());
        row = "";
        counter = 0;
      }
    }
    return rows;
  }

  /**
   * Divide tokens into rows and return a set of strings.
   *
   * @param cols the number of columns
   * @param tokens the tokens to divide
   * @return a set of strings, where each string represents a row of results
   */
  private Set<String> getExpectedNames(int cols, List<String> tokens) {
    Set<String> rows = new HashSet<String>();
    int counter = 0;
    String row = "";
    for(String token: tokens) {
      counter++;
      row += token + " ";
      if(counter >= cols) {
        rows.add(row.trim());
        row = "";
        counter = 0;
      }
    }
    return rows;
  }

  /**
   * Given a list of variables and a SPARQL solution,
   * return a string "row" representing the results.
   *
   * @param vars a list of the names of the columns
   * @param solution one SPARQL solution
   * @return a string representing the results.
   */
  private String getIRIs(List<String> vars, QuerySolution solution) {
    String result = "";
    for(String var: vars) {
      String value = solution.get(var).toString();

      RDFNode node = solution.get(var);
      if(node.isURIResource()) {
        value = "<" + node.asResource().getURI() + ">";
      } else if (node.isLiteral()) {
        value = "\"" + node.asLiteral().getString() + "\"";
      } else {
        value = "BLANK_NODE";
      }
      
      result += value + " ";
    }
    return result.trim();
  }

  /**
   * Given an ontology, list of variables and a SPARQL solution,
   * return a string "row" representing the results, using labels when possible.
   *
   * @param ontology the ontology to search for labels
   * @param vars a list of the names of the columns
   * @param solution one SPARQL solution
   * @return a string representing the results.
   */
  private String getNames(OWLOntology ontology, List<String> vars, QuerySolution solution) {
    OWLDataFactory df = ontology.getOWLOntologyManager().getOWLDataFactory();
    String result = "";
    for(String var: vars) {
      String value = solution.get(var).toString();

      RDFNode node = solution.get(var);
      if(node.isURIResource()) {
        String uri = node.asResource().getURI();
        IRI iri = IRI.create(uri);
        String name = null;
        if(ontology.containsClassInSignature(iri, true)) {
          value = getName(ontology, df.getOWLClass(iri));
        } else if(ontology.containsObjectPropertyInSignature(iri, true)) {
          value = getName(ontology, df.getOWLObjectProperty(iri));
        } else if(ontology.containsAnnotationPropertyInSignature(iri, true)) {
          value = getName(ontology, df.getOWLAnnotationProperty(iri));
        } else if(ontology.containsIndividualInSignature(iri, true)) {
          value = getName(ontology, df.getOWLNamedIndividual(iri));
        } else if(value.startsWith(Tester.baseIRI + "#")) {
          value = value.replaceFirst(Tester.baseIRI + "#", ":");
        } else {
          value = "<" + uri + ">";
        }
      } else if (node.isLiteral()) {
        value = "\"" + node.asLiteral().getString() + "\"";
      } else {
        value = "BLANK_NODE";
      }
      
      result += value + " ";
    }
    return result.trim();
  }

}