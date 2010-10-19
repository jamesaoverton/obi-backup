Making the merged file:

1. make freshly check out of obi files

2. assign new IDs using the lisp scripts written by Alan

3. generate disjoint.owl using lisp script written by Alan

4. create list-purls.xml file by running lisp script. Some missing IDs 
were found and saved in missing-ids.txt (both files can be found under 
releases/2010-08-19 directory

5. manually load disjoint.owl after open obi.owl using Protege 4.1
    classified using Hermit, no conflicts were found and reasoning took 
185 sec

6. manually fix some disjoint axioms fro specimen related to storage 
process and add disjoints of following classes:
    fresh specimen OBI_0000971
    frozen specimen OBI_0000922
    lyophilized specimen OBI_0000965
    agar stab specimen OBI_0000981
    paraffin specimen OBI_0000950
    classified using Hermit, no conflicts were found and reasoning took 
185 sec

7. Create inferred-superclasses.owl using P4.1
    only export inferred axioms of Subclasses

8. merge the files including disjoint.owl and inferred-superclasses.owl, 
remove all defined classes under places holder using Java code written 
by Melanie (I made minor modification)

9. open the saved merged-obi.owl using P4.1 for getting neat format and 
manually clean the header
    now classification took 220 sec using Hermit

10. got svn log and saved as SVNlogs.txt under 
releases/2010-08-19/merged directory

Note: The quality checking of curation status and  editor preferred term 
properties have been done before creating the merged file.