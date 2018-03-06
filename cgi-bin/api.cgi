#!/usr/bin/env perl

#    gRSShopper 0.7  API 0.01  -- gRSShopper api module
#    30 December 2017 - Stephen Downes

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
#           API Functions
#
#-------------------------------------------------------------------------------
print "Content-type: text/html\n\n";


# Forbid bots

	die "HTTP/1.1 403 Forbidden\n\n403 Forbidden\n" if ($ENV{'HTTP_USER_AGENT'} =~ /bot|slurp|spider/);


# Load gRSShopper
  use strict;
	use File::Basename;
	use CGI::Carp qw(fatalsToBrowser);
	my $dirname = dirname(__FILE__);
	require $dirname . "/grsshopper.pl";


# Load modules

	our ($query,$vars) = &load_modules("api");
  $vars->{db} ||= $vars->{table};
	$vars->{table} ||= $vars->{db};

# Load Site

	our ($Site,$dbh) = &get_site("api");

# Get Person  (still need to make this an object)

	our $Person = {}; bless $Person;
	&get_person($dbh,$query,$Person);
	my $person_id = $Person->{person_id};

# while (my($vx,$vy) = each %$vars) { print "$vx = $vy <br>"; }

  # LOGIN
	if ($vars->{cmd} eq "login") {

		 print &api_login();
		 exit;

	}

  # START
  elsif ($vars->{cmd} eq "start") {
		my @tabs = split",",$vars->{tabs};
		unless (@tabs) { @tabs = ('Database');}
			 #{}print qq|<textarea cols=60 rows=60>|;
			 print &main_window(\@tabs,@tabs[0]);
			#{} print qq|</textarea>|;
			 exit;
  }


	# SHOW
  elsif ($vars->{cmd} eq "show") {
		print &api_show_record(); exit;
	}

	# SHOW FIRST
  elsif ($vars->{cmd} eq "showfirst") {
		$vars->{id} = &db_get_single_value($dbh,$vars->{table},$vars->{table}.qq|_id|,"",$vars->{table}.qq|_id|);
		print &api_show_record(); exit;
	}

	# SHOW PREV
  elsif ($vars->{cmd} eq "showprev") {
		my $first = &db_get_single_value($dbh,$vars->{table},$vars->{table}.qq|_id|,"",$vars->{table}.qq|_id|);
		if ($vars->{id} > $first) {	$vars->{id} = &db_get_single_value($dbh,$vars->{table},$vars->{table}.qq|_id|,$vars->{id},$vars->{table}.qq|_id DESC|,"lt"); }
		print &api_show_record(); exit;
	}

	# SHOW NEXT
  elsif ($vars->{cmd} eq "shownext") {
		my $last = &db_get_single_value($dbh,$vars->{table},$vars->{table}.qq|_id|,"",$vars->{table}.qq|_id DESC|);
		if ($vars->{id} < $last) { $vars->{id} = &db_get_single_value($dbh,$vars->{table},$vars->{table}.qq|_id|,$vars->{id},$vars->{table}.qq|_id|,"gt"); }
		print &api_show_record(); exit;
	}

	# SHOW LAST
  elsif ($vars->{cmd} eq "showlast") {
		$vars->{id} = &db_get_single_value($dbh,$vars->{table},$vars->{table}.qq|_id|,"",$vars->{table}.qq|_id DESC|);
		print &api_show_record(); exit;
	}

	&admin_only();


# get Postdata, in which API JSON will be stored


  my $postdata = $query->param('POSTDATA');
  if ($postdata) {
    print "Found postdata<br>";
		# Parse the JSON Data
		use JSON::Parse 'parse_json';
		use JSON;
		my $request_data = parse_json($postdata);

		if ($request_data->{action} eq "search") {


			# Table
			unless ($request_data->{table}) { print "Error: table name must be provided."; exit; }
			$request_data->{table} =~ s/[^a-zA-Z0-9 _]//g;  # Just make sure there's no funny business

			my $sql = &create_sql($request_data->{table},$request_data->{language},$request_data->{sort},$request_data->{page});
			my $query = '%'.$request_data->{query}.'%';

			# Execute query and convert the result to JSON, then print
			my $json->{entries} = $dbh->selectall_arrayref( $sql, {Slice => {} },$query,$query );
			my $json_text = to_json($json);
			print $json_text;
      exit;

    }



			while (my($x,$y) = each %$request_data) { print "$x = $y <p>";}  											#{%}



		print "Content-type: text/html\n\n";
		print "ok";
		exit;
	}


# -------------------------------------------------------------------------------------
#          App Functions
#
# These are requests put to the app to offer some sort of form or interaction
#
# -------------------------------------------------------------------------------------


# COMMANDS

