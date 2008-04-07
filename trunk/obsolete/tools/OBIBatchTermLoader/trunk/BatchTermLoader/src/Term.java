import java.util.ArrayList;
import java.util.Vector;


public class Term {
	String termName;
	String obiIdentifier;
	String parentTermName;
	String definition;
	String definitionSource;
	String definitionEditor;
	String example;
	String externalClass;
	ArrayList<String> editorNote;
	ArrayList<String> curationStatus;
	boolean hasParent;
	Vector<Term> kids;
	
	Term(String name, String obiId, String parentName, String def, String definitionSrc, String defEditor, 
			String exampleUsage, String extClass, ArrayList<String> allCurStatusValues, ArrayList<String> allEdNoteValues) {
		termName=name;
		obiIdentifier=obiId;
		parentTermName=parentName;
		definition=def;
		definitionSource=definitionSrc;
		definitionEditor=defEditor;
		example=exampleUsage;
		externalClass=extClass;
		editorNote=allEdNoteValues;
		curationStatus=allCurStatusValues;
		
	}
}
