dita-utilities
==============

Random utilities for doing things with DITA, mostly XSLT transforms
but some XQuery too

Topic Burster
-------------

Takes a single XML document containing multiple DITA topics, either a
topic document with nested topics or a compound document with multiple
sibling topics, and "bursts" the topics to separate files and also
generates a map that references the burst topics.  Provides the option
to limit the depth of bursting.

Enhancements generously made possible by [The Content Era](http://thecontentera.com).

Code is under src/xslt/burst-topics.

XSLT runtime parameters:

* burstLevel: sets the level of bursting.  A value of `0` (zero) means
  "burst all", `1` means "only burst top-level topics", etc.  The
  default is `0` (burst all).
* outdir: Directory to put the burst files into.  The default is
  `burst-result` (it will be under the input document's directory).
* mapFormat: The format of map to generate (as defined by an XSLT
  format instruction.  The default is `map`.
* debug: Turn debugging on or off.  A value of `true` turns debugging
  on.  The default is `false`.


Data Set Generator
------------------

Generates arbitrarily-large sets of maps and topics with different
characteristics as a aid for scale and performance testing.

Uses data files to populate the topics with distinguishing content;
for example words randomly selected from the words.xml file (a list of
about 236,000 English words).

The input to the transform is the template topic (generic-topic.xml).
The direct output is a single map document that includes each
generated topic.

The generated topics are grouped into subdirectories with a specified
number of topics in each subdirectory.

Code is under src/xslt/generate-large-datase

XSLT runtime parameters:

* start: The starting number to use for generated filenames.  The
  default is one (`1`).
* count: The number of topics to generate.  The default is `10000`.
* chunkAt: The number of topics to put in each subdirectory.  Default
  is `1000`.
* random: Generate random numbers.  Requires implementation of the
  exslt-random:random-sequence() function.  The default is `false` (no
  random numbers).

Make Keydefs
------------

Generates a new copy of the input map with all key-defining,
non-resource-only topicrefs converted to key references to separate
key definitions.  New key definitions are organized into separate
submaps.

Produces a copy of the input maps with the keydefs generated and any
key-defining topicrefs reworked.  The @href values are not changed in
the result, meaning that they won't resolve until the copy is used to
replace the original maps (or the other files are moved to the same
location relative to the copy as they are to the original).

Code is under src/xslt/make-keydefs

XSLT runtime parameters:

* outputPath: The output directory to use.  Must be specified.
* rootmap-doctype-publicid: The public ID for the generated root map.
  The default is "`-//OASIS//DTD DITA Map//EN`".
* submap-doctype-publicid: The public ID for generate sub maps.
  The default is "`-//OASIS//DTD DITA Map//EN`".

Map-to-Map Transform Sample
---------------------------

A simple map-to-map transform that demonstrates how to process DITA maps 
to modify or enhance them.  Can be used as the basis for new transorms.

Renames maps to make all filenames unique and add title-only topics
for submap titles.

Code is under src/xslt/map-to-map-transform

XSLT runtime parameters:

* outputPath: The output directory to use.  Must be specified
* namePrefix: Prefix to use for generated names.  Must be specified.

Filter Attributes XQuery Module
-------------------------------

XQuery update script to remove
@domains and @class attributes
from DITA documents.

To set up an Oxygen transform:

1. Open the "`Create transformation scenario`" dialog and select "`New
   XQuery tranform`".
2. Set the XML URL to "`${currentFileURL}`".
3. Set the XQuery URL to this transform.
4. Select `Saxon EE` as the Transformer.
5. Click the little gear icon to bring up the Saxon options and make
   sure the "`Use linked tree model`" option is checked.  This is
   required for Saxon to do XQuery updates

Code is in `src/xquery/filter-attributes`

Code examples
-------------

### Excel XML 2004 format to DITA table

In: `src/xslt/excel-xml-to-dita-table`

An example on how to convert a Excel XML 2004 to a DITA table


Submodules
----------

### org.uottawa.audience

A simple plugin which extracts the audience information and output it
as an xml file in your final documentation directory.  The xml file
could be used, for example, to render the list of available audience
for a specific documention using a server-side language like PHP.


### org.uottawa.brand

An example of a customization of the pdf2 plugin of the DITA-OT.
**important:** it only works with Antenna House formatter


### org.uottawa.logs

A simple plugins that logs each call of the DITA-OT per date and transtype.


### org.uottawa.report

Few tests to extracts information on your documentation.  It is a
plugin that parse your documentation and generate a DITA documentation
from it.  For now the plugin creates:

* keydef documentation: one page per keydef on your documentation
* audiences analysis: a table that shows which audience has been
  applied on which topic
