#    gRSShopper 0.7  Common Functions  0.81  -- 

#    27 April 2017

#    Copyright (C) <2013>  <Stephen Downes, National Research Council Canada>
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
#           Common Functions 
#
#-------------------------------------------------------------------------------



#-------------------------------------------------------------------------------
#
#		Initialization  
#
#-------------------------------------------------------------------------------

sub load_modules {
	



	my ($context) = @_;
							# Require Valid User Agent

#	die "Requests without valid user agent will be rejected" unless ($ENV{'HTTP_USER_AGENT'});

	use strict;
	use warnings;



	$!++;							# CGI
	use CGI;
	use CGI::Carp qw(fatalsToBrowser);

	use CGI::Session;
	my $query = new CGI; 
	my $vars = $query->Vars;
	
	&filter_input($vars);				#	- filter CGI input
	
							# Required Modules

	use DBI;
	use LWP;
	use LWP::UserAgent;
	use LWP::Simple;	
	

	# Added by Luc - Support for french (or other) dates
	# Required by : locale_date
	use POSIX qw(locale_h);
	use POSIX qw(strftime);
	use Scalar::Util 'looks_like_number';
	use Date::Parse;
	
	# Moved from admin context below to here (for dates)
	use HTML::Entities;
							# Admin Modules
	if ($context eq "admin") {
		use File::Basename;
		use File::stat;
		use Scalar::Util 'blessed';
		use Text::ParseWords;
	}					
							
							# Optional Modules
	unless (&new_module_load($query,"MIME::Types")) { $vars->{warnings} .= "MIME::Types;"; }
	unless (&new_module_load($query,"Net::Twitter::Lite::WithAPIv1_1")) { $vars->{warnings} .= "Net::Twitter::Lite::WithAPIv1_1;"; }
	unless (&new_module_load($query,"Image::Magick")) { $vars->{warnings} .= "Image Magick;"; }	
	unless (&new_module_load($query,"DateTime")) { $vars->{warnings} .= "DateTime;"; }
	unless (&new_module_load($query,"DateTime::TimeZone")) { $vars->{warnings} .= "DateTime::TimeZone;"; }	
	unless (&new_module_load($query,"Time::Local")) { $vars->{warnings} .= "Time::Local;"; }
	unless (&new_module_load($query,"Digest::SHA1 qw/sha1 sha1_hex sha1_base64/")) { $vars->{warnings} .= "Digest::SHA1 qw/sha1 sha1_transform sha1_hex sha1_base64/"; }


	return ($query,$vars);
	
}

#-------------------------------------------------------------------------------
#
#		Screen Input  
#
#-------------------------------------------------------------------------------

sub filter_input {
	
	my ($vars) = @_;
	my $numArgs = $#ARGV + 1;					# Command Line Args (For Cron)
	
									# Do not allow these to be set by input
	$vars->{mode} = ""; 
	$vars->{cronsite} = "";
	$vars->{context} = "";
	
			
									# Default input variables
					
	unless (defined $vars->{format}) { $vars->{format} = "html"; }		
	unless (defined $vars->{action}) { $vars->{action} = ""; }	
	unless (defined $vars->{button}) { $vars->{button} = ""; }	
	unless (defined $vars->{force}) { $vars->{force} = "no"; }		
	unless (defined $vars->{comment}) { $vars->{comment} = ""; }


									# Apostraphe-proofs and hack-proof system

	while (my ($vx,$vy) = each %$vars) { 		
		$vars->{$vx} =~ s/'/&#39;/g; # '
		$vars->{$vx} =~ s/\Q#!\E//g; # '
	}


	unless ($vars->{db}) { 						# Make old form requests compatible
		if ($vars->{table}) { 
			$vars->{db} = $vars->{table}; 
		}
	}


	if ($numArgs > 1) {
		
		$vars->{context} = "cron";
		$vars->{cronsite} = $ARGV[0];                # Site
		$vars->{action} = $ARGV[1];		# Command
		if ($vars->{action} eq "publish") { $vars->{page} = $ARGV[2]; }
		$vars->{preview} = $ARGV[2];		# Preview Option
		$cronkey = $ARGV[3];
		$vars->{person_status} = "cron";
		$vars->{mode} = "silent";

	}
	

	
}
 
#-------------------------------------------------------------------------------
#
#		Initialization Functions 
#
#-------------------------------------------------------------------------------




# -------   Get Site -----------------------------------------------------------

sub get_site {
 
	# print "Content-type: text/html\n\n";
	my ($context) = @_;
	
	
	my $numArgs = $#ARGV + 1;						# Command Line Args (For Cron)
	if ($ARGV[1]) { $context = "cron"; }					# Set cron context, as appropriate
	if ($vars->{action} eq "cron") { 					# Note that a cron key is required to execute 
		$context = "cron"; 						# from the command line
		$vars->{cronuser} = "web";
	}
	if ($context) { $vars->{context} = $context; }
	

	our $Site = gRSShopper::Site->new({					# Create new Site object
		context		=>	$context,
		data_dir	=>	'/var/www/cgi-bin/data/',		# Location of site configuration files
	});

	

	
	$Site->{scriptfile} = $0;						# Find script filename 
	$Site->{scriptdir} = dirname($0);					# and directory
	

						
	my @languages = split /,/,$Site->{site_language};
	foreach my $lang (@languages) {
		
		unless ($Site->{lang_default}) { $Site->{lang_default} = $lang; }
		unless ($Site->{lang_user}) { $Site->{lang_user} = $lang; }


		my $lang_filename = $Site->{scriptdir} . "/languages/".$lang . ".pl";
			
		if (-e $lang_filename) { 	
			do $lang_filename; 
		} else { 
			&error_inline($dbh,"<p>Was expecting to find $lang_filename but it was not found</p>");	
		}		
	}	

	

										# Open Site Database


	
	my $dbh = DBI->connect("DBI:mysql:database=$Site->{database}->{name};host=$Site->{database}->{loc};port=3306",
		$Site->{database}->{usr},$Site->{database}->{pwd},{'RaiseError' => 1});

	$Site->{database}="";						# Clear site database info so it's not available later				
	$_ = "";								# Prevent accidental (or otherwise) print of config file.		


										# Get Site Info From Database	
	&get_config($dbh);

	

	
	my $upload_limit = $Site->{file_limit} || 10000;		# File Upload Limit
	$CGI::POST_MAX = 1024 * $upload_limit;			

	return ($Site,$dbh);

}


sub get_config {

	my ($dbh) = @_;
	my $sth = $dbh->prepare("SELECT * FROM config");
	$sth -> execute();
	while (my $c = $sth -> fetchrow_hashref()) { 
		next if ($c->{config_noun} =~ /script|st_home|st_url|st_cgi|co_host/ig);	# Can't change basic site data
		next unless ($c->{config_value});
		$Site->{$c->{config_noun}} = $c->{config_value};
	}
	$sth->finish();
}




# -------   Get Person ---------------------------------------------------------

#   Gets login information based on cookie data

sub get_person {

	my ($dbh,$query,$Person,$pstatus) = @_;
	
	if ($Site->{context} eq "cron") { 			# Create cron person, if applicable,
								# and exit
		
										# Confirm cron key
		my $cronkey = $vars->{cronkey} || $ARGV[1];
		unless ($Site->{cronkey} eq $cronkey) {
			print &printlang('Cron key mismatch',$vars->{cronkey},$Site->{st_name});
			
			&send_email("stephen\@downes.ca","stephen\@downes.ca",
				&printlang("Cron Error",$Site->{st_name}),
				&printlang("Cron key mismatch",$vars->{cronkey},$Site->{st_name}));			
			exit;
		}
	
		$Person->{person_title} = $Site->{st_name};
		$Person->{person_name} = $Site->{st_name};
		$Person->{person_email} = $Site->{em_from};
		$Person->{person_status} = "admin";
		return;

	}					
		

						# Define Cookie Names
	my $site_base = &get_cookie_base();		
	my $id_cookie_name = $site_base."_person_id";
	my $title_cookie_name = $site_base."_person_title";
	my $session_cookie_name = $site_base."_session";
	my $language_cookie_name = $site_base."_language";

	

	my $id = $query->cookie($id_cookie_name);	# Get Person Info from Cookies
	my $pt = $query->cookie($title_cookie_name);
	my $sid = $query->cookie($session_cookie_name);
	$Site->{lang_user} = $query->cookie($language_cookie_name) || $Site->{lang_user} || "en";	
# print "Cookie data: ID $id Title $pt <br>";

	

					# Define Default Headers and Footers 
					
	my $nowstr = &nice_date(time);	my $tempstr;
	$Site->{context} ||= "page";
	
	if (($Site->{context} eq "page")||($Site->{context} eq "admin")) { 
		$Site->{header} = &get_template($dbh,$query,$Site->{context}."_header"); 	
		$Site->{footer} = &get_template($dbh,$query,$Site->{context}."_footer");
			
		for ($Site->{header},$Site->{footer}) {
			$_ =~ s/\Q[*page_crdate*]\E|\Q[*page_update*]\E/$nowstr/sig;
		}
	} 

	unless (($id) && ($pt)) {		# No Person Info - Return anonymous User
		
		&anonymous(&printlang("No Person Info"));	
		return;
	}
	

						# Get Person Data
						# Temporary - I should be building a proper Person object here
	
	my $persondata = &db_get_record($dbh,"person",{person_title=>$pt,person_id=>$id});
	while (my($x,$y) = each %$persondata) {	$Person->{$x} = $y; }

	

	unless ($Person->{person_status} eq "admin") {		# Screen all non-admin from changing person_status
		$vars->{person_status} = "";
	}

	unless ($Person->{person_id}) { 	# No Person Data - Return anonymous User

		&anonymous("No Person Data");
		$Person->{person_status} = "anonymous";
	}
		
	unless ($Person->{person_mode} eq $sid) { 	# Bad session data - Return anonymous User
		&anonymous("Bad session data");
		$Person->{person_status} = "anonymous";
	}

	unless ($Person->{person_status} || ($Person->{person_status} eq "reg")) {
		$Person->{person_status} = "registered";
	}
	

	


}

# -------   Get Cookie Base ---------------------------------------------------

# Internal function to get site-specific cookie bases, derived from site URL
# as defined in global $Site->{st_url} variable

sub get_cookie_base {

	my $site_base = $Site->{'st_url'};	# Get Site Cookie Prefix
	$site_base =~ s/http(s|):|\///ig;
	$site_base =~ s/\./_/ig;
	&error("","","",&printlang("Site info not found","get_cookie_base")) unless $site_base;
	return $site_base;
}



# -------   Get File ---------------------------------------------------

# Internal function to get files

sub get_file {

	my ($file) = @_;
	my $content;

	open FIN,"$file" or return &printlang("Not found",$file);
	
	while (<FIN>) {
		$content .= $_;
	}
	close FIN;
	
	return $content;
	
}


# -------   Anonymous ---------------------------------------------------------

# Makes an anonymous person


sub anonymous {
	my ($why) = @_;
	$Person->{person_title} = "Anymouse";
	$Person->{person_id} = 2;
	$Person->{person_name} = "Anymouse";
	$Person->{person_status} = "anonymous";
	$Person->{person_mode} = $why;
						
	# Get Person Data

	my $p;
	my $stmt = qq|SELECT * FROM person WHERE person_id = ?|;
	my $sth = $dbh -> prepare($stmt);
	$sth -> execute(2);
	my $ref = $sth -> fetchrow_hashref();
	while (my($x,$y) = each %$ref) { 	
		$p->{$x} = $y; 
	}
	$sth->finish(  );
	
	# Place selected data into person hash
	$Person->{person_lastread} = $p->{person_lastread};	
	
}



# -------   Output Record ------------------------------------------------------


sub output_record {

    my ($dbh,$query,$table,$id_number,$format) = @_;
    if ($diag>9) { print "Output Record<br>"; }
   
	my $vars = (); if (ref $query eq "CGI") { $vars = $query->Vars; }
	my $output = "";

	
																										# Check Request
	$table ||= $vars->{table}; die "Table not specified in output record" unless ($table);			#   - table
	$id_number ||= $vars->{id_number};  
	unless ($table) { my $err = ucfirst($table)." ID not specified in output record" ; die "$err"; } 	#   - ID number
	unless ($id_number =~ /^[+-]?\d+$/) { $id_number = &find_by_title($dbh,$table,$id_number); } 		#     (Try to find ID number by title)
	$format ||= $vars->{format} || "html";									#   - format
	
						
						
	return unless (&is_allowed("view",$table,$wp));								# Permissions
	

	my $record = &db_get_record($dbh,$table,{$table."_id"=>$id_number});					# Get Record
	unless ($record) { die "Looking for $table number $id_number, but it was not found, sorry."; }		#     - catch get record error
#	my ($hits,$total) = &record_hit($table,$id_number);							#     - Increment record hits counter

	$record->{page_title} = $record->{$table."_title"} || $record->{$table."_name"} || "Untitled";		# Page Title
	unless ($table eq "page") { $record->{page_title} = $Site->{st_name} . " ~ " .
		$record->{page_title}; }

	$record->{page_content} = &format_record($dbh,$query,$table,$format,$record);				# Page Content = Formated Record content


	$header_template = $record->{page_header} || lc($format) . "_header";					# Add headers and footers
	$footer_template = $record->{page_footer} || lc($format) . "_footer";					#     - pages can override default templates

	if ($table eq "presentation") {
		$header_template = "presentation_header";
		$footer_template = "presentation_footer";	
	}
	


	unless ($table eq "page") {
	$record->{page_content} =
		&db_get_template($dbh,$header_template,$record->{page_title}) .
		$record->{page_content} .
		&db_get_template($dbh,$footer_template,$record->{page_title});
	}

	&format_content($dbh,$query,$options,$record);								# Format Page content
	
	&make_pagedata($query,\$record->{page_content});								# Fill special Admin links and post-cache content
	&make_admin_links(\$record->{page_content});
	&make_login_info($dbh,$query,\$record->{page_content},$table,$id_number);
						
	$record->{page_content} =~ s/\Q]]]\E/] ]]/g;  								# Fixes a Firefox XML CDATA bug			
	
	$output .= $record->{page_content};

														# Fill special Admin links and post-cache data

	&make_pagedata($query,\$wp->{page_content},\$wp->{page_title});				
	&make_admin_links(\$wp->{page_content});
	&make_login_info($dbh,$query,\$wp->{page_content},$table,$id_number);
	&autotimezones($query,\$record->{page_content});
		
	my $mime_type = set_mime_type($format);
	print "Content-type: ".$mime_type."\n\n";								# Print output
	print $output;
	if ($diag>9) { print "/Output Record<br>"; }
	exit;
	
}




#----------------------------- Save Graph ------------------------------


