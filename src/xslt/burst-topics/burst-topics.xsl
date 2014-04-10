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
       Sample top-level transform for using the burst-topics-base.xsl
       transform. 
       
       Customize this transform by adding xsl:output declarations
       to set the public IDs and system IDs for the topic types
       that will be generated:
       
  <xsl:output name="topic"
    doctype-public="urn:pubid:mycompany.com:doctypes:dita:topic"
    doctype-system="topic.dtd"
  />
  
       If you're only generating OASIS-defined topic types (topic,
       concept, task, reference, glossentry, glossgroup) then you
       only need to add the <xsl:output> declarations for each topic
       type you'll generate.
       
       If you have non-standard topic types, then in addition to the
       <xsl:output> declarations you also need templates that
       match on the topic type and set the name of the <xsl:output>
       declaration to use for that topic type:

  <xsl:template match="myTopicType">
    <xsl:next-match>
      <xsl:with-param name="topicFormat" as="xs:string" select="'myTopicType'"/>
    </xsl:next-match>
  </xsl:template>
  
       Where "myTopicType" in the @match attribute is the tagname of the topic
       type (<myTopicType>) and the value in the @select attribute is the
       name used on the corresponding <xsl:output> element.
       
       See burst-topics-d4p.xsl for a working example.
       
       Author: W. Eliot Kimber, ekimber@contrext.com
       
       May be used without restriction
       ================================================= -->
  <xsl:import href="burst-topics-base.xsl"/>
  
  <!-- Put <xsl:output> statements here. -->
<!-- 
  <xsl:output name="topic"
    doctype-public="urn:pubid:mycompany.com:doctypes:dita:topic"
    doctype-system="topic.dtd"
  />
  -->

  <!-- Put <xsl:template> statements here. -->
  
<!-- 
  <xsl:template match="myTopicType">
    <xsl:next-match>
      <xsl:with-param name="topicFormat" as="xs:string" select="'myTopicType'"/>
    </xsl:next-match>
  </xsl:template>  
  -->  

</xsl:stylesheet>