<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:local="urn:local:functions"
  xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
  exclude-result-prefixes="xs xd relpath df local ditaarch"
  version="2.0">
  
  <!-- =================================================
       Burst a multi-topic document into individual
       topics, generating a map that reflects the topic
       hierarchy.
       
       The input to this transform is either a document
       with a single root topic or a <dita> document
       with one or more child topics.
       
       The outdir parameter specifies the output directory.
       If not specified, the output directory is under the
       directory containing the input document.
       
       Author: W. Eliot Kimber, ekimber@contrext.com
       
       May be used without restriction
       ================================================= -->
  <xsl:import href="burst-topics-base.xsl"/>
  
  <!-- xsl:output declarations for local shells, in this case,
       the DITA for Publishers-defined shells.
  
    -->
  
  <xsl:output name="chapter"
    doctype-public="urn:pubid:dita4publishers.sourceforge.net:doctypes:dita:chapter"
    doctype-system="chapter.dtd"
  />
  <xsl:output name="subsection"
    doctype-public="urn:pubid:dita4publishers.sourceforge.net:doctypes:dita:subsection"
    doctype-system="subsection.dtd"
  />
  
  <xsl:template match="chapter">
    <xsl:next-match>
      <xsl:with-param name="topicFormat" as="xs:string" select="'chapter'"/>
    </xsl:next-match>
  </xsl:template>

  <xsl:template match="subsection">
    <xsl:next-match>
      <xsl:with-param name="topicFormat" as="xs:string" select="'subsection'"/>
    </xsl:next-match>
  </xsl:template>

  
</xsl:stylesheet>