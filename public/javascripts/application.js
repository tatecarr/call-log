// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// enable the submit buttons for file uploaders
function enableSubmit(ourButton) {
	ourButton.form["commit"].disabled = false;
}

function toggleIt(element) {
	var content = document.getElementById('content').childNodes;
	for (var i = 0; i < content.length; i++) {
		if (content[i].style) {
			content[i].style.display = "none";
		}
	}
	document.getElementById(element).style.display = "";
}