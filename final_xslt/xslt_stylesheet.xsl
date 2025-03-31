<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:tei="http://www.tei-c.org/ns/1.0"
               exclude-result-prefixes="tei"
               version="2.0">

<!-- Output pour HTML5 -->
<xsl:output method="html" encoding="UTF-8" indent="yes" doctype-system="about:legacy-compat"/>

<!-- Variables pour éviter les répétitions -->
<xsl:variable name="title" select="//tei:titleStmt/tei:title/text()"/>
<xsl:variable name="author" select="//tei:titleStmt/tei:author/text()"/>
<xsl:variable name="characters" select="//tei:front/tei:div[@type='editorial'][1]/tei:listPerson/tei:person"/>
<xsl:variable name="places" select="//tei:front/tei:div[@type='editorial'][2]/tei:listPlace/tei:place"/>
<xsl:variable name="books" select="//tei:body/tei:div1"/>

<!-- Root template: Crée index.html et les pages individuelles des romans  -->
<xsl:template match="/">
    <!-- Génère index.html -->
    <xsl:call-template name="generate-index"/>
    
    <!-- Génère character page -->
    <xsl:call-template name="generate-characters"/>
    
    <!-- Génère place page -->
    <xsl:call-template name="generate-places"/>
    
    <!-- Génère timeline page -->
    <xsl:call-template name="generate-timeline"/>
    
    <!-- Génère les pages individuelles avec des boucles -->
    <xsl:for-each select="$books">
        <xsl:variable name="book-id" select="translate(normalize-space(tei:head[@type='title']), ' ', '-')"/>
        <xsl:call-template name="generate-book">
            <xsl:with-param name="book" select="."/>
            <xsl:with-param name="book-id" select="$book-id"/>
        </xsl:call-template>
    </xsl:for-each>
</xsl:template>
 <!-- Template utilisée plus tard pour les dates du edition statement -->
    <xsl:template match="tei:date">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>)</xsl:text>
    </xsl:template>

<!-- Template pour index.html -->
<xsl:template name="generate-index">
    <xsl:result-document href="index.html">
        <html lang="en">
            <xsl:call-template name="html-head">
                <xsl:with-param name="page-title" select="$title"/>
            </xsl:call-template>
            
            <body>
                <xsl:call-template name="header"/>
                
                <main>
                    <section class="hero">
                        <h1><xsl:value-of select="$title"/></h1>
                        <h2>by <xsl:value-of select="$author"/></h2>
                        
                        <!-- Edition statement avec apply-templates pour formatter la date -->
                        <p class="edition">
                            <xsl:apply-templates select="//tei:editionStmt/tei:edition/node()"/>
                        </p>
                        
                        <!-- Epigraphe avec prédicat XPath -->
                        <xsl:if test="//tei:front/tei:div[not(@type='editorial')]/tei:p">
                            <div class="dedication">
                                <xsl:value-of select="//tei:front/tei:div[not(@type='editorial')]/tei:p"/>
                            </div>
                        </xsl:if>
                    </section>
                    
                    <section class="books">
                        <h2>The Duluoz Legend Books</h2>
                        <div class="book-grid">
                            <!-- Boucle avec fonction position() -->
                            <xsl:for-each select="$books">
                                <xsl:variable name="book-id" select="translate(normalize-space(tei:head[@type='title']), ' ', '-')"/>
                                <div class="book">
                                    <h3>
                                        <xsl:value-of select="concat(position(), '. ')"/>
                                        <a href="{$book-id}.html">
                                            <xsl:value-of select="tei:head[@type='title']"/>
                                        </a>
                                    </h3>
                                    <!-- Preview du premier paragraphe avec la fonction substring -->
                                    <p>
                                        <xsl:value-of select="concat(substring(normalize-space(tei:div2[1]/tei:div3[1]/tei:p[1]), 1, 200), '...')"/>
                                    </p>
                                    <p class="publication">
                                        <xsl:variable name="book-title" select="tei:head[@type='title']"/>
                                        <!-- Utilisation du prédicat pour la date de publication correspondante -->
                                        <xsl:value-of select="//tei:back//tei:bibl[tei:title=$book-title]/tei:date"/>
                                    </p>
                                    <a href="{$book-id}.html" class="read-more">Read More</a>
                                </div>
                            </xsl:for-each>
                        </div>
                    </section>
                </main>
                
                <xsl:call-template name="footer"/>
            </body>
        </html>
    </xsl:result-document>
