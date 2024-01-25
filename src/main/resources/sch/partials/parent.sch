<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
      xmlns:a="http://www.opengroup.org/xsd/archimate/3.0/"
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:local="local">
    <sch:title>Architecture Principle integrity validation</sch:title>
    <sch:ns prefix="a" uri="http://www.opengroup.org/xsd/archimate/3.0/"/>
    <sch:ns prefix="xsi" uri="http://www.w3.org/2001/XMLSchema-instance"/>
    <sch:ns prefix="local" uri="local"/>

    <sch:let name="root" value="/"/>
    <sch:let name="satDoc" value="document('ELAP_sat.xml')"/>
    <sch:let name="satView" value="$satDoc/a:model/a:views/a:diagrams/a:view[a:name = 'ELAP Architecture Principles']"/>
    <sch:let name="satPrinciples" value="$satDoc/a:model/a:elements/a:element[string(./a:properties/a:property[@propertyDefinitionRef = string($satDoc/a:model/a:propertyDefinitions/a:propertyDefinition[a:name = 'dct:type']/@identifier)]/a:value) = 'eira:ArchitecturePrinciple']"/>
    <sch:let name="inputPrinciples" value="$root/a:model/a:elements/a:element[string(./a:properties/a:property[@propertyDefinitionRef = string($satDoc/a:model/a:propertyDefinitions/a:propertyDefinition[a:name = 'dct:type']/@identifier)]/a:value) = 'eira:ArchitecturePrinciple']"/>
    <sch:let name="inputAbb" value="$root/a:model/a:elements/a:element[
       a:properties/a:property[
                    @propertyDefinitionRef = $root/a:model/a:propertyDefinitions/a:propertyDefinition[a:name = 'eira:concept']/@identifier
                ]/a:value = 'eira:ArchitectureBuildingBlock']"/>
    <sch:let name="inputSbb" value="$root/a:model/a:elements/a:element[
       a:properties/a:property[
       				@propertyDefinitionRef = $root/a:model/a:propertyDefinitions/a:propertyDefinition[a:name = 'eira:concept']/@identifier
       			]/a:value = 'eira:SolutionBuildingBlock']"/>
    <sch:let name="satAbb" value="$satDoc/a:model/a:elements/a:element[
       a:properties/a:property[
                    @propertyDefinitionRef = $root/a:model/a:propertyDefinitions/a:propertyDefinition[a:name = 'eira:concept']/@identifier
                ]/a:value = 'eira:ArchitectureBuildingBlock']"/>

    <xsl:function name="local:inElementSet" as="xs:boolean">
        <xsl:param name="elementIdentifier"/>
        <xsl:param name="elementSet"/>
        <xsl:sequence select="exists($elementSet[@identifier = $elementIdentifier])"/>
    </xsl:function>

    <xsl:function name="local:findAllRelatedElements" as="element()*">
        <xsl:param name="element"/>
        <xsl:param name="checkedElements"/>
        <xsl:variable name="elementIdentifier" select="$element/@identifier"/>
        <xsl:variable name="checkedElementsWithCurrent" as="element()*">
            <xsl:if test="exists($checkedElements)">
                <xsl:for-each select="$checkedElements">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsl:if>
            <xsl:copy-of select="$element"/>
        </xsl:variable>
        <xsl:variable name="relatedIdentifiers" select="
            $root/a:model/a:relationships/a:relationship[$elementIdentifier = @source and not(local:inElementSet(@target, $checkedElements))]/@target
            |
            $root/a:model/a:relationships/a:relationship[$elementIdentifier = @target and not(local:inElementSet(@source, $checkedElements))]/@source
        "/>
        <xsl:variable name="foundElements" select="$root/a:model/a:elements/a:element[contains-token($relatedIdentifiers, @identifier)]"/>
        <xsl:variable name="result" as="element()*">
            <xsl:if test="exists($foundElements)">
                <xsl:for-each select="$foundElements">
                    <xsl:copy-of select="local:findAllRelatedElements(., $checkedElementsWithCurrent)"/>
                </xsl:for-each>
            </xsl:if>
            <xsl:copy-of select="$element"/>
        </xsl:variable>
        <xsl:copy-of select="$result"/>
    </xsl:function>

    <xsl:function name="local:findAncestorElements" as="element()*">
        <xsl:param name="element"/>
        <xsl:param name="checkedElements"/>
        <xsl:variable name="elementIdentifier" select="$element/@identifier"/>
        <xsl:variable name="ancestorIdentifiers" select="
            $root/a:model/a:relationships/a:relationship[$elementIdentifier = @source and (@xsi:type = 'Realization' or @xsi:type = 'Specialization')]/@target
            |
            $root/a:model/a:relationships/a:relationship[$elementIdentifier = @target and (@xsi:type = 'Aggregation' or @xsi:type = 'Composition')]/@source
        "/>
        <xsl:variable name="foundElements" select="
            $root/a:model/a:elements/a:element[contains-token($ancestorIdentifiers, @identifier)]
        "/>
        <xsl:variable name="checkedElementsWithCurrent" as="element()*">
            <xsl:if test="exists($checkedElements)">
                <xsl:for-each select="$checkedElements">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsl:if>
            <xsl:copy-of select="$element"/>
        </xsl:variable>
        <xsl:variable name="result" as="element()*">
            <xsl:if test="exists($foundElements)">
                <xsl:for-each select="$foundElements">
                    <xsl:copy-of select="local:findAncestorElements(., $checkedElementsWithCurrent)"/>
                </xsl:for-each>
            </xsl:if>
            <xsl:copy-of select="$element"/>
        </xsl:variable>
        <xsl:copy-of select="$result"/>
    </xsl:function>

    <xsl:function name="local:findChildElements" as="element()*">
        <xsl:param name="element"/>
        <xsl:param name="checkedElements"/>
        <xsl:variable name="elementIdentifier" select="$element/@identifier"/>
        <xsl:variable name="childIdentifiers" select="
            $root/a:model/a:relationships/a:relationship[$elementIdentifier = @target and (@xsi:type = 'Realization' or @xsi:type = 'Specialization')]/@source
            |
            $root/a:model/a:relationships/a:relationship[$elementIdentifier = @source and (@xsi:type = 'Aggregation' or @xsi:type = 'Composition')]/@target
        "/>
        <xsl:variable name="foundElements" select="
            $root/a:model/a:elements/a:element[contains-token($childIdentifiers, @identifier)]
        "/>
        <xsl:variable name="checkedElementsWithCurrent" as="element()*">
            <xsl:if test="exists($checkedElements)">
                <xsl:for-each select="$checkedElements">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsl:if>
            <xsl:copy-of select="$element"/>
        </xsl:variable>
        <xsl:variable name="result" as="element()*">
            <xsl:if test="exists($foundElements)">
                <xsl:for-each select="$foundElements">
                    <xsl:copy-of select="local:findChildElements(., $checkedElementsWithCurrent)"/>
                </xsl:for-each>
            </xsl:if>
            <xsl:copy-of select="$element"/>
        </xsl:variable>
        <xsl:copy-of select="$result"/>
    </xsl:function>

    <xsl:function name="local:findNonHierarchicalLinkedElements" as="element()*">
        <xsl:param name="element"/>
        <xsl:variable name="result" select="local:findAllRelatedElements($element, $root/..)
  [@identifier != $element/@identifier and @xsi:type != 'Principle' and @xsi:type != 'Grouping']"/>
        <xsl:sequence select="$result"/>
    </xsl:function>

    <xsl:function name="local:isArchitecturePrinciple" as="xs:boolean">
        <xsl:param name="element"/>
        <xsl:sequence select="exists($element[string(./a:properties/a:property[@propertyDefinitionRef = string($root/a:model/a:propertyDefinitions/a:propertyDefinition[a:name = 'dct:type']/@identifier)]/a:value) = 'eira:ArchitecturePrinciple' and
        a:name!='Architecture Principle'])"/>
    </xsl:function>

    <xsl:function name="local:abbFromPrinciple" as="xs:string*">
        <xsl:param name="element"/>
        <xsl:variable name="abb" select="$satAbb[let $satAbbIdentifier := ./@identifier return(let $principlePURI := $element/a:properties/a:property[
               @propertyDefinitionRef = string($root/a:model/a:propertyDefinitions/a:propertyDefinition[string(a:name) = 'eira:PURI']/@identifier)
               ]/a:value return(let $satPrincipleIdentifier := $satPrinciples[
                     string(a:properties/a:property[
                         @propertyDefinitionRef = string($satDoc/a:model/a:propertyDefinitions/a:propertyDefinition[string(a:name) = 'eira:PURI']/@identifier)
                     ]/a:value) = $principlePURI]/@identifier return(
                          exists($satDoc/a:model/a:relationships/a:relationship[
                              @target = $satAbbIdentifier and @source = $satPrincipleIdentifier
                          ])
                     )
                )
            )]/a:name"/>
        <xsl:sequence select="string-join($abb, ', ')"/>
    </xsl:function>

    <xsl:function name="local:extractAbbRelatedToPrinciple" as="xs:string*">
        <xsl:param name="element"/>
        <xsl:variable name="abb" select="$inputAbb/a:name
        "/>
        <xsl:sequence select="string-join($abb, ', ')"/>
    </xsl:function>

    <xsl:function name="local:extractSbbRelatedToPrinciple" as="xs:string*">
        <xsl:param name="element"/>
        <xsl:variable name="sbb" select="$inputSbb/a:name
        "/>
        <xsl:sequence select="string-join($sbb, ', ')"/>
    </xsl:function>

    <xsl:function name="local:findAbbRelatedToPrinciple" as="xs:boolean">
        <xsl:param name="inputPrinciple"/>
		<xsl:variable name="abbsRelatedToPrinciple" select="$inputAbb[
		    $root/a:model/a:relationships/a:relationship[@source = $inputPrinciple/@identifier]/@target = @identifier]"/>
		<xsl:variable name="equivalentSatPrincipleIdentifier" select="$satPrinciples[
			let $satPrinciplePURI := a:properties/a:property[
				@propertyDefinitionRef = $satDoc/a:model/a:propertyDefinitions/a:propertyDefinition[a:name = 'eira:PURI']/@identifier
			]/a:value return (
				$inputPrinciple/a:properties/a:property[
					@propertyDefinitionRef = $root/a:model/a:propertyDefinitions/a:propertyDefinition[a:name = 'eira:PURI']/@identifier
				]/a:value = $satPrinciplePURI
			)]/@identifier"/>
		<xsl:variable name="result" select="every $abbRelatedToPrinciplePURI in $abbsRelatedToPrinciple/a:properties/a:property[
			@propertyDefinitionRef = $root/a:model/a:propertyDefinitions/a:propertyDefinition[a:name = 'eira:PURI']/@identifier
		]/a:value satisfies(
                let $equivalentSatAbbIdentifier := $satAbb[
                    a:properties/a:property[
                        @propertyDefinitionRef = $satDoc/a:model/a:propertyDefinitions/a:propertyDefinition[a:name = 'eira:PURI']/@identifier
                    ]/a:value = $abbRelatedToPrinciplePURI
                ]/@identifier return (
                    exists(
                        $satDoc/a:model/a:relationships/a:relationship[@target = $equivalentSatAbbIdentifier and @source = $equivalentSatPrincipleIdentifier]
                    ) or
                    not(exists($abbsRelatedToPrinciple))
                    )
		)"/>
    	<xsl:sequence select="$result"/>
    </xsl:function>

    <xsl:function name="local:findSbbRelatedToPrinciple" as="xs:boolean">
        <xsl:param name="element"/>
		<xsl:variable name="sbbRelatedToInput" select="$inputSbb[
			$root/a:model/a:relationships/a:relationship[@source = $element/@identifier]/@target = @identifier]"/>
		<xsl:variable name="abbRelatedToSbbTypes" select="$sbbRelatedToInput/a:properties/a:property[
			@propertyDefinitionRef = $root/a:model/a:propertyDefinitions/a:propertyDefinition[a:name = 'eira:ABB']/@identifier
		]"/>
		<xsl:variable name="result" select="every $abbType in $abbRelatedToSbbTypes satisfies(
				exists(
					$satAbb/a:properties/a:property[
						@propertyDefinitionRef = $satDoc/a:model/a:propertyDefinitions/a:propertyDefinition[a:name = 'dct:type']/@identifier and
						a:value = $abbType
					]
				) or
				not(exists($sbbRelatedToInput))
			)"/>
    	<xsl:sequence select="$result"/>
    </xsl:function>

    <xsl:function name="local:lackOfPrincipleIsExplained" as="xs:boolean">
        <xsl:param name="element"/>
        <xsl:variable name="ancestorsOrSelf" select="local:findAncestorElements($element, $root/..)"/>
        <xsl:variable name="result" select="
             exists($ancestorsOrSelf[
                let $elementIdentifier := @identifier return (
                   $root/a:model/a:views/a:diagrams/a:view[
                      let $view := . return (
                         $view/a:node[
                            @elementRef = $elementIdentifier
                            and (
                               let $nodeIdentifier := @identifier return (
                                  $view/a:connection[
                                     ($nodeIdentifier = @source and (
                                        let $otherNodeIdentifier := @target return (
                                           exists($view/a:node[@identifier = $otherNodeIdentifier and @xsi:type = 'Label'])
                                        )
                                     )) or
                                     ($nodeIdentifier = @target and (
                                        let $otherNodeIdentifier := @source return (
                                           exists($view/a:node[@identifier = $otherNodeIdentifier and @xsi:type = 'Label'])
                                        )
                                     ))
                                  ]
                               )
                            )
                         ]
                      )
                   ]
                )
             ])
        "/>
<!--        <xsl:message>lackOfPrincipleIsExplained [<xsl:value-of select="$element/a:name"/>] [<xsl:value-of select="$result"/>]</xsl:message>-->
        <xsl:sequence select="$result"/>
    </xsl:function>

    <xsl:function name="local:influencesGrouping" as="xs:boolean">
        <xsl:param name="element"/>
        <xsl:variable name="ancestorsOrSelf" select="local:findAncestorElements($element, $root/..)"/>
        <xsl:variable name="result" select="exists(
         $ancestorsOrSelf[
            let $elementIdentifier := @identifier return (
               $root/a:model/a:relationships/a:relationship[@source = $elementIdentifier and (
                  let $otherElementIdentifier := @target return (
                     $root/a:model/a:elements/a:element[@identifier = $otherElementIdentifier and @xsi:type = 'Grouping']
                  )
               )]
            )
         ]
      )"/>
        <xsl:sequence select="$result"/>
    </xsl:function>

</sch:schema>