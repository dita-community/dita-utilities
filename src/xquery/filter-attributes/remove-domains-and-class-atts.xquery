(:================================
  XQuery update script to remove
  @domains and @class attributes
  from DITA documents.
  ================================ :)
  
declare namespace dita="http://dita.oasis-open.org/architecture/2005/";

declare updating function local:removeAtts($elem as element()) {
   delete nodes $elem/@*[name(.) = ('domains', 'class')]
};

declare updating function local:updateDoc($e as element()) {

   for $elem in ($e,$e//*)
       return local:removeAtts($elem)
   
};

let $doc := doc(document-uri(.))

return local:updateDoc($doc/*)