</xsl:template>

<!-- Template pour characters.html -->
<xsl:template name="generate-characters">
    <xsl:result-document href="characters.html">
        <html lang="en">
            <xsl:call-template name="html-head">
                <xsl:with-param name="page-title" select="concat('Characters | ', $title)"/>
            </xsl:call-template>
            <body>
                <xsl:call-template name="header"/>
                
                <main>
                    <h1>Characters in the Duluoz Legend</h1>
                    
                    <section class="character-list">
                        <!-- Boucle dans les personnages pour les "ranger" -->
                        <xsl:for-each select="$characters">
                            <xsl:sort select="tei:persName[1]/tei:surname"/>
                            <div class="character">
                                <h2 id="{@xml:id}">
                                    <xsl:value-of select="tei:persName[1]/tei:forename"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="tei:persName[1]/tei:surname"/>
                                </h2>
                                
                                <!-- Partie "Aliases" avec conditions -->
                                <xsl:if test="count(tei:persName[@type='alias']) > 0">
                                    <div class="aliases">
                                        <h3>Appears as:</h3>
                                        <ul>
                                            <xsl:for-each select="tei:persName[@type='alias']">
                                                <li>
                                                    <xsl:choose>
                                                        <!-- Condition pour vérifier s'il y a un surname -->
                                                        <xsl:when test="tei:surname">
                                                            <xsl:value-of select="concat(tei:forename, ' ', tei:surname)"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="tei:forename"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                    </div>
                                </xsl:if>
                                
                                <!-- Lien Wikidata avec condition -->
                                <xsl:if test="tei:idno[@type='wikidata']">
                                    <p class="external-link">
                                        <a href="https://www.wikidata.org/wiki/{tei:idno[@type='wikidata']/text()}">
                                            View on Wikidata
                                        </a>
                                    </p>
                                </xsl:if>
                            </div>
                        </xsl:for-each>
                    </section>
                </main>
                
                <xsl:call-template name="footer"/>
            </body>
        </html>
    </xsl:result-document>
</xsl:template>

<!-- Template pour places.html -->
<xsl:template name="generate-places">
    <xsl:result-document href="places.html">
        <html lang="en">
            <xsl:call-template name="html-head">
                <xsl:with-param name="page-title" select="concat('Places | ', $title)"/>
            </xsl:call-template>
            <body>
                <xsl:call-template name="header"/>
                
                <main>
                    <h1>Places in the Duluoz Legend</h1>
                    
                    <section class="place-list">
                        <!-- Groupe les places avec des prédicats -->
                        <h2>Cities</h2>
                        <ul class="cities">
                            <xsl:for-each select="$places[@type='city']">
                                <xsl:sort select="tei:placeName"/>
                                <li id="{@xml:id}">
                                    <xsl:value-of select="tei:placeName"/>
                                </li>
                            </xsl:for-each>
                        </ul>
                        
                        <h2>States</h2>
                        <ul class="states">
                            <xsl:for-each select="$places[@type='state']">
                                <xsl:sort select="tei:placeName"/>
                                <li id="{@xml:id}">
                                    <xsl:value-of select="tei:placeName"/>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </section>
                </main>
                
                <xsl:call-template name="footer"/>
            </body>
        </html>
    </xsl:result-document>
</xsl:template>

