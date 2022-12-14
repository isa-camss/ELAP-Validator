<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron">
   <sch:pattern id="SolutionSpecific">
      <sch:rule context="/a:model/a:elements/a:element[local:isArchitecturePrinciple(.)]">
         <!-- Realization principle: In solutions, APs MUST be linked to Interoperability Specifications through a realisation relation -->
         <sch:assert id="ELAP-003" flag="fatal" test="local:isRealisedByInteroperabilitySpecification(.) or local:lackOfPrincipleIsExplained(.)">[ELAP-003] Architecture principle '<sch:value-of select="./a:name"/>' must be realised by an Interoperability Specification.</sch:assert>
      </sch:rule>
   </sch:pattern>
</sch:schema>
