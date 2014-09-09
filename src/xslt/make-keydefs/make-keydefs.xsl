<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:local="http://local-functions"
  xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
  exclude-result-prefixes="xs xd relpath local df ditaarch"
  version="2.0">

  <xsl:import href="../org.dita-community.common.xslt/xsl/dita-support-lib.xsl"/>
  <xsl:import href="../org.dita-community.common.xslt/xsl/relpath_util.xsl"/>

  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Sep 24, 2013</xd:p>
      <xd:p><xd:b>Author:</xd:b> ekimber</xd:p>
      <xd:p>Generates a new copy of the input map with all key-defining, non-resource-only
      topicrefs converted to key references to separate key definitions. New key definitions
      are organized into separate submaps.</xd:p>
      <xd:p>Produces a copy of the input maps with the keydefs generated and any key-defining
      topicrefs reworked. The @href values are not changed in the result, meaning that they
      won't resolve until the copy is used to replace the original maps (or the other files
      are moved to the same location relative to the copy as they are to the original).</xd:p>
    </xd:desc>
  </xd:doc>
    
  <xsl:param name="outputPath" as="xs:string"/>
  <xsl:param name="rootmap-doctype-publicid" as="xs:string"
    select="'-//OASIS//DTD DITA Map//EN'"
  />
  <xsl:param name="submap-doctype-publicid" as="xs:string"
    select="'-//OASIS//DTD DITA Map//EN'"
  />
  
  <xsl:output name="map" 
    doctype-public="-//OASIS//DTD DITA Map//EN" 
    doctype-system="map.dtd"
    indent="yes"
  />
  
  <xsl:template match="/">
    
    <!-- Get the set of documents to process by walking the
         the map tree.
         
      -->

    <xsl:variable name="docsToProcess" as="document-node()*">
      <xsl:sequence select="."/><!-- Root map document -->
      <xsl:apply-templates mode="gatherDocsToProcess"/>
    </xsl:variable>

    <xsl:if test="false()">
      <xsl:message> + [DEBUG] Docs to process:</xsl:message>
        <xsl:for-each select="$docsToProcess">
          <xsl:message> + [DEBUG]  - <xsl:sequence select="document-uri(.)"/></xsl:message>
        </xsl:for-each>
    </xsl:if>    
    <!-- Match the root map. -->
    <xsl:variable name="resultUrl" as="xs:string"
        select="local:getResultUrl(string(document-uri(.)))"
    />
    
    <!-- Now process each document to generate the result document: -->
    
    <xsl:message> + [INFO] ### ==============================</xsl:message>
    <xsl:message> + [INFO] ### Generating result documents...</xsl:message>
    <xsl:message> + [INFO] ### ==============================</xsl:message>
    
    <xsl:apply-templates select="$docsToProcess" mode="makeResultDocs">
      <xsl:with-param name="rootMapUrl" as="xs:string" tunnel="yes"
        select="string(document-uri(.))"
      />
    </xsl:apply-templates>
    
  </xsl:template>

  <!-- =========================================
       Gather Docs to Process Mode
       ========================================= -->
  
  <xsl:template mode="gatherDocsToProcess" match="*[df:class(., 'map/map')]">
    <!-- NOTE: We only care about direct references to documents, so keyref
         is not relevant.
      -->
    <xsl:apply-templates select=".//*[df:class(., 'map/topicref')][@href]" mode="#current"/>
  </xsl:template>
  
  <xsl:template mode="gatherDocsToProcess" match="*[df:class(., 'map/topicref')]">    
    <xsl:variable name="targetDoc" as="document-node()"
      select="root(df:resolveTopicRef(.))"
    />
    <!-- For this process we only care about maps, not topics. -->
    <xsl:if test="$targetDoc/*[df:class(., 'map/map')]">
      <xsl:message> + [INFO] Adding <xsl:sequence select="document-uri($targetDoc)"/> to docs to process</xsl:message>
      <xsl:sequence select="$targetDoc"/>
      <xsl:apply-templates mode="#current" select="$targetDoc/*"/>
    </xsl:if>
  </xsl:template>
  
  <!-- =========================================
       Result copying (default mode)
       ========================================= -->
  
  <xsl:template mode="makeResultDocs" match="/">
    <xsl:param name="rootMapUrl" as="xs:string" tunnel="yes"/>
    

    <xsl:variable name="inUrl" as="xs:string"
      select="string(document-uri(.))"
    />
    <xsl:variable name="inFilename" as="xs:string"
      select="relpath:getName($inUrl)"
    />
    <xsl:variable name="relPath" as="xs:string"
      select="
      relpath:getRelativePath(
        relpath:getParent(
          relpath:getResourcePartOfUri($rootMapUrl)), 
          $inUrl)"
    />    
    
    <xsl:variable name="resultRelPath" as="xs:string"
      select="relpath:newFile(
            relpath:getParent($relPath), 
            $inFilename)"
    />

    <xsl:variable name="resultUrl" as="xs:string"
      select="
      relpath:newFile(
        $outputPath,
        $resultRelPath 
        )
        "
    />
    <xsl:choose>
      <xsl:when test="*[df:class(., 'map/map')]">