if ($vars->{cmd}) {

	# LIST
	if ($vars->{cmd} eq "list") {
   if ($vars->{obj} eq "record") { print &api_list_records(); exit; }
   elsif ($vars->{obj} eq "table") { print &list_tables(); exit; }
  }

  # BACKUP
  elsif ($vars->{cmd} eq "backup") { print &api_backup(); exit; }

  # CREATE
  elsif ($vars->{cmd} eq "create") {
   if ($vars->{obj} eq "table") { print &api_create_table(); exit; }
	}


  # EDIT
  elsif ($vars->{cmd} eq "edit") {
		unless ($vars->{table} ) { print "Table to $vars->{cmd} has not been specified."; exit; }
		my $tabs = "";
		print &main_window($tabs,"Edit",$vars->{table},"$vars->{id}",$vars);
		exit;
	}

	# IMPORT
  elsif ($vars->{cmd} eq "import") {
		unless ($vars->{table} ) { print "Table to $vars->{cmd} has not been specified."; exit; }
		my $tabs = ['Import','Export'];
		print &main_window($tabs,"Import",$vars->{table},"none",$vars);
		exit;
	}

	# HARVEST
  elsif ($vars->{cmd} eq "harvest") {
		unless ($vars->{table} ) { print "Table to $vars->{cmd} has not been specified."; exit; }
		unless ($vars->{id} ) { print ucfirst($vars->{table})." to $vars->{cmd} has not been specified."; exit; }
		my $tabs = ['Harvest'];
		print &main_window($tabs,"Harvest",$vars->{table},"$vars->{id}",$vars);
		exit;
	}

	# DROP
	elsif ($vars->{cmd} eq "drop") {
		if ($vars->{obj} eq "table") { print &api_drop_table(); exit; }
	}

	# DELETE
  elsif ($vars->{cmd} eq "delete") {
		if ($vars->{obj} eq "record") { print &api_delete_record(); exit; }
	}

  # ADMIN
  elsif ($vars->{cmd} eq "admin") {
		my $starting_tab = $vars->{starting_tab} || "Database";
		print &main_window(['Database','Harvester','Permissions','Logs','General'],$starting_tab);
	 	exit;
	}

	# SOCIAL
  elsif ($vars->{cmd} eq "social") {
		my $starting_tab = $vars->{starting_tab} || "Accounts";
		print &main_window(['Subscribers','Newsletters','Accounts','Meetings'],$starting_tab);
		exit;
	}

	# SOCIAL
  elsif ($vars->{cmd} eq "publishing") {
		my $starting_tab = $vars->{starting_tab} || "Newsletters";
		print &main_window(['Subscribers','Newsletters','Accounts','Meetings'],$starting_tab);
		exit;
	}

	# PUBLISH
  elsif ($vars->{cmd} eq "publish") {
	 	print &api_page_publish();
	 	exit;
  }

	# CLONE
	elsif ($vars->{cmd} eq "clone") {
		print &api_clone();
		exit;
	}

	# AUTOPOST
  elsif ($vars->{cmd} eq "autopost") {
		print &api_autopost();
		exit;
	}

   print "Command $vars->{cmd} not recognized.";
	 exit;
}


# API Show ----------------------------------------------------------
# ------- Show Record ------------------------------------------------------
#
# Show in a table
# Will accept search parameters
#
# -------------------------------------------------------------------------

sub api_show_record {

	 unless ($vars->{table}) { return "Don't know which table to show."; exit;}
	 return unless (&is_allowed("view",$vars->{table}));
   unless ($vars->{id}) { return "Don't know which ".$vars->{table}." number to show."; exit;}
	 $vars->{format} ||= "html";
	 return	&output_record($dbh,$query,$vars->{table},$vars->{id},$vars->{format},"api");
	 exit;
}



# API LIST ----------------------------------------------------------
# ------- Table ------------------------------------------------------
#
# List records in a table
# Will accept search parameters
#
# -------------------------------------------------------------------------

sub api_list_records {

	unless ($vars->{db}) { print "Table to $vars->{cmd} has not been specified."; exit; }
  unless ($vars->{tab}) { $vars->{tab} = "no-tab"; }
	print &list_records($dbh,$query,$vars->{table},$vars->{tab});
	exit;

}

# API BACKUP ----------------------------------------------------------
# ------- Back Up Table ------------------------------------------
#
# Alter a column in a database
# Expects semi-colon-delimited comtent as follows: "field;type;size;null;default;extra"
#
# -------------------------------------------------------------------------

sub api_backup {

	my $output = "Backing up $vars->{table}. ";
	if ($vars->{table} eq "all") {$output .= " tables"; }
	my $savefile = &db_backup($vars->{table});
	my $saveurl = $savefile;
	$saveurl =~ s/$Site->{st_urlf}/$Site->{st_url}/;
	$output .= qq|Table '$vars->{table}' backed up to <a href="$saveurl">$savefile</a>|;
  return $output;

}


# API CREATE ----------------------------------------------------------
# ------- Table -----------------------------------------------------
#
# Create a table in the database
# Expects $vars->{table} as table name
#
# -------------------------------------------------------------------------


sub api_create_table {

   my $apilink = $Site->{st_cgi}."api.cgi";
	 unless ($vars->{table}) { print "Table to $vars->{cmd} has not been specified."; exit; }
	 $vars->{table} =~ s/[^a-zA-Z0-9_-]//g;
	 &db_create_table($dbh,$vars->{table});
   return "Creating table $vars->{table} " .
	    qq|<a href="#" onClick="openMain('$apilink','edit','form','','|.$vars->{table}.qq|','Database');">Edit the New Table</a>|;
	 exit;

}


# API DROP ----------------------------------------------------------
# ------- Table -----------------------------------------------------
#
# Create a table in the database
# Expects $vars->{table} as table name
#
# -------------------------------------------------------------------------


sub api_drop_table {

  my $apilink = $Site->{st_cgi}."api.cgi";
	unless ($vars->{table}) { print "Table to $vars->{cmd} has not been specified."; exit; }

	# Back up table
  my $savemsg = &api_backup($vars->{table});

	# Drop table
	my $dropmsg = &db_drop_table($dbh,$vars->{table});

  return qq|$savemsg <br>$dropmsg|;
	exit;

}

# API DELETE ----------------------------------------------------------
# ------- Record -----------------------------------------------------
#
# Delete Record
# Expects $vars->{table} as table name, $vars->{id} as table id
#
# -------------------------------------------------------------------------


sub api_delete_record {

  my $apilink = $Site->{st_cgi}."api.cgi";
	unless ($vars->{table}) { print "Table to $vars->{cmd} has not been specified."; exit; }
	unless ($vars->{id}) { print "ID number to $vars->{cmd} has not been specified."; exit; }

	&record_delete($dbh,$query,$vars->{table},$vars->{id},"silent");
	# Back up table
  #my $savemsg = &api_backup($vars->{table});

	# Drop table
	#my $dropmsg = &db_drop_table($dbh,$vars->{table});

  return qq|OK|;
	exit;

}


# API LOGIN ----------------------------------------------------------
# ------- ------------------------------------------------------------
#
# Receives login credentials
# Writes login cookies
#
# -------------------------------------------------------------------------

