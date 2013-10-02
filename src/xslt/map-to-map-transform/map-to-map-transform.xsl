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

    <xsl:import href="../net.sourceforge.dita4publishers.common.xslt/xsl/lib/relpath_util.xsl"/>
    <xsl:import href="../net.sourceforge.dita4publishers.common.xslt/xsl/lib/dita-support-lib.xsl"/>

  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Sep 24, 2013</xd:p>
      <xd:p><xd:b>Author:</xd:b> ekimber</xd:p>
      <xd:p>Transform to rename maps to make all filenames unique and add title-only topics
      for submap titles.</xd:p>
    </xd:desc>
  </xd:doc>
  

  
  <xsl:param name="outputPath" as="xs:string"/>
  <xsl:param name="namePrefix" as="xs:string"/>
  
  <xsl:output name="map" 
    doctype-public="-//OASIS//DTD DITA Map//EN" 
    doctype-system="map.dtd"
    indent="yes"
  />
  <xsl:output name="topic" 
    doctype-public="-//OASIS//DTD DITA Topic//EN" 
    doctype-system="topic.dtd"
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
    <xsl:message> + [INFO] Adding <xsl:sequence select="document-uri($targetDoc)"/> to docs to process</xsl:message>
    <xsl:sequence select="$targetDoc"/>
    <xsl:if test="$targetDoc/*[df:class(., 'map/map')]">
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
    <xsl:variable name="newName" as="xs:string"
       select="concat($namePrefix, $inFilename)"
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
            $newName)"
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
          format="map"
          >
          <xsl:apply-templates select="node()">
            <xsl:with-param name="mapResultUrl" as="xs:string" tunnel="yes"
              select="$resultUrl"
            />
          </xsl:apply-templates>
        </xsl:result-document>
      </xsl:when>
      <xsl:when test="*[df:class(., 'topic/topic')]">
        <xsl:message> + [INFO] Generating result topic document "<xsl:sequence select="$resultUrl"/>"</xsl:message>
        <xsl:result-document href="{$resultUrl}"
          format="topic"
          >
          <xsl:apply-templates select="node()"/>
          
        </xsl:result-document>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message> + [WARN] document <xsl:sequence select="document-uri(.)"/> is not a map or topic document.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'map/map')]" mode="makeTitleTopic">
    <xsl:apply-templates mode="#current" select="*[df:class(., 'topic/title')]"/>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/title')]" mode="makeTitleTopic">
    <xsl:param name="mapResultUrl" as="xs:string" tunnel="yes"/>
    <xsl:variable name="filenameBase" as="xs:string"
      select="relpath:getNamePart($mapResultUrl)"
    />
    <xsl:variable name="topicFilename" as="xs:string"
      select="concat($filenameBase, '.dita')"
    />
    <xsl:variable name="resultUrl" as="xs:string"
      select="relpath:newFile(relpath:getParent($mapResultUrl), $topicFilename)"
    />
    <xsl:result-document href="{$resultUrl}" format="topic">
      <topic id="{$filenameBase}">
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="@*,node()"/>
        </xsl:copy>
      </topic>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'map/map')]">
    <xsl:param name="mapResultUrl" as="xs:string" tunnel="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="filenameBase" as="xs:string"
        select="relpath:getNamePart($mapResultUrl)"
      />
      <xsl:variable name="topicFilename" as="xs:string"
        select="concat($filenameBase, '.dita')"
      />
      <xsl:apply-templates/>
      <!-- Handle the title and anything preceding it (e.g., PIs, comments): -->
<!--      <xsl:apply-templates 
        select="node()[following-sibling::*[df:class(., 'topic/title')]] | 
                *[df:class(., 'topic/title')]"
      />
-->      <!-- Now Generate a reference to the title-only topic for the map and
           inside it anything that isn't the title or reltable-->
<!--      <topicref href="{$topicFilename}">
        <xsl:apply-templates select="node() except (*[df:class(., 'topic/title')], *[df:class(., 'map/reltable')])"/>        
      </topicref>
-->      <!-- NOTE: This won't preserve order of comments and reltables. -->
<!--      <xsl:apply-templates select="*[df:class(., 'map/reltable')]"/>        -->
    </xsl:copy>
  </xsl:template>
  
  
  
  <xsl:template match="*" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@class | @domains"/><!-- Suppress -->
  
  
  <xsl:template match="@href">
    <!-- Rewrite the value to add the name prefix -->
    <xsl:variable name="inFilename" as="xs:string"
      select="relpath:getName(.)"
    />
    <xsl:variable name="newName" as="xs:string"
       select="concat($namePrefix, $inFilename)"
    />
    <xsl:variable name="parentPart" as="xs:string"
      select="relpath:getParent(.)"
    />
    <xsl:variable name="newHref" as="xs:string"
      select="relpath:newFile($parentPart, $newName)"
    />
    <xsl:attribute name="{name(.)}" select="$newHref"/>
  </xsl:template>
  
  <xsl:template match="@* | node()" priority="-2">
    <xsl:sequence select="."/>
  </xsl:template>
  
  <xsl:function name="local:getResultUrl" as="xs:string">
    <xsl:param name="inUri" as="xs:string"/>
    <xsl:variable name="inFilename" as="xs:string"
      select="relpath:getName($inUri)"
    />
    <xsl:variable name="newName" as="xs:string"
       select="concat($namePrefix, $inFilename)"
    />
    <xsl:variable name="resultUrl" as="xs:string"
        select="
        relpath:newFile(
          relpath:getResourcePartOfUri($outputPath), 
          $newName)"
    />
<!--    <xsl:message> + [DEBUG] local:getResultUrl(): resultUrl="<xsl:sequence select="$resultUrl"/>"</xsl:message>-->
    <xsl:sequence select="$resultUrl"/>
  </xsl:function>
  
</xsl:stylesheet>