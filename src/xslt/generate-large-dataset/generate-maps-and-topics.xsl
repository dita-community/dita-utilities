<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:exslt-random="http://exslt.org/random"
  exclude-result-prefixes="xs xd relpath exslt-random"
  version="2.0">
  
  <!-- =============================================================
       Transform to generate arbitrary numbers of maps and topics.
       Uses data files to populate the topics with distinguishing
       content, e.g., words randomly selected from the words.xml
       file (a list of about 236,000 English words).
       
       The input to the transform is the template topic. The direct
       output is a single map document that includes each generated
       topic.
       
       Author: W. Eliot Kimber
       May be used without restriction
       ============================================================= -->
  
  <xsl:import href="../org.dita-community.common.xslt/xsl/relpath_util.xsl"/>
  <xsl:param name="start" as="xs:string"
    select="'1'"
  />
  <xsl:param name="count" as="xs:string"
    select="'10000'"
  />
  <xsl:param name="chunkAt" as="xs:string"
    select="'1000'"
  />
  <xsl:param name="random" as="xs:string"
    select="'false'"
  />
  
  <xsl:variable name="startNum" as="xs:integer" select="xs:integer($start)"/>
  <xsl:variable name="numToGenerate" as="xs:integer" select="xs:integer($count)"/>
  <xsl:variable name="chunkSize" as="xs:integer" select="xs:integer($chunkAt)"/>  
  <xsl:variable name="doRandom" as="xs:boolean" 
    select="matches($random, '(yes|true|on|1)', 'i')"
  />

  <xsl:variable name="words" as="document-node()" select="document('data-files/words.xml')"/>
  <xsl:variable name="wordCount" as="xs:integer" select="count($words/*/*)"/>
  
  <xsl:output
    doctype-public="-//OASIS//DTD DITA Map//EN"
    doctype-system="map.dtd"
  />
  <xsl:output
    name="topic"
    doctype-public="-//OASIS//DTD DITA Topic//EN"
    doctype-system="topic.dtd"
  />
  
  <xsl:template match="/">
    <xsl:variable name="baseFilename" as="xs:string"
      select="relpath:getNamePart(document-uri(.))"
    />
    <xsl:variable name="templateDoc" select="." as="document-node()"/>
    <map><title>Generated Topics Map: <xsl:value-of select="current-dateTime()"/></title>
    <xsl:for-each select="$startNum to ($numToGenerate + $startNum)">
      <xsl:variable name="numberFormatted" as="xs:string"
        select="format-number(., '000000000')"
      />
      <xsl:variable name="chunkNumber" as="xs:integer" 
        select="(xs:integer(. div $chunkSize) * $chunkSize)"/>
      <xsl:variable name="chunkName" as="xs:string"
        select="format-number($chunkNumber, '000000000')"
      />
      <xsl:variable name="seed" select="(seconds-from-dateTime(current-dateTime()) + .) * 1000" as="xs:double"/>
<!--      <xsl:message> + [DEBUG] seed="<xsl:value-of select="$seed"/>"</xsl:message>-->
      <xsl:variable name="wordIndex" as="xs:integer"
        select="if ($doRandom) 
        then xs:integer(exslt-random:random-sequence(1, $seed) * $wordCount)
        else ."
        />
<!--      <xsl:message> + [DEBUG] wordIndex="<xsl:value-of select="$wordIndex"/></xsl:message>-->
      <xsl:variable name="docUri" as="xs:string" 
        select="concat($chunkName, '/', $baseFilename, '-', $numberFormatted, '.xml')"/>
      <xsl:message> + [INFO] Generating result document "<xsl:value-of select="$docUri"/></xsl:message>
      <xsl:result-document href="{$docUri}" format="topic"
        >
        <xsl:apply-templates select="$templateDoc/*">
          <xsl:with-param name="num" as="xs:integer" tunnel="yes" select="."/>
          <xsl:with-param name="wordIndex" as="xs:integer" tunnel="yes" select="$wordIndex"/>
        </xsl:apply-templates>
      </xsl:result-document>
      <topicref href="{$docUri}"/>
    </xsl:for-each>
    </map>
  </xsl:template>
  
  <xsl:template match="*[not(*) and contains(., '^')]">
    <xsl:param name="num" as="xs:integer" tunnel="yes"/>    
    <xsl:param name="wordIndex" as="xs:integer" tunnel="yes"/>
<!--    <xsl:message> + [DEBUG] Element with no subelements</xsl:message>-->
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"/>
      <xsl:analyze-string select="." regex="\^(.+)\^">
        <xsl:matching-substring>
          <xsl:variable name="var" select="regex-group(1)" as="xs:string"/>
<!--          <xsl:message> + [DEBUG] var="<xsl:value-of select="$var"/>"</xsl:message>-->
          <xsl:choose>
            <xsl:when test="$var = 'num'">
              <xsl:value-of select="$num"/>
            </xsl:when>
            <xsl:when test="$var = 'term'">
              <xsl:sequence select="$words/*/*[$wordIndex]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:sequence select="."/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@domains | @class"/>
  
  <xsl:template match="*" priority="-1">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@* | text() | processing-instruction()" priority="-1">
    <xsl:sequence select="."/>
  </xsl:template>
</xsl:stylesheet>