sub api_login {

	  my $login_error = &printlang("Login error")."<br/>".
		    &printlang("Try again",$Site->{st_cgi}."login.cgi")."<br>".
		    &printlang("Recover registration",$Site->{st_cgi}."login.cgi?refer=$vars->{refer}&action=Email");

		# Check Input Variables
		unless (($vars->{person_title}) && ($vars->{person_password})) { print $login_error; exit;	}

		# Create query (email or title)
		my $stmt;
		if ($vars->{person_title} =~ /@/) {
			$vars->{person_email} = $vars->{person_title};
			$stmt = qq|SELECT * FROM person WHERE person_email = ? ORDER BY person_id LIMIT 1|;
		} else {
			$vars->{person_title} = $vars->{person_title};
			$stmt = qq|SELECT * FROM person WHERE person_title = ? ORDER BY person_id LIMIT 1|;
		}

    # Execute Query
		my $sth = $dbh -> prepare($stmt);
		$sth -> execute($vars->{person_title});
		my $ref = $sth -> fetchrow_hashref();

		# Eerror if Data not found
		unless ($ref) { print $login_error; exit; }

		# Password Check
		unless ($ref->{person_password} eq crypt($vars->{person_password}, $ref->{person_password})) { print $login_error; exit; }	# Salted crypt match

    # Successful Login. Reset 'Person' values.
		while (my($x,$y) = each %$ref) { $Person->{$x} = $y; }
    $sth->finish(  );

    # Define Cookie Names
		my $site_base = &get_cookie_base();
		my $id_cookie_name = $site_base."_person_id";
		my $title_cookie_name = $site_base."_person_title";
		my $session_cookie_name = $site_base."_session";
		my $admin_cookie_name = $site_base."_admin";

		my $exp; 							# Expiry Date
		if ($vars->{remember}) { $exp = '+1y'; }
		else { $exp = '+1h'; }

										# Session ID
		my $salt = $site_base . time;
		my $sessionid = crypt("anymouse",$salt); 			# Store session ID in DB
		&db_update($dbh,"person",{person_mode => $sessionid}, $Person->{person_id},&printlang("Setting session",$Person->{person_id}));

		# Admin Cookie
		# Not secure; can be spoofed, use only to create links
    my $admin_cookie_value = "";
    if ($Person->{person_status}  eq "admin") { $admin_cookie_value="admin"; }
    else { my $admin_cookie_value="registered"; }

		return qq|{"site_base":"$site_base",
			  "person_id": "$Person->{person_id}",
				"person_title": "$Person->{person_title}",
				"session": "$sessionid",
				"admin": "$admin_cookie_value"}|;

		# User is successfully logged in, reload the page now

   exit;
}



# API PAGE PUBLISH ---------------------------------------------------------- "
# ------- Page -----------------------------------------------------
#
# Publish Page
# Expects $vars->{id} as page id
#
# -------------------------------------------------------------------------


sub api_page_publish {

	unless ($vars->{table} eq "page") { return qq|Only publishing pages at the moment|; exit; }
	unless ($vars->{id}) { return qq|Publish command needs a page ID to publish|; exit; }
	my ($pgcontent,$pgtitle,$pgformat,$archive_url,$keyword_count,$loc) = &publish_page($dbh,$query,$vars->{id},"");
	exit;

}


# to force a new harvest: http://beeyard.lpss.me:8091/hive/d69ce375-4168-4a7d-b6f1-439216e6094f


sub create_sql {

	my ($table,$language,$sort,$page) = @_;

  #  Language
  my $lang_where = "";
	$language =~ s/[^a-zA-Z]*//g;
  if ($language && $vars->{language} ne "All") {
		  $lang_where = "course_language LIKE '%".$language."%' AND ";
	}

	# Orderby
	my $orderby = "";
	$sort =~ s/[^a-zA-Z_]*//g;
	if ($sort eq "Title") {
		$orderby = " ORDER BY course_title";
	} else  {
		$sort = "Recent";
		$orderby = " ORDER BY course_crdate DESC";
	}


	# Start and Limit
	my $count = "Need to create counter";
	$page =~ s/[^0-9]*//g;
  my $limit; my $results_per_page = 10; my $start=0;
  unless ($page) { $page=0;}
	if ($page > 0) 	{ $start = $page*10; $limit = "LIMIT $start,$results_per_page"}
	else { $limit = "LIMIT $results_per_page"; }
	my $end = $start+$results_per_page; my $s = $start+1;
	my $results_range = "$s to $end of $count";


  my $sql = "SELECT * FROM  course	WHERE $lang_where (course_title LIKE ? OR course_description LIKE ?) $orderby $limit ";


	return $sql;
}


sub keylist {

  my ($sutocontent) = @_;
	my $script = {}; my $replace;

	&parse_keystring($script,$sutocontent);


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


    return $replace;

}




# API UPDATE ----------------------------------------------------------
# ------- Keylist Update-----------------------------------------------
#
# Find or, if not found, create a new $key record named $value
# Then create a graph entry linking the new $key with $table $id
#
# -------------------------------------------------------------------------



