#!/usr/bin/perl
#print "Content-type: text/html\n\n";
#    gRSShopper 0.2  CChat  0.4  -- gRSShopper administration module
#    12 April 2011 - Stephen Downes
#    Updated 2013 03 04 to use File::Basename


#    Copyright (C) <2010>  <Stephen Downes, National Research Council Canada>
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.



# Forbid agents

if ($ENV{'HTTP_USER_AGENT'} =~ /bot|slurp|spider/) { 
  	print "Content-type: text/html; charset=utf-8\n";
	print "HTTP/1.1 403 Forbidden\n\n";
	print "403 Forbidden\n"; 
	exit; 
}


# Initialize gRSShopper Library

use File::Basename;
my $basepath = dirname(__FILE__);
require $basepath . "/grsshopper.pl";

our ($query,$vars) = &load_modules();
our $lastharvest = time;



#use Net::Twitter;
#use Net::Twitter::Search;
#use Scalar::Util 'blessed';



# print "Content-type: text/html; charset=utf-8\n\n";


# Initialize Session --------------------------------------------------------------

					

my $options = {}; bless $options;		# Initialize system variables
our $cache = {}; bless $cache;	
						
our ($Site,$dbh) = &get_site($query);		# Get Site Information
unless (defined $Site) { die "Site not defined."; }

our $Person = {}; bless $Person;		# Get User Information
&get_person($dbh,$query,$Person);		
my $person_id = $Person->{person_id};



# Analyze Request --------------------------------------------------------------------
unless (defined $vars->{chat_thread} && $vars->{chat_thread}) { &select_backchannel($dbh,$query); exit; }



# Actions ------------------------------------------------------------------------------
my $action = $vars->{action};
if ($action) {						# Perform Action, or


	for ($action) {
		/select/ && do { &select_backchannel($dbh,$query); last; 	};
		/display/ && do { &display($dbh,$query); last; 	};
		/display_master/ && do { &display($dbh,$query); last; 	};
		/form/ && do { show_form($dbh,$query); last;	};
		/update/ && do { &submit($dbh,$query); last; 	};
		/archives/ && do { &chat_archives($dbh,$query); last; 	};
	}


}



						
&screen($dbh,$query);

exit;



#-------------------------------------------------------------------------------
#
#           Functions 
#
#-------------------------------------------------------------------------------


# -------   Header ------------------------------------------------------------

sub header {

	my ($dbh,$query,$table,$format,$title) = @_;
	my $template = $Site->{lc($format) . "_header"} || lc($format) . "_header";

	return &get_template($dbh,$query,$template,$title);

}

# -------   Footer -----------------------------------------------------------

sub footer {

	my ($dbh,$query,$table,$format,$title) = @_;
	my $template = $Site->{lc($format) . "_footer"} || lc($format) . "_footer";
	return &get_template($dbh,$query,$template,$title);


}

# -------  Make Admin Links -------------------------------------------------------
#


sub make_admin_links {

	my ($input) = @_;



}


# -------   Display Comment (for big screen) --------------------------------------------
#
#   Displays itrem and updates queue
#

