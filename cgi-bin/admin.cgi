#!/usr/bin/env perl

#    gRSShopper 0.7  Admin  0.62  -- gRSShopper administration module
#    05 June 2017 - Stephen Downes

#    Copyright (C) <2011>  <Stephen Downes, National Research Council Canada>
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

#-------------------------------------------------------------------------------
#
#	    gRSShopper
#           Admin Functions
#
#-------------------------------------------------------------------------------
  print "Content-type: text/html\n\n";






# Diagnostics

	our $diag = 0;
	if ($diag>0) { print "Content-type: text/html\n\n"; }


# Forbid bots

	die "HTTP/1.1 403 Forbidden\n\n403 Forbidden\n" if ($ENV{'HTTP_USER_AGENT'} =~ /bot|slurp|spider/);


# Load gRSShopper

	use File::Basename;
	use CGI::Carp qw(fatalsToBrowser);
	my $dirname = dirname(__FILE__);
	require $dirname . "/grsshopper.pl";



# Load modules

	our ($query,$vars) = &load_modules("admin");





# Load Site

	our ($Site,$dbh) = &get_site("admin");
	if ($vars->{context} eq "cron") { $Site->{context} = "cron"; }



# Get Person  (still need to make this an object)

	our $Person = {}; bless $Person;
	&get_person($dbh,$query,$Person);
	my $person_id = $Person->{person_id};


# Initialize system variables

	my $options = {}; bless $options;
	our $cache = {}; bless $cache;


# Option to call initialize functions

	if ($vars->{action} eq "initialize") {  $Site->__initialize("command"); }
    print "Content-type: text/html\n\n";
    while (my($fx,$fy) = each %$vars) { print "$fx = $fy<br>";}   #{%}

# Restrict to Admin

	if ($vars->{context} eq "cron") { &cron_tasks($dbh,$query,$ARGV); } else { &admin_only(); }




# To fix

	if ($vars->{api}) { print "ok"; exit; }

	if ($vars->{code}) { 						# Capture Facebook code submit
		facebook_access_code_submit();				# I'll make this a proper API capture at some point
	}

	 #    use Image::Thumbnail 0.65;

#print "Content-type: text/html\n\n";
	# $sth = $dbh->prepare("SELECT * FROM author");
	# $sth->execute();
  # while (my $author = $sth -> fetchrow_hashref()) {
  #    if ($author->{author_name} eq "") {
	#			print "Author: ".$author->{author_name}."-".$author->{author_title}."(".$author->{author_id}.")<br>";
			#	$dbh->do("DELETE FROM author WHERE author_id=".$author->{author_id});
	#		}
  #    if ($author->{author_name} =~ /=/) {
	#			print "Author: ".$author->{author_name}."-".$author->{author_name}."(".$author->{author_id}.")<br>";
			#	$dbh->do("DELETE FROM author WHERE author_id=".$author->{author_id});
	#		}
  # }

#my $psql = "SELECT * FROM product";
#my $psth = $dbh->prepare($psql);
#$psth->execute();
#while (my $product = $psth -> fetchrow_hashref()) {

#	my $type = $product->{product_genre};
	#&db_update($dbh,"post",{post_facebook => 1},$post->{post_id});
	#if ($type) {
		#&db_update($dbh,"product",{product_type => $type},$product->{product_id});
	#}
#}

#	my $graphid = &db_insert($dbh,$query,"graph",{
#		graph_tableone=>'publication', graph_idone=>$pub->{publication_id}, graph_urlone=>'',
#		graph_tabletwo=>'post', graph_idtwo=>$pub->{publication_post},graph_urltwo=>'',
#		graph_creator=>$Person->{person_id}, graph_crdate=>time, graph_type=>'published', graph_typeval=>''});
# print "graph $graphic $pub->{publication_title} -- $pub->{publication_id} - $pub->{publication_post} <br>";

#}

# $dbh->do("DELETE FROM project WHERE author_name='theartguy'");
#  $dbh->do("ALTER TABLE course MODIFY course_title varchar(256)");
#  $dbh->do("ALTER TABLE course MODIFY course_url varchar(256)");
#&db_drop_table($dbh,"element");
#&db_create_table($dbh,"form",$data);
#$sth = $dbh->prepare("TRUNCATE TABLE provider");
#$sth->execute();
#$sth = $dbh->prepare("TRUNCATE TABLE course");
#$sth->execute();

# Analyze Request --------------------------------------------------------------------

# Determine Action ( assumes admin.cgi?action=$action&id=$id )

	my $action = $vars->{action};
	my $id = $vars->{id};



# Determine Request Table, ID number ( assumes admin.cgi?$table=$id and not performing action other than list, edit or delete)

	my @tables = &db_tables($dbh);
	foreach $t (@tables) {

		if ((!$action || $action =~ /^edit$/i || $action =~ /^list$/i || $action =~ /^Delete$/i || $action =~ /^extract_nouns$/i ) && $vars->{$t}) {
			$table = $t;
			$id = $vars->{$t};
			$vars->{id} = $id;
			last;
		}
	}


# Direct Request Table, ID number, and list requests ( required for most actions, assumes admin.cgi?db=$table&id=$id or admin.cgi?table=$table&id=$id , no $id for action=list )

if ($vars->{db} || $vars->{table}) {
	$table = $vars->{table} || $vars->{db};
	if ($vars->{id}) {
		$id = $vars->{id};
	} else {
		unless ($action) {
			$action = "list";
		}
	}
}

# Determine Output Format  ( assumes admin.cgi?format=$format )

if ($vars->{format}) { 	$format = $vars->{format};  }
if ($action eq "list") { $format = "list"; }
$format ||= "html";		# Default to HTML




# Actions ------------------------------------------------------------------------------

# Perform Action, or





if ($action) {

	for ($action) {
														# Main admin menu nav

		/general/ && do { &admin_general($dbh,$query); last;			};	# 	- General Menu
		/harvester/ && do { &admin_harvester($dbh,$query); last;		};	# 	- Harvester Menu
		/users/ && do { &admin_users($dbh,$query); last;			};	# 	- Users Menu
		/newsletters/ && do { &admin_newsletters($dbh,$query); last;	};		#	- Newsletters Menu
		/database/ && do { &admin_database($dbh,$query); last;		};		#	- Database Menu
		/meetings/ && do { &admin_meetings($dbh,$query); last;		};		#	- Meetings Menu
		/logs/ && do { &admin_logs($dbh,$query); last;		};			#	- Logs Menu
		/accounts/ && do { &admin_accounts($dbh,$query); last;		};		#	- Accounts Menu
		/permissions/ && do { &admin_permissions($dbh,$query); last;		};	#	- Permissions Menu




														# Editing Functions

		/list/ && do { &admin_list_records($dbh,$query,$table); last;		};		#	- List records
		/edit/i && do { &edit_record($dbh,$query,$table,$id); last; 	};		#	- Edit Record - Show the Editing form
		/update/ && do { &update_record($dbh,$query,$table,$id);
			&edit_record($dbh,$query,$table, $id_number);last; };		# 	- Edit Record - Update with input data
		/Delete/i && do	{ &record_delete($dbh,$query,$table,$id);last; };		#	- Delete Record
		/Spam/i && do { &record_delete($dbh,$query,$table,$id);  last; };		#	- Delete Record and log creator IP to Spam
		/multi/i && do { &admin_multi($dbh,$query); last;		};		#	- Multi-Delete Record (FIXME needs work)



														# Feed Functions

		/approve/i && do { &record_approve($dbh,$query,$table,$id); last; };		#	- Approve Feed
		/retire|reject/i && do { &record_retire($dbh,$query,$table,$id); last; };	#	- Reject / Retire Feed


														# Site Configuration

		/config/ && do { &admin_update_config($dbh,$query); last;	};		#	- Update config data
		/export_table/ && do { &admin_db_export($dbh,$query); last;	};		#	- export a table
		/db_pack/ && do {&admin_db_pack($dbh,$query); last;		};		#	- Make a new pack
		/db_add_column/ && do { my $msg = &db_add_column($vars->{stable},$vars->{col});
			&showcolumns($dbh,$query,$msg); last; };				#	- Add new column to a table
		/removecolumnwarn/ && do { &removecolumnwarn($dbh,$query); last; };		#	- Remove column - warn user
		/removecolumndo/ && do { &removecolumndo($dbh,$query); last; };			#	- Remove column - remove it



														# Newsletter and Page Functions

		/publish/ && do {
				if ($table eq "badge"){ &publish_badge($dbh,$query,$id,"verbose"); last;}
				else { &publish_page($dbh,$query,$vars->{page},"verbose"); last; } };

		/rollup/ && do { &news_rollup($dbh,$query); last;			};	#	- Show posts allocated to future newsletters
		/autosub/ && do { &autosubscribe_all($dbh,$query); last;   };			#	- Auto-subscribe all users to newsletter
		/autounsub/ && do { &autounsubscribe_all($dbh,$query); last; };			#	- Auto-unsubscribe all users from newsletter
		/send_nl/ && do { &send_nl($dbh,$query); last;	};				#	- Send newsletter to email subscribers


														# Cron Tasks (FIXME make a separate file? )

		/rotate/ && do { &rotate_hit_counters($dbh,$query,"post"); last;};		#	- Reset daily hits counter to '0'

		/remove_key/ && do { &remove_key($dbh,$query,$table,$id);
			&edit_record($dbh,$query,$table,$id); last;};

												#		# Database Functions

		/backup_db/ && do { &admin_db_backup($vars->{backup_table},"verbose"); last; };	#	- Back up database
		/showcolumns/ && do { &showcolumns($dbh,$query); last; };			#	- Show the columns in a table
		/add_table/ && do { admin_db_add_table($vars->{add_table}); last; };		#	- Add table
		/drop_table/ && do { admin_db_drop_table($vars->{drop_table}); last; };		#	- Drop table

		/fixmesubs/ && do { &fixmesubs($dbh,$query,$table); last;		};

                       # API Functions

    /access_api/ && do { &access_api($dbh,$query); last; };

		/export_users/ && do { &export_user_list($dbh,$query); last;			};
		/import/ && do { &import($dbh,$query,$table); last;		};
		/remove_all/ && do { &delete_all_users($dbh,$query); last; };


		/youtubepost/ && do { &parse_youtube($dbh,$query); last; };
		/autopost/ && do { &autopost($dbh,$query); last; };
		/postedit/ && do { &postedit($dbh,$query); last; };

		/eduser/ && do { &admin_users_edit($dbh,$query); last;			};
		/subs/ && do { &edit_subs($dbh,$query); last;			};


		/extract_nouns/ && do { &extract_nouns($dbh,$query,$table,$id); last; };

		/make_icon/ && do { &auto_make_icon($table,$id);
				&edit_record($dbh,$query,$table,$id); last;};
		/logview/ && do { &log_view($dbh,$query); last; };
		/logreset/ && do { &log_reset($dbh,$query); last; };
		/reindex_topics/ && do { &reindex_topics($dbh,$query,$id); last; };
		/refield/ && do { &refield($dbh,$query); last; };
		/recache/ && do { &recache($dbh,$query); last; };
		/reindex/ && do { &reindex_matches($dbh,$query,$table,$id); };

		/count/ && do { &count_feed($dbh,$query); last; };

		/cache_clear/ && do { print "Content-type: text/html\n\n"; &cache_clear($dbh,$query); last; };
		#/stats/ && do { &calculate_stats($dbh,$query); last;  };
		/graph/ && do { &make_graph($dbh,$query); last;  };
		/sendmsg/ && do { &admin_users_send_message($dbh,$query); last; };
		/moderate_meeting/ && do { &moderate_meeting($dbh,$query); last;			};	# 	- General
		/test_rest/ && do { api_send_rest($dbh,$query); last; };
		/cstats/ && do { &calculate_cstats($dbh,$query); last; };

	}


# Output Record, or

} elsif ($table) {					# Default Data Output

	&output_record($dbh,$query,$table,$id,$format);

} else {

# Show Admin Menu

	&admin_general($dbh,$query);
}



# &db_cache_write($dbh);				# Write cache records to database after page is printed

if ($dbh) { $dbh->disconnect; }			# Close Database and Exit
exit;




#---------------------------------------------------------------------------------------------
#
#                 Functions
#
#---------------------------------------------------------------------------------------------


sub calculate_cstats {

	my ($dbh,$query) = @_;
	print "Content-type: text/plain\n\n";
	#print "Stats<p>";
	my $vars = $query->Vars;
	my $table = $vars->{table} || "link";
	my $search = $vars->{search};
	my $type = $vars->{type};
print "Search : $search <p>";
	my $lcr=$table."_crdate"; my $lid = $table."_id",my $lti = $table."_title"; my $lde = $table."_description";
	my $where;
	if ($search) {
		$where = "WHERE ($lti LIKE '%".$search."%' OR $lde  LIKE '%".$search."%')";
		if ($table eq "post") { $where .= " AND (post_type='link' OR post_type = 'article')"; }
	}

	if ($type) {
		if ($where) { $where .= " AND "; } else { $where .= " WHERE "; }
		if ($table eq "post") { $where .= "(post_type='$type')"; }
	}
print "Where : $where <p>";
	my $sql;

	if ($table eq "subscription") { $sql = qq|SELECT $lid,$lcr FROM $table $where|; }
	else { $sql = qq|SELECT $lid,$lcr,$lti FROM $table $where|; }
	#print $sql."<p>";


	print $sql."\n\n";
	my $sth = $dbh -> prepare($sql);
	$sth -> execute();
	my $linklist = (); my $linktitle = (); my $total=0;



	while (my $link = $sth -> fetchrow_hashref()) {
		if ($table eq "subscription") { $link->{$lti} = $link->{$lid}; }

#print $link->{$lcr},"<br>";
		unless ($linktitle->{$link->{$lti}}) {
			$linktitle->{$link->{$lti}} = $link->{$lcr};
			my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($link->{$lcr});
			$year +=1900; $mon+=1;
			if ($mon < 10) { $mon = "0".$mon; }
			if ($mday < 10) { $mday = "0".$mday; }
			my $ldate = $year."-".$mon."-".$mday;

			if ($linklist->{$ldate}) { $linklist->{$ldate}->{daily}++;  }
			else { $linklist->{$ldate}->{daily} = 1; }



		}

	}

	print "date,daily,total\n";
	foreach my $name (sort keys %$linklist) {
		$total += $linklist->{$name}->{daily};
		print $name.",".$linklist->{$name}->{daily}.",".$total."\n";



	}

}

#%"

# -----------------------------------   Admin: Sorter   -----------------------------------------------
sub admin_sorter {

	my ($dbh,$query,$title) = @_;

	for ($title) {
		/Site Information/ 			&& do { &admin_general($dbh,$query); last;		};
		/Permissions/ 				&& do { &admin_permissions($dbh,$query); last;		};
		/Twitter/ 				&& do { &admin_accounts($dbh,$query); last;		};
		/Facebook/ 				&& do { &admin_accounts($dbh,$query); last;		};
		/Base URLs and Directories/ 		&& do { &admin_general($dbh,$query); last;		};
		/Media Directories/ 			&& do { &admin_general($dbh,$query); last;		};
		/Upload Directories/ 			&& do { &admin_general($dbh,$query); last;		};
		/Anonymous User/ 			&& do { &admin_users($dbh,$query); last;		};
		/Enable Registration/			&& do { &admin_users($dbh,$query); last;		};
		/Enable External Accounts/		&& do { &admin_users($dbh,$query); last;		};
		/Enable Harvester/			&& do { &admin_harvester($dbh,$query); last; 		};
		/Audio Harvesting/			&& do { &admin_harvester($dbh,$query); last; 		};
		/Email Program and Addresses/ 	&& do { &admin_newsletters($dbh,$query); last;		};
		/Big Blue Button Configuration/ 	&& do { &admin_meetings($dbh,$query); last;		};
	}
	&admin_general($dbh,$query);
#	exit;
}





# -----------------------------------   Admin: Config Table   -----------------------------------------------

sub admin_configtable {

	my ($dbh,$query,$title,@vals) = @_;

	my $content = qq|

		<h3>$title</h3>
		<div class="adminpanel">
		<ul><form method="post" action="$Site->{st_cgi}admin.cgi">
		<input type="hidden" name="action" value="config">
		<input type="hidden" name="title" value="$title">
		<table cellspacing="0" cellpadding="2" border="0">
	|;
	foreach my $v (@vals) {
		my ($t,$v,$f,$o,$h) = split ":",$v;    # Title, variable name, format   #"
		if ($f eq "yesno") {
			my $yesselected=""; my $noselected="";
			if ($Site->{$v} eq "yes") { $yesselected = qq| selected="selected"|; }
			else { $noselected = qq| selected="selected"|; }
			$content .= qq|<tr><td align="right">$t : </td><td>
			<select name="$v">
			<option value="yes" $yesselected >Yes</option>
			<option value="no" $noselected >No</option>
			</select>
			</td></tr>\n|;
		} elsif($f eq "dir") {
			my $vfval; $vfval = $Site->{$v} || $o;
			$content .= qq|<tr><td align="right">$t : </td><td>
			$Site->{st_urlf}<input type="text" size="60" name="$v" value="$vfval"></td></tr>\n|;
		} elsif($f eq "url") {
			my $vuval; $vuval = $Site->{$v} || $o;
			$content .= qq|<tr><td align="right">$t : </td><td>
			$Site->{st_url}<input type="text" size="60" name="$v" value="$vuval"></td></tr>\n|;
		} else {
			my $vval; $vval = $Site->{$v} || $f;
			$content .= qq|<tr><td align="right">$t : </td><td>
			<input type="text" size="60" name="$v" value="$vval"></td></tr>\n|;
		}
	}


	$content .= qq|<tr><td colspan="2"><input type="submit" class="button" value="Submit $title"></tr></td>|;
	$content .= "</table>\n</form></ul>
		</div>\n";
}

