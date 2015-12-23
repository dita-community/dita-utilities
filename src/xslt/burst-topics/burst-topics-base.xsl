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
  <xsl:param name="debug" as="xs:string" select="'false'"/>
  
  <xsl:variable name="doDebug" as="xs:boolean" 
    select="matches($debug, '1|yes|true|on', 'i')"
  />
  
  <xsl:output omit-xml-declaration="yes"/>
  
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
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] #default '/': Starting... </xsl:message>
    </xsl:if>
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
        <xsl:apply-templates mode="make-map">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:apply-templates>
      </map>
    </xsl:result-document>
    
    <xsl:message> + [INFO] Bursting topics...</xsl:message>
    <xsl:apply-templates mode="make-topics">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      <xsl:with-param name="outputDir" as="xs:string" tunnel="yes" select="$outputDir" />
    </xsl:apply-templates>
    <xsl:message> + [INFO] Topics burst...</xsl:message>
  </xsl:template>
  
  <!-- ================================
       Mode make-map
       ================================ -->
  
  <xsl:template mode="make-map" match="*[df:class(., 'topic/topic')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="topicFilename" as="xs:string" select="local:constructTopicFilename(.)"/>

   <!-- FIXME: Will need the map path if we want to construct references relative to the map that are not
        in the same directory.
     -->
   <topicref href="{$topicFilename}">
     <xsl:apply-templates mode="#current" select="*[df:class(., 'topic/topic')]"/>
   </topicref>
    
  </xsl:template>
  
  <xsl:template mode="make-map" match="text() | processing-instruction() | comment()">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
  </xsl:template>
  
  <!-- ================================
       Mode make-topics
       ================================ -->
  
  <xsl:template mode="make-topics" match="*[df:class(., 'topic/topic')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="topicFormat" as="xs:string" select="name(.)"/>

    <xsl:variable name="topicUri" as="xs:string"
      select="local:getTopicResultUri($outdir, .)"
    />
    
    <xsl:message> + [INFO] Generating topic "<xsl:value-of select="$topicUri"/></xsl:message>
    <xsl:result-document href="{$topicUri}" format="{$topicFormat}">
      <xsl:apply-templates select="." mode="copy-topic">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        <xsl:with-param name="resultUri" as="xs:string" tunnel="yes" select="$topicUri"/>
      </xsl:apply-templates>
    </xsl:result-document>
    
    <xsl:apply-templates mode="#current" select="*[df:class(., 'topic/topic')]"/>
    
  </xsl:template>
  
  
  
  <!-- ================================
       Mode copy-topic
       ================================ -->
  
  <xsl:template mode="copy-topic" match="*[df:class(., 'topic/topic')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates mode="#current"
        select="@*, node() except (*[df:class(., 'topic/topic')])"
      />
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="copy-topic"
      match="*[df:class(., 'topic/xref')]
              [@scope = ('local') or not(@scope)]
              [@format = 'dita' or not(@format)]
              [@href]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <!-- Result URI for the topic that contains this element. -->
    <xsl:param name="resultUri" as="xs:string" tunnel="yes"/>
    
    <!-- Rewrite pointers to topics -->
    <xsl:variable name="href" as="xs:string" select="@href"/>
    <xsl:variable name="fragID" as="xs:string?" select="relpath:getFragmentId($href)"/>
    <xsl:variable name="resourcePart" as="xs:string" select="relpath:getResourcePartOfUri($href)"/>
    <xsl:variable name="thisTopicID" select="string(ancestor::*[df:class(., 'topic/topic')][1]/@id)"/>/>
    
    <!-- For the reference there are three possible cases:
      
         1. The target is in the same topic.
         2. The target is in a different topic within the same XML document. In this 
            case there should not be a resource part for the URI but there could be.
         3. The target is a different topic in a different XML document.
         
         For cases 1 and 3 we don't have to do anything because in case 1 there's
         no change to location of the target relative to the reference and in case 3
         we're not modifying the location of the target topic (because it's not part
         of this burst activity as far as we know).
         
         for case (2) we have to determine the new result URI of the target topic
         and use that as the basis for a new resource part of the URI. The fragment
         ID does not change, although we have the option of omitting the fragment ID
         when the resulting topic will be the root of it's chunk. (Not doing that for now).
      -->
    
    <xsl:variable name="hrefAtt" as="attribute(href)">      
      <xsl:choose>
        <xsl:when test="not($fragID) or 
                        tokenize($fragID, '/')[1] = ('.', $thisTopicID)">
          <!-- Target is same topic, no change -->
          <xsl:sequence select="@href"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- Try to rewrite the pointer -->
          <xsl:variable name="targetElement" as="node()*" 
            select="df:resolveTopicElementRef(., $href)"
          />
          <xsl:variable name="targetTopic" as="element()?">
            <xsl:choose>
              <xsl:when test="not($targetElement)">
                <xsl:message> - [WARN] In topic <xsl:value-of select="ancestor::*[df:class(., 'topic/topic')][1]/@id"/>:</xsl:message>
                <xsl:message> - [WARN]   Failed to resolve @href "<xsl:value-of select="$href"/>" to an element. Not rewriting element.</xsl:message>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="$targetElement/ancestor-or-self::*[df:class(., 'topic/topic')][1]"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$targetTopic">
              <xsl:variable name="targetTopicUri" as="xs:string" select="local:getTopicResultUri($outdir, $targetTopic)"/>
              <xsl:variable name="relativeUri" as="xs:string"
                select="relpath:getRelativePath(relpath:getParent($resultUri), $targetTopicUri)"
              />
              <!-- FIXME: May need to encode the URI. -->
              <xsl:variable name="targetHref" as="xs:string"
                select="concat($relativeUri, '#', $fragID)"
              />
              <xsl:attribute name="href" select="$targetHref"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="@href"/>
            </xsl:otherwise>
          </xsl:choose>          
        </xsl:otherwise>
      </xsl:choose>    
    </xsl:variable>
    
    <xsl:copy copy-namespaces="no">
      <xsl:sequence select="$hrefAtt"/>
      <xsl:apply-templates select="@* except (@href), node()" mode="#current">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="copy-topic" match="*" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates mode="#current"
        select="@*, node()"
      />
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@class | @domains | @ditaarch:DITAArchVersion" mode="copy-topic">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
  </xsl:template>
  
  <xsl:template match="@*" priority="-1" mode="copy-topic">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:sequence select="."/>
  </xsl:template>
  
  <xsl:template mode="copy-topic" match="text() | processing-instruction() | comment()">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
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
      select="if ($topicElem/ancestor::*[df:class(., 'topic/topic')] | $topicElem/parent::dita) 
      then concat($filenameBase, '-', $topicElem/@id, '.dita')
      else concat($filenameBase, '.dita')" 
      as="xs:string"/>
    <xsl:sequence select="$result"/>
  </xsl:function>
  
  <xsl:function name="local:getTopicResultUri" as="xs:string">
    <xsl:param name="outdir" as="xs:string"/>
    <xsl:param name="topic" as="element()"/>
    
    <xsl:variable name="topicFilename" as="xs:string" select="local:constructTopicFilename($topic)"/>
    <xsl:variable name="result" select="relpath:newFile($outdir, $topicFilename)"/>
    <xsl:sequence select="$result"/>
  </xsl:function>
</xsl:stylesheet>