sub display {

	my ($dbh,$query,$table,$id_number,$format) = @_;
	my $vars = $query->Vars;
	return unless (defined $vars->{chat_thread} && $vars->{chat_thread});
	print "Content-type: text/html; charset=utf-8\n\n";
	my $stylesheet = $Site->{st_url}."css/cchat.css";

	# Get Thread Information
	my $thread = &db_get_record($dbh,"thread",{thread_id=>$vars->{chat_thread}});

	# Inactive Threads
	unless (&activated($dbh,$query,$thread)) {
		my $display_url = $Site->{st_cgi}."cchat.cgi";
		print qq|<html><head><title>Backchannel Inactive</title></head>
			<body><h1>Backchannel Inactive</h1>
			<p>Enter a new comment to activate; 
			reload this screen when content has been entered.
			<form method="post" action="$display_url">
			<input type="hidden" name="action" value="display">
			<input type="hidden" name="chat_thread" value="$vars->{chat_thread}">
			<input type="submit" value="   Reload   "/></form></p>
			</body></html>|;
		exit;
	}


	# Set Display Parameters
	my $refresh = $thread->{thread_refresh}; unless ($refresh) { $refresh=10; }		# Refresh frequency
	my $desc = $thread->{thread_description};								# Default Message
	my $activity_message .= " Updating every ".$refresh." seconds.";				# Activity Message
	my $timestamp = localtime(time);									# Timestamp
	my $textsize = $thread->{thread_textsize} || 36; $textsize.="pt";				# Text Size


	# Print Display Header
	print qq|<html><head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<link rel="stylesheet" type="text/css" href="$stylesheet" media="screen, projection, tv " />
		<title>CChat Display Screen</title>
		<meta http-equiv="refresh" content="$refresh">
		</head><body>
	|;


	# Poll for harvest update

	my $twittermsg = "";
	if ((time - 30) > $thread->{thread_twitterstatus}) {

		$twittermsg .= "Harvesting Twitter $thread->{thread_tag} <br>";
	
		$twittermsg .= &twitter_harvest($thread);
	
		&db_update($dbh,"thread", {thread_twitterstatus=>time}, $thread->{thread_id});
	}

	
	# Get Next Chat Message	
	my $current = $thread->{thread_current}; unless ($current) { $current=1; }		# Current chat item
	my $updated = $thread->{thread_updated}; unless ($updated) { $updated=1; }		# Thread last updated

	my $chat;													# If refresh time has elapsed, 	
	if (time - $refresh > $updated) {									# try to find the next chat item
		my $sql = qq|SELECT * FROM chat WHERE chat_thread = ? AND chat_id > ? ORDER BY chat_id LIMIT 1|;
		my $sth = $dbh->prepare($sql);
		$sth->execute($thread->{thread_id},$current);
		$chat = $sth->fetchrow_hashref();
	}

	if ($chat->{chat_id}) {										#  Next chat item found, update thread
		$current = $chat->{chat_id};
		&db_update($dbh,"thread", {thread_current=>$current,thread_updated=>time}, $thread->{thread_id});
		
	} else {												# No next item, just get the old chat item
		$chat = &db_get_record($dbh,"chat",{chat_id=>$current});
	}

	if ($chat->{chat_description}) { $desc = $chat->{chat_description}; }

	# Display Page
	my $tagnote; if ($thread->{thread_tag}) { $tagnote .= "Tag: <b>$thread->{thread_tag}</b>"; }
	if ($vars->{status}) { $vars->{status} = qq|<p class="notice">$vars->{status}</p>|; }


	print qq|
		Discussion Thread: $thread->{thread_id} $thread->{thread_title}. $tagnote<br/> 
		$activity_message
		<p style="text-align:left; font: $textsize Verdana,Arial, sans-serif;">
		$desc
		</p>
		<p style="text-align:right">
		$chat->{chat_signature} ($chat->{chat_id})<br/>
		$timestamp
		</p>
	|;


	exit;

}

sub activated {

	my ($dbh,$query,$thread) = @_;

	my $latency = time - $thread->{thread_srefresh}; 
	my $timeout = 1800;								# Threads time out at 1800 seconds (1/2 hour)

	if ($latency < $timeout) {							# Thread is active
		unless ($thread->{thread_active} eq "yes") {				#     recently!
			&db_update($dbh,"thread", 
				{thread_active=>'yes'}, $thread->{thread_id});	#     so we update it
		}
		return 1;
	} else {										# Thread is no longer active
		unless ($thread->{thread_active} eq "no") {				#     recently!
			&db_update($dbh,"thread", 
				{thread_active=>'no'}, $thread->{thread_id});	#     so we update it
		}
		return 0;
	}
	return 0;
}

# -------   Update Record ------------------------------------------------------