# -----------------------------------   Admin: General   -----------------------------------------------
#
#   Initialization and editing of general site configuration data
#   Expects and requires access to a 'config' table in the database
#   The config table in turn is used by init_site() in grsshopper.pl
#
# ------------------------------------------------------------------------------------------------------

sub admin_general {

	my ($dbh,$query) = @_;

        my $content = &printlang("General Information");

	$content .= &admin_configtable($dbh,$query,"Site Information",
		("Site Name:st_name","Site Tag:st_tag","Publisher:st_pub","Creator:st_crea","License:st_license","Time Zone:st_timezone","Reset Key:reset_key","Cron Key:cronkey"));


	$content .= &admin_api($dbh,$query);

#	$content .= &admin_configtable($dbh,$query,"Base URLs and Directories",
#		("Base URL:st_url","Base Directory:st_urlf","CGI URL:st_cgi","CGI Directory:st_cgif","Login URL:st_login"));

#	$content .= &admin_configtable($dbh,$query,"Media Directories",
#		("Images:st_img","Photos:st_photo","Files:st_file","Icons:st_icon"));

#	$content .= &admin_configtable($dbh,$query,"Upload Directories",
#		("Uploads:st_upload","Images:up_image","Documents:up_docs","Slides:up_slides","Audio:up_audio","Videos:up_video"));

	&admin_frame($dbh,$query,"Admin General",$content);					# Print Output
	exit;



}


# -----------------------------------   Admin: Meetings   -----------------------------------------------
#
#   Initialization and editing of general site configuration data
#   Expects and requires access to a 'config' table in the database
#   The config table in turn is used by init_site() in grsshopper.pl
#
# ------------------------------------------------------------------------------------------------------

sub admin_meetings {

	my ($dbh,$query) = @_;



	my $content = &printlang("Meetings");
	qq|<h2>Meetings</h2><p>This is the gRSShopper interface to Big Blue Button. If there is
		no instance of BBB available, this section will not be usable.</p>|;

	my $meeting_con = &bbb_get_meetings();
	my $meetingcount = 0;

	$Person->{person_name} ||= $Person->{person_title};
	$content .= qq|<h3>Current Live Meetings</h3>
		<form method="post" action="$Site->{st_cgi}page.cgi">
		<p>These are the live meetings currently running ion $Site->{st_name}. If you would
		like to enter the confreencing environment and join the meeting, please provide a
		name and then select the meeting you would like to join.<br/><br/>

		Enter your name: <input size="40" type="text" name="username" value="$Person->{person_name}"></p>

		<input type="hidden" name="action" value="join_meeting">

		<ul><table cellpadding="5" cellspacing="0" border="0">|;

	while ($meeting_con =~ /<meeting>(.*?)<\/meeting>/g) {
		$meetingcount++; my $meeting = (); my @moderators;
		my $meet_data = $1; my $meeting_id; my $meeting_name; my $meeting_started;

		while ($meet_data =~ /<meetingName>(.*?)<\/meetingName>/g) { $meeting->{name} = $1; }
		next if ($meeting->{name} eq "Administrator Meeting");

		while ($meet_data =~ /<meetingID>(.*?)<\/meetingID>/g) { $meeting->{id} = $1; }
		$meeting->{info} = &bbb_getMeetingInfo($meeting->{id});

		while ($meeting->{info} =~ /<participantCount>(.*?)<\/participantCount>/g) { $meeting->{count} = $1; }
		while ($meeting->{info} =~ /<attendee>(.*?)<\/attendee>/g) {
			my $attendee = $1; my $a = ();
			while ($attendee =~ /<role>(.*?)<\/role>/g) { $a->{role} = $1; }
			while ($attendee =~ /<fullName>(.*?)<\/fullName>/g) { $a->{fn} = $1; }
			if ($a->{role} =~ /moderator/i) {
				if ($meeting->{mods}) { $meeting->{mods} .= ", "; }
				$meeting->{mods} .= $a->{fn};
			}
		}

		while ($meet_data =~ /<createTime>(.*?)<\/createTime>/g) { $meeting_started = $1; }
		$content .= qq|<tr><td align="right"><b>$meeting->{name}</b> - $meeting->{count} participant(s)<br/>
				Moderator(s): $meeting->{mods} </td>
				<td valign="top">
				<input type="submit" name="meeting_id"
				value="Join Meeting $meeting->{id}"></td></tr>|;
 # $content .= qq|<form><textarea cols="50" rows="10">$meet_data\n\n$meet_info</textarea></form><p>|;
	}
	$content .= "</table></ul></p></form>";
	if ($meetingcount ==0) {
		$content .= "<p><ul>There are currently no live meetings taking place.</ul></p>";
	}




	my $newid = time;
	$content .= qq|<h3>Create and Join Meetings</h3>
		<form method="post" action="$Site->{st_cgi}admin.cgi">
		<input type="hidden" name="action" value="moderate_meeting">
		<ul><table cellpadding="2" cellspacing="0" border="0">
		<tr><td align="right">Meeting Name:</td><td><input type="text" name="meeting_name" size="40"></td></tr>
		<tr><td align="right">Meeting Ident:</td><td><input type="text" name="meeting_id" value="$newid" size="40"></td></tr>
		<tr><td align="right">Recording:</td>
		<td><select name="meeting_record"><option value="off">Recording Off</option>
		<option value="on">Recording On</option></select></td></tr>
		<tr><td align="right" colspan="2"><input type="submit" value="Create Meeting and Join It"></td></tr>
		</table></form></ul>|;


	$content .= qq|<h3><a href="$Site->{st_cgi}admin.cgi?action=moderate_meeting">Join Standing Administration Meeting</a></h3><p>|;

	$content .= &admin_configtable($dbh,$query,"Big Blue Button Configuration",
		("BBB Name:bbb_name","BBB URL:bbb_url","BBB Salt:bbb_salt","Admin Pwd:bbb_mp","Attendee Pwd:bbb_ap"));






	&admin_frame($dbh,$query,"Meetings",$content);					# Print Output
	exit;



}

# -----------------------------------   Admin: Logs   -----------------------------------------------
#
#   View Logs
#
# ------------------------------------------------------------------------------------------------------


sub admin_logs {

	my ($dbh,$query) = @_;

	return unless (&is_viewable("admin","logs")); 		# Permissions

	my $content = qq|<h2>View Logs</h2><p>
		General Statistics -
		[<a href="admin.cgi?action=logview&logfile=General Stats&format=table">Table</a>]
		[<a href="admin.cgi?action=logview&logfile=General Stats&format=tsv">TSV</a>]
		[<a href="admin.cgi?action=logview&logfile=General Stats&format=csv">CSV</a>]<br/>
		Cron Logs - [<a href="admin.cgi?action=logview&logfile=cronlog">Text File</a>]
		</p>|;




	&admin_frame($dbh,$query,"Admin General",$content);					# Print Output
	exit;



}


sub admin_api {

	my ($dbh,$query) = @_;



	my $content = qq|<h2>Access API</h2><p>
	 <ul><table cellspacing="0" cellpadding="2" border="0"><tr><td>
   <form method="post" action="$Site->{st_cgi}admin.cgi">
	 <input type="hidden" name="action" value="access_api">
	 Method: <select name="method"><option value="get"> GET </option> <option value="post" selected> POST </option></select><br>
	 URL: <input type="text" name="url" size="40" value="http://www.mooc.ca/cgi-bin/api.cgi">
	 JSON: <textarea rows=10 cols="40" name="postdata">
{
 "action": "search",
 "table": "course",
 "query": "agriculture",
 "language": "en",
 "sort": "course_title"
}
	 </textarea>
	 <input type="submit">
	 </form>
   </table></ul>

	|;

   return $content;

	exit;



}

# -----------------------------------   Admin: Multi   -----------------------------------------------
#
#   Admin Multi
#
# 	Perform the same action on multiple records, selected with checkboxes, with name multi_id
#	Also expects a hidden field, multi_db
#	And a field called multi_action
#	Called by action: multi
#
# ------------------------------------------------------------------------------------------------------


sub admin_multi {

	my ($dbh,$query) = @_;

	my $action = $vars->{multi_action};
	my $table = $vars->{multi_db};

	return unless (&is_allowed($action,$table));

	my $content = qq|<h2>Multi-$action |.$table.qq|s</h2><p>|;

	my @records = split /\0/,$vars->{multi_id};
	foreach $record (@records) {
		if ($action eq "Delete") { &record_delete($dbh,$query,$table,$record,"silent"); }
		$content .=  "Delected $table record number $record<br>";
	}



	$content .= "</p>";

	$content .= qq|[<a href="admin.cgi?db=$table&action=list">List Again</a>]|;

	&admin_frame($dbh,$query,"Multi-".$action." ".$table."s",$content);					# Print Output
	exit;




}




# -----------------------------------   Admin: Accounts   -----------------------------------------------
#
#   View Logs
#
# ------------------------------------------------------------------------------------------------------


sub admin_accounts {

	my ($dbh,$query) = @_;

	return unless (&is_viewable("admin","accounts")); 		# Permissions

	my $content = qq|<h2>Accounts</h2><p>These values control access information to external accounts.</p>|;

	$content .= &admin_configtable($dbh,$query,"Twitter",
		("Twitter Account:tw_account","Post to Twitter:tw_post:yesno","Use Site Hashtag:tw_use_tag:yesno","Consumer Key:tw_cckey","Consumer Secret:tw_csecret","Token:tw_token","Token Secret:tw_tsecret"));

	$content .= &admin_configtable($dbh,$query,"Facebook",
		("Facebook Account:fb_account","Post to Facebook:fb_post:yesno","Use Site Hashtag:fb_use_tag:yesno","Application ID:fb_app_id","Application Secret:fb_app_secret","Postback URL:fb_postback_url","Access Code:fb_code","Access Token:fb_token","Authorization URL:fb_auth_url"));


	&admin_frame($dbh,$query,"Admin Accounts",$content);					# Print Output
	exit;



}

# -----------------------------------   Admin: Permissions   -----------------------------------------------
#
#   View and Set Default Permissions
#
# ------------------------------------------------------------------------------------------------------


