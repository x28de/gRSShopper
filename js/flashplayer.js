/*

Init variables. The moviesToReplace array is used in case you
insert more than one movie on the same page.

The flashPlayer is the flash movie with a default
placeholderdownes.flv default movie

swfBGcolor is the background color of your page. You may be
able to set this to blank.

*/
moviesToReplace = new Array();
flashPlayer = "movies/player.swf";
swfBGcolor = "#ffffff";

/*

The following function actually embeds the movie. It is placed in a function for
the reason explained here: http://www.findmotive.com/2006/10/13/ie-click-to-activate-flash-fix/

*/
function displayMyMovie(moviePath, movieName) {
	var obHTML =
		"<object classid=\"clsid:d27cdb6e-ae6d-11cf-96b8-444553540000\" codebase=\"http:\/\/fpdownload.macromedia.com\/pub\/shockwave\/cabs\/flash\/swflash.cab#version=8,0,0,0\""+
			"id=\"" + movieName + 
			"\" width=\"340\" height=\"304\" align=\"middle\">" +
			"<param name=\"allowScriptAccess\" value=\"always\" \/>" +
			"<param name=\"swliveconnect\" value=\"true\" \/>" +
			"<param name=\"movie\" value=\"" + flashPlayer + "\" \/>" +
			"<param name=\"quality\" value=\"high\" \/>" +
			"<param name=\"bgcolor\" value=\"" + swfBGcolor + "\" \/>" +
				"<embed src=\"" + flashPlayer + "\" quality=\"high\" bgcolor=\"" + swfBGcolor + "\" width=\"340\" height=\"304\" swLiveConnect=true " + 
				"id=\"" + movieName + "\" " + 
				"name=\"" + movieName + "\" align=\"middle\" allowScriptAccess=\"always\" type=\"application\/x-shockwave-flash\" pluginspage=\"http:\/\/www.macromedia.com\/go\/getflashplayer\" \/>" +
		"<\/object>";
	document.write(obHTML);
	moviesToReplace[moviesToReplace.length] = new Array (moviePath,movieName);
}

/*

The following function is called from the previous function and loops the page for all movies to replace them.
The reason you can't load the movies directly is due to a bug in firefox. When it embeds the flash object, it doesn't
attach the SetVariables method quick enough to that object. That's why we load the movie with a placeholder
file and then load the other movies after a second of wait (see HTML file)

*/
function changeMovies() {
	for (i = 0; i < moviesToReplace.length; i++) {
		movieName = moviesToReplace[i][1];
		fullMovieName = moviesToReplace[i][0] + "/" + moviesToReplace[i][1] + ".flv";
		getFlashMovieObject(movieName).SetVariable("myCurrentMovie.contentPath",fullMovieName);
	}
}


/*

Just a function to the the specific object based on type of browser. It is called
by the previous function.

*/
function getFlashMovieObject(movieName) {
	if (navigator.appName.indexOf("Microsoft") != -1) {
		return window[movieName]
	} else {
		return document[movieName]
	}
}