sub submit {

	my ($dbh,$query,$table,$id_number) = @_;
	my $vars = $query->Vars;
	
	my $table = "chat";
	my $format = $vars->{format};

	return unless (defined $vars->{chat_thread} && $vars->{chat_thread});
	&error($dbh,$query,"","Database not ready") unless ($dbh);


	while (my ($vx,$vy) = each %$vars) { &clean_chat(\$vars->{$vx}); }			# sanitize

	# Get Thread Information
	return unless (defined $vars->{chat_thread} && $vars->{chat_thread});
	my $thread = &db_get_record($dbh,"thread",{thread_id=>$vars->{chat_thread}});


					#Admin Functions
#	print "Content-type: text/html; charset=utf-8\n\n";



	if (($Person->{person_id} eq $thread->{thread_creator}) || ($Person->{person_status} eq "admin")) {


		# Tag
		if ($vars->{chat_description} =~ s/^tag:(.*?)/$1/) {
			$vars->{chat_description} =~ s/^ //g;
			if (&db_update($dbh,"thread", {thread_tag=>$vars->{chat_description}}, $thread->{thread_id})) {
				$vars->{status}="success";$vars->{msg} .= "Thread Tag: $vars->{chat_description}"; }
			else { $vars->{status}="fail";$vars->{msg} .= "Thread Activity update failed"; }
			&show_form($dbh,$query);
		}


		# Textsize
		if ($vars->{chat_description} =~ s/^textsize:(.*?)/$1/) {
			$vars->{chat_description} =~ s/^ //g;
			if (&db_update($dbh,"thread", {thread_textsize=>$vars->{chat_description}}, $thread->{thread_id})) {
				$vars->{status}="success";$vars->{msg} .= "Thread Textsize: $vars->{chat_description}"; }
			else { $vars->{status}="fail";$vars->{msg} .= "Thread Textsize update failed"; }
			&show_form($dbh,$query);
		}
	
	
		# Refresh
		if ($vars->{chat_description} =~ s/^refresh:(.*?)/$1/) {
			$vars->{chat_description} =~ s/^ //g;
			if ($vars->{chat_description} < 10) {
				$vars->{chat_description} = 10;
				$vars->{msg} .= "Cannot set refresh less than 10 seconds"; 
			}
			if (&db_update($dbh,"thread", {thread_refresh=>$vars->{chat_description}}, $thread->{thread_id})) {
				$vars->{status}="success";$vars->{msg} .= "Thread Refresh: $vars->{chat_description}"; }
			else { $vars->{status}="fail";$vars->{msg} .= "Thread Refresh update failed"; }
			&show_form($dbh,$query);
		}
	

		# Help
		if ($vars->{chat_description} =~ s/^admin:(.*?)/$1/) {
			$vars->{chat_description} =~ s/^ //g;
			if ($vars->{chat_description} eq "help") {

				$vars->{help} = qq|Admin commands:
tag:xxx        -- set the tag for this thread
textsize:xx    -- display text size xx pt
refresh:xx     -- display a new chat comment every xx seconds
admin:help     -- display this help screen
admin:panel    -- display the admin panel
Just ckick [Submit] to clear this form
|;
			$vars->{status}="success";
			}
		&show_form($dbh,$query);
		}
	

		# Clear
		if ($vars->{chat_description} =~ s/^Admin commands:(.*?)/$1/) {
			$vars->{status}="success";
			&show_form($dbh,$query);
		}
	}



					# Submit Data


	# Create Record

	$vars->{chat_crdate} = time;
	$vars->{chat_creator} = $Person->{person_id};
	$vars->{chat_crip} = $ENV{'REMOTE_ADDR'};

	my $id_number = &db_insert($dbh,$query,$table,$vars);
	if ($id_number) {	$vars->{msg} .= "Comment submitted. ";$vars->{status}="success"; }
	else { $vars->{msg} .= "Error, comment not created.";$vars->{status}="fail"; }
	&show_form($dbh,$query,$id_number);
	return $id_number;

}

# -------   Clean chat --------------------------------------------------------

sub clean_chat {

	my ($txt_ptr) = @_;

	$$txt_ptr =~ s/#!//g;					# No programs!
	$$txt_ptr =~ s/'/&apos;/g;				# No sql injection!
	$$txt_ptr =~ s/<(\/|)(a|e|t|script)(.*?)>//sig;	# No links, embeds, tables, scripts
	$$txt_ptr =~ s/(\r|\n)//mgi;				# Kill returns
	$$txt_ptr =~ s/(viagra|areaseo|carisoprodol|holdem|phentermine|ultram| pills| loans|tramadol|cialis|penis|handbag| shit | cock | fuck | fucker | cunt | motherfucker | ass )/*bleep*/gi;

}

# -------   Show Form --------------------------------------------------------

