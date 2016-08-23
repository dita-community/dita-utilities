(: XQuery script to report on the keys used an declared in a map.

   NOTE: This script requires a custom collection() that provides
   the set of maps and topics referenced directly or indirectly 
   by the input root map. 
   
   :)

declare function local:getKeyrefs($doc as document-node()) as xs:string* {
for $e in $doc//*[@keyref]
return tokenize($e/@keyref, '/')[1]

};

declare function local:reportKeydef($keydef as element()) as node()* {
    element {name($keydef)} {
        $keydef/@* except ($keydef/@*:ditaarch, $keydef/@class),
        attribute {'mapuri'} { document-uri(root($keydef)) }
    }
};

let $thisDoc := root(.)
let $topicDocs := collection('ditaTopics:/' || document-uri(.))[*[contains(@class, ' topic/topic ')]]
let $mapDocs := ($thisDoc, collection('ditaTopics:/' || document-uri(.))[*[contains(@class, ' map/map ')]])

let $allKeyrefs as xs:string* := 
for $doc in $topicDocs  return local:getKeyrefs($doc)

return
<key-usage-report 
   input-doc="{document-uri($thisDoc)}"
>
  <allreffedkeys>
{
  distinct-values($allKeyrefs)
 }</allreffedkeys>
   <unresolvedkeys>{
   for $key in distinct-values($allKeyrefs)
        return 
        if (exists(
                 for $doc in $mapDocs
                       return 
                             $doc//*[$key = tokenize(./@keys, ' ')])
             )
              then ()
              else '
' || $key
                 }</unresolvedkeys>
  <usedkeydefs>{
  for $key in distinct-values($allKeyrefs)
      return 
         for $doc in $mapDocs             
             return for $keydef as element() in $doc//*[$key = tokenize(./@keys, ' ')]
                               return local:reportKeydef($keydef)
  }</usedkeydefs>
  <keyrefsbytopic>{
    for $doc in $topicDocs order by lower-case(tokenize(document-uri($doc), '/')[last()])
         return
            <topic uri="{string-join(tokenize(document-uri($doc), '/')[position() ge last() -2 ], '/')}"
            >
               <reffedkeys>{
                   distinct-values(local:getKeyrefs($doc))
               }</reffedkeys>
             </topic>
  }</keyrefsbytopic>
  <navigationKeys>{
    for $doc in $mapDocs
          return for $keydef in $doc//*[@keys][@processing-role = ('normal')]
               return for $key in tokenize($keydef/@keys, ' ')
                   return '
' || $key
  }</navigationKeys>
 </key-usage-report>