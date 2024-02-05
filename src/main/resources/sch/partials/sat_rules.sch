<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron">
   <sch:pattern id="SATSpecific">
         <sch:rule context="/a:model/a:elements/a:element[local:isArchitecturePrinciple(.)]">
         <!--
            Salient Alignment Principle: APs MUST be related to an ABB (following ELAP 1.0.0).
            -->
         <sch:assert id="ELAP-004" flag="warning" test="local:findAbbRelatedToPrinciple(.)">[ELAP-004] Architecture principle '<sch:value-of select="./a:name"/>' must be modelled and related to the correct ABB. Any of the following ABBs can be related to this principle: <sch:value-of select="local:abbFromPrinciple(.)"/>.</sch:assert>
      </sch:rule>
   </sch:pattern>
</sch:schema>
