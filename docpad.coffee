# The DocPad Configuration File
# It is simply a CoffeeScript Object which is parsed by CSON
cheerio = require('cheerio')
url = require('url')

docpadConfig = {
	prompts: false,
	layoutsPaths: [  # default
        'layouts'
    ]

	# =================================
	# Template Data
	# These are variables that will be accessible via our templates
	# To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ
	templateData:

		# Specify some site properties
		site:
			# The production url of our website
			url: "http://michaelcummings.net"

			# The default title of our website
			title: "Michael H.C. Cummings"

			# The website description (for SEO)
			description: """
				This is the personal blog of Michael H.C. Cummings, a Microsoft Technical Evangelist in the Northeastern United States.
				"""

			# The website keywords (for SEO) separated by commas
			keywords: """
				Michael Cummings, Microsoft, Technical Evangelist, .Net, Mono, Game Development, Mobile
				"""

			# The website author's name
			author: "Michael H.C. Cummings"

			# The website author's email
			email: "cummings.michael@live.com"

			# Styles
			styles: [
				"/styles/bootstrap.min.css"
				"/styles/bootstrap-responsive.min.css"
				"/styles/site.css"
				"/styles/theme.css"
				"/styles/abstract.css"
				"http://alexgorbatchev.com/pub/sh/current/Styles/shCore.css"
				"http://alexgorbatchev.com/pub/sh/current/Styles/shThemeDefault.css"
			]

			# Scripts
			scripts: [
				"http://cdnjs.cloudflare.com/ajax/libs/jquery/1.10.2/jquery.min.js"
				"http://cdnjs.cloudflare.com/ajax/libs/modernizr/2.6.2/modernizr.min.js"
				"/scripts/bootstrap.min.js"
				"/scripts/script.js"
				"/scripts/search.js"
			]



		# -----------------------------
		# Helper Functions

		# Get the prepared site/document title
		# Often we would like to specify particular formatting to our page's title
		# we can apply that formatting here
		getPreparedTitle: ->
			# if we have a document title, then we should use that and suffix the site's title onto it
			if @document.title
				"#{@document.title} by #{@site.author}"
			# if our document does not have it's own title, then we should just use the site's title
			else
				@site.title

		getPageUrlWithHostname: ->
			"#{@site.url}#{@document.url}"

		getIdForDocument: (document) ->
			hostname = url.parse(@site.url).hostname
			date = document.date.toISOString().split('T')[0]
			path = document.url
			"tag:#{hostname},#{date},#{path}"
		
		getOldUrl: (newUrl) ->
			newUrl.substr(0,newUrl.length-1) + '.html'

		fixLinks: (content, baseUrlOverride) ->
			baseUrl = @site.url
			if baseUrlOverride
				baseUrl = baseUrlOverride
			regex = /^(http|https|ftp|mailto):/

			$ = cheerio.load(content)
			$('img').each ->
				$img = $(@)
				src = $img.attr('src')
				$img.attr('src', baseUrl + src) unless regex.test(src)
			$('a').each ->
				$a = $(@)
				href = $a.attr('href')
				$a.attr('href', baseUrl + href) unless regex.test(href)
			$.html()

		getFirstParagraph: ( content ) ->
			regex = /<p>([.\s\S]*?)<\/p>/
			regex.exec(content)?[0]

		moment: require('moment')
			
		getJavascriptEncodedTitle: (title) ->
			title.replace("'", "\\'")

		# Get the prepared site/document description
		getPreparedDescription: ->
			# if we have a document description, then we should use that, otherwise use the site's description
			@document.description or @site.description

		# Get the prepared site/document keywords
		getPreparedKeywords: ->
			# Merge the document keywords with the site keywords
			@site.keywords.concat(@document.keywords or []).join(', ')

		getTagUrl: (tag) ->
            slug = tag.toLowerCase().replace(/[^a-z0-9]/g, '-').replace(/-+/g, '-').replace(/^-|-$/g, '')

		# Discus.com settings
		disqusShortName: 'michaelcummings'

	# =================================
	# Collections
	# These are special collections that our website makes available to us

	collections:
		pages: (database) ->
			database.findAllLive({pageOrder: $exists: true}, [pageOrder:1,title:1])

		posts: (database) ->
			database.findAllLive({layout: 'post', draft: $exists: false},[{date:-1}])


	# =================================
	# Plugins

	plugins:
        tags:
          extension: ".html.eco"
          injectDocumentHelper: (document) ->
            document.setMeta(
              layout: 'article'
              data: """
                <%- @partial('tagged', @) %>
              """
            )

        tagcloud:
          getTagWeight: (count, maxCount) ->
            return Math.round((count/maxCount) * 10)

		paged:
			cleanurl: true
			startingPageNumber: 2
		cleanurls:
			trailingSlashes: true

	# =================================
	# DocPad Events

	# Here we can define handlers for events that DocPad fires
	# You can find a full listing of events on the DocPad Wiki
	events:

		# Server Extend
		# Used to add our own custom routes to the server before the docpad routes are added
		serverExtend: (opts) ->
			# Extract the server from the options
			{server} = opts
			docpad = @docpad

			# As we are now running in an event,
			# ensure we are using the latest copy of the docpad configuraiton
			# and fetch our urls from it
			latestConfig = docpad.getConfig()
			oldUrls = latestConfig.templateData.site.oldUrls or []
			newUrl = latestConfig.templateData.site.url

			# Redirect any requests accessing one of our sites oldUrls to the new site url
			server.use (req,res,next) ->
				if req.headers.host in oldUrls
					res.redirect(newUrl+req.url, 301)
				else
					next()
}


# Export our DocPad Configuration
module.exports = docpadConfig
