FUNCTION: The perl script findLastId.pl is to identify the last used identifier used in an OWL file within a specified range of minimum and maximum values. 

MOTIVATION: The autoId plugin that the OBI group is using to automatically generate the term prefix is not able to identify the last used identifier and this needs to be entered into the id.seed file manually.  

USAGE: perl findLastID.pl inputFile outputFile minId maxId

