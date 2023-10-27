<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron">
   <sch:pattern id="Common">
      <sch:rule context="/a:model/a:elements/a:element[local:isArchitecturePrinciple(.)]">
         <!-- Archi notation compliance principle: APs SHOULD be modelled as an ArchiMate class ‘principle’ -->
         <sch:assert id="ELAP-002" flag="warning" test="local:followsCompliancePrinciple(.)">[ELAP-002] Element '<sch:value-of select="./a:name"/>' must be defined as an ArchiMate 'Principle' (actual is '<sch:value-of select="./@xsi:type"/>').</sch:assert>
         <!--
            No-orphan elements principle: APs MUST be related to at least one other element.
            Comply or explain principle: If APs are not modelled, they  MUST be commented in the Architecture view together with the reasons why are not included (as ArchiMate ‘note’ elements).
         -->
         <sch:assert id="ELAP-003" flag="fatal" test="exists(local:findNonHierarchicalLinkedElements(.)) or local:lackOfPrincipleIsExplained(.)">[ELAP-003] '<sch:value-of select="./a:name"/>' must be associated with at least one element in the model, not being a 'principle'. If the principle is not used, associate it to a note (Archi  “note” element).</sch:assert>
         <!-- Specific implementation Solution: In solutions, APs MUST be linked to Interoperability Specifications through a realisation relation
         -->
         <sch:assert id="ELAP-005" flag="fatal" test="local:findSbbRelatedToPrinciple(.)">[ELAP-005] Architecture principle '<sch:value-of select="./a:name"/>' must be modelled and related to the correct SBBs (currently realized by the following ABBs: <sch:value-of select="local:extractSbbRelatedToPrinciple(.)"/>) through the correct ABB(s): <sch:value-of select="local:abbFromPrinciple(.)"/>.</sch:assert>
      </sch:rule>
   </sch:pattern>
</sch:schema>