sub save_graph {
	
	
	my ($type,$recordx,$recordy,$typeval) = @_;
#$Site->{diag_level} = 1;	

	
							# Set default values
	my $tabone = $recordx->{type}; unless ($tabone) { &diag(7,"Graph error 1"); return; }
	
	my $idone = $recordx->{$tabone."_id"}; unless ($idone) { &diag(7,"Graph error 3"); return; }
	my $urlone; if ($tabone eq "feed") { $urlone = $recordx->{$tabone."_html"}; }
	elsif ($tabone eq "media") { $urlone = $recordx->{$tabone."_url"}; }
	else { $urlone = $recordx->{$tabone."_link"}; }
	unless ($urlone) { $urlone = $Site->{st_url}.$tabone."/".$idone; }
	my $baseone = "one"; if ($urlone =~ m/http:\/\/(.*?)\//) { $baseone = $1; } 	
		
	my $tabtwo = $recordy->{type}; unless ($tabtwo) { &diag(7,"Graph error 2"); return; }
	my $idtwo = $recordy->{$tabtwo."_id"} || "-1";
	my $urltwo; if ($tabtwo eq "feed") { $urltwo = $recordy->{$tabtwo."_html"}; }
	elsif ($tabtwo eq "media") { $urltwo = $recordy->{$tabtwo."_url"}; }
	else { $urltwo = $recordy->{$tabtwo."_link"}; }	
	my $basetwo = "two"; if ($urltwo =~ m/http:\/\/(.*?)\//) { $basetwo = $1; } 
	unless ($urltwo) { $urltwo = $Site->{st_url}.$tabtwo."/".$idtwo; }		
	
							# Graph distinct entities only
							
	if (($tabone eq $tabtwo) && (($idone eq $idtwo) || ($urlone eq $urltwo))) { &diag(7,"Graph error 4"); return; }
	if (($tabone eq $tabtwo) && ($baseone eq $basetwo)) { &diag(7,"Graph error 5"); return; }
	
							# Uniqueness constraint

						
	if (&db_locate($dbh,"graph",{
		graph_tableone=>$tabone, graph_idone=>$idone, graph_urlone=>$urlone,
		graph_tabletwo=>$tabtwo, graph_idtwo=>$idtwo}, graph_urltwo=>$urltwo))
		{ &diag(7,"Graph error 6 - uniqueness"); return; }

	my $crdate  = time;  
	my $creator = $Person->{person_id};
	
							# Create Graph Record
							
#	print qq|------ Save Graph: [<a href="$urlone">$tabone $idone</a>] $type [<a href="$urltwo">$tabtwo $idtwo</a>]<br>|;
	my $graphid = &db_insert($dbh,$query,"graph",{
		graph_tableone=>$tabone, graph_idone=>$idone, graph_urlone=>$urlone,
		graph_tabletwo=>$tabtwo, graph_idtwo=>$idtwo, graph_urltwo=>$urltwo,
		graph_creator=>$creator, graph_crdate=>$crdate, graph_type=>$type, graph_typeval=>$typeval}); 
	
		
	return $graphid ||  &diag(7,"Graph error 6"); 
	return;						


	
}

# -------   Create Graph Table ---------------------------------------------------------
#

sub create_table_graph {
	
	
	# Create the graph table
	my @tables = $dbh->tables();
	my $tableName = "graph";
	if ((grep/$tableName/, @tables) <= 0) {
		$vars->{msg} .=  "<b>Creating Graph Table</b>";
		my $sql = qq|CREATE TABLE graph (
			  graph_id int(15) NOT NULL auto_increment,
			  graph_type varchar(64) default NULL,
  			  graph_typeval varchar(40) default NULL,
  			  graph_tableone varchar(40) default NULL,
  			  graph_urlone varchar(256) default NULL,
  			  graph_idone varchar(40) default NULL,
  			  graph_tabletwo varchar(40) default NULL,
  			  graph_urltwo varchar(256) default NULL,
  			  graph_idtwo varchar(40) default NULL,  			  
  			  graph_crdate varchar(15) default NULL, 
  			  graph_creator varchar(15) default NULL,   			  
			  KEY graph_id (graph_id)
		)|;
		$dbh->do($sql);
	} 	
}



# -------   Find Graph of ---------------------------------------------------------

#  Find a list of $tabletwo id numbers graphed to $tableone id number $idone

sub find_graph_of {

	my ($tableone,$idone,$tabletwo,$type) = @_;
	return unless ($tableone && $idone);
	return unless ($tabletwo || $type);	
#	if ($Site->{counter}) {$Site->{counter}++; } else { $Site->{counter} = 1; }
#	return if ($Site->{counter} > 8000);
	
	
	unless ($dbh) { $dbh = $ddbbhh; }
	return unless ($dbh);						# For some reason mooc.ca doesn't pass $dbh
	
	if ($Site->{$tableone}->{$idone}) {				# Return cached graph entry
	
		if ($type) {							# by type, or
		
			return @{$Site->{$tableone}->{$idone}->{$type}};
			
		} else {							# by table
		

			return @{$Site->{$tableone}->{$idone}->{$tabletwo}};
		}
		
		
		
	} else {							# Create a cache and call the function again
									# so we have one DB call per record, not 12, or 16 times
									
		my $sql = qq|SELECT * FROM graph WHERE (graph_tableone = ? AND graph_idone = ?) OR (graph_tabletwo = ? AND graph_idtwo = ?)|;
		my $sth = $dbh->prepare($sql);
		$sth -> execute($tableone,$idone,$tableone,$idone); my $grfound=0;
		while (my $c = $sth -> fetchrow_hashref()) { 
			$grfound = 1;	
	
			if ($c->{graph_tableone} eq $tableone && $c->{graph_idone} eq $idone) {	
				push @{$Site->{$tableone}->{$idone}->{$c->{graph_tabletwo}}},$c->{graph_idtwo};
				if ($c->{graph_type}) { push @{$Site->{$tableone}->{idone}->{$c->{graph_type}}},$c->{graph_idtwo}; }
			} elsif ($c->{graph_tabletwo} eq $tableone && $c->{graph_idtwo} eq $idone) {
				push @{$Site->{$tableone}->{$idone}->{$c->{graph_tableone}}},$c->{graph_idone};
				if ($c->{graph_type}) { push @{$Site->{$tableone}->{idone}->{$c->{graph_type}}},$c->{graph_idone}; }	
			}
		}
		if ($grfound) {
			my @connections = &find_graph_of($tableone,$idone,$tabletwo,$type);  # Once we've stored the data, call the result from cache
			return @connections;
		} else { return 0; }
		
	}	

}


# -------   Big Blue Button ---------------------------------------------------------

sub bbb {
	
# "BBB Name:bbb_name","BBB URL:bbb_url","BBB Salt:bbb_salt"	

	my ($url,$salt,$cmd,$qs) = @_;
	
	my $suburl = $cmd . $qs . $salt;
	my $checksum = sha1_hex($suburl); 
	my $gourl = $Site->{bbb_url}.$cmd."?".$qs."&checksum=".$checksum;
	return $gourl;
}

sub bbb_create {
	
	my ($name,$id,$mp,$ap) = @_;
	
	$name =~ s/ /+/g; $id =~ s/ /+/g;
	unless ($name) { $name = $id; }
	my $qs = "name=$name&meetingID=$id&moderatorPW=$mp&attendeePW=$ap";
	my $cmd = "create";
	my $suburl = $cmd . $qs . $Site->{bbb_salt};
	my $checksum = sha1_hex($suburl); 
	my $gourl = $Site->{bbb_url}.$cmd."?".$qs."&checksum=".$checksum;
	return $gourl;
}

sub bbb_joinmod {
	
	my ($meetingid,$username,$userid,$mp) = @_;
		
	&error($dbh,"","","Need a name to join a meeting") unless ($username || $userid);
	unless ($username) { $username = $userid; }
	unless ($userid) { $userid = $username; }
	$username =~ s/ /+/g;
	$userid =~ s/ /+/g;
	
	my $qs = "meetingID=$meetingid&password=$mp&fullName=$username&userID=$userid";
	my $cmd = "join";
	my $suburl = $cmd . $qs . $Site->{bbb_salt};
	my $checksum = sha1_hex($suburl); 
	my $gourl = $Site->{bbb_url}.$cmd."?".$qs."&checksum=".$checksum;
	return $gourl;	
	
	
}

sub bbb_create_meeting {
	
	my ($name,$id) = @_;
#print "Content-type: text/html\n\n";
#print "Smod password $Site->{bbb_mp} <p>";	
	$name =~ s/ /+/g; $id =~ s/ /+/g;
	$name =~ s/&#39;//ig; $id =~ s/&#39;//ig;
	unless ($name) { $name = $id; }

	my $qs = "name=$name&meetingID=$id&maxParticipants=-1&moderatorPW=$Site->{bbb_mp}&attendeePW=$Site->{bbb_ap}";
	if ($vars->{record_meeting} eq "on") { $qs .= "record=true"; }
	my $cmd = "create";
	my $suburl = $cmd . $qs . $Site->{bbb_salt};
	my $checksum = sha1_hex($suburl); 
	my $gourl = $Site->{bbb_url}.$cmd."?".$qs."&checksum=".$checksum;
	
	my $content = get($gourl);
	&error($dbh,"","","Couldn't Create Meeting with $gourl") unless defined $content;
#print qq|<form><textarea cols=50 rows=10>$content</textarea></form><p>|;	
#exit;
	my $status;
	if ($content =~ /<returncode>FAILED<\/returncode>/) { $status = "failed"; }
	elsif ($content =~ /<returncode>SUCCESS<\/returncode>/) { $status = "success"; }
	else { $status = "unknown"; }
}

sub bbb_getMeetingInfo {
	
	my ($meetingid) = @_;
#print "Content-type: text/html\n\n";
	$meetingid =~ s/ /+/g;
	my $qs = "meetingID=$meetingid&password=$Site->{bbb_mp}";
	my $cmd = "getMeetingInfo";
	my $suburl = $cmd . $qs . $Site->{bbb_salt};
	my $checksum = sha1_hex($suburl); 
	my $gourl = $Site->{bbb_url}.$cmd."?".$qs."&checksum=".$checksum;
#print "$gourl <p>";
	my $content = get($gourl);

#print qq|<form><teaxarea cols="50" rows="10">$content</textarea></form>|;
#print "Done";
#exit;	
	&error($dbh,"","","Couldn't get Meeting info from $gourl") unless defined $content;
		
	return $content;	

	
	
}

sub bbb_getMeetingStatus {
	
	my ($meetingid,$req) = @_;

	my $content = bbb_getMeetingInfo($meetingid);	
	my $status;
	if ($content =~ /<returncode>FAILED<\/returncode>/) { $status = "failed"; }
	elsif ($content =~ /<returncode>SUCCESS<\/returncode>/) { $status = "success"; }
	else { $status = "unknown"; }
	return $status; 	
}


sub bbb_get_meetings {
	
	my $random = "1234567890";
	my $qs = "random=$random";
	my $cmd = "getMeetings";	
	my $suburl = $cmd . $qs . $Site->{bbb_salt};
	my $checksum = sha1_hex($suburl); 
	my $gourl = $Site->{bbb_url}.$cmd."?".$qs."&checksum=".$checksum;	
	
	my $content = get($gourl);
	return "Couldn't get Meetings info from $gourl" unless defined $content;
	return $content;

	
}

sub bbb_join_as_moderator {
	
# print "Content-type: text/html\n\n";	
	my ($meetingid,$username,$userid) = @_;
	&error($dbh,"","","Must specify meeting ID to join as moderator<p>") unless ($meetingid);
	&error($dbh,"","","Need a name to join a meeting") unless ($username || $userid);
	
	unless ($username) { $username = $userid; }
	unless ($userid) { $userid = $username; }
	$username =~ s/ /+/g; $userid =~ s/ /+/g; $meetingid =~ s/ /+/g;
	

	# Get Meeting Information	
	my $status = &bbb_getMeetingStatus($meetingid);
	if ($status eq "failed") {
		$vars->{meeting_name} = "Generic Meeting" unless ($vars->{meeting_name});
		$vars->{meeting_name} =~ s/&#39;//ig; $meetingid =~ s/&#39;//ig;
		$status = &bbb_create_meeting($vars->{meeting_name},$meetingid);
		if ($status eq "failed") {
			&error($dbh,"","","Tried to create meeting but it failed.<p>$content");
		}
	}
	
		# Join the Meeting
	
	$qs = "meetingID=$meetingid&password=$Site->{bbb_mp}&fullName=$username&userID=$userid";
	$cmd = "join";
	$suburl = $cmd . $qs . $Site->{bbb_salt};
	$checksum = sha1_hex($suburl); 
	$gourl = $Site->{bbb_url}.$cmd."?".$qs."&checksum=".$checksum;
	print "Content-type:text/html\n";
	print "Location:".$gourl."\n\n";
#	print "<br> $suburl <p>";	
	

}

sub bbb_join_meeting {
	
# print "Content-type: text/html\n\n";	
	my ($meetingid,$username,$userid) = @_;
	&error($dbh,"","","Must specify meeting ID to join meeting<p>") unless ($meetingid);
	&error($dbh,"","","Need a name to join a meeting") unless ($username || $userid);
	
	unless ($username) { $username = $userid; }
	unless ($userid) { $userid = $username; }
	$username =~ s/ /+/g; $userid =~ s/ /+/g; $meetingid =~ s/ /+/g;

	
		# Join the Meeting
	
	$qs = "meetingID=$meetingid&password=$Site->{bbb_ap}&fullName=$username&userID=$userid";
	$cmd = "join";
	$suburl = $cmd . $qs . $Site->{bbb_salt};
	$checksum = sha1_hex($suburl); 
	$gourl = $Site->{bbb_url}.$cmd."?".$qs."&checksum=".$checksum;
	print "Content-type:text/html\n";
	print "Location:".$gourl."\n\n";
#	print "<br> $suburl <p>";	
	

}

#-------------------------------------------------------------------------------
#
#           PERMISSION SYSTEM
#
#-------------------------------------------------------------------------------

# -------   Admin Only ---------------------------------------------------------

# Restrict to admin only

sub admin_only {

# if ($Person->{person_title} eq "Downes") { $Person->{person_status} = "admin" }  
#
	unless ($Person->{person_status} eq "admin") {
		my $msg = qq|@{[&printlang("Must be admin")]}<br/>
		   <h3><a href="$Site->{st_cgi}login.cgi?refer=$Site->{script}">@{[&printlang("Login")]}</a></h3>|;
		&error($dbh,$query,"",$msg);
	}
}


# -------   Registered Only ---------------------------------------------------------

# Restrict to registered users only

sub registered_only {

	unless (($Person->{person_status} eq "registered") 
			 || ($Person->{person_status} eq "admin")) {
		my $msg = qq|@{[&printlang("Must be registered")]}<br/>
		   <h3><a href="login.cgi?refer=$Site->{script}">@{[&printlang("Login")]}</a></h3>|;
		&error($dbh,$query,"",$msg);
	}
}



# -------   is Viewable - Permissions System------------------------------------------
# Will return 0 if triggered, 1 if allowed


sub is_viewable {

	my ($action,$table,$object) = @_;
	return 1 if (&check_status($action,$table,$object));
	return 0;
	
}


# -------   is Allowed - Permissions System-------------------------------------------
# Will punt you with an error if triggered, returns 1 if allowed


sub is_allowed {

	my ($action,$table,$object,$place,$api) = @_;


	return 1 if (&check_status($action,$table,$object));

	# Otherwise...
	my $req = lc($Site->{$action."_".$table});
	print qq|<p class="notice">@{[&printlang("Permission Denied",$req,$action,$table,$place)]}<br/>
		<h3><a href="login.cgi?refer=$Site->{script}">@{[&printlang("Login")]}</a></h3></p>|;

	exit;

}


#-------------------------------------------------------------------------------
#
# -------   Check Status -------------------------------------------------------
#
#           Check the status of the requested user and action
#		Restrict to proper status only
#		May use $object address to examine ownership info
#
#	      Edited: 3 July 2012
#-------------------------------------------------------------------------------



sub check_status {

	my ($action,$table,$object) = @_;

							# Verify Site information and
							# Always allow views of templates, boxes, views

	unless ($Site) { &error($dbh,"","",&printlang("Site info not found","check_status")); }
	return 1 if ($action eq "view" && ( $table =~ /view|box|template/i ));
	return 1 if (lc($Person->{person_status}) eq "admin");	# Admin always has permission
	return 1 if ($Site->{cron} );				# Always allow cron
	return 1 if ($Site->{permission} eq "initialize");		# Lets us do things to initialize
							
									

							# Read permision data from site information

	my $req = &permission_current($action,$table,$object);
	

#	Diagnostic
#	print "$action _ $table :  $req <br>";

							# Return 0 if nobody can do this (hides features) and
							# Return 1 if everybody can do this 

	return 0 if ($req eq "none");					
	return 1 if ($req eq "anyone");				
							
							# Get User Status															
	my $status = lc($Person->{person_status});
	my $project = lc($Person->{project});
	my $pid = $Person->{person_id};



#	Diagnostic
#	print "Person: $pid <br>Status: $status <br>Project: $project <br>";
	

	
							# If requirement is 'registered'
							# Return 1 if $pid > 2 

	if ($req eq "registered") { return 1 if ($pid > 2); }		
		
							# The next set requires that we look at the object.
	
	if ($object) {
	
							# If requirement is 'owner' or 'project'
							# Return 1 if person is the object creator
							
		my $ownf = $table."_creator";				
 		if (($req eq "owner") || ($req eq "project")) {
			return 1 if ($object->{$ownf} eq $pid); 
		}
			
							# If requirement is 'project'
							# Return 1 if person is in the project
		my $prof = $table."_project";
		if ($req eq "project") {
# Needs to be created	
		}
	
	} else {
		#&error($dbh,"","","Object information not found in check_status()");
	}
	
	return 0;
}

#-------------------------------------------------------------------------------
#
# -------   Current Pernmission -------------------------------------------------------
#
#           Permission for action on table
#
#	    Edited: 3 July 2012
#-------------------------------------------------------------------------------

sub permission_current {
	
	my ($action,$table,$object) = @_;
		
	my $req = lc($Site->{$action."_".$table});
	unless ($req) { $req = &permission_default($action,$table,$object); }
	
	return $req;
	
	
}

#-------------------------------------------------------------------------------
#
# -------   Default Pernmission -------------------------------------------------------
#
#           Hard-coded Deafult Permission in Case db version not available
#
#	    Edited: 3 July 2012
#-------------------------------------------------------------------------------


sub permission_default {
	
	my ($action,$table,$object) = @_;	
	
	if ($action eq "view")  { 
		if ($table =~ /config|mapping|optlist/) { return "admin"; }
		if ($table =~ /person/) { return "owner"; }
		else { return "anyone"; }
	} 
	elsif ($action eq "admin") { return "admin"; }
	elsif ($action eq "delete")  { return "admin"; }
	elsif ($action eq "create")  { 
		if ($table =~ /post|feed/) { return "registered"; }
		else { return "admin"; }
	}
	elsif ($action eq "edit")  { 
		if ($table =~ /post|feed|person/) { return "owner"; }
		else { return "admin"; }
	}
	elsif ($action eq "publish")  { 
		return "admin";
	} else {
		return "anyone";
		#die "Nonstandard permission request: $action,$table,$object ";
	}

}

















#-------------------------------------------------------------------------------
#
#           Content Formatting Functions 
#
#-------------------------------------------------------------------------------

# -------  Publish Page --------------------------------------------------------

sub publish_page {

	my ($dbh,$query,$page_id,$opt) = @_;
	my $options = $query->{options};

	$Site->{pubstatus} = "publish";
	my ($pgcontent,$pgtitle,$pgformat,$archive_url); 		# Vars for send_newsletter
	my $LF; if ($Site->{cron} ) { $LF = "\n"; } else { $LF = "<br/>\n"; }
	my $keyword_count;
	if ($vars->{mode} eq "silent") { $opt = "silent"; }
	$vars->{force} = "yes";				# Always rebuild when publishing
								# instead of using caches
	
	if ($opt eq "verbose") {			# Print header for verbose
		print "Content-type: text/html; charset=utf-8\n\n";
		$Site->{header} =~ s/\Q<page_title>\E/Publish!/g;
		$Site->{header} =~ s/\Q[*page_title*]\E/Publish!/g;
		print $Site->{header};
		print "<p>";
	}


							# Set Up Request
	my $stmt;my $sth;
	if ($page_id eq "all" || $page_id eq "auto") { 
		$stmt = qq|SELECT * FROM page|; 
		$sth = $dbh -> prepare($stmt);
 		$sth -> execute(); }
	else {  $stmt = qq|SELECT * FROM page WHERE page_id = ?|;
		$sth = $dbh -> prepare($stmt);
		$sth -> execute($page_id); 
	}
	
							# Get Page Data
	my $count=0;my $wp;
	while ($wp = $sth -> fetchrow_hashref()) {
		$count++;
		
		$wp->{page_content} = $wp->{page_code};
		
		next unless (&is_allowed("publish","page",$wp)); 
		unless ($opt eq "silent" || $opt eq "initialize") { print "Publishing Page: ",$wp->{page_title},$LF; }

								# Skip non-auto in autopublish mode
		if ($page_id eq "auto") {
			next unless ($wp->{page_autopub} eq "yes");
		}						


								# Make Sure We Have Content
		unless ($wp->{page_content}) {		
			unless ($opt eq "silent") { print qq|Whoa, this page has no content $LF $LF|; }
			next;
		}

								# Add Headers and Footers

		my $header = &get_template($dbh,$query,$wp->{page_header},$wp->{page_title});
		my $footer = &get_template($dbh,$query,$wp->{page_footer},$wp->{page_title});
		$wp->{page_content} = $header . $wp->{page_content} . $footer;

								# Update 'update' value
		$wp->{page_update} = time;
		&db_update($dbh,"page",{page_update=>$wp->{page_update}},$wp->{page_id});						


		# Format Page Content
		&format_content($dbh,$query,$options,$wp);
		$wp->{page_content} =~ s/\Q<page_id>\E/$page_id/g;		
		$wp->{page_content} =~ s/\Q[*page_id*]\E/$page_id/g;
		unless ($wp->{page_linkcount} || $wp->{page_allow_empty} eq "yes") {
			print "Zero linkcount, page not published.<p>";
			next;
		}
		$keyword_count = $wp->{page_linkcount};	
		




								# Save Formatted Content to DB
		&db_update($dbh,
			"page",
			{page_content=>$wp->{page_content},page_latest=>time}, 
			$page_id);
				
								# Make Sure We Have an Output File
		unless ($wp->{page_location}) {	
			unless ($opt eq "silent") { print qq|Whoa, no file to print this to $LF $LF|; }
			next;
		}

								# Remove CGI Headers

		my $hdr9 = 'Content-type:text/html';
		my $hdr0 = 'Content-type:text/html; charset=utf-8';
		my $hdr1 = 'Content-type: text/html; charset=utf-8';
		wp->{page_content} =~ s/($hdr0|$hdr1|$hdr9)//sig;

								# Print Page

		if (($wp->{page_autopub} eq "yes") || ($opt eq "verbose") || ($opt eq "initialize")) {

			my $pgfile = $Site->{st_urlf} . $wp->{page_location};
			my $pgurl = $Site->{st_url} . $wp->{page_location};

			open PSITE, ">$pgfile"  or  print qq|Cannot open $pgfile : $! $LF $LF|; 
			print PSITE $wp->{page_content} or print qq| Cannot print to $pgfile : $!  $LF $LF|; 
		
			unless ($opt eq "silent" || $opt eq "initialize") { print qq|Saved page to <a href="$pgurl">$pgfile</a>  $LF|; }
		}

		close PSITE;
	
	

								# Print Archive Version


		if ($wp->{page_archive} eq "yes") {

			my ($save_to,$save_url) = &archive_filename($wp->{page_location});
			unless ($save_to) { print qq|No location to save archive file.$LF $LF|; }
			open POUT,">$save_to" or print qq|Error opening to write to $save_to : $! $LF $LF|;
			print POUT $wp->{page_content} or print qq|Error printing to $save_to : $! $LF $LF|;
			close POUT;
			unless ($vars->{mode} eq "silent" || $opt eq "silent" || $opt eq "initialize") { 
				print qq|Archived $wp->{page_title} to <a href="$save_url">$save_url</a> |;
			}
			$archive_url = $save_url;

		} 
		if ($wp->{page_content}) { $pgcontent = $wp->{page_content}; }
		if ($wp->{page_title}) { $pgtitle = $wp->{page_title}; }
		if ($wp->{page_format}) { $pgformat = $wp->{page_format}; }
		unless ($opt eq "silent" || $opt eq "initialize") { print $LF; }
	}


	$sth->finish(  );

	if ($opt eq "verbose") {	
		print "</p>";		
		print $Site->{footer};
	}

	return ($pgcontent,$pgtitle,$pgformat,$archive_url,$keyword_count);


}


# -------  Publish badge --------------------------------------------------------

sub publish_badge {
        
	my ($dbh,$query,$badge_id,$opt) = @_;
	my $options = $query->{options};

	$vars->{force} = "yes";				# Always rebuild when publishing
								# instead of using caches
	
     	if ($opt eq "verbose") {			# Print header for verbose
		print "Content-type: text/html; charset=utf-8\n\n";
		$Site->{header} =~ s/\Q[*badge_name*]\E/Publish!/g;
		print $Site->{header};
		print "<p>";
	}
		



							# Set Up Request
	my $stmt;my $sth;
	if ($badge_id eq "all" || $badge_id eq "auto") { 
		$stmt = qq|SELECT * FROM badge|; 
		$sth = $dbh -> prepare($stmt);
 		$sth -> execute(); }
	else {  $stmt = qq|SELECT * FROM badge WHERE badge_id = ?|;
		$sth = $dbh -> prepare($stmt);
		$sth -> execute($badge_id); 
	}
	
							# Get Badge Data
	my $count=0;my $wp;
	while ($wp = $sth -> fetchrow_hashref()) {
		$count++;
		
				
		next unless (&is_allowed("publish","badge",$wp)); 
		unless ($opt eq "silent" || $opt eq "initialize") { print "Publishing Badge: ",$wp->{badge_name},$LF; }

														


								# Make Sure We Have Content
		unless ($wp->{badge_name}) {		
			unless ($opt eq "silent") { print qq|Whoa, this badge has no name! $LF $LF|; }
			next;
		}
																				
								# Make Sure We Have an Output File
		unless ($wp->{badge_location}) {	
			unless ($opt eq "silent") { print qq|Whoa, no file to print this to $LF $LF|; }
			next;
		}

																		
                     						# Print Page

		
			my $pgfile = $Site->{st_urlf} . $wp->{badge_location};
  			my $pgurl = $Site->{st_url} . $wp->{badge_location};
			my $json = qq|{"name": "$wp->{badge_name}","description": "$wp->{badge_description}","image": "$wp->{badge_image}", "criteria": "$wp->{badge_criteria}","issuer": "$wp->{badge_issuer}"}|;


			open PSITE, ">$pgfile"  or  print qq|Cannot open $pgfile : $! $LF $LF|; 

			print PSITE $json or print qq| Cannot print to $pgfile : $!  $LF $LF|; 
		
			unless ($opt eq "silent" || $opt eq "initialize") { print qq|Saved page to <a href="$pgurl">$pgfile</a>  $LF|; }
		

		close PSITE;
	

	}


	$sth->finish(  );

	if ($opt eq "verbose") {	
		print "</p>";		
		print $Site->{footer};
	}

   #assign_badge($dbh,$query,$badge_id,1,$opt);
   #bake_badge("http://rel2014.mooc.ca/badge/badgeassert.json",$Site->{st_urlf}."monnouveaubadge.png"); 
	
}

# -------  Assign badge --------------------------------------------------------

sub assign_badge {
        
	my ($dbh,$query,$badge_id, $person_id,$opt) = @_;
	my $options = $query->{options};
	
	 $stmt = qq|SELECT * FROM badge WHERE badge_id = ?|;
		$sth = $dbh -> prepare($stmt);
		$sth -> execute($badge_id);

         my $badge = $sth -> fetchrow_hashref(); 
	
	 $stmt = qq|SELECT * FROM person WHERE person_id = ?|;
		$sth = $dbh -> prepare($stmt);
		$sth -> execute($person_id); 	
								  
          my $person = $sth -> fetchrow_hashref();  
		
		


								# Make Sure We Have Badge Class
		unless ($badge->{badge_location}) {		
			unless ($opt eq "silent") { print qq|Whoa, this badge has no class location! $LF $LF|; }
			next;
		}
																			
                     						# Print Page

		
			my $pgfile = $Site->{st_urlf} . "assert_".$person->{person_id}."_".$badge->{badge_location};
			my $pgurl = $Site->{st_url} . "assert_".$person->{person_id}."_".$badge->{badge_location};
  			
			my $json = qq|{"uid": "$person->{person_id}_$badge->{badge_id}","recipient": {"type":"email", "hashed": false, "identity": "$person->{person_email}"},"image": "$badge->{badge_image}", "evidence": "$badge->{badge_criteria}","issuedOn": "12345","badge":"$Site->{st_url}$badge->{badge_location}", "verify":{"type": "hosted","url": "$pgurl"} }|;


			open PSITE, ">$pgfile"  or  print qq|Cannot open $pgfile : $! $LF $LF|; 

			print PSITE $json or print qq| Cannot print to $pgfile : $!  $LF $LF|; 
		
			unless ($opt eq "silent" || $opt eq "initialize") { print qq|Saved page to <a href="$pgurl">$pgfile</a>  $LF|; }
		

		close PSITE;
	

	


	$sth->finish(  );

	if ($opt eq "verbose") {	
		print "</p>";		
		print $Site->{footer};
	}

	
}


# -------  Get Badge from Mozilla --------------------------------------------------------

sub bake_badge {

my ($urlbadge,$pgfile) = @_;

use LWP::Simple;

$contents = get("http://backpack.openbadges.org/baker?assertion=".$urlbadge);

open PSITE, ">$pgfile"  or  print qq|Cannot open $pgfile : $! $LF $LF|; 

print PSITE $contents or print qq| Cannot print to $pgfile : $!  $LF $LF|; 

close PSITE;

}






# -------  Make Admin Links -------------------------------------------------------
#
# If the person specified in the Person object has status=admin,
# creates edit, delete and spam links for any content item, when declared
# in a 'view'. Format:  <admin table,id>  eg. <admin post,[*post_id*]>
# (format_record() will replace [*post_id*] with the record ID number)
# Receives text pointer as input; acts directly on text

sub make_admin_links {

	my ($input) = @_;

	my $count;
	while ($$input =~ /<admin (.*?)>/mig) {
	
		my $autotext = $1;
		$count++; last if ($count > 100);			# Prevent infinite loop
		my $replace = "";
		my ($table,$id,$status) = split ",",$autotext;
		
					# Define Admin Links (or Blanks)

		if ($Person->{person_status} eq "admin") { 
			unless ($Site->{pubstatus} eq "publish") {
			
				$replace = "";
						# Special for feeds

				if ($table eq "feed") {
					
					my $sz = qq|width=10 height=10|;
					my $A = qq|<img src="|.$Site->{st_img}.qq|A.jpg" $sz/> |;
					my $R = qq|<img src="|.$Site->{st_img}.qq|R.jpg" $sz/> |;
					my $O = qq|<img src="|.$Site->{st_img}.qq|O.jpg" $sz/> |;
					my $was = "was=".$vars->{action};
					my $adminlink = $Site->{st_cgi}."admin.cgi";
					my $harvestlink = $Site->{st_cgi}."harvest.cgi";
					my $ffeed = $filldata->{feed_id};
					if ($status eq "A" || $status eq "Published") {
						$replace .=  $A.
							qq|[<a href="$harvestlink?feed=$id&analyze=on">@{[&printlang("Analyze")]}</a>]|.
							qq|[<a href="$harvestlink?feed=$id">@{[&printlang("Harvest")]}</a>]|.
							qq|[<a href="$adminlink?action=retire&feed=$id&$was">@{[&printlang("Retire")]}</a>]|
					} elsif ($status eq "R" || $status eq "Retired") {
						$replace .=  $R.
							qq|[<a href="$adminlink?action=approve&feed=$id&$was">@{[&printlang("Approve")]}</a>]|;

					} elsif ($status eq "O") {
						$replace .=  $O.
							qq|[<a href="$harvestlink?feed=$id&analyze=on">@{[&printlang("Analyze")]}</a>]|.
							qq|[<a href="$adminlink?action=approve&feed=$id&$was">@{[&printlang("Approve")]}</a>]|.
							qq|[<a href="$adminlink?action=retire&feed=$id&$was">@{[&printlang("Retire")]}</a>]|;
					} else {
						$replace .= qq|[$status]|;
					}
				}	
				
				
				$replace .=  qq| 
				[<a href="$Site->{st_cgi}admin.cgi?$table=$id&action=edit">@{[&printlang("Edit")]}</a>]
				[<a href="javascript:confirmDelete('$Site->{st_cgi}admin.cgi?$table=$id&action=Delete')">@{[&printlang("Delete")]}</a>]|;
				
				if ($table eq "post") {
					$replace .= qq|[<a href="javascript:confirmDelete('$Site->{st_cgi}admin.cgi?$table=$id&action=Spam')">@{[&printlang("Spam")]}</a>]|;
				}
				
				
					
			}
		}	
		
		
		
		
		
		$$input =~ s/<admin $autotext>/$replace/;
	}



}

# -------  Make Comment Form -----------------------------------------------------------



sub make_comment_form {

	my ($dbh,$text_ptr) = @_;
	return unless (defined $text_ptr);

	while ($$text_ptr =~ /<CFORM>(.*?)<END_CFORM>/sg) {

		my $autotext = $1; my ($cid,$ctitle) = split /,/,$autotext;
		$ctitle =~ s/"//g;
		my $code = &make_code($cid);

		# Detect anonymous user
		my $anonuser = 0;
		if ($Person->{person_name} eq $Site->{st_anon}) { $anonuser=1; }

		# Set up email subscription element...
		my $email_subscription;

		# ... for anon user
		if ($anonuser) {
			$email_subscription = qq|
				<tr><td colspan=2>@{[&printlang("Enter Email for Replies")]}</td>
				<td colspan="2"><input type="text" name="anon_email" size="40"></tr>|;

		# ... for registered user
		} else {	 
			$email_subscription = qq|	
			<tr><td><input type="checkbox" name="post_email_checked" checked></td>
			<td colspan="3">@{[&printlang("Check Box for Replies")]}<br>&nbsp;@{[&printlang("Your email")]}
			<input type="text" name="anon_email" value="$Person->{person_email}" size="57"></tr>|;
		}			

		my $identifier = "id".$Person->{person_id}.time;
		my $comment_form = qq|
		<div class="comment_form_container" style="background-color:#eeeeee;"><div style="padding:10px;">
		<section id="Comment"><h3>@{[&printlang("Your Comment")]}</h3></section>
		
		<div id="preview" style="width:90%;">
		<p><LOGIN_INFO></p>
		<p>@{[&printlang("Preview until satisfied")]} @{[&printlang("Not posted until done")]}<p>
		</div></div>

		<div id="theform" style="width:90%;">
		
		 <a name="comment"></a>
 		 <form id="apisubmit" method="post" action="$Site->{st_cgi}page.cgi" style="margin-left:15px;">
		 <input type="hidden" name="table" value="post">
		 <input type="hidden" name="post_type" value="comment">
		 <input type="hidden" name="id" value="new">
		 <input type="hidden" name="post_thread" value="$cid">
		 <input type="hidden" name="code" value="$code">
		 <input name="action" value="api submit" type="hidden">	 
		 <input name="identifier" value="$identifier" type="hidden">

		<input name="post_title" value="Re: $ctitle" size="60" style="width:300px;height:1.8em;" type="text"> 
		<br/>
		
		
		<textarea id="post_description" name="post_description" cols="70" rows="5"></textarea>
		<br/>
		
		$email_subscription 

		<br/>
		<input name="pushbutton" id="pushbutton" type="hidden">
		<button id="preview">Preview</button>
		<button id="done">Done</button>


		</form>|;
		
		my $cbox = &printlang("comment_disclaimer");
		$comment_form .= &db_get_content($dbh,"box",$cbox);
		
		$comment_form .= "</div></div>";
	
		$$text_ptr =~ s/<CFORM>\Q$autotext\E<END_CFORM>/$comment_form/sig;
	}
}



# -------  Archive Filename -----------------------------------------------------------

# Creates an archive filename based on date and page location filename (page_location)

sub archive_filename {	

	# Obtain filename from inout
	my $archivefile = shift @_;

	# Replace any slashes with underscores
	$archivefile =~ s/\//_/g;

	# Get current time and fix digits
	my ($sec,$min,$hour,$mday,$mon,$year,
		$wday,$yday,$isdst) = localtime(time);
	$mday = "0$mday" if ($mday < 10);
	$mon++;
	$mon  = "0$mon"  if ($mon < 10);
	$year  = $year - 2000 if ($year > 1999);  					$year  = $year - 100 if ($year > 99);
	$year  = "0$year"  if ($year < 10);


	# Make these directories if necessary
	my $af = $Site->{st_urlf}."archive/";
	unless (-d $af) { mkdir $af, 0755 or &error($dbh,"","",&printlang("Cannot create directory",$af,"archive_filename",$!)); }
	$af .= $year."/";
	unless (-d $af) { mkdir $af, 0755 or &error($dbh,"","",&printlang("Cannot create directory",$af,"archive_filename",$!)); }

	# Compile filename and url
	$af = $Site->{st_urlf} .
		"archive/$year/$mon" . "_" . $mday . "_" .
		$archivefile;
	my $au = $Site->{st_url} .
		"archive/$year/$mon" . "_" . $mday . "_" .
		$archivefile;	# Compile URL


	
	# And return them
	return ($af,$au);
}

# -------  Format Content -----------------------------------------------------------

# Should be called page_format()  (and eventually, $page->format() when we're fully OO)

# Formats the content area of a page or record
# $wp is a page object
# $wp->{page_content} is the output content that is being processed here

sub format_content {

				
	my ($dbh,$query,$options,$wp) = @_;
	if ($diag>9) { print "Format Content <br>"; }
	
    	my $vars = ();
    	if (ref $query eq "CGI") { $vars = $query->Vars; }

    		

						# Default Content
	unless (defined $wp->{page_content}) { $wp->{page_content} = &printlang("No content"); }
	unless (defined $wp->{page_description}) { $wp->{page_description} = &printlang("No description");; }
	unless (defined $wp->{page_title}) { $wp->{page_title} = &printlang("Untitled");; }
	unless (defined $wp->{page_format}) { $wp->{page_format} = "html"; }
	unless (defined $wp->{page_crdate}) { $wp->{page_crdate} = time; }
	unless (defined $wp->{page_creator}) { $wp->{page_creator} = $Person->{person_id}; }
	unless (defined $wp->{page_update}) { $wp->{page_update} = time; }
	unless (defined $wp->{page_feed}) { $wp->{page_feed} = $Site->{st_feed}; }
	unless (defined $Site->{st_title}) { $Site->{st_title} = &printlang("Site Title");; }
	$wp->{page_linkcount} = 0;
	
	

	&make_data_elements($wp->{page_content},$wp,$wp->{page_format});		# Fill page content elements	
	&make_boxes($dbh,\$wp->{page_content});						# Make Boxes
	&make_counter($dbh,\$wp->{page_content});						# Make Boxes	
	my $results_count = &make_keywords($dbh,$query,\$wp->{page_content},$wp);	# Make Keywords
	$wp->{page_linkcount} .= $results_count;
	
	$wp->{page_content} =~ s/<count>/$vars->{results_count}/mig;			# Update results count from keywords


	my $today = &nice_date(time);
	$wp->{page_content} =~ s/#TODAY#/$today/;
	
	&autodates(\$wp->{page_content});
	

        &get_loggedin_image(\$wp->{page_content});

						# Comment Form
		
	if ($vars->{comment} eq "no") {
		$wp->{page_content} =~ s/<CFORM>(.*?)<END_CFORM>//g;
	} else {

		&make_comment_form($dbh,\$wp->{page_content});
	}

						# Wikipedia

	&wikipedia_entry($dbh,\$wp->{page_content});


	$wp->{page_content} =~ s/\Q[*page_title*]\E/$wp->{page_title}/g;					# Page Title
	$wp->{page_content} =~ s/\Q<page_title>\E/$wp->{page_title}/g;				
	&autotimezones($query,\$wp->{page_content});								# Fill timezone dates
	
						# Template and Site Info
	&make_site_info(\$wp->{page_content});
	
	&make_site_hits_info(\$wp->{page_content});


					


						# Stylistic
						# Customize Internal Links
	my $style = qq||;
	$wp->{page_content} =~ s/<a h/<a $style h/sig;
	

		
		
		
		
	&clean_up(\$wp->{page_content},$format);
	
						# RSSify
						
	if ($wp->{page_format} =~ /rss|xml|atom/i) {
		&format_rssify(\$wp->{page_content});
	}

	if ($diag>9) { print "/Format Content <br>"; }
	
}

sub  get_loggedin_image{
my ($text_ptr) = @_;

    #my $person = &get_person();
#$mystring =~ s/<get_loggedin_image>/mom/;
}

# -------  Format Record ----------------------------------------------------

# Puts a single data record into its template
# where there are different templates for different formats
# keyflag is set by make_keywords() and is set to prevent 
# keyword commands from creating full page records with templates

# Should be called record_format()  (and eventually, $record->format() when we're fully OO)

sub format_record {


	my ($dbh,$query,$table,$record_format,$filldata,$keyflag) = @_;
	if ($diag>9) { print "Format Record  <br>"; }

	my $vars = (); if (ref $query eq "CGI") { $vars = $query->Vars; }
	my $id_number = $filldata->{$table."_id"};
	


	
	
									# Permissions
				
	return &printlang("Permission denied to view",$table) unless (&is_viewable("view",$table,$filldata)); 

	
									# Get and Return Cached Version
									
	$vars->{force} = "yes";						# Cache is broken (again), still haven't figured out how to make this work	
			
	unless ($vars->{force} eq "yes") {								
		if (my $cached = &db_cache_check($dbh,$table,$id_number,$record_format)) {							
			if ($cached) {
				&make_admin_links(\$cached);
				return $cached;	
			}
		}					
	}							
					



	
											# No cached version, format record
									
		

	my $view_text = "";								# Get the code and add header and footer for Page
	if (($table eq "page") && ($record_format ne "page_list") && !$keyflag) { 
			$view_text = &db_get_template($dbh,$filldata->{page_header}) .
			$filldata->{page_code} .				
			&db_get_template($dbh,$filldata->{page_footer});	
	} else { 	
	
									# Or Get the Template (aka View)

		my $view_title = $record_format;
		if ($table eq "post") { $view_title = $filldata->{post_type}."_".$view_title; }	# Special for post
		unless ($view_title =~ /$table/) { $view_title = $table."_".$view_title; }	# ensure full view format name		
		$view_text = &db_get_text($dbh,"view",$view_title);		

	}




											
	&make_boxes($dbh,\$view_text);							# Make Boxes - insert box text into element
	&make_counter($dbh,\$view_text);							# Make Counter
	
	&make_data_elements(\$view_text,$filldata,$record_format);			# Fill page content elements				

	my $results_count = &make_keywords($dbh,$query,\$view_text);						# Keywords

	my $kresults_count = &make_keylist($dbh,$query,\$view_text);						# Keylist
						
	&make_next($dbh,\$view_text,$table,$id_number,$filldata);							# Prev / Next Link
						
	&autodates(\$view_text);										# Dates



	&make_images(\$view_text,$table,$id_number,$filldata);							# Images

	&make_enclosures(\$view_text,$table,$id_number,$filldata);						# Enclosures	
	
	&make_author(\$view_text,$table,$id_number,$filldata);							# Author	
	
	&make_hits($text_ptr,$table,$id,$filldata);								# Hits


	if ($record_format =~ /opml/) { $view_text =~ s/&/&amp;/g; }
	if ($record_format =~ /text|txt/) { &strip_html($text_ptr); }

	
	
	
	&make_escape($dbh,\$view_text);										# Escaped HTML

	&clean_up(\$view_text,$record_format);
										
#	&db_cache_save($dbh,$table,$id_number,$record_format,$view_text);					# Save To Cache
	

	&make_admin_links(\$view_text);	
	
	$view_text =~ s/CDATA\((.*?)\)//g;		# Kludge to eliminate hanging CDATA tags
	
	# Clean up presentations
	if ($table eq "presentation") {
		
			unless ($filldata->{presentation_slideshare}) {
				$view_text =~ s|<iframe(.*?)slideshare.net/(.*?)/iframe>||g;
			}


			unless ($filldata->{presentation_youtube}) {
				$view_text =~ s|<iframe(.*?)youtube(.*?)/iframe>||g;
			}

	}
	
	
	
	#$viewtext = " - ";
	if ($view_text =~ /CampaignToBuildOneBigCampaign/ || $view_text =~ /Blacklock/ ||  $view_text =~ /One Big Campaign/ || $view_text =~ /feed\/408/) {
		$view_text = " - ";
}

	if ($diag>9) { print "/Format Record <br>"; }
	return $view_text;											# Return the Completed Record

}


# -------   Facebook --------------------------------------------------

# Autopost to Facebook
# Requires: $dbh,$table,$id
# Optional: $tweet (will print record title if tweet is not given)
# Requires $Site->{fb_post} set to 'yes' and $record->{post_social_media} not containing 'facebook' (for the post specified)
# Will include site hastag $Site->{st_tag} if $Site->{fb_use_tag} is set to "yes"
# Will update the record to set the value 'posted' the value in 'post_twitter'   (or 'event_twitter', etc)
# to ensure each item is posted only once
# Returns status update in $vars->{twitter}


sub facebook_post {
	
	my ($dbh,$table,$id,$message) = @_;
	
	return "Facebook turned off." unless ($Site->{fb_post} eq "yes");				# Make sure Facebook is active
	my $record = &db_get_record($dbh,$table,{$table."_id"=>$id});					# get record
	my $fbp = &facebook_session(); 
	
	my $fbp = Net::Facebook::Oauth2->new(
		application_secret     => $Site->{fb_app_secret} , 
		application_id          => $Site->{fb_app_id},
		callback           => $Site->{fb_postback_url}
	);
		
	my $text = &format_record($dbh,"","post","facebook",$record);				# Format content
	my $link = $Site->{st_url}."post/".$id."/rd";
	
	$text =~ s/<br>|<br\/>|<br \/>|<\/p>/\n\n/ig;							# No HTML
	$text =~ s/\n\n\n/\n\n/g;				
	$text =~ s/<(.*?)>//g; 
	$text =~ s/<(.*?)>//g;
		
	
	my $posturl = "https://graph.facebook.com/v2.2/OLDaily/feed";
        my $args = {											
            message => $text,
            link => $link,
        };
        $fbp->{access_token} = $Site->{fb_token};        	
        my $info = $fbp->post( $posturl,$args );							# Post to Facebook
        my $inforcheck = $info->as_json;
	
	if ($inforcheck =~ /error/) {													# catch error, or
	
			print "Content-type: text/html\n\n";
			$vars->{facebook} .= "Facebook: Error <br />";
			$vars->{facebook} .=  $inforcheck;  
			print $vars->{facebook};
			facebook_access_code_url($vars->{facebook});
			exit;
		
	} else {
		my $smfield = $table."_social_media";								# Update Record	
		my $smstring = $record->{$smfield}."facebook ";
		&db_update($dbh,$table,{$smfield => $smstring},$id);
		$vars->{facebook} .= "$inforcheck <br>Facebook: OK";
	 }               									
	 
	 
	
	return $vars->{facebook};
	
}


sub facebook_session {
	
	my ($dbh) = @_;	

	#use Facebook::Graph;
	use Net::Facebook::Oauth2;
	
		
									# Make sure we have an access token
	unless ($Site->{fb_token}) { $Site->{fb_token} = &facebook_access_token(); }

									# Authenticate and Encode token
	unless (my $fb = &facebook_authenticate()) { return $vars->{facebook}; } 
	$fb->{access_token} = $Site->{fb_token};
	return $fb;	
}



sub facebook_authenticate {
	
	
	my $fbz = Net::Facebook::Oauth2->new(
		application_secret     => $Site->{fb_app_secret} , 
		application_id          => $Site->{fb_app_id},
		callback           => $Site->{fb_postback_url}
	);
    
	unless ($fbz) { $vars->{facebook} .= "Facebook authentication error: $?"; return; } 
    
	return $fbz;   	
	
}

sub facebook_access_token {
	
	return $Site->{fb_token} if ($Site->{fb_token});

	my $access_code = &facebook_access_code_url(); 	
	
	my $fb = Net::Facebook::Oauth2->new(
            application_secret     => $Site->{fb_app_secret}, 
            application_id          => $Site->{fb_app_id},
            callback           => $Site->{fb_postback_url}
        );
    
        my $access_token = $fb->get_access_token(code => $access_code);         
        if ($access_token) { $Site->update_config($dbh,{fb_token => $access_token}); }
        else { $vars->{facebook} .= "Facebook: Error getting access token."; }
        	
	return $access_token;
}

sub facebook_access_code_url {

	my ($info) = @_;
	return $Site->{fb_code} if ($Site->{fb_code});
	if ($vars->{code}) {						# This picks up the code from the redirect
		$Site->{fb_code} = $vars->{code};			# We'll store it for later use
		if ($Site->{fb_code}) { $Site->update_config($dbh,{fb_code => $Site->{fb_code}}); }		
		print "Content-type: text/html\n\n";			# Print a response
		print "Facebook OK $Site->{fb_code}";
		exit;							# And quit
	}

									# This assumes we did not get a code from a redirect
									# So we have to make the request
	my $fbb = Net::Facebook::Oauth2->new(
            application_secret     => $Site->{fb_app_secret}, 
            application_id          => $Site->{fb_app_id},
            callback           => $Site->{fb_postback_url}
        );	
	
	
								        # Get the authorization URL 
        my $url = $fbb->get_authorization_url(	
            scope   => [ 'public_profile', 'email'  ],
            display => 'page'
        );
    
        print "Content-type: text/html\n\n";
        print "$info <p>";
        print "Facebook needs to generate an access token. Click on the link or enter the URL:  $url<p>";					# And provide the link to click on
    
        print qq|Redirect URL: <a href="$url">Click here</a><p>|;	
	
	exit;
}

sub facebook_access_code_submit {
	
	my $code = $vars->{code};					# save the code. Note it's valif only for a couple minutes
	if ($access_token) { $Site->update_config($dbh,{fb_code => $code}); }
	
									# Regenerate the access token, which will persist
	$Site->{fb_token} = "";
	my $result = &facebook_access_token();
	print "Content-type: text/html\n\n";
	print "Facebook Access Result: $result<br>";
	unless ($result =~ /error/i) { print "You can now use Facebook services<p>"; }
	exit;
	
	
}

# -------   Post to Twitter --------------------------------------------------

# Autopost to Twitter
# Requires: $dbh,$table,$id
# Optional: $tweet (will print record title if tweet is not given)
# Requires $Site->{tw_post} set to 'yes' and $record->{post_social_media} to not contain "twitter" (for the post specified)
# Will include site hastag $Site->{st_tag} if $Site->{tw_use_tag} is set to "yes"
# Will update the record to set the value 'posted' the value in 'post_twitter'   (or 'event_twitter', etc)
# to ensure each item is posted only once
# Returns status update in $vars->{twitter}


sub twitter_post {
	
	my ($dbh,$table,$id,$tweet) = @_;

	my $record = &db_get_record($dbh,$table,{$table."_id"=>$id});
	
	unless ($Site->{tw_post} eq "yes") { $vars->{twitter} .= "Twitter turned off."; return $vars->{twitter}; }

	
	
	if ($record->{$table."_twitter"} eq "posted") { $vars->{twitter} .= "Already posted this $table to Twitter."; return; }	
	
	#use Net::Twitter::Lite::WithAPIv1_1;
	#use Scalar::Util 'blessed';

	#my $Site->{tw_cckey} = '';
	#my $Site->{tw_csecret}  = '';
	#my $Site->{tw_token} = '';
	#my $Site->{tw_tsecret}  = '';


										# Access Account
	
	&error($dbh,"","","Twitter posting requires values for consumer key, consumer secret, token and token secret")
		unless ($Site->{tw_cckey} && $Site->{tw_csecret} && $Site->{tw_token} && $Site->{tw_tsecret});
		

		
	    
										# Compose Tweet	
	my $tw_url = $Site->{st_url}.$table."/".$id;
	if ($Site->{tw_use_tag}) { $tw_url = $Site->{st_tag}." ".$tw_url; }
	my $url_length = length($tw_url)+1;
	$tweet ||= $record->{$table."_title"};
	my $tweet_length = length($tweet);

										# Shorten Tweet
	if (($url_length + $tweet_length) > 137) { 
		my $etc = "...";
		my $trunc_length = 137 - $url_length;
		$tweet = substr($tweet,0,$trunc_length);
		$tweet =~ s/(\w+)[.!?]?\s*$//;		
		$tweet.=$etc;
	}
	
	$tweet = $tweet . " " . $tw_url;
	
	
	$tweet =~ s/\xe2\x80\x99/\'/gs;						# Convert smartquotes
	$tweet =~ s/\xe2\x80\x98/\'/gs;						# No doubt more UTF8 stuff needs to be fixed
	$tweet =~ s/\xe2\x80\x9c/\"/gs;
	$tweet =~ s/\xe2\x80\x9d/\"/gs;
	
	my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
		consumer_key        => $Site->{tw_cckey},
		consumer_secret     => $Site->{tw_csecret},
		access_token        => $Site->{tw_token},
		access_token_secret => $Site->{tw_tsecret},
		ssl                 => 1,  ## enable SSL! ##
	);	

        my $result = eval {$nt->update({ status => $tweet})};
	if ( my $err = $@ ) {
		die $@ unless blessed $err && $err->isa('Net::Twitter::Lite::Error');
		$vars->{twitter} = "<p><b>Twitter posting error</b><br>Attempted to tweet: $tweet <br>HTTP Response Code: ". $err->code. "<br>".
			"HTTP Message......: ". $err->message. "<br>Twitter error.....: ". $err->error. "</p>";
		return $vars->{twitter};
	}
	

	
	my $smfield = $table."_social_media";								# Update Record	
	my $smstring = $record->{$smfield}."twitter ";
	&db_update($dbh,$table,{$smfield => $smstring},$id);
			
	if ($result) { $vars->{twitter} .= "Twitter: OK" }

	return $vars->{twitter};
	
}


# -------   Set Formats ------------------------------------------------------

sub esc_for_javascript {

	my ($text_ptr) = @_;
	my $vars = (); if (ref $query eq "CGI") { $vars = $query->Vars; }

	$$text_ptr =~ s/&quot;/\"/mig;
	$$text_ptr =~ s/&#147;/"/mig;
	$$text_ptr =~ s/&#148;/"/mig;
 	$$text_ptr =~ s/\xe2\x80\x9c/\"/gs;
 	$$text_ptr =~ s/\xe2\x80\x9d/\"/gs;
#	$$text_ptr =~ s/"Education/GORP/gs;
	$$text_ptr =~ s/\n//sig;
	$$text_ptr =~ s/\r//sig;
	$$text_ptr =~ s/\\\s/\\\\ /sig;
	$$text_ptr =~ s/\"/\\\"/sig;
}

# -------   Set Formats ------------------------------------------------------
#
# Determine page format, record format and mime type given
# page data and var input
# returns array: page_format,record_format,mime_type

sub set_formats {

	my ($dbh,$query,$wp,$table) = @_;
	my $vars = (); if (ref $query eq "CGI") { $vars = $query->Vars; }


	

						# Page Format
	my $page_format = "html";				# default page format
	if ($table eq "page") { 				# Assign predefined page format
		if ($wp->{page_format}) { 			# for pages
			$page_format = $wp->{page_format}; 
		} 
	} else {										# Assign requested format
		if ($vars->{format}) {				# for everything else
			$page_format = uc($vars->{format});
		} 
	}
		
						# Record Format
	my $record_format = $table. "_" . lc($page_format);	# default record format	
	# Special formats for 'types' of content
	# Eg., for types of post: comment, link, article, gallery, announcement
	if ($table eq "post") { 
		if ($vars->{format}) { 
			$record_format = "post_".$wp->{post_type}."_".lc($vars->{format});
		} elsif ($wp->{post_type}) {
			$record_format = "post_".$wp->{post_type}."_".lc($page_format);
		} else {
			$record_format = "post_link_".lc($page_format);
		}	
	} 
	
						
	my $mime_type = &set_mime_type($page_format);					# Mime Types
					

	return ($page_format,$record_format,$mime_type);
}

# -------  Mime Types ------------------------------------------------------

sub set_mime_type {
	
	my ($page_format) = @_;
	if ($page_format =~ /RSS|OPML|XML|DC|ATOM/i) { 
		$mime_type = "text/xml";
	} elsif ($page_format =~ /TEXT|TXT/i) {
		$mime_type = "text/plain"; 
	} elsif ($page_format =~ /JSON/i) {
		$mime_type = "application/json";
	} elsif ($page_format =~ /JS/i) {
		$mime_type = "text/Javascript";
	} else {
		$mime_type = "text/html";
	}
	return $mime_type;	
	#	my $mime_type = "text/html; charset=utf-8";					# default mime
}


# -------  Clean Up ------------------------------------------------------


sub clean_up {		# Misc. clean-up for print
	my ($text_ptr,$format) = @_;
	$format ||= "";
	$$text_ptr =~ s/BEGDE(.*?)ENDDE//mig;				# Kill unfilled data elements
	$$text_ptr =~ s/\[<a(.*?)href=""(.*?)>(.*?)<\/a>\]//mig;			# Kill blank Nav	
	$$text_ptr =~ s/<a(.*?)href=""(.*?)>(.*?)<\/a>/$1 $2 $3/mig;			# Kill blank URLs

	$$text_ptr =~ s/<img(.*?)src=""(.*?)>//mig;			# Kill blank img
	$$text_ptr =~ s/1 Replies/1 Reply/mig;				# Depluralize replies
	$$text_ptr =~ s/0 Reply/0 Replies/mig;
	$$text_ptr =~ s/&quot;/"/mig;					# Replace quotes

	$$text_ptr =~ s/&amp;#(.*?);/&#$1;/mig;				# Fix broken special chars
	$$text_ptr =~ s/&#147;/"/mig;
	$$text_ptr =~ s/&#148;/"/mig;
	$$text_ptr =~ s/&#233 /&#233; /g;		# For U de M, which drops a ;
	$$text_ptr =~ s/&amp;#233 /&#233; /g;		# For U de M, which drops a ;


	$$text_ptr =~ s/\x18\x20/'/g;
	$$text_ptr =~ s/\x19\x20/'/g;
	$$text_ptr =~ s/\x1a\x20/'/g;
	$$text_ptr =~ s/\x1c\x20/"/g;
	$$text_ptr =~ s/\x1d\x20/"/g;
	$$text_ptr =~ s/\x1e\x20/"/g;


	$$text_ptr =~ s/&apos;/'/mig;					# '
	$$text_ptr =~ s/&#39;/'/mig;					# '

						# Site Info
	$$text_ptr =~ s/<st_url>/$Site->{st_url}/g;
	$$text_ptr =~ s/<st_cgi>/$Site->{st_cgi}/g;
	
	$$text_ptr =~ s/ & / &amp; /mig;					# Catch hanging ampersands

	$$text_ptr =~ s/,\s+}/}/g;
	$$text_ptr =~ s/&amp;nbsp;/ /g;
	

	

	return;
}

#------------------------  Strip HTML --------------------
	
