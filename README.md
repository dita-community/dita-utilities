dita-utilities
==============

Random utilities for doing things with DITA, mostly XSLT transforms


Submodules
----------

### org.uottawa.audience

A simple plugin which extracts the audience information and  output it as an xml file in your 
final documentation directory.
The xml file could be used, for example, to render the list of available audience for a specific documention 
using a server-side language like PHP.


### org.uottawa.brand

An example of a customization of the pdf2 plugin of the DITA-OT. 
!important: it only works with Antenna House formatter


### org.uottawa.logs

A simple plugins that logs each call of the DITA-OT per date and transtype.


### org.uottawa.report

Few tests to extracts information on your documentation.
It is a plugin that parse your documentation and generate a DITA documentation from it.
For now the plugin creates:
* keydef documentation: one page per keydef on your documentation
* audiences analysis: a table that shows which audience has been applied on which topic