sub show_form {

	my ($dbh,$query,$new_id) = @_;
	my $vars = $query->Vars;
	my $pname = $Person->{person_name} || $Person->{person_title};
	
#	&login_required($dbh,$query);

	# JSON Return for API
	if ($vars->{format} eq "json") {
		print "Content-type: application/json\n\n";
		print qq|{
    "cchat": {
        "id": "$new_id",
        "status": "$vars->{status}",
        "message": "$vars->{msg}"
    }
}|;
		exit;
	}

	print "Content-type: text/html; charset=utf-8\n\n";	

	my $table = "chat";
	my $thread = &db_get_record($dbh,"thread",{thread_id=>$vars->{chat_thread}});
	unless (defined $vars->{chat_thread} && $vars->{chat_thread}) {
		print qq|<h2>Backchannel not defined</h2><p>No thread number provided</p>|;
		exit;
	}
	unless ($thread) {
		print qq|<h2>Backchannel not defined</h2><p>You asked for backchannel number
			$vars->{chat_thread} but it doesn't exist|;
		exit;
	}

						# Set record ID number, value

	unless ($dbh) { &error($dbh,$query,"","Database not ready") }


						# Activate Thread
	my $activetime = time;
	&db_update($dbh,"thread", {thread_srefresh=>$activetime}, $thread->{thread_id});

						# Print Titles

	if (($Person->{person_id} eq $thread->{thread_creator}) || ($Person->{person_status} eq "admin")) {
		$vars->{msg} .= " Enter admin:help for options";
	}

	unless ($vars->{msg}) { $vars->{msg} = "Enter your comment below. "; }



						# Print Form
	my $chat_url = $Site->{st_cgi}."cchat.cgi";
	my $archive_url = $Site->{st_cgi}."cchat.cgi?action=archives&chat_thread=$vars->{chat_thread}";
	my $stylesheet = $Site->{st_url}."/css/cchat.css";
	print qq|
		<html>
		<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<link rel="stylesheet" type="text/css" 
			href="$stylesheet" 
			media="screen, projection, tv " />
		<title>Submission Form</title>
  		<script type="text/javascript" src="http://www.downes.ca/downes.js"></script>
		</head>
		<body>
		<form method="post" action="$Site->{script}">
		<input type="hidden" name="action" value="update">
		<input type="hidden" name="chat_thread" value="$vars->{chat_thread}">
		<table border=1 cellpadding=2 cellspacing=0>\n
		<tr><td colspan="4">$vars->{msg}<br/>
		<textarea name="chat_description" cols="80" rows="5">$vars->{help}</textarea></td>
		<tr>
		<td>Signature</td>
		<td colspan="3"><input type="text" value="$pname" name="chat_signature" size="50"></td>
		<tr><td colspan="4">
		<input type="submit" name="button" value="Submit"> [<a href="$chat_url" target="_top">Select Another Backchannel</a>]
		[<a href="$archive_url" target="_top">Backchannel archives</a>]
		</table></form>\n
		</body>
		</html>
	|;
	exit;


}


# -------   Screen --------------------------------------------------------


sub screen {

	print "Content-type: text/html; charset=utf-8\n\n";
	my $stylesheet = $Site->{st_url} . "css/cchat.css";
	my $display_url = $Site->{st_cgi}."cchat.cgi?action=display&chat_thread=".$vars->{chat_thread};
	my $form_url = $Site->{st_cgi}."cchat.cgi?action=form&chat_thread=".$vars->{chat_thread};

#print "$display_url <p>";

	print qq|
		<html>
		<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<link rel="stylesheet" type="text/css" 
			href="$stylesheet" 
			media="screen, projection, tv " />
		<title>CChat - by Stephen Downes</title>
		</head>
		<iframe src ="$display_url" 
			width="100%" height="65%">
  			<p>Your browser does not support iframes.</p>
		</iframe>
		<iframe src ="$form_url" 
			width="100%" height="30%">
  			<p>Your browser does not support iframes.</p>
		</iframe>
	|;
	exit;
}

# -------   Select Backchannel --------------------------------------------------------

