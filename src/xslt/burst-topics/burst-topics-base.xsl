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
  
  <xsl:import href="../org.dita-community.common.xslt/xsl/dita-support-lib.xsl"/>
  <xsl:import href="../org.dita-community.common.xslt/xsl/relpath_util.xsl"/>
  
  <xsl:param name="outdir" as="xs:string" select="'burst-result'"/>
  <xsl:param name="mapFormat" as="xs:string" select="'map'"/>
  
  <xsl:output name="map"
    doctype-public="-//OASIS//DTD DITA Map//EN"
    doctype-system="map.dtd"
    indent="yes"
  />
  <xsl:output name="topic"
    doctype-public="-//OASIS//DTD DITA Topic//EN"
    doctype-system="topic.dtd"
  />
  <xsl:output name="concept"
    doctype-public="-//OASIS//DTD DITA Concept//EN"
    doctype-system="concept.dtd"
  />
  <xsl:output name="reference"
    doctype-public="-//OASIS//DTD DITA Reference//EN"
    doctype-system="reference.dtd"
  />
  <xsl:output name="task"
    doctype-public="-//OASIS//DTD DITA Task//EN"
    doctype-system="task.dtd"
  />
  
  <xsl:template match="/">
    <xsl:variable name="outputDir" as="xs:string"
      select="relpath:newFile(relpath:getParent(document-uri(.)), $outdir)"
    />
    <xsl:variable name="inputFilename" as="xs:string"
      select="relpath:getNamePart(document-uri(.))"
    />
    <xsl:variable name="mapUri" as="xs:string"
      select="relpath:newFile($outputDir, concat($inputFilename, '.ditamap'))"
    />
    
    <!-- Generate the map that will refer to all the topics once they 
         are burst:         
      -->
    <xsl:message> + [INFO] Generating map document "<xsl:value-of select="$mapUri"/>"...</xsl:message>
    <xsl:result-document href="{$mapUri}" format="{$mapFormat}">
      <map>
        <xsl:apply-templates mode="make-map"/>
      </map>
    </xsl:result-document>
    
    <xsl:message> + [INFO] Bursting topics...</xsl:message>
    <xsl:apply-templates mode="make-topics">
      <xsl:with-param name="outputDir" as="xs:string" tunnel="yes" select="$outputDir" />
    </xsl:apply-templates>
    <xsl:message> + [INFO] Topics burst...</xsl:message>
  </xsl:template>
  
  <!-- ================================
       Mode make-map
       ================================ -->
  
  <xsl:template mode="make-map" match="*[df:class(., 'topic/topic')]">
    
    <xsl:variable name="topicFilename" as="xs:string" select="local:constructTopicFilename(.)"/>

   <!-- FIXME: Will need the map path if we want to construct references relative to the map that are not
        in the same directory.
     -->
   <topicref href="{$topicFilename}">
     <xsl:apply-templates mode="#current" select="*[df:class(., 'topic/topic')]"/>
   </topicref>
    
  </xsl:template>
  
  <xsl:template mode="make-map" match="text() | processing-instruction() | comment()"/>
  
  <!-- ================================
       Mode make-topics
       ================================ -->
  
  <xsl:template mode="make-topics" match="*[df:class(., 'topic/topic')]">
    <xsl:param name="topicFormat" as="xs:string" select="name(.)"/>
    <xsl:variable name="topicFilename" as="xs:string" select="local:constructTopicFilename(.)"/>
    <xsl:variable name="topicUri" as="xs:string"
      select="relpath:newFile($outdir, $topicFilename)"
    />
    
    <!-- FIXME: Parameterize the @format value -->
    <xsl:message> + [INFO] Generating topic "<xsl:value-of select="$topicUri"/></xsl:message>
    <xsl:result-document href="{$topicUri}" format="{$topicFormat}">
      <xsl:apply-templates select="." mode="copy-topic"/>
    </xsl:result-document>
    
    <xsl:apply-templates mode="#current" select="*[df:class(., 'topic/topic')]"/>
    
  </xsl:template>
  
  
  
  <!-- ================================
       Mode copy-topic
       ================================ -->
  
  <xsl:template mode="copy-topic" match="*[df:class(., 'topic/topic')]">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates mode="#current"
        select="@*, node() except (*[df:class(., 'topic/topic')])"
      />
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="copy-topic" match="*" priority="-1">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates mode="#current"
        select="@*, node()"
      />
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@class | @domains | @ditaarch:DITAArchVersion" mode="copy-topic"/>
  
  <xsl:template match="@*" priority="-1" mode="copy-topic">
    <xsl:sequence select="."/>
  </xsl:template>
  
  <xsl:template mode="copy-topic" match="text() | processing-instruction() | comment()">
    <xsl:sequence select="."/>
  </xsl:template>
  
  <!-- ================================
       Functions
       ================================ -->

  
  <xsl:function name="local:constructTopicFilename" as="xs:string">
    <xsl:param name="topicElem" as="element()"/>
    
    <xsl:variable name="filenameBase" as="xs:string"
      select="relpath:getNamePart(document-uri(root($topicElem)))"
    />
    <xsl:variable name="result" 
      select="if ($topicElem/ancestor::*[df:class(., 'topic/topic')]) 
      then concat($filenameBase, '-', $topicElem/@id, '.dita')
      else concat($filenameBase, '.dita')" 
      as="xs:string"/>
    <xsl:sequence select="$result"/>
  </xsl:function>
</xsl:stylesheet>