<!-- Template pour les pages des romans -->
<xsl:template name="generate-book">
    <xsl:param name="book"/>
    <xsl:param name="book-id"/>
    
    <xsl:result-document href="{$book-id}.html">
        <html lang="en">
            <xsl:call-template name="html-head">
                <xsl:with-param name="page-title" select="concat($book/tei:head[@type='title'], ' | ', $title)"/>
            </xsl:call-template>
            <body>
                <xsl:call-template name="header"/>
                
                <main>
                    <h1><xsl:value-of select="$book/tei:head[@type='title']"/></h1>
                    
                    <!-- Process les chapitres des romans -->
                    <div class="book-content">
                        <xsl:for-each select="$book/tei:div2/tei:div3">
                            <section class="chapter">
                                <h2>Chapter <xsl:value-of select="tei:head"/></h2>
                                
                                <!-- Process les paragraphes avec surlignage des personnages -->
                                <xsl:for-each select="tei:p">
                                    <p>
                                        <!-- Process contenu avec surlignage des persos/endroits -->
                                        <xsl:apply-templates select="node()"/>
                                    </p>
                                </xsl:for-each>
                            </section>
                        </xsl:for-each>
                    </div>
                </main>
                
                <xsl:call-template name="footer"/>
            </body>
        </html>
    </xsl:result-document>
</xsl:template>

<!-- Templates pour process le mixed content: références aux persos -->
<xsl:template match="tei:persName">
    <span class="character" title="Character reference">
        <xsl:choose>
            <!-- Condition pour les différents formats de nom -->
            <xsl:when test="tei:forename and tei:surname">
                <a href="characters.html#{@ref}">
                    <xsl:value-of select="tei:forename"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="tei:surname"/>
                </a>
            </xsl:when>
            <xsl:when test="tei:forename">
                <a href="characters.html#{@ref}">
                    <xsl:value-of select="tei:forename"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </span>
</xsl:template>

<!-- Template pour les références aux endroits -->
<xsl:template match="tei:placeName">
    <span class="place" title="Place reference">
        <a href="places.html#{@ref}">
            <xsl:apply-templates/>
        </a>
    </span>
</xsl:template>

<!-- Template pour les dates -->
<xsl:template match="tei:date">
    <span class="date">
        <xsl:apply-templates/>
    </span>
