package obi;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.util.Scanner;

import java.util.Map;
import java.util.HashMap;

import javax.xml.namespace.QName;
import javax.xml.stream.events.XMLEvent;
import javax.xml.stream.XMLStreamException;
import org.codehaus.stax2.XMLInputFactory2;
import org.codehaus.stax2.XMLOutputFactory2;
import org.codehaus.stax2.XMLStreamReader2;
import org.codehaus.stax2.XMLStreamWriter2;

/**
 * Add comments to an OWLXML file.
 * 
 * @author <a href="mailto:james@overton.ca">James A. Overton</a>
 */
public class Commenter {

  /**
   * Given an OWLXML file path and a spreadsheet path (containing tab-separated values)
   * use the IRIs and labels in the spreadsheet to add comments to the OWLXML.
   *
   * @param args Three strings:
   *   1. the name of the input OWLXML file
   *   2. the name of the report
   *   3. the name of the output OWLXML file
   */
  public static void main(String[] args) {
    try {
      File inFile = new File(args[0]);
      File reportFile = new File(args[1]);
      File outFile = new File(args[2]);
      Map<String,String> labelMap = getLabelMap(reportFile);
      System.out.println("Adding XML comments to "+ args[0]);
      addComments(inFile, labelMap, outFile);
      System.out.println("Saved comments to "+ args[2]);
    } catch (Exception e) {
      System.out.println("ERROR: Could not add comments to OWLXML file with arguments:");
      for (String arg: args) System.out.println ("  " + arg);
      System.out.println(e.getMessage());
    }
  }

  /**
   * Given a spreadsheet file containing tab-separated values,
   * where the second column is the term IRI and the fourth is the term label,
   * return a map from IRIs to labels.
   *
   * @param file the spreadsheet file
   * @return a map from IRI strings to label strings
   */
  public static Map<String,String> getLabelMap(File file) throws FileNotFoundException {
    Map<String,String> labelMap = new HashMap<String,String>();
    Scanner scanner = new Scanner(file);
    scanner.nextLine();
    while (scanner.hasNextLine()) {
      try {
        String[] strings = scanner.nextLine().split("\t");
        labelMap.put(strings[1], strings[3]); // HACK: this should not be hard-coded
      } catch (Exception e) { }
    }

    return labelMap;
  }

  /**
   * Given an OWLXML file and a map from IRIs to labels,
   * look for rdf:about and rdf:resource attributes with IRIs,
   * and append XML comments with the label for that IRI.
   * Cases:
   * 1. empty start element: advance one step to the end element
   *   then write the comment.
   * 2. non-empty start element: write the comment then advance
   *
   * @param inFile the OWLXML file to read
   * @param labelMap a map from IRI strings to label strings
   * @param outFile the OWLXML file to write
   */
  public static void addComments(File inFile, Map<String,String> labelMap, File outFile)
      throws XMLStreamException, IOException {
    String rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
    XMLStreamReader2 reader = ((XMLInputFactory2) XMLInputFactory2.newInstance())
        .createXMLStreamReader(inFile);
    XMLStreamWriter2 writer = (XMLStreamWriter2) ((XMLOutputFactory2) XMLOutputFactory2.newInstance())
        .createXMLStreamWriter(new FileOutputStream(outFile), "UTF-8");

    writer.writeStartDocument("UTF-8", "1.0");
    writer.writeCharacters("\n");

    while(reader.hasNext()) {
      int eventType = reader.next();
      writer.copyEventFromReader(reader, true);

      if(eventType == XMLEvent.START_ELEMENT) {
        String iri = reader.getAttributeValue(rdf, "resource");
        if(iri == null || iri.length() == 0) {
          iri = reader.getAttributeValue(rdf, "about");
        }
        if(iri == null || iri.length() == 0) { continue; }

        String label = labelMap.get(iri);
        if(label == null) { continue; }

        if(reader.isEmptyElement()) {
          reader.next(); // advance to END_ELEMENT
          writer.copyEventFromReader(reader, true);
        }
        writer.writeComment(" "+ label +" ");
      }
    }

  }

}