sub api_keylist_update {

	my ($table,$key) = split /_/,$vars->{col_name};
  #	die "Field does not exist" unless &__check_field($table,$vars->{col_name});

	my $id = $vars->{table_id};
	my $value = $vars->{value};

	# Split list of input $value by ;
	$value =~ s/&apos;|&#39;/'/g;   # ' Remove apostraphe escaping, just for the split
	my @keynamelist = split /;/,$value;

	# For each member of the list...
	foreach my $keyname (@keynamelist) {

	  $keyname =~ s/'/&#39;/g;   # Replace apostraphe escaping

		# Trim leading, trailing white space
		$keyname =~ s/^ | $//g;

		# Are we looking for _name, _title ...?
		my $keyfield = &get_key_namefield($key);

		# can we find a record with that name or title?
		my $keyrecord = &db_get_record($dbh,$key,{$keyfield=>$keyname});

		# Record wasn't found, create a new record, eg., a new 'author'
		unless ($keyrecord) {

			# Initialize values
			$keyrecord = {
				$key."_creator"=>$Person->{person_id},
				$key."_crdate"=>time,
				$keyfield=>$keyname
			};

			# Save the values and obtain new record id
			$keyrecord->{$key."_id"} = &db_insert($dbh,$query,$key,$keyrecord);
		}

		# Error unless we have a new record id
		print &error() unless $keyrecord->{$key."_id"};

		# Save Graph Data
		my $graphid = &db_insert($dbh,$query,"graph",{
			graph_tableone=>$key, graph_idone=>$keyrecord->{$key."_id"}, graph_urlone=>$keyrecord->{$key."_url"},
			graph_tabletwo=>$table, graph_idtwo=>$id, graph_urltwo=>"",
			graph_creator=>$Person->{person_id}, graph_crdate=>time, graph_type=>"", graph_typeval=>""});
	}

	# Return new graph output for the form

	print &form_graph_list($table,$id,$key);
	exit;

}

# API UPDATE ----------------------------------------------------------
# ------- KeylistRemove -----------------------------------------------
#
# Remove any graph entry linking the new $key $value with $table $id
#
# -------------------------------------------------------------------------

sub api_keylist_remove {

	my ($table,$key) = split /_/,$vars->{col_name};
	my $id = $vars->{table_id};
	my $value = $vars->{value};

   # Remove Graph Database

	my $sql = "DELETE FROM graph WHERE graph_tableone=? AND graph_idone = ? AND graph_tabletwo =? AND graph_idtwo = ?";
	my $sth = $dbh->prepare($sql);
	$sth->execute($table,$id,$key,$value);
	$sth->execute($key,$value,$table,$id);

	# Return new graph output for the form
	print &form_graph_list($table,$id,$key);

	exit;
}


# API UPDATE ----------------------------------------------------------
# ------- Text -----------------------------------------------------
#
# Update a text field
#
# -------------------------------------------------------------------------

sub api_textfield_update {




	die "Field does not exist" unless (&__check_field($vars->{table_name},$vars->{col_name}));
	my $id_number = &db_update($dbh,$vars->{table_name}, {$vars->{col_name} => $vars->{value}}, $vars->{table_id});
	if ($id_number) { &api_ok();   } else { &api_error(); }
	die "api failed to update $vars->{table_name}  $vars->{table_id}" unless ($id_number);


}

# API UPDATE ----------------------------------------------------------
# ------- Publish -----------------------------------------------------
#
# Update a publish field, including actually publishing the resources
# on a third party site oif so directed by the field
#
# -------------------------------------------------------------------------

sub api_publish {

	#die "Field $vars->{table_name},$vars->{col_name} does not exist" unless (&__check_field($vars->{table_name},$vars->{col_name}));

	my $table = $vars->{table_name};
	my $id = $vars->{table_id};
	my $value = $vars->{value};
	my $col = $vars->{col_name};


	my $published = &db_get_single_value($dbh,$table,$col,$id);



	my $result;
	if ($published =~ /$vars->{value}/) {	# Already Published
		print "Was already published";
		exit;
	} else {				# Not yet published, so publish it

	# So now, ideally, I'd use the name of the social network service to pick a subroutine to actually do the publishing, but...

		if ($vars->{value} =~ /twitter/i) {

			print "Sending to Twitter<br>";
			my $twitter = &twitter_post($dbh,"post",$id);
			print "Twitter result: $twitter<br>";
			$published .= ",twitter";
			my $result = &db_update($dbh,$table, {$col => $published}, $id);
			print "Recorded publication success $result<br>";
			exit;

		}


		elsif ($vars->{value} =~ /web|json|rss/i) {

			$published .= ",".$vars->{value};
			my $result = &db_update($dbh,$table, {$col => $published}, $id);
			print "Published to ".$vars->{value}."<p>";
			exit;
		}
	}

}

# API UPDATE ----------------------------------------------------------
# ------- Create Column -----------------------------------------------------
#
# Update a column in a database
# Expects semi-colon-delimited comtent as follows: "field;type;size;null;default;extra"
#
# -------------------------------------------------------------------------

sub api_column_create {

	my $table = $vars->{table_name};
	my $id = $vars->{table_id};
	my $value = $vars->{value};
	my $column = $vars->{col_name};
  my ($field,$type,$size,$null,$default,$extra) = split ';',$value;

  # Validate column name
  unless ($field) {
		print "No column created because no column name was provided."; exit;
	}

	# Validate field sizes
	($type,$size) = validate_column_sizes($type,$size);

  if ($id eq "new") {
     print &db_add_column($table,$field,$type,$size,$default); exit;
	} else {

     print "Error creating new column. 'id' should equal 'new'."; exit;

	}
	exit;

	die "Field does not exist" unless (&__check_field($vars->{table_name},$vars->{col_name}));
	my $id_number = &db_update($dbh,$vars->{table_name}, {$vars->{col_name} => $vars->{value}}, $vars->{table_id});
	if ($id_number) { &api_ok();   } else { &api_error(); }
	die "api failed to update $vars->{table_name}  $vars->{table_id}" unless ($id_number);


}

# API UPDATE ----------------------------------------------------------
# ------- Alter Column -----------------------------------------------
#
# Alter a column in a database
# Expects semi-colon-delimited comtent as follows: "field;type;size;null;default;extra"
#
# -------------------------------------------------------------------------

sub api_column_alter {

	my $table = $vars->{table_name};
	my $value = $vars->{value};
	my $column = $vars->{col_name};
  my ($field,$type,$size,$null,$default,$extra) = split ';',$value;
	my $result = "";

  print &db_alter_column($table,$field,$type,$size,$default);

	exit;


}

# API UPDATE ----------------------------------------------------------
# ------- Remove Column Warn ------------------------------------------
#
# Alter a column in a database
# Expects semi-colon-delimited comtent as follows: "field;type;size;null;default;extra"
#
# -------------------------------------------------------------------------

