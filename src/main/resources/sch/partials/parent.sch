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
    <sch:let name="satView" value="$satDoc/a:model/a:views/a:diagrams/a:view[a:name = 'Architecture Principles viewpoint']"/>
    <sch:let name="satPrinciples" value="$satDoc/a:model/a:elements/a:element[
      let $elementIdentifier := @identifier return (
         $satView//a:node[@elementRef = $elementIdentifier]
         and starts-with(./a:name, '&lt;&lt;ELAP:Architecture Principle&gt;&gt;')
      )
    ]"/>

    <xsl:function name="local:inElementSet" as="xs:boolean">
        <xsl:param name="elementIdentifier"/>
        <xsl:param name="elementSet"/>
        <xsl:sequence select="exists($elementSet[@identifier = $elementIdentifier])"/>
    </xsl:function>

    <xsl:function name="local:hasStereotype" as="xs:boolean">
        <xsl:param name="element"/>
        <xsl:param name="stereotype"/>
        <xsl:sequence select="starts-with($element/a:name, concat('&lt;&lt;', $stereotype,'&gt;&gt;'))"/>
    </xsl:function>

    <xsl:function name="local:isRealisedByInteroperabilitySpecification" as="xs:boolean">
        <xsl:param name="element"/>
        <xsl:variable name="elementIdentifier" select="$element/@identifier"/>
        <xsl:variable name="ancestorsOrSelf" select="local:findAncestorElements($element, $root/..)"/>
        <xsl:variable name="otherIdentifiers" select="
            $root/a:model/a:relationships/a:relationship[@xsi:type = 'Realization' and (
                let $target := @target return (
                    exists($ancestorsOrSelf[@identifier = $target])
                )
            )]/@source
        "/>
        <xsl:variable name="foundElements" select="
            $root/a:model/a:elements/a:element[contains-token($otherIdentifiers, @identifier)]
        "/>
        <xsl:variable name="result" select="
            exists($foundElements[
                exists(local:findAncestorElements(., $root/..)[local:hasStereotype(., 'Interoperability Specification')])
                or exists(local:findChildElements(., $root/..)[local:hasStereotype(., 'Interoperability Specification')])
            ])
        "/>
<!--        <xsl:message>isRealisedByInteroperabilitySpecification [<xsl:value-of select="$element/a:name"/>] [<xsl:value-of select="$result"/>]</xsl:message>-->
        <xsl:sequence select="$result"/>
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
        <xsl:sequence select="exists($satPrinciples[a:name = $element/a:name])"/>
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