<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:a="http://www.opengroup.org/xsd/archimate/3.0/"
                xmlns:local="local">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:variable name="apViewNode" select="/a:model/a:views/a:diagrams/a:view[a:name = 'Architecture Principles viewpoint']"/>
    <xsl:variable name="apElementNodes" select="/a:model/a:elements/a:element[local:isArchitecturePrinciple(.)]"/>
    <xsl:variable name="apElementNodeNames" select="$apElementNodes/a:name"/>

    <xsl:function name="local:inView" as="xs:boolean">
        <xsl:param name="elementNode"/>
        <xsl:sequence select="exists($apViewNode//a:node[@elementRef = $elementNode/@identifier])"/>
    </xsl:function>

    <xsl:function name="local:isArchitecturePrinciple" as="xs:boolean">
        <xsl:param name="elementNode"/>
        <xsl:sequence select="local:inView($elementNode) and starts-with($elementNode/a:name, '&lt;&lt;ELAP:Architecture Principle&gt;&gt;')"/>
    </xsl:function>

    <xsl:function name="local:removeStereotype" as="xs:string">
        <xsl:param name="elementName"/>
        <xsl:sequence select="normalize-space(substring-after(string($elementName), '&gt;&gt;'))"/>
    </xsl:function>

    <xsl:template match="/">
        <schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
            <pattern xmlns="http://purl.oclc.org/dsdl/schematron" id="CommonCompleteness">
                <rule context="/a:model">
                    <!-- Add an always successful assertion to avoid an invalid schematron if empty. -->
                    <assert id="ELAP-000" test="true()">No architecture principles defined</assert>
                    <!-- Completeness principle: All APs MUST be modelled -->
                    <xsl:for-each select="$apElementNodeNames">
                        <xsl:variable name="apName" select="."/>
                        <xsl:variable name="ruleId" select="'ELAP-001'"/>
                        <assert id="{$ruleId}" flag="fatal" test="exists(/a:model/a:elements/a:element[a:name = '{$apName}'])">[<xsl:value-of select="$ruleId"/>] Architecture principle '<xsl:value-of select="local:removeStereotype(.)"/>' must be defined in the model.</assert>
                    </xsl:for-each>
                </rule>
            </pattern>
        </schema>
    </xsl:template>

</xsl:stylesheet>