sub api_column_remove {

	my $table = $vars->{table_name};
	my $value = $vars->{value};
	my $col = $vars->{col_name};
	my $second_look = $vars->{second_look};
  my ($field,$type,$size,$null,$default,$extra) = split ';',$value;
	my $result = "";
  my $api_url = $Site->{st_cgi}."api.cgi";


  if ($value eq "confirm") {

    if (($col =~ /_id/) || ($col =~ /_name/) || ($col =~ /_title/) ||
			($col =~ /_description/) || ($col =~ /_crdate/) || ($col =~ /_creator/)) {
					print "The column <i>$col</i> is a required column and cannot be removed"; exit;
		} else {
					$dbh->do("ALTER TABLE $table DROP COLUMN $col");
					print "The column <i>$col</i> has been removed. I hope that's what you wanted."; exit;
		}


	} else {
  	print qq|
	  	<h1>WARNING</h1>
			<p>Are you <i>sure</i> you want to drop $col from $table ?????</p>
			<p><b>All data</b> in $col will be lost. Never to be recovered again.</p>
			<p>You <b>cannot</b> fix this. Backspace to get out of this.</p>
			<p>If you're <i>sure</i>, press the button:</p>
     	<input type="button" name="remove_column_warn" id="remove_column_warn" value=" Remove Column ">
		 	<script>
 				\$('#remove_column_warn').on('click',function(){
 					remove_column("$api_url","$table","$col","confirm");
 					openColumns("$Site->{st_cgi}api.cgi?app=show_columns&db=$table","$table");
 				});
 			</script>
		|;
	}
	exit;


}


#
#             API Commit
#
#             Commits changes saved in the 'Form' table to the database
#             - creates table if necessary
#             - creates columns if necessary
#             - alters column to new type if necessary
#


sub api_commit {

  print "Commit";
  return "Commit";
  exit;

	# Get the Form record from database
	my $record = &db_get_record($dbh,$vars->{table_name},{$vars->{table_name}."_id" => $vars->{table_id}});
	unless ($record) { print "<span style='color:red;'>Error: API failed to update $vars->{table_name}  $vars->{table_id}</span>"; exit; }

	# Standardize form names to lower case (because some operations are case insensitive)
	$record->{form_title} = lc($record->{form_title});


	# Create table if table doesn't exist
	&db_create_table($dbh,$record->{form_title});

	# Get the existing columns from the table
	my $columns;
	#my $showstmt = qq|SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = ? AND table_schema = ? ORDER BY column_name|;
	my $showstmt = "SHOW COLUMNS FROM ".$record->{form_title};
	my $sth = $dbh -> prepare($showstmt)  or die "Cannot prepare: $showstmt FOR $record->{form_title} in $Site->{db_name} " . $dbh->errstr();
	$sth -> execute()  or die "Cannot execute: $showstmt " . $dbh->errstr();
  #	$sth -> execute($record->{form_title},$Site->{db_name})  or die "Cannot execute: $showstmt " . $dbh->errstr();
	while (my $showref = $sth -> fetchrow_hashref()) {
  #print $showref->{Field},"<p>";
		# Stash Column Data for future reference
		$columns->{$showref->{Field}}->{type} = $showref->{Type};
		$columns->{$showref->{Field}}->{size} = $showref->{CHARACTER_MAXIMUM_LENGTH};

	}

	# Go though the table structure defined in $record->{form_data}
	my @fcols = split /;/,$record->{form_data};
	my $titles = 0;

	# For each of the columns defined in the form data
	foreach my $fcol (@fcols) {
		my ($fname,$ftype,$fsize) = split /,/,$fcol; 	# This assumes an order which could be a problem
		if ($titles == 0) {
								# Fix that problem here
			$titles = 1; next; 			# Skip past titles
		}

		# Does the column exist?
		my $columntitle = $record->{form_title}."_".$fname;

		# No
		unless ($columns->{$columntitle}) {

			next if (&__map_field_types($ftype) eq "none");

			# Create New Column as per the Form Data
			my $sql;
			if (&__map_field_types($ftype) eq "text") {
				$sql = qq|alter table |.$record->{form_title}.qq| add column $columntitle text;|;
			} elsif (&__map_field_types($ftype) eq "int") {
				unless ($fsize) { $fsize=15; }
				$sql = qq|alter table |.$record->{form_title}.qq| add column $columntitle int ($fsize);|;
			} elsif (&__map_field_types($ftype) eq "varchar") {
				unless ($fsize) { $fsize = 256; }
				$sql = qq|alter table |.$record->{form_title}.qq| add column $columntitle varchar ($fsize);|;
			} else {
				$sql = qq|alter table |.$record->{form_title}.qq| add column $columntitle varchar ($fsize);|;
			}
			#print "Doing: $sql <br>";
			$dbh->do($sql) or die "error creating $fname using $sql";


		# Yes
		} else {

			# Check for increased varchar size
			if (&__map_field_types($ftype) eq "varchar") {
				if ($columns->{$columntitle}->{size} < $fsize) {

					# And alter column size if necessary

					my $sql = qq|alter table |.$record->{form_title}.qq| modify $columntitle VARCHAR($fsize);|;
					$dbh->do($sql) or die "error embiggening $fname";

				}

			}

		}


	}


	my $id_number = &db_update($dbh,$vars->{table_name}, {$vars->{col_name} => 1}, $vars->{table_id});
	if ($id_number) { &api_ok();   } else { &api_error(); }
	die "api failed to update $vars->{table_name}  $vars->{table_id}" unless ($id_number);

}

sub __map_field_types {

	my ($field) = @_;
	if ($field eq "select" || $field eq "date" || $field eq "varchar") { return "varchar"; }
	elsif ($field eq "text" || $field eq "textarea" || $field eq "wysihtml5" || $field eq "data") { return "text"; }
	elsif ($field eq "commit" || $field eq "publish" || $field eq "int") { return "int"; }
	else { return "none"; }

}