sub select_backchannel {

	my ($dbh,$query,$table,$id_number) = @_;


	my $stylesheet = $Site->{st_url} . "css/cchat.css";
	my $javascript = $Site->{st_url} . "js/downes.js";
	my $backchannel = $Site->{st_url} . "create_backchannel.htm";

	print "Content-type: text/html; charset=utf-8\n\n";

	print &header($dbh,$query,"thread","page","Select Backchannel");



	my $page_text = qq|<h2>Backchannels</h2>
		<p>A backchannel is a real-time online chat between participants 
            in an event or conference. To participate in a backchannel, 
            click on the topic of your choice.</p>|;



								# Display My Backchannels

	if (($Person->{person_status} eq "admin") || ($Person->{person_status} eq "registered")) {

		my $my_text="";
		my $ary_ref = &find_records($dbh,{table=>"thread",thread_creator=>$Person->{person_id}});
		foreach my $t (@$ary_ref) { 
			my $ref = &db_get_record($dbh,"thread",{thread_id=>$t});
			my $url = $Site->{st_cgi}."cchat.cgi?chat_thread=$t";
			$my_text .= qq|<li> <a href="$url">$ref->{thread_title}</a>|;
			if ($ref->{thread_active} eq "yes") { $my_text .= qq| <span style="color:#008800;">Active!</span>|; }
			$my_text .= "</li>";
		}
		if ($my_text) { 
			$my_text = qq|<p><b>My Backchannels</b></p><p>When you create a backchannel,
                      it shows up here. Make your backchannel <i>active</i> by entering it.
                      Active backchannels may be viewed and entered by other users.</p><ul>|.$my_text."</ul>";
            }
		$page_text .= $my_text;

	}

								# Display Active Backchannels


	$page_text .= qq|<p><b>Active Backchannels</b></p><p>Active backchannels are live
                      chat discussions that are currently taking place. Enter a backchannel
                      by clicking on the backchannel topic name.</p>|;
	my $ac_text="";
	my $ary_ref = &find_records($dbh,{table=>"thread",thread_active=>"yes"});
	foreach my $t (@$ary_ref) { 
		my $ref = &db_get_record($dbh,"thread",{thread_id=>$t});
		my $url = $Site->{st_cgi}."cchat.cgi?chat_thread=$t";
		$ac_text .= qq|<li> <a href="$url">$ref->{thread_title}</a></li>|;
	}
	if ($ac_text) { 
		$ac_text = "<ul>\n".$ac_text."\n</ul>\n"; 
		if (($Person->{person_status} eq "admin") || ($Person->{person_status} eq "registered")) {
			$ac_text .= qq|<p>[<a href="$backchannel">Create a new backchannel?</a>]</p>|;	
		}
	} else { 
		$ac_text = "<p>No active backchannels.</p>"; 
		if (($Person->{person_status} eq "admin") || ($Person->{person_status} eq "registered")) {
			$ac_text .= qq|<p>Why not <a href="$backchannel">create a new backchannel?</a></p>|;	
		}
	}
	$page_text .= $ac_text;


								# Administer Backchannels

	if ($Person->{person_status} eq "admin") {
		$page_text .=  qq|<p>[<a href="|.$Site->{st_cgi}.qq|admin.cgi?db=thread&action=list">Aminister Backchannels</a>]</p>|;
	}


	print $page_text;
	print &footer($dbh,$query,"thread","page","Select Backchannel");


}

# -------   Twitter --------------------------------------------------------