sub strip_html {
	
	# Source
	#########################################################
	# striphtml ("striff tummel")
	# tchrist@perl.com 
	#########################################################

	my ($text_ptr) = @_;
	
	$$text_ptr =~ s/&gt;/>/ig;
	$$text_ptr =~ s/&lt;/</ig;
	
	$$text_ptr =~ s/(<br>|<br\/>|<br \/>|<p>)/\n/ig;
	$$text_ptr =~ s{ <!(.*?)(--.*?--\s*)+(.*?)>}{if ($1 || $3) {"<!$1 $3>";}}gesx;                 
	$$text_ptr =~ s{ <(?:[^>'"] *|".*?"|'.*?') +>}{}gsx;    
	$$text_ptr =~ s/\n\n\n/\n\n/g;     
	$$text_ptr =~ s/\n/<br>/;         

}

sub de_cp1252 {
  my( $s ) = @_;

  #   Map incompatible CP-1252 characters
  $s =~ s/\x82/,/g;
  $s =~ s-\x83-<em>f</em>-g;
  $s =~ s/\x84/,,/g;
  $s =~ s/\x85/.../g;

  $s =~ s/\x88/^/g;
  $s =~ s-\x89- \B0/\B0\B0-g;

  $s =~ s/\x8B/</g;
  $s =~ s/\x8C/Oe/g;

  $s =~ s/\x98/'/g;
  $s =~ s/\x99/'/g;
  $s =~ s/\x93/"/g;
  $s =~ s/\x94/"/g;
  $s =~ s/\x95/*/g;
  $s =~ s/\x96/-/g;
  $s =~ s/\x97/--/g;
 # $s =~ s-\x98-<sup>~</sup>-g;
 # $s =~ s-\x99-<sup>TM</sup>-g;

  $s =~ s/\x9B/>/g;
  $s =~ s/\x9C/oe/g;

  #   Now check for any remaining untranslated characters.
  if ($s =~ m/[\x00-\x08\x10-\x1F\x80-\x9F]/) {
      for( my $i = 0; $i < length($s); $i++) {
          my $c = substr($s, $i, 1);
          if ($c =~ m/[\x00-\x09\x10-\x1F\x80-\x9F]/) {
              printf(STDERR  "warning--untranslated character 0x%02X in input line %s\n",
                  unpack('C', $c), $s );
          }
      }
  }

  $s;
}

# -------   RSSify -----------------------------------------------------------

#
#     Make XML parser safe
#

sub format_rssify {		# Misc. clean-up for print

	my ($text_ptr) = @_;

	$$text_ptr =~ s/&(\w+?);/AMPERSAND$1; /g;
	$$text_ptr =~ s/&/&amp;/mig;
	$$text_ptr =~ s/AMPERSAND(\w+?);/&$1;/g;
	$$text_ptr =~ s/AMPERSAND/&/mig;

	
}




# -----------   Auto Categories --------------------------------------------------


sub autocats {

	my ($dbh,$query,$text_ptr,$table,$filldata) = @_;
	my $vars = (); if (ref $query eq "CGI") { $vars = $query->Vars; }



	# Define some fields
	my $idfield = $table."_id";
	my $tfield = $table."_title";
	my $dfield = $table."_description";
    	my $acfield = $table."_autocats";
    	my @tlist;
	
	
	if (($filldata->{$acfield} eq "") || ($vars->{autocats} eq "force")) {		# if autocats are not defined in table_authcats, then 
	

		unless ($vars->{topicdefinitions}) {							# Get topic list (just once)
			my $tsql = "SELECT * from topic";
			my $tsth = $dbh->prepare($tsql);
			$tsth->execute();
			while (my $topic = $tsth -> fetchrow_hashref()) {
				$vars->{topicdefinitions}->{$topic->{topic_title}} = $topic->{topic_where};	
				$vars->{topicids}->{$topic->{topic_title}} = $topic->{topic_id};	
			}
		}
	
		my $tdata = $filldata->{$tfield}.$filldata->{$dfield};					# Find topics in data
		while ( my ($tx,$ty) = each %{$vars->{topicdefinitions}}) {
			if ($tdata =~ m/$ty/) { push @tlist,"$tx"; }				
		}		

		$filldata->{$acfield} = join ";",@tlist;						# Save the topic list in table_authcats
		# print "Autocats: $filldata->{$acfield} <br>";
		unless ($filldata->{$acfield}) { $filldata->{$acfield} = "none"; }
		&db_update($dbh,$table,{$acfield => $filldata->{$acfield}},$filldata->{$idfield});	
	}
	
	# find List of Topics in Text  (@topiclist in $$text_ptr)
	# then store in table_authcats
	

	unless (@tlist) { @tlist = split ";",$filldata->{$acfield}; }

	# HTML Topics
	while ($$text_ptr =~ m/<TOPIC>(.*?)<END_TOPIC>/g) {
		my $id = $1; my $replace = "";
		foreach my $t (@tlist) { 
			if ($replace) { $replace .= ", "; } 
			$replace .= $t;
		}
		unless ($replace) { $replace = "None"; }
		$replace = "[Tags: $replace]";
		$$text_ptr =~ s/<TOPIC>\Q$id\E<END_TOPIC>/$replace/sig;
	}
	
	# XML Topics
	while ($$text_ptr =~ m/<XMLTOPIC>(.*?)<END_XMLTOPIC>/g) {
		my $id = $1; my $replace = "";

		foreach my $t (@tlist) { 
			my $topicurl = $Site->{st_url} . "topic/" . $vars->{topicids}->{$t};
			$replace .= qq|      <category domain="$topicurl">$t</category>\n|;
		}
		$$text_ptr =~ s/<XMLTOPIC>\Q$id\E<END_XMLTOPIC>/$replace/sig;
	}

}



















#-------------------------------------------------------------------------------
#
#           Make Functions 
#
#-------------------------------------------------------------------------------

# -------  Make Page Data -------------------------------------------------------
#
#
#   Given an input text reference $text_ptr and table data hash $reference,
#   will replace instances of [*table_field*] with $table->{field}
#   in $$text_ptr

sub make_data_elements {
	
	my ($text_ptr,$table,$format) = @_;	
	
	my @data_elements = ();
	while ($$text_ptr =~ /\[\*(.*?)\*\]/) {
		my $de = $1; push @data_elements,$de; 
		$$text_ptr =~ s/\[\*(.*?)\*\]/BEGDE $de ENDDE/si;
	}
	
	foreach my $data_element (@data_elements) {
		
		unless (defined $table->{$data_element}) { $table->{$data_element} = ""; }
		if ($format =~ /JS|JSON/i) { &esc_for_javascript(\$table->{$data_element}); } 	# JS/JSON escape		
		$$text_ptr =~ s/BEGDE $data_element ENDDE/$table->{$data_element}/mig;
	}
	
}



# -------  Make Page Data -------------------------------------------------------
#
# Lets you send some link data to a page using page variables
# eg. ... &pagedata=post,12,rdf
# Separate values with commas. make_pagedata() will insert them into
# appropriately numbered fields. Eg. <pagedata 1> for the first,
# <pagedata 2> for the second, etc.
# Typically, usage is: pagedata=table,id_number,format
# Receives text pointer and query as input; acts directly on text
# Note that this will not work on static versions of pages

sub make_pagedata {

	my ($query,$input,$title) = @_;

	return unless (defined $input);
	my $vars = (); if (ref $query eq "CGI") { $vars = $query->Vars; }
	return unless (defined $vars->{pagedata});
	my @insertdata = split ",",$vars->{pagedata};

	my $count;
	while ($$input =~ /<pagedata (.*?)>/mig) {
	
		my $autotext = $1;		
		$count++; last if ($count > 100);			# Prevent infinite loop
		my $replace = "";
		
		my $replacenumber = $autotext-1;
		next unless ($replacenumber >= 0);
		$replace = $insertdata[$replacenumber];

		$$input =~ s/<pagedata $autotext>/$replace/;
	}
	
									# Write Page Title
	$$input =~ s/\Q[*page_title*]\E/$$title/g;
	$$input =~ s/\Q<page_title>\E/$$title/g;


}

# -------  Make Login Info --------------------------------------------------------
#
# Looks at the Person object and creates a personalized set of
# login options for that user
# Receives text pointer as input; acts directly on text

sub make_login_info {

	my ($dbh,$query,$text_ptr,$table,$id) = @_;
	return unless (defined $text_ptr);
	
#	if ($diag eq "on") { print "Make Login Info ($table $text_ptr)\n"; }
    	my $vars = ();
    	if (ref $query eq "CGI") { $vars = $query->Vars; }

#	my $refer = $Site->{script} . "?" . $table . "=" . $id . "#comment";
#	my $logout_link = $Site->{st_cgi} . "login.cgi?action=Logout&refer=".$refer;
#	my $login_link = $Site->{st_cgi} . "login.cgi?refer=".$refer;
#	my $options_link = $Site->{st_cgi} . "login.cgi?action=Options&refer=".$refer;

#	my $name = $Person->{person_name} || $Person->{person_id};

#	my $replace = "";
#	if (($Person->{person_id} eq 2) ||
#	    ($Person->{person_id} eq "")) {

#		$replace = qq|
#			You are not logged in. 
#			[<a href="$login_link">Login</a>]
#		|;

#	} else {
#		$replace = qq|
#			You are logged on as $name. 
#			[<a href="$logout_link">Logout</a>]
#			[<a href="$options_link">Options</a>]
#		|;
#	}
#

	my $replace = qq|<script language="Javascript">comment_login_box();</script>|;
	$$text_ptr =~ s/<LOGIN_INFO>/$replace/sig;

}



# -------  Make Site Info --------------------------------------------------------
#
# Puts site variables into pages
# Site variables are found in the site data file in cgi-bin/data
# For security reasons, only st_ (site) and em_ (email) variables are filled

sub make_site_info {

	my ($text_ptr) = @_;
	return unless (defined $text_ptr);
	
	while (my($sx,$sy) = each %$Site) {	
		next unless ($sx =~ /^(em|st)/);		
		$$text_ptr =~ s/<$sx>/$sy/mig;
		$$text_ptr =~ s/&lt;$sx&gt;/$sy/mig;		
	}

}

sub make_site_hits_info {
	
	my ($text_ptr) = @_;
	return unless (defined $text_ptr);
	
	while ($$text_ptr =~ /<site_hits>/sig) {

						# Site Page Hit Totals
		my $post_today; my $page_today; my $event_today;	
		my $post_total; my $page_total; my $event_total;					
		print "Content-type: text/html\n\n";
	
		# Posts - today
		my $sth = $dbh->prepare("SELECT SUM(post_hits) FROM post");
		$sth->execute();					
		my ($post_today) = $sth->fetchrow_array();

	
		# Posts - total
		my $sth = $dbh->prepare("SELECT SUM(post_total) FROM post");
		$sth->execute();					
		my ($post_total) = $sth->fetchrow_array();

		my $site_hits = "Posts viewed: $post_today today, $post_total all time.<br>";
	
		$$text_ptr =~ s/<site_hits>/$site_hits/;	
	}
	
}	
	
# -------  Make Hits -------------------------------------------------------------
#
#  Fill values for today and total number of hits recorded by the hit counter
#  Replaces <hits> command

sub make_hits {

	my ($text_ptr,$table,$id,$filldata) = @_;
	return unless (defined $table eq "post");			# Hits only for posts
	return unless (defined $text_ptr);

	my $count=0;
	
	while ($$text_ptr =~ /<hits>/sig) {
			
		my $autotext = $1;
		$count++; last if ($count > 100);			# Prevent infinite loop

		my $replace = "";
		my $parse = $autotext;
		
		my $hits = $filldata->{$table."_hits"};
		my $total = $filldata->{$table."_total"};		
		
		$$text_ptr =~ s/<hits>/$hits\/$total/;
	}


}

# -------  Make Next -------------------------------------------------------------
#

sub make_next {

	my ($dbh,$input,$table,$id_number,$filldata) = @_;
	if ($diag>9) { print "Make Next<br>"; }
	
	unless (defined $input) { if ($diag>9) { print "/Make Next - input not defined<br>"; } return;	}
	unless (defined $input) { if ($diag>9) { print "/Make Next - input not defined<br>"; } return;	}
	
	my @directions = qw(next previous first last);
	foreach my $direction (@directions) {

		my $count=0;
		while ($$input =~ /<$direction(.*?)>/sig) {
			
			$count++; last if ($count > 100);			# Prevent infinite loop	
		
			my $autocontent = $1;my $nexttext = "";
			next if ($autocontent eq "BuildDate");			# Fixes RSS bug, need something more permanent
			
			my $script = {}; 
			&parse_keystring($script,$autocontent);
			my $format = $script->{format} || $vars->{format} || "html";
			

			if ($script->{type}) { 	$typesql = " ".$table."_type='".$script->{type}."' AND ";  }		
			
			my $nextsql ="SELECT ".$table."_id FROM $table WHERE $typesql ".$table."_id ";		
			
			if ($direction eq "next") {  $nextsql .= ">'".$id_number."' ORDER BY ".$table."_id";}		
			elsif ($direction eq "previous") { $nextsql .= "<'".$id_number."' ORDER BY ".$table."_id DESC";}	
			elsif ($direction eq "first") { $nextsql .= "<'".$id_number."' ORDER BY ".$table."_id";}	
			elsif ($direction eq "last") { $nextsql .= ">'".$id_number."' ORDER BY ".$table."_id DESC";}	
			$nextsql .= " LIMIT 1";
								
			my ($newnextid) = $dbh->selectrow_array($nextsql);
			if ($newnextid) { 
				$nexttext = qq|[<a class="next" href="|.$Site->{st_cgi}.
					qq|page.cgi?$table=$newnextid&format=$format">@{[&printlang(ucfirst($direction))]}</a>]|; 
			}
			$$input =~ s/$autotext/$nexttext/; 
		}
		
	}
	if ($diag>9) { print "/Make Next<br>"; }

}


# -------  Make Counter -------------------------------------------------------------

sub make_counter {
	my ($dbh,$input,$silent) = @_;

	my @boxlist;
	while ($$input =~ /<counter(.*?)>/sig) {

		my $autotext = "<counter".$1.">";
		
		if ($1 eq " increment") { 
			#$Site->{keyword_counter}++; 
		} else { 		
			my $script = {}; 
			&parse_keystring($script,$1);
			if ($script->{start}) {	
					$Site->{keyword_counter} = "joe";
					if ($Site->{keyword_counter}==1) { $Site->{keyword_counter} = $script->{start}; } }
			#if ($script->{increment}) { $Site->{keyword_counter} += $script->{increment}; } else { $Site->{keyword_counter}++; }	
					
		}
		
		my $replace = $Site->{keyword_counter};
		$$input =~ s/$autotext/$replace/;
	}

}




# -------  Make Boxes -------------------------------------------------------------

sub make_boxes {
	my ($dbh,$input,$silent) = @_;

	my @boxlist;
	while ($$input =~ /<box (.*?)>/sig) {
	
		my $autotext = $1;
		
		&error($dbh,"","",&printlang("No box recursion")) unless (&index_of($autotext,\@boxlist) == -1);
		push @boxlist,$autotext;

		my $box_content = db_get_content($dbh,"box",$autotext);
		&make_site_info(\$box_content);	
		$$input =~ s/<box $autotext>/$box_content/;
	}

}


sub make_escape {

	my ($dbh,$input,$silent) = @_;
	return unless $$input =~ /<escape>/;
	my $newinput = "";
	
	my @elist = split /<escape>/,$$input;
	foreach my $eitem (@elist) {
		unless ($newinput) { $newinput = $eitem; next; }
		my ($escarea,$nonescarea) = split "</escape>",$eitem;
		$escarea = HTML::Entities::encode($escarea);
		$newinput .= $escarea.$nonescarea;
	}
	$$input = $newinput;
}



# -------   Make Keylist ------------------------------------------------------
#
#           Analyzes <keylist ...> command in text
#           A keylist is a series of records linked via entries in the graph table
#	    make_keylist parses a <keylist> command and replaces it with a 
#           list of names with links. format: <keylist db=link,id=234,keytable=author>
#	      Edited: 14 January 2013
#-------------------------------------------------------------------------------

sub make_keylist {
	
	my ($dbh,$query,$text_ptr) = @_;
	if ($diag>9) { print "Make Keylist <br>"; }
	
   	my $vars = ();	
       	if (ref $query eq "CGI") { $vars = $query->Vars; }


	unless ($$text_ptr =~ /<keylist (.*?)>/i) { 
		if ($diag>9) { print "/Make Keylist - No content found<br>"; }
		return 1 
	} 	

	while ($$text_ptr =~ /<keylist (.*?)>/ig) {

		my $autocontent = $1; my $replace = "";
#print " -- $autocontent <br>";		

						# No endless loops, d'uh
		$escape_hatch++; die "Endless keyword loop" if ($escape_hatch > 10000);		
		$vars->{escape_hatch}++; die "Endless recursion keyword loop" if ($escape_hatch > 10000);		

						# Pasre Keyword into Script
		my $script = {}; 
		&parse_keystring($script,$autocontent);
		
		$script->{separator} = $script->{separator} || ", ";

		for (qw(prefix postfix separator)) {
			if ($script->{$_} =~ /(BR|HR|P)/i) { 
				$script->{$_} = "<".$script->{$_}.">"; 
			}
		}
	
		our $ddbbhh = $dbh;
#print " Finbding graph $script->{db},$script->{id},$script->{keytable} <br>";		
		my @connections = &find_graph_of($script->{db},$script->{id},$script->{keytable});
		
		foreach my $connection (@connections) {
	
									# Get item data 
									
									# Prepare SQL Query for each item
									# (We could probably combine into one
									# by making a large 'OR' out of all the ID
									# numbers...
			my $titfield = get_key_namefield($script->{keytable});		
			my $klid = $script->{keytable}."_id";
			$script->{search} =~ s/'//; $connection =~ s/'//;
				
			my $keylistsql = qq|SELECT * FROM $script->{keytable} WHERE $klid = '$connection'|;
			if ($script->{search}) { 
				my $descfield = $script->{keytable}."_description";
				my $catfield = $script->{keytable}."_category";								
				my $contfield = $script->{keytable}."_content";	
				my $keylistwhere = qq| AND ($descfield LIKE '%$script->{search}' OR 
						$titfield LIKE '%$script->{search}%' OR
						$contfield LIKE '%$script->{search}%' OR
						$catfield LIKE '%$script->{search}%')|;	
				$keylistsql .= $keylistwhere;
			}
			
									# Execute SQL Query for each item
			my $sth = $dbh->prepare($keylistsql);
			$sth -> execute();
			while (my $c = $sth -> fetchrow_hashref()) { 
			
				next unless ($c);			# Items that don't match $script->{search}
									# if it's used will not return results

									# Display the result
				my $kname = $c->{$titfield};
				if ($replace) { $replace .= $script->{separator}; }	
				if ($script->{format} eq "text") { $replace .= qq|$kname|; } 
				elsif ($script->{format}) { 
					my $ftext = &format_record($dbh,$query,$script->{keytable},"$script->{format}",$c);
					$replace .= $ftext; }
				else { $replace .= qq|<a href="$Site->{st_url}$script->{keytable}/$connection" style="text-decoration:none;">$kname</a>|; $replace =~ s/\n/<br\/>/ig; }
			


			}
			$sth->finish();						
			
			
			
			
		}
#print " -- $replace <br>";

		if ($replace) { $replace = $script->{prefix} . $replace . $script->{postfix}; }
		$$text_ptr =~ s/\Q<keylist $autocontent>\E/$replace/;
		
		
	}       		
       		
	if ($diag>9) { print "/Make Keylist <br>"; }
}


#-------------------------------------------------------------------------------
#
# -------   Make Author Info ------------------------------------------------------
#
# 
#   For a record $r finds the appropriate author records and returns
#   formated content
#
#   For example:  <author summary>  returns author records in author_summary format
#
#	      Edited: 19 April 2013
#-------------------------------------------------------------------------------
   	
 sub make_author {
	
	my ($text_ptr,$table,$id,$filldata) = @_;  	
	
   	return 1 unless ($$text_ptr =~ /<author (.*?)>/i);       	
	while ($$text_ptr =~ /<author (.*?)>/ig) {

		my $autocontent = $1; my $replace = ""; 

		&escape_hatch();
		

		my @connections = &find_graph_of($table,$id,"author");
		foreach my $connection (@connections) {

			my $author = &db_get_record($dbh,"author",{author_id=>$connection});
			if ($author->{author_id}) {
				$replace .= &format_record($dbh,$query,"author",$autocontent,$author);
			}

		}


		
		$$text_ptr =~ s/\Q<author $autocontent>\E/$replace/;
					
	}
	
}
   	
   	
#-------------------------------------------------------------------------------
#
# -------   Make Enclosures ------------------------------------------------------
#
#    Make a list of enclosures at the <enclosures> tag
#
#	      Edited: 21 Jan 2013
#-------------------------------------------------------------------------------

sub make_enclosures {
	
	my ($text_ptr,$table,$id,$filldata) = @_;
	
   	return 1 unless ($$text_ptr =~ /<enclosures (.*?)>/i);       	
	while ($$text_ptr =~ /<enclosures (.*?)>/ig) {

		my $autocontent = $1;my $replace = ""; my $style = "";

		&escape_hatch();
		
		my @enclosures = &find_graph_of($table,$id,"file","Enclosure");
		foreach my $enclosure (@enclosures) {
			my $file = &db_get_record($dbh,"file",{file_id=>$enclosure});
			if ($autocontent eq "format=html") { 
				$replace .= qq|- <a href="$Site->{st_url}$file->{file_dirname}">$file->{file_title}</a><br/>|;
			} elsif  ($autocontent eq "format=html") { 
				$replace .= qq|<enclosure url="$Site->{st_url}$file->{file_dirname}" length="$file->{file_size}" type="$file->{file_size}" />|;
			}
		}
		if ($replace) { 
			if ($autocontent eq "format=html") { $replace = qq|<p>Enclosures:<br>$replace</p>|; }
		}

		$$text_ptr =~ s/\Q<enclosures $autocontent>\E/$replace/;	
		
	}       		
	
}	
   	
  
  
#-------------------------------------------------------------------------------
#
# -------   Make Media ------------------------------------------------------
#
# 
#   For a record $r finds the appropriate image file $f or alignment $a and
#   width $w and returns the formated image (with captions, etc., as
#   appropriate given width parameters).
#
#	      Edited: 21 Jan 2013
#-------------------------------------------------------------------------------


sub make_media {
	
	my ($text_ptr,$table,$id,$filldata) = @_;
#print "Making media<p>";	
   	return 1 unless ($$text_ptr =~ /<media (.*?)>/i);       	
	while ($$text_ptr =~ /<media (.*?)>/ig) {

		my $autocontent = $1; my $replace = ""; my $style = "";

		&escape_hatch();
		
		my $typeval; my $width;
		if ($autocontent eq "display") { 
			$width = "400";
			$style = qq|style="width:400px;margin:5px 15px 5px 0px;"|;
		}
		else { $typeval = autocontent; }		


		if ($autocontent eq "icon") { $replace =  &make_icon($table,$id,$filldata)."<p>";


		} else { $replace =  &make_media_display($table,$id,$autocontent,$style,$filldata)."<p>"; 
		

		}
		

		$$text_ptr =~ s/\Q<media $autocontent>\E/$replace/;	
		
	}       		
	
}	

 	
   	
#-------------------------------------------------------------------------------
#
# -------   Make Image ------------------------------------------------------
#
# 
#   For a record $r finds the appropriate image file $f or alignment $a and
#   width $w and returns the formated image (with captions, etc., as
#   appropriate given width parameters).
#
#	      Edited: 21 Jan 2013
#-------------------------------------------------------------------------------


sub make_images {
	
	my ($text_ptr,$table,$id,$filldata) = @_;
	
   	return 1 unless ($$text_ptr =~ /<image (.*?)>/i);       	
	while ($$text_ptr =~ /<image (.*?)>/ig) {

		my $autocontent = $1; my $replace = ""; my $style = "";

		&escape_hatch();
		
		my $typeval; my $width;
		if ($autocontent eq "display") { 
			$width = "400";
			$style = qq|style="width:400px;margin:5px 15px 5px 0px;"|;
		}
		else { $typeval = autocontent; }		


		if ($autocontent eq "icon") { $replace =  &make_icon($table,$id,$filldata)."<p>";


		} else { $replace =  &make_display($table,$id,$autocontent,$style,$filldata)."<p>"; 
		

		}
		

		$$text_ptr =~ s/\Q<image $autocontent>\E/$replace/;	
		
	}       		
	
}	

#-------------------------------------------------------------------------------
#
# -------   Make Icon ------------------------------------------------------
#
# Makes icon text for a record in response to an <image icon> tag
# 
# 

sub make_icon {

	my ($table,$id,$filldata) = @_;
	$Site->{st_icon} ||= "files/icons/";		# Default icon directory location
	my $width = "100";
	my $style = qq|style="width: 100px; float:left; margin:5px 15px 5px 0px;"|; 
	my $iconurl = "";	
	

	my $iconlink = $Site->{st_url}.$table."/".$id."/rd";	
	
	# Defined icon over-rides everything
	if ($filldata->{$table."_icon"} && -e $Site->{st_urlf}.$Site->{st_icon}.$filldata->{$table."_icon"}) {
		$iconurl = $Site->{st_url} . $Site->{st_icon} . $filldata->{$table."_icon"};
	
	# In certain cases, default to author icon
	} elsif ($table eq "author" || $filldata->{$table."_genre"} eq "Column") {
		$iconurl = &make_related_icon($table,$id,"author");
	} 

	# Otherwise, look for autogenerated icon	
	unless ($iconurl) {
		if (-e $Site->{st_urlf}.$Site->{st_icon}.$table."_".$id.".jpg") {
			$iconurl = $Site->{st_url} . $Site->{st_icon} . $table."_".$id.".jpg";
			$filldata->{$table."_icon"} = $table."_".$id.".jpg";
		
		# Otherwise, try the author icon 
		} else {
			$iconurl = &make_related_icon($table,$id,"author");
		}
		
		unless ($iconurl) {
			$iconurl = &make_related_icon($table,$id,"feed");
			
		}
	}
	
	if ($iconurl) {
		return  qq|<div class="image_icon" $style>
		           <a href="$iconlink"><img src="$iconurl" alt="Icon" width=$width></a>
		           </div>|;	
	}
	
	return "";
}


sub make_display {
	
	my ($table,$id,$autocontent,$style,$filldata) = @_;
	my $replace = "";
	my $imagefile = &item_images($table,$id,"largest");
	my $imlink = $imagefile->{file_link} || $filldata->{$table."_link"};
	my $width = 400;
	
	if ($imagefile->{file_dirname}) {
		$replace =  qq|<div class="image_$autocontent">
		<a href="$imlink"><img src="<st_url>$imagefile->{file_dirname}" $style 
		alt="$imagefile->{file_dirname}" width="$width"></a></div>|; 
	}

	return $replace;
	
}

#          Item Images
#
#          Get the largest or smallest image associated with an item
#          This is used to make icons and display images
#          Provide, table, id, and option = largest|smallest
#          Full image record is returned

sub item_images {
	
	
	my ($table,$id,$option) = @_;
	
	my $replace; my $largest_size = 0; $smallest_size = 10000000; my $largest_image; my $smallest_image;
	
	# Get the list of all images
	my @image_list_a = &db_get_record_list($dbh,"graph",
		{graph_tableone=>$table,graph_idone=>$id,graph_tabletwo=>'file',graph_type=>'Illustration'},"graph_idtwo");
	my @image_list_b = &db_get_record_list($dbh,"graph",
		{graph_tabletwo=>$table,graph_idtwo=>$id,graph_tableone=>'file',graph_type=>'Illustration'},"graph_idone");				
	my @image_list = &arrays("union",@image_list_a,@image_list_b);

	# Find the largest and smallest

	foreach my $image_id (@image_list) { 
		

		my $imagefile = &db_get_record($dbh,"file",{file_id=>$image_id});

		
		if ($imagefile->{file_size} > $largest_size) {
			
			$largest_size = $imagefile->{file_size};
			$largest_image = $imagefile;		
		}
		if ($imagefile->{file_size} < $smallest_size) {
			
			$smallest_size = $imagefile->{file_size};
			$smallest_image = $imagefile;			
		}		
	}	

	if ($option eq "largest") { return $largest_image; }
	elsif ($option eq "smallest") { return $smallest_image; }
	else { print "ERROR"; }
	
	
}

sub make_media_display {
	
	my ($table,$id,$autocontent,$style,$filldata) = @_;
	my $replace = "";

	my $imagefile = &item_media($table,$id,"largest");
	my $width = 400;


	$imagefile->{media_dirname} = $imagefile->{media_url};
	
	print "displaying media id number ".$imagefile->{media_id}."<P>".$imagefile->{media_dirname}."<p>";
	
	
	if ($imagefile->{media_dirname}) {
		$replace =  qq|Display<div class="image_$autocontent">
		<a href="$imagefile->{media_link}"><img src="$imagefile->{media_dirname}" $style 
		alt="$imagefile->{media_dirname}" width="$width"></a></div>|; 
	}

	return $replace."Display ".$imagefile->{media_dirname}."<br>";
	
}

sub item_media {
	
	
	my ($table,$id,$option) = @_;

	
	my $replace; my $largest_size = 0; $smallest_size = 10000000; my $largest_image; my $smallest_image;
	
	# Get the list of all images
	my @image_list_a = &db_get_record_list($dbh,"graph",
		{graph_tableone=>$table,graph_idone=>$id,graph_tabletwo=>'media'},"graph_idtwo");
	my @image_list_b = &db_get_record_list($dbh,"graph",
		{graph_tabletwo=>$table,graph_idtwo=>$id,graph_tableone=>'media'},"graph_idone");				
	my @image_list = &arrays("union",@image_list_a,@image_list_b);

	# Find the largest and smallest

	my $largest_size = 0;
	foreach my $image_id (@image_list) { 
		
		

		my $imagefile = &db_get_record($dbh,"media",{media_id=>$image_id});

		
		if ($imagefile->{media_width} > $largest_size) {
			
			$largest_size = $imagefile->{media_width};
			$largest_image = $imagefile;		
		}
		if ($imagefile->{media_width} < $smallest_size) {
			
			$smallest_size = $imagefile->{media_width};
			$smallest_image = $imagefile;			
		}		
	}	

	if ($option eq "largest") { return $largest_image; }
	elsif ($option eq "smallest") { return $smallest_image; }
	else { print "ERROR"; }
	
	
}


#-------------------------------------------------------------------------------
#
# -------   Make Author Icon ------------------------------------------------------
#
# Used my make_icon() to find an author icon
# 
# 

sub make_related_icon {
	
	my ($table,$id,$related) = @_;

	my @connections = &find_graph_of($table,$id,$related);
	foreach my $connection (@connections) {
		if (-e $Site->{st_urlf} . $Site->{st_icon} . $related."_".$connection.".jpg") {
			return $Site->{st_url} . $Site->{st_icon} . $related."_".$connection.".jpg";	
		}
	}
	return "";
}

#-------------------------------------------------------------------------------
#
# -------   Make Lunchbox ------------------------------------------------------
#
# Takes input content $content and lunchbox name $name and makes a slide-down lunchbox
# using javascript lunchboxOpen() scripts
#
#	      Edited: 21 Jan 2013
#-------------------------------------------------------------------------------

sub make_lunchbox {
	
	my ($food,$name,$title) = @_;

		$title ||= "Add more...";
		$lunchbox = qq|
	<div id="clasp_$name" class="clasp"><a href="javascript:lunchboxOpen('$name');">$title</a></div>
	<div id="lunch_$name" class="lunchbox">
		<div class="well">
		$food
		</div>
			
	</div>|;
	return $lunchbox;	
	
}

		

#-------------------------------------------------------------------------------
#
# -------   Make Keywords ------------------------------------------------------
#
#           Analyzes <keyword ...> command in text
#           Inserts contents from databased based on keyword commands
#	      Edited: 28 March 2010
#-------------------------------------------------------------------------------

 
sub make_keywords {

	my ($dbh,$query,$text_ptr) = @_;
	if ($diag>9) { print "Make Keywords <br>"; }
	
   	my $vars = (); my $results_count=0;
   	my $running_results_count;


 	
   	return 1 unless ($$text_ptr =~ /<keyword (.*?)>/i);				# Return 1 if no keywords
											# This allows static pages to be published
											# Otherwise, if keyword returns 0 results,
											# the page will not be published, email not sent
											
   	
    	if (ref $query eq "CGI") { $vars = $query->Vars; }

						# Substitute site tag (used to create filters)
	$$text_ptr =~ s/<st_tag>/$Site->{st_tag}/g;
		
								
						
						# For Each keyword Command
	my $escape_hatch=0; my $page_format = "";
	while ($$text_ptr =~ /<keyword (.*?)>/ig) {
		my $autocontent = $1; my $replace = ""; my $grouptitle = "";
	

						# No endless loops, d'uh
		$escape_hatch++; die "Endless keyword loop" if ($escape_hatch > 10000);		
		$vars->{escape_hatch}++; die "Endless recursion keyword loop" if ($escape_hatch > 10000);		

						# Pase Keyword into Script
		my $script = {}; 
		&parse_keystring($script,$autocontent);

						# Check Keyword Contents and Defaults
		next unless ($script->{db});
		$script->{number} ||= 50;

						# Make SQL from Keyword Data

						# Where
		my $where = &make_where($dbh,$script);
		
						# Number / Limit
		my $limit = ""; 
		if ($script->{start}) {
			$script->{number} ||= 10;
			$script->{start}--; if ($script->{start} < 0) { $script->{start} = 0; }
			$limit = " LIMIT $script->{start},$script->{number}";
		} elsif ($script->{number}) { $limit = " LIMIT $script->{number}"; }

		my $order = "";			# Order / Sort
		if ($script->{sort}) {
			my @orderlist = split ",",$script->{sort};
			foreach my $olst (@orderlist) {
				if ($order) { $order .= ","; }
				$order .= "$script->{db}_$olst";
			}
			$order = " ORDER BY " . $order;
		}


		my $sql = "SELECT * FROM $script->{db} $where$order$limit";


						# Permissions
						
		my $perm = "view_".$table;					
		if ((defined $Site->{perm}) && $Site->{$perm} eq "owner") {
			$where .= " AND ".$table."_creator = '".$Person->{person_id}."'";
		} else {
			return unless (&is_allowed("view",$script->{db},"","make keywords")); 
		}
	
#print "Content-type: text/html\n\n";						# Get Records From DB

		my $sth = $dbh -> prepare($sql);
		$sth -> execute();
		$results_count=0; 
		my $results_in = "";

						# For Each Record
		$Site->{keyword_counter}=0;		
		while (my $record = $sth -> fetchrow_hashref()) {
			$Site->{keyword_counter}++;
			$results_count++; 
			
				
						# Apply nohtml and truncate commands
						# to description or content fields

			my $descelement = $script->{db}."_description";
			my $conelement = $script->{db}."_content";
			my $titelement = $script->{db}."_title";

	
			if ($script->{truncate} || $script->{nohtml}) {
				$record->{$descelement} =~ s/<br>|<br\/>|<br \/>|<\/p>/\n\n/ig;
				$record->{$descelement} =~ s/\n\n\n/\n\n/g;				
				$record->{$descelement} =~ s/<(.*?)>//g; 
				$record->{$conelement} =~ s/<(.*?)>//g;
			}
			
						# Clean if for Javascript
			if ($script->{format} =~ /js|player/) {
				$titelement =~ s/"/&quote;/g; 
				$comelement =~ s/"/&quote;/g;
				$descelement =~ s/"/&quote;/g;
			}
	
			if ($script->{truncate}) {
				my $etc = "...";
				if (length($record->{$descelement}) > $script->{truncate}) { 
					$record->{$descelement} = substr($record->{$descelement},0,$script->{truncate}-1);
					$record->{$descelement} =~ s/(\w+)[.!?]?\s*$//;		
					$record->{$descelement}.=$etc;
				}
				if (length($record->{$conelement}) > $script->{truncate}) { 
					$record->{$conelement} = substr($conelement,0,$script->{truncate}-1);
					$record->{$conelement} =~ s/(\w+)[.!?]?\s*$//;	
					$record->{$conelement}.=$etc;
				}
			}
	

						# Format Record
			my $keyflag = 1;		# Tell format_record this is a keywords request 

			my $record_text = &format_record($dbh,
				$query,
				$script->{db},
				$script->{format},
				$record,
				$keyflag);

						# Add counter information
			$record_text =~ s/<count>/$results_count/mig;
			if ($results_count) { $vars->{results_count} = $results_count; }
	
						# Add Grouping titles
						
			if ($script->{groupby} eq "start date") {
				my $element_date = &epoch_to_date($record->{$script->{db}."_start"});	
				unless ($element_date eq $grouptitle) {
					$grouptitle = $element_date;
					$results_in .= qq|<div class="key_group">$grouptitle</div>|;
					
				}
				
			}
							
						# Add to Keyword Text
			$results_in .= $record_text;

		}
		
		
		$results_in =~ s/,$//;	# Remove trailing comma
		
		if ($results_count) {		
			$running_results_count += $results_count;
			# Insert Heading
			if ($script->{heading}) { 
				if ($script->{helptext}) {
					$results_in = "<h2>".$script->{heading} ."</h2><p>".$script->{helptext}."</p>".  $results_in;
				} else {
					$results_in = "<h2>".$script->{heading} ."</h2>".  $results_in;
				}
			}
			
			if ($script->{readmore}) {
				$results_in .= qq|Read more: <a href="$script->{readmore}">$script->{heading}</a>|;
			}
	
		} else {
			# If no results are found, and a empty format is specified, display empty format. -Luc
			if ($script->{empty_format}) {
				$results_in = &format_record($dbh, "", 	$script->{db}, 	$script->{empty_format}, "", 1);
			}
		}	
		
		$replace .= $results_in;
		

						# Insert Keyword Text Into Page

		$$text_ptr =~ s/\Q<keyword $autocontent>\E/$replace/;
		$sth->finish( );
	}


	if ($diag>9) { print "/Make Keywords <br>"; }
	return $running_results_count;
}


# -------  Parse Keystring ----------------------------------------------------

# Parses keyword string and fills script command hash

sub parse_keystring {
	my ($script,$keystring) = @_;

	foreach (split /;/,$keystring) {
		my ($cx,$cy) = split /=/,$_;
		if ($cx eq "all") { $cy = "yes"; }
		$cy =~ s/'//g; $cx =~ s/'//g;
		$script->{$cx} = $cy;
	}
	$script->{all} ||= "off";
}


#-------------------------------------------------------------------------------
#
# -------   Make Where ------------------------------------------------------
#
#		Called by make_keywords() and receives an individual script
#           Creates a 'where' statement based on keyword commands
#	      Edited: 28 March 2010
#
#-------------------------------------------------------------------------------


sub make_where {

	my ($dbh,$script) = @_; my @where_list;

	unless ($script->{id}) { undef $script->{id}; }

	if ($script->{lookup}) { 
		my $ret = "(".&make_lookup($dbh,$script).")"; 
		push @where_list,$ret;
	}


	# Set Start and Finish date-times
	# Input may be in the form yyyy/mm/dd hh:mm
	# of +/- offset (in seconds)
	# or NOW (for now)
	
	
	my $startafter; if ($script->{startafter}) {

		my $dts;
		if ($script->{startafter} =~ /^(\+|\-)/) {				# Offset Value
			$dts = time + $script->{startafter};
		} elsif ($script->{startafter} eq "NOW") {
			$dts = time;
		} else {								# RFC3339 value
			$dts = &rfc3339_to_epoch($script->{startafter});
		}

		$startafter = $script->{db}."_start > ".$dts;
		push @where_list,$startafter;

	}
	

	# The same as startafter, in seconds. 
	
	my $startbefore; if ($script->{startbefore}) {
		my $dtf;
		if ($script->{startbefore} =~ /^(\+|\-)/) {				# Offset Value
			$dtf = time + $script->{startbefore};
		} elsif ($script->{startafter} eq "NOW") {
			$dts = time;
		} else {								# RFC3339 value
			$dtf = &rfc3339_to_epoch($script->{startbefore});
		}
		$startbefore = $script->{db}."_starttime < ".$dtf;
		push @where_list,$startbefore;

	}

	my $expires; if ($script->{expires}) {
		
		# Auto Adjust for weekends
		my ($weekday) = (localtime time)[6];
		if (($weekday == 1) && ( $script->{expires} == 24)) { $script->{expires} = 72; }

		# Calculate Expires Time
		my $extime = time - ($script->{expires}*3600);
		$expires = $script->{db}."_crdate > ".$extime;
		push @where_list,$expires;
		
	}


	while (my($cx,$cy) = each %$script) {
		next if	($cx =~ /^(prefix|postfix|separator|color|number|startbefore|startafter|expires|heading|format|db|dbs|sort|start|next|all|none|wrap|lookup|nohtml|truncate|helptext|groupby|readmore)$/);
		if ($cx eq "event_start") { $cx = "start"; }

		my $flds; my $tval; my @fid_list;
		if ($cx =~ '!~') {								# does not contain
			($flds,$tval) = split "!~",$cx;
			my @matchlist = split ",",$flds;
			foreach my $ml (@matchlist) {
				push @fid_list,$script->{db}."_".$ml." NOT REGEXP '".$tval."'";
			}
		} elsif ($cx =~ '~') {								# contains
			($flds,$tval) = split "~",$cx;
			my @matchlist = split ",",$flds;
			foreach my $ml (@matchlist) {
				push @fid_list,$script->{db}."_".$ml." REGEXP '".$tval."'";
			}
		} elsif ($cx =~ 'GT') {								# greater than
			($flds,$tval) = split "GT",$cx;
			my @matchlist = split ",",$flds;
			foreach my $ml (@matchlist) {
				push @fid_list, $script->{db}."_".$ml." > '".$tval."'";
			}
		} elsif ($cx =~ 'LT') {								# less than
			($flds,$tval) = split "LT",$cx;
			my @matchlist = split ",",$flds;
			foreach my $ml (@matchlist) {
				push @fid_list, $script->{db}."_".$ml." < '".$tval."'";
			}	
		} elsif ($cx =~ '!=') {								# not equal
			($flds,$tval) = split '!=',$cx;
			my @matchlist = split ",",$flds;
			foreach my $ml (@matchlist) {
				push @fid_list, $script->{db}."_".$ml." <> '".$tval."'";
			}					
		} elsif (defined($cy)) {							# equals


			if ($cy eq "TODAY") { $cy = &cal_date(time); }
			push @where_list, $script->{db}."_".$cx." = '".$cy."'";
		}


		my $fwhere = join " OR ",@fid_list;
		if ($fwhere) { push @where_list,"(".$fwhere.")"; }
	}
	my $where = join " AND ",@where_list;
#print "Where: $where <p>";
#&log_event($dbh,$query,"where","$Site->{process}\t$where");
	if ($where) { $where = " WHERE $where"; }

	return $where;

}

# -------  Make UnpackedData ---------------------------------------------------

# 	Sometimes I store data in the form a1,b1,ca;a2,b2,c2; ... etc
#	This function receives that string
#	and returns it neatly formatted as a table
#	Use titles = a,b,c  (ie, a string with values separated by commas) for titles
#	Specify table properties with $tv, eg. {cellpadding=>14}
#	If $reqd is specified as a title, then there must be a value for that title to print 
#	Note that this value is only for checking if printing is OK, it will never actually be printed

sub make_unpackeddata {
	
	my ($data,$titles,$tablevals,$reqd) = @_;
	
	my $ret = qq|<table cellpadding="$tv->{cellpadding}" cellspacing="$tv->{cellspacing}" border="$tb->{border}">\n|;
	
	my @titlelist; if ($titles) {
		$ret .= "<tr>\n";
		my @titlelist = split ",",$titles; my $tcount=0;
		foreach my $tit (@titlelist) {
			$ret .= qq|<td>$tit</td>|;
		}
	}
	
	
	my @dl = split ";",$data;

	
	foreach my $dline (@dl) {
		my $lineret = qq|<tr>|; my $ct = 0; my $skip=0;
		my @dvls = split ",",$dline;
		foreach my $dv (@dvls) {
			if ($titlelist[$ct] && ($titlelist[$ct] eq $reqd)) {
				unless ($dv) { $skip = 1; }
			} else {
				$lineret .= qq|<td>$tit</td>\n|;
			}
		}	
		$lineret .= "</tr>\n";
		unless ($skip == 1) { $ret .= $lineret; }
	
	}
	$ret .= "<table>\n";
	return $ret;
	
}

# -------  Make Lookup ---------------------------------------------------------

sub make_lookup {
	my ($dbh,$script) = @_; my $str="";
	my ($look,$as) = split / as /,$script->{lookup}; 		#/ fix for code highligher
	my ($lf,$ll) = split / in /,$look;				#/
	my $lv = $script->{$lf};
	my $asitem = $as || $script->{db};
	my $ret = $ll."_".$asitem;
	die "Lookup command badly formed: $ll && $lf && $lv && $script->{db}" unless ($ll && $lf && $lv && $script->{db});

# print "Content-type: text/html; charset=utf-8\n\n$stmt -- $lv <br>"; 

						# Permissions
			
	my $where ="";
	my $perm = "view_".$ll;					
	if ((defined $Site->{perm}) && $Site->{$perm} eq "owner") {
		$where .= " AND ".$ll."_id = '".$Person->{person_id}."'";
	} else {
		return unless (&is_allowed("view",$ll,"","make lookup")); 
	}

	my $stmt = "SELECT $ret FROM $ll WHERE ".$ll."_".$lf." = ?".$where;
	my $sth = $dbh->prepare($stmt);
	$sth->execute($lv);
	while (my $ref = $sth -> fetchrow_hashref()) {
		if ($str) { $str .= " OR "; }
		$str .= $script->{db}."_id = '".$ref->{$ret}."'";
	}
	undef $script->{lookup};
	undef $script->{$lf};
	if ($str) { return $str; }
}





# -------   Header ------------------------------------------------------------

sub header {

	my ($dbh,$query,$table,$format,$title) = @_;
	$format ||= "html";
	my $template = $Site->{lc($format) . "_header"} || lc($format) . "_header";
	
	return &get_template($dbh,$query,$template,$title);

}

# -------   Footer -----------------------------------------------------------

sub footer {

	my ($dbh,$query,$table,$format,$title) = @_;
	$format ||= "html";
	my $template = $Site->{lc($format) . "_footer"} || lc($format) . "_footer";
	return &get_template($dbh,$query,$template,$title);


}














#-------------------------------------------------------------------------------				UPLOAD FUNCTIONS
#
#           Upload Functions 
#
#-------------------------------------------------------------------------------



# -------   Upload File --------------------------------------------------------------                          
#
#
#	      Edited: 21 January 2013
#
#----------------------------------------------------------------------

sub upload_file {
	
	
	my ($query) = @_;
	
	my $file = gRSShopper::File->new();
	$file->{file_title} = $query->param("file_name");

	$file->{file_dir} = $Site->{st_urlf} . "uploads";
	unless (-d $file->{file_dir}) { mkdir $upload_dir, 0755 or die "Error 1857 creating upload directory $file->{file_dir} $!"; }
	unless ($file->{file_title}) { $vars->{msg} .= " No file was uploaded."; }

	# Prepare Filename 	
	my ( $ffname, $ffpath, $ffextension ) = fileparse ( $file->{file_title}, '\..*' );  
	$file->{file_title} = $ffname . $ffextension;
	$file->{file_title} = &sanitize_filename($dbh,$file->{file_title});

	# Set File Upload Directory
	($file->{filetype},$file->{file_dir}) = &file_upload_dir($ffextension);
	my $fulluploaddir = $Site->{st_urlf} . $file->{file_dir};
	unless (-d $fulluploaddir) { mkdir $fulluploaddir, 0755 or die "Error 1867 creating upload directory $fulluploaddir $!"; }
	
		
	# Store the File
	my $upload_filehandle = $query->upload("file_name");
	$upload_filedirname = $file->{file_dir}.$file->{file_title};
	$upload_fullfilename = $Site->{st_urlf}.$upload_filedirname;
	
	# Prevent Duplicate File Names  (creates filename.n.ext where n is the increment number)
	my $ccnt = 0;		
	while (-e $upload_fullfilename) {
		my @farr = split /\./,$file->{file_title};
		my $ext = pop @farr;
		my $incr = pop @farr;
		$incr++;
		push @farr,$incr;
		push @farr,$ext;
		$file->{file_title} = join /\./,@farr;
		$upload_filedirname = $file->{file_dir}.$file->{file_title};
		$upload_fullfilename = $Site->{st_urlf}.$upload_filedirname;	
		$ccnt++; last if ($ccnt > 100000);			
	}	
		

	open ( UPLOADFILE, ">$upload_fullfilename" ) or &error($dbh,"","","Failed to upload $upload_fullfilename $!");  
	binmode UPLOADFILE;  
	while ( <$upload_filehandle> ) { print UPLOADFILE; } 
	close UPLOADFILE;

	$file->{fullfilename} = $upload_fullfilename;
		
	return $file;


}


# -------   Upload URL ---------------------------------------------------------------                                          
#
#
#	      Edited: 21 January 2013
#
#----------------------------------------------------------------------

sub upload_url {

	my ($url) = @_;
	return unless ($url);

	my $file = gRSShopper::File->new();

	
	# Prepare Filename 
	my @parts = split "/",$url; 										
	$file->{file_title} = pop @parts;
	$file->{file_title} = &sanitize_filename($dbh,$file->{file_title});

	# Set File Upload Directory
	my @pparts = split /\./,$file->{file_title};
	my $ffextension = "." . pop @pparts;			
	($file->{filetype},$file->{file_dir}) = &file_upload_dir($ffextension);
	my $fulluploaddir = $Site->{st_urlf} . $file->{file_dir};
	unless (-d $fulluploaddir) { mkdir $fulluploaddir, 0755 or die "Error 1892 creating upload directory $upload_dir $!"; }
	$file->{filedirname} = $file->{file_dir}.$file->{file_title};
	$file->{fullfilename} = $Site->{st_urlf}.$file->{filedirname};

	# Prevent Duplicate File Names  (creates filename.n.ext where n is the increment number)
	my $ccnt = 0;	
	while (-e $file->{fullfilename}) {
		my @farr = split /\./,$file->{file_title};
		my $ext = pop @farr;
		my $incr = pop @farr;
		$incr++;
		push @farr,$incr;
		push @farr,$ext;
		$file->{file_title} = join ".",@farr;	
		$file->{filedirname} = $file->{file_dir}.$file->{file_title};
		$file->{fullfilename} = $Site->{st_urlf}.$file->{filedirname};	
		$ccnt++; last if ($ccnt > 100000);	
	}
	
	# Get and Store the File
	
	my $result = getstore($url,$file->{fullfilename});
	
	unless ($result eq "200") {   
		$vars->{msg} .= qq|
			Error $result while trying to download <a href="$url">$url</a> <br> 
			Try saving manually and uploading from your computer|;
		$file->{fullfilename} = ""; $file->{file_title} = "";
		return 0;
	}

	return $file;

}


# -------   Sanitize Filename --------------------------------------------------------


sub sanitize_filename {

	my ($dbh,$filename) = @_; 
	my $safe_filename_characters = "a-zA-Z0-9_.-";

	$filename =~ tr/ /_/;  
	$filename =~ s/[^$safe_filename_characters]//g;
	if ( $filename =~ /^([$safe_filename_characters]+)$/ )  { $filename = $1;  }  
	else { &error($dbh,"","","Filename $filename contains invalid characters"); }

	return $filename;

}

# -------   Set File Upload Directory --------------------------------------------------------

sub file_upload_dir {

	my ($ff) = @_;
	my $filetype = "";
	my $dir = "";

	if ($ff =~ /\.jpg|\.jpeg|\.gif|\.png|\.bmp|\.tif|\.tiff/i) { 
		$filetype = "image"; $dir = $Site->{up_image} || "files/images/"; 
	} elsif ($ff =~ /\.doc|\.txt|\.pdf/i) {
		$filetype = "doc"; $dir = $Site->{up_docs} || "files/documents/"; 
	} elsif ($ff =~ /\.ppt|\.pps/i) {
		$filetype = "slides"; $dir = $Site->{up_slides} || "files/slides/"; 
	} elsif ($ff =~ /\.mp3|\.wav/i) {
		$filetype = "audio"; $dir = $Site->{up_audio} || "files/audio/"; 
	} elsif ($ff =~ /\.flv|\.mp4|\.avi|\.mov/i) {
		$filetype = "video"; $dir = $Site->{up_video} || "files/video/"; 
	} else {
		$filetype = "other"; $dir = $Site->{up_files} || "files/files/"; 
	}

	unless ($dir =~ /\/$/) { $dir .= "/"; }

	
	return ($filetype,$dir);
}


# -------  Auto Make Icon  --------------------------------------------------------                                                  
#
#
#	      Edited: 21 January 2013
#
#----------------------------------------------------------------------

#
#  Used with auto_post()
#  Find an associated media image, download it as a file,
#  and set it up as an icon
#

sub auto_make_icon {
	
	my ($table,$id) = @_;
	

	
	my $file = &auto_upload_image($table,$id);					# Upload image found in RSS feed
	if ($file =~ /Error:/) { return "Error uploading image"; }
	$file->{file_id} =  &db_insert($dbh,$query,"file",$file);			# Save file record (for later graphing)	

	my $icondir = $Site->{st_icon} || $Site->{st_urlf}."files/icons/";		# Define (or make) icon directory
	unless (-d $icondir) { mkdir $icondir, 0755 or die "Error creating icon directory $icondir $!"; }


	my $filename = $file->{file_title};						# Set image and icon filenames and directories
	my $filedir = $Site->{st_urlf}."files/images/";
	my $icondir = $Site->{st_urlf}."files/icons/";
	my $iconname = $table."_".$id.".jpg";
	my $icon = &make_thumbnail($filedir,$filename,$icondir,$iconname);		# make the icon
	
	
	if ($icon) {									# Update icon value in post record									
		&db_update($dbh,$table,{post_icon=>$icon},$id,"Update icon in $table"); # (not strictly necessary but loads image a bit faster)
	}
	
	return $file;
	
}


# -------  Auto Upload Image  --------------------------------------------------------                                                  
#
#
#	      Edited: 25 January 2013
#
#----------------------------------------------------------------------

sub auto_upload_image {
	
	my ($table,$id) = @_;
		
	my @graph = &find_graph_of($table,$id,"media");
	my $media; foreach my $media_id (@graph) {					# Find media associated with record
		$media = &db_get_record($dbh,"media",{media_id=>$media_id});		#    keep searching till you find an image
		next unless (($media->{media_mimetype} =~ /image/ || $media->{media_type} =~ /image/));		
		my $uploadedfile = &upload_url($media->{media_url});			#    then upload that image to the server
		if ($uploadedfile->{fullfilename}) {					#    if the upload was successful
			return $uploadedfile ;						#    return the newly created file record as an object
		}
			 
	}
	return "Error: could not find a record to upload."; 
	
}

# -------  Make Thumbnail  --------------------------------------------------------                                                  
#
#
#	      Edited: 21 January 2013
#
#----------------------------------------------------------------------

sub make_thumbnail {
	

	my ($dir,$img,$icondir,$iconname) = @_;

		
	return "Error: need both directory and file" unless ($img && $dir);		
	my $tmb = $img;
	if ($iconname) { $tmb = $iconname; }
	else { $tmb =~ s/\.(.*?)$/_tmb\.$1/; }
	
	my $dimf = $dir . $img;			# Full filename of original
	my $domf = $icondir . $tmb;		# Full filename of new icon
	
	my $image = Image::Magick->new;

	my $error = $image->Read($dimf);
	return "Error: reading $dimf image file: $error" if $error;

	$error = $image->Resize(geometry=>'100x100');
	return "Error: resizing image file: $error" if $error;

	my $error = $image->Write($domf);
	return "Error: writing $domf image file: $error" if $error;

	return $tmb;
	
	
}




























#-------------------------------------------------------------------------------
#
#           Form Functions 
#
#-------------------------------------------------------------------------------


#----------Auto-Post------------------------------------------------------------
#
#	Takes a harvested link id as input
#       Converts into a post
#
#-------------------------------------------------------------------------------

sub auto_post() {
	
	my ($dbh,$query,$linkid) = @_;
	
	my $link = &db_get_record($dbh,"link",{link_id=>$linkid});
	unless ($link->{link_id}) { return &printlang("Link error",$linkid); }
	
	
									# Uniqueness Constraints
	my $l = "";
	if (
	    ($l = &db_locate($dbh,"post",{post_link => $link->{link_link}}))  ||
	    ($l = &db_locate($dbh,"post",{post_title => $link->{link_title},post_feedid => $link->{link_feedid}})) 
	    ) {
	    	print "Not unique <br>";
	    	return $l;
	}    	

									# Create post 
						
	my $post = {
		post_journal => $link->{link_feed},	
		post_journalname => $link->{link_feedname},			
		post_creator => $Person->{person_id},
		post_feedid => $link->{link_feedid},
		post_crdate => $now,
		post_type => "link"
	};				
									# Fill with link data
	while (my($lx,$ly) = each %$link) {
		
		my $px=$lx; $px =~ s/link_/post_/i;
		$post->{$px} ||= $ly;
	
	}					
						
	my $now = time;

	
	$post->{post_id} = &db_insert($dbh,$query,"post",$post);	# save post record
	$vars->{post_twitter}="yes";
	$vars->{post_facebook}="yes";
	$vars->{msg} .= &publish_post($dbh,"post",$post->{post_id});	# Publish to Social Media
	
									# Create post graph
		
	$post->{type} = "post";			# Declare types for graphing
	$link->{type} = "link";
	&clone_graph($link,$post)		# Clone link graph items for post
	&save_graph("posted",$link,$post);	# Create graph linking link, post					

									
									# Update link status
	my $link = {
		link_post => $post->{post_id},
		link_status => "Posted"
	};
	&db_update($dbh,"link",$link,$linkid);				
	
	
	my $file = &auto_make_icon("post",$post->{post_id});			# Make post icon
	
	if ($file) {								# If a file was uploaded to make the icon		
										# Graph it to the post
		$file->{type} = "file";							# Declare types for graphing
		&save_graph("contains",$post,$file);					# Create graph linking post, file
	}		
	
	

	
	return $post->{post_id};	

	
}


# -------  Publish Post  --------------------------------------------------------                                                  
#
#
#	      Edited: 10 July 2013
#
#----------------------------------------------------------------------

sub publish_post {

	my ($dbh,$table,$id,$msg) = @_;


	if ($vars->{post_twitter}) { $vars->{twitter} = &twitter_post($dbh,"post",$id); }
	if ($vars->{post_facebook}) { $vars->{facebook} = &facebook_post($dbh,"post",$id);	}
	
	return $vars->{twitter}.$vars->{facebook};
}




# -------  Clone Graph  --------------------------------------------------------                                                  
#
#
#	      Edited: 21 January 2013
#
#----------------------------------------------------------------------

sub clone_graph {
	
	my ($link,$post) = @_;
	
	&diag(7,"Cloning graph for link $link->{link_id} autopost<br>");
	my $now = time;
	my $cr = $Person->{person_id};
	
	my $sql = qq|SELECT * FROM graph WHERE graph_tableone=? AND graph_idone = ?|;
	my $sth = $dbh->prepare($sql);
	$sth->execute("link",$link->{link_id});
	while (my $ref = $sth -> fetchrow_hashref()) {
		
		$ref->{graph_tableone} = "post";
		$ref->{graph_idone} = $post->{post_id};
		$ref->{graph_urlone} = $post->{post_link};
		$ref->{graph_crdate} = $now;
		$ref->{graph_creator} = $cr;	
		&diag(7,qq|------ Save Graph: [<a href="$ref->{graph_urlone}">$ref->{graph_tableone} $ref->{graph_idone}</a>] 
			$ref->{graph_type} [<a href="$ref->{graph_urltwo}">$ref->{graph_tabletwo} $ref->{graph_idtwo}</a>]<br>|);				
		&db_insert($dbh,$query,"graph",$ref);
	}
	
	my $sql = qq|SELECT * FROM graph WHERE graph_tabletwo=? AND graph_idtwo = ?|;
	my $file_list = "";
	my $sth = $dbh->prepare($sql);
	$sth->execute("link",$link->{link_id});
	while (my $ref = $sth -> fetchrow_hashref()) {
	
		$ref->{graph_tabletwo} = "post";
		$ref->{graph_idtwo} = $post->{post_id};
		$ref->{graph_urltwo} = $post->{post_link};
		$ref->{graph_crdate} = $now;
		$ref->{graph_creator} = $cr;	
		&diag(7,qq|------ Save Graph: [<a href="$ref->{graph_urlone}">$ref->{graph_tableone} $ref->{graph_idone}</a>] 
			$ref->{graph_type} [<a href="$ref->{graph_urltwo}">$ref->{graph_tabletwo} $ref->{graph_idtwo}</a>]<br>|);				
		&db_insert($dbh,$query,"graph",$ref);
	}	
}


# -------   API --------------------------------------------------------                                                  FORM EDITOR
#
# 	General API Functions
#
#	      Edited: 24 September 2012
#
#----------------------------------------------------------------------

#----------API: Send REST---------------------------------------------

sub api_send_rest {
	
	my ($dbh,$query,$url,$path,$data,$target) = @_;
       
									# Load REST::Client module
	unless (&new_module_load($query,"REST::Client")) { 
		print $vars->{error};
		exit;
	}
									# Load JSON Module
	unless (&new_module_load($query,"JSON")) { 
		print $vars->{error};
		exit;
	}
	
									# Load URI::Escape
	unless (&new_module_load($query,"URI::Escape")) { 
		print $vars->{error};
		exit;
	}
	  
      
        # Prepare content
        
        my $body = JSON->new->utf8->encode($data);

	$target =~ s/&amp;/&/g;
	$target = uri_escape($target);
	if ($target) { $target = "?target=$target"; }

	# Send Request

	my $client = REST::Client->new();
 	$client->POST($url.$path.$target,$body);
	my $loc = $client->responseContent();
	
	# Return Redirect URL 
	
	$loc =~ s/"//g;
	return $loc;

	exit;

	
	
}

sub api_receive_rest {
	
	my ($dbh,$query) = @_;
	
	
	
	
}



# -------   Editor --------------------------------------------------------                                                  FORM EDITOR
#
# 	General Editing Form Function
#
# 	Reqireds table and id numbers as inputs
# 	Also requires $showcols which identifies which columns to allow edit
# 	for and in which order. Sample:
# 	$showcols={table1 => ["column","column2"], table2 => ["column1","column2"] };
#
#	      Edited: 15 July 2010
#
#-------------------------------------------------------------------------------





sub form_editor() {
	
	my ($dbh,$query,$table,$showcols,$id_number,$data) = @_;

	my $vars = $query->Vars;
	my $form_text = "";
	my $autoblog = $vars->{autoblog};
	my $id; my $id_value;						# Not needed, but let's wipe out the value
										# in case they're used accidentally. Heh


						# Set Column Names

	my $fields = &set_fields($table);


						# Set record ID number, value

	unless ($dbh) { &error($dbh,$query,"","Database not ready") }	
	unless ($table) { &error($dbh,$query,"","A record type must be provided."); }
	my $id_value = "";
	if ($id_number) { $id_value = $id_number; }
	else { $id_value = "new"; }

		
	
						# Get Record
	my $record; my $quotationtext; my $link; my $feed;	
	$record = &db_get_record($dbh,$table,{$fields->{id} => $id_number});



						# Permissions
	if ($id_value =~ /new/i) {	return unless (&is_allowed("create",$table,"","$Person->{person_id} form editor")); } 
	else { return unless (&is_allowed("edit",$table,$record,"$Person->{person_id} form editor")); }
	

						# Create Titles

	$form_text .= "<h3>Edit ".ucfirst($table)."</h3>";

	if ($vars->{msg}) { $form_text .=  qq|<p class="notice">$vars->{msg}</p>|; }


						# Navigation
	unless ($vars->{autoblog}) {
		my $scripturl = $Site->{st_url}.$ENV{'REQUEST_URI'};
		$form_text .= qq|<p class="nav"> [<a href="$Site->{st_url}$table/$id_number">View |.ucfirst($table).qq|</a>] |;
		$form_text .= qq|[<a href="$Site->{script}?db=$table&action=list">List All |.ucfirst($table).qq|s</a>] |;
		$form_text .= qq|[<a href="$Site->{script}?db=$table&action=edit">Create New |.ucfirst($table).qq|</a>] |;
		if ($table eq "feed") { $form_text .= qq|[<a href="$Site->{st_cgi}harvest.cgi?feed=$id_number&force=yes">Harvest Feed</a>]</p>|; }
		$form_text .= qq|</p>|;
	}

						# Create Preview Version 

if ($table eq "post" || $table eq "event" || $table eq "author") {		# Temporary - posts for now
	if ($id_number && $id_number ne "new") { 

		my $wp = {}; 
		$vars->{comments} = "no";
		$wp->{table} = $table;
		$wp->{page_content} = &format_record($dbh,
				$query,
				$table,
				"summary",
				$record);


		&format_content($dbh,$query,$options,$wp);
		$form_text .= qq|	 
		 	<br><i>&nbsp;&nbsp;Preview:</i><br/><table border=1 cellpadding=10 cellspacing=0 width="600">
			<tr><td>
			$wp->{page_content}
			</td></tr></table></form><br>|;
	}
}





						# Create thread options
				

	$form_text .= &form_thread_options($table,$id_number,$record->{$fields->{location}});

						# Stuff for courses
						
						
	if ($record->{page_type} eq "course") {
		$form_text .=  qq|[<a href="course.cgi?action=review&page=$record->{page_id}">Review Entire Course</a>]<br/><br/>|;
	} elsif ($record->{post_type} eq "course") {
		$form_text .=  qq|[<a href="course.cgi?action=review&page=$record->{post_thread}">Review Entire Course</a>]<br/><br/>|;
	}

						# Create WYSIWYG Options
						
#	if ($table eq "post") {						
		$form_text .= qq[
        <script type="text/javascript">
	tinymce.init({selector:'textarea',
		plugins: [
			"advlist autolink lists link image charmap print preview anchor",
			"searchreplace visualblocks code fullscreen",
			"insertdatetime media table contextmenu paste"
			],
		insertdatetime_formats: ["%Y/%m/%d", "%H:%M"],
		extended_valid_elements : "script[language|type|src],link,keyword,box,time,date",	
		toolbar: "insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image",
		autosave_ask_before_unload: false,
		selector: "textarea.editme",
		browser_spellcheck: true,
		max_height: 200,
		min_height: 160,
		height : 180			
		});
</script>

		];
#	}

						# Create Form Heading
	$form_text .=  qq|
 		 <form method="post" id="contenteditor" action="$Site->{script}" enctype="multipart/form-data">
		 <input type="hidden" name="table" value="$table">
		 <input type="hidden" name="id" value="$id_value">
		 <input type="hidden" name="action" value="update">|;

	if ($vars->{autoblog}) {
		$form_text .=  qq|
		 <input type="hidden" name="newautoblog" value="$vars->{autoblog}">|;
	}

						# Preserve AntiSpam Codes
	my $spam_code = $vars->{code};
	if ($spam_code) { $form_text .=  qq|
		 <input type="hidden" name="code" value="$vars->{code}">
		 <input type="hidden" name="post_thread" value="$record->{post_thread}">|; }
	
		 
		 				# Add hidden values from $data
	while (my($dx,$dy) = each %$data) {
		$form_text .=  qq|		 
		<input type="hidden" name="$dx" value="$dy">
		|
 	}
		 
	 
		 
	if ($autoblog) {
		$form_text .= qq|<table border=0 cellpadding=4 cellspacing=0><tr><td>
			<i>Full text of the link you are commenting on is located below the form</i></td></tr></table>|;
	}
	$form_text .= qq|	 
		 <table border=0 cellpadding=2 cellspacing=0 style="color:#888888;">\n|;
	
						# Get the full list of tables, for crosslinks
						
	my @db_tables_a = $dbh->tables(); my @db_tables;			
	foreach my $dta (@db_tables_a) { $dta =~ s/`//g; push @db_tables_b,$dta; }			#`
	foreach my $dtb (@db_tables_b) { 
		if ($dtb =~ /\./) { 		# Strip db name
			my ($bd,$dt) = split /\./,$dtb;
			$dtb = $dt;
		}
		push @db_tables,$dtb; my $dtba = $dtb."id"; push @db_tables,$dtba; 
	}
	
	
#	foreach my $dt (@db_tables) { print "$dt<br>";  }	
	
						# Init Rows (for short text inputs)
	$Site->{newrow} = 0;

	my @columns = (); 
	my $coltypes = ();			 
	my $showstmt = "SHOW COLUMNS FROM $table";
	my $sth = $dbh -> prepare($showstmt);
	$sth -> execute();
	while (my $showref = $sth -> fetchrow_hashref()) { 			
		push @columns,$showref->{Field}; 
		$coltypes->{$showref->{Field}} = $showref->{Type};
	}

	# Remove spacings
	$record->{$fields->{description}} =~ s/<br\/>/\n/g;
	$record->{$fields->{content}} =~ s/<br\/>/\n/g;

	$Site->{newrow} eq "1";
	foreach my $sc (@{$showcols->{$table}}) {
		my $col = $table."_".$sc;


		# Test for canonical vocabulary
		my $opts = &db_get_record($dbh,"optlist",{optlist_title=>$col});
		if ($opts->{optlist_data} || $opts->{optlist_list}) { 
			$form_text .=  &form_optlist_select($dbh,$table,$col,$record->{$col},$opts);  
			next; 
		}


						# Find the Size, if specified
		my $size;
		if ($coltypes->{$col} =~ /\((.*?)\)/) {
			$size = $1;
		}
		
		

						# Isolate Field Type
		my $fieldstem = $col; my $tabstem = $table."_";
		$fieldstem =~ s/$tabstem//;
		
						# Print Input Fields
		if ((grep {$_ eq $fieldstem} @db_tables) && ($fieldstem ne "url") && ($fieldstem ne "link") && ($fieldstem ne "field")) {			
			$form_text .= &form_keylist($table,$id_value,$sc);
			# $form_text .=  &form_keyinput($col,$record->{$col},2);	
		}  elsif ($fieldstem eq "twitter") {
			$form_text .=  &form_twitter($record,2);		
		} elsif (($table eq "media") && ($fieldstem eq "link")) {
			$form_text .=  &form_keyinput($col,$record->{$col},2);		
		} elsif ( $table eq "link" && $col =~ /_category/ ) {
			$form_text .=  &form_textinput($record,$col,4);
		} elsif ( $col =~ /_type|_catdetails|_active|_status|_category/ ) {
			$form_text .=  &form_option_select($dbh,$col,$record->{$col});
		} elsif ( $col =~ /_content/) {
			$form_text .=  &form_textarea($col,80,30,$record->{$col});
		} elsif ($col =~ /_file/) {
			$form_text .=  &form_file_select($dbh,$table,$id_number);
		} elsif ($col =~ /_date/) {
			$form_text .=  &form_date_select($col,$record->{$col});
		} elsif ($col =~ /_start|_finish/) {
			$form_text .=  &form_date_time_select($col,$record->{$col},$table,$record);
		} elsif ($col =~ /_timezone/) {
			$form_text .=  &form_timezone($col,$record->{$col},$table,$record);			
		} elsif ( $coltypes->{$col} =~ /int/ ||
		     ($coltypes->{$col} =~ /varchar/ && $size <60)) {	
			$form_text .=  &form_textinput($record,$col);
		} elsif ( $col =~ /_current|_updated|_refresh|_textsize|_tag|_srefresh|_supdated/) {	
			$form_text .=  &form_textinput($record,$col);
		} elsif ( $col =~ /_creatorname|_source/ ) {
 			$form_text .=  &form_textinput($record,$col,4);
		} elsif ( $coltypes->{$col} =~ /varchar/ ) {
 			$form_text .=  &form_textinput($record,$col,4);
		} elsif ( $coltypes->{$col} eq "text") {	
			$form_text .=  &form_textarea($col,80,15,$record->{$col});
		} elsif ( $coltypes->{$col} eq "longtext") {
			$form_text .=  &form_textarea($col,80,30,$record->{$col});
		} elsif ($sc eq "submit") {
			$form_text .=  &form_submit();
		} else {
			$form_text .=  &form_textinput($record,$col,3);		
		}

	}


	$form_text .=  "</table>\n";


	if ($autoblog) {
		my $link = db_get_record($dbh,"link",{link_id=>$autoblog});
		$form_text .= qq|	 
		 	<br><table border=0 cellpadding=10 cellspacing=0 width="600">
			<tr><td>
			<i>Link Text:</i><br/><br/>
			$link->{link_description} <hr>
			$link->{link_content}
			<br>
			<a href="$link->{link_link}" target="_new">Open link in a new window</a>
			</td></tr></table><br>\n|;
	
	}
	
	$form_text .= &form_page_options($table,$id_number,$record);
        $form_text .= &form_badge_options($table,$id_number,$record);
	$form_text .= "</form>\n";
	$form_text = qq|<div id="form_text">|.$form_text.qq|</div>|;

	return $form_text;
}

# -------  Form Submit -----------------------------------------------------
#
# Creates Form Submit Button

sub form_submit {


# Kludge here on twitter publish checkbox, come back and fix later
# 	<input type="radio" name="publish_post" value="twitter"> Publish to Twitter  
#	<input type="radio" name="publish_post" value="rss"> Publish RSS  
	
	if ($Person->{person_status} eq "admin") {
	return qq|<tr><td colspan="4">
	<input type="submit" value="Update Record" class="button"></td></tr>|;
	} else {

	return qq|<tr><td colspan="4">
  
	<input type="submit" value="Update Record" class="button"></td></tr>|;
	}

}

# -------  File Select -----------------------------------------------------
#
# Creates File Select Form Field


sub form_file_select {

	my ($dbh,$table,$id,$name) = @_;
	my $admin = 1 if ($Person->{person_status} eq "admin");	

	# Images

	my $content = qq|<tr><td valign="top">Image(s)</td><td colspan="3">|;	
	$content .= &form_graph_list($table,$id,"file","Illustration");
	$content .= qq| </td></tr>|;	
		
	# Enclosures
	
	$content .= qq|<tr><td valign="top">File(s)</td><td colspan="3">|;	
	$content .= &form_graph_list($table,$id,"file","Enclosure");
	$content .= qq| </td></tr><tr><td colspan="4">|;			
	
	# <input type="file" name="file_name" />
	if ($admin) {
		my $lunch = qq|
				<table>
		<td colspan="4">Upload an image or a file...</td></tr>
		<tr><td colspan=2>By URL: <input type="text" name="file_url" size="40"><br />
		<input type="file" accept="image/*;capture=camera" name="file_name" />
		Or Select: 
		</td><td colspan="2" style="padding-left:20px;">
		<input type="radio" name="file_rel" value="icon"> Icon <br/>
		<input type="radio" name="file_rel" value="display"> Display <br />
		Width: <input type="text" name="file_width" style="width:5em;"> 
		Align: <select name="file_align"  style="width:5em;">		
		<option value="left">left</option>
		<option value="right">right</option>
		<option value="top">top</option>
		<option value="bottom">bottom</option>
		</select></td></tr>
		<input type="hidden" name="$countname" value="$value"></td></tr>
		</table>
		|;
		
		$content .= &make_lunchbox($lunch,"image","Add an image or a file...");	

	}

	
	$content .= qq| </td></tr>|;	
	

	
	return $content;
	
	
	# Old
	
	my @files = &find_graph_of($table,$id,"file");	
	
	foreach my $file (@files) {
		my $name = &get_key_name($key,$connection);
		my $alink = "$Site->{st_cgi}admin.cgi?".lc($key)."=".$connection;
		my $blink = "$Site->{st_cgi}admin.cgi?table=$table&id=$id&remove=".lc($key)."/".$connection;
		my $editlink; my $removelink;
		if ($admin) {
			$editlink = qq|[<a href="$alink&action=edit">Edit</a>]|;
			$removelink = qq|[<a href="$blink&action=remove_key">Remove</a>]|;	
		}
		$content .= qq|<a href="$Site->{st_url}$key/$connection">$name</a> $editlink $removelink<br/>|;
	}
	
	my $urlname = $name;
	$urlname =~ s/file$/url/;
	my $countname = $name;
	$countname =~ s/file$/count/;
	unless ($value) { $value=0; } 
	my $table = $vars->{table};
	$value++;

	# Create Filelist
	my $stmt = qq|SELECT * FROM file where file_post='$id_number'|;
	my $file_list = "";
	my $sth = $dbh->prepare($stmt);
	$sth->execute();
	while (my $file = $sth -> fetchrow_hashref()) {
		$file_list .= qq|$file->{file_type}: <a href="$Site->{st_url}$file->{file_dirname}">$file->{file_title}</a>
			[<a href="?file=$file->{file_id}&action=edit">Edit</a>]<br/>|;
	}



		

	
	# Add More

	
	
	

	return $content;
	
	return qq |
		<tr><td colspan="4">Associated Files: <br/>
		<div id="clasp_$name" class="clasp"><a href="javascript:lunchboxOpen('$name');">Add more...</a></div>
		<div id="lunch_$name" class="lunchbox">

		$file_list </td></tr>

		<td colspan="4">Add an Image...</td></tr>
		<tr><td colspan=2>By URL: <input type="text" name="file_url" size="40"><br />
		Or Select: <input type="file" name="file_name" />
		</td><td colspan="2">
		<input type="radio" name="reltype" value="icon"> Icon <br/>
		<input type="radio" name="reltype" value="display"> Display <br />
		Width: <input type="text" name="file_width" size="5"> 
		Align: <select name="file_align" width="5">		
		<option value="left">left</option>
		<option value="right">right</option>
		<option value="top">top</option>
		<option value="bottom">bottom</option>
		</select></td></tr>
		<input type="hidden" name="$countname" value="$value"></td></tr>
		
		<td colspan="4">Add a File...</td></tr>
		<tr><td colspan=2>By URL: <input type="text" name="file_url" size="40"><br />
		Or Select: <input type="file" name="file_name" />
		</td><td colspan="2">
		<input type="radio" name="reltype" value="icon"> Audio <br/>
		<input type="radio" name="reltype" value="display"> Slides <br />
		<input type="radio" name="reltype" value="display"> Video <br />		
		<input type="hidden" name="$countname" value="$value">
		</td></tr>
		</div>
		|;

}


sub form_graph_list {
	
	my ($table,$id,$key,$type) = @_;
	my $output = ""; 
	my $admin = 1 if ($Person->{person_status} eq "admin");
	
	my @keylist = &find_graph_of($table,$id,$key,$type);
	
	foreach my $keyid (@keylist) {
		next unless ($keyid > 0);
		my $keyname = &get_key_name($key,$keyid);	
		if ($admin) {
			$editlink = qq|[<a href="$Site->{st_cgi}admin.cgi?$key=$keyid&action=edit">Edit</a>]|;
			$removelink = qq|[<a href="$Site->{st_cgi}admin.cgi?table=$table&id=$id&remove=$key/$keyid&action=remove_key">Remove</a>]|;	
		}		
		$output .= qq|<a href="$Site->{st_url}$key/$keyid">$keyname</a> $editlink $removelink<br/>|;
		#$output .= $keyid." ".$keyname."<p>";
	}
	

	
	

			
	unless ($output) { $output .= "None"; }
	return $output;
	
}

# -------  Date Select -----------------------------------------------------
#
# Creates Date Select Form Field


sub form_date_select {


	my ($name,$value) = @_;
	my $title = $name;
	$title =~ s/(.*?)_(.*?)/$2/;
	$title = ucfirst($title);

	unless ($value) { # Default to today's date
		$value = &cal_date(time);
	}
	
	return qq |
		<tr><td>$title</td><td colspan="3">
<input class="span2" name="$name" value="$value" data-date-format="yyyy/mm/dd" id="dp|.$name.qq|" type="text" style="height:1.8em;">
		<script>
			\$('#dp|.$name.qq|').datepicker();
			\$('#dp|.$name.qq|').datepicker( "option", "dateFormat", "yy/mm/dd" );
			\$('#dp|.$name.qq|').datepicker( "setDate", "$value");
</script>

		</td>
		</tr>
		|;
		
}


# -------  Date-Time Select -----------------------------------------------------
#
# Creates Date-Time Select Form Field


sub form_date_time_select {

	my ($name,$value,$table,$record) = @_;
	my $title = $name;
	$title =~ s/(.*?)_(.*?)/$2/;
	$title = ucfirst($title);

	# Time Zone - default to site defined time zone
	my $tzkey = $table."_timezone";
	unless ($record->{$tzkey}) { $record->{$tzkey} = $Site->{st_timezone};	}
	
	# Date-time - default to today
	if ($value) { $value = &cal_date($value,"min",$record->{$tzkey}); } else { $value = &cal_date(time,"min",$record->{$tzkey}); }
	

	
	
	
	return qq |
		<tr><td valign="top">$title</td><td colspan="3">
		<input class="span4" name="$name" value="$value" id="dp|.$name.qq|" type="text">
		<script>
        \$('#dp|.$name.qq|').datetimepicker({
            controlType: 'select',	
            dateFormat: "yy/mm/dd",
            timeFormat: "HH:mm",
            stepMinute: 5
        });		
		
		</script>




		</td>
		</tr>
		|;


# 
}


sub form_timezone {
	
	my ($name,$value,$table,$record) = @_;	
	
	
	# Time Zone - default to site defined time zone
	my $tzkey = $table."_timezone";
	unless ($record->{$tzkey}) { $record->{$tzkey} = $Site->{st_timezone};	}
	
	my @dt = DateTime::TimeZone->all_names;
	my $dtstr = qq|<select name="|.$table.qq|_timezone" style="height:18pt;">\n|; foreach my $dts (@dt) {
		my $sel; if ($dts eq $record->{$tzkey}) { $sel = " selected"; } else { $sel = ""; }
		$dtstr .= qq|<option value="$dts" $sel>$dts</option>\n|; 
	}
	
	$dtstr .= "</select>\n";	

	
	return qq|<tr><td valign="top">Time Zone</td><td colspan="3">$dtstr</td></tr>|;
			
	
}

# -------  Date-Time Parse -----------------------------------------------------

sub date_time_parse {
	my ($value) = @_;
	
	$value =~ /(.*?)(\/|-)(.*?)(\/|-)(.*?) (.*?):(.*?)/;
	my $year = $1; my $month = $3; my $day = $5; my $hour = $6, my $min = $7;
	
	return ($year,$month,$day,$hour,$min);
	

	
}

# -------  Date-Time Find -----------------------------------------------------

sub date_time_find {
	
	my ($time) = @_;
	unless ($time) { $time = time; }
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
	if ($sec < 10) { $sec = "0".$sec; }
	if ($min < 10) { $min = "0".$min; }	
	if ($hour < 10) { $hour = "0".$hour; } 
	if ($mday < 10) { $mday = "0".$mday; }
	$mon++; if ($mon < 10) { $mon = "0".$mon; }
	if ($year < 2000) { $year += 1900; }
	return ($sec,$min,$hour,$mday,$mon,$year);
}


# -------  Optlist Select ----------------------------------------------------

sub form_optlist_select {
	
	my ($dbh,$table,$name,$opted,$record) = @_;	
	my $options = "";


		my @opts = split ";",$record->{optlist_data};
		foreach my $opt (@opts) {
			my ($oname,$ovalue) = split ",",$opt;
			next unless ($oname && $ovalue);
			my $selected; if ($opted eq $ovalue) { $selected = " selected"; } else { $selected=""; }
			$options .= qq|    <option value="$ovalue"$selected>$oname</option>\n|;				
		}
	
		if ($options) { $options = qq|<select name="$name" style="width:12em;">$options</select>|; }
		else { $options = "$record $record->{optlist_data} Options for $name not found"; }

	
	my $open="";my$close="";
	if ($Site->{newrow} eq "1") {
		$Site->{newrow} = 0;
		$close = "</tr>";
	} else {
		$Site->{newrow} = 1;
		$open = "<tr>";
	}
	
	my $cname=$name;$cname =~ s/_/ /g; $cname =~ s/(\w+)/\u\L$1/g; 		
	return qq|$open<td>$cname</td><td>$options</td>$close|;	
}

# -------  Option Select -----------------------------------------------------
#
# Creates Option Select Form Field

sub form_option_select {

	my ($dbh,$name,$value) = @_;


	my ($table,$title) = split /_/,$name;
	$title = ucfirst($title);
	

	my $options = "TABLE $table <p>";
	if ($table eq "graph") {
		$options =  qq|<input type="text" name="$name" size="10" value="$value">|;
	} else {
	

		my $stmt = "SELECT optlist_list FROM optlist WHERE optlist_title='$name'";
		my $ary_ref = $dbh->selectcol_arrayref($stmt);
		my $list = $ary_ref->[0]; 

		my $astmt = "SELECT optlist_default FROM optlist WHERE optlist_title='$name'";
		my $ay_ref = $dbh->selectcol_arrayref($astmt);
		my $deft = $ay_ref->[0];

		my @List = split /;/,$list;

		foreach my $o (@List) {
			my $sel = "";
			my ($tit,$val) = split /,/,$o;
			$tit =~ s/^\s+//; $tit =~ s/\s+$//;			# Remove leading and trailing spaces
			$val =~ s/^\s+//; $val =~ s/\s+$//;			# Allows for nice formatting of data
			unless ($val) { $val = $tit; }

			if ($value) {
				if ($val eq $value) { $sel = " selected"; }
			} else {
				if ($val eq $deft) { $sel = " selected"; }
			}
			
			$options .= qq|<option value="$val"$sel>$tit</option>\n|;
		}
		if ($options) { $options = qq|<select name="$name">$options</select>|; }
		else { $options = "$stmt $ary_ref Options for $name not found"; }
	}
	
	return qq|<tr><td>$title</td><td colspan="3">$options</td></tr>|;

}

# -------  Text Input -----------------------------------------------------
#
# Creates Text Input Form Field

sub form_textinput {
	my ($record,$col,$colspan,$advice) = @_;

	my ($table,$title) = split /_/,$col;
	$title = ucfirst($title);
	my $id = $record->{$table."_id"};
	my $value = $record->{$col};
	$value ||= $advice;						# Allows advice to be put in the form
									# prior to input
									# (there's a way to make this light and disappear, 
									# but I don't know what that is yet)

	$value =~ s/"/&quot;/sig;		#"


	my $open = ""; my $size=""; my $stylesize; my $close = "";

	if ($colspan) {
		$open = "<tr>\n";
		$size = 60; $stylesize="500px";
		$colspan = qq| colspan="3"|;
		$Site->{newrow} = 0;
		$close = "</tr>";
	} else {
		$size = 20; $stylesize="200px";
		if ($Site->{newrow} eq "1") {
			$Site->{newrow} = 0;
			$close = "</tr>";
		} else {
			$Site->{newrow} = 1;
			$open = "<tr>";
		}
	}

	my $lgoto = ""; 
	
	if ($col =~ /_post/) {

		$lgoto = qq|[<a href="$Site->{script}?action=edit&post=$value">Edit Post</a>]|;
	}

	if ($col =~ /_icon/) {
		$stylesize = "30em";
		$icopref = $Site->{st_icon} || "file/icon/";		
		$lgoto = qq|[<a href="$Site->{script}?action=make_icon&db=$table&id=$id">Make Icon</a>]|;
	}

	my $texttype; if ($col =~ /password/) { $texttype = "password"; } else { $texttype = "text"; }
	return qq |
		$open
		<td valign="middle">$title</td>
		<td valign="middle"$colspan>
		$icopref<input type="$texttype" name="$col" value="$value" size="$size" style="width:|.$stylesize.qq|;height:1.8em;"> $lgoto
		</td>
		$close
		|;



}



# -------  Key List --------------------------------------------

sub form_keylist {
	
	my ($table,$id,$key,$more) = @_;


	my $suggform = ""; my $suggstr;	
	$key =~ s/id$//i;
	my $admin = 1 if ($Person->{person_status} eq "admin");
	
	# Temporary - what I really should do here is count the number of items in the table and do a cut-off
	if ($key eq "author" || $key eq "feed") { $more = 1; }

	# Create Title
	my $content = qq|<tr><td valign="top">|.ucfirst($key).qq|(s)</td><td colspan="3">|;
	
	# Get Existing List
	my $sugglist = &form_graph_list($table,$id,$key);
	

	# Add More
	
		# Create List of Alternatives from DB
		my $arr_ref = &get_key_name_array($key);
		foreach my $ar (@$arr_ref) { 
			if ($suggstr) { $suggstr .= ","; }
			$ar =~ s/('|&#39;)/&apos;/g;$ar=~s/(\n|\r)//g;		
			$suggstr .= qq|'$ar'|;
		}
		$suggstr = qq|source: [ $suggstr ]|;

		# Place into Input script
		$suggform = qq|<input name="keyname_$key" value="" id="autocomplete_$key" >
			<script>
			\$( "#autocomplete_$key" ).autocomplete({$suggstr});
			</script>|;

	
	if ($admin && $more) {
		
		if ($sugglist eq "None") {
			$content .= $suggform;
		} else {
		
		
		$content .= qq|$sugglist
	<div id="clasp_$key" class="clasp"><a href="javascript:lunchboxOpen('$key');">Add more...</a></div>
	<div id="lunch_$key" class="lunchbox">
		<div class="well">
			$suggform
			<input type="submit" value="Submit new $key">
		</div>			
	</div>|;
		}
		
	} else {
		
		# Temporary - what I should really do here is put in a popup search window
		$content .= qq|$sugglist<input type="text" name="keyname_$key" size=40"> (Enter title or name)|;
	}	

	$content .= qq| </td></tr>|;	
	

	return $content;
}


# -------  get Key Name --------------------------------------------
#
#   Returns a name for table $key and id $id

sub get_key_name {
	
	my ($key,$id) = @_;
	my $field = get_key_namefield($key);
	my $name = &db_get_single_value($dbh,$key,$field,$id);
	return $name;
		
}

# -------- get key name array ---------------------------------------
#
#   Returns an array of key names or titles
#   Use for form typeahead lookup

sub get_key_name_array {
	
	my ($key) = @_;
	my $field = get_key_namefield($key);
	my $names_ref = &db_get_column($dbh,$key,$field);
	return $names_ref;
		
}

# -------- get key namefield ---------------------------------------

sub get_key_namefield {
	my ($key) = @_; my $field;
	if ($key eq "person" || $key eq "author") { $field = "name"; }
	else { $field = "title"; }
	$field = $key."_".$field;
	return $field;	
	
}

# -------  Key Input -----------------------------------------------------
#
# Creates Key inoput and lookup

sub form_keyinput {
	my ($name,$value) = @_;

	if ($name =~ m/id$/) { $name =~ s/(.*?)id$/$1/; }		# Remove 'id' from end of field name
	my $title = $name;									# This gives us our table name
								

	$title =~ s/(.*?)_(.*?)/$2/;
	$title = ucfirst($title);
	my $editlink; if ($value) { 
		$editlink = qq|[<a href="$Site->{st_cgi}admin.cgi?|.lc($title)."=".$value.qq|&action=edit">Edit</a>]|;
	}

	return qq |
		<tr><td>Key: $title</td><td colspan="3">
		<input type="text" name="$name" value="$value" size="10" style="height:1.8em;"> 
		$editlink
		</td>
		</tr>
		|;

}




# -------  Textarea -----------------------------------------------------
#
# Creates Textarea Form Field

sub form_textarea {
	my ($name,$cols,$rows,$content) = @_;
	my $title = $name;
	$title =~ s/(.*?)_(.*?)/$2/;
	$title = ucfirst($title);
	my $output = "";
	my $noEditor = "";
	if ($name =~ /(template_|_code|view_|_rules|box_)/) { $noEditor = qq|class="mceNoEditor"|; }
	else { $noEditor = qq|class="editme"|; }

	my $rulesinfo; if ($name =~ /rules/) { 
		$rulesinfo = qq| [<a href="http://grsshopper.downes.ca/rules.htm" target="_new">Rules Help</a>]|;
		$rows=5;
	}
	$content =~ s/</&lt;/sig;
	$content =~ s/>/&gt;/sig;

	if ($name =~ /description|rules|code|content/) { 
		$output .= qq|<tr><td colspan="4">$title$rulesinfo<br/>|;
	} else {
		# Hide most textareas unless needed
		$output .= qq|<tr><td>$title</td><td colspan="3">
		<div id="clasp_$name" class="clasp"><a href="javascript:lunchboxOpen('$name');">Open...</a></div></td></tr><tr><td colspan="4">
		<div id="lunch_$name" class="lunchbox">
		|;
	}
		
	# Style width:auto to replace bootstrap default - line 802 in bootstrap.css
	$output .= qq |
		<textarea name="$name" cols="$cols" rows="$rows" style="width:auto;" $noEditor >$content</textarea>
		|;
		
	unless ($name =~ /description|rules/) {  $output .= qq|	</div>|; }	
	$output .= qq|</td></tr>|;
	
	return $output;

}

# -------  Page Options -----------------------------------------------------
#
#

sub form_page_options {

	my ($table,$id_number,$record) = @_;

	
	return unless (&is_viewable("publish","page"));
	return unless ($table eq "page");
	return unless ($Site->{script} =~ /admin/);

	my @auto = qw|Never Weekly Daily Hourly|;
	my @wdays = qw|Sunday Monday Tuesday Wednesday Thursday Friday Saturday|;
	my @mdays = qw|01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31|;
	my @dhour = qw|00 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23|;
	my @dmin = qw|00 05 10 15 20 25 30 35 40 45 50 55|;
	my @noyes = qw|no yes|;
	
	my $archivelink = "";
	if ($record->{page_archive} eq "yes") { 
		my $archivefile = $record->{page_location};
		$archivefile =~ s/\//_/g;
		$archivelink=qq|[<a href="$Site->{st_cgi}archive.cgi?page=$archivefile">View Page Archive</a>]|; 
	}
		
	my $autopubpanel = qq|
		<br/><h3>Publishing Options</h3>
		<div class="adminpanel" style="text-align:left;"><table><tr><td>
		Publish to: $Site->{st_url}<input style="height:1.8em;" type="text" 
		name="page_location" value="$record->{page_location}" />\n
		<br>Archive page? |.&form_opt_multiple("page_archive",$record,\@noyes,1,100,0)." $archivelink".
		qq|<br>Autopublish? |.&form_opt_multiple("page_autopub",$record,\@noyes,1,100,0).
		qq|How often? |.&form_opt_multiple("page_autowhen",$record,\@auto,1,100,0).
		qq|<br>Allow empty (keywords)? |.&form_opt_multiple("page_allow_empty",$record,\@noyes,1,100,0).
		qq|<br>Note that pages are also autopublished and archived when sent as newsletters.\n
		</td></tr></table></div>
	|;
	
	
	my $newsletter_panel = qq|
		<br/><h3>Newsletter Options</h3>
		<div class="adminpanel" style="text-align:left;">
		<table cellpadding="3" border="1" width="90%">
		<tr><td colspan="3">Enable newsletter subscriptions? |.
		&form_opt_multiple("page_sub",$record,\@noyes,1,100,0).
		qq|<br>Auto-send newsletters turned on? |.
		&form_opt_multiple("page_subsend",$record,\@noyes,1,100,0).
		qq|<br>Autosubscribe to this newsletter? |.
		&form_opt_multiple("page_autosub",$record,\@noyes,1,100,0).
		qq|</td></tr>
		<tr><td>Weekdays</td><td>Days of Month</td><td>Time</td></tr>
		<tr><td>|.&form_opt_multiple("page_subwday",$record,\@wdays,5,150,1).qq|</td>
		<td valign="top">|.&form_opt_multiple("page_submday",$record,\@mdays,5,60,1).qq|</td>
		<td valign="top">|.&form_opt_multiple("page_subhour",$record,\@dhour,1,60,0).qq|:|.
		&form_opt_multiple("page_submin",$record,\@dmin,1,60,0).qq|</td></tr>
		<tr><td colspan="3">When should the newsletter be published and sent?
		Select more than one weekday or date as desired</td></tr>				
		</table><p><input value="Update Record" class="button" type="submit"></p></div>
	|;
	my $text = "";
	$text .=  qq|
		<p>[<a href="$Site->{st_cgi}admin.cgi?db=page&action=list">List Pages</a>] 
		[<a href="$Site->{st_cgi}admin.cgi?page=$id_number&force=yes">View Generated Version of Page</a>]
		[<a href="$Site->{st_cgi}admin.cgi?action=publish&page=$id_number&force=yes">Publish Page</a>] 
		[<a href="$Site->{st_url}$record->{page_location}">View Published Page</a>]</p>|.
		$autopubpanel .
		$newsletter_panel .
		qq||;

# &jq_panel("Set this page up as a newsletter?",$newsletter_panel,"330px").

	return $text;

}


# -------  Badge Options -----------------------------------------------------
#
#

sub form_badge_options {

	my ($table,$id_number,$record) = @_;

	
	return unless (&is_viewable("publish","badge"));
	return unless ($table eq "badge");
	return unless ($Site->{script} =~ /admin/);

		
		
	my $autopubpanel = qq|
		<br/><h3>Publishing Options</h3>
		<div class="adminpanel" style="text-align:left;">
		Publish to: $Site->{st_url}<input style="height:1.8em;" type="text" 
		name="badge_location" value="$record->{badge_location}" />\n
                <input value="Update Record" class="button" type="submit">     
		</div>
	|;
	
		
	my $text = "";
	$text .=  qq|
		<p>
		[<a href="$Site->{st_cgi}admin.cgi?action=publish&badge=$id_number&force=yes">Publish Badge</a>] 
		[<a href="$Site->{st_url}$record->{page_location}">View Published Badge</a>]</p>|.
		$autopubpanel .
		qq||;


	return $text;

}






sub form_opt_multiple {
	
	my ($field,$record,$list,$size,$width,$multiple) = @_;
	my @selected = split ",",$record->{$field};
	my $multi = ""; if ($multiple) { $multi = qq| multiple="multiple"|; }
	my $output = qq|<select $multi name="$field" size="$size" width="$width" style="width: |.$width.qq|px">\n|;
	foreach my $litem (@$list) {
		my $sel= ""; if (&index_of($litem,\@selected) > -1) { $sel = " selected"; }
		$output .= qq|<option value="$litem"$sel>$litem</option>\n|;
	}
	$output .= "</select>\n";
	return $output;
}


sub form_twitter {

	my ($record) = @_;
	
	my $return_text = qq|<tr><td>Publish</td><td colspan="3">|;
	
	my @socialmedias = qw(twitter facebook);				# List of supported social media sites
	foreach my $socialmedia (@socialmedias) {
		$return_text .= ucfirst($socialmedia).": ";
	
		if ($record->{post_social_media} =~ /$socialmedia/i) { $return_text .= "Published&nbsp;&nbsp;&nbsp;"; }	
		else { 
			$return_text .= qq|<select name="post_|;
			$return_text .= $socialmedia;
			$return_text .= qq|"><option value="">Later</option>
			<option value="yes">Publish Now</option>
			</select>&nbsp;&nbsp;&nbsp;|;	}		
	}
	

	$return_text .= qq|<input type="submit" value="Publish" class="button"></td></tr>|;
	return $return_text;
	
		
}

sub jq_panel {
	my ($message,$content,$height) = @_;
	$height ||= "280px";
	return qq|<script type="text/javascript"> 
\$(document).ready(function(){
\$(".flip").click(function(){
    \$(".panel").slideToggle("slow");
  });
});
</script>
 
<style type="text/css"> 
div.panel,p.flip
{
margin:0px;
padding:5px;
text-align:center;
background:#e5eecc;
border:solid 1px #c3c3c3;
}
div.panel
{
height: $height;
display:none;
}
</style>
 
<div class="panel">$content</div>
 
<p class="flip">$message</p>
 

	|;
	
	
}

# -------  Thread Options -----------------------------------------------------
#
#

sub form_thread_options {

	my ($table,$id_number,$pagefile) = @_;

	return unless ($table eq "thread");

	my $text = "";
	$text .=  qq|
		<p>[<a href="$Site->{st_cgi}cchat.cgi">Chat Selection Page</a>]<br/>
		[<a href="$Site->{st_cgi}cchat.cgi?chat_thread=$id_number&force=yes">Enter Chat Thread</a>]<br/>|;

	return $text;

}
# ------- Submit Data -----------------------------------------------------
#


sub form_update_submit_data {

	my ($dbh,$query,$table,$id_number,$data) = @_;
	my $vars = $data || $query->Vars;
	
	my $fields = &set_fields($table);

	if ($table eq "post") {
		#$vars->{$fields->{description}} =~ s/\n/<br\/>/g;
		#$vars->{$fields->{content}} =~ s/\n/<br\/>/g;
		if ($Person->{person_status} eq "admin") { $vars->{$fields->{source}} = "admin"; }

	}		
		
		
	if ($id_number eq "new") {	# Create Record, or

		$vars->{$fields->{crdate}} = time;
		$vars->{$fields->{creator}} = $Person->{person_id};
		$id_number = &db_insert($dbh,$query,$table,$vars);
		$vars->{msg} .= "Created new $table ($id_number) <br/>";

		if ($vars->{$table."_thread"}) {										# If it's a comment
			my $ctable; my $cid;									# identify table and id of item being commented upon
			if ($vars->{$table."_thread"} =~ /:/) {	($ctable,$cid) = split /:/,$vars->{$table."_thread"}; }
			else { $ctable = "post"; $cid = $vars->{$table."_thread"}; }					# and increment its comment count
			$rep .= "<br>Incrementing $ctable $cid <br>";
			&db_increment($dbh,$ctable,$cid,$table."_comments","form_update_submit_data");				
		}

	
	

	} else {				# Update Record

		my $where = { $fields->{id} => $id_number};
		$id_number = &db_update($dbh,$table, $vars, $id_number);
		$vars->{msg} .= ucfirst($table)." $id_number successfully updated<br/>";
	}

							# Trap Errors
	unless ($id_number) {
		&error($dbh,$query,"","I attempted to create this record, but failed, sorry.");
		exit;
	}
	
	return $id_number;
}








#-------------------------------------------------------------------------------
#
#           Database Functions 
#
#-------------------------------------------------------------------------------



# -------   Open Database ------------------------------------------------------

sub db_open {

	my ($dsn,$user,$password) = @_;
	
	die "Database dsn note specified in db_open" unless ($dsn);
	die "Database user note specified in db_open" unless ($user);
	
	my $dbh = DBI->connect($dsn, $user, $password)
		or die "Database connect error: $! \n";
	# Uncomment next line to trace DB errors
#	  if ($dbh) { $dbh->trace(1,"/var/www/connect/dberror.txt"); }
	return $dbh;
}

# -------   Get Record -------------------------------------------------------------


sub db_get_record {
	
	my ($dbh,$table,$value_arr) = @_;
	&error($dbh,"","","Database not ready") unless ($dbh);
	if ($diag eq "on") { print "Get Record ($table $value_arr)<br/>\n"; }
	my @value_list; my @value_vals;
	while (my($kx,$ky) = each %$value_arr) { push @value_list,"$kx=?"; push @value_vals,$ky; }
	my $value_str = join " AND ",@value_list;
	unless ($value_vals[0]) { warn "No value input to db_get_record"; return; }
	my $stmt = "SELECT * FROM $table WHERE $value_str LIMIT 1";	
	my $sth = $dbh -> prepare($stmt);
	$sth -> execute(@value_vals);
	my $ref = $sth -> fetchrow_hashref();
	$sth->finish(  );
	return $ref;
}

# -------   Get Record List ---------------------------------------------------------
#
# Returns a list of values from specified table
# Default value is id number, but can optionally define an alternative field
# (this is useful for getting a list of records from the graph)
# updated 12 May 2013

sub db_get_record_list {
	
	my ($dbh,$table,$value_arr,$field) = @_;
	&error($dbh,"","","Database not ready") unless ($dbh);
	if ($diag eq "on") { print "Get Record List ($table $value_arr)<br/>\n"; }

	my @value_list; my @value_vals;
	while (my($kx,$ky) = each %$value_arr) { push @value_list,"$kx=?"; push @value_vals,$ky; }
	my $value_str = join " AND ",@value_list;
	&error($dbh,"","","Error forming request in db_get_record_list()") unless ($value_str);

	my $idfield = $table ."_id";
	$field ||= $idfield;
	my $stmt = "SELECT $field FROM $table WHERE $value_str";	

	my $sth = $dbh -> prepare($stmt);
	$sth -> execute(@value_vals);

	
	
	my @record_list;
	while (my $hash_ref = $sth->fetchrow_hashref) {
		push @record_list,$hash_ref->{$field}; 
	}	
	$sth->finish(  );
	
	return @record_list;
}


#
# -------   Get Text --------------------------------------------------------
#
#  Specialized function to get the content only, used for making views
#  Eventually I'mm combine all these three into one function

sub db_get_text {
	
	my ($dbh,$table,$title) = @_;
	
	
	my $fname = "db_get_text";								# Error Check
	unless ($title) { &error($dbh,$query,"",&printlang("Required in","title",$fname)); }
	unless ($table) { &error($dbh,$query,"",&printlang("Required in","table",$fname)); }	
	
	my $viewcache = $table.$title;									# Never get the same thing from the db twice
	if (defined $cache->{$viewcache}) { return $cache->{$viewcache}; }
			
	my $stmt = "SELECT ".$table."_text FROM $table WHERE ".$table."_title = '$title'";	# Get Data from DB		
	my $ary_ref = $dbh->selectcol_arrayref($stmt) or &error($dbh,$query,"",&printlang("Cannot execute SQL",$fname,$sth->errstr(),$stmt));
	my $templ = $ary_ref->[0];									# Fail silently
	
	$cache->{$viewcache} = $templ;									# Save in cache and return
	

	return $templ;	
	
}




#
# -------   Get Content --------------------------------------------------------
#
#  Specialized function to get the content only, used for making boxes on the fly

sub db_get_content {
	
	my ($dbh,$table,$title) = @_;
	
	my $fname = "db_get_content";								# Error Check
	unless ($title) { &error($dbh,$query,"",&printlang("Required in","title",$fname)); }
	unless ($table) { &error($dbh,$query,"",&printlang("Required in","table",$fname)); }	
	
	my $viewcache = $table.$title;									# Never get the same thing from the db twice
	if (defined $cache->{$viewcache}) { return $cache->{$viewcache}; }
			
	my $stmt = "SELECT ".$table."_content FROM $table WHERE ".$table."_title = '$title'";	# Get Data from DB		
	my $ary_ref = $dbh->selectcol_arrayref($stmt) or &error($dbh,$query,"",&printlang("Cannot execute SQL",$fname,$sth->errstr(),$stmt));
	my $templ = $ary_ref->[0];									# Fail silently
	
	$cache->{$viewcache} = $templ;									# Save in cache and return
	return $templ;	
	
}

# -------   Get Template -------------------------------------------------------- 

sub db_get_template {

	my ($dbh,$title,$page_title) = @_; 


	if ($title =~ /'/) { &error($dbh,"","","Cannot put apostraphe in template title"); }  # '
	&error($dbh,"","","Database not initialized in get_single_value") unless ($dbh);
	return unless ($title);							# Just pass by blank template requests


	my $stmt = qq|SELECT template_description FROM template WHERE template_title='$title' LIMIT 1|; 


	my $ary_ref = $dbh->selectcol_arrayref($stmt);
	my $ret = $ary_ref->[0];


	return $ret;

}

# -------  Get Template ---------------------------------------------------------
#
#	Get a template from the database, format it, and return the formatted text
#

sub get_template {
 
	my ($dbh,$query,$template_title,$title) = @_;
 	if ($diag>9) { print "Get Template <br>"; }
	
														# Get Template From DB
					
	return unless ($template_title);			                   		#     - Can print 'blank' remplate (ie., nothing)
	my $template_record = &printlang($template_title) || $template_title;		#     - Try to find a translated title of template
	my $template = &db_get_description($dbh,"template",$template_record) ||		#     - Get the template text from the database
		&printlang("Template file $template_record not found",$ermsg);		# 		- or report error


														# Format the template
	&make_boxes($dbh,\$template);									# 	- Make boxes		
	&make_counter($dbh,\$template);								# 	- Make counter	 
	
	&make_keywords($dbh,$query,\$template);							# 	- Make Keywords
	
	&autodates(\$template);										# 	- Autodates

														# More Formatting

	$template =~ s/&#39;/'/g;									# 	- Makes scripts work
	&make_site_info(\$template);									#	- Template and Site Info
	
														# Write Page Title
	$template =~ s/\Q[*page_title*]\E/$title/g;
	$template =~ s/\Q<page_title>\E/$title/g;	

	if ($diag>9) { print "/ Get Template <br>"; }							
	return $template;


}

#
# -------   Get Description --------------------------------------------------------
#
#  Specialized function to get the description only, used for get_template()

sub db_get_description {
	
	my ($dbh,$table,$title) = @_;
	
	my $fname = "db_get_description";								# Error Check
	unless ($title) { &error($dbh,$query,"",&printlang("Required in","title",$fname)); }
	unless ($table) { &error($dbh,$query,"",&printlang("Required in","table",$fname)); }	
	
	my $viewcache = $table.$title;									# Never get the same thing from the db twice
	if (defined $cache->{$viewcache}) { return $cache->{$viewcache}; }
			
	my $stmt = "SELECT ".$table."_description FROM $table WHERE ".$table."_title = '$title'";	# Get Data from DB		
	my $ary_ref = $dbh->selectcol_arrayref($stmt) or &error($dbh,$query,"",&printlang("Cannot execute SQL",$fname,$sth->errstr(),$stmt));
	my $templ = $ary_ref->[0];									# Fail silently
	
	$cache->{$viewcache} = $templ;									# Save in cache and return
	return $templ;	
	
}


# -------   Get Column --------------------------------------------------------

sub db_get_column {
	
	my ($dbh,$table,$field) = @_;
	&error($dbh,"","","Database not ready") unless ($dbh);
	if ($diag eq "on") { print "Get Column ($table $value_arr)<br/>\n"; }
	my $stmt = qq|SELECT $field FROM $table|;
	my $names_ref = $dbh->selectcol_arrayref($stmt);
	return $names_ref;
}

# -------   Get Record Cache --------------------------------------------------------

# Cache is a pre-assembled version of complex records all ready for display
# 
# Cache is either 
#       *expired*   if time-$Site->{st_cache} > cache_update
#       or *active*
#
# Chack check returns either the record cache, if active, or '0' if expired


sub db_cache_check {
	
	my ($dbh,$table,$record,$format) = @_;
	
	return 0 if ($format =~ /_edit/i);			# never cache edit screen

	return 0 if ($vars->{force} eq "yes");			# command line force
	
	$format ||= "html";					# format defaults to html
	return unless ($table && $record);			# must specify table and record
	
	my $cache = &db_cache_get($dbh,$table,$record,$format);
	

	my $expired = time+$Site->{pg_update};
	if ($cache->{cache_text} && ( $expired > $cache->{cache_update} )) { 
		return $cache->{cache_text}; 
	}
	return 0;

	
}



# -------   Get Record Cache --------------------------------------------------------

# Cache is a pre-assembled version of complex records all ready for display

sub db_cache_get {

	my ($dbh,$table,$record,$format) = @_;
	
	return if ($format =~ /_edit/i);			# never cache edit screen
	$format ||= "html";					# format defaults to html
	return unless ($table && $record);			# must specify table and record


	my $stmt = "SELECT * FROM cache WHERE cache_table=? AND cache_record=? AND cache_format=? LIMIT 1";
	my $sth = $dbh -> prepare($stmt);
	$sth -> execute($table,$record,$format);
	
	my $ref = $sth -> fetchrow_hashref();
	$sth->finish(  );
	if ($ref->{cache_text}) { return $ref; } else { return 0; }
}

# -------   Save Record Cache --------------------------------------------------------

sub db_cache_save {
	
	my ($dbh,$table,$record,$format,$text) = @_;
	push @{$Site->{cache}},"$table:$record:$format:$text";

}

# -------   Save Record Cache --------------------------------------------------------

# Cache is a pre-assembled version of complex records all ready for display
# Cache items gathered during processing and stored in $Site->{cache}
# Cache is written at the end of page processing, after all page output is complete

sub db_cache_write {

	my ($dbh) = @_;
	
	foreach my $cache (@{$Site->{cache}}) {
		
		my @cachearr = split /:/,$cache;
		my $table = shift @cachearr;
		my $record = shift @cachearr;
		my $format = shift @cachearr;
		my $text = join ":",@cachearr;		

		next if ($format =~ /_edit/i);			# never cache edit screen
		$format ||= "html";					# format defaults to html
		die "table and record not specified for cache save" unless ($table && $record);			# must specify table and record	
	
		my $cache_update = time;				# record time of current update
								# used in db_cache_check()
		
		&db_cache_remove($dbh,$table,$record,$format);		# remove previous entry		
	
									
								# insert new entry
		&db_insert($dbh,$query,"cache",
			{	cache_table => $table,
				cache_record => $record,
				cache_format => $format,
				cache_text => $text,
				cache_update => $cache_update	});
	}
	 
}

# -------   Remove Record Cache --------------------------------------------------------

# Short and simple, remove cached records, nothing permanent is touched

sub db_cache_remove {
	
	
	my ($dbh,$table,$record,$format) = @_;
	return unless ($table);		
	
	my $where = "cache_table = '$table'";
	if ($record) { $where .= " AND cache_record = '$record'"; }
	if ($format) { $where .= " AND cache_format = '$format'"; }	
	
	my $sql = "DELETE from cache WHERE $where";

	my $sth = $dbh->prepare($sql);
    	$sth->execute();
		
}


# -------   Get Single Value-------------------------------------------------------- 

sub db_get_single_value {

my ($dbh,$table,$field,$id) = @_; 

&error($dbh,"","","Database not initialized in get_single_value") unless ($dbh);
&error($dbh,"","","Table not initialized in get_single_value") unless ($table);
&error($dbh,"","","Field not initialized in get_single_value") unless ($field);
#&error($dbh,"","","ID number not initialized in get_single_value") unless ($id);
return unless ($id);

my $idfield = $table."_id";								# define id field name
my $t = $table."_";unless ($field =~ /$t/) { $field = $t.$field; }	# Normalize field field name

my $stmt = qq|SELECT $field FROM $table WHERE $idfield='$id' LIMIT 1|; 	# Perform SQL
my $ary_ref = $dbh->selectcol_arrayref($stmt);
my $ret = $ary_ref->[0];

return $ret;

}



# -------   Delete -------------------------------------------------------------

sub db_delete {

	my $dbh = shift || die "Database handler not initiated";
	my $table = shift || die "Table not specified on delete";
	my $field = shift || die "Field not specified on delete";
	my $id = shift || die "No data provided on delete $table, $field)";
	die "Invalid input record $id on delete" unless (($id+0) > 0);	# Prevents accidental mass deletes
	my $sql = "DELETE FROM $table WHERE $field = '".$id."'";

	my $sth = $dbh->prepare($sql);
    	$sth->execute();
}

# -------   Locate -------------------------------------------------------------

# Find the ID number given input values

# Used by new_user()

sub db_locate {

	my ($dbh,$table,$vals) = @_;
						# Verify Input Data

	&error($dbh,"","","db_locate(): Cannot locate with no values") unless ($vals);

						# Prepare SQL Statement
	my $stmt = "SELECT ".$table.
		"_id from $table WHERE ";
	my $wherestr = ""; my @whvals;
	while (my($vx,$vy) = each %$vals) {
		if ($wherestr) { $wherestr .= " AND "; }
		$wherestr .= "$vx = ?";
		push @whvals,$vy;
	}
	$stmt .= $wherestr . " LIMIT 1";
						
	my $sth = $dbh->prepare($stmt);		# Execute SQL Statement

	$sth->execute(@whvals)
		or die "Can't execute SQL statement in db_locate $stmt : ", $sth->errstr(), "\n";
    
  	my $hash_ref = $sth->fetchrow_hashref;
	$sth->finish(  );
	
	return $hash_ref->{$table."_id"};

}

# -------   Locate Multiple -------------------------------------------------------------

# Find an array of ID numbers given input values

# Used by new_user()

sub db_locate_multiple {

	my ($dbh,$table,$vals) = @_;
						# Verify Input Data

	&error($dbh,"","","db_locate(): Cannot locate with no values") unless ($vals);

						# Prepare SQL Statement
	my $stmt = "SELECT ".$table.
		"_id from $table WHERE ";
	my $wherestr = ""; my @whvals;
	while (my($vx,$vy) = each %$vals) {
		if ($wherestr) { $wherestr .= "AND "; }
		$wherestr .= "$vx = ?";
		push @whvals,$vy;
	}
	$stmt .= $wherestr;
					
	my $ary_ref = $dbh->selectcol_arrayref($stmt,{},@whvals);	
	return $ary_ref;

}

# -------   Insert --------------------------------------------------------

# Adapted from SQL::Abstract by Nathan Wiger

sub db_insert {		# Inserts record into table from hash

						# Verify Input Data

	my $dbh = shift || &error($dbh,"","","Database handler not initiated");
	my $query = shift;
	my $table = shift || &error($dbh,"","","Table not specified on insert");
	my $input = shift || &error($dbh,"","","No data provided on insert");

	
    	my $vars = ();
    	if (ref $query eq "CGI") { $vars = $query->Vars; }

	
	my $dtype = ref $input;
	&error($dbh,"","","Unsupported data type specified to insert (data was $dtype)") 
		unless (ref $input eq 'HASH' || ref $input eq 'gRSShopper::Record' || ref $input eq 'gRSShopper::Person' || ref $input eq 'gRSShopper::File');
	my $data= &db_prepare_input($dbh,$table,$input);
	
						
	my $sql   = "INSERT INTO $table ";	# Prepare SQL Statement

	my(@sqlf, @sqlv, @sqlq) = ();

	for my $k (sort keys %$data) {
		push @sqlf, $k;
		push @sqlq, '?';
		push @sqlv, $data->{$k};
	}
	$sql .= '(' . join(', ', @sqlf) .') VALUES ('. join(', ', @sqlq) .')';

						
	my $sth = $dbh->prepare($sql);		# Execute SQL Statement
	
	if ($diag eq "on") { 
		print "Content-type: text/html\n\n";
		print "$sql <br/>\n @sqlv <br/>\n";
	}

    	$sth->execute(@sqlv);
	
	if ($sth->errstr) { $vars->{err} = "DB INSERT ERROR: ".$sth->errstr." <p>"; }
	
	my $insertid = $dbh->{'mysql_insertid'};
	$sth->finish(  );
	return $insertid;


}

# -------   Insert --------------------------------------------------------

# Adapted from SQL::Abstract by Nathan Wiger

sub db_insert_ignore {		# Inserts record into table from hash

						# Verify Input Data

	my $dbh = shift || &error($dbh,"","","Database handler not initiated");
	my $query = shift;
	my $table = shift || &error($dbh,"","","Table not specified on insert");
	my $input = shift || &error($dbh,"","","No data provided on insert");

	
    	my $vars = ();
    	if (ref $query eq "CGI") { $vars = $query->Vars; }

	
	my $dtype = ref $input;
	&error($dbh,"","","Unsupported data type specified to insert (data was $dtype)") 
		unless (ref $input eq 'HASH' || ref $input eq 'gRSShopper::Record' || ref $input eq 'gRSShopper::Person');
	my $data= &db_prepare_input($dbh,$table,$input);
	
	
	my $sql   = "INSERT IGNORE INTO $table ";	# Prepare SQL Statement

	my(@sqlf, @sqlv, @sqlq) = ();

	for my $k (sort keys %$data) {
		push @sqlf, $k;
		push @sqlq, '?';
		push @sqlv, $data->{$k};
	}
	$sql .= '(' . join(', ', @sqlf) .') VALUES ('. join(', ', @sqlq) .')';

						
	my $sth = $dbh->prepare($sql);		# Execute SQL Statement
	if ($diag eq "on") { 
		print "Content-type: text/html\n\n";
		print "$sql <br/>\n @sqlv <br/>\n";
	}

    	$sth->execute(@sqlv);
	
	if ($sth->errstr) { $vars->{msg} .= "DB INSERT ERROR: ".$sth->errstr." <p>"; }
	my $insertid = $dbh->{'mysql_insertid'};
	$sth->finish(  );
	return $insertid;


}


# -------  Update---------------------------------------------------------

# Updates record $where (must be ID) in table from hash
# Adapted from SQL::Abstract by Nathan Wiger


# -------  Update---------------------------------------------------------

# Updates record $where (must be ID) in table from hash
# Adapted from SQL::Abstract by Nathan Wiger

sub db_update {		
	
	my ($dbh,$table,$input,$where,$msg) = @_;
	unless ($dbh) { die "Error $msg Database handler not initiated"; }
	unless ($table) { die "Error $msg Table not specified on update"; }
	unless ($input) { die "Error $msg No data provided on update"; }
	unless ($where) { die "Error $msg Record ID not specified on update"; }

	if ($diag eq "on") { print "DB Update ($table $input $where)<br/>\n"; }
	die "Unsupported data type specified to update" unless (ref $input eq 'HASH' || ref $input eq 'Link' || ref $input eq 'Feed' || ref $input eq 'gRSShopper::Record' || ref $input eq 'gRSShopper::Feed');
	#print "Updating $table $input $where <br>";

	my $data = &db_prepare_input($dbh,$table,$input);
	#print "Data: $data <br>";
	return "No data" unless ($data);
	
	my $sql = "UPDATE $table SET ";
	my(@sqlf, @sqlv) = ();

	for my $k (sort keys %$data) {
		push @sqlf, "$k = ?";
		push @sqlv, $data->{$k};

        }

	$sql .= join ', ', @sqlf;
	$sql .= " WHERE ".$table."_id = '".$where."'";
	#print "$sql <br>".@sqlv;
	my $sth = $dbh->prepare($sql);
	
	if ($diag eq "on") { print "$sql <br/>\n @sqlv <br/>\n"; }
    	$sth->execute(@sqlv) or &error($dbh,"","","Update failed: ".$sth->errstr);

	return $where;


}


# -------  Increment---------------------------------------------------------
#
# For table type $gtable, record id $id, increment the value of $field by one
# and return the new value of $field

sub db_increment {

	my ($dbh,$table,$id,$field,$from) = @_;
	
	&error($dbh,"","","Database not initialized in db_increment") unless ($dbh);				# Check Input
	&error($dbh,"","","Table not initialized in db_increment") unless ($table);
	&error($dbh,"","","Field not initialized in db_increment") unless ($field);
	&error($dbh,"","","ID number not initialized in db_increment - $from") unless ($id);

	my $idfield = $table."_id";
	my $prefix = $table."_";

	unless ($field =~ /$prefix/) { $field = $table."_".$field; }

	my $hits = db_get_single_value($dbh,$table,$field,$id);

	my $sql;
	if ($hits) { $sql = "update $table set $field = $field + 1 where $idfield = $id"; }
	else { $sql = "update $table set $field = 1 where $idfield = $id"; }
 	my $sth = $dbh->prepare($sql) or &error($dbh,"","","Can't prepare the SQL in db_increment $table");
	$sth->execute or &error($dbh,"","","Can't execute the query: ".$sth->errstr);
	$hits++;
	return $hits;

}


# -------   Prepare Input ----------------------------------------------------


sub db_prepare_input {	# Filters input hash to contain only columns in given table

	my ($dbh,$table,$input) = @_;
	if ($diag eq "on") { print "DB Prepare Input ($table $input)<br/>\n"; }
	my $data = ();

						# Get a list of columns

	my @columns = &db_columns($dbh,$table);				

						# Clean input for save
	foreach my $ikeys (keys %$input) {

		next unless ($input->{$ikeys});		
		next if ($ikeys =~ /_id$/i);	
		if (&index_of($ikeys,\@columns) < 0) {
			# print "Warning: input for aa".$ikeys."aa does not have a corresponding column in aa".$table."aa<p>";	
			next;
		}	
		# print "$ikeys = $input->{$ikeys} <br>"; 	
		$data->{$ikeys} = $input->{$ikeys};			
	}

	return $data;

}

# -------   Count -------------------------------------------------------------

# Count Number of Items in a Search

sub db_count {

	my ($dbh,$table,$where) = @_;
						
	my $stmtc = "SELECT COUNT(*) AS items FROM $table $where";
	my $sthc = $dbh -> prepare($stmtc);
	$sthc -> execute();
	my $refc = $sthc -> fetchrow_hashref();
	my $count = $refc->{items};
	$sthc->finish( );
	unless ($count) { $count = 0; }
	return $count;

}

# -------   Columns -----------------------------------------------------------

sub db_columns {

						
	my ($dbh,$table) = @_;			# Get a list of columns
	my @columns = ();			 
	my $showstmt = "SHOW COLUMNS FROM $table";
	my $sth = $dbh -> prepare($showstmt);
	$sth -> execute();
	while (my $showref = $sth -> fetchrow_hashref()) { 
		push @columns,$showref->{Field}; 
	}
	return @columns;
}



#-------------------------------------------------------------------------------
#
# -------   Database Tables ---------------------------------------------------------
#
# 		Returns the list of tables in the database
#	      Edited: 28 March 2010
#-------------------------------------------------------------------------------



sub db_tables {

	my ($dbh) = @_; my @tables;
	my $sql = "show tables";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while (my $hash_ref = $sth->fetchrow_hashref) {
		while (my($hx,$hy) = each %$hash_ref) { push @tables,$hy; }
	}
	return @tables;
}




#-------------------------------------------------------------------------------
#
# -------   Set Fields ---------------------------------------------------------
#
# 		Reads the fields list from a file and defines field names for the current table
# 		eg. 'description' in the 'post' table is named 'post_description' 
# 		This file is generated in admin.cgi, refield()
# 		Done this way to avoid another database hit and to allow unique field names
#	      Edited: 28 March 2010
#-------------------------------------------------------------------------------


sub set_fields {

	my $table = shift;
	my $fields = {};

	my @fieldlist = qw(access active author body cache code cohort crdate creator crip content current day description dirname environment feedid feedname file finish 	finishtime group host icalstart icalend id identifier issued journal link localtz location mday mime modified mon name owner_url parent password pub_date refresh source sponsor sponsor_url srefresh star start status starttime supdated text textsize thread timezone title type updated yday year);

   	foreach my $f (@fieldlist) {
		$fields->{$f} = $table."_".$f;
	}
	return $fields

}






# -------   Update Vote ------------------------------------------------------                                                   UPDATE


sub update_vote {
	
	my ($dbh,$query) = @_;
	my $vars = $query->Vars;
	$vars->{vote_table} ||= "post";
	
		
	# Remove Previous Vote
	if ($Person->{person_id} && $vars->{vote_table} && $vars->{vote_post} ) {
		my $dsql = qq|DELETE FROM vote WHERE vote_person='$Person->{person_id}' AND vote_table='$vars->{vote_table}' AND vote_post='$vars->{vote_post}'|;
		$dbh->do($dsql);
	}

	
	# Create Current Vote
	my $crdate = time;
	$vote_id = &db_insert($dbh,$query,"vote",{vote_person=>$Person->{person_id},
		vote_post=>$vars->{vote_post},vote_table=>$vars->{vote_table}, vote_value=>$vars->{vote_value},
		vote_creator=>$Person->{person_id},vote_crdate=>$crdate});
		
	# Recalculate vote count for the post
	my $sth1 = $dbh->prepare(qq|SELECT SUM(vote_value) FROM vote WHERE vote_post=? AND vote_table=?|) or return $dbh->errstr;
	$sth1->execute($vars->{vote_post},$vars->{vote_table}) or return $dbh->errstr;
	my ($sum) = $sth1->fetchrow_array or $dbh->errstr;
	&db_update($dbh,"post",{post_votescore=>$sum},$vars->{vote_post},"Update vote in post");

	
	
	# Return the vote value
	if (sum) { return $sum; } else { return "0"; }
	
}











































#-------------------------------------------------------------------------------
#
#   Search Functions
#
#-------------------------------------------------------------------------------

sub find_by_title {

	my ($dbh,$table,$title) = @_;
	return unless (defined $table);
	$title =~ s/%20/ /g;
	$title =~ s/  / /g;
   	my $vars = (); if (ref $query eq "CGI") { $vars = $query->Vars; }

				# Find and return ID number for title
	my $tfield;
	if ($table =~ /author|person/) { $tfield = $table."_name"; }
	else {$tfield = $table."_title"; }
	
	if ($title =~ /(.*?) - (.*?)/) {
		$vars->{table} = "feed";
		return $1;
	}
	
	my $newid = &db_locate($dbh,$table,{$tfield => $title});
	if ($newid) { return $newid; }
	
				# For select tables, autocreate the record if it doesn't exist
				# Works only for links from the site
			
	return unless ($ENV{'HTTP_REFERER'} =~ $Site->{st_url});
	if ($table =~ /journal/) {
			$newid = &db_insert($dbh,$query,$table,{journal_title => $title});
	} elsif ($table =~ /author/) {
			$newid = &db_insert($dbh,$query,$table,{author_name => $title});
	}
	return $newid;
}


#-------------------------------------------------------------------------------
#
# -------   Find Records ------------------------------------------------------
#
#		$terms is a hash of vield values eg. $terms->{post_id} = 12
#		$terms must include   table=>$table
#		to use > or < do this:   field=>">$value" or field=>"<$value" 
#		this finction treats search terms as a conjunction
#		use com=>"OR" to treat as disjunction
#		use number=>$num to specify a limit
#		use sort=>$field to specify a sort (or sort=>"$field DESC")
#	      Edited: 31 July 2010
#
#-------------------------------------------------------------------------------

sub find_records {

	my ($dbh,$terms) = @_;						# Default Parameters
	return unless (defined $dbh && $dbh);
	return unless (defined $terms && $terms);
	return unless (defined $terms->{table} && $terms->{table});
	unless (defined $terms->{com} && $terms->{com}) {$terms->{com} = " AND "; }

	my @fields_array; my @values_array;						# Create SQL Statement
	while (my($sx,$sy) = each %$terms) {
		next if ($sx =~ /^(sort|number|table|com)$/);
		my $rel = "=";
		if ($sy =~ /^</) { $rel="<"; $sy=~s/<//; }
		if ($sy =~ /^>/) { $rel=">"; $sy=~s/>//; }
		push @fields_array,$sx.$rel."?";
		push @values_array,$sy;
	}
	my $fieldstring = join $terms->{com},@fields_array;
	my $sql = "SELECT " . $terms->{table} . "_id" . " FROM " . $terms->{table};
	if ($fieldstring) { $sql .= " WHERE " . $fieldstring; }
	if (defined $terms->{sort} && $terms->{sort}) {
		$sql .= " ORDER BY ".$terms->{sort};
	}
	if (defined $terms->{number} && $terms->{number}) {
		$sql .= " Limit ".$terms->{number};
	}

	my $sth = $dbh->prepare($sql);						# Execute Search
	return $dbh->selectcol_arrayref($sth, {}, @values_array);

} 

sub search {

	my ($dbh,$query) = @_;

	print "Content-type: text/html; charset=utf-8\n\n";
   	my $vars = (); if (ref $query eq "CGI") { $vars = $query->Vars; }


						# Initialize Page
	my $page = gRSShopper::Page->new;
	$page->{table} = $vars->{table} || "post";
	$page->{format} = $vars->{format} || "html";
	$page->{title} = "Search ".ucfirst($page->{table})."s";
	
						# Permissions
						
	return unless (&is_allowed("view",$page->{table})); 

						# Header
	$page->{page_format} = $format;
	$page->{page_content} = &header($dbh,$query,$page->{table},$page->{format},$page->{title});
	$page->{page_content} .= "<h3>$page->{title}</h3>";


						# Compile SQL 'Where' Statement
	my @conjuncts = ();
	my @columns = &db_columns($dbh,$page->{table});
	while (my($cx,$cy) = each %$vars) {

		next if ($cx eq "format");
		my @disjuncts = ();
		$vars->{$cx} =~ s/\0//g;
		$cy =~ s/\0//g;

		my @flds = split /,/,$cx;
		foreach my $fld (@flds) {


			next unless ($cy);
			my $field = $page->{table}."_".$fld;
			next unless (&index_of($field,\@columns)>-1);
			$cy =~ s/'/&apos/g;		#'
			if ($cy =~ /\|/) {
				push @disjuncts,"($field REGEXP '$cy')";
			} else {
				push @disjuncts,"($field LIKE '%$cy%')"; 
			}


		}
		my $searchvar = join " OR ",@disjuncts;
		next unless ($searchvar);
		$searchvar = "(".$searchvar.")";
		push @conjuncts,$searchvar;

	}
	my $where = join " AND ",@conjuncts;
	if ($where) { $where = "WHERE ".$where; }


						# Count Results

	my $count = &db_count($dbh,$page->{table},$where);


						# Set Sort, Start, Number values

	my ($sort,$start,$number,$limit) = &sort_start_number($query,$page->{table});
	$page->{page_content} .= qq|<p id="listing">Listing $start to |.($start+$number)." of $count ".$page->{table}."s found</p>";


	
						# Execute SQL search

	my $stmt = qq|SELECT * FROM $page->{table} $where $sort $limit|;
	unless ($vars->{start}) { $vars->{start} = 0; }
	my $sthl = $dbh->prepare($stmt);
	$sthl->execute();
	


	while (my $list_record = $sthl -> fetchrow_hashref()) {


		$vars->{comment} = "no";		# Suppresss comment form in results

		my $record = gRSShopper::Record->new;
		$record->{data} = $list_record;
		my $type = $list_record->{post_type};


						# Set Record Format
		my $record_format = lc($page->{format});							# default record format	
		if ($record_format =~ /html/i) { $record_format = "summary"; }			# special case for HTML pages


						# Format Record

		my $record_text = &format_record($dbh,
			$query,
			$page->{table},
			$record_format,
			$list_record);
			
		$page->{page_content} .=  $record_text;

	}


						# Next Button
#	if ($page->{format} eq "html") {
		$page->{page_content} .= &next_button($query,$table,$page->{format},$start,$number,$count);
#	}

						# Footer
	$page->{page_content} .= &footer($dbh,$query,$table,$page->{format},"Search ".ucfirst($table)."s");


						# Format Content

	&format_content($dbh,$query,$options,$page);
	$page->print;
	$sthl->finish();
	exit;


}

#
# -------  Sort, Start and Number --------------------------------------------------------
#
#          Determine values for sort, start and number
#          Called from list()
#	     Edited: 27 March 2010
#

sub sort_start_number {

	my ($query,$table) = @_;
	my $vars = ();
	if (ref $query eq "CGI") { $vars = $query->Vars; }

						# Number

	my $number = $vars->{number} || $Site->{st_list} || 100;
#	print "Number: $number <br>";

						# Sort
	my $sort = "ORDER BY "; 
	if ($vars->{sort}) {
		$sort .= $vars->{sort};
	} else {
		if ($table =~ /box|view|feed|field|page|topic|template|optlist/) { 
			$sort .= $table."_title" ; 
		} elsif ($table =~ /person/) {
			$sort .= $table."_name";
		} elsif ($table =~ /event/) {
			$sort .= $table."_start DESC";
		} elsif ($table =~ /link/) {
			$sort .= $table."_id DESC";
		} else { 
			$sort .=  $table."_crdate DESC"; 
		}
	}
#	print "Sort: $sort <br>";
	
						# Start
	my $limit = "";
	if ($vars->{start}) {
		$limit = " LIMIT $vars->{start},$number";
	} else {
		$limit = " LIMIT $number";
	}
	my $start = $vars->{start};
	unless ($start) { $start = 0; }
#	print "Start: $start <br>Limit: $limit<br>";

	return ($sort,$start,$number,$limit);
}


#
# -------  Next Buttom --------------------------------------------------------
#
#          Creates a 'Next' Button to page lists
#          Called from list()
#	     Edited: 27 March 2010	
#

sub next_button {

	my ($query,$table,$format,$start,$number,$count) = @_;
    	my $vars = ();
    	if (ref $query eq "CGI") { $vars = $query->Vars; }

						# Reset Search Variables
	unless ($vars) { $vars = (); }
	$vars->{format} = $format;
	$vars->{start} = $start+$number;
	$vars->{number} = $number;
	$vars->{table} = $table;
	my $button = "";

						# Create Next Button Using Search Variables
	if (($start+$number)<$count) {

		$button = qq|<p><form method="post" action="$Site->{script}">\n|;
		while (my ($fx,$fy) = each %$vars) {
			$fy =~ s/"/&quot;/g;		# "
			$button .= qq|<input type="hidden" name="$fx" value="$fy">\n|;
		}
		$button .= qq|<input type="submit" value="Next $number Results" class="button">|;
		$button .= "<form></p>";
	}

	return $button;
}



#-------------------------------------------------------------------------------
#
#           DATES 
#
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#
# -------   AutoTimezones ---------------------------------------------------
#
# 		Inserts dates into string
#           Defaults to system timezone
#           But will defer to query variable 'timezone'
#
#-------------------------------------------------------------------------------

sub autotimezones {		
	my ($query,$text_ptr) = @_;
    	my $vars = ();
    	if (ref $query eq "CGI") { $vars = $query->Vars; }

	while ($$text_ptr =~ /<timezone epoch="(.*?)">/sg) {
		my $epoch = $1; my $tz = $vars->{timezone};
		my $replace = &tz_date($query,$epoch,$tz);
		my $original = qq|<timezone epoch="|.$epoch.qq|">|;
		$$text_ptr =~ s/$original/$replace/sig;
	}

	while ($$text_ptr =~ /<timezonedropdown>/sg) {
		my $db; my $id;
		if ($vars->{page}) { $vars->{db} = "page"; $vars->{id} = $vars->{page}; }
		if ($vars->{event}) { $vars->{db} = "event"; $vars->{id} = $vars->{page}; }
		my $ctz = $vars->{timezone} || $Site->{st_timezone};
		my $replace = qq|<p><form method="post" action="?">
			<input type="hidden" name="db" value="$vars->{db}">
			<input type="hidden" name="id" value="$vars->{id}">

			Time Zone: 
		|;
		$replace .= &tzdropdown($query,$ctz);
		$replace .= qq|<input type="submit" value="Select time zone">
			</form></p>|;

		$$text_ptr =~ s/<timezonedropdown>/$replace/sig;
	}

}

#-------------------------------------------------------------------------------
#
# -------   TZ Dropdown ---------------------------------------------------
#
#		Creates a select dropdown to select time zone
#
#-------------------------------------------------------------------------------

sub tzdropdown {

	my ($query,$ctz) = @_;
	unless (&new_module_load($query,"DateTime::TimeZone")) {
		return "DateTime::TimeZone module not available in sub tzdropdown"; 
	}

	my @TZlist = DateTime::TimeZone->all_names;
	my $replace = qq|<select name="timezone">\n|;
	foreach $tzl (@TZlist) { 
		my $sel=""; if ($ctz eq $tzl) { $sel = " selected"; }
		$replace .= qq|<option value="$tzl"$sel>$tzl</option>\n|; 
	}
	$replace .= "</select>\n";
	return $replace;

}

# -------------------------------------------------------------------
#
#  Prevents endless loops
#

sub escape_hatch {
	$vars->{escape_hatch}++; die "Endless recursion keyword loop" if ($escape_hatch > 10000);
	
}



#-------------------------------------------------------------------------------
#


#-------------------------------------------------------------------------------
#
# -------   AutoDates ---------------------------------------------------
#
# 		Inserts dates into string
# 		Provide text pointer 
#		Format: <date_type>time<END_date_type>
#
#		Supported:
#		<NICE_DATE>		Nice date string
#		<MON_DATE>		Nice date string, month only
#           <822_DATE>		RFC 822 Date
#		<GMT_DATE>		GMT Date	
#
#		I'd like to fix this for nicer syntax
#		and include other date types
#-------------------------------------------------------------------------------



sub autodates {		
	my ($text_ptr) = @_;


			
	while ($$text_ptr =~ /<date (.*?)>/sg) {
		
		my $autocontent = $1; my $replace = "date not found";
		&escape_hatch();				
		my $script = {}; &parse_keystring($script,$autocontent);

		my $time = $script->{time} || time;					# Date / time from record (in epoch format)
		if ($time eq "now") { $time = time; }
		my $tz = $script->{timezone} || $Site->{st_timezone};			# Allows input to specify timezone
		my $format = $script->{format} || "nice";				# Format

		if ($format eq "nice") { $replace = &nice_date($time,"day",$tz);	}
		elsif ($format eq "niceh") { $replace = &nice_date($time,"min",$tz);	}		
		elsif ($format eq "time") { $replace = &epoch_to_time($time,"min",$tz); }
		elsif ($format eq "rfc822") { $replace = &epoch_to_rfc822($time,"min",$tz); }
		elsif ($format eq "tzdate") { $replace = &tz_date($time,"day",$tz); }
		elsif ($format eq "datepicker") { $replace = &tz_date($time,"min",$tz); }
		elsif ($format eq "iso") { $replace = &iso_date($time,"day",$tz); }
		elsif ($format eq "isoh") { $replace = &iso_date($time,"min",$tz); }		
		else { $relace = "Autodates error"; }
		
	
		$$text_ptr =~ s/<date $autocontent>/$replace/sg
	}
		
	
	
		
		
		
			
	for my $date_type ("NICE_DATE","NICE_DT","822_DATE","MON_DATE","GMT_DATE","YEAR") {

		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time); 
		$year = $year+1900;


		if ($date_type =~ /YEAR/i) { $$text_ptr =~ s/<YEAR>/$year/ig; next;}
		elsif ($date_type =~ /NOW/i) { my $replace = &nice_date(time); $$text_ptr =~ s/<NOW>/$replace/ig; next;}


		my $date_type_end = "END_".$date_type;
		while ($$text_ptr =~ /<$date_type>(.*?)<$date_type_end>/sg) {
			my $autotext = $1; my $otime; my $replace;
			$otime = $autotext; 			
			if ($date_type =~ /822/) { 
				$replace = &rfc822_date($otime); 
			} elsif ($date_type =~ /GMT_DATE/) {
				$replace = &nice_date($otime,"GMT"); 
			} elsif ($date_type =~ /MON/) { 
				$replace = &nice_date($otime,"month"); 
			} elsif ($date_type =~ /NICE_DT/) { 
				$replace = &nice_dt($otime,"month"); 			
			} else { 
				$replace = &nice_date($otime); 
			}
			$$text_ptr =~ s/<$date_type>\Q$autotext\E<$date_type_end>/$replace/sig;
		}
	}
}

#-------------------------------------------------------------------------------
#
# -------   Locale Date ---------------------------------------------------
#
# 		Returns a date string based on the specified locale
#		Edited: 18 Feb 2014
#		Author: Luc Belliveau <luc.belliveau@nrc-cnrc.gc.ca>
#		Requires: system that supports locales (and POSIX)
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#
# -------   ISO Date ---------------------------------------------------
#
# 		ISO format string supported is either YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS
# 		
#	      Edited: 21 Jun 2014
#-------------------------------------------------------------------------------

sub iso_date {



	my ($time,$h,$tz) = @_; 
	
	my $dt = &set_dt($time,$tz);
		
	my ($year,$month,$day,$dow,$hour,$minute,$second) = &dt_to_array($dt);

	if ($h eq "min") { return $year."-".$month."-".$day."T".$hour.":".$minute.":00"; }
	
	return $dt->year."-".$dt->month."-".$dt->day;

}


#-------------------------------------------------------------------------------
#
# -------   Nice Date ---------------------------------------------------
#
# 		Returns a nice date string given the time
#	      Edited: 29 Jul 2010
#-------------------------------------------------------------------------------

sub nice_date {

	# Get date from input
	my ($time,$h,$tz) = @_; my $date;
	unless (defined $h) { $h = "day"; }
	unless (defined $time) { $time = time; }

	my $dt = &set_dt($time,$tz);
	
	# return locale_date($current, "%e %b %Y", "fr_CA");
        
	my ($year,$month,$day,$dow,$hour,$minute,$second) = &dt_to_array($dt);        
	my @months = &month_array();
	my @days = &day_array();
	


	if ($h eq "month") {							# April, 1959
		return "$months[$month], $year";
	} elsif ($h eq "day" ) {						# April 6, 1959
		return "$months[$month] $day, $year";
	} else {								# April 6, 1959 3:12 p.m.
		
		$date = "$months[$month] $day, $year";
		my $midi;
		if ($hour > 11) { $midi = "p.m."; }
		else { $midi = "a.m."; }
		if ($hour > 12) { $hour = $hour - 12; }
		if ($hour == 0) { $hour = 12; $midi = "a.m."; }
		
		return "$months[$month] $day, $year $hour:$minute $midi";
	}

}

# -------   Nice Date ---------------------------------------------------
#
# 		Returns a nice date string with the exact time given the time
#	      Edited: 29 Jul 2010
#-------------------------------------------------------------------------------

sub nice_dt {

	# Get date from input
	my ($current) = @_; 
	return &nice_date($current,"hour");
	


}
#-------------------------------------------------------------------------------
#
# -------   RFC 822 Date ---------------------------------------------------
#
# 		Returns an rfc822 date string given the time
#	      Edited: 29 Jul 2010
#-------------------------------------------------------------------------------



sub rfc822_date {

	# Get date from input
	my ($time,$h,$tz) = @_;

	my $dt = &set_dt($time,$tz);
	my ($year,$month,$day,$dow,$hour,$minute,$second) = &dt_to_array($dt);        
	my @months = &month_array();
	my @days = &day_array();
	unless ($minute) { $minute="00"; }
	unless ($second) { $second="00"; }	
	return "$days[$dow], $day $months[$month] $year $hour:$minute:$second -0400";
}



#-------------------------------------------------------------------------------
#
# -------   Calendar Date ---------------------------------------------------
#
# 		Returns an cal date string given the time Format: year/month/day
# 		Used to match input from date-picker
#	      Edited: 29 Jul 2010
#-------------------------------------------------------------------------------



sub cal_date {

	my ($time,$h,$tz) = @_;

	my $dt = &set_dt($time,$tz);
	
	my ($year,$month,$day,$dow,$hour,$minute,$second) = &dt_to_array($dt);        

	if ($h eq "min") { return $year."/".$month."/".$day." ".$hour.":".$minute; }
	
	return $year."/".$month."/".$day;
}


#-------------------------------------------------------------------------------
#
# -------   TZ Date ---------------------------------------------------
#
# 		Returns a date string given the epoch date, a time zone,
#           and optional formatting parameter
#           Do not cache tz date, run immediately before print
#
#	      Edited: 24 April 2011
#-------------------------------------------------------------------------------


sub tz_date {
	
	# Get date from input
	my ($time,$h,$tz) = @_;

	my $dt = &set_dt($time,$tz);
	my ($year,$month,$day,$dow,$hour,$minute,$second) = &dt_to_array($dt);        
	my @months = &month_array();
	my @days = &day_array();
	
	if ($h eq "min") {
		return "$year/$month/$day $hour:$minute";
	} elsif ($h eq "day") {
		return "$year/$month/$day";
	} else {
		return "$hour:$minute, $weekdays[$dow], $day $months[$month] $year ";
	}
}

#-------------------------------------------------------------------------------
#

# -------   set_dt -------------------------------------------------------

sub set_dt {
	
	
	my ($time,$tz) = @_;
	
	unless ($time > 0) { $time = 0; }						# Fail silently if text sent instead of epoch
	
	
	unless (&new_module_load($query,"DateTime")) {				
		return "DateTime module not available in sub set_dt"; 
	}
		
	my $dt = DateTime->from_epoch( epoch => $time );			# Convert to DateTime
	my $tz = $tz || $Site->{st_timezone} || "America/Toronto";					# Allows input to specify timezone
	unless (DateTime::TimeZone->is_valid_name($tz)) { 
		print "Content-type: text/html\n\n"; print "Invalid time zone in set_dt(): $tz <p>"; return; }
	if ($tz) { $dt->set_time_zone($tz); }
		
	return $dt;
	
}

# -------   $dt to array  ---------------------------------------------------

sub dt_to_array {
	
	my ($dt) = @_;
	unless (defined $dt) {
		$Site->{warn} .= "dt_to_array received no input <br>\n";
      	return;
	}		

	my $year   = $dt->year;
	
	my $month  = $dt->month;       # 1-12
	if ($month < 10) { $month = "0".$month; }	

	$day    = $dt->day;            # 1-31
	if ($day < 10) { $day = "0".$day; }
	
	$dow    = $dt->day_of_week;    # 1-7 (Monday is 1)
	
	$hour   = $dt->hour;           # 0-23
	if ($hour < 10) { $hour = "0".$hour; }
		
  	$minute = $dt->minute;         # 0-59
	if ($minute < 10) { $minute = "0".$minute; }

	return ($year,$month,$day,$dow,$hour,$minute,$second);
}


sub month_array {
	
	return 	("",&printlang("Jan"),&printlang("Feb"),&printlang("Mar"),&printlang("Apr"),
		&printlang("May"),&printlang("Jun"),&printlang("Jul"),&printlang("Aug"),
		&printlang("Sept"),&printlang("Oct"),&printlang("Nov"),&printlang("Dec"));
	
}


sub day_array {

											# String Arrays
	return (&printlang("Sun"),&printlang("Mon"),&printlang("Tue"),
		&printlang("Wed"),&printlang("Thu"),&printlang("Fri"),&printlang("Sat"));
	
	
}

#-------------------------------------------------------------------------------
#
# -------   Locale Date ---------------------------------------------------
#
# 		Returns a date string based on the specified locale
#		Edited: 18 Feb 2014
#		Author: Luc Belliveau <luc.belliveau@nrc-cnrc.gc.ca>
#		Requires: system that supports locales (and POSIX)
#-------------------------------------------------------------------------------

sub locale_date {
	my ($current, $fmt, $locale) = @_;
	unless (defined $fmt) { $fmt = "%c"; }
	unless (defined $locale) { $locale = "en_US"; }

	my $date = $current;
	unless (looks_like_number($current)) {
		$date = str2time($current);
	}

	if ($current eq 0) { return &printlang("N/A"); }
	
	# Save old locale	
	my $old_locale = setlocale(LC_TIME);
	
	# Set current locale to specified value (TODO: add sanity check))
	setlocale(LC_TIME, $locale);

	# Extract values for date
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);
	if ($h eq "GMT") { ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($date); } 
	else { ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($date); }
	
	# Format date
	my $str = strftime($fmt, $sec, $min, $hour, $mday, $mon, $year);

	# Return locale to it's original setting
	setlocale(LC_TIME, $old_locale);

	# Return our formated date, with any extended characters encoded as html entities.
	return encode_entities($str);

}



#-------------------------------------------------------------------------------
#
# -------   RFC3339 to eopch ---------------------------------------------------
#
#           Converts an RFC 3339 (ISO ISO 8601)
#		to epoch, GMT value
#	      Edited: 28 March 2010
#-------------------------------------------------------------------------------

sub rfc3339_to_epoch {

	my ($rfc3339,$tz) = @_;

	my ($y,$m,$d,$h,$mm,$s) = $rfc3339 =~ /(.*?)\-(.*?)\-(.*?)T(.*?):(.*?):(.*?)Z/;
	$y+=0;$m+=0;$d+=0;$h+=0;$mm+=0;	# Convert to numeric;
	$y-=1900;$m-=1;
	my $epoch = timegm($s,$mm,$h,$d,$m,$y);
	return $epoch;


}



sub epoch_to_rfc822 {

	# Get date from input
	my ($time,$h,$tz) = @_;
	my $dt = &set_dt($time,$tz);
	my ($year,$month,$day,$dow,$hour,$minute,$second) = &dt_to_array($dt);        
	my @months = &month_array();
	my @days = &day_array();
	unless ($minute) { $minute="00"; }
	unless ($second) { $second="00"; }		

	return "$days[$dow], $day $months[$month] $year $hour:$minute:$second -0400";

}


#-------------------------------------------------------------------------------
#
# -------   Datepicker to eopch ---------------------------------------------------
#
#           Converts a datepicker Date 
#		to epoch, GMT value
#               Datepicker dates have the form:  yyyy/mm/dd hh:mm
#             Time zone offset (in hours) is $Site->{st_timezone}
#	      Edited: 28 March 2010
#-------------------------------------------------------------------------------

sub datepicker_to_epoch {

	my ($datepick,$tz) = @_;

	unless (&new_module_load($query,"DateTime")) {
		return "DateTime module not available in epoch_to_datepicker"; 
	}
	
	my $s = 0;
	my ($date,$hour) = split " ",$datepick;
	my ($y,$m,$d) = split "/",$date;
	my ($h,$mm) = split ":",$hour;
#	my ($y,$m,$d,$h,$mm) = $datepick =~ /(.*?)\/(.*?)\/(.*?) (.*?):(.*?)/;    Doesn't work for some reason (drops minutes to 0 )
	return "" unless ($y);	# Catch parsing errors

	$m = int($m); $h = int($h); $y = int($y); $d = int($d); $mm = int($mm);		# Convert datepicker to integers

	my $tz ||= $Site->{st_timezone} || "America/Toronto";	# Needs to be the server time zone setting
	
	my $dt = DateTime->new( 
		year 	   => $y,
		month      => $m,
		day        => $d,
		hour       => $h,
		minute     => $mm,
		time_zone  => $tz,
	);

	my $epoch = $dt->epoch();
	
	return $epoch;

}



#-------------------------------------------------------------------------------
#
# -------   Epoch to Datepicker ---------------------------------------------------
#
#           Converts an epoch Date 
#		to Datepicker
#               Datepicker dates have the form:  yyyy/mm/dd hh:mm
#             Time zone offset (in hours) is $Site->{st_timezone}
#	      Edited: 28 March 2010
#-------------------------------------------------------------------------------

sub epoch_to_datepicker {

	# Get date from input
	my ($time,$h,$tz) = @_;
	my $dt = &set_dt($time,$tz);
	my ($year,$month,$day,$dow,$hour,$minute,$second) = &dt_to_array($dt);        

	return "$year/$month/$day $hour:$minute";
}


#-------------------------------------------------------------------------------
#
# -------   Epoch to Date ---------------------------------------------------
#
#           Return the date in an epoch
#            Eg. March 26  or May 5
#             Time zone offset (in hours) is $Site->{st_timezone}
#	      Edited: 28 March 2010
#-------------------------------------------------------------------------------

sub epoch_to_time {

	# Get date from input
	my ($time,$h,$tz) = @_;
	my $dt = &set_dt($time,$tz);
	my ($year,$month,$day,$dow,$hour,$minute,$second) = &dt_to_array($dt);        
 	
	return $hour.":".$minute;
}

#-------------------------------------------------------------------------------
#
# -------   Epoch to Time ---------------------------------------------------
#
#           Return the time in an epoch
#            Eg. 18:35
#             Time zone offset (in hours) is $Site->{st_timezone}
#	      Edited: 28 March 2010
#-------------------------------------------------------------------------------

sub epoch_to_date {

	# Get date from input
	my ($time,$h,$tz) = @_;
	my $dt = &set_dt($time,$tz);
	my ($year,$month,$day,$dow,$hour,$minute,$second) = &dt_to_array($dt);        
	my @months = &month_array();
	
	return $months[$month]." ".$day;
}
#-------------------------------------------------------------------------------
#
# -------   RFC3339 to eopch ---------------------------------------------------
#
#           Converts an RFC 3339 (ISO ISO 8601)
#		to epoch, GMT value
#	      Edited: 28 March 2010
#-------------------------------------------------------------------------------

sub ical_to_epoch {

	my ($tval,$feedtz) = @_;

	my $tz; my $val;					# Establish time zone
	if ($tval =~ /TZID=(.*?):(.*?)/) {
		$tz = $1; $val = $2;
	} elsif ($tval =~ /Z/) {
		$tz = "UTC"; $val = $tval;
	} else {
		if ($feedtz) { $tz = $feedtz; $val = $tval; }
		else { $tz = "UTC"; $val = $tval; }
	}


    	$val =~ tr/a-zA-Z0-9/X/cs;             	# remove non-alphas from iCal date
    	$val =~ s/X//g;             			# (complicated because Google throws a weird char in there) 

								# parse ical vals and create dt
#print "parsing icaldate<br>";
	my ($y,$m,$d,$h,$mm,$s) = &parse_icaldate($val);
	unless ($y) { $y = "2011"; }
	unless ($m) { $m = 1; }
	unless ($d) { $d = 1; }
	unless ($h) { $h = 0; }
	unless ($mm) { $mm = 0; }
	unless ($s) { $s = 0; }
#print "($y,$m,$d,$h,$mm,$s)";	
	my $dt = DateTime->new(
 	     year       => $y,
 	     month      => $m,
 	     day        => $d,
 	     hour       => $h,
 	     minute     => $mm,
 	     second     => $s,
 	     time_zone  => $tz,
 	);

	my $epoch_time  = $dt->epoch;
	return ($tz,$epoch_time);


}



#-------------------------------------------------------------------------------
#
# -------   RFC3339 to local ---------------------------------------------------
#
#           Converts an RFC 3339 (ISO ISO 8601)
#		to epoch, GMT value
#	      Edited: 28 March 2010
#-------------------------------------------------------------------------------

sub ical_to_local {

	my ($datetime) = @_;

	my $offset="";						# Offset as determined from the dt


	if ($datetime =~ /Z/) { $datetime =~ s/Z//; $offset=0; }

	my ($year,$month,$day,$hour,$minute,$second) = &parse_datetime($datetime);





print "Length $length ; $year : $month : $day : $hour : $minute : $second <br>";


}

# Parse Datetime
#
# parses an iCal datetime string
# bleah


sub parse_icaldate {

	my ($datetime) = @_;

	if ($datetime =~ /Z/) { $datetime =~ s/Z//; $offset=0; }
	my $length = length($datetime);
	my ($year,$month,$day,$hour,$minute,$second);

	if ($length == 15) {
		if ($datetime =~ /^(\d\d\d\d)(\d\d)(\d\d)T(\d\d)(\d\d)(\d\d)$/) {
			$year = $1;
			$month = $2;
			$day = $3;
			$hour = $4;
			$minute = $5;
			$second = $6;
		}
	} elsif ($length == 13) {
		if ($datetime =~ /^(\d\d\d\d)(\d\d)(\d\d)T(\d\d)(\d\d)$/) {
			$year = $1;
			$month = $2;
			$day = $3;
			$hour = $4;
			$minute = $5;
		}
	} elsif ($length == 11) {
		if ($datetime =~ /^(\d\d\d\d)(\d\d)(\d\d)T(\d\d)$/) {
			$year = $1;
			$month = $2;
			$day = $3;
			$hour = $4;
		}
	} elsif ($length == 8) {
		if ($datetime =~ /^(\d\d\d\d)(\d\d)(\d\d)$/) {
			$year = $1;
			$month = $2;
			$day = $3;
		}
	} else {
		print "Odd length: $length for $datetime <br>";
	}

	return ($year,$month,$day,$hour,$minute,$second);

}







#-------------------------------------------------------------------------------
#
#           ANTI-SPAM 
#
#-------------------------------------------------------------------------------


# -------   Make Code ---------------------------------------------------------

# Anti-spammer code - change this if you use this system

sub make_code {

	my $lid = shift;
		# Extract values for date
	my ($sec,$min,$hour,$mday,$mon,
		$year,$wday,$yday,$isdst) = localtime();

	my $cc = $year.$yday;
	my $code = $cc - $lid + 64;
	my $ecode = crypt($code,"85"); 
	
	return $ecode;
}


# -------   Check Code --------------------------------------------------------

# Anti-spammer code - change this if you use this system

sub check_code {

	my ($lid,$check) = @_;
		# Extract values for date

	my ($sec,$min,$hour,$mday,$mon,
		$year,$wday,$yday,$isdst) = localtime();

	my $cc = $year.$yday;
	my $code = $cc - $lid + 64;
	my $gencode = crypt($code,"85");
	if (crypt($code,"85") eq $check) { return 1; }

	$yday--; if ($yday < 0) { 
		if( 0 == $year % 4 and 0 != $year % 100 or 0 == $year % 400 ) { $yday=365; } else { $yday=365; }
		$year--; } 
	$cc = $year.$yday;
	$code = $cc - $lid + 64;
	if (crypt($code,"85") eq $check) { return 1; }

	return 0;

}





#-------------------------------------------------------------------------------
#
#           Utility Functions 
#
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#
#           Getting and Storing Data 
#
#-------------------------------------------------------------------------------


# -------   Harvest: Process Data ------------------------------------------------------

# URL is stored in gRSShopper feed record, $feed->{feed_link}

# If URL is known and in feed record
# my $feedrecord = gRSShopper::Feed->new({dbh=>$dbh,id=>$feedid});

# Otherwise
#	$feedrecord->{feed_link} = $url;
#	&get_url($feedrecord);
#       my $feedrecord = gRSShopper::Feed->new({dbh=>$dbh});

sub get_url {

	my ($feedrecord,$feedid) = @_;
	$feedrecord->{feedstring} = "";
	my $cache = &feed_cache_filename($feedrecord->{feed_link},$Site->{feed_cache_dir});
	my $editfeed = qq|<a href="$Site->{st_cgi}admin.cgi?action=edit&feed=$feedid">Edit Feed</a>|;
	

#	if ((time - (stat($cache))[9]) < (60*60)) {			# If the file is less than 1 hour old

#		&diag(1,"Getting file from common cache<br>");
#		$feedrecord->{feedstring} = &get_file($cache);

#	} else {	

		&diag(1,"Harvesting $feedrecord->{feed_link}<br>\n");





	my $ua = LWP::UserAgent->new;
	$ua->agent("Mozilla/8.0");

	my $server_endpoint = $feedrecord->{feed_link};
 
	# set custom HTTP request header fields
	my $req = HTTP::Request->new(GET => $server_endpoint);

	# set up user agent 
	my $response = $ua->request($req);




	if ($response->is_success) {
		# my $message = $response->decoded_content;
		# my $message .=  "$Site->{st_name}<br>Request Successful\n<br>\nResults returned from $server_endpoint <br> $editfeed <br>";
		#&send_email('stephen@downes.ca','stephen@downes.ca',"gRSShopper Harvest Succeeded",$message,"htm");

	} else {

		my $message = "$Site->{st_name}<br>gRSShopper Harvest Failed \n<br>\n".
			$response->code. "<br>\n".
			$response->message. "<br>\n".
			$server_endpoint. "<br>\n".
			$editfeed."<br>";
    
		print $message;
		#&send_email('stephen@downes.ca','stephen@downes.ca',"gRSShopper Harvest Failed",$message,"htm");
		return;
	}


	
		$feedrecord->{feedstring} = $response->decoded_content();		
		$feedrecord->{feedstring} =~ s/^\s+//;			

		unless ($feedrecord->{feedstring}) {
			&diag(1,"ERROR: Couldn't get $feedrecord->{feed_link} <br>\n\n");
			return;
		}

									# Save common cache
#		open FOUT,">$cache" or die qq|Error opening to write to $cache: $! \nCheck your Feed Cache Location at this location: \n$Site->{st_cgi}admin.cgi?action=harvester\n\n|;
#		print FOUT $feedrecord->{feedstring}  or die "Error writing to $cache: $!";
#		close FOUT;
#		chmod 0666, $cache or &diag(1,"Couldn't chmod $cache: $! <br>\n");
#	}
	

		
	return;

}



sub feed_cache_filename  {
	

	my ($feedurl,$feed_cache_dir) = @_;
	
	my $feed_file = $feedurl;
	unless ($feed_cache_dir =~ /\/$/) {  $feed_cache_dir .= "/"; }
	$feed_file =~ s/http:\/\///g;
	$feed_file =~ s/https:\/\///g;	
	$feed_file =~ s/\%|\$|\@//g;	
	$feed_file =~ s/(\/|=|\?)/_/g;
	
	return $feed_cache_dir.$feed_file;
	
}


#-------------------------------------------------------------------------------
#
#           Misc. Utilities 
#
#-------------------------------------------------------------------------------



sub printlang {						# Print in current language
							# languages loaded in get_site()

	@vars = @_; $counter = 1;
	$langstring = $vars[0];
	$langstring =~ s/&#39;/&apos;/g;                       # (probably need a more generic decoder he
	$Site->{lang_user} ||= $Site->{lang_default};			# Current language, as selected from cookie
	
	if ($Site->{$Site->{lang_user}}->{$langstring}) {
		my $output = $Site->{$Site->{lang_user}}->{$langstring};
		while () {
			my $var_number = '#'.$counter;
			if ($output =~ m/$var_number/) {  
				$vars[$counter] =~ s/&#39;/&apos;/g;
				$output =~ s/$var_number/$vars[$counter]/g;				
			} else { last; }
			$counter++;
		}
		return $output;

	} else {
		return $langstring;
	}
}

#-------------------------------------------------------------------------------


sub isint{						# Is it an integwer?
  my $val = shift;
  return ($val =~ m/^\d+$/);
}

sub new_module_load {
	
							# Load Non-Standard Modules
						
	my ($query,$module) = @_; 
	
		
	my $vars = ();
	if (ref $query eq "CGI") { $vars = $query->Vars; }
	eval("use $module;"); $vars->{mod_load} = $@;
	if ($vars->{mod_load}) {
		
		$vars->{error} .= qq|<p>In order to perform this function gRSShopper requires the $module
			Perl module. This has not been installed on your system. Please consult
			your system administratoir and request that the $module Perl mocule
			be installed.</p>|;
		return 0;
		
	}

	return 1;
}


sub random_password {
	
	my $password;
	my $_rand;

	my $password_length = $_[0];
	if (!$password_length) {
		$password_length = 10;
	}

	my @chars = split(" ",
		"a b c d e f g h i j k l m n o
		p q r s t u v w x y z - _ % # |
		0 1 2 3 4 5 6 7 8 9");

	srand;

	for (my $i=0; $i <= $password_length ;$i++) {
		$_rand = int(rand 41);
		$password .= $chars[$_rand];
	}
	return $password;
}


#	Arrays
#
#	Common array functions - 12 May 2013
#
#	Accepts pointer to @array1, @array2
#	Returns full array of @union, @intersection or @difference
#
# 	Example:
#	my @array1 = (10, 20, 30, 40, 50, 60);
#	my @array2 = (50, 60, 70, 80, 90, 100);
#	my @intersection = &arrays("intersection",@array1,@array2);

sub arrays {

	my ($func,@array1,@array2) = @_;
	
	@union = @intersection = @difference = ();
	%count = ();

	foreach $element (@array1, @array2) { $count{$element}++;  }
	foreach $element (keys %count) {
		if ($func eq "union") { push @union, $element; }
		else { push @{ $count{$element} > 1 ? \@intersection : \@difference }, $element; }
	}
	if ($func eq "union") { return @union; }
	elsif ($func eq "intersection") { return @intersection; }
	elsif ($func eq "difference") { return @difference; }	
}	

#   -------------------------------------------------------------------------------------
#
#   encryptions and salts
#
#   -------------------------------------------------------------------------------------

sub encryptingPsw {
	my $psw = shift;
	my $count = shift; 
	my @salt = ('.', '/', 'a'..'z', 'A'..'Z', '0'..'9');  
	my $salt = "";
	$salt.= $salt[rand(63)] foreach(1..$count);
	my $encrypted = crypt($psw, $salt);
	return $encrypted; 
}

sub generate_random_string
{
  my $count = shift; 
  my @salt = ('-','/', 'a'..'z', 'A'..'Z', '0'..'9');  
  my $salt = "";
  $salt.= $salt[rand(63)] foreach(1..$count);
  return $salt;
}



sub error {

	my ($dbh,$query,$person,$msg,$supl) = @_;
	my $vars = ();
	if (ref $query eq "CGI") { $vars = $query->Vars; }

	if ($vars->{mode} eq "silent") { exit; }
	
	
	if ($person eq "api") {

		print qq|<p class="notice">$msg</p>|;
		exit;
	}



	if ($msg eq "404") {
 print "Content-type: text/html\n\n";
		print "Status: 404 Not Found\n\n";
		print '<!-- ' . ' ' x 512 . ' -->'; # IE 512 byte limit cure
		print "404 - File Not Found\n$supl"; 
	} else {
	

							# Page header
							
	    my $pagetitle = &printlang("Error");	
	    $Site->{header} =~ s/\Q[*page_title*]\E/$pagetitle/g;
	    $Site->{header} =~ s/\Q<page_title>\E/$pagetitle/g;	    	
	    print "Content-type: text/html; charset=utf-8\n\n";
									  
                            # Page body


		print $Site->{header}.qq|<div id='grey-box-wrapper'><h2>$pagetitle</h2>
               <h3>$Site->{st_name}</h3>|;
		
		print "<p>$msg</p></div>";
		print $Site->{footer};
	
#	my $adr = 'stephen@downes.ca';
#	my $env_values = &show_environment();
#	&send_email($adr,$adr,
#		"Error on Website",
#		"Error message: $msg\nSupplementary:$supl\n\n$env_values\n\n");
#	&log_event($dbh,$query,"error","Error message: $msg\nSupplementary:$supl");


	}

	exit if ($dbh eq "nil");
	if ($dbh) { $dbh->disconnect; }
	exit;
}


sub error_inline {

	my ($dbh,$msg,$supl) = @_;
	my $vars = ();

	if (ref $query eq "CGI") { $vars = $query->Vars; }
	if ($vars->{mode} eq "silent") { exit unless ($supl eq "nonterminal"); return; }

	# API Error
	if ($person eq "api") {  print qq|<p class="notice">$msg</p>|;	exit;	}

	# 404 Error
	if ($msg eq "404") {
		print "Content-type: text/html\n\n";
		print "Status: 404 Not Found\n\n";
		print '<!-- ' . ' ' x 512 . ' -->'; # IE 512 byte limit cure
		print "404 - File Not Found\n$supl"; 
		exit;
	} 
	
	
	# Other Errors
	print "Content-type: text/html\n\n";
	print qq|<h2>@{[&printlang("Error")]}</h2>|;
	print "<div id='notice_box'>";
	print "<p>$msg</p></div>";
	
	if ($dbh) { $dbh->disconnect; }
	exit unless ($supl eq "nonterminal");
}


sub show_environment {

	my $env_values;
	while (my($x,$y) = each %ENV) {
		$env_values.= "$x = $y \n";
	}
	return $env_values;


}

sub log_event {
	return;	
}

sub log_status {
	
	my ($dbh,$query,$logfile,$message) = @_;

	my $ltime = time;
	my $lcreator = $Person->{person_id} || 1;
	
						# Configure log entry
	my $lvals = {
		log_crdate =>$ltime,
		log_creator => $lcreator,
		log_title => $logfile,
		log_entry => $message
	};
		
	if ($message =~ /headers:/) {		# Add headers if they aren't already there, or
		return if (&db_locate($dbh,"log",{log_title=>$logfile,log_entry=>$message}));	
	}
	
						# Add log entry
	&db_insert($dbh,$query,"log",$lvals);

}

sub log_cron {
	
	my ($log) = @_;
	return unless ($Site->{cron});
	
											# Get the time
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	my @wdays = qw|Sunday Monday Tuesday Wednesday Thursday Friday Saturday|;
	my $weekday = @wdays[$wday]; 
	if ($min < 10) { $min = "0".$min; }
	if ($mday < 10) { $mday = "0".$mday; }	
	my $logtime="$mon/$mday $hour:$min ";
	
	# Print Cron Jobs Log
	
	unless ($log) { $log = $logtime . " No activities to report\n"; }
	else { $log = $logtime . $log; }
	my $cronfile = &get_cookie_base($Site->{st_url});
	$cronfile =~ s/\./_/g;
	my $cronlog = $Site->{data_dir} . $cronfile. "_cron.log";
#	open CRONLOG,">>$cronlog" or &send_email("stephen\@downes.ca","stephen\@downes.ca","Error Opening Cron Log File","Error opening Cron Logfile\n $cronfile: $!");
#	print CRONLOG $log  or &send_email("stephen\@downes.ca","stephen\@downes.ca","Error Printing to Cron Log","Error printing Cron Log $cronfile : $! \nLog: $log");
#	close CRONLOG;
	return 1;

}

sub log_view {
	my ($dbh,$query,$logfile,$format) = @_;	


						# Table View Defaults
	my $vars = $query->Vars;
	$logfile ||= $vars->{logfile};
	$format ||= $vars->{format};
	my $border = $vars->{border} || 1; 
	my $padding = $vars->{padding} || 3;
	my $spacing = $vars->{spacing} || 0;
	
	
	print "Content-type:text/html\n\n";
	print "Retrieving $logfile <br>";
	if ($logfile eq "cronlog") {
		my $cronfile = &get_cookie_base($Site->{st_url});
		$cronfile =~ s/\./_/g;
		my $cronlog = $Site->{data_dir} . $cronfile. "_cron.log";
		if ($vars->{format} eq "tail") {
			open my $pipe, "-|", "/usr/bin/tail", "-f", $cronlog 
				or die "could not start tail on SampleLog.log: $!";
			print while <$pipe>;
		}
		print "Opening $cronlog <br>";
		open CRONLOG,"$cronlog" or &error($dbh,"","","Error opening cron log: $!");
		while (<CRONLOG>) { print $_ . "<br>"; }
		close CRONLOG;
		exit;
	}
			


	
						# Retrieve Log
	my $lsql = qq|SELECT * FROM log WHERE log_title=?|;
	my $lsth = $dbh -> prepare($lsql);
	$lsth -> execute($logfile);
	
						# Process Data
	my $lcount; my $headers; my $body;
	while (my $logrow = $lsth -> fetchrow_hashref()) { 
		my $line = $logrow->{log_entry};
		if ($line =~ /headers:/) { $line =~ s/headers:/headers:date,/; } 
		else { 
			my $d = $logrow->{log_crdate};
			$d = &nice_date($d,"min");
			$d =~ s/,//g;
			$line = $d.",".$line; }
		if ($format eq "table") {
			$line =~ s|,|</td><td>|mig;
			$line = "<tr><td>".$line."</td></tr>";
		} elsif ($format eq "tsv") {
			$line =~ s|,|\t|g;
		}
		$line .= "\n";
		if ($line =~ /headers:/) {
			$line =~ s|headers:||;
			$headers = $line; 
		} else {
			$body .= $line;
		}
	}	
	$lsth->finish();	
						# Print Output
						
	if ($format eq "table") { print qq|<table border="$border" cellspacing="$spacing" cellpadding="$padding">|; }
	print $headers;
	print $body;
	if ($format eq "table") { print "</table>"; }
	exit;
}

sub log_reset {
	
	my ($dbh,$query,$logfile) = @_;		
	$logfile ||= $vars->{logfile};
	return unless ($logfile);
	my $sth = $dbh->prepare("DELETE FROM log WHERE log_title = ?");
	$sth->execute($logfile);
	print "Content-type:text/html\n\n";
	print "Log $logfile wiped clean<br>";
	exit;
	
}

sub show_status_message {

	my ($dbh,$query,$person,$msg,$supl) = @_;

    my $vars = ();
    if (ref $query eq "CGI") { $vars = $query->Vars; } else { return; }

	return if ($vars->{mode} eq "silent");

	print "Content-type: text/html; charset=utf-8\n\n";
	$Site->{header} =~ s/\Q[*Login Required\E*]/Login Required/g;
	print $Site->{header};
	print "<h2>Login Required</h2>";
	print "<p>$msg</p>";
	print $Site->{footer};
	my $adr = 'stephen@downes.ca';

#	&send_email($adr,$adr,
#		"Error on Website",
#		"Error message: $msg\nSupplementary:$supl\n\n");




	exit if ($dbh eq "nil");

	if ($dbh) { $dbh->disconnect; }
	exit;
}


# -------  Send Email ----------------------------------------------------------

sub send_email {




	my ($to,$from,$subj,$page,$ext) = @_;
	






use Email::Stuffer;
use Email::Sender::Transport::SMTP;


   my $page_text = "TEXT VERSION \n".$page;
   $page_text =~ s/<head(.*?)head>//sig;
   $page_text =~ s/<style(.*?)style>//sig;
   $page_text =~ s/\[(.*?)\]//sig;
   $page_text =~ s/<a(.*?)href="(.*?)"(.*?)>(.*?)<\/a>/$4 $2/sig;
   $page_text =~ s/<br\/>/\n/sig;
   $page_text =~ s/<\/p>/\n/sig;
   $page_text =~ s/<(.*?)>//sig;
   $page_text =~ s/  //sig;
   $page_text =~ s/\r//sig;
   $page_text =~ s/\n\n/\n/sig;


Email::Stuffer
    ->text_body($page_text)
    ->html_body($page)
    ->subject($subj)
    ->from($from)
    ->transport(Email::Sender::Transport::SMTP->new({
        host => 'www.downes.ca',
    }))
    ->to($to)
 
    ->send;






}


#--------------------------------------------------------
#
#	line_lengths($text)
#
#	For text-style output, converts the file to
#	line lengths of 60 characters
#
#--------------------------------------------------------

sub line_lengths {

	# Get text string from input
	my $pagetext = shift @_;

	# Initialize variables
	my $line; my $word; my $linelength;
	my $newline; my $newpage;
	$pagetext =~ s/\r//;

	my @linelist = split /\n/,$pagetext;

	foreach $line (@linelist) {
		$linelength=0; my $first = "yes";
		my @wordlist = split / /,$line;
		$newline = "\n  ";
		foreach $word (@wordlist) {
			my $wordlength = length($word) + 1;
			if ($first eq "yes") {
				$first = "no";
				$linelength = $wordlength;}
			else {
				if (($linelength + $wordlength) > 60) {
					$word = "\n  " . $word;
					$linelength = $wordlength;
				} else {
					$word = " " . $word;
					$linelength += $wordlength;
				}
			}
			$newline .= $word;
		}
		$newpage .= $newline;
	}
	$newpage =~ s/\n\s*\n\s*\n\s*\n/\n\n\n/g;
	return $newpage;
}



# -------  Mime Types ----------------------------------------------------------

# Returns a mime type based on extension of filename

sub mime_type {
	
	my ($url) = @_;
	
	my $mime_table = {
	      ai => "application/postscript",
	      aiff => "audio/x-aiff",
	      au => "audio/basic",
	      avi => "video/x-msvideo",
	      bck => "application/VMSBACKUP",
	      bin => "application/x-octetstream",
	      bleep => "application/bleeper",
	      class => "application/octet-stream",
	      com => "text/plain",
	      crt => "application/x-x509-ca-cert",
	      csh => "application/x-csh",
	      dat => "text/plain",
	      doc => "application/msword",
	      docx => "application/msword",
	      dot => "application/msword",
	      dvi => "application/x-dvi",
	      eps => "application/postscript",
	      exe => "application/octet-stream",
	      gif => "image/gif",
	      gtar => "application/x-gtar",
	      gz => "application/x-gzip",
	      hlp => "text/plain",
	      hqx => "application/mac-binhex40",
	      htm => "text/html",
	      html => "text/html",
	      htmlx => "text/html",
	      htx => "text/html",
	      imagemap => "application/imagemap",
	      jpe => "image/jpeg",
	      jpeg => "image/jpeg",
	      jpg => "image/jpeg",
	      mcd => "application/mathcad",
	      mid => "audio/midi",
	      midi => "audio/midi",
	      mov => "video/quicktime",
	      movie => "video/x-sgi-movie",
		mp3 => "audio/mpeg",
	      mpeg => "video/mpeg",
	      mpe => "video/mpeg",
	      mpg => "video/mpeg",
	      pdf => "application/pdf",
	      png => "image/png",
	      ppt => "application/vnd.ms-powerpoint",
	      pptx => "application/vnd.ms-powerpoint",
	      ps => "application/postscript",
	      'ps-z' => "application/postscript",
	      qt => "video/quicktime",
	      rtf => "application/rtf",
	      rtx => "text/richtext",
	      sh => "application/x-sh",
	      sit => "application/x-stuffit",
	      tar => "application/x-tar",
	      tif => "image/tiff",
	      tiff => "image/tiff",
	      txt => "text/plain",
	      ua => "audio/basic",
	      wav => "audio/x-wav",
	      xls => "application/vnd.ms-excel",
	      xbm => "image/x-xbitmap'",
	      zip => "application/zip"
	     };	


	my ($dirname,$atts) = split /\?/,$url;
	my @slices = split /\//,$dirname;
	my $filename = pop @slices;	
	my @harray = split /\./,$filename; 
	my $ext = pop @harray; 
	$ext = lc($ext);
	my $mimetype = $mime_table->{$ext};	
	unless ($mimetype) { $mimetype = "unknown"; }
	
	return $mimetype;
	
}

# -------  Conditional print -------------------------------------------------------

sub diag {
	
	# $diag_level set at top
	
	my ($score,$output) = @_;

	if ($score < $Site->{diag_level}) { 
		print $output; 
	}

	return;
}

# -------  Index Of ------------------------------------------------------------

#   Checks for membership of variable in an array

sub index_of {


	my ($item,$array) = @_;			
	my $index_count = 0;			
	foreach my $i (@$array) {		
		if ($item eq $i) { return $index_count; }
		$index_count++;
	}
	return "-1";
}


# -------  Base URL ------------------------------------------------------------

sub site_url {

	my ($url) = @_;

	my @urlarr = split "/",$url;
	return $urlarr[2];

}








# -------   Get Wikipedia Page Content ----------------------------------------------

sub wikipedia {

	my ($dbh,$term) = @_;
	
	use constant WIKIPEDIA_URL =>'http://%s.wikipedia.org/w/index.php?title=%s';
	use CGI qw( escape );

	return unless ($term);

 	my $browser = LWP::UserAgent->new();
	my $language = "en";
	my $string = escape($term);

	$browser->agent( 'Edu_RES' );
	my $src = sprintf( WIKIPEDIA_URL, $language, $string );
	my $response = $browser->get($src);

	if ( $response->is_success() ) {
		my $article = $response->content();
		$article =~ s/(.*?)<body(.*?)>(.*?)<\/body>(.*?)/$3/si;
		$article =~ s|/wiki/|http://en.wikipedia.org/wiki/|sig;
		$article =~ s|<script(.*?)>(.*?)</script>||sig;
		$article =~ s/<div(.*?)>//sig;
		$article =~ s|</div>||sig;
		$article = qq|<div id="wikipedia">\n$article\n</div>|;
	
		return $article;
	} else {
		return "Unable to connect to Wikipedia";
	}

        # look for a wikipedia style redirect and process if necessary
        # return $self->search($1) if $entry->text() =~ /^#REDIRECT (.*)/i;

}


# -------  Process Wikipedia  ----------------------------------------------------------


sub process_wikipedia {

	my ($content) = @_;
	
	my $output = "";
	my @graphs = split /\n/,$content;
	foreach my $graph (@graphs) {
		next unless ($graph);
		$output .= "<p>".$graph."</p>";
	}

	return $output;
}

# -------  Wikipedia Entry ----------------------------------------------------------

sub wikipedia_entry {

	my ($dbh,$text_ptr) = @_;

	while ($$text_ptr =~ /<WIKIPEDIA (.*?)>/sg) {

		my $autotext = $1;
		my $term = $autotext;
		my $entry = &wikipedia($dbh,$term);
		$$text_ptr =~ s/<WIKIPEDIA \Q$autotext\>/$entry/sig;
	}

}



# Initialize Function header and footer

sub iheader {
	my ($page) = @_;
	
	return qq|
		<html><head>
		<title>gRSShopper Initialization - $page</title>
		</head><body>
		<img src="http://demo.downes.ca/images/grsshopper1.png">
		<h2 style="margin-left:100px;">gRSShopper Initialization - $page</h2>
		
	|;
	
	
}

sub ifooter {
	
		return qq|</body></html>|;
	
}


# ---------------------------------------------------------------------------------------------------
#
#                        RECORD SUBMIT
#
#    One Submit to Rule them All
#
#    Record data: $vars
#    Person data: $Person
#
# ---------------------------------------------------------------------------------------------------

sub record_submit {
	
	my ($dbh,$vars,$return) = @_;

	$vars->{force} = "yes";


	&error($dbh,$query,"api","Database not initialized") unless ($dbh);		# Set database
	my $table = $vars->{db} || &error($dbh,$query,"api","Table not specified");	# Set table

	&record_sanitize_input($vars);							# Sanitize input		
	&record_anti_spam($dbh,$table,$vars);						# No Spam!

	&record_autoformat($table,$vars);						# Autoformat text-based input	
	&record_convert_dates($table,$vars);						# Convert input dates to epoch
	
	my $record = &record_load($dbh,$table,$vars);					# Load or create new record
	my $id = &record_save($dbh,$record,$table,$vars) || 		
		&error($dbh,$query,"api","Error saving record");			# Save record
		
	my $new_record = &record_verify($dbh,$table,$id);				# Verify and return saved record
	
	&record_graph($dbh,$vars,$table,$new_record);					# Create graph of associated entities

											# Remove Cache 
#	&db_cache_remove($dbh,$table,$id);						# (So people can see their updates)
#	&db_cache_remove($dbh,$table,$vars->{$table."_thread"});

	if ($return) { return $record->{$table."_".$return}; }				# Quick return without preview
	
	$preview .= &record_preview($dbh,$table,$id,$vars);				# Generate Preview version

	$vars->{msg} .= &record_notifications($dbh,$vars,$table,$record,$preview);			# Send email notifications to admin
	
	return ($id,$preview);								# Full return with preview
}


# -------  Graph Record ---------------------------------------------
#
#   This function associates a just-saved record with records in other tables 
#   Values for these other records are submitted in $vars and always have the prefix 'keyname_'
#   For example, a field named 'keyname_author' will refer to the name of an author in the 'author' table
#   The function produces a record in the graph table  
#   It will also create a new record in the other table, if necessary
#   Be sure to set $new_record->{type} before sending $new_record to this function (where 'type' = new_record's table)
# 
sub record_graph {
	
	my ($dbh,$vars,$table,$new_record) = @_;
	
	# return unless ($vars->{$table."_status"} eq "Final");				# Can be commented out, but really
											# graphs entries shouldn't be created
											# until the user commits
	$new_record->{type} ||= $table;	# Just in case					
								
	while (my ($vkey,$vval) = each %$vars) {	
		
		if ($vkey =~ /^keyname_(.*?)$/) {				# Eg. 'keyname_author'
			my $keytable = $1; 					# This is a record in another table associated with this one Eg. 'author'
			my @keynamelist = parse_csandv($vval);  		# Find eg. authors, split: first, second and third  (but leave values in quotes intact)
			foreach my $keyname (@keynamelist) {			# For each., eg. author...
				$keyname =~ s/^ | $//g;	 			# Trim leading, trailing white space

				my $keyfield = &get_key_namefield($keytable);	# Are we looking for _name, _title ...?
				my $keyrecord = &db_get_record($dbh,$keytable,{$keyfield=>$keyname});	# can we find a record with that name or title?
				
				unless ($keyrecord) {				# Record wasn't found, create a new record, eg., a new 'author'
					$keyrecord = {
						$keytable."_creator"=>$Person->{person_id},
						$keytable."_crdate"=>time,
						$keyfield=>$keyname
					};
					$keyrecord->{$keytable."_id"} = &db_insert($dbh,$query,$keytable,$keyrecord);
					&error($dbh,"","api","New $keytable crash and burn") unless ($keyrecord->{$keytable."_id"});
				}	
				$keyrecord->{type}=$keytable;	
								# Create Graph Record
				if ($keytable eq "author") { $keytype = "by"; }						
				else { $keytype = "in"; }
				&save_graph($keytype,$new_record,$keyrecord);					
			}
		}						 
	}	
} 

# -------  Sanitize ------------------------------------------------------
#
# Clean hashes of programs, injection code, etc
#  
sub record_sanitize_input {
  	

	my ($vars) = @_;

	while (my ($vkey,$vval) = each %$vars) {

		$vars->{$vkey} =~ s/#!//g;				# No programs!
		$vars->{$vkey} =~ s/\x{201c}/"/g;	# "
		$vars->{$vkey} =~ s/\x{201d}/"/g;	# "
		$vars->{$vkey} =~ s/\x{2014}/-/g;	# '
		$vars->{$vkey} =~ s/\x{2018}/'/g;	# '
		$vars->{$vkey} =~ s/\x{2019}/'/g;	# '
		$vars->{$vkey} =~ s/\x{2026}/.../g;	# ...
		$vars->{$vkey} =~ s/'/&apos;/g;	#     No SQL injections
	
		# If it's not from a JS editor, auto-insert spaces
		unless ($vars->{$vkey} =~ /^<p>/i) { 
			$vars->{$vkey} =~ s/\r//g;
			$vars->{$vkey} =~ s/\n/\n\n/g;   # Adds an extra LF for single returns - converts MS Doc paras to extra LFs
			$vars->{$vkey} =~ s/\n\n\n/\n\n/g; $vars->{$vkey} =~ s/\n/<br\/>/g; 
		}
	}
	
	
	return if ($Person->{person_status} eq "Admin");
	
	$vars->{$vkey} =~ s/<(\/|)(scr|if|ob|e|t)(.*?)>//sig;	# No scripts, iframes, embeds, tables

	return if ($Person->{person_status} eq "Registered");
	
	$vars->{$vkey} =~ s/<(\/|)(a|img)(.*?)>//sig;	# No links, images
	
}


# -------  Anti-Spam ------------------------------------------------------
#
# Like the title says
# 

sub record_anti_spam {		# Checks input for spam content and kills on contact

	my ($dbh,$table,$vars) = @_;
	
	# die "Commenting disabled due to persistent and annoying spammers." unless $Person->{person_status} eq "admin";
	
	
								# Define test text

	my $d = $table."_description";
	my $t = $table."_title";
	my $c = $table."_content";
	my $test_text = $vars->{$d}.$vars->{$t}.$vars->{$c};
	my $sem_text = $vars->{$d}.$vars->{$c};

								# Require Users to Have Remote Addr
								# if they fail access permissions
	unless (&is_viewable("spam","remote_addr")) {
		unless ($ENV{'REMOTE_ADDR'}) {
			&error($dbh,$query,"api","Who are you?");
		}
	}

								# Require Comment Code Match
#	unless (&is_viewable("spam","code_match")) {
#
#		unless (&check_code($vars->{post_thread},$vars->{code}) || $table ne "post" || $vars->{code} eq "override") {
#			&error($dbh,$query,"api",qq|Spam code mismatch - $vars->{post_thread},$vars->{code}  - (used to prevent robots from 
#			submitting comments). Try this: copy your comment (highlight and ctl/c), 
#			reload the web page ( do a shift-reload #for force a full reload), 
#			paste the comment into the form, and submit again.|,"CONTENT: $test_text");
#		}
#	}
	
								# Ban multiple links
	unless (&is_viewable("spam","many_links")) {
		my $c; while ($test_text =~ /http/ig) { $c++ }
		my $d; while ($test_text =~ /url/ig) { $d++ }
		if (($c > 5)||($d > 15)) {
			&error($dbh,$query,"api","This post is link spam. Go away. (Too many links)","CONTENT: $test_text");
		}
	}
	
								# Ban scripts
	unless (&is_viewable("spam","scripts")) {
		if ($test_text =~ /<(.*?)(script|embed|object)(.*?)>/i) {
			&error($dbh,$query,"api","No scripts in the comments please.","CONTENT: $test_text");
		}	
	}

								# Ban links
	unless (&is_viewable("spam","links")) {
		if ($test_text =~ /<a(.*?)>/i) {
			&error($dbh,$query,"api","No links in the comments please.","CONTENT: $test_text");
		}	
	}
	
	
								# Ban words
	unless (&is_viewable("spam","links")) {
		if ($test_text =~ /(You are invited|viagra|areaseo|carisoprodol|betting|pharmacy|poker|holdem|casino|roulette|phentermine|ringtone|insurance|diet|ultram| pills| loans|tramadol|cialis|penis|handbag| shit | cock | fuck | fucker | cunt | motherfucker | ass )/i) {
			&error($dbh,$query,"api","Spam in the text.","CONTENT: $test_text");
		}	
	}


								# Ban short comments
	unless (&is_viewable("spam","length")) {
		my $test_text_length = length ($test_text); 
		if ($test_text_length < 150) {
			&error($dbh,$query,"api","Comments must be long enough to mean something.","CONTENT: $test_text");
		}	
	}


								# Semantic Test
								# applied to post only
								
	unless (&is_viewable("spam","semantic")) {

		unless ($sem_text =~ / and | or | but | the | is | If | you | my | me | he | she | was | will | all | some | I /i) {
			if ($table eq "post") {
				&error($dbh,$query,"api","This content makes no sense and has thus been classified as spam","CONTENT: $test_text");
			}
		}
	}

					

	# Filter by IP
	unless (&is_viewable("spam","ip")) {
		if (&db_locate($dbh,"banned_sites",{banned_sites_ip => $ENV{'REMOTE_ADDR'}})) {
			&error($dbh,$query,"api","Your IP address has been classified as a spammer.");
		}
	}

	return 1;
}


# -------  Convert Dates ------------------------------------------------------
#
#   All dates input are turned to epoch
#   That's just how I roll
#
#  

sub record_convert_dates {

	my ($table,$vars) = @_;
	
											#Set default timezones, durations
	$vars->{$table."_timezone"} ||= $Site->{st_timezone} || "America/Toronto";	# Allows input to specify timezone						
	unless ($vars->{$table."_duration"}) {$vars->{$table."_duration"} = "1:00";}	
	unless ($vars->{$table."_duration"} =~ /:/) {$vars->{$table."_duration"} .= ":00";}										
	
										# Convert datepicker input to epoch
	$vars->{$table."_start"} = &datepicker_to_epoch($vars->{$table."_start"},$vars->{$table."_timezone"});							
	$vars->{$table."_finish"} = &datepicker_to_epoch($vars->{$table."_finish"},$vars->{$table."_timezone"});
	
}

# -------  Autoformat ------------------------------------------------------
#
#   Autoformatting for comment-form based input
#
#  

sub record_autoformat {

	my ($table,$vars) = @_;

	return if ($vars->{autoformat} eq "off");				# May be turned off from form
	foreach (qw(description content)) {					
		my $element = $table."_".$_;
		

										
		unless ($vars->{$element} =~ /^<p|^<div/i) { 				# Unless from text-fromatter (eg TinyMCE)...
			
			$vars->{$element} =~ s/\n/<br\/><br\/>/g; 			# Auto line feed
			$vars->{$element} =~ s/<br\/><br\/><br\/>/<br\/><br\/>/g;	# (Double to enable seamless MS-Word paste)
										
			$vars->{$element} =~ s/\s\*(.*?)\*(\s|\.|,|;|:)/ <b>$1<\/b> /g;	# Auto bold			
										
			$vars->{$element} =~ s/\s_(.*?)_(\s|\.|,|;|:)/ <i>$1<\/i> /g;	# Auto italics
		}
							
	}

}

# -------  Load Record ------------------------------------------------------
#
#   Loads the new record into memory, combining existing record information with new form submission info
#
#  
sub record_load {
	
	my ($dbh,$table,$vars) = @_;
	my $record;
#identifier
	my $id = &db_locate($dbh,$table,{$table."_identifier"=>$vars->{identifier}}) || $vars->{id} || "new";								
	&record_defaults($table,$vars);
	
	if ($id =~ /new/i) { 					# Create New Record
	
	
		&error($dbh,$query,"api","Permission denied to create $table") unless (&is_allowed("create",$table)); 
		
		&error($dbh,$query,"api","This $table already exists, you can't recreate it") 
			unless (&record_unique($dbh,$table,$vars)); 		
		$vars->{$table."_id"} = "new";
		$record = gRSShopper::Record->new({tag=>$table});
		&record_creation_info($table,$vars);							# Set creation info
		
	} else { 						# Load Existing Record
		
		$record = &db_get_record($dbh,$table,{$table."_id"=>$id});
		&error($dbh,$query,"api","Record ID $id not found") unless ($record->{$table."_id"}); 
		$vars->{$table."_id"} = $record->{$table."_id"};
		$vars->{id} = $record->{$table."_id"};
		&error($dbh,$query,"api","Permission denied to edit $table record $id") unless (&is_allowed("edit",$table,$record)); 
		&record_update_info($table,$vars);							# Set update info
	}
	
								# Load vars into Record and return record
								# Note: record is NOT saved at this point, only loaded

	while (my($vx,$vy) = each %$vars) { $record->{$vx} = $vy;  }
	
	return $record;
}




# -------  Unique Record ------------------------------------------------------
#
# Is this a unique record? Returns 1 if yes, 0 if no
#

sub record_unique {
	
	my ($dbh,$table,$vars) = @_;

	if ($table eq "event") {
		return 0 if (&db_locate($dbh,$table,{event_title=>$vars->{event_title},event_start=>$vars->{event_start}})); 
	} elsif ($table eq "post" && $vars->{post_type} eq "link") {
		return 0 if (&db_locate($dbh,$table,{post_link=>$vars->{post_link}})); 	
	}
	
	return 1;
	
	
}


# -------  Save Record ------------------------------------------------------
#
# Save record (*update or create) and return record id
#
 
sub record_save {
	
	my ($dbh,$record,$table,$vars) = @_;
	my $record_id;						# ID of saved record
		
	if ($record->{$table."_id"} && $record->{$table."_id"} ne "new") {
		$record_id = &db_update($dbh,$table,$vars,$record->{$table."_id"});	
		$vars->{msg} .= "Updated $table ($record_id)";
	} else {
		$record_id = &db_insert($dbh,$query,$table,$vars);
		$vars->{id} = $record_id;
		$record->{$table."_id"} = $record_id;	
		#$vars->{msg} .= "Created new $table ($record_id)";			
	}
	return $record_id;
} 
 
 
 
# -------  Verify ------------------------------------------------------
#
# Returns newly saved record with type info for further processing
# 	
 
sub record_verify {
	
	my ($dbh,$table,$id) = @_;
	my $new_record=&db_get_record($dbh,$table,{$table.+"_id"=>$id});
	&error($dbh,"","api","New $table record not created properly.") unless ($new_record);
	$new_record->{type} = $table;
} 

# -------  Creation Info ------------------------------------------------------
#
# Set record creator crdate, creation IP and identifier
#
 
sub record_creation_info {
  	
	my ($table,$vars) = @_;
	
	$vars->{$table."_creator"} = $Person->{person_id};
	
	$vars->{$table."_crdate"} = time;
	$vars->{$table."_crip"} = $ENV{'REMOTE_ADDR'};		
	$vars->{$table."_identifier"} = $vars->{identifier};

  	
}


 
# -------  Update Info ------------------------------------------------------
#
# Set record creator crdate, creation IP and identifier
#
 
sub record_update_info {
  	
	my ($table,$vars) = @_;
	
	$vars->{$table."_updater"} = $Person->{person_id};
	$vars->{$table."_updated"} = time;
	$vars->{$table."_upip"} = $ENV{'REMOTE_ADDR'};		
  	
}





 
# -------  Defaults ------------------------------------------------------
#
# Set record defaults
#
 
sub record_defaults {
  	
	my ($table,$vars) = @_;
	
								# Status  (Need some work to standardize on this)
	$vars->{$table."_status"} ||= "None";
	if ($vars->{pushbutton} eq "preview") { $vars->{$table."_status"} = "Draft"; }
	elsif ($vars->{pushbutton} eq "done") { $vars->{$table."_status"} = "Final"; }	
	if ($Person->{person_status} eq "Admin") { 
		if ($vars->{pushbutton} eq "rejected") { $vars->{$table."_status"} = "Rejected"; }
		else { $vars->{$table."_status"} = "Approved"; }
	}	
	
								# Type
								
	if ($vars->{newautoblog}) { $vars->{post_type} = "link"; }				# Autoblog, first input, default to Link
	unless ($Person->{person_status} eq "admin") { $vars->{post_type} ||= "comment"; }	# Default to comment						
	
								# Source
	if ($vars->{newautoblog}) { $vars->{$table."_source"} = "autoblog"; }
	else  { $vars->{$table."_source"} = "page"; }
	
								# Title, Description, Dates
								
	&error($dbh,$query,"api",ucfirst($table)." requires a title") unless ($vars->{$table."_title"});
	&error($dbh,$query,"api",ucfirst($table)." requires a description") unless ($table eq "feed" || $vars->{$table."_description"});
	if ($table eq "feed") { &error($dbh,$query,"api",ucfirst($table)." requires a link") unless ($vars->{$table."_link"}); }
	if ($table eq "event") {
		&error($dbh,$query,"api",ucfirst($table)." requires a start time") unless ($vars->{$table."_start"});
	} 
	
								# Link
								
	if ($vars->{post_type} eq "link") { unless ($vars->{post_link}) { &error($dbh,$query,"api","Link post requires a link"); } }	
	unless ($vars->{$table."_link"}	=~ /http/) { $vars->{$table."_link"} = "http://".$vars->{$table."_link"}; }	
	unless ($vars->{$table."_html"}	=~ /http/) { $vars->{$table."_html"} = "http://".$vars->{$table."_html"}; }					
	
								# Author
	$vars->{$table."_author"} ||= $Person->{person_name} || $Person->{person_title} || $Site->{st_anon} || "Any Mouse";
  	
}

# -------  Record Preview ------------------------------------------------------
#
# 	Return a preview of our newly minted record
#

sub record_preview {
	
	my ($dbh,$table,$id,$vars) = @_;
	
	my $preview = &db_get_record($dbh,$table,{$table."_id" => $id});			# Get record
	
	
	

	my $wp = {}; 									# Format Record
	$vars->{comments} = "no";
	$wp->{table} = $table;
	$wp->{page_content} = &format_record($dbh,$query,$table,"preview",$preview);
	&format_content($dbh,$query,$options,$wp);
	
	my $hh; 
	if ($table eq "event") { $hh = qq|<section>@{[&printlang("Start")]} <h3>|.&nice_date($preview->{$table."_start"}) ."</h3>"; }
	elsif ($table eq "post") { $hh = qq|<h3>@{[&printlang("Preview")]}</h3><p>@{[&printlang("Continue editing")]}</p>|; }
	
	
	
	
											# Return text
	return $hh.
		qq|$wp->{page_content}|.
		qq|</section>|;	
	
	
	
	
}


sub record_notifications {
	
	my ($dbh,$vars,$table,$record,$preview) = @_;
	
#	$Site->{st_crea} = "stephen\@downes.ca";
		
	# If User is done editing - status = "Final" (or feed)
	
	if ($record->{$table."_status"} eq "Final" || $table eq "feed") {	
		
		
		if ($Person->{person_status} eq "admin") {
			$vars->{msg} = qq|<p class="notice">@{[&printlang("Automatic approval",&printlang($table))]} </p>|;
			return;			
		}
		
		
		
		# Compose notification message	
		
		my $readername = $Person->{person_name} || $Person->{person_title};
		my $mailtext = qq|
			@{[&printlang("Dear")]} <name> <email>,<br><br>	
			@{[&printlang("New submitted approval needed",&printlang($table),$Site->{st_name},$readername)]}<br/><br/>
			$preview<br/><br/>
			[<a href="$Site->{st_cgi}admin.cgi?$table=$record->{$table."_id"}&action=approve&from=email">Approve</a>]
			[<a href="$Site->{st_cgi}admin.cgi?$table=$record->{$table."_id"}&action=edit&from=email">Edit</a>]
			[<a href="$Site->{st_cgi}admin.cgi?$table=$record->{$table."_id"}&action=reject&from=email">Reject</a>]
			[<a href="$Site->{st_cgi}admin.cgi?$table=$record->{$table."_id"}&action=delete&from=email">Delete</a>]
			[<a href="$Site->{st_cgi}admin.cgi?$table=$record->{$table."_id"}&action=spam&from=email">Spam</a>]</p>|;

		
	        my $subject = &printlang("New submitted",&printlang($table),$record->{$table."_id"},$Site->{st_name});
	        &send_notifications($dbh,$vars,$table,$subject,$mailtext);
 
	        my $return_message .= qq|<p class="notice">@{[&printlang("Has been submitted",&printlang($table),$Site->{st_name})]}|;
	        if ($table eq "feed") { $return_message .=  &printlang("Check feed status",$Site->{st_cgi}."login.cgi?action=Options"); }
	        $return_message .= "</p>";
			
		return $return_message;
	} else {

		return;
	}
	
	
	# Not working yet, temporary storage of legacy code
	if ($record->{$table."_status"} eq "Approved") {		
	
	
					# Update email notification list
	if ($vars->{anon_email}) {						# Detect anonymous email
		$vars->{post_email_checked} = "checked";
		$Person->{person_email} = $vars->{anon_email};
	}
				
	if ($vars->{post_email_checked} eq "checked") {			
		&add_to_notify_list($dbh,$Person->{person_email},$vars->{$fields->{thread}});
	} else {
		&del_from_notify_list($dbh,$Person->{person_email},$vars->{$fields->{thread}});	
	}	
	
	
					# Get Email Addresses
		my $elist = &db_get_single_value($dbh,"post","post_emails",$vars->{$fields->{thread}});

		my @earray = split ",",$elist;
	
		
					# Send Emails
					# To Email List
		my $adr = $Site->{em_discussion};
		my $eml = "";
		foreach my $e (@earray) {
			my $emailcontent = $wp->{page_content};
			$emailcontent =~ s/<SUBSCRIBEE>/$e/g;
			$eml .= $e." <br/>\n";
			last if ($e eq "none");
			&send_email($e,$adr,$ttitle,$emailcontent,"htm");
		}	
	}
}


sub send_notifications {
	
	my ($dbh,$vars,$table,$subject,$mailtext) = @_;
	
	
	# List who gets notified?
	
	my $req = lc($Site->{"approve_".$table});
	my @rlist = db_get_record_list($dbh,"person",{person_status=>$req});
	my @alist = db_get_record_list($dbh,"person",{person_status=>'admin'});	
	my @list = arrays("union",@rlist,@alist);
	
	# Send each one the message
	
	foreach my $approver (@list) {
			
		my $apers = &db_get_record($dbh,"person",{person_id=>$approver});
		my $admintext = $mailtext;
		$admintext =~ s/<name>/$apers->{person_name}/g; 
		$admintext =~ s/<email>/$apers->{person_email}/g; 
		&send_email($apers->{person_email},$Site->{st_pub},$subject,$admintext,"htm");			 
		
	}	
	
	
	
}

#----------------------------------------------------------------------------------------------------------
#
#                                               PACKAGES
#
#----------------------------------------------------------------------------------------------------------

package gRSShopper::Temp;

   use strict;
  use warnings;
  our $VERSION = "1.00";
 

  sub new {
  	
  	my($class, $context, $args) = @_;
   	my $self = bless({}, $class);
	
   	$self->{context} = $context;
   	while (my ($ax,$ay) = each %$args) {
		$self->{$ax} = $ay;
   	}
   	
  	$self->{process} = time;					# Make process name
  	$self->{site_url} = $self->home();
 	
 	return $self;
  }
  
 1;
#----------------------------------------------------------------------------------------------------------
#
#                                             gRSShopper::Site
#
#----------------------------------------------------------------------------------------------------------


  package gRSShopper::Site;

  # $Site = gRSShopper::Site->new();
  
   
  use strict;
  use warnings;
  our $VERSION = "1.00";
 

  sub new {
  	
  	my($class, $args) = @_;								# Load Site object
   	my $self = bless({}, $class);

   	

   	while (my ($ax,$ay) = each %$args) {						# Assign default values when Site created
		$self->{$ax} = $ay;
   	}
   	
  	$self->{process} = time;							# Make process name


  	$self->__home();								# Define Site home URL from $ENV data
											# (Used to find database info in multisite.txt)



	unless ($self->{no_db}) { 
		
		$self->__dbinfo(); 								# Find db info from multisite.txt

	}				
 	
 	return $self;
  }





#  db_info - gets the database info for the site in multisite mode
#          - requires as input the 'base url' as determiend by $self->home()
#          - data is in cgi-bin/data/multisite.txt   (this can be changed at the top of this file)
#          - format:   site_url\tdatabase name\tdatabase host\tdatabase user\tdatabase user password\n
#
 
  sub __dbinfo {
  
 	
  	my ($self,$args) = @_;

											# Open the multisite configuration file,
											# Initialize if file can't be found or opened
  	my $data_file = $self->{data_dir} . "multisite.txt";							
	open IN,"$data_file" or $self->__initialize("file");

	my $url_located = 0;							
  	while (<IN>) {
		my $line = $_; $line =~ s/(\s|\r|\n)$//g;			# Find the line beginning with site URL
		if ($line =~ /^$self->{st_home}/) {				# and read site database information from it
			( $self->{st_home},
			  $self->{database}->{name},
			  $self->{database}->{loc},
			  $self->{database}->{usr},
			  $self->{database}->{pwd},
			  $self->{st_lang},
			  $self->{st_urlf},
			  $self->{st_cgif} ) = split "\t",$line;
			$url_located = 1;
			last;
		}
	}
	close IN;

											# Initialize if line beginning with site URL can't be found

	unless ($url_located) { $self->__initialize("url"); }

	$self->{st_lang}  ||= 'en';						# Assign or override defaults
	$self->{st_urlf}  ||= '/var/www/html';
	$self->{st_cgif}  ||= '/var/www/cgi-bin/';	
	return;
  }


  

#  __home()  - determines a 'site url' given a script request
#          - used to determine which database to use for multisite requests
#  Deduces the home URL of the website the script is managing
#  This information is used to find the name of the site configuration script
#  The Site Home is typically the domain name, eg. www.downes.ca
#  This is the case if the admin script is in http://www.downes.ca/cgi-bin/admin.cgi
#  Home URL subdirectories may also be used, if a subdirectory URL is called
#  Eg. site home is www.downes.ca_subdomain if admin script is in 
#  http://www.downes.ca/subdomain/cgi-bin/admin.cgi
#  If the 'cgi-bin' dir is not use, the Site home will be wherever the
#  admin.cgi script is located eg. http://www.downes.ca/wherever/admin.cgi will
#  have a home of www.downes.ca/wherever
 
 # -------   Get Site Home ------------------------------------------------------
#
#  Deduces the home URL of the website the script is managing
#  This information is used to find the name of the site configuration script
#  The Site Home is typically the domain name, eg. www.downes.ca
#  This is the case if the admin script is in http://www.downes.ca/cgi-bin/admin.cgi
#  Home URL subdirectories may also be used, if a subdirectory URL is called
#  Eg. site home is www.downes.ca_subdomain if admin script is in 
#  http://www.downes.ca/subdomain/cgi-bin/admin.cgi
#  If the 'cgi-bib' dir is not use, the Site home will be wherever the
#  admin.cgi script is located eg. http://www.downes.ca/wherever/admin.cgi will
#  have a home of www.downes.ca/wherever


  sub __home {
  	
  	my($self, $args) = @_;
  	
  	
  	
	
  	my $home;
  	my $ht = "http://";
  	my $numArgs = $#ARGV + 1;
  	if ($ENV{'SCRIPT_URI'} || $ENV{'HTTP_HOST'}) {
  				
											# Script 
    		$self->{script} = $ENV{'SCRIPT_URI'}; 					#    - eg. http://www.downes.ca/cgi-bin/admin.cgi
    		unless ($self->{script}) { die "Cannot determine website script."; }	#    - Failure?
  		if ($self->{script} =~ /https:/) {				#    - Set protocol
			$ht = "https://"; } else { $ht = "http://"; }
		
											# Home
  		$self->{st_home} = $ENV{'HTTP_HOST'} || $ENV{'SERVER_NAME'};		#    - eg. www.downes.ca
  		unless ($self->{st_home}) { die "Cannot determine website home."; }	#    - Failure?
  
		
	} elsif ($numArgs > 1) {							# Home from Cron request
		$self->{st_home} = $ARGV[0];   
		unless ($self->{st_home}) { die "Cannot determine website home in cron."; }        			

	} else {
		die "Cannot determine website home in ENV or cron.";
	}
	
	$self->{co_host} = $self->{st_home};						# Set cookie host 		
 	$self->{st_url} = $ht.$self->{st_home}."/";					# Set base URL
	$self->{st_cgi} = $self->{st_url}."cgi-bin/";					# Set base URL 	
	
	
  }

  sub __initialize {

  	my ($self,$cmd) = @_;

	unless ($ENV{'SCRIPT_NAME'} =~ /admin/) { $self->__site_maintenance($self->{st_home}); }
	if ($cmd) {
		print "Content-type: text/html\n";
		print "Location:initialize.cgi?action=".$cmd."\n\n";
		exit;
	}
	die "Unexplained failure to initialize.";

  }


  #  Multisite Form 
  #
  #  Form to input values for database access
  #
  
  sub __multisite_form {

  	my ($self,$cause) = @_;					# Create or update database information


		print "Content-type: text/html\n\n";
		print qq|
			Please enter database information for $self->{st_home} 
			<br>
			Please provide database information in the form below:
			<form action="initialize.cgi" method="post">
			<br><table cellspacing=1 cellpadding=2>
			<input type="hidden" name="st_home" value="$self->{st_home}">
			<input type="hidden" name="cause" value="$cause">
			<tr><td align="right">Database Name</td><td><input type="text" name="db_name" value="$self->{database}->{name}"></td></tr>
			<tr><td align="right">Database Location</td><td><input type="text" name="db_loc" value="$self->{database}->{loc}"></td></tr>
			<tr><td align="right">Database Username</td><td><input type="text" name="db_usr" value="$self->{database}->{usr}"></td></tr>
			<tr><td align="right">Database Password</td><td><input type="password" name="db_pwd" value="$self->{database}->{pwd}"></td></tr>
			<tr><td></td><td><input type="submit" name="action" value="Initialize Site"></td></tr></table><br/><br/>Context: $cause<p>
			<a href="admin.cgi">Return to Admin</a>|;
 
 
  }


    sub __initialize_site {
    	
    	my ($self,$vars) = @_;	
    	
											# Open the multisite configuration file,
											# Initialize if file can't be found or opened
  	my $data_file = $self->{data_dir} . "multisite.txt";			
  	my $output = "";
  					
	if (-e $data_file) {								# If the multisite configuration file exists
		open IN,"$data_file" or die "Can't open $data_file to read";		#    open it

		my $url_located = 0;							
		while (<IN>) {								#    read each line
			my $line = $_; 
			next if ($line =~ /^$self->{st_home}/);				#    if it's the current site, skip
			$output .= $line."\n";						#    otherwise write data to output
		}
		close IN;
		
    	}	
    	
											#    write current site data to output
	my $new_line = qq|$self->{st_home}\t$vars->{db_name}\t$vars->{db_loc}\t$vars->{db_usr}\t$vars->{db_pwd}| or die "Cannot write to $data_file";
	$output .= $new_line;
    				
	open OUT,">$data_file" or die "Cannot open $data_file for append";		# Save output
	print OUT $output;
	close OUT;
	
	$self->__dbinfo();
	$self->__multisite_form("Updated");						# Show the form again
    	
    
  	
    }
    
    
  # Create database information  
  
  sub __append_site {
  	
  	my ($self,$vars) = @_;								

  											# Open the multisite configuration file,
											# Initialize if file can't be found or opened
											


 
 
  }
  
  sub __update_site {
    	
    	
    	
  }
  
  
  sub __site_maintenance {

  	my ($self,$home) = @_;
	print "Content-type: text/html\n\n";
	print qq|
		Welcome to $home<br> 
		<br>
		The website is currently down for maintenance.|;
	exit;
  }
		
 
 
 
   #----------------------------------------------------------------------------------------------------------
   
   # $Site is loaded with site configuration variables at the beginning of each session
   # This function updates those variables in the site configuration table
   # Input in the form { name => value }  which are stored as config_name and config_value in the config table
 
   sub update_config {
   	
   	my ($self,$dbh,$data) = @_;
  print "Content-type: text/html\n\n";
  print "Updating config:   	";
  
	# Update Config Table
	while (my ($vx,$vy) = each %$data) {
print "$vx $vy <br>";
		my $sth; my $sql;
		if ($self->{$vx}) {	# Existing
		
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
		$self->{msg} .= "$vx has been set to $vy <br/>";
	}




	# Reload Site Data
	my $sth = $dbh -> prepare("SELECT * FROM config"); $sth -> execute();
	while (my $c = $sth -> fetchrow_hashref()) { $self->{$c->{config_noun}} = $c->{config_value}; }
	$sth->finish();   	
     	
   	
   	
   }
#----------------------------------------------------------------------------------------------------------
#
#                                             gRSShopper::Page;
#
#----------------------------------------------------------------------------------------------------------


  package gRSShopper::Page;
 
  use strict;
  use warnings;
  our $VERSION = "1.00";

  sub new {
  	my($class, $site, %args) = @_;
   	my $self = bless({}, $class);
 	my $target = exists $args{target} ? $args{target} : "world";
	$self->{target} = $target;
	
	$self->{site} = $site;
	$self->{context} = $site->{context};
	

	
 	return $self;
  }
  
  sub header {
  	
	my $self = shift;

	my $template = $self->{context} . "_header";


  }
  
  
  sub footer {
  	
  	my $self = shift;
  	
  	my $template = $self->{context} . "_header";
  	
  }

  sub target {
	my $self = shift;
	if( @_ ) {
		my $target = shift;
      	$self->{target} = $target;
	}
	return $self->{target};
  }


  sub to_string {
   	my $self = shift;
   	return $self->{page_content};
  }

  sub print {
  	my $self = shift;
   	print $self->to_string(), "\n";
  }



#----------------------------------------------------------------------------------------------------------
#
#                                             gRSShopper::File
#
#----------------------------------------------------------------------------------------------------------


  package gRSShopper::File;

  # $item = gRSShopper::Record->new("count",$itemcount);
  
   
  use strict;
  use warnings;
  our $VERSION = "1.00";


  sub new {
  	my($class, %args) = @_;
   	my $self = bless({}, $class);

 	$self->{file_title} = "";;
 	$self->{file_dir} = "";;
 	$self->{file_type} = "";
 	
 	
 	$self->{filename} = "";
 	$self->{filedirname} = "";
	$self->{fullfilename} = "";
	$self->{dir} = "";
	$self->{filetype} = "";
	
 	return $self;
  }



  
1;

  

#----------------------------------------------------------------------------------------------------------
#
#                                             gRSShopper::Record;
#
#----------------------------------------------------------------------------------------------------------

#
#  Create using tag:  $item = gRSShopper::Record->new({tag=>'tagname'});
#  Tags are associated with different types of record: feed, link, content, media, author, event

  package gRSShopper::Record;

  # $item = gRSShopper::Record->new("count",$itemcount);
  
   
  use strict;
  use warnings;
  our $VERSION = "1.00";


  sub new {
  	my($class, %args) = @_;
   	my $self = bless({}, $class);

	foreach ( keys %args ) { $self->{$_} = $args{$_}; }					# Import values from call
   	   	
     	unless ($self->{type}) { 
     		if ($self->{tag}) { $self->set_type($self->{tag}); }
	}
	
	if ($self->{parent}->{type}) {
		
		&flow_values($self->{parent},$self->{parent}->{type},$self,$self->{type});	# Inherit values from the parent
	}											# Actual values may override


 	return $self;
  }

  sub set_type {
	my $self = shift;
	my ($tag) = @_;
	return unless ($tag);
	if ($tag =~ /(^feed$|^channel$)/i) { $self->{type} = "feed"; }
	elsif ($tag =~ /(^item$|^entry$)/i) { $self->{type} = "link"; }
	elsif ($tag =~ /(^content$|^description$)/i) { $self->{type} = "content"; }
	elsif ($tag =~ /(^author$|^dc:creator$)/i) { $self->{type} = "author"; }
	elsif ($tag =~ /(^media$|^media:content$)/i) { $self->{type} = "media"; }
	elsif ($tag =~ /(^event$)/i) { $self->{type} = "event"; }

  }

  	
#----------------------------- Flow Values ------------------------------
#
#  Flow values from one type of record to another
#  Eg., fill empty valies in a link with values from the feed
#  Used to initialize record values


   sub flow_values {
	
	my ($from,$from_prefix,$to,$to_prefix) = @_;
	
	while (my ($fx,$fy) = each %$from) {	
		my $fprefix = $from_prefix."_";
		my $tprefix = $to_prefix."_";
		next unless ($fx =~ /$fprefix/i);					# Only flow through record values (signified by the presence of the prefix)
		next if ($to_prefix =~ /feed_/);					# Never flow *to* feed
		next if ($fx =~ /_id$/i);							# Never flow-through ID
		next if ($fx =~ /_type$/i);							# Never flow-through type		
		
		if ($fx =~ /genre|section|author|publisher|title|descxription/) {		# Limited list of flow-through values
			my $tx = $fx;												# These are intended to be defaults and
			$tx =~ s/$fprefix/$tprefix/ig;									# re over-written by actual discovered values
			$to->{$tx} ||= $from->{$fx}; 
		}			
	}
	
	
	
   }
   
   
   

  sub load_from_db {

    my $self = shift;
    my ($dbh,$id) = @_;
    
    unless ($self->{type}) { $self->{error} = "Record type not defined on load from db"; return 0; }
    my $idfield = $self->{type}."_id";
    my $stmt = "SELECT * FROM $self->{type} WHERE $idfield=? LIMIT 1";
    my $sth = $dbh -> prepare($stmt);
    $sth -> execute($id);
    my $data = $sth -> fetchrow_hashref();
    $sth->finish(  );
    unless ($data) { $self->{error} = "$self->{type} '$id' not found in database."; return 0; }
    while (my($dx,$dy) = each %$data) { $self->{$dx} = $data->{$dx}; }	
    return 1;	
  }
  
  #
  #   Add a value to the end of a list of values in an element
  #   Delimeter defaults to ;
  
  
  # Adding values to elements
  
  sub set_value {
	
	my ($self,$tag,$con) = @_;
	$self->{$tag} = $con; 					# Just set a value, eg. title
	$self->{$self->{type}."_".$tag} = $con;   		# Set a value for db storage, eg. feed_title	
  }
   
  sub extend_list {
	
	my ($self,$tag,$con,$delimiter) = @_;
	$delimiter ||= ";";
	if ($con) { 
		if ($self->{$tag}) { $self->{$tag} .= $delimiter; }  	# Just set a value, eg. title
		$self->{$tag} .= $con; 	
									# Set a value for db storage, eg. feed_title
		if ($self->{$self->{type}."_".$tag}) { $self->{$self->{type}."_".$tag} .= $delimiter; }
		$self->{$self->{type}."_".$tag} .= $con; 
	
	}
  }
  
    sub do_not_replace {
	
	my ($self,$tag,$con) = @_;
	unless ($self->{$tag}) { $self->{$tag} = $con; 	}	# Just set a value, eg. title
	unless ($self->{$self->{type}."_".$tag}) {
		$self->{$self->{type}."_".$tag} = $con;   }		# Set a value for db storage, eg. feed_title	
  }
  
  sub target {
	my $self = shift;
	if( @_ ) {
		my $target = shift;
      	$self->{target} = $target;
	}
	return $self->{target};
  }


  sub to_string {
   	my $self = shift;
   	return $self->{page_content};
  }

  sub print {
  	my $self = shift;
   	print $self->to_string(), "\n";
  }
  
1;


  


#----------------------------------------------------------------------------------------------------------
#
#                                             gRSShopper::Feed
#
#----------------------------------------------------------------------------------------------------------

#





  package gRSShopper::Feed;

  # $item = gRSShopper::Feed->new("count",$itemcount);
  
   
  use strict;

  use warnings;
  our $VERSION = "1.00";
  our @ISA = qw(gRSShopper::Record);    # inherits from Record


  sub new {

  	my($class, $args) = @_;
   	my $self = bless({}, $class);

	$self->set_type("feed");				# Default values
	$self->{content_buffer} = "";
	$self->{attributes_buffer} = "";
 	$self->{feed_title} = "";
 	$self->{feed_id} = "new";
 	$self->{feed_dir} = "";
 	$self->{feed_type} = "";
 	$self->{error} = "";
 	$self->{feedstring} = "";				# Feed as single string
 	$self->{stack} = [];					# array of tags used in processing
 

	if ($args->{id}) {
		$self->load_feed($args->{dbh},$args->{id});
	}
 	

 	return $self;
  }


  sub load_feed {
  	
	my $self = shift;
	my $dbh = shift;
	my $id = shift;
	
	die "Database not ready in _load_feed" unless ($dbh);
	my $stmt = "SELECT * FROM feed WHERE feed_id = ?";
	my $sth = $dbh->prepare($stmt);
	$sth -> execute($id);
	my $ref = $sth -> fetchrow_hashref();
	while (my($fx,$fy) = each %$ref) { 	
		$self->{$fx} = $fy; 
	}

	return;
	
  }
## use padre_syntax_check
  sub get_feed {

	my ($self) = @_;
	$self->{feedstring} = "";
	my $cache = &feed_cache_filename($self->{feed_link});
	if ((time - (stat($cache))[9]) < (60*60)) {			# If the file is less than 1 hour old
		$self->{feedstring} = &get_file($cache);
#print "Getting feedstring from cache<p>";		
	} else {	
	
#print "Getting feedstring from web<p>";	
		my $ua = LWP::UserAgent->new();
		my $response = $ua->get($self->{feed_link},{
			'User-Agent' => 'gRSShopper 0.3',
			'Accept' => '*/*','application/atom+xml',
			'Accept-Charset' => 'iso-8859-1,*,utf-8',
			'timeout' => '30'
		});
  
		if (! $response->is_success) { 
			my $err = $response->status_line;
			my $as_string = $response->as_string;
			my ($r_header,$r_body) = split "<",$as_string;
			$r_header =~ s/\n/<br>\n/g;
			#$err .= $response->head;
			return "ERROR:  $err ".$r_header." <br>$r_body<br>";
		}
	
		$self->{feedstring} =~ s/^\s+//;			# Remove leading spaces
		$self->{feedstring} = $response->content;		
		return "ERROR: Couldn't get $self->{feed_link} <br>" unless ($self->{feedstring});
	
									# Save common cache
		open FOUT,">$cache" or die "Error opening $cache: $!";
		print FOUT $self->{feedstring}  or die "Error writing to $cache: $!";
		close FOUT;
	}
	
	return;

}

