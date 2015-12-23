(: Sample Update XQuery that adds paragraph IDs to 
   pargraphs within a DITA topic.
 :)
 
 (: Finds all paragraphs without @id attributes within the body or
    abstract of a topic and adds IDs to them.
  :)
  
 
    
 declare updating function local:addParaIDs($topic as element()) {
    let $pTagnames := ('p')
    
    let $paras := $topic/*[name(.) = $pTagnames][contains(@class, ' topic/abstract ') or 
                           contains(@class, ' topic/body ')]//*[contains(@class, ' topic/p ')][not(@id)]
    
    for $para in $paras count $i
        return insert node attribute id { concat('p-', format-number($i, '00')) } into $para
   
 
 };
 
 let $doc := doc(document-uri(.))

return local:addParaIDs($doc/*)
