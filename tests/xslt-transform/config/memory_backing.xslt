<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml" indent="yes"/>

  <!-- 1) Drop any existing <cpu> definitions entirely -->
  <xsl:template match="cpu"/>

  <!-- 2) Root template: copy the <domain> element and everything beneath… -->
  <xsl:template match="/domain">
    <xsl:copy>
      <!-- …preserve ALL child nodes & attributes verbatim -->
      <xsl:apply-templates select="@*|node()"/>

      <!-- 3) THEN append your passthrough CPU -->
      <cpu mode="host-passthrough" check="none" migratable="on"/>

      <!-- 4) AND append your memoryBacking block -->
      <memoryBacking>
        <source type="memfd"/>
        <access mode="shared"/>
      </memoryBacking>
    </xsl:copy>
  </xsl:template>

  <!-- 5) Identity template for everything else -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
