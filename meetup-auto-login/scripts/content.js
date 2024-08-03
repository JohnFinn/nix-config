'use strict';
var executed = false;
var observer = new MutationObserver(function(mutations) {
		var loginWithGoogleButton = document.querySelector("#google-login");
		if (loginWithGoogleButton === null) {
				//alert('???')
		} else if (!executed) {
				executed = true;
				loginWithGoogleButton.click();
		}
});
observer.observe(document, {
		subtree: true,
		childList: true,
		attributes: true //configure it to listen to attribute changes
});