sub feed_cache_filename  {
	

	my ($feedurl,$feed_cache_dir) = @_;
	
	my $feed_file = $feedurl;
	$feed_file =~ s/http:\/\///g;
	$feed_file =~ s/https:\/\///g;	
	$feed_file =~ s/\%|\$|\@//g;	
	$feed_file =~ s/(\/|=|\?)/_/g;
	
	return $feed_cache_dir.$feed_file;
	
}

# -------   Get File ---------------------------------------------------

# Internal function to get files

sub get_file {

	my ($file) = @_;
	my $content;
	open FIN,"$file" or return "$file not found";
	while (<FIN>) {
		$content .= $_;
	}
	close FIN;
	return $content;
	
}
1;




#----------------------------------------------------------------------------------------------------------
#
#                                             gRSShopper::Person;
#
#----------------------------------------------------------------------------------------------------------


package gRSShopper::Person;

# $Person = gRSShopper::Person->new({person_title=>'title',person_password=>'password'});
# Note that password will be encrypted in save
  
   
use strict;
use warnings;
our $VERSION = "1.00";
# use Temp;

sub new {
  	my($class, $args) = @_;
   	my $self = bless({}, $class);
   	while (my($ax,$ay) = each %$args) { 
   		print "$ax = $ay <br>";
   		$self->{$ax} = $ay; }
 	return $self;
 }


