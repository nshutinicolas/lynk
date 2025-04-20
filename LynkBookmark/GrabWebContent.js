var GrabWebContent = function() {}

function getFaviconUrl() {
	// Try to find the favicon in various ways
	const links = document.getElementsByTagName('link');
	let faviconUrl = null;
	
	// Check for <link rel="icon"> or <link rel="shortcut icon">
	for (let i = 0; i < links.length; i++) {
		const link = links[i];
		if (link.rel === 'icon' || link.rel === 'shortcut icon') {
			faviconUrl = link.href;
			// Prefer the first one found, unless there's a better one later
			break;
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
		eval(customJavascript)
	}
};

// This global name should be named as is ie: `ExtensionPreprocessingJS`
var ExtensionPreprocessingJS = new GrabWebContent;
