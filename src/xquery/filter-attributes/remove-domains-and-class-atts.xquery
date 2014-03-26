(:==============================================================
  XQuery update script to remove
  @domains and @class attributes
  from DITA documents.
  
  To set up an Oxygen transform:
  
  1. Open the "Create transformation scenario" dialog and 
     select "New XQuery tranform"
  
  2. Set the XML URL to "${currentFileURL}" 
  
  3. Set the XQuery URL to this transform
  
  4. Select Saxon EE as the Transformer.
  
  5. Click the little gear icon to bring up the Saxon options
and make sure the "Use linked tree model" option is checked. This is 
required for Saxon to do XQuery updates

  Author: W. Eliot Kimber, ekimber@contrext.com
  
  May be used without restriction.
  
  ============================================================== :)
  
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
