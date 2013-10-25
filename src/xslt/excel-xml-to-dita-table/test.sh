#!/bin/bash          
echo "Converting XMl Excel document to DITA concept"
mkdir "out"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
java net.sf.saxon.Transform -s:$DIR/sample-excel-2004.xml -xsl:$DIR/excel-xml-to-dita-table.xsl -o:$DIR/out/trash.xml
rm $DIR/out/trash.xml