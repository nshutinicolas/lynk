var GrabWebContent = function() {}

function getFaviconUrl() {
	// Try to find the favicon using link tag
	const links = document.getElementsByTagName('link');
	let faviconUrl = null;
	
	// Check for <link rel="icon"> or <link rel="shortcut icon">
	for (let i = 0; i < links.length; i++) {
		const link = links[i];
		const rel = link.rel.toLowerCase();
		if (rel.includes('icon')) {
			faviconUrl = link.href;
			if (faviconUrl) break;
		}
	}
	
	// If no explicit favicon found, try the default /favicon.ico
	if (!faviconUrl) {
		const url = new URL(document.URL);
		faviconUrl = url.origin + '/favicon.ico';
	}
	
	return faviconUrl;
}

GrabWebContent.prototype = {
	run: function(parameters) {
		parameters.completionFunction({
			"url": document.URL,
			"title": document.title,
			"icon": getFaviconUrl()
		});
	},
	finalize: function(parameters) {
		var customJavascript = parameters["customJavaScript"];
		if (customJavascript && typeof customJavascript === 'string') {
			try {
				(new Function(customJavascript))()
			} catch (e) {
				console.error("Failed to load Script: ", e)
			}
		}
	}
};

// This global name should be named as is ie: `ExtensionPreprocessingJS` - extracted from Apple Docs
var ExtensionPreprocessingJS = new GrabWebContent;
