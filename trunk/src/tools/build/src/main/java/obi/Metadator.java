package obi;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.io.UnsupportedEncodingException;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import org.xml.sax.SAXException;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.Element;

import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;

/**
 * Add metadata to an ontology file. We use Java XML methods rather than OWLAPI.
 * 
 * @author <a href="mailto:james@overton.ca">James A. Overton</a>
 */
public class Metadator {
  /**
   * Given a source ontology and a DOAP file, copy the owl:Ontology element
   * from the source ontology, and the DOAP elements, then save the result.
   *
   * @param args Five strings:
   *   1. the name of the source ontology file
   *   2. the name of the doap.xml file
   *   3. the date string for the target ontology
   *   4. the version IRI for the target ontology
   *   5. the name of the output file -- it is modified and saved in place
   */
  public static void main(String[] args) {
    try {
      File sourceFile = new File(args[0]);
      File doapFile = new File(args[1]);
      String date = args[2];
      String iri = args[3];
      File targetFile = new File(args[4]);

      updateMetadata(sourceFile, doapFile, targetFile, date, iri);
    } catch (Exception e) {
      System.out.println("ERROR: Could not update metadata with arguments:");
      for (String arg: args) System.out.println ("  " + arg);
      System.out.println(e.getMessage());
    }
  }

  /**
   * Given a source file, DOAP file, target file, date, and IRI...
   * Parse the source, DOAP, and target XML, then call various methods
   * to update the target file and write the results.
   *
   * @param sourceFile the source of the owl:Ontology element
   * @param doapFile the source of the DOAP elements
   * @param targetFile the OWL XML file to modify
   * @param date the date string to set for the target ontology
   * @param iri the version IRI string to set for the target ontology
   */
  public static void updateMetadata(File sourceFile, File doapFile, File targetFile,
      String date, String iri)
      throws ParserConfigurationException, SAXException, IOException, TransformerException {
    DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
    Document sourceDoc = builder.parse(sourceFile);
    Document doapDoc   = builder.parse(doapFile);
    Document targetDoc = builder.parse(targetFile);

    updateOntology(sourceDoc, targetDoc, date, iri);
    removeImports(targetDoc);
    updateDOAP(doapDoc, targetDoc);
    writeDocument(targetDoc, targetFile);
  }

  /**
   * Copy the owl:Ontology element from the source document to the target
   * document, then update the version information in the target document.
   *
   * @param sourceDoc the source to copy the owl:Ontology element from
   * @param targetDoc the target document to modify
   * @param date the version date for the target ontology
   * @param iri the version IRI for the target ontology
   */
  public static void updateOntology(Document sourceDoc, Document targetDoc,
      String date, String iri) {
    // Copy the owl:Ontology element
    Element sourceOntologyNode = (Element) sourceDoc.getElementsByTagName("owl:Ontology").item(0);
    Element targetOntologyNode = (Element) targetDoc.getElementsByTagName("owl:Ontology").item(0);
    String targetIRI = targetOntologyNode.getAttribute("rdf:about");
    Element adopted = (Element) targetDoc.adoptNode(sourceOntologyNode.cloneNode(true));
    targetOntologyNode.getParentNode().replaceChild(adopted, targetOntologyNode);
    if(!targetIRI.equals("http://temporary.org")) {
      adopted.setAttribute("rdf:about", targetIRI);
    }

    // Ensure that the required xmlns attributes are present
    targetDoc.getDocumentElement().setAttribute("xmlns", "http://purl.obolibrary.org/obo/obi.owl#");
    targetDoc.getDocumentElement().setAttribute("xml:base", "http://purl.obolibrary.org/obo/obi.owl");
    targetDoc.getDocumentElement().setAttribute("xmlns:dc", "http://purl.org/dc/elements/1.1/");
    targetDoc.getDocumentElement().setAttribute("xmlns:protege", "http://protege.stanford.edu/plugins/owl/protege#");

    // Add version IRI
    Element versionIRI = targetDoc.createElement("owl:versionIRI");
    versionIRI.setAttribute("rdf:resource", iri);
    adopted.insertBefore(versionIRI, adopted.getFirstChild());

    // Add version information
    Element versionInfo = targetDoc.createElement("owl:versionInfo");
    versionInfo.setAttribute("rdf:datatype", "http://www.w3.org/2001/XMLSchema#string");
    versionInfo.setTextContent(date);
    adopted.insertBefore(versionInfo, versionIRI);

    // Clean whitespace
    adopted.normalize();
    adopted.insertBefore(targetDoc.createTextNode("\n        "), versionIRI);
    adopted.insertBefore(targetDoc.createTextNode("\n        "), versionInfo);
  }

  /**
   * Remove all owl:imports elements from the document.
   *
   * @param doc the target document
   */
  public static void removeImports(Document doc) {
    Node ontologyNode = doc.getElementsByTagName("owl:Ontology").item(0);
    NodeList children = ontologyNode.getChildNodes();
    for (int i = 0; i < children.getLength(); i++) {
      Node child = children.item(i);
      if (child.getNodeName().equals("owl:imports")) {
        ontologyNode.removeChild(child);
      }
    }
    
    // Clean whitespace
    ontologyNode.normalize();
    ontologyNode.replaceChild(doc.createTextNode("\n      "), ontologyNode.getLastChild());
  }
    
  /**
   * Copy DOAP (Description of a Project) elements to the ontology.
   *
   * @param doapDoc the document with the DOAP elements
   * @param targetDoc the document to add the elements to
   */
  public static void updateDOAP(Document doapDoc, Document targetDoc) {
    Node next = targetDoc.getDocumentElement().getFirstChild()
      .getNextSibling().getNextSibling();
    NodeList children = doapDoc.getFirstChild().getChildNodes();
    for (int i = 0; i < children.getLength(); i++) {
      Node child = children.item(i);
      Node adopted = targetDoc.adoptNode(child.cloneNode(true));
      targetDoc.getFirstChild().insertBefore(adopted, next);
    }
    
    // Add xmlns
    targetDoc.getDocumentElement().setAttribute("xmlns:doap", "http://usefulinc.com/ns/doap#");

    // Fix whitespace
    next = targetDoc.getDocumentElement().getFirstChild()
      .getNextSibling().getNextSibling();
    targetDoc.getFirstChild().insertBefore(
        targetDoc.createTextNode("\n\n    "), next);
    targetDoc.getFirstChild().insertBefore(
        targetDoc.createComment("  Description Of A Project  "), next);
    targetDoc.getFirstChild().insertBefore(
        targetDoc.createTextNode("\n\n    "), next);
  }

  /**
   * Write the document to an XML file.
   *
   * @param doc the document to write
   * @param file the file to write to
   */
  public static void writeDocument(Document doc, File file) throws
      TransformerException, UnsupportedEncodingException, FileNotFoundException {
    TransformerFactory transformerFactory = TransformerFactory.newInstance();
    Transformer transformer = transformerFactory.newTransformer();
    transformer.setOutputProperty(OutputKeys.INDENT, "yes");
    DOMSource source = new DOMSource(doc);
    StreamResult result = new StreamResult(
        new OutputStreamWriter(new FileOutputStream(file), "UTF-8"));
    transformer.transform(source, result);
  }

}
