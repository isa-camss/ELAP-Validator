<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<xsl:stylesheet xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:a="http://www.opengroup.org/xsd/archimate/3.0/" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:local="local" xmlns:saxon="http://saxon.sf.net/" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
<!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->

<xsl:param name="archiveDirParameter" />
  <xsl:param name="archiveNameParameter" />
  <xsl:param name="fileNameParameter" />
  <xsl:param name="fileDirParameter" />
  <xsl:variable name="document-uri">
    <xsl:value-of select="document-uri(/)" />
  </xsl:variable>

<!--PHASES-->


<!--PROLOG-->
<xsl:output indent="yes" method="xml" omit-xml-declaration="no" standalone="yes" />

<!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->
<xsl:function as="xs:boolean" name="local:inElementSet">
        <xsl:param name="elementIdentifier" />
        <xsl:param name="elementSet" />
        <xsl:sequence select="exists($elementSet[@identifier = $elementIdentifier])" />
    </xsl:function>
  <xsl:function as="xs:boolean" name="local:hasStereotype">
        <xsl:param name="element" />
        <xsl:param name="stereotype" />
        <xsl:sequence select="starts-with($element/a:name, concat('&lt;&lt;', $stereotype,'>>'))" />
    </xsl:function>
  <xsl:function as="xs:boolean" name="local:isRealisedByInteroperabilitySpecification">
        <xsl:param name="element" />
        <xsl:variable name="elementIdentifier" select="$element/@identifier" />
        <xsl:variable name="ancestorsOrSelf" select="local:findAncestorElements($element, $root/..)" />
        <xsl:variable name="otherIdentifiers" select="             $root/a:model/a:relationships/a:relationship[@xsi:type = 'Realization' and (                 let $target := @target return (                     exists($ancestorsOrSelf[@identifier = $target])                 )             )]/@source         " />
        <xsl:variable name="foundElements" select="             $root/a:model/a:elements/a:element[contains-token($otherIdentifiers, @identifier)]         " />
        <xsl:variable name="result" select="             exists($foundElements[                 exists(local:findAncestorElements(., $root/..)[local:hasStereotype(., 'Interoperability Specification')])                 or exists(local:findChildElements(., $root/..)[local:hasStereotype(., 'Interoperability Specification')])             ])         " />

        <xsl:sequence select="$result" />
    </xsl:function>
  <xsl:function as="element()*" name="local:findAllRelatedElements">
        <xsl:param name="element" />
        <xsl:param name="checkedElements" />
        <xsl:variable name="elementIdentifier" select="$element/@identifier" />
        <xsl:variable as="element()*" name="checkedElementsWithCurrent">
            <xsl:if test="exists($checkedElements)">
                <xsl:for-each select="$checkedElements">
                    <xsl:copy-of select="." />
                </xsl:for-each>
            </xsl:if>
            <xsl:copy-of select="$element" />
        </xsl:variable>
        <xsl:variable name="relatedIdentifiers" select="             $root/a:model/a:relationships/a:relationship[$elementIdentifier = @source and not(local:inElementSet(@target, $checkedElements))]/@target             |             $root/a:model/a:relationships/a:relationship[$elementIdentifier = @target and not(local:inElementSet(@source, $checkedElements))]/@source         " />
        <xsl:variable name="foundElements" select="$root/a:model/a:elements/a:element[contains-token($relatedIdentifiers, @identifier)]" />
        <xsl:variable as="element()*" name="result">
            <xsl:if test="exists($foundElements)">
                <xsl:for-each select="$foundElements">
                    <xsl:copy-of select="local:findAllRelatedElements(., $checkedElementsWithCurrent)" />
                </xsl:for-each>
            </xsl:if>
            <xsl:copy-of select="$element" />
        </xsl:variable>
        <xsl:copy-of select="$result" />
    </xsl:function>
  <xsl:function as="element()*" name="local:findAncestorElements">
        <xsl:param name="element" />
        <xsl:param name="checkedElements" />
        <xsl:variable name="elementIdentifier" select="$element/@identifier" />
        <xsl:variable name="ancestorIdentifiers" select="             $root/a:model/a:relationships/a:relationship[$elementIdentifier = @source and (@xsi:type = 'Realization' or @xsi:type = 'Specialization')]/@target             |             $root/a:model/a:relationships/a:relationship[$elementIdentifier = @target and (@xsi:type = 'Aggregation' or @xsi:type = 'Composition')]/@source         " />
        <xsl:variable name="foundElements" select="             $root/a:model/a:elements/a:element[contains-token($ancestorIdentifiers, @identifier)]         " />
        <xsl:variable as="element()*" name="checkedElementsWithCurrent">
            <xsl:if test="exists($checkedElements)">
                <xsl:for-each select="$checkedElements">
                    <xsl:copy-of select="." />
                </xsl:for-each>
            </xsl:if>
            <xsl:copy-of select="$element" />
        </xsl:variable>
        <xsl:variable as="element()*" name="result">
            <xsl:if test="exists($foundElements)">
                <xsl:for-each select="$foundElements">
                    <xsl:copy-of select="local:findAncestorElements(., $checkedElementsWithCurrent)" />
                </xsl:for-each>
            </xsl:if>
            <xsl:copy-of select="$element" />
        </xsl:variable>
        <xsl:copy-of select="$result" />
    </xsl:function>
  <xsl:function as="element()*" name="local:findChildElements">
        <xsl:param name="element" />
        <xsl:param name="checkedElements" />
        <xsl:variable name="elementIdentifier" select="$element/@identifier" />
        <xsl:variable name="childIdentifiers" select="             $root/a:model/a:relationships/a:relationship[$elementIdentifier = @target and (@xsi:type = 'Realization' or @xsi:type = 'Specialization')]/@source             |             $root/a:model/a:relationships/a:relationship[$elementIdentifier = @source and (@xsi:type = 'Aggregation' or @xsi:type = 'Composition')]/@target         " />
        <xsl:variable name="foundElements" select="             $root/a:model/a:elements/a:element[contains-token($childIdentifiers, @identifier)]         " />
        <xsl:variable as="element()*" name="checkedElementsWithCurrent">
            <xsl:if test="exists($checkedElements)">
                <xsl:for-each select="$checkedElements">
                    <xsl:copy-of select="." />
                </xsl:for-each>
            </xsl:if>
            <xsl:copy-of select="$element" />
        </xsl:variable>
        <xsl:variable as="element()*" name="result">
            <xsl:if test="exists($foundElements)">
                <xsl:for-each select="$foundElements">
                    <xsl:copy-of select="local:findChildElements(., $checkedElementsWithCurrent)" />
                </xsl:for-each>
            </xsl:if>
            <xsl:copy-of select="$element" />
        </xsl:variable>
        <xsl:copy-of select="$result" />
    </xsl:function>
  <xsl:function as="element()*" name="local:findNonHierarchicalLinkedElements">
        <xsl:param name="element" />
        <xsl:variable name="result" select="local:findAllRelatedElements($element, $root/..)   [@identifier != $element/@identifier and @xsi:type != 'Principle' and @xsi:type != 'Grouping']" />
        <xsl:sequence select="$result" />
    </xsl:function>
  <xsl:function as="xs:boolean" name="local:isArchitecturePrinciple">
        <xsl:param name="element" />
        <xsl:sequence select="exists($satPrinciples[a:name = $element/a:name])" />
    </xsl:function>
  <xsl:function as="xs:boolean" name="local:lackOfPrincipleIsExplained">
        <xsl:param name="element" />
        <xsl:variable name="ancestorsOrSelf" select="local:findAncestorElements($element, $root/..)" />
        <xsl:variable name="result" select="              exists($ancestorsOrSelf[                 let $elementIdentifier := @identifier return (                    $root/a:model/a:views/a:diagrams/a:view[                       let $view := . return (                          $view/a:node[                             @elementRef = $elementIdentifier                             and (                                let $nodeIdentifier := @identifier return (                                   $view/a:connection[                                      ($nodeIdentifier = @source and (                                         let $otherNodeIdentifier := @target return (                                            exists($view/a:node[@identifier = $otherNodeIdentifier and @xsi:type = 'Label'])                                         )                                      )) or                                      ($nodeIdentifier = @target and (                                         let $otherNodeIdentifier := @source return (                                            exists($view/a:node[@identifier = $otherNodeIdentifier and @xsi:type = 'Label'])                                         )                                      ))                                   ]                                )                             )                          ]                       )                    ]                 )              ])         " />

        <xsl:sequence select="$result" />
    </xsl:function>
  <xsl:function as="xs:boolean" name="local:influencesGrouping">
        <xsl:param name="element" />
        <xsl:variable name="ancestorsOrSelf" select="local:findAncestorElements($element, $root/..)" />
        <xsl:variable name="result" select="exists(          $ancestorsOrSelf[             let $elementIdentifier := @identifier return (                $root/a:model/a:relationships/a:relationship[@source = $elementIdentifier and (                   let $otherElementIdentifier := @target return (                      $root/a:model/a:elements/a:element[@identifier = $otherElementIdentifier and @xsi:type = 'Grouping']                   )                )]             )          ]       )" />
        <xsl:sequence select="$result" />
    </xsl:function>