sub api_data_update {



    my $data = "";
    for (my $i=-1; $i < 100; $i++) {
    	my $row = "";
    	for (my $j=-1; $j < 100; $j++) {
    	   my $slot = $i."-".$j;
	   if ($vars->{$slot}) {
	   	if ($row) { $row .= ","; }
	   	$row .= $vars->{$slot};
	   }
        }
        if ($data && $row) { $data .= ";"; }
	$data .= $row;
    }

  #$data = qq|name,type,size;name,textarea,256;nickname,textarea,256|;
    my $id_number = &db_update($dbh,$vars->{table_name}, {$vars->{col_name} => $data}, $vars->{table_id});


  #my $str; while (my ($x,$y) = each %$vars) 	{ $str .= "$x = $y <br>\n"; }
  #&send_email('stephen@downes.ca','stephen@downes.ca', 'data  update',$str.$data);

	# Reset commit flag in case the table is 'form'
	if ($vars->{table_name} eq "form") {
  #		&db_update($dbh,$vars->{table_name}, {form_commit => 0}, $vars->{table_id});
	}

    if ($id_number) { &api_ok();   } else { &api_error(); }



  #	my $id_number = &db_update($dbh,$vars->{table_name}, {$vars->{name} => $vars->{value}}, $vars->{table_id});
  #	if ($id_number) { &api_ok();   } else { &api_error(); }
	#die "api failed to update $vars->{table_name}  $vars->{table_id}";
    #enless ($id_number);


}

sub api_ok {

	print qq|&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:green;">ok!</a>|;
	exit;

}

sub api_error {


	print "300 API Error - failed to update $vars->{table_name}  $vars->{table_id} \n";
	exit;

}

sub api_file_upload {


	$vars->{graph_table} = $vars->{table_name};
	$vars->{graph_id} = $vars->{table_id};

	# Upload the file

	my $file = &upload_file();
	&api_save_file($file);

	# Return new graph output for the form
	#print &form_graph_list($vars->{graph_table},$vars->{graph_id},"file");

	# Return json response for JQuery
	my $outurl = $Site->{st_url}.$file->{file_dir}.$file->{file_title};
	my $output = qq|
 {"files": [
  {
    "name": "$file->{file_title}",
    "size": 902604,
    "url": "$outurl",
    "deleteUrl": "http:\/\/example.org\/files\/picture1.jpg",
    "deleteType": "DELETE"
  }
 ]}
 |;
 print $output;



 exit;



}

# API UPDATE ----------------------------------------------------------
# ------- URL -----------------------------------------------------
#
# Retrieves the file found at the URL supplied, saves it, stores
# metadata as a 'file' entry, then create a graph entry linking the new
# file with $table $id
#
# -------------------------------------------------------------------------

sub api_url_upload {


 #my $str; while (my ($x,$y) = each %$vars) 	{ $str .= "$x = $y <br>\n"; }
 #&send_email('stephen@downes.ca','stephen@downes.ca', 'url upload '.$vars->{value},$str);


	$vars->{graph_table} = $vars->{table_name};
	$vars->{graph_id} = $vars->{table_id};

	# Upload the file

	my $file = &upload_url($vars->{value});
	&api_save_file($file);

	# Return new graph output for the form
	if ($vars->{msg}) { print $vars->{msg}; }
	print &form_graph_list($vars->{graph_table},$vars->{graph_id},"file");







}

# API UPDATE ----------------------------------------------------------
# ------- API Save File -----------------------------------------------
#
# Save a file, then create a graph entry
# linking the new file with $table $id
#
# -------------------------------------------------------------------------

sub api_save_file {

	my ($file) = @_;

	# Reject unless there's a full file name
	return unless ($file && $file->{fullfilename});

	die "Graph table name not provided" unless ($vars->{graph_table});
	die "Graph table name not provided" unless ($vars->{graph_id});

	# Save the file
	my $file_record = &save_file($file);
	if ($file_record) { $vars->{msg} .= qq|&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:green;">ok!</a><br><br>|; }
	else { $vars->{msg} .= qq|<span style="color:red;">Error saving file. $!</span>|; die "Error saving file $!"; }


	# Set up Graph Data
	return unless ($vars->{graph_id} && $vars->{graph_table});
	my $urltwo = $Site->{st_url}.$vars->{graph_table}."/".$vars->{graph_id};
	my $graph_typeval = "";
	if ($file_record->{file_type} eq "Illustration") { $graph_typeval = $vars->{file_align} . "/" . $vars->{file_width}; }
	else { $graph_typeval = $file_record->{file_mime}; }


	# Save Graph Data
	my $graphid = &db_insert($dbh,$query,"graph",{
		graph_tableone=>'file', graph_idone=>$file_record->{file_id}, graph_urlone=>$file_record->{file_url},
		graph_tabletwo=>$vars->{graph_table}, graph_idtwo=>$vars->{graph_id}, graph_urltwo=>$urltwo,
		graph_creator=>$Person->{person_id}, graph_crdate=>time, graph_type=>$file_record->{file_type}, graph_typeval=>$graph_typeval});

	# Make Icon (from smallest uploaded image thus far)

	if ($file_record->{file_type} eq "Illustration") {

		my $icon_image = &item_images($vars->{graph_table},$vars->{graph_id},"smallest");

		my $filename = $icon_image->{file_title};
		my $filedir = $Site->{st_urlf}."files/images/";
		my $icondir = $Site->{st_urlf}."files/icons/";
		my $iconname = $vars->{graph_table}."_".$vars->{graph_id}.".jpg";

		my $tmb = &make_thumbnail($filedir,$filename,$icondir,$iconname);
	}



}

# API UPDATE ----------------------------------------------------------
# ------- Save File -----------------------------------------------------
#
# Save a file, get metadata, store a 'file' entry in the db, return the
# new file record
#
# -------------------------------------------------------------------------
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
		file_url => $Site->{st_url}.$file->{file_dir}.$file->{file_title},
		file_dir => $file->{file_dir},
		file_mime => $mime,
		file_size => $ffsize,
		file_crdate => time,
		file_creator => $Person->{person_id},
		file_type => $file_type,
		file_width => $ffwidth,
		file_align => "top");



	# Create File Record
	$file_record->{file_id} = &db_insert($dbh,$query,"file",$file_record);

	if ($file_record->{file_id}) { return $file_record; }
	else { &error($dbh,"","","File save failed: $! <br>"); }


}