sub search_twitter {

	my ($dbh,$query,$term) = @_;
	my $vars = $query->Vars;


	my $nt = Net::Twitter->new(traits => [qw/API::Search/]);
	eval {
	   # Parameters: q, callback, lang, rpp, page, since_id, geocode, show_user
	   my $r = $nt->search({
	      q=>$term,
	      rpp=>50,
	      since=>"2010-03-21"
	   });
	   for my $status ( @{$r->{results}} ) {
	
		# No injections from Twitter, thank you
		while (my ($vkey,$vval) = each %$status) {
			$vars->{$vkey} =~ s/#!//g;					# No programs!
			$vars->{$vkey} =~ s/'/&apos;/g;				# No sql injection!
			$vars->{$vkey} =~ s/<(\/|)(a|e|t|script)(.*?)>//sig;	# No links, embeds, tables, scripts
			$vars->{$vkey} =~ s/(\r|\n)//mgi;				# Kill returns
		}

		unless (&db_locate($dbh,"chat",{chat_description => $status->{text}})) {

			# Create Record
	
			$vars->{chat_crdate} = time;
			$vars->{chat_creator} = "1";
			$vars->{chat_crip} = "127.0.0.1";
			$vars->{chat_signature} = "\@$status->{from_user}";
			$vars->{chat_description} = "$status->{text}";
			my $id_number = &db_insert($dbh,$query,"chat",$vars);
		}
	   }
	};
	if ( my $err = $@ ) {
		$vars->{msg} .= "Twitter update error  $err->code $err->message."; 
		return;
	#   die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

	}

	return;


#   warn "<acronym title="HyperText Transfer Protocol">HTTP</acronym> Response Code: ", $err->code, "\n",
#   "<acronym title="HyperText Transfer Protocol">HTTP</acronym> Message......: ", $err->message, "\n",
#   "Twitter error.....: ", $err->error, "\n";



}

sub chat_archives {

	my ($dbh,$query,$msg) = @_;
	my $vars = $query->Vars;
	my $cth = $vars->{chat_thread};

	my $thread = &db_get_record($dbh,"thread",{thread_id=>$vars->{chat_thread}});	
	print "Content-type: text/html; charset=utf-8\n\n";

	my $desc; if ($vars->{opt} eq "reverse") { $desc = ""; } else { $desc = " DESC"; }
	my $eesc; if ($vars->{opt} eq "reverse") { $eesc = ""; } else { $eesc = "&opt=reverse"; }
	my $sql = "SELECT * FROM chat WHERE chat_thread='$cth' ORDER BY chat_crdate$desc";
	my $sth = $dbh->prepare($sql) || print "Database Error<br/>";
	$sth->execute();

	my $page_text = "";
	while (my $s = $sth -> fetchrow_hashref()) {
	
		my $cdsk_url = $Site->{st_cgi}."page.cgi?chat=".$s->{chat_id};
		if ($vars->{format} eq "xml") {
			my $ctime = &rfc822_date($s->{chat_crdate});
			$page_text .= qq|
<item>
   <title>$s->{chat_signature}</title>
   <link>$cdsk_url</link>
   <description><![CDATA[$s->{chat_description} 
		<a href="$cdsk_url">Thread</a>]]></description>
   <pubDate>$ctime</pubDate>
   <guid>$cdsk_url</guid>     
</item>
|;
		} else {
			my $ctime = &nice_date($s->{chat_crdate});
			$page_text .= qq|<tr><td>$ctime</td><td>$s->{chat_signature}</td><td>$s->{chat_description}</td></tr>|;
		}
	}


	if ($vars->{format} eq "xml") {
		my $nowctime = &rfc822_date(time);
		my $cchan_url = $Site->{st_cgi}."cchat.cgi?chat_thread=$thread->{thread_id}";
		print qq|<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
   <channel>
      <title>$thread->{thread_title}</title>
      <link>$cchan_url</link>
      <description>$thread->{thread_description}</description>
      <language>en-us</language>
      <pubDate>$nowctime</pubDate>
      <lastBuildDate>$nowctime</lastBuildDate>
      <docs>http://blogs.law.harvard.edu/tech/rss</docs>
      <generator>Edu_RSS</generator>
      <managingEditor>stephen\@downes.ca (Stephen Downes)</managingEditor>
      <webMaster>stephen\@downes.ca (Stephen Downes)</webMaster>
$page_text
   </channel>
</rss>
	|;


	} else {

		my $stylesheet = $Site->{st_url} . "css/cchat.css";

		print qq|
		<html>
		<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<link rel="alternate" type="application/rss+xml" title="RSS" 
			$Site->{st_cgi}cchat.cgi?chat_thread=$thread->{thread_id}&action=archives&format=xml" />
		<link rel="stylesheet" type="text/css" 
			href="$stylesheet" 
			media="screen, projection, tv " />
		<title>CChat - by Stephen Downes</title>
		</head>
		<body>
		<h1>$thread->{thread_title}<br />Archives</h1>
		<script language="Javascript">login_box();</script>
		<p>[<a href="$Site->{st_cgi}cchat.cgi?chat_thread=$thread->{thread_id}">Return to Thread $vars->{chat_thread}</a>]
[<a href="$Site->{st_cgi}cchat.cgi?chat_thread=$thread->{thread_id}&action=archives$eesc">Reverse Order</a>]
[<a href="$Site->{st_cgi}cchat.cgi?chat_thread=$thread->{thread_id}&action=archives&format=xml">XML</a>]</p>
		<table>
		$page_text
		</table>
		</body></html>
		|;
	}
	exit;

}

