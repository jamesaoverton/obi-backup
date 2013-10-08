# OBI Build Tool README

This is a tool for building and testing a self-contained OBI file from the development files. It's a work in progress -- help is welcome.


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

2. Use Subversion to download the latest OBI files (if you haven't already). There are simpler ways to do this, but this way gets you just the files you need:

    svn checkout --depth immediates svn://svn.code.sf.net/p/obi/code/trunk/src
    svn update --set-depth infinity src/ontology/branches
    svn update --set-depth infinity src/ontology/external
    svn update --set-depth infinity src/tests
    svn update --set-depth infinity src/tools/build
    cd src/tools/build

3. Use Ant and Ivy to download the dependencies (if you didn't download them yourself, see "Dependencies" below):

    ant deps

NOTE: You can edit the `ontology_path` in `config.properties` to tell the tool to look elsewhere for your working directory.

### Windows

TODO: Should be parallel to the Unix instructions.


## Usage

From the `tools/build` directory you can run various Ant "tasks". Here are some examples.

Update the main `branches/obi.owl` file to assign new IDs:

    ant assign-ids

Then build a `release` directory of files:

    ant release
    
The `release` task takes a few minutes to run. It be broken down into five steps.

1. Start with the `branches/obi.owl` file and merge it into a single `dist/obi_merged.owl` file. Then check and update all the terms, generate a `warnings.tsv` file. Finally save a `dist/obi.owl` file:

    ant build

2. Add inferred subClassOf axioms to `dist/obi.owl` -- this uses the reasoner, so it takes a few minutes:

    ant reason

3. Generate a report on all the OBI terms as a tab-separated `dist/obi.tsv` file, and a summary report in `dist/obi.txt`:

    ant report

4. Use the list of IRIs in `core.txt` to extract a new version of OBI Core file and report (`dist/obi_core.owl`, `dist/obi_core.tsv`, and `dist/obi_core.txt`) using the `dist/obi.owl` file you just built:

    ant core

5. Use the 'IEDB alternative term' annotations to create the IEDB view file `dist/obi_iedb.owl`:

    ant iedb


### Tests

You can also run a suite of automated tests using:

    ant test

Test source files are read from `../../tests/` and results are stored in `target/tests/`, including `*.log` files with details on any test failures.

If you're experimenting with OBI, you can run tests on your experiments without committing code to SVN. Put your experiment test files in `build/experiments` and then run to run the test tool against them:

    ant experiment

Results will appear in `target/experiments`.


## Configuration

You can change details of the build process by editing `config.properties`.


## Dependencies

It should be possible to download the dependencies yourself and copy them to `build/lib`:

- The latest OWLAPI: [http://owlapi.sourceforge.net/]() (e.g. `owlapi-distribution-3.4.3-bin.jar`)
- Berkeley Bioinformatics Open-source Projects (BBOP)'s version of HermiT: [http://code.berkeleybop.org/maven/repository/org/semanticweb/HermiT/1.3.6-BBOP/HermiT-1.3.6-BBOP.jar]()
- A recent copy of `jena-core`: [http://search.maven.org/remotecontent?filepath=org/apache/jena/jena-core/2.10.1/jena-core-2.10.1.jar]()
- A recent copy of `jena-arq`: [http://search.maven.org/remotecontent?filepath=org/apache/jena/jena-arq/2.10.1/jena-arq-2.10.1.jar]()
- A recent copy of `log4j`: [http://search.maven.org/remotecontent?filepath=log4j/log4j/1.2.17/log4j-1.2.17.jar]()






