var base_url = "http://www.downes.ca/";
var cgi_url = base_url + "cgi-bin/";




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
   deleteCookie("theme","/","www.downes.ca");
	location.reload();
}

function login_box() {		
  if (getCookie('person_id') == null) {
	document.write("[<A HREF='" + base_url + "login.cgi?refer=" +
	   document.location + "' class='Nav' target='_top'>Login</A>] " +
	   "[<A HREF='" + base_url + "login.cgi?action=register&refer=" +
	   document.location + "'  class='Nav' target='_top'>Register</A>]"); 
   } else if (getCookie('person_id') == "2") {
	document.write("[<A HREF='" + base_url + "login.cgi?refer=" +
	   document.location + "' class='Nav' target='_top'>Login</A>] " +
	   "[<A HREF='" + base_url + "login.cgi?action=register&refer=" +
	   document.location + "'  class='Nav' target='_top'>Register</A>]"); 
   } else {
	document.write("<b>" + getCookie('person_title') + "</b> " +
         "[<A HREF='" + cgi_url + "website/user.cgi' class='Nav' target='_top'>Options</a>] " +
	   "[<a href='" + base_url + "logout.cgi' class='Nav' target='_top'>Logout</A>]"); 
   }
}

function check_link_admin(project,db,key) {

	if (getCookie('userid') == "Downes") { edit_links(project,db,key); }
	return " ";
}

function check_page_admin(project,db,key) {

	
	if (getCookie('userid') == "Downes") { page_links(project,db,key); }
	return " ";
}

function edit_links(project,db,key) {

	document.write("[<a href='" + cgi_url + "website/admin.cgi?action=edit&project=" + project + "&db=" + db + "&key=" + key + "'>Edit</a>]");
	document.write("[<a href='" + cgi_url + "website/admin.cgi?action=delete&project=" + project + "&db=" + db + "&key=" + key + "'>Delete</a>]");

}

function page_links(project,db,key) {

	document.write("[<a href='" + cgi_url + "website/admin.cgi?action=reload&project=" + project + "&db=" + db + "&key=" + key + "'>Update</a>]");

}