sub twitter_harvest {

	my ($thread) = @_;


	my $returnmsg = "";
	my $tag = $thread->{thread_tag} || "altc2013";

	&error($dbh,"","","Twitter posting requires values for consumer key, consumer secret, token and token secret")
		unless ($Site->{tw_cckey} && $Site->{tw_csecret} && $Site->{tw_token} && $Site->{tw_tsecret});
	my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
		consumer_key        => $Site->{tw_cckey},
		consumer_secret     => $Site->{tw_csecret},
		access_token        => $Site->{tw_token},
		access_token_secret => $Site->{tw_tsecret},
		ssl                 => 1,  ## enable SSL! ##
	);
	
# my $result = $nt->update('Hello, world!');

my $r = "";
  eval { $r = $nt->search($tag); };
  if ( my $err = $@ ) {
   

      print "HTTP Response Code: ", $err->code, "\n",
           "HTTP Message......: ", $err->message, "\n",
           "Twitter error.....: ", $err->error, "\n";
  }	

	while (my($rx,$ry) = each %$r) { 
		if ($rx eq "search_metadata") {
	#		while (my($mrx,$mry) = each %$ry) { print "$mrx = $mry <br>"; }
		}
		
		elsif ($rx eq "statuses") {
			foreach my $status (@$ry) { 
				next if ($status->{text} =~ /^RT/);		# Skip retweets (the bane of twitter)
				my $item;my $chat; my $userstr = "";
				while (my($srx,$sry) = each %$status) { 
					if ($srx eq "user") {			# Get user info
						$item->{screen_name} = $sry->{screen_name};
						$item->{name} = $sry->{name};
						$item->{profile_image_url_https} = $sry->{profile_image_url_https};
					}
					
				}
				my ($created,$garbage) = split / \+/,$status->{created_at};
				$status->{text} =~ s/\x{201c}/ /g;	# "
				$status->{text} =~ s/\x{201d}/ /g;	# "
				$chat->{chat_link} = "https://twitter.com/".$item->{screen_name}."/status/".$status->{id};
				$chat->{chat_title} = $status->{text};
				$status->{text} =~ s/#(.*?)( |:)/<a href="https:\/\/twitter.com\/search?q=%23$1&src=hash"  target="_blank">#$1<\/a> /g;
				$status->{text} =~ s/http:(.*?)("|”|$| )/<a href="http:$1" target="_blank">http:$1<\/a> /g;		
				$status->{text} =~ s/\@(.*?)( |:)/<a href="https:\/\/twitter.com\/$1" target="_blank">\@$1<\/a> /g;				
				$chat->{chat_description} = qq| 
					<img src="$item->{profile_image_url_https}" align="left" hspace="10">
					<a href="$chat->{chat_link}">\@|.$item->{screen_name}.qq|</a>: |.
					$status->{text} . "";
				$chat->{chat_signature} = "Twitter";
				$chat->{chat_crdate} = time;
				$chat->{chat_thread} = $thread->{thread_id};
				$chat->{chat_creator} = $Person->{person_id};
				$chat->{chat_crip} = $ENV{'REMOTE_ADDR'};

				if (my $cid = &db_locate($dbh,"chat",{chat_link => $chat->{chat_link}})) { 
					# Nothing
				} else {
					my $id_number = &db_insert($dbh,$query,"chat",$chat);
				}
			
			}




	#if ($id_number) {	$vars->{msg} .= "Comment submitted. ";$vars->{status}="success"; }
	#else { $vars->{msg} .= "Error, comment not created.";$vars->{status}="fail"; }
	#&show_form($dbh,$query,$id_number);
	#return $id_number;
	#		&save_item($feed,$item);
		}
	}	

	return $returnmsg;
}
1;