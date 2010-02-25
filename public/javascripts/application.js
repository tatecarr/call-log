// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// enable the submit buttons for file uploaders
function enableSubmit(ourButton) {
	ourButton.form["commit"].disabled = false;
}

function toggleIt(element) {
	var content = document.getElementById("content").childNodes;
	for (var i = 0; i < content.length; i++) {
		if (content[i].style) {
			content[i].style.display = "none";
		}
	}
	document.getElementById(element).style.display = "";
}

function resizeText(multiplier) {
  if (document.body.style.fontSize == "") {
    document.body.style.fontSize = "1.0em";
  }
  document.body.style.fontSize = parseFloat(document.body.style.fontSize) + (multiplier * 0.2) + "em";
}

// below two methods are some hacked together font size adjustment methods.
// most methods I found online only affected certain types of elements so
// I added an outer loop which applies the changes to any of the elements
// in the elements array.
var minFontSize=8;
var maxFontSize=26;
function increaseFontSize() {
	
	var elements = ['p','div','table','tr','td','body','a','input','li','ul','select']
	
	for(var z = 0; z < elements.length; z++)
	{
	   var p = document.getElementsByTagName(elements[z]);
	   for(i=0;i<p.length;i++) {
	      if(p[i].style.fontSize) {
	         var s = parseInt(p[i].style.fontSize.replace("px",""));
	      } else {
	         var s = 12;
	      }
	      if(s!=maxFontSize) {
	         s += 1;
	      }
	      p[i].style.fontSize = s+"px"
	   }
	}
}
function decreaseFontSize() {
	
	var elements = ['p','div','table','tr','td','body','a','input','li','ul','select']
	
	for(var z = 0; z < elements.length; z++)
	{
	   var p = document.getElementsByTagName(elements[z]);
	   for(i=0;i<p.length;i++) {
	      if(p[i].style.fontSize) {
	         var s = parseInt(p[i].style.fontSize.replace("px",""));
	      } else {
	         var s = 12;
	      }
	      if(s!=minFontSize) {
	         s -= 1;
	      }
	      p[i].style.fontSize = s+"px"
	   }
	}
}