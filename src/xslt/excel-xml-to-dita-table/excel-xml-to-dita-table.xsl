<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
  xmlns:o="urn:schemas-microsoft-com:office:office" 
  xmlns:x="urn:schemas-microsoft-com:office:excel"
  xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
  xmlns:spreadsheet="urn:schemas-microsoft-com:office:spreadsheet"
  exclude-result-prefixes="xsl ditaarch o x ss spreadsheet" 
  version="2.0">

  <xsl:output name="dita-concept" method="xml" doctype-public="-//OASIS//DTD DITA Concept//EN"
    doctype-system="technicalContent/dtd/concept.dtd" indent="yes"/>

  <xsl:template match="/">
    <xsl:message> +++ converting Excel XML file to DITA</xsl:message>
    <xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="/spreadsheet:Workbook">

    <xsl:variable name="meta">
      <xsl:sequence select="spreadsheet:DocumentProperties"/>
    </xsl:variable>

    <xsl:apply-templates select="*" mode="excel-table-conversion">
      <xsl:with-param name="meta" select="$meta"/>
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template match="spreadsheet:Worksheet" mode="excel-table-conversion">

    <xsl:variable name="sheetName" select="@ss:Name"/>

    <xsl:result-document format="dita-concept" href="{$sheetName}.dita">
      <concept id="concept_{translate(normalize-space($sheetName),' ','')}">
        <title>
          <xsl:value-of select="$sheetName"/>
        </title>
        <shortdesc/>
        <conbody>

          <xsl:apply-templates select="spreadsheet:Table" mode="excel-table-conversion">
            <xsl:with-param name="sheetName" select="$sheetName" tunnel="yes"/>
          </xsl:apply-templates>
        </conbody>
      </concept>

    </xsl:result-document>


  </xsl:template>

  <xsl:template match="spreadsheet:Table" mode="excel-table-conversion">

    <xsl:param name="sheetName" tunnel="yes"/>
    <xsl:variable name="columnCount" select="@ss:ExpandedColumnCount"/>

    <table frame="all" colsep="1" id="table_{translate(normalize-space($sheetName),' ','')}">
      <title>
        <xsl:value-of select="$sheetName"/>
      </title>
      <tgroup cols="{$columnCount}">
        <!-- colspecs -->
        <xsl:call-template name="colspecs">
          <xsl:with-param name="num" select="0"/>
          <xsl:with-param name="columnCount" select="$columnCount"/>
        </xsl:call-template>
        <thead>
          <xsl:apply-templates select="spreadsheet:Row" mode="table-thead"/>
        </thead>
        <tbody>
          <xsl:apply-templates select="spreadsheet:Row" mode="table-tbody"/>
        </tbody>
      </tgroup>
    </table>
  </xsl:template>

  <xsl:template name="colspecs">
    <xsl:param name="num"/>
    <xsl:param name="columnCount"/>
    <xsl:if test="not($num = $columnCount)">
      <colspec colname="c{$num}" colnum="{$num}" colwidth="1.0*"/>
      <xsl:call-template name="colspecs">
        <xsl:with-param name="num" select="$num + 1"/>
        <xsl:with-param name="columnCount" select="$columnCount"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="spreadsheet:Row[1]" mode="table-thead">
    <row>
      <xsl:apply-templates select="*" mode="default-row-processing"/>
    </row>
  </xsl:template>

  <xsl:template match="spreadsheet:Row" mode="table-thead"/>

  <xsl:template match="spreadsheet:Row[1]" mode="table-tbody"/>

  <xsl:template match="spreadsheet:Row" mode="table-tbody">
    <row>
      <xsl:apply-templates select="*" mode="default-row-processing"/>
    </row>
  </xsl:template>

  <xsl:template match="spreadsheet:Cell" mode="default-row-processing">
    <entry>
      <xsl:apply-templates select="*" mode="#current"/>
    </entry>
  </xsl:template>

  <xsl:template match="spreadsheet:Data" mode="default-row-processing">
    <xsl:value-of select="."/>
  </xsl:template>

</xsl:stylesheet>
