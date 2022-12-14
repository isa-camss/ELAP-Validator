<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron">
   <sch:pattern id="SATSpecific">
      <sch:rule context="/a:model/a:elements/a:element[local:isArchitecturePrinciple(.)]">
         <!--
         Influence principle: In SATs, APs MUST be influencing ABBs through ArchiMate  “groupings” (following the EIRA Ontology viewpoint)
         -->
         <sch:assert id="ELAP-005" flag="fatal" test="local:influencesGrouping(.) or local:lackOfPrincipleIsExplained(.)">[ELAP-005] Architecture principle '<sch:value-of select="./a:name"/>' must be modelled as influencing one or more elements (modelled within an ArchiMate 'Grouping' element).</sch:assert>
      </sch:rule>
   </sch:pattern>
</sch:schema>