sub __check_field {
	my ($table,$field) = @_;

	my @columns = &db_columns($dbh,$table);
	return 1 if (&index_of($field,\@columns)>-1);
	return 0;

}

# API CLONE ----------------------------------------------------------
# ------- Clone Record -----------------------------------------------------
#
# Give the id and table of a record and an exact copy of that record is created
#
# -------------------------------------------------------------------------
#


sub api_clone {

   unless ($vars->{table}) { return "Don't know which table to clone."; exit;}
   unless ($vars->{id}) { return "Don't know which ".$vars->{table}." number to clone."; exit;}
	 my $record = &db_get_record($dbh,$vars->{table},{$vars->{table}."_id" => $vars->{id}});
	 $record->{$vars->{table}."_crdate"} = time;
	 $record->{$vars->{table}."_creator"} = $Person->{person_id};
	 $record->{$vars->{table}."_id"} = "new";
   print "Cloning ".$record->{$vars->{table}."_title"}.": ";
	 my $id = record_save($dbh,$record,$vars->{table},$record);
   print qq|Created new <a href="|.$Site->{st_url}.$vars->{table}.qq|/$id" target="_new">|.$vars->{table}.qq| number $id</a> |;
	 print qq|[<a href="#" onclick="openMain('$Site->{script}','edit','$vars->{table}','$id');">Edit</a>]|;
	 exit;
}


# API AUTOPOST ----------------------------------------------------------
# ------- Clone Record -----------------------------------------------------
#
# Give a link id and a post based on the link is created
#
# -------------------------------------------------------------------------
#


sub api_autopost {

   $vars->{table} = "link";
	 my $url = $Site->{st_cgi}."api.cgi";
   unless ($vars->{id}) { return "Don't know which ".$vars->{table}." number to clone."; exit; }
	 my $post_id = &auto_post($dbh,$query,$vars->{id});
	 if ($post_id > 0) { return qq|<a onclick="openMain('$url','edit','post','$post_id');alert('Autopost Submitted');openDiv('$url','Reader','show','link','$vars->{id}');$('#Edit').tab('show');">Edit Post</a>|; }
   else { return $post_id; } # which will be an error message
	 exit;
}


# Legacy

if ($vars->{app}) {



  # Edit

  if ($vars->{app} eq "edit") {

		 unless ($vars->{db}) { print "Table to $vars->{app} has not been specified."; exit; }

		 my $tabs = "";
		 print &main_window($tabs,"Edit");
		 exit;
	}

  # List
  elsif ($vars->{app} eq "list") {

		 unless ($vars->{db}) { print "Table to $vars->{app} has not been specified."; exit; }
     print &list_records($dbh,$query,$vars->{db});
		 exit;
	}

  # List Tables
  elsif ($vars->{app} eq "list_tables") {
     print &list_tables($dbh);
		 exit;
  }

	# Show Columns from Tables
  elsif ($vars->{app} eq "show_columns") {
	   print &show_columns($vars->{db});
		 exit;
	}

	# Admin
  elsif ($vars->{app} eq "admin") {
	   print &main_window(['Database','text','moretext'],'Database');
		 exit;
	}

  # Unrecognized
  else {
	   print "App command (".$vars->{app}.") not recognized.";
		 exit;
  }

}

# -------------------------------------------------------------------------------------
#          Update Functions
#
# Submit or modify content
#
# -------------------------------------------------------------------------------------




