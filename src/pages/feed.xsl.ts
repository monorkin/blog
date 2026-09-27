import stylesheetUrl from "~/styles/app.css?url"
import { FEEDS } from "~/lib/feed"

// Styles the Atom feeds so they read like a web page when opened in a browser
export async function GET() {
  return new Response(stylesheet(), {
    headers: { "Content-Type": "application/xslt+xml; charset=utf-8" }
  })
}

function stylesheet() {
  const feedLinks = FEEDS.map(feed => feedLink(feed.path, feed.label)).join("\n")

  return `<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:atom="http://www.w3.org/2005/Atom">
  <xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml" lang="en">
      <head>
        <title>
          RSS Feed |
          <xsl:value-of select="/atom:feed/atom:title"/>
        </title>
        <meta charset="utf-8"/>
        <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <link rel="stylesheet" href="${stylesheetUrl}" media="all" />
      </head>
      <body>
        <main class="feed">
          <dk-alert-box type="info">
            <strong>This is an RSS feed</strong>. Subscribe by copying
            the URL from the address bar into your newsreader.
          </dk-alert-box>
          <div>
            <h1 class="feed__heading">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="feed__rss-icon" alt="RSS icon" aria-label="RSS icon"><path stroke-linecap="round" stroke-linejoin="round" d="M12.75 19.5v-.75a7.5 7.5 0 00-7.5-7.5H4.5m0-6.75h.75c7.87 0 14.25 6.38 14.25 14.25v.75M6 18.75a.75.75 0 11-1.5 0 .75.75 0 011.5 0z" /></svg>
              RSS Feed
            </h1>
            <h2 class="feed__site-name">stanko.io</h2>
            <a class="feed__site-link">
              <xsl:attribute name="href">
                <xsl:value-of select="/atom:feed/atom:link[1]/@href"/>
              </xsl:attribute>
              Visit Website &#x2192;
            </a>

            <div class="feed__filter-section">
              <p class="feed__filter-label">
                Feeds:
              </p>
              <ul class="feed__filter-list">
${feedLinks}
              </ul>
            </div>

            <h2 class="feed__entries-heading">
              Latest
            </h2>

            <xsl:for-each select="/atom:feed/atom:entry">
              <div class="feed__entry">
                <div class="feed__entry-date">
                  Published on
                  <xsl:value-of select="substring(atom:published, 0, 11)" />
                </div>

                <div class="feed__entry-title">
                  <a>
                    <xsl:attribute name="href">
                      <xsl:value-of select="atom:link/@href"/>
                    </xsl:attribute>
                    <xsl:value-of select="atom:title"/>
                  </a>
                </div>

                <div class="feed__entry-summary"><xsl:value-of select="atom:summary"/></div>
              </div>
            </xsl:for-each>
          </div>
        </main>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
`
}

function feedLink(href: string, label: string) {
  return `                <li><a href="${href}">${label}</a></li>`
}