sub admin_permissions {

	my ($dbh,$query) = @_;

	return unless (&is_viewable("admin","permissions")); 		# Permissions

	my $content = qq|<h2>Permissions</h2><p>|;

	# my @tables = $dbh->tables();
	my @tables = &db_tables($dbh);
	my @actions = qw{create approve edit delete view};
	my @reqs = qw{admin editor owner project registered anyone};


	$content .= qq|<style>

		select.admin {background-color: #cc0000;}
		select.owner {background-color: #ffcccc;}
		select.editor {background-color: #FF7F00;}
		select.project {background-color: #ffcc00;}
		select.registered {background-color: #ff00cc;}
		select.anyone {background-color: #008800;}
		option.admin {background-color: #cc0000;}
		option.editor {background-color: #FF7F00;}
		option.owner {background-color: #ffcccc;}
		option.project {background-color: #ffcc00;}
		option.registered {background-color: #ff00cc;}
		option.anyone {background-color: #008800;}
		select, option { width: 100px; }
		</style>
		|;

	# Table Headings
	$content .= qq|<form method="post" action="admin.cgi">
		<input type="hidden" name="title" value="Permissions">
		<input type="hidden" name="action" value="config">|;
	$content .= "<p><table cellpadding=3 cellspacing=0 border=1>";
	$content .= "<tr><td><i>Data Type</i></td>";
	foreach my $action (@actions) { $content .= "<td>".ucfirst($action)."</td>"; }
	$content .= "</tr>\n";

	foreach my $table (@tables) {
		$content .= "<tr><td>".ucfirst($table)."</td>";
		foreach my $action (@actions) {

			my $vname = $action."_".$table;
			my $creq = &permission_current($action,$table);
			$content .= qq|<td><select name="$vname" class="$creq" >\n|;
			foreach my $req (@reqs) {
				my $sel="";if ($creq eq $req) { $sel = " selected"; }
				$content .= qq|<option class="$req" value="$req"$sel> $req</option>\n|;
			}
			$content .= qq|</select></td>\n|;
		}
		$content .= "</tr>\n";
	}

	$content .= qq|</table></p>Color will not change until data has been saved.<br>
		<input type="submit" value="Update Permissions"></form>|;




	&admin_frame($dbh,$query,"Admin Permissions",$content);					# Print Output
	exit;

}



# -----------------------------------   Admin: Harvester   -----------------------------------------------
#
#   Harvester management utilities
#
# ------------------------------------------------------------------------------------------------------

sub admin_harvester {

	my ($dbh,$query) = @_;

	return unless (&is_viewable("admin","harvester")); 		# Permissions

	my $content = qq|<h2>Harvester</h2><p>On this page you can manage and operate your harvester. To turn
		on automated harvesting, set 'Enable Harvester' to 'yes' (requires cron). The harvester will
		process one feed every 'Harvester Interval' minutes. To add, manage and delete content sources,
		create, edit and delete feeds (see the menu at left) or use the OPML options below.</p>|;

	my $harvesterlink = $Site->{st_cgi}."harvest.cgi";
	my $edursslink = $Site->{st_cgi}."edurss02.cgi";

										# Harvester Controls
	$content .= &admin_configtable($dbh,$query,"Enable Harvester",
	("Enable Harvester:st_harvest_on:yesno","Harvester Interval:st_harvest_int","Feed Cache Location:feed_cache_dir"));

										# Audio Download Controls
	my $default_audio_download = "dir:files/podaudio/";
	my $default_playlist_file = "url:files/podaudio/playlist.pls";
	$content .= &admin_configtable($dbh,$query,"Audio Harvesting",
	("Download Audio:st_audio_dl:yesno","Make Playlist:st_audio_pl:yesno","Audio File Directory:audio_download_dir:$default_audio_download",
		"Audio Playlist File:audio_playlist_file:$default_playlist_file","Files Expire (in days):audio_files_expire:1"));


	# Get Feed List
	my $feedselector = qq|<option value="0">Please select a feed from the list....</option>\n|;
	my $sql = qq|SELECT feed_id,feed_title,feed_status from feed ORDER BY feed_title|;
	my $sth = $dbh -> prepare($sql);
	$sth -> execute();
	while (my $feed = $sth -> fetchrow_hashref()) {
		$feed->{feed_title} = substr($feed->{feed_title},0,45);
		$feedselector .= qq|<option value="$feed->{feed_id}">$feed->{feed_title} ($feed->{feed_status})</option>\n|;
	}

	$content .= qq|

		<h3>Operate Harvester</h3>
		<form method="post" action="harvest.cgi">
		<ul>
		<input type="radio" name="source" value="queue" selected> Harvest Next In Queue<br/>
		<input type="radio" name="source" value="feed"> Harvest Feed: <select name="feed">$feedselector</select>
		<br/>
		<input type="radio" name="source" value="url"> Harvest URL:
		<input type="text" name="url" value="Enter full URL here" size="40"><br/>
		<input type="radio" name="source" value="file"> Harvest File:
		<input type="text" name="file" value="File name, file needs to be in same directory as script (for now)" size="40"><br/>
		<input type="radio" name="source" value="all"> Harvest All<br/><br/>
		<input type="submit" class="button" value="Harvest Feed">
		</ul>
		</form>


		<h3>View Harvest Results</h3>
		<p><ul>
		<li><a href="$Site->{cgi}page.cgi?action=viewer">Viewer</a></li>
		</ul></p>

		<h3>Import and Export Feeds</h3>|;

	if (&new_module_load($query,"XML::OPML")) {
		$content .= qq|
		<p><ul>
		<li><a href="|.$Site->{st_cgi}.qq|harvest.cgi?action=export">Export OPML File</a></li>
		<li> <a href="$harvesterlink?action=opmlopts">Import Feed List From OPML</a>
		</ul></p>|;
	} else {
		$content .= $vars->{error};
	}

	&admin_frame($dbh,$query,"Admin General",$content);					# Print Output
	exit;

}

# -----------------------------------   Admin: Users   -----------------------------------------------
#
#   Manage Users
#
# ------------------------------------------------------------------------------------------------------

sub admin_users {

	my ($dbh,$query) = @_;


	return unless (&is_viewable("admin","users")); 		# Permissions
	my $adminlink = $Site->{st_cgi}."admin.cgi";

	my $intro = "";
	if ($vars->{msg}) { $intro = qq|<p class="notice">$vars->{msg}</p>|; }
	else { $intro = "<p>On this page you can manage your user accounts and newsletter subscriptions. Note that
		you can also access user accounts directly by searching and editing in the 'Persons' table, left.</p>";	}


	my $content = qq|<h2>Users</h2>$intro|;


	$content .= &admin_configtable($dbh,$query,"Enable Registration",
		("Enable Registration:st_reg_on:yesno","Turn Capchas On:st_capcha_on:yesno"));

	$content .= &admin_configtable($dbh,$query,"Enable External Accounts",
		("Enable OpenID:st_openid_on:yesno","Enable Google:st_google_on:yesno"));

	$content .= &admin_configtable($dbh,$query,"Anonymous User",
		("Anonymous User Name:st_anon","Anonymous IUser ID:st_anon_id"));

	$content .= qq|
		<h3>Find User</h3>
		<div class="adminpanel">
		<form method="post" action="$Site->{st_cgi}admin.cgi">
		<input type="hidden" name="action" value="eduser">
		<table>
		<tr><td>User ID number:</td><td><input type="text" name="pid" size="20"></td></tr>
		<tr><td><b>or</b> userid:</td><td><input type="text" name="ptitle" size="40"></td></tr>
		<tr><td><b>or</b> name:</td><td><input type="text" name="pname" size="40"></td></tr>
		<tr><td><b>or</b> email:</td><td><input type="text" name="pemail" size="40"></td></tr>
		</td></tr></table>
		<input type="submit" value="Find User" class="button">
		</form>
		</div>
	|;


	$content  .= qq|
		<br/><h3>Import User List From File</h3>
		<div class="adminpanel">
		The system expects a file with
		field names in the first row. Importer will ignore field names it does not recognize.<br/><br/>
		<form method="post" action="$adminlink" enctype="multipart/form-data">
		<input type="hidden" name="action" value="import">
		<table cellpadding=2>
		<input type="hidden" name="table" value="person">
		<tr><td>File URL:</td><td><input type="text" name="file_url" size="40"></td></tr>
		<tr><td>Or Select:</td><td><input type="file" name="file_name" /></td></tr>
		<tr><td>Data Format:</td><td><select name="file_format"><option value="">Select a format...</option>
		<option value="tsv">Tab delimited (TSV)</option>
		<option value="csv">Comma delimited (CSV)</option></select></td>
		<tr><td colspan=2><input type="submit" value="Import" class="button"></tr></tr></table>
		</form></div>|;

	$content .= qq|	<h3>Export User List</h3>
		<div class="adminpanel">

		<p>
		<form method="post" action="$adminlink">
		<input type="hidden" name="action" value="export_users">
		<select name="exportformat">
		<option value="CSV" selected>Select a Format...</option>
		<option value="CSV">Comma Separated Values</option>
		<option value="TSV">Tab Separated Values</option>
		</select>
		<input type="submit" value="Export User List" class="button">
		</form>
		</p>



		</p></div>|;


	# It's here, but I just don't think it's wise to enable it
	# To enable, remove the word DISABLED

	 	$content .= qq|	<h4>Delete All Users</h4>
		<div class="adminpanel"><p>
		<form method="post" action="$adminlink">
		<input type="hidden" name="saction" value="remove_all">
		<select name="action">
		<option value="NONONO" selected>Really?</option>
		<option value="DISABLEDremove_all">Yes, Really</option>
		</select>
		<input type="submit" value="Delete All Users" class="button">
		</form></p>
		</div><p>&nbsp;</p>|;



	&admin_frame($dbh,$query,"Admin General",$content);					# Print Output
	exit;



}


sub admin_users_edit {

	my ($dbh,$query) = @_;

	&error ($dbh,"","","Permission denied") unless ($Person->{person_status} eq "admin"); 		# Permissions

									# Find User Information
	my $user;
	if ($vars->{ptitle}) { $user = &db_get_record($dbh,"person",{person_title=>$vars->{ptitle}}); }
	elsif ($vars->{pname}) {  $user = &db_get_record($dbh,"person",{person_name=>$vars->{name}}); }
	elsif ($vars->{pemail}) {  $user = &db_get_record($dbh,"person",{person_email=>$vars->{pemail}}); }
	elsif ($vars->{pid}) {  $user = &db_get_record($dbh,"person",{person_id=>$vars->{pid}}); }
	else { &error($dbh,"","","User information was not supplied"); }
	unless ($user) { &error($dbh,"","","I feel terrible. User information was not found."); }

	$user->{person_name} ||= $user->{person_title};
	my $content = qq|<h2>User Information Found</h2>
		<div class="adminpanel">
		Name: $user->{person_name} ($user->{person_title})<br/>
		UserID: $user->{person_id}<br/>
		Email: $user->{person_email}<br/>
		[<a href="$Site->{st_cgi}admin.cgi?person=$user->{person_id}&action=edit">Edit $user->{person_name}</a>]<br/>
		[<a href="javascript:confirmDelete('$Site->{st_cgi}admin.cgi?person=$user->{person_id}&amp;action=Delete')">Delete $user->{person_name}</a>] <br>
		[<a href="$Site->{st_cgi}login.cgi?action=Subscribe&pid=$user->{person_id}">Edit Subscriptions</a>]<br/>
		<br/>Send this person a message:<br/>
		<form method="post" action="$Site->{st_cgi}admin.cgi">
		<input type="hidden" name="action" value="sendmsg">
		<input type="hidden" name="userid" value="$user->{person_id}">
		<input type="text" size="40" name="subject">
		<textarea cols="80" rows="10" name="body"></textarea>
		<input type="submit" value="send email"></form>
		</div>|;



	my $user = &db_get_record($dbh,"person",{$table."_id"=>$id_number});




	 print "Content-type: text/html; charset=utf-8\n\n";
	 print $Site->{header};
	 print $content;
	 print $Site->{footer};
	 exit;

}

# -----------------------------------   Admin: Users: Send Message  --------------------------------------------
#
#   Manage Users
#
# ------------------------------------------------------------------------------------------------------

sub admin_users_send_message {

	 my $content =qq|<h2>Message Sent</h2>|;


	&error ($dbh,"","","Permission denied") unless ($Person->{person_status} eq "admin"); 		# Permissions
	&error($dbh,"","","No body in message") unless ($vars->{body});
	&error($dbh,"","","No person to send to") unless ($vars->{userid});
	$vars->{subject} ||= "Message from $Person->{person_name} on $Site->{st_name}";

	my  $user = &db_get_record($dbh,"person",{person_id=>$vars->{userid}});
	&error($dbh,"","","No email address to send to") unless ($user->{person_email});
	$vars->{body} .= "\n\nSent from gRSShopper administrator on $Site->{st_name}\n";


	$vars->{subject} =~ s/&#39;/'/g;
	$vars->{body} =~ s/&#39;/'/g;
	$Site->{st_name} =~ s/&#39;/'/g;

	&send_email($user->{"person_email"},$Site->{em_from}, $vars->{subject},$vars->{body});



	 print "Content-type: text/html; charset=utf-8\n\n";
	 print $Site->{header};
	 print $content;
	 print $Site->{footer};
	 exit;
}

# -----------------------------------   Admin: Newsletters   -----------------------------------------------
#
#   Manage and Send Newsletters
#
# ------------------------------------------------------------------------------------------------------

sub admin_newsletters {

	my ($dbh,$query) = @_;

	return unless (&is_viewable("admin","newsletter")); 		# Permissions
	my $adminlink = $Site->{st_cgi}."admin.cgi";

	my $content = qq|<h2>Newsletters</h2><p>Each newsletter is composed of a page and a list of subscribers.
		Edit pages at left, and to turn any page into a newsletter, set 'Autopub' to 'yes' and 'Sub' to 'yes'.
		Newsletter contents are typically created automatically using 'keyword' commands in the page; see
		keyword help for more information. Users subscribe to newsletters through the 'Options' screen;
            you can manage user subscriptions directly from this page, either individually or as a group. Selecting
		'send newsletter' to all subscribers sends the newsletter by email using the values at the bottom
            of the screen.|;




	# Get list of eligible newsletters in dropdown form
	my $npageoptionlist = "<option>Select a newsletter</option>\n";
	my $stmt = qq|SELECT * FROM page WHERE page_sub='yes'|;
	my $sthl = $dbh->prepare($stmt);
	$sthl->execute();
	while (my $s = $sthl -> fetchrow_hashref()) {
		$npageoptionlist .= qq|<option value="$s->{page_id}">$s->{page_title}</option>\n|;
	}


	$content .= qq|
		<h3>Send Newsletter</h3>
		<div class="adminpanel">
		<form method="post" action="$Site->{st_cgi}admin.cgi">
		<input type="hidden" name="action" value="send_nl">
		<input type="hidden" name="verbose" value="1">
		<table cellpadding="3">
		<tr><td><b>Page</td><td><b>List</b></td><td>&nbsp;</td></tr>
		<tr><td><select name="page_id">$npageoptionlist</select></td>
		<td>		<select name="send_list">
		<option value="on">Select an action</option>
		<option value="admin">To Admins Only</option>
		<option value="subscribers">To All Subscribers</option>
		<option value="all_users">To All Users</option>
		</select></td>
		<td><input type="submit" value="Send Newsletter" class="button"></td></tr></table>
		</form>
		</div>
	|;

	$content .= qq|


		<br/><h3>Manage Newsletter</h3>
		<div class="adminpanel">

		<b>Post Issue Rollup</b><br/>
		Posts in newsletters can be scheduled for publication ahead of time; see the
		'Edit Post' screen for more. This button will show you the list of posts scheduled
		for upcoiming newsletters.<br>
		<form method="post" action="$adminlink">
		<input type="hidden" name="action" value="rollup">
		<input type="submit" value="Rollup" class="button">
		</form>
		</div><br/>



		<h3>Manage Subscriptions</h3>
		<div class="adminpanel">
				<b>Autosubscribe</b><br/>
		<form method="post" action="$adminlink">
		<select name="action">
		<option>Select an action</option>
		<option value="autosub">Autosubscribe All</option>
		<option value="autounsub">Unsubscribe All</option>
		</select>
		to
		<select name="newsletter">
		$npageoptionlist
		</select>
		<input type="submit" value="Do It" class="button">
		</form>
		</div><br/>

	|;

	$content .= &admin_configtable($dbh,$query,"Email Program and Addresses",
		("Mail Program Location:em_smtp","System Email:em_from",
		"Discussion Email:em_discussion","Copyto Email:em_copy","Def:em_def"));

	&admin_frame($dbh,$query,"Admin General",$content);					# Print Output
	exit;



}

# -----------------------------------   Admin: Database   -----------------------------------------------
#
#   Initialization and editing site databases
#
# ------------------------------------------------------------------------------------------------------

sub admin_database {

	my ($dbh,$query,$sst,$columns) = @_;


	# Permissions
	return unless (&is_viewable("admin","database"));
	my $adminlink = $Site->{st_cgi}."admin.cgi";

	if ($vars->{dbmsg}) { $vars->{dbmsg} = qq|<p class="notice"><br>$vars->{dbmsg}</p>|; }
	my $content = qq|$vars->{dbmsg}<h2>Database</h2><p>Get database information and manage database tables.</p>|;


	# Manage Database

	# Create generic tables dropdown
	my @tables = $dbh->tables();
	my $table_dropdown;
	foreach my $table (@tables) {

		# Remove database name from specification of table name
		if ($table =~ /\./) {
			my ($db,$dt) = split /\./,$table;
			$table = $dt;
		}

		# User cannot view or manipulate person or config tables
		next if ($table eq "person" || $table eq "config");
		$table=~s/`//g;  #`

		my $sel; if ($table eq $sst) { $sel = " selected"; } else {$sel = ""; }
		$table_dropdown  .= qq|		<option value="$table"$sel>$table</option>\n|;
	}




	$content .= qq|
		<h3>Manage Database</h3>
		<div class="adminpanel">
		<form method="post" action="admin.cgi">Select table:
		<select name="stable">$table_dropdown</select><br>\n
		<select name="action">\n
		<option value="showcolumns">Show Columns</option>\n
		<option value="db_add_column">Add Column</option>\n
		<option value="removecolumnwarn">Remove Column</option>\n
		</select>\n
		<input type="text" name="col" value="" size="12"  style="height:1.8em;"/>\n
		<input type="submit" value="Submit" class="button">\n
		</select></form></ul>\n|;

	# Display results from previous processing
	if ($columns) { $content .= $columns; }
	$content .= "<br/>";
	$content .= "</div>";


	# Back Up Database


	$content .= qq|
		<br/><h3>Back Up Database</h3>
		<div class="adminpanel">
		<form method="post" action="admin.cgi">
		<input type="hidden" value="backup_db" name="action">
		<select name="backup_table">
		<option value="all">All Tables</option>
		$table_dropdown
		</select>

		<input type="submit" value="Back Up Database">
		</form>
		</div>|;


	# Add and Drop Tables

	$content .= qq|
		<br/><h3>Add Table</h3>
		<div class="adminpanel">
		<form method="post" action="admin.cgi">
		<input type="hidden" value="add_table" name="action">
		<input type="text" name="add_table">
		<input type="submit" value="Add Table">
		</form>
		</div>|;

	$content .= qq|
		<br/><h3>Drop Table</h3>
		<div class="adminpanel">
		<form method="post" action="admin.cgi">
		<input type="hidden" value="drop_table" name="action">
		<select name="drop_table">
		$table_dropdown
		</select>
		<input type="submit" value="Drop Table"><br>
		<span style="color:red;">Warning</span>: dropping a table will eliminate all data in the table. Table data will be saved in a backup file.
		</form>
		</div>|;


	# Import from File


	my $tout = qq|<select name="table">$table_dropdown</select><br/>\n|;


	$content  .= qq|
		<br/><h3>Import Data From File</h3>
		<div class="adminpanel">
		The file needs to be preloaded on the server. The system expects a tab delimited file with
		field names in the first row. Importer will ignore field names it does not recognize.<br/><br/>
		<form method="post" action="$adminlink" enctype="multipart/form-data">
		<input type="hidden" name="action" value="import">
		<table cellpadding=2>
		<tr><td>Import into table:</td><td>$tout</td></tr>
		<tr><td>File URL:</td><td><input type="text" name="file_url" size="40"></td></tr>
		<tr><td>Or Select:</td><td><input type="file" name="myfile" /></td></tr>
		<tr><td>Data Format:</td><td><select name="file_format"><option value="">Select a format...</option>
		<option value="tsv">Tab delimited (TSV)</option>
		<option value="csv">Comma delimited (CSV)</option>
		<option value="json">JSON</option></select></td>
		<tr><td colspan=2><input type="submit" value="Import" class="button"></tr></tr></table>
		</form></div>|;

	# Export data

	$content  .= qq|
		<br/><h3>Export Data</h3>
		<div class="adminpanel">
		<form method="post" action="$adminlink">
		<input type="hidden" name="action" value="export_table">
		<table cellpadding=2>
		<tr><td>Export from table:</td><td>$tout</td></tr>
		<tr><td>Data Format:</td><td><select name="export_format"><option value="">Select a format...</option>
		<option value="tsv">Tab delimited (TSV)</option>
		<option value="csv">Comma delimited (CSV)</option>
		<option value="json">JSON</option></select></td>
		<tr><td colspan=2><input type="submit" value="Export" class="button"></tr></tr></table>
		</form></div>|;


	$content .=  qq|</table></ul>|;


	$content .= qq|
		<h3>Create Data Pack</h3><ul>
		Data Packs contain the <i>data</i> from several tables in addition to the basic table structure
		for all tables (which may be modified above). These are intended to create new blank sites out
		of the site you already have, with predefined pages, templates, or whatever.
		Data Pack scripts use <b>mysqldump</b> and assume
		you are using MySQL and Linux. If you are not set up this way you will need to replace
		the export scripts with scripts that will work for your system. Saving a Data Pack
		writes over an existing Data Pack with that name.<br/><br/>
		<form method="post" action="admin.cgi"><table cellpadding="3" cellspacing="0" border="1">
		<input type="hidden" name="action" value="db_pack">
		<tr><td>Create Data Pack named</td><td><input type="text" name="pack" size="20"></td></tr>
		<tr><td valign="top">Use fields:</td><td><select name="fields" multiple="multiple" size="8">|;

	foreach my $tt (@tables) {
		$tt=~s/`//g;              #`
		next if ($tt =~ /config/);
		next if ($tt =~ /person/);
		next if ($tt =~ /cache/);
		$content  .= qq|	<option value="$tt">$tt</option>\n|;

	}
	$content .= qq|</select></td></tr><tr><td>&nbsp;</td>
		<td><input type="submit" value="Create Data Pack"></td></tr></table></form>
		</ul>|;



	$Site->{ServerInfo}  =  $dbh->{'mysql_serverinfo'};
	$Site->{ServerStat}  =  $dbh->{'mysql_stat'};

	$content .= qq|
		<h3>Database Information</h3><br/><ul>
		&nbsp;&nbsp;Server Info: $Site->{ServerInfo} <br/>
		&nbsp;&nbsp;Server Stat: $Site->{ServerStat}<br/><br/></ul>|;



	&admin_frame($dbh,$query,"Admin General",$content);					# Print Output
	exit;



}



sub admin_db_export {

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;



	if ($vars->{export_format} eq "json") {
		print "Content-type: application/json\n\n";
		my $keyfield = $vars->{table}."_id";
		my $hash_ref = $dbh->selectall_hashref(qq|select * from $vars->{table}|,$keyfield);
		use JSON::XS;
		my $utf8_encoded_json_text = encode_json $hash_ref;
		print "$utf8_encoded_json_text";
		exit;
	} else {


		print "Content-type: text/plain\n\n";
		my $sth= $dbh->prepare(qq|select * from $vars->{table}|);
		$sth->execute();

		my $fields = join "\t" , @{$sth->{NAME}};
		print $fields,"\n";

		my $count = 0;
		while (my $row = $sth->fetchrow_arrayref()) {
			foreach my $r (@$row) { $row[$count] =~ s/\t/    /g; $count++;}
			print join( "\t", map( {$dbh->quote($_)} @$row)),"\n";
		}
	}
	$dbh->disconnect;

}



sub admin_db_pack {

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;
	&error($dbh,"","","No Pack Name specified") unless ($vars->{pack});
												# Make Pack Directory
	my $packsdir = $Site->{st_cgif}."packs/".$vars->{pack};
	unless (-d $packsdir) { mkdir $packsdir, 0755 or die "Error 1062 creating upload directory $packsdir $!"; }

												# Clearn out existing files
	opendir (DIR,$packsdir);
	my @files = grep(/grsshopper/, readdir (DIR));
	closedir (DIR);
	foreach my $file (@files) { unlink "$packsdir/$file"; }

												# Execute shell script
	my $pwd = $Site->{database_pwd}; $pwd =~ s/\&/\\\&/g; 					# cgi-bin/data_pack.sh
	my @fields = split /\0/,$vars->{fields};
	my $fields = join " ",@fields;

	my $symsg = qq|./data_pack.sh $vars->{pack} $pwd $Site->{db_name} $fields|;
	print "Content-type: text/html\n\n";
	print $symsg,"<p>";
	my $systring = `./data_packa.sh $vars->{pack} $pwd $Site->{db_name} $fields`;
	$vars->{dbmsg} .= "$systring<br>Data Pack a <b>$vars->{pack}</b> Created";
	&admin_database($dbh,$query);
}

sub admin_db_backup {

	my ($table,$p) = @_;

	my $output = "Backing up $table";
	if ($table eq "all") {$output .= " tables"; }
	my $savefile = &db_backup($table);
	my $saveurl = $savefile;
	$saveurl =~ s/$Site->{st_urlf}/$Site->{st_url}/;

	my $output .= qq|Table '$table' backed up to <a href="$saveurl">$savefile</a>|;

	if ($p) { $vars->{dbmsg} .= $output; &admin_database($dbh,$query,$table,""); }
	else { return $output; }

}


sub admin_db_add_table {

	my ($table) = @_;

	print "Content-type: text/html\n\n";

	# Normalize table names
	$table =~ s/[^a-zA-Z0-9_]//g;
	$table = lc($table);

	# Create the table
	my $content = "<h3>Create Table</h3>";
	$vars->{dbmsg} .= &db_create_table($dbh,$table) || $vars->{msg};

	# Print Output
	&admin_database($dbh,$query,$table,"");

	# Done


}


sub admin_db_drop_table {

	my ($table) = @_;

	print "Content-type: text/html\n\n";

	# Back up table
	my $savemsg = &admin_db_backup($table);

	# Drop table
	my $dropmsg = &db_drop_table($dbh,$table);

	# Print Output
	$vars->{dbmsg} .= "$savemsg <br>$dropmsg";
	&admin_database($dbh,$query,$table,"");

}


# --------------------------------------   Update Config -----------------------------------------------
#
#    Accept user input from admin and update the config table
#
# ------------------------------------------------------------------------------------------------------

sub admin_update_config {

	my ($dbh,$query,$silent) = @_;
	return unless (&is_allowed("edit","config"));

	# Update Config Table
	while (my ($vx,$vy) = each %$vars) {

		next if ($vx =~ /^(action|mode|cronsite|format|button|force|comment|id|title|mod_load|msg|test)$/);

		my $sth; my $sql;
		if (&db_locate($dbh,"config",{"config_noun" => $vx})) {	# Existing

			$sql = qq|UPDATE config SET config_value=? WHERE config_noun='$vx'|;
			$sth = $dbh->prepare($sql)  or die "Cannot prepare: " . $dbh->errstr();
			$sth->execute($vy) or die "Cannot execute: " . $sth->errstr();
		} else {

			$sql = "INSERT INTO config (config_noun,config_value) VALUES (?,?)";
			$sth = $dbh->prepare($sql)  or die "Cannot prepare: " . $dbh->errstr();
			$sth->execute($vx,$vy) or die "Cannot execute: " . $sth->errstr();
		}
		$sth->finish();

		# Status Message
		$vars->{msg} .= "$vars->{title} : $vx has been set to $vy <br/>";

	}


	# Reload Site Data
	my $sth = $dbh -> prepare("SELECT * FROM config"); $sth -> execute();
	while (my $c = $sth -> fetchrow_hashref()) { $Site->{$c->{config_noun}} = $c->{config_value}; }
	$sth->finish();



	# Display Admin Page
	unless ($silent) { &admin_sorter($dbh,$query,$vars->{title}); }

}








# -------   Admin Menu: Courses   -----------------------------------------------

sub admin_courses {

	return unless (&is_viewable("admin","courses")); 		# Permissions

	return qq|<div class="menubox">

		<h4>Courses</h4>
		<p><ul>
		<li><a href="course.cgi">My Courses</a></li>
		</ul>

	</div>|;

}






# -------   Admin Menu: graph ---------------------------------------------

sub admin_graph {

	return unless (&is_viewable("admin","graph")); 		# Permissions
	my $adminlink = $Site->{st_cgi}."admin.cgi";


	return qq|<div class="menubox">

		<h4>Graph</h4>



		<ul>
		<b>Generate Graph</b><br/>
		<form method="post" action="$adminlink">
		<input type="hidden" name="action" value="graph">
		<input type="submit" value="Generate" class="button">
		</form>
		</ul>

	</div>|;

}


# -------   Export User List --------------------------------------------------------

sub export_user_list {

	my ($dbh,$query) = @_;

	if ($vars->{exportformat} =~ /^CSV$/i) {			# CSV
		print "Content-type: text/plain\n\n";
		print &make_user_list($dbh,$query,"csv");

	}elsif($vars->{exportformat} =~ /^TSV$/i) {		# TSV
		print "Content-type: text/plain\n\n";
		print &make_user_list($dbh,$query,"tsv");
	}


}


sub make_user_list {

	my ($dbh,$query,$delim) = @_;

	my $endlim;
	if ($delim =~ /^CSV$/i) { $endlim = "\n"; $delim = ","; }
	elsif ($delim =~ /^TSV$/i) { $endlim = "\n";$delim = "\t"; }
	my $row = 0; my $output = "";

	my $sql = qq|SELECT * from person|;
	my $sth = $dbh -> prepare($sql);
	$sth -> execute();

	while (my $user = $sth -> fetchrow_hashref()) {
		my @titles; my @data;
		while (my ($ux,$uy) = each %$user) {
			$user->{$ux} =~ s/$delim/ /ig; 		# clean data of delimiters
			$user->{$ux} =~ s/$endlim/ /ig; 		# clean data of delimiters
			if ($row == 0) { $ux =~ s/person_//; push @titles,$ux; }
			push @data,$uy;
		}
		if ($row == 0) { my $topline = join $delim,@titles; $output .= $topline . "\n"; }
		my $line = join $delim,@data; $output .= $line . "\n";
		$row++;
	}
	return $output;

}

sub delete_all_users {

	my ($dbh,$query) = @_;
	print "Content-type: text/html; charset=utf-8\n\n";					# Header
	$Site->{header} =~ s/\Q[*page_title*]\E/Delete All Users/g;
	$Site->{header} =~ s/\Q<page_title>\E/Delete All Users/g;
	print $Site->{header};
	print "<h1>Deleting All Users</h1>";
	print "<p>Ummm.... no. Go edit the code to allow this - line 1270 in admin.cgi</p>";
exit;

# Note - backup of subscription file needs column headers
#exit;

	# Save a backup file
	&error($dbh,"","","Can't get users") unless ( my $savetext = &make_user_list($dbh,$query,"TSV") );
	my $savefile = $Site->{st_cgif}."/data/".$Site->{db_name}."_person_".time;
	&error("$dbh","","","Save Users: Cannot open $savefile: $!") unless (open OUT,">$savefile");
	&error("$dbh","","","Save Users: Cannot print to $savefile: $!") unless (print OUT $savetext);
	close OUT;
	print "<p>Backup of users saved to $savefile </p>";


	# Erase all subscriptions
	my $sql = qq|SELECT page_id FROM page WHERE page_type='email'|;
	my $sth = $dbh -> prepare($sql);
	$sth -> execute();
	while (my $page = $sth -> fetchrow_hashref()) {
		&autounsubscribe_all($dbh,$query,$page->{page_id},"return");
	}

	# Erase all users
	# Erase all subscriptions
	my $sql = qq|SELECT person_id,person_status FROM person|;
	my $sth = $dbh -> prepare($sql);
	$sth -> execute();
	while (my $user = $sth -> fetchrow_hashref()) {
		unless ($user->{person_status} eq "admin") {
			unless ($user->{person_id} eq "2") {
				&db_delete($dbh,"person","person_id",$user->{person_id});
			}
		}
	}
	print "<p>All users (except admin) deleted.</p>";

	print $Site->{footer};
	exit;
}




# -------   User Find Form -----------------------------------------------------
#
#   Quick form to find a user

sub userfindform {

	my ($title,$action) = @_;

						# Permissions

	return unless (&is_allowed("edit","person"));

						# Form

	$Site->{header} =~ s/\Q[*page_title*]\E/$title/g;
	$Site->{header} =~ s/\Q<page_title>\E/$title/g;
	return qq|Content-type: text/html; charset=utf-8\n\n|.
		$Site->{header}.
		qq|<h2>$title</h2>
		<p>Select a person to edit. Enter:
		<form method="post" action="$Site->{st_cgi}login.cgi">
		<input type="hidden" name="action" value="$action">
		User ID number: <input type="text" name="pid" size="20"><br/><br/>
		<b>or</b> userid: <input type="text" name="ptitle" size="40"><br/><br/>
		<b>or</b> name: <input type="text" name="pname" size="40"><br/><br/>
		<b>or</b> email: <input type="text" name="pemail" size="40"><br/><br/>
		<input type="submit" value="Find User data" class="button">
		</form>|.
		$Site->{footer};

}



# -------   Import List --------------------------------------------------------

sub import {

	my ($dbh,$query,$table) = @_;


	my $vars = $query->Vars;

  print "Content-type: text/html\n\n";
  while (my($fx,$fy) = each %$vars) { print "$fx = $fy<br>";}
	print "<h1>Importing List</h1>";
	print "Table: $table File: ".$vars->{myfile}."<br>";                  #"

	my $file;
	if ($query->param("myfile")) { $file = &upload_file(); }		# Uploaded File
	elsif ($vars->{file_url}) { $file = &upload_url($vars->{file_url}); }		# File from URL
	$file->{file_format} = $vars->{file_format};

	$file->{file_location}  = $Site->{st_urlf}.$file->{file_dir}.$file->{file_title};
	print "Got a file - $file->{file_location}  -- $file->{file_title} <p>";
	print "Format is $file->{file_format} <br>";


	if ($file->{file_format} =~ /^json$/i) {

print "Yes";

		my $result = &import_json($file,$table);
		&admin_list_records($dbh,$query,$table);
		exit;
	}

	unless (&new_module_load($query,"Text::ParseWords")) {
		&error($dbh,"","","Text::ParseWords is not available");
	}

	my $count = 0;
	open DBIN,"$file->{file_location}" or &error($dbh,"","","Can't open $file->{file_location} $!");
	my $count = 0; my @fields;
	while (<DBIN>) {
		chomp;
#		print "$_ <br>\n";
		my @values; my $data;

								# Set Up Field Titles from Import File
		if ($count eq 0) {
			if ($file->{file_format} eq "tsv") { @fields = split "\t",$_; }
			elsif ($file->{file_format} eq "csv") {	@fields = parse_csv($_); }
			else { &error($dbh,"","","File format must be csv or tsv"); }

			foreach my $field (@fields) {
				$field = lc($field);
				$field =~ s/ /_/g;
				$field =~ s/first_name/firstname/g;
				$field =~ s/last_name/lastname/g;
				if ($field eq "e-mail_address") { $field = "email"; }
				$field = $table ."_". $field;
			}
			$count++;
			next;
		}

								# Assign datafrom file to imput values
		else {
			if ($file->{file_format} eq "tsv") { @values = split "\t",$_; }
			elsif ($file->{file_format} eq "csv") {	@values = parse_csv($_); }

			my $innercount=0;
			foreach my $field (@fields) {
				$data->{$field} = $values[$innercount];
				$innercount++;
			}
		}

		if ($table eq "person") {			# Special functions for person insert

			my ($to) = $data->{person_email};				# Check email address
				if ($to =~ m/[^0-9a-zA-Z.\-_@]\./) {
				print "Rejected: $to is a Bad Email<br/>";
				next;
			}

			if (&db_locate($dbh,"person",
				{person_email => $data->{person_email}}) ) {		# Unique Email
				print "Duplicate email: $data->{person_email}<br/>";
				next;
			}

			unless ($data->{person_name}) {
				$data->{person_name} = $data->{person_firstname} . " " . $data->{person_lastname};
			}

			unless ($data->{person_name}) {
				$data->{person_name} = $data->{person_email};
			}

			unless ($data->{person_title}) {
				$data->{person_title} = $data->{person_name};
			}

			unless ($data->{person_password}) {
				$data->{person_password} = &random_password();
			}

			unless ($data->{person_status}) {
				$data->{person_status} = "reg";
			}

		}

								# Automatically generated data

		$data->{$table."_crdate"} = time;
		$data->{$table."_creator"} = $Person->{person_id};


								# Save data to database
		$count++;
		if ($table eq "person") { next unless ($data->{"person_email"}); }

		my $ok = 0;
		$ok = &db_insert($dbh,$query,$table,$data);
#	while (my ($vx,$vy) = each %$data) { print "$vx = $vy <br>"; }
#		print "Inserting $data->{person_name} ($data->{person_email}) ($data->{person_organization}) <br>";
		if ($ok) { print "."; }


								# Send email
	}

	print " <br>";
	print "Data uploaded, $count records added.";
	exit;
# connect_page_4_subscriptions_1284638307



exit;


}


# --------  Parse YouTube ----------------------------------------
#
#  Takes a YouTube URL and creates a post

sub parse_youtube {
	my ($dbh,$query) = @_;
	my $vars = $query->Vars;
	my $url = $vars->{url};
	if ($ENV{'HTTP_HOST'} =~ /monctonfreepress/) { # Use proxy for Moncton Free Press
#print "Content-type: text/html\n\n";

		use URI::Escape;
		$safe = uri_escape($url);

		$url = "http://www.downes.ca/cgi-bin/page.cgi?action=proxy&url=$safe";

		#	print "$url.<br>$safe <br>ip";
		#	exit;

	}



	# Get YouTube page
	my $feedrecord = gRSShopper::Feed->new({dbh=>$dbh});
	$feedrecord->{feedstring} = "";
	$feedrecord->{feed_link} = $url;
	&get_url($feedrecord);
	my $tubetext = $feedrecord->{feedstring};
	my $item = ();
#print "Content-type: text/html\n\n";
#print $feedrecord->{feedstring};
#exit;
	#print qq|<form><textarea cols=120 rows=40> $feedrecord->{feedstring}</textarea></form>|;
#exit;

	if ($tubetext =~ m/<meta(.*?)name="description"(.*?)content="(.*?)"(.*?)>/i) { $vars->{post_description} = $3; }
	if ($tubetext =~ m/<meta(.*?)name="keywords"(.*?)content="(.*?)"(.*?)>/i) { $vars->{post_category} = $3; }
	if ($tubetext =~ m/<meta(.*?)property="og:url"(.*?)content="(.*?)"(.*?)>/i) { $vars->{post_link} = $3; }
	if ($tubetext =~ m/<meta(.*?)property="og:site_name"(.*?)content="(.*?)"(.*?)>/i) { $vars->{keyname_feed} = $3; }
	if ($tubetext =~ m/<meta(.*?)property="og:title"(.*?)content="(.*?)"(.*?)>/i) { $vars->{post_title} = $3; }
	if ($tubetext =~ m/<meta(.*?)name="twitter:image"(.*?)content="(.*?)"(.*?)>/i) { $vars->{file_url} = $3; }
	$vars->{keyname_feed} = "YouTube";

	$vars->{post_genre} = "video";
	$vars->{post_type} = "link";


	my $id = &update_record($dbh,$query,"post",$id);
	&edit_record($dbh,$query,"post",$id);
	exit;


}


# -------   Parse CSV -- used by input, requires that you use Text::ParseWords ------


sub parse_csv {
    return quotewords(",",0, $_[0]);
}

sub parse_csandv {
    my ($firstbunch,$lastone) = quotewords(" and ",0, $_[0]);
    my @csvlist = quotewords(",",0, $firstbunch);
    if ($lastone) { push @csvlist,$lastone; }
    return @csvlist;

}


#
# -------   Refield ------------------------------------------------------------
#
# Rebuilds field_definition.pl from database
#

sub refield {

						# Permissions

	return unless (&is_allowed("edit","field"));

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;

														# Create File Header

	my $ds = '$'."base_fields";
	my $output = qq|
		sub set_base_fields {
			\$base_fields = {|;

														# Get Fields Data, and...

	my $sql = qq|SELECT * FROM field|;
	my $sth = $dbh -> prepare($sql);
	$sth -> execute();

														# For each field listed...

	while (my $ref = $sth -> fetchrow_hashref()) {
		my $title = $ref->{field_title};
		my $type = $ref->{field_type};
		my $size = $ref->{field_size};
		next unless ($title && $type && $size);

														# Create field definition text

		$output .= qq|
				$title => {
					title => "$title",
					type => "$type",
					size => "$size"
				},|;
	}

														# Create file footer

	$output .= qq|			};
			return \$base_fields;
			};
			1;|;

														# Print the file

	my $filename = $Site->{st_cgif}."/data/" . $ENV{'SERVER_NAME'} . ".field_definitions.pl";

	open OTPUT,">$filename" or
		&error("$dbh","","","Cannot print fields definition file $filename: $!");
	print OTPUT $output or
		&error("$dbh","","","Cannot print fields definition file $filename: $!");;
	close OTPUT;

														# Return to admin menu

	$vars->{msg} = "New field types table created.";
	&admin_menu($dbh,$query);
}

#
# -------   Refield ------------------------------------------------------------
#
# Rebuilds record cache
#

sub recache {


	my ($dbh,$query) = @_;
	my $vars = $query->Vars;

	return unless (&is_allowed("edit",$vars->{table})); 			# Get variables
	print "Content-type: text/html\n\n";

	my $format = $vars->{format};							# Set Format
	if ($vars->{type}) { $format = $vars->{type}."_".$format; }
	$format = $vars->{table}."_".$format;
	$vars->{force} = uc($format);

	my $sql = qq|SELECT * FROM $vars->{table}|;				# Select Records
	if ($vars->{type}) { $sql .= " WHERE ".$vars->{table}."_type=?"; }
	my $sth = $dbh -> prepare($sql);
	$sth -> execute($vars->{type});
# my $count=0;
	print "Record search: $sql <br /> Recaching $vars->{table} : $vars->{type} : $vars->{format} ";
	while (my $ref = $sth -> fetchrow_hashref()) {
		my $idfield = $vars->{table}."_id";

		my $record_text = &format_record($dbh,
			$query,
			$vars->{table},
			$format,
			$ref);

#		print $record_text;
# $count++; last if ($count > 20);
		print "$ref->{$idfield} - ";
	}

	exit;

}



# -------   Admin Menu: topics ---------------------------------------------

sub admin_topics {

	return unless (&is_viewable("admin","topics")); 		# Permissions

	return qq|<div class="menubox">

		<h4>Build Content Types</h4>
		<p>
		<ul>
		<li><a href="?action=refield">Rebuild Fields List</a></li>
		</ul>

		<h4>Matches</h4>
		<p><b>Caution: Reindexing can take a long time</b><ul>
		<li> <a href="?action=reindex_topics">Reindex Topics</a> (Caution - this could take a long time)
		<li><a href="?action=reindex&db=author">Reindex Authors</a></li>
		<li><a href="?action=reindex&db=journal">Reindex Journals</a></li>
		</ul></p>

	</div>|;

}




# -------   News Rollup ----------------------------------------------------------
#
#	Gives a quick preview of posts slated for upcoming newsletters
#

sub news_rollup {
	my ($dbh,$query) = @_;
	my $vars = $query->Vars;
	print "Content-type: text/html; charset=utf-8\n\n";
	print $Site->{header};
	print "<h1>Content for Today & Future Issues</h1>";

	# Get Data for Today and Future Issues
	my $date = &cal_date(time - (3600*24));	# ie., yesterday
	my $issues = ();
	my $stmt = qq|SELECT * FROM post where post_pub_date >?|;
	my $sthl = $dbh->prepare($stmt);
	$sthl->execute($date);
	my $count = 0;
	while (my $post = $sthl -> fetchrow_hashref()) {
		my $text = qq|<a href="?post=$post->{post_id}">$post->{post_title}</a>
			[<a href="?action=edit&post=$post->{post_id}">Edit</a>]|;
		push @{$issues->{$post->{post_pub_date}}},$text;
		$count++; last if ($count>1000);
	}

	# Sort and Display Content
	my @index = sort keys %$issues;
	foreach my $iss (@index) {
		print "<p><b>ISSUE: $iss</b><br>\n";
		foreach my $pp (@{$issues->{$iss}}) {
			print "- $pp <br/>\n";
		}
		print "</p>\n";
	}
	print $Site->{footer};
	exit;
}


# -------   Autosubscribe All ----------------------------------------------------------
#
#	Autosubscribes all users to given newsletter
#


sub autosubscribe_all {

print "Content-type: text/html; charset=utf-8\n\n";

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;

	print $Site->{header};
	print "<h2>Autosubscribe</h2>";
	my $page = $vars->{newsletter};
	my $stmt = qq|SELECT person_id FROM person|;
	my $pers = $dbh->selectcol_arrayref($stmt);

	# Delete Previous Subscriptions
	&save_subscriptions($dbh,$query);
	my $stmt2 = qq|DELETE FROM subscription WHERE subscription_box=?|;
	my $sth = $dbh->prepare($stmt2);
    	$sth->execute($page);

	print "Subscribe to $page <p>";
	my $crdate = time;
	foreach my $person(@$pers) {
		&db_insert($dbh,$query,"subscription",{subscription_box => $page,
								   subscription_person => $person,
								   subscription_crdate => $crdate});


		print "$person subscribed OK<br>";

	}
	print $Site->{footer};
exit;

}



# -------   Autosubscribe All ----------------------------------------------------------
#
#	Autosubscribes all users to given newsletter
#


sub autounsubscribe_all {

	my ($dbh,$query,$page,$return) = @_;
	my $vars = $query->Vars;

	unless ($return) {
		print "Content-type: text/html; charset=utf-8\n\n";
		print $Site->{header};
		print "<h2>Autosubscribe</h2>";
	}
	$page ||= $vars->{newsletter};
	my $stmt = qq|SELECT person_id FROM person|;
	my $pers = $dbh->selectcol_arrayref($stmt);

	# Delete Previous Subscriptions
	&save_subscriptions($dbh,$query,$page);
	my $stmt2 = qq|DELETE FROM subscription WHERE subscription_box=?|;
	my $sth = $dbh->prepare($stmt2);
    	$sth->execute($page);

	print "<p>All users unsubscribed from page number $page </p>";
	my $crdate = time;

	unless ($return) {
		print $Site->{footer};
		exit;
	}
	return;
}

sub save_subscriptions {

	my ($dbh,$query,$page) = @_;
	my $savefile = $Site->{data_dir}.$Site->{db_name}."_page_".$page."_subscriptions_".time;
	open OUT,">$savefile" or
		&error("$dbh","","","Save subscriptions: Cannot open $savefile: $!");
	my $stmt = qq|SELECT * FROM subscription|;
	my $sthl = $dbh->prepare($stmt);
	$sthl->execute();
	while (my $s = $sthl -> fetchrow_hashref()) {
		print OUT $s->{subscription_box}."\t".$s->{subscription_person}."\t".$s->{subscription_crdate}."\n"
		 or
		&error("$dbh","","","Save subscriptions: Cannot write to $savefile: $!");

	}
	print "<p>Backup of subscriptions saved to $savefile </p>";
	close OUT;
}


# -------   List Records -------------------------------------------------------
#
# List records of a certain type
#
sub admin_list_records {

	my ($dbh,$query,$table) = @_;

	my $output = &list_records($dbh,$query,$table);

	# print output in Admin frame

	&admin_frame($dbh,$query,"List ".$table."s",$output);
}



# -------  Autopost------------------------------------------------------

sub autopost {

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;
	exit unless ($Person->{person_status} eq "admin");
	my $postid = &auto_post($dbh,$query,$vars->{id});
	print "Content-type: text/html\n\n";
	print "Autopost $postid";
	exit;

}

# -------  Autopost------------------------------------------------------

sub postedit {

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;
	exit unless ($Person->{person_status} eq "admin");
	print "Content-type: text/html\n\n";
	my $postid = &auto_post($dbh,$query,$vars->{id});
	my $posttext = &edit_record($dbh,$query,"post",$postid,1);

 	print $posttext;
	exit;

}


# -------   Update Record ------------------------------------------------------                                                   UPDATE

sub update_record {

	my ($dbh,$query,$table,$id_number) = @_;
	my $vars = $query->Vars;



	# print "Content-type: text/html; charset=utf-8\n\n";
	#print "Updating a $table id number $id_number <br>";
	#while (my($vx,$vy) = each %$vars) { print "$vx = $vy <br/>"; }

						# Validate Input

	&error("nil",$query,"","Database not ready") unless ($dbh);
	&error($dbh,$query,"","Table not specified") unless ($table);
	&error($dbh,$query,"","Fishy ID") unless ($id);

							# Permissions

	my $id_field = $table."_id";
	my $record = &db_get_record($dbh,$table,{$id_field=>$id});
	if ($id =~ /new/i) {	return unless (&is_allowed("create",$table)); }
	else { return unless (&is_allowed("edit",$table,$record)); }





						# Clean Input
						# Fix mismatched href quotes

	$vars->{$table."_description"} =~ s/href=('|&#39;|&apos;)(.*?)"/href="$2"/ig; #'





						# Fix relative links
						# (eg. created by TinyMCE)
	if ($vars->{$table."_description"} =~ /\.\.\//) {
		$vars->{$table."_description"} =~ s/\.\.\//$Site->{st_url}/;
	}
	if ($vars->{$table."_content"} =~ /\.\.\//) {
		$vars->{$table."_content"} =~ s/\.\.\//$Site->{st_url}/;
	}
						# Require URL in link
	if ($vars->{post_type} eq "link") {
		unless ($vars->{$table."_link"} =~ /http/i) {
	#		&error($dbh,$query,"","Link must contain 'http'");
		}
	}

	# Remove line feeds in _data
	$vars->{$table."_data"} =~ s/\n//g;
	$vars->{$table."_data"} =~ s/\r//g;
						# Table-specific functions
						# Capitalize titles in Post
	if ($table eq "post") {
		$vars->{$table."_title"} = &capitalize($vars->{$table."_title"});
		$vars->{$table."_name"} = &capitalize($vars->{$table."_name"});
		unless ($vars->{$table."_pub_date"}) {
			$vars->{$table."_pub_date"} = &cal_date(time); }

	} elsif ($table eq "person") {

		if ($vars->{$table."_password"}) {		# Create a Salted Password
			$vars->{$table."_password"} = &encryptingPsw($vars->{person_password}, 4);

		}

	} elsif ($table eq "optlist") {				# Autogenerate Optlist Titles
		$vars->{optlist_table} ||= "table";
		$vars->{optlist_field} ||= "field";
		$vars->{optlist_title} = $vars->{optlist_table} ."_".$vars->{optlist_field};
	} elsif ($table eq "feed") {
		$vars->{msg} .= "YouTube feed detected. ";
		if (($vars->{feed_link} =~ m|youtube\.com/channel/(.*?)$|i) ||
			(($vars->{feed_html} =~ m|youtube\.com/channel/(.*?)$|i) && ($vars->{feed_link} eq ""))) {

			$vars->{feed_link} = qq|http://www.youtube.com/feeds/videos.xml?channel_id=$1|;
			$vars->{msg} .= "Channel $1 converted to RSS URL<p>";
			# https://www.youtube.com/channel/UCvInFYiyeAJOGEjhqJnyaMA
		} elsif ($vars->{feed_link} =~ m|youtube\.com/user/(.*?)$|i) {
			$vars->{feed_link} = qq|http://www.youtube.com/feeds/videos.xml?user=$1|;
			$vars->{msg} .= "User $1 converted to RSS URL <p>";
		}
	}



	&record_convert_dates($table,$vars);



						# Kill spartquotes
	while (my ($vkey,$vval) = each %$vars) {
		$vars->{$vkey} =~ s/\0/,/g;	# Replace 'multi' delimiter with comma
		$vars->{$vkey} =~ s/#!//g;				# No programs!

	}


	if ($id_number eq "new") {			# Uniqueness Constraints
		my $l = "";
		my $name_or_title = &get_key_namefield($vars->{insert_table});
		if (($l = &db_locate($dbh,"post",{post_link => $vars->{post_link}}))        ||
		    ($l = &db_locate($dbh,"feed",{feed_link => $vars->{feed_link}})) 	 ||
		    ($l = &db_locate($dbh,$table,{$name_or_title => $vars->{$name_or_title}})) 	) {
			$vars->{msg} .= qq|<p>Duplicate Entry: <a href="$Site->{st_cgi}admin.cgi?$table=$l">$table $l</a></p>
			<p>If you would like to edit the existing $table then please <a href="$Site->{st_cgi}admin.cgi?$table=$l&action=edit">Click here</a></p>|;
			return "duplicate";
		}
	}

							# Submit and verify record
	$id_number = &form_update_submit_data($dbh,$query,$table,$id_number);

	my $new_record=&db_get_record($dbh,$table,{$table.+"_id"=>$id_number});
	&error($dbh,"","","New $table record not created properly.") unless ($new_record);
	$new_record->{type} = $table;

	#   Submissions will include info about authors, feeds, etc.
	#   Values for these other records are submitted in $vars and always have the prefix 'keyname_'
	#   For example, a field named 'keyname_author' will refer to the name of an author in the 'author' table
	#   The function produces a record in the graph table
	#   It will also create a new record in the other table, if necessary

	&record_graph($dbh,$vars,$table,$new_record);					# Save Graph Records







						# Identify, Save and Associate File

	my $file;
	if ($query->param("file_name")) { $file = &upload_file($query); }		# Uploaded File
	elsif ($vars->{file_url}) { $file = &upload_url($vars->{file_url}); }		# File from URL

	# Create File Record
	if ($file->{fullfilename}) {
		my $file_record = &save_file($file);
		$file_record->{type} = "file";
		my $graph_typeval = "";
		if ($file_record->{file_type} eq "Illustration") { $graph_typeval = $vars->{file_align} . "/" . $vars->{file_width}; }
		else { $graph_typeval = $mime; }
		&save_graph($file_record->{file_type},$new_record,$file_record,$graph_typeval);



	# Make Icon (from smallest uploaded image thus far)

		if ($file_record->{file_type} eq "Illustration") {

			my $icon_image = &item_images($table,$new_record->{$table."_id"},"smallest");

			my $filename = $icon_image->{file_title};
			my $filedir = $Site->{st_urlf}."files/images/";
			my $icondir = $Site->{st_urlf}."files/icons/";
			my $iconname = $table."_".$new_record->{$table."_id"}.".jpg";

			my $tmb = &make_thumbnail($filedir,$filename,$icondir,$iconname);
		}
	}





						# Insert Topic Matches
#	if (($table eq "post") || ($table eq "link")) {
#		my $matchstr = $vars->{$fields->{title}} . $vars->{$fields->{description}};
#		&insert_topic_matches($dbh,$query,$matchstr,$table,$id_number);
#		my $matchstr = $vars->{$author};

						# Topic Matches

#		my ($matchmsgstr,$matchmsgids) =
#			&insert_matches($dbh,$query,$vars->{$title}.$vars->{$description},
#				$table,$id_number,"topic","");
#		$vars->{$table."_authorstr"} = $matchmsgstr;
#		$vars->{$table."_authorids"} = $matchmsgids;

						# Author Matches

#		my ($matchmsgstr,$matchmsgids) =
#			&insert_matches($dbh,$query,$vars->{$author},$table,$id_number,"author","");
#		$vars->{$table."_authorstr"} = $matchmsgstr;
#		$vars->{$table."_authorids"} = $matchmsgids;


						# Journal Matches

#		my ($matchmsgstr,$matchmsgids) =
#			&insert_matches($dbh,$query,$vars->{$journal},$table,$id_number,"journal","");
#		$vars->{$table."_journalstr"} = $matchmsgstr;
#		$vars->{$table."_journalids"} = $matchmsgids;


						# Update the input item with matches

#		$id_number = &db_update($dbh,$table, $vars, $id_number);
#	}




						# If Topic, Reindex Topic

	if (($table eq "topic") && ($vars->{topic_reindex} eq "yes")) {

		&reindex_topics($dbh,$query,$id_number);
		$vars->{msg} .= "Topic number $id_number successfully reindexed.<br/>";
	}

						# If publish selected, publish

	if ($vars->{post_facebook} || $vars->{post_twitter}) {
		$vars->{msg} .= &publish_post($dbh,$table,$id_number);
	}



#	print "Content-type: text/html; charset=utf-8\n\n";

	$vars->{updated_table} = $table;
	$vars->{updated_title} = $vars->{$table."_title"};



    return $id_number;


}

#
#   	Saves file
#
#   	Expects input from either upload_file() or upload_url()
#       input hash $file needs:
# 		$file->{fullfilename}   - full directory and file name of upload file


sub save_file {

	my ($file) = @_;

	my ($ffdev,$ffino,$ffmode,$ffnlink,$ffuid,$ffgid,$ffrdev,$ffsize, $ffatime,$ffmtime,$ffctime,$ffblksize,$ffblocks)
			= stat($file->{fullfilename});
	my $ffwidth = "400";


	my $mime;
	if (&new_module_load($query,"MIME::Types")) {
		use MIME::Types;
		my MIME::Types $types = MIME::Types->new;
			my MIME::Type  $m = $types->mimeTypeOf($file->{fullfilename});
			$mime = $m;
	} else {
		$mime="Unknown; install MIME::Types module to decode upload file mime types";
		$vars->{msg} .= "Could not determine mime type of upload file; install MIME::types module<br>";
	}

	my $file_type; if ($mime =~ /image/) {
		$file_type = "Illustration";



	} else { $file_type = "Enclosure"; }



	my $file_record = gRSShopper::Record->new(
		file_title => $file->{file_title},
		file_dirname => $file->{file_dir}.$file->{file_title},
		file_dir => $file->{file_dir},
		file_mime => $mime,
		file_size => $ffsize,
		file_post => $id_number,
		file_link => $vars->{$table."_link"},
		file_crdate => time,
		file_creator => $Person->{person_id},
		file_type => $file_type,
		file_width => $ffwidth,
		file_align => "top");



	# Create File Record
	$file_record->{file_id} = &db_insert($dbh,$query,"file",$file_record);
	$vars->{msg} .= "File $upload_filename inserted as file number $file_id <br>";


	if ($file_record->{file_id}) { return $file_record; }
	else { &error($dbh,"","","File save failed: $! <br>"); }


}



# -------   Set File Upload Directory --------------------------------------------------------

sub file_upload_dir {

	my ($ff) = @_;
	my $filetype = "";
	my $dir = "";

	if ($ff =~ /\.jpg|\.jpeg|\.gif|\.png|\.bmp|\.tif|\.tiff/i) {
		$filetype = "image"; $dir = $Site->{up_image};
	} elsif ($ff =~ /\.doc|\.txt|\.pdf/i) {
		$filetype = "doc"; $dir = $Site->{up_docs};
	} elsif ($ff =~ /\.ppt|\.pps/i) {
		$filetype = "slides"; $dir = $Site->{up_slides};
	} elsif ($ff =~ /\.mp3|\.wav/i) {
		$filetype = "audio"; $dir = $Site->{up_audio};
	} elsif ($ff =~ /\.flv|\.mp4|\.avi|\.mov/i) {
		$filetype = "video"; $dir = $Site->{up_video};
	} else {
		$filetype = "other"; $dir = $Site->{up_files};
	}

	return ($filetype,$dir);
}

# -------   Edit Record --------------------------------------------------------
#
# Administrator's general record editing function
#

sub edit_record {

	# Get variables

	my ($dbh,$query,$table,$id_number,$viewer) = @_;
	$vars->{force} = "yes";	# Never use cache on edit

	# print "Content-type: text/html; charset=utf-8\n\n";


	# Define Form Contents

	my $form_text = &main_window($tabs,"Edit",$table,$id_number,$vars);
	#&form_editor($dbh,$query,$table,$id_number);

	$form_text =~ s/&#39;/'/mig;
  $form_text = qq|<script src="http://www.downes.ca/assets/js/jquery.min.js"></script>
       <script src="http://www.downes.ca/assets/js/grsshopper_admin.js">|.$form_text;
	if ($viewer) { return $form_text; }							# Send form text to viewer, or
	else { &admin_frame($dbh,$query,"Edit $table",$form_text); } 				# Print Output


}






# -------  Approve Feed --------------------------------------------------------
#
#   Removes a graph record

sub remove_key {

	my ($dbh,$query,$table,$id) = @_;
	my $vars = $query->Vars;
	unless ($vars->{remove}) {
		$vars->{msg} .= "No remove instructions";
		return;
	}
	my ($rtab,$rid) = split /\//,$vars->{remove};
	my $sql = "DELETE FROM graph WHERE graph_tableone=? AND graph_idone = ? AND graph_tabletwo =? AND graph_idtwo = ?";
	my $sth = $dbh->prepare($sql);
    	$sth->execute($table,$id,$rtab,$rid);
	my $sql = "DELETE FROM graph WHERE graph_tableone=? AND graph_idone = ? AND graph_tabletwo =? AND graph_idtwo = ?";
	my $sth = $dbh->prepare($sql);
    	$sth->execute($rtab,$rid,$table,$id);
	return;

}


#--------------------------------------------------------
#
#	Editor Functions
#
#--------------------------------------------------------




# -------  Approve a Record -----------------------------------------------------

# Change record_status to "Published"
# This is used to filter displays

sub record_approve {

	my ($dbh,$query,$table,$id) = @_;
	my $vars = $query->Vars;

	return unless (&is_allowed("approve",$table));
	my $readername = $Person->{person_name} || $Person->{person_title};

	my $approval;
	if ($table eq "feed") {	$approval = "A"; } else { $approval = "Published"; }
	&db_update($dbh,$table,{$table."_status"=>$approval},$id);
	&db_cache_remove($dbh,$table,$id);



								# Return message
	$vars->{msg} .= qq|New $table ($id) approved by $readername |.
		qq| View at: <a href="$Site->{st_url}$table/$id">$Site->{st_url}$table/$id</a></p>|;
	$vars->{api} = 	"Approved $wp->{post_title}";		# Needs to be fixed
	$vars->{title} = qq|$table ($id) approved by $readername|;


	&send_notifications($dbh,$vars,$table,$vars->{title},$vars->{msg});
	&report_action($vars->{title});
	exit;

}

# -------  Reject or a Record -----------------------------------------------------

# Change record_status to "Retired"
# This is used to filter displays

sub record_retire {

	my ($dbh,$query,$table,$id) = @_;
	my $vars = $query->Vars;

	return unless (&is_allowed("approve","feed"));
	my $readername = $Person->{person_name} || $Person->{person_title};

	my $approval;
	if ($table eq "feed") {	$retired = "R"; } else { $retired = "Retired"; }

	&db_update($dbh,$table,{$table."_status"=>$retured},$id);
	&db_cache_remove($dbh,$table,$id);



								# Return message
	$vars->{msg} .= qq|New $table ($id) rejected by $readername |.
		qq| View at: <a href="$Site->{st_url}$table/$id">$Site->{st_url}$table/$id</a></p>|;
	$vars->{api} = 	"Rejected $wp->{post_title}";		# Needs to be fixed
	$vars->{title} = qq|$table ($id) rejected by $readername|;


	&send_notifications($dbh,$vars,$table,$vars->{title},$vars->{msg});
	&report_action($vars->{title});
	exit;

}

# -------  Report Action -----------------------------------------------------

# Routes the response to an action depending on where it came from
# so we can use the same functions to manage commands from API, email and editor
# Eventually I might just combine this with admin_frame()

sub report_action {

	my ($action,$apiresponse) = @_;


	if ($vars->{from} eq "email") {
		&admin_frame($dbh,$query,$action,$vars->{msg});
		exit;
	} elsif ($vars->{from} eq "api") {
		print "Content-type: text/html\n\n";
		print $vars->{api};
		exit;
	} else {
		&admin_list_records($dbh,$query,$table);
		exit;
	}


}


# -------  Count  --------------------------------------------------------

# Counts the number of items in feeds, journals, whatever
# If feed specified, returns the value, otherwise, simply updates DB
# ie., counting X in Y

sub count_feed {
#print "Content-type: text/html; charset=utf-8\n\n";
	my ($dbh,$query) = @_;

	my $X = $vars->{count};
	my $Y = $vars->{in};

	my $idfield = $X."_id";
	my $id = $vars->{$idfield};
	my $tracefield = $Y."_".$X."id";
	my $countfield = $X."_".$Y."s";			# eg. feed_links

	if ($id) {
		my $count = &db_count($dbh,$Y,{$idfield => $id});
		return $count;
	} else {
		my $stmt = qq|SELECT $idfield from $X|;
		my $Xs = $dbh->selectcol_arrayref($stmt);
		foreach my $xitem (@$Xs) {
			my $count = &db_count($dbh,$Y,"WHERE $tracefield = '$xitem'");
			&db_update($dbh,$X,{$countfield => $count},$xitem);
		}
		$vars->{msg} .= "Number of $X counted for each $Y and database updated.";
	}

	&admin_menu($dbh,$query);
}

# --------------------------------------------------------------------------------------
#
#          API requests
#
# -------------------------------------------------------------------------------------

# Access API

sub access_api {

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;

print "Content-type: text/html\n\n";
print "Accessing API <p>";

  my $server_endpoint = $vars->{url};
  my $postdata = $vars->{postdata};
  my $message;  # from remote server

  if ($vars->{method} eq "get") {

		use LWP::Simple;
		$message = get($server_endpoint);
		unless (defined $message) {
			 print "HTTP GET Error!";
			 return;
		}


	} else {

  	use LWP::UserAgent;

  	my $ua = LWP::UserAgent->new;



    # set custom HTTP request header fields
    my $req = HTTP::Request->new(POST => $server_endpoint);
    $req->header('content-type' => 'application/json');

    # add POST data to HTTP request body
    $req->content($postdata);

    my $resp = $ua->request($req);
    unless ($resp->is_success) {

      print "HTTP POST error code: ", $resp->code, "\n";
      print "HTTP POST error message: ", $resp->message, "\n";
			return;
    }

		$message = $resp->decoded_content;

  }

		#print "Received reply: $message\n";
		use JSON::Parse 'parse_json';
		my $response_data = parse_json($message);
		#print $response_data->{entries};
		foreach my $entry (@{$response_data->{entries}}) {
			print qq|
				<b><a href="$entry->{course_url}">$entry->{course_title}</a></b><br>$entry->{course_description}<br><br>
			|;

			#while (my ($x,$y) = each %$entry) {	print "$x = $y <br>";	}
		}

		print qq|<form><textarea cols=60 rows=20>$message</textarea></form>|;
		#print $response_data;

}
#--------------------------------------------------------
#
#       CRON TASKS
#
#	Cron Functions
#	Perform Cron Function once a minute
#
#--------------------------------------------------------

sub cron_tasks {

	my ($dbh,$query) = @_;

	my $log = "";	# Flag that indicates whether an activity was logged
	my $loglevel = 0;


	my $content = "Cron Report \n\n";
	$content .= "Site Context: $Site->{context} \n\n";
	$content .="0 $ARGV[0] 1 $ARGV[1] 2 $ARGV[2] 3 $ARGV[3] \n";
	$content .= qq|
	Home: $Site->{st_home}
	Site URL: $Site->{st_url}
	Script: $Site->{script}
	|;
	print $content;

										# Confirm cron key
	my $cronkey = $ARGV[1];
	unless ($Site->{cronkey} eq $cronkey) {
		print "Error: Cron key mismatch. $vars->{cronkey} must match the value of the cronkey set in $Site->{st_name} admin \n";
		&send_email("stephen\@downes.ca","stephen\@downes.ca","Cron Error in cron - $Site->{st_url}","Args: $ARGV[0] 1 $ARGV[1] 2 $ARGV[2] 3 $ARGV[3] <p>Error: Cron key mismatch. $ARGV[1] must match the value of the cronkey set in $ARGV[0] admin\n");
		exit;
	}

										# Get the time
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	my @wdays = qw|Sunday Monday Tuesday Wednesday Thursday Friday Saturday|;
	my $weekday = @wdays[$wday];
	$year += 1900;
	$mon++;if ($mon < 10) { $mon = "0".$mon; }
	if ($min < 10) { $min = "0".$min; }
	if ($mday < 10) { $mday = "0".$mday; }
	if ($loglevel > 5) { $log .= "Calculated time as: Hour = $hour and minute = $min\n"; }



										# Autopublish
	my $asql=""; my $amode;
	if ($weekday eq "Sunday" && $hour eq "23" && $min eq "54")
		{ $amode = "Weekly"; $asql = qq|SELECT * FROM page WHERE page_autopub='yes' AND page_autowhen='Weekly'|; }
	elsif ($hour eq "23" && $min eq "50") { $amode = "Daily";  $asql = qq|SELECT * FROM page WHERE page_autopub='yes' AND page_autowhen='Daily'|; }
	elsif ($min eq "40") { $amode = "Hourly"; $asql = qq|SELECT * FROM page WHERE page_autopub='yes' AND page_autowhen='Hourly'|; }

	if ($amode) { $log .= "Autopublish mode triggered: $amode \n"; }
	if ($asql) {
		my $asth = $dbh -> prepare($asql);
		$asth->execute();
		if ($dbh->errstr()) { &send_email("stephen\@downes.ca","stephen\@downes.ca","Autopublish Error",$dbh->errstr()); }
		while (my $npage = $asth -> fetchrow_hashref()) {
			&publish_page($dbh,$query,$npage->{page_id},0);
			if ($loglevel > 1) { $log .= "Autopublish $npage->{page_id} - $npage->{page_title}\n"; }
		}
		$asth->finish;
	}

										# Newsletters

	my $sql = qq|SELECT * FROM page WHERE page_subhour=? AND page_submin=? AND (page_subwday LIKE ? OR page_submday LIKE ?)|;
	my $sth = $dbh -> prepare($sql);

	$sth -> execute($hour,$min,'%'.$weekday.'%','%'.$mday.'%');
	# if ($loglevel > 1) { $log .= "Sending newsletter? - $npage->{page_title}\n"; }
	while (my $npage = $sth -> fetchrow_hashref()) {
			if ($loglevel > 1) { $log .= "Yes\n"; }
		next unless ($npage->{page_subsend} eq "yes");
		my $report = &send_nl($dbh,$query,$npage->{page_id},"subscribers",0);
		if ($loglevel > 1) { $log .= "Sent newsletter - $npage->{page_title}\n"; }
	}

	$sth->finish;


$Site->{st_harvest_on} = "yes";

										# Harvester
	if ($Site->{st_harvest_on} eq "yes") {


		my $dividend = ($mday * 24 * 60) + ($hour * 60) + $min;
		my $divisor = $Site->{st_harvest_int}; $divisor ||= 60;
		if ($dividend % $divisor == 0) {
			$hn = "Harvesting";
			my $harvester = $Site->{st_cgif} . "harvest.cgi";
			my $siteurl = $Site->{site_url}; $siteurl =~ s|http://||;$siteurl =~ s|/||;
			my $status = system($harvester,$siteurl,$Site->{cronkey},"queue");
			if ($loglevel > 5) { $log .= "\nHarvester run, Status: $status\n"; }
		}

  #  &send_email("stephen\@downes.ca","stephen\@downes.ca","Harvester - $Site->{st_url}","\nHarvester run, Status: $status\n");

	}


	$Site->{log_items} eq "yes";

										# Hourly Tasks
	if ($min eq "19") {
		my $deletelink = '\'%wxMONCTON%\'';				# Removes hourly environment Canada weather updates after an hour
		my $dsql = qq|select link_id FROM link WHERE link_link LIKE $deletelink|;
		my $sthl = $dbh->prepare($dsql);
		$sthl->execute();
		while (my $stale_link = $sthl -> fetchrow_hashref()) {
			&record_delete($dbh,$query,"link",$stale_link->{link_id});
			if ($loglevel > 2) { $log .= "Deleted bad link $stale_link->{link_id} \n"; }
		}


	}

										# Daily Tasks


	if ($hour eq "23" && $min eq "44") {					# Make Fresh Links Stale
		my $staledate = time - (24 * 60 * 60);
		my $dsql = qq|UPDATE link SET link_status = 'Stale' WHERE (link_status = 'Fresh'
			OR link_status = 'RSS 0.91 Fresh' OR link_status = 'fresh') && link_crdate < '$staledate'|;

		my $affected = $dbh->do($dsql);
		if ($loglevel > 2) { $log .= "Making fresh links stale \n"; }
		if ($loglevel > 0) {
			$log .= "Error making links stale in cron_tasks() : $dbh->errstr" if (!affected); # report errors
			$log .= "No links made stale in cron_tasks()" if ($affected eq '0E0'); # report no insert/update
		}

										# Clean Up Audio Downloads
										# See Admin 'Harvester' screen for settings
		my $audio_dir = $Site->{st_urlf}.$Site->{audio_download_dir};
		if (-d $audio_dir) {
			my $audio_files_expire = $Site->{audio_files_expire} || 1;
			$audio_dir =~ s/\/$//;	# Remove trailing slash
			opendir (DIR, "$audio_dir/");
			my @audio_files = grep(/.txt/,readdir(DIR));
			closedir (DIR);

			foreach $audio_file (@audio_files) {
				if (-M "$dir/$FILES" > $audio_files_expire) { unlink("$dir/$FILES"); }
			}
		}





	}

	if ($hour eq "23" && $min eq "30") {					# Make Stale Links Disappear

		my $disappeardate = time; # - (72 * 60 * 60);
#my $msg = "Time:".time."\nDisp: $disappeardate \n\n";
#&send_email("stephen\@downes.ca","stephen\@downes.ca","Disappearing stale links","$msg");
		my $dsql = qq|select link_id FROM link WHERE (link_status = 'Stale'
			OR link_status = 'RSS 0.91 stale' OR link_status = 'stale') && link_crdate < '$disappeardate'|;
		my $sthl = $dbh->prepare($dsql);
		$sthl->execute();
		while (my $stale_link = $sthl -> fetchrow_hashref()) {
			&record_delete($dbh,$query,"link",$stale_link->{link_id});
			if ($loglevel > 2) { $log .= "Deleted stale link $stale_link->{link_id} \n"; }
		}
	}

										# Clear the cache
	if ($hour eq "02" && $min eq "10") {
		&cache_clear($dbh,$query);
	}



	if ($hour eq "23" && $min eq "50") {				# Reset Hits to 0

		&rotate_hit_counters($dbh,$query,"post");			# Reset post hit counters
		&rotate_hit_counters($dbh,$query,"page");			# Reset page hit counters

	}


#	unless ($log) { &log_cron($log); }  # Sends empty log report

	my $logtitle = "$Site->{st_name} cron log report for ".localtime(time);
	if ($log && $loglevel > 0) {
		$log = $logtitle."\n\n".$log;
		&send_email("stephen\@downes.ca","stephen\@downes.ca",$logtitle,"$log");
	}



	exit;
}


sub cache_clear {

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;
	$Site->{pg_update} ||= 86000;
	my $expired = time - $Site->{pg_update};
$sth = $dbh->prepare("TRUNCATE TABLE cache");

$sth->execute();
#	my $csql = qq|delete FROM cache WHERE cache_update < ?|;
#	my $sth = $dbh->prepare($sql);
#	print $csql."<br> $expired";
 #       my $affected = $sth->execute($expired);


	#my $affected = $dbh->do($csql);
	print "$affected rows cleared <br>";

}



#--------------------------------------------------------                                                                #      NEWSLETTER
#
#	Publishing and Newsletter Functions
#
#--------------------------------------------------------




sub send_nl {

	my ($dbh,$query,$page_id,$send_list,$verbose) = @_;
	my $vars = $query->Vars;
	my $report = "Send Newsletter\n\n";

	return unless (&is_allowed("send","newsletter"));	# Admin Only

	$page_id ||= $vars->{page_id};				# ID of page to send
	$send_list ||= $vars->{send_list};				# Send to admin or subscribers
	$verbose ||= $vars->{verbose};				# Silent (0) (for cron) or verbose (1)
	my $date = &nice_date(time);
	my $today = &day_today;

	if ($verbose) { 					# Print web page header
		$Site->{header} =~ s/\Q[*page_title*]\E/Send Newsletter/g;
		$Site->{header} =~ s/\Q<page_title>\E/Send Newsletter/g;
		print "Content-type: text/html; charset=utf-8\n\n";
		print $Site->{header};
		print "<h2>Send Newsletter</h2>";
		print "<p>Today is $today, $date.</p>";
	}

								# Get newsletter page data
	my $record = &db_get_record($dbh,"page",{page_id=>$page_id});
	if ($verbose) { print "<p>Preparing email. "; }
	my ($pgcontent,$pgtitle,$pgformat,$pgarchive,$keyword_count) = &publish_page($dbh,$query,$page_id,0);
	$pgtitle .= " ~ $date";
	if ($verbose) { print "Sending page: $pgtitle </p>\n"; }
	$report .= "$pgtitle \n\n";

								# Do not send empty newsletters
	unless ($keyword_count) {
		&send_email("stephen\@downes.ca","stephen\@downes.ca","Failed content",
			"No new content; no newsletter sent.".$content.$status);
		if ($verbose) { print "<p>No new content for $pgtitle; no newsletter sent.</p>"; print $Site->{footer}; }
		$report .= "No new content; no newsletter sent. \n\n";
		return;
	}


								# Get subscriber List
	my $subscribers = {}; my $stmt;
	if ($send_list eq "all_users") { $stmt = "SELECT person_id FROM person";	}
	else { $stmt = "SELECT subscription_person FROM subscription WHERE subscription_box='$page_id'";	}
	$report .= "Sending to $send_list\n\n";

	$subscribers = $dbh->selectcol_arrayref($stmt);

								# Loop through subscriber list

	my $count = 0;
	foreach my $subscriber (@$subscribers) {
		my $subdata = &db_get_record($dbh,"person",{person_id=>$subscriber});
		if ( ($subdata->{person_email}) &&
		     ( ($send_list eq "subscribers") ||
		       ($send_list eq "all_users") ||
		       ($send_list eq "admin" && $subdata->{person_status} eq "admin") ) ) {
			$count++;
			my $customcontent = $pgcontent;
			$customcontent =~ s/SUBSCRIBER/$subdata->{person_email}/sg;				# Customize
			$customcontent =~ s/PERSON/$subdata->{person_id}/sg;
			$customcontent =~ s/SUBSCRIBER/$subscriber/sg;


			&send_email($subdata->{person_email},$Site->{st_pub},$pgtitle,$customcontent,$pgformat);
			$report .= ": $subdata->{person_email}\n";
			if ($verbose) {
				if ($count < 10) { print "&nbsp"; }
				if ($count < 100) { print "&nbsp"; }
				if ($count < 1000) { print "&nbsp"; }
				print "$count - $subdata->{person_email}\n<br>";

			}
		}
	}

	my $cmg = "$count newsletters sent.";
	if ($count == 1) { $cmg = "1 newsletter sent."; }
	if ($verbose) {
		print "<hr><p>$cmg newsletter sent.</p>";
		print $Site->{footer};
	}
	$report .= "\n$cmg.\n\n";
	if ($dbh) { $dbh->disconnect; }		# Close Database and Exit
	return $report;

}



# -------   Admin Report -------------------------------------------------------

sub admin_report {

	my ($dbh,$query,$count) = @_;
	my $vars = $query->Vars;
	my $ndate = &nice_date(time);

	my $subject - "Statistics for $ndate from $Site->{st_name}";
	$subject .= &nice_date(time);

	my $tag = $Site->{st_tag};
	$tag =~ s/#//;


	my ($oc,$op,$of,$ol,$ot,$om);
	open FSAVEIN,"/var/www/cgi-bin/data/".$Site->{st_name}."_fsave.txt";
	while (<FSAVEIN>) {
		chomp;
		($oc,$op,$of,$ol,$ot,$om) = split "\t",$_;
		last;
	}
	close FSAVEIN;


	my $subCount = $dbh->selectrow_array(qq{SELECT count(*) FROM subscription},undef);
	my $personCount = $dbh->selectrow_array(qq{SELECT count(*) FROM person},undef);
	my $feedCount = $dbh->selectrow_array(qq{SELECT count(*) FROM feed},undef);

	my $lsql = qq|SELECT count(*) FROM link WHERE (link_title REGEXP '$tag' OR link_description REGEXP '$tag' OR link_category REGEXP '$tag') AND link_type = 'text/html'|;
	my $linkCount = $dbh->selectrow_array($lsql);

	my $tsql = qq|SELECT count(*) FROM link WHERE link_type = 'twitter'|;
	my $twitterCount = $dbh->selectrow_array($tsql);

	my $msql = qq|SELECT count(*) FROM link WHERE link_type = 'moodle'|;
	my $moodleCount = $dbh->selectrow_array($msql);

	my $msql = qq|SELECT count(*) FROM link WHERE link_type = 'diigo'|;
	my $diigoCount = $dbh->selectrow_array($msql);


	&log_status($dbh,$query,"General Stats","headers:Subscriptions,Persons,Feeds,Blog Posts,Twitter,Moodle,Diigo");
	&log_status($dbh,$query,"General Stats","$subCount,$personCount,$feedCount,$linkCount,$twitterCount,$moodleCount,$diigoCount");


	my $content = qq|Statistics for $ndate from $Site->{st_name}:\n|;
	$content .= "Subscriptions: Total: $count ; Since last: ".($count - $oc)."\n";
	$content .= "Persons:  Total: $personCount  ; Since last: ".($personCount - $op)."\n";
	$content .= "Feeds:  Total: $feedCount  ; Since last: ".($feedCount - $of)."\n";
	$content .= "Blog Posts  Total: $linkCount ; Since last: ".($linkCount - $ol)." \n";
	$content .= "Twitter: Total:  $twitterCount  ; Since last: ".($twitterCount - $ot)."\n";
	$content .= "Moodle:  Total: $moodleCount ; Since last: ".($moodleCount - $om)." \n";

	my $sql = qq|SELECT person_email FROM person WHERE person_status='admin'|;


	my $ary_ref = $dbh->selectcol_arrayref($sql);
	foreach my $admin (@$ary_ref) {
		next unless $admin =~ /downes/i;
		&send_email($admin,$Site->{em_from},$subject,$content,"html");

	}



}





# -------  Rotate Hit Counters -----------------------------------------------------------

sub rotate_hit_counters {

	my ($dbh,$query,$table) = @_;


	# Set default variables for current table
	my $hitsfield = $table."_hits";
	my $idfield = $table."_id";
	my $message_text = "Hits record for today for $Site->{st_name}.<p><p>\n";

	# For each record with a hit today
	my $sql = "SELECT $idfield,$hitsfield FROM $table WHERE $hitsfield > 0";
	$message_text .= $sql;

	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while (my $record = $sth -> fetchrow_hashref()) {


		# Reset Daily Hits to 0
		$message_text .= "Record $record->{$idfield} found $record->{$hitsfield} and reset $hitsfield to 0  <br>\n";
		my $usql = "UPDATE $table SET $hitsfield = ? WHERE $idfield = ?";
		my $usth = $dbh->prepare($usql);
		$usth->execute("0",$record->{$idfield});

	}

	$message_text .= "<br>Done";
	&send_email("stephen\@downes.ca","stephen\@downes.ca","Rotating Hits Counter",
		$message_text);

	return;
}


# -------  Format Content -----------------------------------------------------------


sub make_heading {
	my ($script) = @_;
	return unless ($script->{heading});
	my $heading = "";
	if ($script->{format} =~ /txt/) { $heading = "\n\n$script->{heading}\n\n"; }
	else {	$heading = "<h1>$script->{heading}</h1>\n"; }
	return $heading;
}

sub make_next_link {
	my ($dbh,$vars,$options,$person,$script) = @_;
	my @optlist; my $optstring;
	while (my($ox,$oy) = each %$script) { my $st = "$ox=$oy"; push @optlist,$st; }
	$optstring = join ";",@optlist;
	return "http://www.downes.ca/cgi-bin/page.cgi?".$optstring;
}





# -------  DB Creator IP ------------------------------------------------------------

# Returns the creator IP for a record given table and IP
# Used to delete spam

sub db_record_crip {

	my ($dbh,$table,$value) = @_;
	return unless ($value);					# Never compare blank values
	my $stmt = "SELECT ".$table."_crip FROM $table WHERE ".$table."_id='$value'";
	my $ary_ref = $dbh->selectcol_arrayref($stmt);
	return $ary_ref->[0];
}




sub day_today {

	# What day is it Today? Return the name of the day
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	my @days = ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
	return $days[$wday];
}



# -------   Capitalize ---------------------------------------------------------

# For titles
# Adapted from Joseph Brenner >  Text-Capitalize >  Text::Capitalize
# http://search.cpan.org/~doom/Text-Capitalize/Capitalize.pm

sub capitalize {

	my $sentence = shift;
return $sentence;
	$sentence =~ s/&apos;/'/ig;				# '
	$sentence =~ s/&#39;/'/ig;
	my $words; my @words;

	my $title = shift; my $first; my $last;
	my $new_sentence;

								# Defines a word array
	my $word_rule =  qr{ ([^\w\s]*)   			# $1 - leading punctuation
                   ([\w']*) #'   				# $2 - the word itself
                   ([^\w\s]*)  					# $3 - trailing punctuation
                   (\s*)       					# $4 - trailing whitespace
                 }x ;

								# Define exceptions
	my @exceptions = qw(a an the and or nor for but so yet
		to of by at for but in with has de von);
	my $exceptions_or = join '|', @exceptions;
	my $exception_rule = qr/^(?:$exceptions_or)$/oi;

	my $i = 0;						# Extract Words
	while ($sentence =~ /$word_rule/g) {
		if ( ($2 ne '') or $1 or $3 or ($4 ne '') ) {
			$words[$i] = [$1, $2, $3, $4];
			$i++;
		}
	}

	$first = 0;						# For each word...
	$last = @words+0;
	for (my $i=$first; $i<=$last; $i++) {
		my $punct_leading; my $word; my $punct_trailing; my $spc;
       		{  						# Spoof 'continue'
		if ($i >= 0){ $punct_leading = $words[$i]; } else { $punct_leading = ""; }
		$word = $words[$i];
		$punct_trailing = $words[$i+1];
		$spc = $words[$i+2];

#		($punct_leading, $word, $punct_trailing, $spc) = ( @{ $words[$i] } );

		$_ = $word;

		next if ( /[[:upper:]]/ );			# Skip special caps eg. iMac
		next if ( /^[[:upper:]]+$/);

		if ( /^[dl]'/) { #'				# Skip special french cases
			s{ ^(d') (\w) }{ lc($1) . uc($2) }iex;
			s{ ^(l') (\w) }{ lc($1) . uc($2) }iex;
			if ( ($i == $first) or ($i == $last) ) {
				$_ = ucfirst;
			}
			next;
		}

		if ( ($i == $first) or ($i == $last) ) {	# Capitalize first and last
			$_ = ucfirst( lc );
			next;
		}

 								# Skip exceptions
		if ( /$exception_rule/ ) {
			$_ = lc;
		} else {
			$_ = ucfirst( lc );			# Cap the rest
		}

       		} continue {
								# Append word to title
			$new_sentence .=  $punct_leading . $_ . $punct_trailing . $spc;
		}

	}  # end of per word for loop

	# Fix upper-case contractions
	$new_sentence =~ s/(\S')(\S)/$1\l$2/ig;
	$new_sentence =~ s/'/&#39;/ig;  #'

	return $new_sentence;
}


sub moderate_meeting {

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;

	unless ($vars->{meeting_name}) { $vars->{meeting_name} = "Administrator Meeting"; }
	unless ($vars->{meeting_id}) { $vars->{meeting_id} = "12345"; }


	&bbb_join_as_moderator($vars->{meeting_id},$Person->{person_name},$Person->{person_title});

	exit;



}




#
# Don't Delete these
# They're actually used by gRSShopper.pl
#

# -------   Header ------------------------------------------------------------

sub header {

	my ($dbh,$query,$table,$format,$title) = @_;
	my $template = "admin_header";

	return &template($dbh,$query,$template,$title);

}

# -------   Footer -----------------------------------------------------------

sub footer {

	my ($dbh,$query,$table,$format,$title) = @_;
	my $template = "admin_footer";
	return &template($dbh,$query,$template,$title);

}


sub fix_graph() {

	#   Submissions will include info about authors, feeds, etc.
	#   Values for these other records are submitted in $vars and always have the prefix 'keyname_'
	#   For example, a field named 'keyname_author' will refer to the name of an author in the 'author' table
	#   The function produces a record in the graph table
	#   It will also create a new record in the other table, if necessary
print "Content-type: text/html\n\n";
print "Posts.<p>";
	my $sth = $dbh->prepare("SELECT * FROM post");
	$sth -> execute();
	my $ccount=0; my $articles;my $comments; my $links; my $other;
	while (my $c = $sth -> fetchrow_hashref()) {
		$ccount++;
		if ($c->{post_type} =~ /article/) { $articles++; }
		elsif ($c->{post_type} =~ /link/) { $links++; }
		elsif ($c->{post_type} =~ /comment/) { $comments++; }
		else { $other++; }
		next unless ($c->{post_type} =~ /link/);
		#last if ($ccount > 5);
		$c->{post_author} =~ s/Reviewed by//i;
		$c->{post_author} =~ s/, eds\.//i;
		print qq|$ccount : |.$c->{post_id}.qq| (|.$c->{post_type}.qq|) |.$c->{post_title}.qq|, |;
		print qq||.$c->{post_authorname}.qq|, |;
		print qq||.$c->{post_author}.qq|<br>|;
		print qq||.$c->{post_journal}.qq|<br>|;

		$c->{keyname_author} = $c->{post_author};
		$c->{keyname_feed} = $c->{post_journal};
	&record_graph($dbh,$c,"post",$c);					# Save Graph Records
	}
	print "<p>Links: $links  Comments:  $comments  Articles: $articles  Other: $other <p>";
	$sth->finish();

exit;

}

# -------------------------------------------------------------------------------------------------------------
#
#                                   Extract Nouns
#
# This is a set of functions to study the text of a post and extract words of significance. It works with an
# author, presenting candidates for categorization as author, organization, company, etc., and identifying
# associations between them
#
#
# --------------------------------------------------------------------------------------------------------------


sub extract_nouns {

    my ($dbh,$query,$table,$id) = @_;
    	my $vars = $query->Vars;
#print "Content-type: text/html\n\n";
    my $record = &db_get_record($dbh,$table,{$table."_id"=>$id});
    my $str; #contents to be analyzed


    # Get the content we're studying
    if ($table eq file) {
        my $filename = $Site->{st_urlf}.$record->{file_dirname};
        my $url;my $title;my $descr;
        open IN,"$filename";
        while(<IN>) {

					  # Parse string
            chomp;
						my $carryover = $_;
            my @stuff = split ' - ',$carryover;
            my $title = shift @stuff;
            next unless ($tit);
            my $url = shift @stuff;

						# If we have something to save, save it
            if ($url =~ /http/) {

                    $vars->{link_title} = $tit;
                    $vars->{link_link} = $u;
                    $vars->{link_description} = $description;
                    $vars->{insert_table} = "link";
                    if ($vars->{link_title}) {
                        print qq|Title: "|.$title.qq|" <br>URL: $url <br>Descr: <br>$descr<br>|;
                        print "Updating...";
                        $update_id = &update_record($dbh,$query,"link","new");
                        print "$update_id <hr>";
                    }

						# Otherwise, save what we got into the description and move on
            } else {

                    $description = $carryover . " - " . $description;

            }



        }
        print qq|Title: "|.$title.qq|" <br>URL: $url <br>Descr: <br>$descr<hr>|;
        exit;

    } elsif ($table eq "link") {

       $str = "title: ". $record->{$table."_title"} ." - description: ". $record->{$table."_description"};
			 $str =~ s/http/ http/g;

    } else {


        $str = $record->{$table."_description"};
    }

#print "STR: $str <p>";

    # Define the list of tables we're including in our graph
    my @categories = qw(common_noun author place institution organization company product project work feed journal concept);


    # If a category has been selected for a word: present options for saving data, then exit
    if ($vars->{word} && $vars->{category}) {
        &assoc_present_save_options($str); exit;
    }

    # Else if data has been submitted. Process and save to database, then move on
    elsif ($vars->{insert_table}) {


        # First, save the word data itself as a new record
        my $name_or_title = &get_key_namefield($vars->{insert_table});
        my $update_id = $vars->{$vars->{insert_table}."_id"};
        if ($vars->{$name_or_title}) {

           unless ($update_id) {  $vars->{$vars->{insert_table}."_id"} = "new"; }

           unless ($update_id = &update_record($dbh,$query,$vars->{insert_table},$vars->{$vars->{insert_table}."_id"})) {
                die "Update record failed for some reason, $vars->{insert_table} : $vars->{$name_or_title}"; }
           # print "Updated in table ".$vars->{insert_table}." as id $update_id<br>";

           unless ($update_id eq "duplicate") { &add_to_associates_file($vars->{$name_or_title},$vars->{insert_table}); }
    	}

        # Second, create associations in the graph
        my @associates = split ",",$vars->{associates};
        foreach my $associate (@associates) {

            # Do not associate duplicates; the record was never created
            last if ($update_id eq "duplicate");

            # For each associate listed in the imput form

            # get the category and title
            my ($category,$title) = split ":",$associate;

            # If the associate can be found (as it always should be)
            if (my $associate_id = &test_word_in_db($title,$category)) {

                # Create the graph record
                my $graph_id = &db_insert($dbh,$query,"graph",{
                    graph_tableone=>$vars->{insert_table}, graph_idone=>$update_id,
                    graph_tabletwo=>$category, graph_idtwo=>$associate_id,
                    graph_creator=>$Person->{person_id}, graph_crdate=>time, graph_type=>'assoc', graph_typeval=>''});
                #print "Associated $vars->{insert_table}:$update_id and $category:$associate_id as graph entry $graph_id<br>";
            }


    	}


    }


    # print $record->{$table."_description"},"<p>";
    #use Data::Dumper qw(Dumper);

    # Initialize the counter. This keeps track of which $associate we're processing in the record
    my $counter = $vars->{counter};
    $counter = 0 unless $counter;

    # If this is the first associate in a new post, we will be creating a file listing all the associates
    if ($counter == 0) { &clear_associates_file(); }

    # Define and extract the list of words @matches matching the test string
    my $regex = qr{\b([ie]*-?[A-Z]+[A-Za-z0-9]+.*?)\b} ;  # Test pattern
    my $teststr = $str;                                   # Test string
    $teststr =~ s/<(.*?)>//g;
    my @matches;                                       # Output
    #print qq| $regex <br> $teststr <p>|;
    if ( @matches = $teststr =~ /$regex/g ) {
        #  Add a dummy match 'EOF' to the list of matches
        my $number_of_matches = 0+@matches;
        #print qq|Found $number_of_matches matches: <br> |;
		if (@matches) { push @matches,"EOF"; }
	}

    # Define and extract the list of @associates from combinations in the test string
    my $quickprev;
    foreach my $match (@matches) {

        #print qq|Checking match "$match" <br>|;
        if ($quickprev) {

			# Create test concatinations between the previous match $quickprev and the current one
            my $quicktesta = $quickprev." ".$match;
            my $quicktestb = $quickprev." of ".$match;

            #print qq|Looking for "$quicktesta" in string<br>|;
            if ($teststr =~ m/$quicktesta/) {

                # If we find the $quicktest in the string, we'll make it $quickprev, so we can test for even more matches
                $quickprev = $quicktesta;
                #print "Found $quicktest in string. <br>";
                next;
             #print qq|Looking for "$quicktestb" in string<br>|;

            } elsif ($teststr =~ m/$quicktestb/) {

                # If we find the $quicktest in the string, we'll make it $quickprev, so we can test for even more matches
                $quickprev = $quicktestb;
                #print "Found $quicktest in string. <br>";
                next;

            } else {

                # $quicktest wasn't there, so now we'll see is $quickprev is a common noun<br>|;
                # print "Did not find $quicktest in string. <br>";
                if (&test_word_in_file($quickprev,"common_noun")) {
                   # print "It's a common noun. <p>";

                    #Reinitialize $quickprev and move on to the next test candidate
                    $quickprev = $match;
                    next;
                }

                # If it's not a common noun, add $quickprev to the associates list
                push @associates,$quickprev;
                #print qq|It's an associate, saving "$quickprev" to associates array. <p>|;

                # And reinitialize $quickprev with the next test candidate
                $quickprev = $match;
            }
        } else {
            #print "No previous match to concatinate with. <p>";
            $quickprev = $match;
        }
    }




    # Loop through the @associates
    # We're only processing ONE of these, as indicated by $counter, which we'll find with $internal_counter
    my $internal_counter = 0;
    my $form_printed=0;
    #print 0+@associates." associates found!<br>";

    # print "Content-type: text/html\n\n";
    foreach my $associate (@associates) {

    	#print "<p>Loop $internal_counter <br>";
    	# print qq|Associate: $associate <br>|;
    	#print " Counter $counter Internal $internal_counter <br>";

        # Test to see whether we've already saved the $associate as a record in the database
        # The database table will match the categories we're considering
        my $found = 0;
        foreach my $category (@categories) {

            next if ($category eq "common_noun");
            next if ($category eq "feed");

            # print qq|Looking for a "$associate" in category "$category"  <br>|;
			if (my $rid = &test_word_in_db($associate,$category)) {
				#my $rec = db_get_record($dbh,$table,{$vars->{category}."_id"=>$record_id});
				$found=1;
				# If we're starting a new post, save found associates to associates file
				if ($counter == 0) {
				    # print "Add $associate : $category to associates file<br>";
				    &add_to_associates_file($associate,$category);

				}

				last;
			}
		}

    	if ($counter == $internal_counter) {
			unless ($found) {
			# If we did not find the $associate...

				# Our associate is not recorded. It's new!
				# Present categorization options, which when selected will give us our 'save data' screen
				my $new_counter = $counter+1;

				print "Content-type: text/html\n\n";
				    print ":: ".$str. " ----". $carryover;
				print $vars->{msg},"<p>";
				$str =~ s/$associate/<span style="color:red;">$associate<\/span>/g;
				my $prstr = select_incontext_display($associate,$str);
				print $prstr;print "<p>";
				print qq|<a href="admin.cgi?db=$table&id=$id&action=extract_nouns&counter=$new_counter">Next</a><p>|;
				print qq|
					<form method="post" action="admin.cgi">
					<input type="hidden" name="action" value="extract_nouns">
					<input type="text" name="word" value="$associate">|;
				foreach my $category (@categories) {
					print qq|<input type="submit" name="category" value="$category">|;
				}
				print qq|<br>Suggest associates (separate with comma) <input type="text" name="new_associates" size="40"><br>|;
				print qq|
					<input type="hidden" name="counter" value="$new_counter">
					<input type="hidden" name="db" value="$table">
					<input type="hidden" name="id" value="$id">
					</form>
				|;
				$form_printed=1;

            }

        }
        $internal_counter++;
    }

    # Oh? We're here?
    # This means that we're done this associate




    # Was this the last associate in our current post?
    my $number_of_associates = 0+@associates;
    unless ($form_printed) {
        if ($counter >= $number_of_associates) {

            # Yes. Let's move opn to the next post.
            $id++;
            print "Content-type: text/html\n";
            print "Location: $Site->{st_cgi}admin.cgi?db=$table&id=$id&action=extract_nouns\n\n";

        } else {

            # No. Let's move on to the next associate
            $counter++;
            print "Content-type: text/html\n";
            print "Location: $Site->{st_cgi}admin.cgi?word=$word&category=$category&db=$table&id=$id&action=extract_nouns&counter=$counter;\n\n";

        }
    }
	exit;


}


sub assoc_present_save_options {

    my ($str) = @_;
    # Define the list of tables we're including in our graph
    my @categories = qw(author place institution organization company product project work feed journal concept);

	# If it's a common noun....
	if ($vars->{category} eq "common_noun") {
		# print qq|The common noun was "$word"|;

		# Save it if necessary
		unless (&test_word_in_file($vars->{word},$vars->{category})) {
			&add_word_to_file($vars->{word},$vars->{category});
		}

		# Then bail
		print "Content-type: text/html\n";
		print "Location: $Site->{st_cgi}admin.cgi?db=$table&id=$id&action=extract_nouns&counter=".$vars->{counter}."\n\n";
		exit;

	}

	# Set up form variables
	my $new_record_form = "";
	my $associates_form = "";
	my $insert_table = $vars->{category};
	my $name_or_title = &get_key_namefield($insert_table);

	# Save to text file keeping track of data we've already managed
    	#print "Content-type: text/html\n\n";
    	#print "Testing $vars->{word} in $vars->{category} <p>";
	unless (&test_word_in_file($vars->{word},$vars->{category})) {

		# Save the word to the appropriate file
		&add_word_to_file($vars->{word},$vars->{category});

	}

	# Get existing data about the $word in the $category, if any
	my $record;
	my $record_id = &test_word_in_db($vars->{word},$vars->{category});
	if ($record_id) {
		$record = db_get_record($dbh,$table,{$vars->{category}."_id"=>$record_id});
		# print qq|Record title: $record->{$name_or_title} <br>|;
	} else { $record_id = "new";  }




	# Otherwise, we're going to create a new record as part of our input
	if ($record_id eq "new") {

		# Define variables
		my $url; my $logo;
		my $search = $vars->{word}; my $wikipedia = $vars->{word};
		$search =~ s/ /%20/g;
		$wikipedia =~ s/ /_/g;


		# Search Clearbit for url and logo
		if ($vars->{category} eq "company" || $vars->{category} eq "institution"
			|| $vars->{category} eq "organization" || $vars->{category} eq "product") {

			($url,$logo,$json_text) = &get_url_from_clearbit($search);
			$new_record_form .=  $json_text."<p>";


		# Search Wikipedia for information about concepts
		} elsif ($vars->{category} eq "concept") {
			$url = "https://en.wikipedia.org/wiki/".$wikipedia;
		}

        # get the list of catgeories, genres and format selection
        my $category_text =  &form_optlist($insert_table,"new",$insert_table."_category","none","none","none",0);
        my $genre_text =  &form_optlist($insert_table,"new",$insert_table."_genre","none","none","none",0);
        my $type_text =  &form_optlist($insert_table,"new",$insert_table."_type","none","none","none",0);

		# Set up the 'new record' part of the form
		$new_record_form .= qq|
			<input type="text" size=40 name="$name_or_title" value="$vars->{word}">
			(<input type="text" size=10 name="|.$insert_table.qq|_acronym">)
			<input type="text" name="insert_table" value="$vars->{category}"><br>

			URL: <input type="text" name="|.$insert_table.qq|_url" value="$url" size=60>
			[<a href="$url" target="new">Test</a>]
			[<a href="http://www.google.com?q=$search" target="new">Search</a>]<br>


			Logo: <input type="text" name="|.$insert_table.qq|_logo" value="$logo" size=60>
			[<a href="$logo" target="new">Test</a>]
			[<a href="http://www.google.com?q=$search" target="new">Search</a>]
            <br><br>

            Category: $category_text
            Or new: <input type="text" size=20 name="new_category"><br><br>

            Genre: $genre_text
            Or new: <input type="text" size=20 name="new_genre"><br><br>


            Type: $type_text
            Or new: <input type="text" size=20 name="new_type"><br><br>

            Description:<br>
            <textarea cols=60 rows=5 name="|.$insert_table.qq|_description"></textarea>


		|;





	} else {
	    $new_record_form .= $record->{$name_or_title}.qq|$vars->{category}:$vars->{word} <p>    |;
	}

	#Set up form for associations
	# Note that new associations could be defined for existing records, based on the current data

	# Get all of the associates for this post, which we saved earlier
	# print "Getting associates file...<br>";
	my @associates = get_associates_file();

	# Suggested Associates  in $vars->{new_associates}
	my @new_associates = split ",",$vars->{new_associates};
	foreach my $new_associate (@new_associates) {
        foreach my $acat (@categories) {
           my $arecord_id = &test_word_in_db($new_associate,$acat);
               if ($arecord_id ne "new" && $arecord_id) {
                   $associates_form .= qq|<input type="checkbox" value="$acat:$new_associate" name="associates" checked> $acat: $new_associate <br>|;
               }
        }
	}

	# For each associate...
	foreach my $associate (@associates) {

		# If it is already associated, we just want to skip it
		# Which would mean that, for both (a) it exists, and (b) there's an entry in the graph table
		# We've already tested one (if ($record_id eq "new")) now we'll test the other
		# print "Testing for association with $associate <br>";

		my ($acategory,$aword) = split /:/,$associate;
		my $arecord_id = &test_word_in_db($aword,$acategory);

		# If the both exist...
		if ($record_id ne "new" && $arecord_id) {

			# Then they might be associated. Let's see if there's a graph entry
			# and if there is, we'll just skip this item
			# print qq|Checking for graph entry between: $insert_table : $record_id and $acategory : $arecord_id <br>|;
			next if (&db_locate($dbh,"graph",{
				graph_tableone=>$insert_table, graph_idone=>$record_id,
				graph_tabletwo=>$acategory, graph_idtwo=>$arecord_id}));

		}

		# No association exists. So let's give the user the option to create one.
		# print "No association found<br>";
		$associates_form .= qq|<input type="checkbox" value="$acategory:$aword" name="associates" checked> $acategory: $aword <br>|;
	}




	# Print the form
    my $new_counter = $vars->{counter}+1;
	print "Content-type: text/html\n\n";
	print &checkbox_style();
	print $vars->{msg},"<p>";
	print $str;print "<p>";
	print qq|<a href="admin.cgi?db=$table&id=$id&action=extract_nouns&counter=$new_counter">Skip data submission</a><p>|;
	print qq|


		<form method="post" action="admin.cgi">
		<input type="hidden" name="action" value="extract_nouns">
		<input type="hidden" name="db" value="$table">
		<input type="hidden" name="id" value="$id">
		<input type="hidden" name="counter" value="$new_counter">
		$new_record_form
		<br><br>Associate with:<br>
		$associates_form
		<br><br><input type="submit" value="Submit data"><p>
		</form>
	|;
	exit;

}


# Given a word and a string, show only stuff around the word in the string


sub select_incontext_display {
    my ($word,$str) = @_;
    if ($str =~ /($|\n\n)(.*?)$word(.*?)(\n\n|^)/) {
        return $1.$word.$2;
    }
}

sub test_word_in_db {

	my ($word,$category) = @_;

	#print "Content-type: text/html\n\n";
	#print qq|Testing "$word" in database table "$category" <br>|;

    # Test for title or name
	my $name_or_title = get_key_namefield($category);
	my $id =  db_locate($dbh,$category,{$name_or_title=>$word});

	# Test for Acronym
	unless ($id) {
        $id =  db_locate($dbh,$category,{$category."_acronym"=>$word});
	}

	# Test for Nickname
	unless ($id) {
        $id =  db_locate($dbh,$category,{$category."_nickname"=>$word});
	}

	#if ($id) { print qq|Found |.$category.qq|_id "$id" in "$category" <p>|; }
	#else { print qq|Did not find |.$category.qq|_id in "$category" <p>|; }

	return $id;
}

sub test_word_in_file {

	my ($word,$category) = @_;

	#print "Content-type: text/html\n\n";

  	#print qq|Testing $word in $category <p>|;

    	my $filename = $Site->{st_urlf}."files/".$category.".txt";

    	open(FILE,$filename);
    	# Looking for an exact match in a line
	if (grep{/^$word\n/} <FILE>){
		#print qq|<b>The word "$word" was found $filename.</b><br>|;
		close FILE; return 1; }
	#print qq|The word "$word" was not found in $filename.<br>|;
	close FILE; return 0;

}

sub add_word_to_file {
	#print "Content-type: text/html\n\n";
	my ($word,$category) = @_;
    	my $filename = $Site->{st_urlf}."files/".$category.".txt";
	open OUT,">>$filename" or die "Could not open $filename $!";
	print OUT $vars->{word}."\n" or die "Could not append to $filename $!";
	close OUT;
	#print qq|The word "$word" appended to file $filename <br>|;


}

# Keeps track of things in the current post so we can decide whether to associate them with each other
sub add_to_associates_file {

	#print "Content-type: text/html\n\n";
	my ($word,$category) = @_;
    	my $filename = $Site->{st_urlf}."files/associates.txt";
	open OUT,">>$filename" or die "Could not open $filename $!";
	print OUT $category.":".$word."\n" or die "Could not append to $filename $!";
	close OUT;
	#print qq|The "$category:$word" appended to file $filename <br>|;

}

# Returns the associates file as an array so we can ask whether we want something associated
sub get_associates_file {

	#print "Content-type: text/html\n\n";
	my @associates;
	my ($word,$category) = @_;
    	my $filename = $Site->{st_urlf}."files/associates.txt";
	open OUT,"$filename" or die "Could not open $filename $!";
	while (<OUT>) {
		chomp;
		my $match = $_;
		unless (grep /$match/, @associates) { push @associates,$match; }
	}
	close OUT;
	return @associates;

}

sub clear_associates_file {

	#print "Content-type: text/html\n\n";
    	my $filename = $Site->{st_urlf}."files/associates.txt";
	open OUT,">$filename" or die "Could not open $filename $!";
	print OUT "" or die "Could not append to $filename $!";
	close OUT;
	#print qq|Content in associates.txt erased <br>|;

}

sub get_url_from_clearbit {

	my ($search) = @_;

	use JSON::XS;
	my $json_text = get("https://autocomplete.clearbit.com/v1/companies/suggest?query=$search") || print "Could not access Clearbit: $! <p>";

	# Extract search results from JSON - #sk_106d8475acaa57a53f51faa04dbceb41
	my $perl_scalar = decode_json $json_text;
	#while (my ($x,$y) = each %$perl_scalar) { print "$x = $y <br>"; }
	foreach my $ps (@$perl_scalar) {
		if ($ps->{name} =~ /^$vars->{word}$/i) {
			$logo = $ps->{logo};
			$url = "http://".$ps->{domain};
			last;
			#print "Data: $ps->{name} , $ps->{domain} , $ps->{logo} <br>";
		}
	}

	return ($url,$logo,$json_text);

}

sub get_concept_from_wikipedia {


   return ($url,$description);
}


sub checkbox_style {


    return qq|


             <style>

/* Form Styles */


.form {
	max-width: 610px;
	margin: 60px auto;
}

.form__answer {
	display: inline-block;
	box-sizing: border-box;
	width: 150;
	margin: 2px;
	height: 20px;
	vertical-align: top;
	font-size: 14px;
	text-align: center;
}

label {
	border: 1px solid black;
	box-sizing: border-box;
	display: block;
	height: 20px;
	width: 100%;
	padding: 3px;
	cursor: pointer;
	opacity: .5;
	transition: all .5s ease-in-out;
	&:hover, &:focus, &:active {
		border: 1px solid red;
	}
}

/* Radio Input style */

input[type="radio"] {
	opacity: 0;
	width: 0;
  height: 0;
}

input[type="radio"]:active ~ label {
  opacity: 1;
}

input[type="radio"]:checked ~ label {
  opacity: 1;
	border: 1px solid green;
	background-color:#e0e0e0;
}


/* Checkbox Input style */

input[type="chackbox"] {
	opacity: 0;
	width: 0;
  height: 0;
}

input[type="checkbox"]:active ~ label {
  opacity: 1;
}

input[type="checkbox"]:checked ~ label {
  opacity: 1;
	border: 1px solid green;
	background-color:#e0e0e0;
}

    </style>

|;
}