</xsl:template>

    <!-- Template for timeline.html -->
    <xsl:template name="generate-timeline">
        <xsl:result-document href="timeline.html">
            <html lang="en">
                <xsl:call-template name="html-head">
                    <xsl:with-param name="page-title" select="concat('Timeline | ', $title)"/>
                </xsl:call-template>
                <body>
                    <xsl:call-template name="header"/>
                    
                    <main>
                        <h1>Duluoz Legend Timeline</h1>
                        
                        <section class="timeline">
                            <!-- Timeline intro -->
                            <p class="timeline-intro">
                                A chronological overview of key dates in the Duluoz Legend.
                            </p>
                            
                            <!-- Timeline container -->
                            <div class="timeline-container">
                                <!-- Publication dates -->
                                <div class="timeline-section">
                                    <h2>Publication History</h2>
                                    <ul class="events">
                                        <xsl:for-each select="//tei:back//tei:bibl">
                                            <xsl:sort select="substring(tei:date, string-length(tei:date) - 3)"/>
                                            <li class="event">
                                                <span class="event-date"><xsl:value-of select="substring(tei:date, string-length(tei:date) - 3)"/></span>
                                                <span class="event-title"><xsl:value-of select="tei:title"/></span>
                                                <span class="event-desc"><xsl:value-of select="tei:date"/></span>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </div>
                                
                                <!-- Story dates from content -->
                                <div class="timeline-section">
                                    <h2>Story Timeline</h2>
                                    <ul class="events">
                                        <!-- Neal Cassady birth -->
                                        <li class="event">
                                            <span class="event-date">1926</span>
                                            <span class="event-title">Dean Moriarty/Cody Pomeray Born</span>
                                            <span class="event-desc">Born on the road when his parents were passing through Salt Lake City, on their way to Los Angeles.</span>
                                        </li>
                                        
                                        <!-- Extract other dates from the text -->
                                        <xsl:for-each select="//tei:body//tei:date[not(. = '1926')]">
                                            <xsl:sort select="@when"/>
                                            <li class="event">
                                                <span class="event-date"><xsl:value-of select="@when"/></span>
                                                <span class="event-title">
                                                    <xsl:text>From </xsl:text>
                                                    <xsl:value-of select="ancestor::tei:div1/tei:head[@type='title']"/>
                                                </span>
                                                <span class="event-desc">
                                                    <xsl:value-of select="concat(substring(normalize-space(parent::*), 1, 100), '...')"/>
                                                </span>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </div>
                                
                                <!-- Character connections -->
                                <div class="timeline-section">
                                    <h2>Character Connections Reminder</h2>
                                    <p>Principal characters in the Duluoz Legend and their real-life counterparts:</p>
                                    <ul class="character-timeline">
                                        <xsl:for-each select="$characters[count(tei:persName[@type='alias']) > 0]">
                                            <li class="character-connection">
                                                <span class="real-person">
                                                    <xsl:value-of select="concat(tei:persName[1]/tei:forename, ' ', tei:persName[1]/tei:surname)"/>
                                                </span>
                                                <span class="aliases">
                                                    <xsl:text>→ </xsl:text>
                                                    <xsl:for-each select="tei:persName[@type='alias']">
                                                        <xsl:choose>
                                                            <xsl:when test="tei:surname">
                                                                <xsl:value-of select="concat(tei:forename, ' ', tei:surname)"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="tei:forename"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                        <xsl:if test="position() != last()">
                                                            <xsl:text>, </xsl:text>
                                                        </xsl:if>
                                                    </xsl:for-each>
                                                </span>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </div>
                            </div>
                        </section>
                    </main>
                    
                    <xsl:call-template name="footer"/>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>

<!-- Garder text nodes tels quels -->
<xsl:template match="text()">
    <xsl:value-of select="."/>
</xsl:template>

<!--Template réutilisable pour le head -->
<xsl:template name="html-head">
    <xsl:param name="page-title"/>
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title><xsl:value-of select="$page-title"/></title>
        <link rel="stylesheet" href="styles.css"/>
    </head>
</xsl:template>

<!-- Template réutilisable pour le header -->
<xsl:template name="header">
    <header>
        <div class="header-content">
            <div class="title">
                <a href="index.html"><xsl:value-of select="$title"/></a>
            </div>
            <nav>
                <ul>
                    <li><a href="index.html">Home</a></li>
                    <!-- Navigation dynamique grâce aux boucles -->
                    <xsl:for-each select="$books">
                        <xsl:variable name="current-book-id" select="translate(normalize-space(tei:head[@type='title']), ' ', '-')"/>
                        <li>
                            <a href="{$current-book-id}.html">
                                <xsl:value-of select="tei:head[@type='title']"/>
                            </a>
                        </li>
                    </xsl:for-each>
                    <li><a href="characters.html">Characters</a></li>
                    <li><a href="places.html">Places</a></li>
                    <li><a href="timeline.html">Timeline</a></li>
                </ul>
            </nav>
        </div>
    </header>
</xsl:template>

<!-- Template réutilisable pour le footer -->
<xsl:template name="footer">
    <footer>
        <div class="footer-content">
            <p>The Duluoz Legend Digital Edition</p>
            <p>
                <xsl:value-of select="$author"/>
            </p>
            <p>
                <small>Encoded by: 
                    <xsl:value-of select="//tei:titleStmt/tei:respStmt/tei:persName/tei:forename"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="//tei:titleStmt/tei:respStmt/tei:persName/tei:surname"/>
                </small>
            </p>
        </div>
    </footer>
</xsl:template>

</xsl:stylesheet>
