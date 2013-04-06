# OBI Build Tool README

This is a tool for building a self-contained OBI file from the development files. It's a work in progress -- help is welcome.


## Requirements

- [Subversion](http://subversion.tigris.org/)
  - The version control system we use to store our files.
- [Java Runtime Environment](http://docs.oracle.com/javase/7/docs/webnotes/install/index.html)
  - Already installed on most systems.
- [Apache Ant](http://ant.apache.org)
  - Ant is a build system used to compile and run Java programs.
  - May already be installed on your system: try running `ant` at the command line.
- [Apache Ivy](http://ant.apache.org/ivy/)
  - An Ant plug-in used to download dependencies -- not absolutely necessary if you want to fetch the dependencies yourself. See "Dependencies" below.
  - May already be installed on your system.


## Setup

The tool will work on Windows, Linux, Unix, and Mac OS X. A few steps are required to get all the code and get it ready to run.

### Unix, Linux, Mac OS X

1. Create a working directory for OBI (if you haven't already):

    mkdir obi
    cd obi

2. Use Subversion to download the latest OBI (if you haven't already):

    mkdir ontology
    cd ontology
    svn co https://obi.svn.sourceforge.net/svnroot/obi/trunk/src/ontology/branches/
    svn co https://obi.svn.sourceforge.net/svnroot/obi/trunk/src/ontology/external/
    cd ..

3. Use Subversion to download the latest build tool:

    mkdir tools
    cd tools
    svn co https://obi.svn.sourceforge.net/svnroot/obi/trunk/src/tools/build/
    cd build

4. Use Ant and Ivy to download the dependencies (if you didn't download them yourself, see "Dependencies" below):

    ant deps

NOTE: You can edit the `ontology_path` in `config.properties` to tell the tool to look elsewhere for your working directory.

### Windows

TODO: Should be parallel to the Unix instructions.


## Usage

Use Ant to build a self-contained OWL file for OBI:

    ant build

Look in `results` for the new OWL files. More Ant build tasks are available, see:

    ant help

### OBI Core

You can also extract a new version of OBI Core from the OBI OWL file you just built:

    ant core

The program uses the IRIs in `core.txt` to extract the core. If you want to extract a different subset of OBI, you can modify the `core.txt` file.


## Configuration

You can change details of the build process by editing `config.properties`.


## Dependencies

Right now the only dependency is OWLAPI. Download the latest distribution Jar file from [http://owlapi.sourceforge.net/]() (e.g. `owlapi-distribution-3.4.3-bin.jar`) and copy it to `lib`.






