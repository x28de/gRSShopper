// Width control script
// Source: http://hem.fyristorg.com/g-force/test/max-width.htm

var base_url = "http://change.mooc.ca/";
var cgi_url = base_url + "cgi-bin/";
var current= 0;



function confirmDelete(delUrl) {
  if (confirm("Are you sure you want to delete")) {
    document.location = delUrl;
  }
}



/**
 * Sets a Cookie with the given name and value.
 *
 * name       Name of the cookie
 * value      Value of the cookie
 * [expires]  Expiration date of the cookie (default: end of current session)
 * [path]     Path where the cookie is valid (default: path of calling document)
 * [domain]   Domain where the cookie is valid
 *              (default: domain of calling document)
 * [secure]   Boolean value indicating if the cookie transmission requires a
 *              secure transmission
 */
function setCookie(name, value, path, domain, expires, secure)
{
    document.cookie= name + "=" + escape(value) +
        ((path) ? "; path=" + path : "") +
        ((domain) ? "; domain=" + domain : "") +
        ((expires) ? "; expires=" + expires.toGMTString() : "") +
        ((secure) ? "; secure" : "");
}

/**
 * Gets the value of the specified cookie.
 *
 * name  Name of the desired cookie.
 *
 * Returns a string containing value of specified cookie,
 *   or null if cookie does not exist.
 */
function getCookie(name)
{
    var dc = document.cookie;
    var prefix = name + "=";
    var begin = dc.indexOf("; " + prefix);
    if (begin == -1)
    {
        begin = dc.indexOf(prefix);
        if (begin != 0) return null;
    }
    else
    {
        begin += 2;
    }
    var end = document.cookie.indexOf(";", begin);
    if (end == -1)
    {
        end = dc.length;
    }
    return unescape(dc.substring(begin + prefix.length, end));
}

/**
 * Deletes the specified cookie.
 *
 * name      name of the cookie
 * [path]    path of the cookie (must be same as path used to create cookie)
 * [domain]  domain of the cookie (must be same as domain used to create cookie)
 */
function deleteCookie(name, path, domain)
{
    if (getCookie(name))
    {
        document.cookie = name + "=" + 
            ((path) ? "; path=" + path : "") +
            ((domain) ? "; domain=" + domain : "") +
            "; expires=Thu, 01-Jan-70 00:00:01 GMT";
    }
}


function changeTheme() {
   deleteCookie("theme","/","www.mooc.ca");
	location.reload();
}

function login_box() {		
  if (getCookie('change_mooc_ca_person_title') == null) {
	document.write("You are not logged in. [<A HREF='" + cgi_url + "login.cgi?refer=" +
	   document.location + "' class='Nav' target='_top'>Login</A>] " +
	   "[<A HREF='" + cgi_url + "login.cgi?action=Register&refer=" +
	   document.location + "'  class='Nav' target='_top'>Register</A>]"); 
   } else if (getCookie('change_mooc_ca_person_title') == "anymouse") {
	document.write("You are not logged in. [<A HREF='" + cgi_url + "login.cgi?refer=" +
	   document.location + "' class='Nav' target='_top'>Login</A>] " +
	   "[<A HREF='" + cgi_url + "login.cgi?action=Register&refer=" +
	   document.location + "'  class='Nav' target='_top'>Register</A>]"); 
   } else {
	document.write("You are logged in as <b>" + getCookie('change_mooc_ca_person_title') + "</b> " +
         "[<A HREF='" + cgi_url + "login.cgi?action=Options&refer="+
		document.location + "' class='Nav' target='_top'>Options</a>] " +
	   "[<a href='" + cgi_url + "login.cgi?action=Logout&refer="+
		document.location + "' class='Nav' target='_top'>Logout</A>]"); 
   }
}

function comment_login_box() {

   var notlogged = "You are not logged in. You must be logged in to comment. <a href='" + cgi_url + "login.cgi?refer=" +
           document.location + "'>Login</a> to your existing account or " +
	   "<a href='" + cgi_url + "login.cgi?refer=" + document.location +
	   "&action=Register'>register</a> for a new one.";

   var logged = "You are logged on as <b>" + getCookie('change_mooc_ca_person_title') + "</b>. You can <a href='" + cgi_url + 
            "login.cgi?action=Logout&refer=" + document.location +
            "'>Logout</a> (we'll bring you right back here after you're done) but then you won't be able to comment."

  if (getCookie('change_mooc_ca_person_title') == null) {
	document.write(notlogged); 
   } else if (getCookie('change_mooc_ca_person_title') == "anymouse") {
	document.write(notlogged); 
   } else {
	document.write(logged); 
   }

}

/* For search forms submissions */

function changeDiv(the_div,the_change)
{
  var the_style = getStyleObject(the_div);
  if (the_style != false)
  {
    the_style.display = the_change;
  }
}

function hideAll()
{
  changeDiv("post_questions","none");
  changeDiv("author_questions","none");
  changeDiv("journal_questions","none");
  changeDiv("event_questions","none");
  changeDiv("topic_questions","none");
}

function getStyleObject(objectId) {
  if (document.getElementById && document.getElementById(objectId)) {
    return document.getElementById(objectId).style;
  } else if (document.all && document.all(objectId)) {
    return document.all(objectId).style;
  } else {
    return false;
  }
}

function click(which) {
    document.the_form.table[which].checked = true;
}


/* Viewer  */


function showpage(id) {

	var url = "http://change.mooc.ca/cgi-bin/page.cgi?format=viewer&link="+id;
	return url;

}


function selectArticle(value)
   {


     if (value != 0)
     {
        var url = showpage(value);

        if (window.ActiveXObject)
        {
          httpRequest = new ActiveXObject("Microsoft.XMLHTTP");
        }
        else
        {
          httpRequest = new XMLHttpRequest();
        }
        httpRequest.open("GET", url, true);
        httpRequest.onreadystatechange= function () {processRequest(); } ;
        httpRequest.send(null);
	return url;
      }
      else
      {
        // just delete the content when no article selected
        document.getElementById("contentViewer").innerHTML = "";
        
      }
   }

   /**
    * Event handler for the XMLhttprequest
    * when the content is back (State 4 and status 200)
    * take the content of the request and copy it into the HTML page
    */
   function processRequest()
   {
      if (httpRequest.readyState == 4)
      {
        if(httpRequest.status == 200)
        {
          var contentViewer = document.getElementById("contentViewer");
          contentViewer.innerHTML = httpRequest.responseText;
        }
        else
        {
            alert("Error loading page\n"+ httpRequest.status +":"+ httpRequest.statusText);
        }
      }
   }


  

   function next() {
	current++;
	document.controls.counter.value=current+" of "+pages.result[0].count;
	selectArticle(pages.links[current].id);
        
   }


   function previous() {
	current--;
	document.controls.counter.value=current+" of "+pages.result[0].count;
	selectArticle(pages.links[current].id);
   }