sub create {
	
	my ($self,$dbh) = @_;

	return "no database handler" unless $dbh;
	return "no person title defined" unless $self->{person_title};
	return "no person password defined" unless $self->{person_password};
	return "no person emaild defined" unless $self->{person_email};	

	$self->{person_password} = _password_encrypt($self->{person_password},4);
	$self->{person_crdate} = time;	
	$self->{person_status} = "reg";					
	$self->{person_id} = &db_insert($dbh,"","person",$self);
	unless ($self->{person_id}) { &error($dbh,"","","Error, no new account was created."); 	}

}

sub _password_encrypt {
	my ($pwd,$count) = @_;
	my @salt = ('.', '/', 'a'..'z', 'A'..'Z', '0'..'9');  
	my $salt = "";
	$salt.= $salt[rand(63)] foreach(1..$count);
	my $encrypted = crypt($pwd, $salt);
	return $encrypted; 
}
	



		


  sub target {
	my $self = shift;
	if( @_ ) {
		my $target = shift;
      	$self->{target} = $target;
	}
	return $self->{target};
  }


  sub to_string {
   	my $self = shift;
   	return $self->{page_content};
  }

  sub print {
  	my $self = shift;
   	print $self->to_string(), "\n";
  }
  
1;

#----------------------------------------------------------------------------------------------------------
#
#                                             gRSShopper::Database;
#
#----------------------------------------------------------------------------------------------------------


package gRSShopper::Database;

# $Person = gRSShopper::Person->new({person_title=>'title',person_password=>'password'});
# Note that password will be encrypted in save
  
   
use strict;
use warnings;
our $VERSION = "1.00";



sub new {
  	my($class, $args) = @_;
   	my $self = bless({}, $class);
   	while (my($ax,$ay) = each %$args) { 
   		print "$ax = $ay <br>";
   		$self->{$ax} = $ay; }
   		
   		

}








1;
