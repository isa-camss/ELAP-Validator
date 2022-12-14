<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron">
   <sch:pattern id="Common">
      <sch:rule context="/a:model/a:elements/a:element[local:isArchitecturePrinciple(.)]">
         <!-- Archi notation compliance principle: APs SHOULD be modelled as an ArchiMate class ‘principle’ -->
         <sch:assert id="ELAP-002" flag="warning" test="@xsi:type = 'Principle'">[ELAP-002] Element '<sch:value-of select="./a:name"/>' must be defined as an ArchiMate 'Principle' (actual is '<sch:value-of select="./@xsi:type"/>').</sch:assert>
         <!--
            No-orphan elements principle: APs MUST be related to at least one other element.
            Comply or explain principle: If APs are not modelled, they  MUST be commented in the Architecture view together with the reasons why are not included (as ArchiMate ‘note’)
         -->
         <sch:assert id="ELAP-004" flag="fatal" test="exists(local:findNonHierarchicalLinkedElements(.)) or local:lackOfPrincipleIsExplained(.)">[ELAP-004] '<sch:value-of select="./a:name"/>' must be linked to at least one element in the model.</sch:assert>
      </sch:rule>
   </sch:pattern>
</sch:schema>