if ($vars->{updated}) {


	# Restrict to Admin

		&admin_only();


	# Verify Data

	die "Table name not provided" unless ($vars->{table_name});
	die "Table ID not provided" unless ($vars->{table_id});
	die "Column name not provided" unless ($vars->{col_name});
	die "Input value not provided" unless ($vars->{value});
	die "Input type not provided" unless ($vars->{type});


	if ($vars->{type} eq "text" || $vars->{type} eq "textarea"  || $vars->{type} eq "wysihtml5" || $vars->{type} eq "select") {  &api_textfield_update(); }

	elsif ($vars->{type} eq "keylist") { &api_keylist_update();  }


	elsif ($vars->{type} eq "remove") { &api_keylist_remove(); }

  # record publish
	elsif ($vars->{type} eq "data") { &api_data_update();  }

  # file upload
	elsif ($vars->{type} eq "file") { &api_file_upload(); }

  # url upload
	elsif ($vars->{type} eq "file_url") { &api_url_upload(); }

  # record publish
	elsif ($vars->{type} eq "publish") { &api_publish(); }

  # column create
	elsif ($vars->{type} eq "column") { &api_column_create(); }

  # column update
	elsif ($vars->{type} eq "alter") { &api_column_alter(); }

  # column remove
	elsif ($vars->{type} eq "column_remove") { &api_column_remove(); }

	elsif ($vars->{type} eq "commit") { &api_commit(); }



    # Identify, Save and Associate File

  #	my $file;
  #	if ($query->param("file_name")) { $file = &upload_file($query); }		# Uploaded File
  #	elsif ($vars->{file_url}) { $file = &upload_url($vars->{file_url}); }		# File from URL



  #my $return = &form_graph_list("post","60231","author");

	# &send_email('stephen@downes.ca','stephen@downes.ca', 'api failed', 	qq|Table ID  - |.$vars->{table_id}.qq|	Column  - |.$vars->{col_name}.qq|	Input value  - |.$vars->{value}.qq|	Input type  - |.$vars->{type}.qq|$return|);


	#print $return;

	exit;


} elsif ($vars->{search}) {

	# Sanitize seach input
	$vars->{query} =~ s/[^a-zA-Z0-9\ \.]*//g;

  my $lang_where = "";
  if ($vars->{language} && $vars->{language} ne "All") {
		  $lang_where = "course_language LIKE '%".$vars->{language}."%' AND ";
	}

	# Count Results
	my $count = &db_count($dbh,"course"," WHERE $lang_where (course_title LIKE '%".$vars->{query}."%' OR course_description LIKE '%".$vars->{query}."%')");


  # Start and Limit
  my $limit; my $results_per_page = 10; my $start=0;
  unless ($vars->{page}) { $vars->{page}=0;}
	if ($vars->{page} > 0) 	{ $start = $vars->{page}*10; $limit = "LIMIT $start,$results_per_page"}
	else { $limit = "LIMIT $results_per_page"; }
	my $end = $start+$results_per_page; my $s = $start+1;
	my $results_range = "$s to $end of $count";


  # Orderby
	my $orderby = "";

	if ($vars->{sort} eq "Title") {
		$orderby = " ORDER BY course_title";
	} else  {
		$vars->{sort} = "Recent";
		$orderby = " ORDER BY course_crdate DESC";
	}



  # Output headers, depending on request format

	# links
	if ($vars->{format} eq "links") {

		# Search Title
		my $p = $vars->{page}+1;
		print qq|<div style="padding:2%">Searching for: |.($vars->{query} || "Everything").
					qq|<br>Sort: $vars->{sort} <br>Page $p: $results_range </div></p><hr>|;

		if ($vars->{query} eq "") {

			#print qq|<a href="javascript:void(0)" onclick="openMail('Welcome');w3_close();" id="firstTab">Welcome</a>|;}
		}

  }

	elsif ($vars->{format} eq "summary") {

		# Print mobile hamburger menu
		print qq|
			<i class="fa fa-bars w3-button w3-white w3-hide-large w3-xlarge w3-margin-left w3-margin-top" onclick="w3_open()"></i>
			<a href="javascript:void(0)" class="w3-hide-large w3-red w3-button w3-right w3-margin-top w3-margin-right" onclick="document.getElementById('id01').style.display='block'">
			<i class="fa fa-pencil"></i></a>|;

		# Print welcome message
		unless ($vars->{query})  {
			print qq|
 				<div id="Welcome" class="w3-container person">
				<br>
				<img class="w3-round  w3-animate-top" src="https://www.w3schools.com/w3images/avatar3.png" style="width:20%;">
				<h5 class="w3-opacity">Welcome to MOOC.ca</h5>
				<h4><i class="fa fa-clock-o"></i> Your host for free and open online learning content</h4>
				<hr>
				<p>MOOC.ca was created as a demonstration of open educational resource aggregation. The page you are viewing is
				an interface to our search function; use this to get a sense of the range of resources listed on this site.
				Click on the search button (upper left) to enter your query.</p>
				</div>
			|;
		}
	}


  # Execute search
	my $sql = "SELECT * FROM  course	WHERE $lang_where (course_title LIKE ? OR course_description LIKE ?) $orderby $limit ";
	# print $sql;

	my $sth = $dbh->prepare($sql) || die "Error: " . $dbh->errstr;
  $sth->execute("%".$vars->{query}."%","%".$vars->{query}."%")
		    || die "Error: " . $dbh->errstr;

  # Define defaults to identify first results
	my $firsttab = ""; if ($vars->{query}) { $firsttab = qq| id="firstTab"|; }

	my $block = qq|style="display:none;"|; if ($vars->{query}) { $block = qq|style="display:block;"|; }

	# Cycle through search results
	while (my $course = $sth -> fetchrow_hashref()) {

  	# Output search result, depending on request format

		if ($vars->{format} eq "links") {

   		print qq|<a href="javascript:void(0)" class="w3-bar-item w3-button w3-border-bottom test w3-hover-light-grey"
	    	onclick="openMail('course_|.$course->{course_id}.qq|');w3_close();" $firsttab>
      	<div class="w3-container">
        <img class="w3-round w3-margin-right" src="http://www.mooc.ca/images/|.$course->{course_provider}.qq|.icon.JPG" style="width:10%;">
				<span class="w3-opacity w3-large">$course->{course_title} </span>
        <p> </p>
      	</div>
    		</a>
			|;
    	$firsttab = "";

		} elsif ($vars->{format} eq "summary") {

      my $provider = &keylist("db=course;id=$course->{course_id};keytable=provider;");
			print qq|
				<div id="course_|.$course->{course_id}.qq|" class="w3-container person" $block>
  			<br>
  			<img class="w3-round w3-animate-top" src="http://www.mooc.ca/images/|.$course->{course_provider}.qq|.JPG" style="width:50%;">
  			<h5 class="w3-opacity">$course->{course_provider}</h5>
  			<h4><i class="fa fa-clock-o"></i> $course->{course_title}</h4>
  			<a target="_new" href="|.$course->{course_url}.qq|" class="w3-button w3-light-grey">View Course<i class="w3-margin-left fa fa-arrow-right"></i></a>
  			<hr>
				<p>Provider: $course->{course_provider}<p>
				<p>Language: $course->{course_language} <p>
  			<p>$course->{course_description}</p><p>Retrieved: |.&nice_date($course->{course_crdate},"day").qq|</p>
				</div>
    	|;
    	$block = qq|style="display:none;"|;

		}
	}

  # Output search footer, depending on request format


  if ($vars->{format} eq "links") {
		my $pg = $vars->{page}+1;
  	print qq|<div style="padding:2%"><a href="#" onClick="search_function('$vars->{query}','$vars->{language}','$vars->{sort}','links','Demo1',$pg);
	     search_function('$vars->{query}','$vars->{language}','$vars->{sort}','summary','Results-Content',$pg);">Next |;
		print $results_per_page;
		print qq| of $count results</a></div>|;
  }

	exit;

}

# Print OK for blank api request
print "OK";
exit;