<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-select-full-path">
    <xsl:apply-templates mode="schematron-get-full-path" select="." />
  </xsl:template>

<!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-get-full-path">
    <xsl:apply-templates mode="schematron-get-full-path" select="parent::*" />
    <xsl:text>/</xsl:text>
    <xsl:choose>
      <xsl:when test="namespace-uri()=''">
        <xsl:value-of select="name()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>*:</xsl:text>
        <xsl:value-of select="local-name()" />
        <xsl:text>[namespace-uri()='</xsl:text>
        <xsl:value-of select="namespace-uri()" />
        <xsl:text>']</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:variable name="preceding" select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])" />
    <xsl:text>[</xsl:text>
    <xsl:value-of select="1+ $preceding" />
    <xsl:text>]</xsl:text>
  </xsl:template>
  <xsl:template match="@*" mode="schematron-get-full-path">
    <xsl:apply-templates mode="schematron-get-full-path" select="parent::*" />
    <xsl:text>/</xsl:text>
    <xsl:choose>
      <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()" />
</xsl:when>
      <xsl:otherwise>
        <xsl:text>@*[local-name()='</xsl:text>
        <xsl:value-of select="local-name()" />
        <xsl:text>' and namespace-uri()='</xsl:text>
        <xsl:value-of select="namespace-uri()" />
        <xsl:text>']</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-2">
    <xsl:for-each select="ancestor-or-self::*">
      <xsl:text>/</xsl:text>
      <xsl:value-of select="name(.)" />
      <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
        <xsl:text>[</xsl:text>
        <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1" />
        <xsl:text>]</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:if test="not(self::*)">
      <xsl:text />/@<xsl:value-of select="name(.)" />
    </xsl:if>
  </xsl:template>
<!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->

<xsl:template match="node() | @*" mode="schematron-get-full-path-3">
    <xsl:for-each select="ancestor-or-self::*">
      <xsl:text>/</xsl:text>
      <xsl:value-of select="name(.)" />
      <xsl:if test="parent::*">
        <xsl:text>[</xsl:text>
        <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1" />
        <xsl:text>]</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:if test="not(self::*)">
      <xsl:text />/@<xsl:value-of select="name(.)" />
    </xsl:if>
  </xsl:template>

<!--MODE: GENERATE-ID-FROM-PATH -->
<xsl:template match="/" mode="generate-id-from-path" />
  <xsl:template match="text()" mode="generate-id-from-path">
    <xsl:apply-templates mode="generate-id-from-path" select="parent::*" />
    <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')" />
  </xsl:template>
  <xsl:template match="comment()" mode="generate-id-from-path">
    <xsl:apply-templates mode="generate-id-from-path" select="parent::*" />
    <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')" />
  </xsl:template>
  <xsl:template match="processing-instruction()" mode="generate-id-from-path">
    <xsl:apply-templates mode="generate-id-from-path" select="parent::*" />
    <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')" />
  </xsl:template>
  <xsl:template match="@*" mode="generate-id-from-path">
    <xsl:apply-templates mode="generate-id-from-path" select="parent::*" />
    <xsl:value-of select="concat('.@', name())" />
  </xsl:template>
  <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
    <xsl:apply-templates mode="generate-id-from-path" select="parent::*" />
    <xsl:text>.</xsl:text>
    <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')" />
  </xsl:template>

<!--MODE: GENERATE-ID-2 -->
<xsl:template match="/" mode="generate-id-2">U</xsl:template>
  <xsl:template match="*" mode="generate-id-2" priority="2">
    <xsl:text>U</xsl:text>
    <xsl:number count="*" level="multiple" />
  </xsl:template>
  <xsl:template match="node()" mode="generate-id-2">
    <xsl:text>U.</xsl:text>
    <xsl:number count="*" level="multiple" />
    <xsl:text>n</xsl:text>
    <xsl:number count="node()" />
  </xsl:template>
  <xsl:template match="@*" mode="generate-id-2">
    <xsl:text>U.</xsl:text>
    <xsl:number count="*" level="multiple" />
    <xsl:text>_</xsl:text>
    <xsl:value-of select="string-length(local-name(.))" />
    <xsl:text>_</xsl:text>
    <xsl:value-of select="translate(name(),':','.')" />
  </xsl:template>
<!--Strip characters-->  <xsl:template match="text()" priority="-1" />

<!--SCHEMA SETUP-->
<xsl:template match="/">
    <svrl:schematron-output schemaVersion="" title="Architecture Principle integrity validation">
      <xsl:comment>
        <xsl:value-of select="$archiveDirParameter" />   
		 <xsl:value-of select="$archiveNameParameter" />  
		 <xsl:value-of select="$fileNameParameter" />  
		 <xsl:value-of select="$fileDirParameter" />
      </xsl:comment>
      <svrl:ns-prefix-in-attribute-values prefix="a" uri="http://www.opengroup.org/xsd/archimate/3.0/" />
      <svrl:ns-prefix-in-attribute-values prefix="xsi" uri="http://www.w3.org/2001/XMLSchema-instance" />
      <svrl:ns-prefix-in-attribute-values prefix="local" uri="local" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">CommonCompleteness</xsl:attribute>
        <xsl:attribute name="name">CommonCompleteness</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M18" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">Common</xsl:attribute>
        <xsl:attribute name="name">Common</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M19" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">SolutionSpecific</xsl:attribute>
        <xsl:attribute name="name">SolutionSpecific</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M20" select="/" />
    </svrl:schematron-output>
  </xsl:template>

<!--SCHEMATRON PATTERNS-->
<svrl:text>Architecture Principle integrity validation</svrl:text>
  <xsl:param name="root" select="/" />
  <xsl:param name="satDoc" select="document('ELAP_sat.xml')" />
  <xsl:param name="satView" select="$satDoc/a:model/a:views/a:diagrams/a:view[a:name = 'Architecture Principles viewpoint']" />
  <xsl:param name="satPrinciples" select="$satDoc/a:model/a:elements/a:element[       let $elementIdentifier := @identifier return (          $satView//a:node[@elementRef = $elementIdentifier]          and starts-with(./a:name, '&lt;&lt;ELAP:Architecture Principle>>')       )     ]" />

<!--PATTERN CommonCompleteness-->


	<!--RULE -->
<xsl:template match="/a:model" mode="M18" priority="1000">
    <svrl:fired-rule context="/a:model" />

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="true()" />
      <xsl:otherwise>
        <svrl:failed-assert test="true()">
          <xsl:attribute name="id">ELAP-000</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>No architecture principles defined</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Technology Neutrality'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Technology Neutrality'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Technology Neutrality' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Preservation of information'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Preservation of information'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Preservation of information' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Reuse, before buy, before build'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Reuse, before buy, before build'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Reuse, before buy, before build' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Openness'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Openness'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Openness' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Transparency'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Transparency'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Transparency' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Preservation of information'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Preservation of information'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Preservation of information' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Data portability'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Data portability'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Data portability' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Privacy'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Privacy'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Privacy' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Service Orientation'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Service Orientation'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Service Orientation' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Multilingulism'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Multilingulism'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Multilingulism' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> User-centricity'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> User-centricity'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'User-centricity' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Security by design'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Security by design'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Security by design' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Preservation of information'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Preservation of information'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Preservation of information' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Accountability'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Accountability'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Accountability' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Accessibility'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Accessibility'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Accessibility' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Administrative Simplification'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Administrative Simplification'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Administrative Simplification' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Best fit Public Service Implementation Orientation'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Best fit Public Service Implementation Orientation'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Best fit Public Service Implementation Orientation' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Carbon-dioxide e-footprint impact awareness'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Carbon-dioxide e-footprint impact awareness'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Carbon-dioxide e-footprint impact awareness' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Care from cradle to grave'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Care from cradle to grave'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Care from cradle to grave' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Code of ethics compliance'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Code of ethics compliance'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Code of ethics compliance' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Convergence assurance on public policy goals attainment'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Convergence assurance on public policy goals attainment'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Convergence assurance on public policy goals attainment' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Convergence control on public policy goals attainment'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Convergence control on public policy goals attainment'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Convergence control on public policy goals attainment' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Digital Inclusion'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Digital Inclusion'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Digital Inclusion' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> EU Legislation Compliance'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> EU Legislation Compliance'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'EU Legislation Compliance' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> EULF compliance'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> EULF compliance'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'EULF compliance' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> European digital sovereignty'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> European digital sovereignty'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'European digital sovereignty' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Evidence based Public Policy'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Evidence based Public Policy'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Evidence based Public Policy' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Innovation'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Innovation'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Innovation' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Integrated Horizontal User Experience'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Integrated Horizontal User Experience'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Integrated Horizontal User Experience' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Loosely coupled integration'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Loosely coupled integration'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Loosely coupled integration' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Market collaboration'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Market collaboration'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Market collaboration' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> New Public Management approach'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> New Public Management approach'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'New Public Management approach' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Once Only'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Once Only'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Once Only' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Primacy of principles'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Primacy of principles'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Primacy of principles' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Trust'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Trust'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Trust' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Subsidiarity and proportionality'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Subsidiarity and proportionality'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Subsidiarity and proportionality' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Social participation'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Social participation'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Social participation' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Public Value'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Public Value'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Public Value' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Proactiveness'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Proactiveness'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Proactiveness' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Deployment fit (Cloud-first approach)'])" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(/a:model/a:elements/a:element[a:name = '&lt;&lt;ELAP:Architecture Principle>> Deployment fit (Cloud-first approach)'])">
          <xsl:attribute name="id">ELAP-001</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-001] Architecture principle 'Deployment fit (Cloud-first approach)' must be defined in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M18" select="*" />
  </xsl:template>
  <xsl:template match="text()" mode="M18" priority="-1" />
  <xsl:template match="@*|node()" mode="M18" priority="-2">
    <xsl:apply-templates mode="M18" select="*" />
  </xsl:template>

<!--PATTERN Common-->


	<!--RULE -->
<xsl:template match="/a:model/a:elements/a:element[local:isArchitecturePrinciple(.)]" mode="M19" priority="1000">
    <svrl:fired-rule context="/a:model/a:elements/a:element[local:isArchitecturePrinciple(.)]" />

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="@xsi:type = 'Principle'" />
      <xsl:otherwise>
        <svrl:failed-assert test="@xsi:type = 'Principle'">
          <xsl:attribute name="id">ELAP-002</xsl:attribute>
          <xsl:attribute name="flag">warning</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-002] Element '<xsl:text />
            <xsl:value-of select="./a:name" />
            <xsl:text />' must be defined as an ArchiMate 'Principle' (actual is '<xsl:text />
            <xsl:value-of select="./@xsi:type" />
            <xsl:text />').</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="exists(local:findNonHierarchicalLinkedElements(.)) or local:lackOfPrincipleIsExplained(.)" />
      <xsl:otherwise>
        <svrl:failed-assert test="exists(local:findNonHierarchicalLinkedElements(.)) or local:lackOfPrincipleIsExplained(.)">
          <xsl:attribute name="id">ELAP-004</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-004] '<xsl:text />
            <xsl:value-of select="./a:name" />
            <xsl:text />' must be linked to at least one element in the model.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="local:influencesGrouping(.) or local:lackOfPrincipleIsExplained(.)" />
      <xsl:otherwise>
        <svrl:failed-assert test="local:influencesGrouping(.) or local:lackOfPrincipleIsExplained(.)">
          <xsl:attribute name="id">ELAP-005</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-005] Architecture principle '<xsl:text />
            <xsl:value-of select="./a:name" />
            <xsl:text />' must be modelled as influencing at least one or more elements (modelled within an ArchiMate 'Grouping' element).</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M19" select="*" />
  </xsl:template>
  <xsl:template match="text()" mode="M19" priority="-1" />
  <xsl:template match="@*|node()" mode="M19" priority="-2">
    <xsl:apply-templates mode="M19" select="*" />
  </xsl:template>

<!--PATTERN SolutionSpecific-->


	<!--RULE -->
<xsl:template match="/a:model/a:elements/a:element[local:isArchitecturePrinciple(.)]" mode="M20" priority="1000">
    <svrl:fired-rule context="/a:model/a:elements/a:element[local:isArchitecturePrinciple(.)]" />

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="local:isRealisedByInteroperabilitySpecification(.) or local:lackOfPrincipleIsExplained(.)" />
      <xsl:otherwise>
        <svrl:failed-assert test="local:isRealisedByInteroperabilitySpecification(.) or local:lackOfPrincipleIsExplained(.)">
          <xsl:attribute name="id">ELAP-003</xsl:attribute>
          <xsl:attribute name="flag">fatal</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>[ELAP-003] Architecture principle '<xsl:text />
            <xsl:value-of select="./a:name" />
            <xsl:text />' must be realised by an Interoperability Specification.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M20" select="*" />
  </xsl:template>
  <xsl:template match="text()" mode="M20" priority="-1" />
  <xsl:template match="@*|node()" mode="M20" priority="-2">
    <xsl:apply-templates mode="M20" select="*" />
  </xsl:template>
</xsl:stylesheet>
