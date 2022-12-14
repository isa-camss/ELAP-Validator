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
        <xsl:variable name="ancestors" select="local:findAncestorElements($element, $root/..)"/>
        <xsl:sequence select="exists($ancestors[
            let $elementIdentifier := @identifier return (
                $root/a:model/a:relationships/a:relationship[
                    @target = $elementIdentifier
                    and @xsi:type = 'Realization'
                    and (let $otherElementIdentifier := @source return (
                        $root/a:model/a:elements/a:element[@identifier = $otherElementIdentifier and (
                            exists(local:findAncestorElements(., $root/..)[local:hasStereotype(., 'Interoperability Specification')])
                            or exists(local:findChildElements(., $root/..)[local:hasStereotype(., 'Interoperability Specification')])
                        )]
                    ))
                ]
            )
        ])"/>
    </xsl:function>

    <xsl:function name="local:findAllRelatedElements" as="element()*">
        <xsl:param name="element"/>
        <xsl:param name="checkedElements"/>
        <xsl:variable name="elementIdentifier" select="$element/@identifier"/>
        <xsl:variable name="foundElements" select="
     $root/a:model/a:elements/a:element[
        not(local:inElementSet(@identifier, $checkedElements)) and (
           let $otherElementIdentifier := @identifier return (
              $root/a:model/a:relationships/a:relationship[
                 ($elementIdentifier = @target and $otherElementIdentifier = @source)
                 or ($elementIdentifier = @source and $otherElementIdentifier = @target)
              ]
           )
        )
     ]
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
        <xsl:variable name="foundElements" select="
     $root/a:model/a:elements/a:element[
        not(local:inElementSet(@identifier, $checkedElements)) and (
           let $otherElementIdentifier := @identifier return (
              $root/a:model/a:relationships/a:relationship[
                 ((@xsi:type = 'Realization') and ($elementIdentifier = @source and $otherElementIdentifier = @target))
                    or ((@xsi:type = 'Specialization') and ($elementIdentifier = @source and $otherElementIdentifier = @target))
                    or ((@xsi:type = 'Aggregation') and ($elementIdentifier = @target and $otherElementIdentifier = @source))
                    or ((@xsi:type = 'Composition') and ($elementIdentifier = @target and $otherElementIdentifier = @source))
              ]
           )
        )
     ]
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
        <xsl:variable name="foundElements" select="
     $root/a:model/a:elements/a:element[
        not(local:inElementSet(@identifier, $checkedElements)) and (
           let $otherElementIdentifier := @identifier return (
              $root/a:model/a:relationships/a:relationship[
                 ((@xsi:type = 'Realization') and ($elementIdentifier = @target and $otherElementIdentifier = @source))
                    or ((@xsi:type = 'Specialization') and ($elementIdentifier = @target and $otherElementIdentifier = @source))
                    or ((@xsi:type = 'Aggregation') and ($elementIdentifier = @source and $otherElementIdentifier = @target))
                    or ((@xsi:type = 'Composition') and ($elementIdentifier = @source and $otherElementIdentifier = @target))
              ]
           )
        )
     ]
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
        <xsl:sequence select="exists(
     $ancestorsOrSelf[
        let $elementIdentifier := @identifier return (
           $root/a:model/a:views/a:diagrams/a:view[
              let $view := . return (
                 $view/a:node[
                    @elementRef = $elementIdentifier and (
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
     ]
  )"/>
    </xsl:function>

    <xsl:function name="local:influencesGrouping" as="xs:boolean">
        <xsl:param name="element"/>
        <xsl:variable name="ancestorsOrSelf" select="local:findAncestorElements($element, $root/..)"/>
        <xsl:sequence select="exists(
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
    </xsl:function>

</sch:schema>