<!--        <xsl:message> + [INFO] Generating result map document "<xsl:sequence select="$resultUrl"/>"</xsl:message>
        <xsl:apply-templates select="*[df:class(., 'map/map')]" mode="makeTitleTopic">
          <xsl:with-param name="mapResultUrl" as="xs:string" tunnel="yes"
            select="$resultUrl"
          />
        </xsl:apply-templates>
-->        <xsl:result-document href="{$resultUrl}"
            doctype-public="{$rootmap-doctype-publicid}"
          >
          <xsl:apply-templates select="node()">
            <xsl:with-param name="mapResultUrl" as="xs:string" tunnel="yes"
              select="$resultUrl"
            />
          </xsl:apply-templates>
        </xsl:result-document>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message> + [WARN] document <xsl:sequence select="document-uri(.)"/> is not a map document.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'map/map')]">
    <xsl:param name="mapResultUrl" as="xs:string" tunnel="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="filenameBase" as="xs:string"
        select="relpath:getNamePart($mapResultUrl)"
      />
      <xsl:if test=".//*[df:class(., 'map/topicref')][@keyref = ''][@keys != ''][@href != ''][@processing-role = 'normal']">
        <!-- This map has key-defining, non-resource-only topicrefs that are not
          already keyrefs. So we'll need to create a submap with keydefs for those topicrefs.
          -->
        <xsl:variable name="submap-filename" as="xs:string"
          select="concat($filenameBase, '-', 'keydefs.ditamap')"
        />
        <mapref href="{$submap-filename}"/><xsl:text>&#x0a;</xsl:text>
        <xsl:apply-templates select="." mode="make-keydef-submap">
          <xsl:with-param name="submap-filename" as="xs:string" select="$submap-filename"/>
        </xsl:apply-templates>        
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'map/map')]" mode="make-keydef-submap">
    <xsl:param name="mapResultUrl" as="xs:string" tunnel="yes"/>
    <xsl:param name="submap-filename" as="xs:string"/>
    <xsl:variable name="submapUri" as="xs:string"
      select="relpath:newFile(relpath:getParent($mapResultUrl), $submap-filename)"
    />
    <xsl:result-document href="{$submapUri}">
      <xsl:apply-templates select="*[df:class(., 'map/topicref')][@keyref = ''][@keys != ''][@href != ''][@processing-role = 'normal']" mode="make-keydef-submap"/>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="*[df:class(., 'map/topicref')]" mode="make-keydef-submap">
    <keydef>
      <xsl:sequence select="./@keys, ./@href"/>
      <xsl:apply-templates select="@format, @type"/>
    </keydef><xsl:text>&#x0a;</xsl:text>
  </xsl:template>
  
  <xsl:template mode="make-keydef-submap" match="node()" priority="-1"/>

  <xsl:template match="*[df:class(., 'map/topicref')][@keyref = ''][@keys != ''][@href != '']
                                                     [@processing-role = 'normal']">
        <!-- Key-defining, non-resource-only topicrefs that is not
          already a keyrefs.
          -->
    <!-- Add keyref to first key in @keys, remove @href, @keys -->
    <xsl:element name="{name(.)}">
      <xsl:apply-templates select="@* except (@href, @keys)"/>
      <xsl:attribute name="keyref" select="tokenize(@keys, ' ')[1]"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="*" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:template match="@class | @domains | @processing-role[string(.) = 'normal']"/><!-- Suppress -->
  
  <!-- @format is defaulted in mapref -->
  <xsl:template match="*[df:class(., 'map-d/mapref')]/@format" priority="20"/>
  
  <xsl:template match="@format[. = 'dita']" priority="20"/><!-- This is the default value. -->
  
  <xsl:template match="@* | node()" priority="-2">
    <xsl:sequence select="."/>
  </xsl:template>
  
  <xsl:function name="local:getResultUrl" as="xs:string">
    <xsl:param name="inUri" as="xs:string"/>
    <xsl:variable name="inFilename" as="xs:string"
      select="relpath:getName($inUri)"
    />
    <xsl:variable name="resultUrl" as="xs:string"
        select="
        relpath:newFile(
          relpath:getResourcePartOfUri($outputPath), 
          $inFilename)"
    />
<!--    <xsl:message> + [DEBUG] local:getResultUrl(): resultUrl="<xsl:sequence select="$resultUrl"/>"</xsl:message>-->
    <xsl:sequence select="$resultUrl"/>
  </xsl:function>
  
</xsl:stylesheet>