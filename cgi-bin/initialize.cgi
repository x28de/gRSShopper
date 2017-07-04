#!/usr/bin/env perl
print "Content-type:text/html\n\n";
print "in";

#-------------------------------------------------------------------------------
#
#	    gRSShopper 
#           Initialization Functions 
#           20 March 2017 - Stephen Downes
#
#-------------------------------------------------------------------------------

# Forbid bots

	die "HTTP/1.1 403 Forbidden\n\n403 Forbidden\n" if ($ENV{'HTTP_USER_AGENT'} =~ /bot|slurp|spider/);
	
	

# Load gRSShopper

	use File::Basename;												
	use CGI::Carp qw(fatalsToBrowser);
	my $dirname = dirname(__FILE__);								
	require $dirname . "/grsshopper.pl";	
	
	


# Load modules

	our ($query,$vars) = &load_modules("initialize");
    	while (my ($vx,$vy) = each %$vars) { 
  #  		print "$vx = $vy <br>";

	}
	
	
	
# Load Site	

our $Site = gRSShopper::Site->new({									# Create new Site object
	no_db		=>	'1',									#   no database
	context		=>	'initialize',
	data_dir	=>	'/var/www/cgi-bin/data/',		
});

print "Actrion ",$vars->{action},"<br>";

if ($vars->{action}) {					# Perform Action, or

	if ($vars->{action} eq "command") { &__command(); }
	elsif ($vars->{action} eq "file") {  &__multisite_form($vars->{action}); }
	elsif ($vars->{action} eq "url") {  &__multisite_form($vars->{action}); }	
	elsif ($vars->{action} eq "db") {   &__multisite_form($vars->{action}); }	
	elsif ($vars->{action} eq "multisite") {   &__init_in_multisite($vars); }
	else { &__init_error($vars->{action}) }
} 

exit;

#  Multisite Form 
  #
  #  Form to input values for database access
  #
  
  sub __multisite_form {

  	my ($action) = @_;					

	# Create or update database information	
	# to be stored in multisite.txt file
	if ($action eq "file" || $action eq "url") {	
		
		$Site->{database}->{loc} ||= "localhost";
		print "Content-type: text/html\n\n";
		print qq|			<form action="initialize.cgi" method="post">

		<!-- DB Administrator Info -->
			Please enter database information for $Site->{st_host}
			<br>
			<br><table cellspacing=1 cellpadding=2 border=0>
			<tr><td colspan=2><br>Please enter database administrator information<br> (required to create databases and grant privileges)<br><br></td></tr>

			<tr><td align="right">Admin Username</td><td><input type="text" name="admin_usr" value=""></td></tr>
			<tr><td align="right">Admin Password</td><td><input type="password" name="admin_pwd" value=""></td></tr>			
	
	
		<!-- Database Info -->
			<tr><td colspan=2><br>Database Information:<br><br></td></tr>
			<input type="hidden" name="st_host" value="$Site->{st_host}">
			<tr><td align="right">Database Name</td><td><input type="text" name="db_name" value="$Site->{database}->{name}"></td></tr>
			<tr><td align="right">Database Location</td><td><input type="text" name="db_loc" value="$Site->{database}->{loc}"></td></tr>
			<tr><td align="right">Database Username</td><td><input type="text" name="db_usr" value="$Site->{database}->{usr}"></td></tr>
			<tr><td align="right">Database Password</td><td><input type="password" name="db_pwd" value="$Site->{database}->{pwd}"></td></tr>
			<tr><td align="right">Language</td><td><input type="text" name="site_language" value="$Site->{site_language}"></td></tr>	
			<tr><td align="right">Site Content Directory</td><td><input type="text" name="st_urlf" value="$Site->{st_urlf}"></td></tr>
			<tr><td align="right">Site CGI Directory</td><td><input type="text" name="st_cgif" value="$Site->{st_cgif}"></td></tr>								
			
			
		<!-- Site Info -->
		
			<tr><td colspan=2><br>Site Information:<br><br></td></tr>		
			<tr><td align="right">Site Name</td><td><input type="text" name="st_name" value="$Site->{st_name}"></td></tr>
			<tr><td align="right">Site Tag</td><td><input type="text" name="st_tag" value="$Site->{st_tag}"></td></tr>
			<tr><td align="right">Site Email Address</td><td><input type="text" name="st_email" value="$Site->{st_email}"></td></tr>
			<tr><td align="right">Site Time Zone</td><td><input type="text" name="st_timezone" value="$Site->{st_timezone}"></td></tr>
			<tr><td align="right">License</td><td><input type="text" name="st_license" value="$Site->{st_license}"></td></tr>
			<tr><td align="right">Site Key</td><td><input type="text" name="st_key" value="$Site->{st_key}"></td></tr>					  

		<!--  Site Administrator -->
		
			<tr><td colspan=2><br>Site Administrator:<br><br></td></tr>		
			<tr><td align="right">Administrator Username</td><td><input type="text" name="site_admin_name"></td></tr>
			<tr><td align="right">Administrator Password</td><td><input type="password" name="site_admin_pwd"></td></tr>

			
					
			
			<tr><td></td><td><br><input type="submit" name="action" value="multisite"><br>
			</td></tr></table><br/><br/><p>
			</form>
			<a href="admin.cgi">Return to Admin</a>|;
			
	}


			  
			  			
			
	elsif ($action eq "db") {
		
		print "Content-type: text/html\n\n";
			
		print "Need to create DB<p>";
		print "Data dir is: ",$Site->{data_dir},"<p>";
		
		$Site->__dbinfo();
		
		
		print "DB Name: ",$Site->{database}->{name},"<p>";
		
	}
 
 
  }



    sub __init_in_multisite {
    	

    	
    	# Restrict input characters
    	while (my ($vx,$vy) = each %$vars) { 
    		print "$vx = $vy <br>";
		if ($vars->{$vx} =~ /[^\/\\\-0-9a-zA-Z_,\0#@&;\.]/) { 
			print "Content-type: text/html\n\n";
			print "<h1>Input Error in $vars->{$vx} </h1><p>Allowed characters for input: a-zA-Z0-9 # @ & . ; / \</p>";
			exit;
			}
	}
	$vars->{site_language} =~ s/\0/,/i;    	
											# Open the multisite configuration file,
											# Initialize if file can't be found or opened
  	my $data_file = $Site->{data_dir} . "multisite.txt";			
  	my $output = "";
  					
	if (-e $data_file) {								# If the multisite configuration file exists
		open IN,"$data_file" or die "Can't open $data_file to read";		#    open it

		my $url_located = 0;							
		while (<IN>) {								#    read each line
			my $line = $_; 
			next if ($line =~ /^$Site->{st_host}/);				#    if it's the current site, skip
			$output .= $line;						#    otherwise write data to output
		}
		close IN;
		
    	}	
    	

	
											#    write current site data to output
	my $new_line = qq|$Site->{st_host}\t$vars->{db_name}\t$vars->{db_loc}\t$vars->{db_usr}\t$vars->{db_pwd}\t$vars->{site_language}\t$vars->{st_urlf}\t$vars->{st_cgif}\n| or die "Cannot write to $data_file";
	$output .= $new_line;
    				
	open OUT,">$data_file" or die "Cannot open $data_file: $!";		# Save output
	print OUT $output  or die "Cannot save to $data_file: $!";		# Save output;
	close OUT;
	
	# Load database information into the $Site object
	$Site->__dbinfo();
	

	# Create Database	
	# Note: windows users must perform this step manually
	my $dbsetup="create database ".$vars->{db_name}.";GRANT ALL PRIVILEGES ON ".
		$vars->{db_name}.".* TO ".$vars->{db_usr}."@".$vars->{db_loc}.
		" IDENTIFIED BY '".$vars->{db_pwd}."';FLUSH PRIVILEGES;";
	my $mysqluser = $vars->{admin_usr};
	my $mysqlpass = $vars->{admin_pwd};
	my $mysqldb = $vars->{db_name};
	`mysql -u $mysqluser -p$mysqlpass -e "$dbsetup"`;

	
	# Connect to Database
	$Site->__db_connect({initialize => "new"});
	print "Created database",$vars->{db_name},"<p>";	
	
	
	# Write gRSShopper tables
	# Note: windows users must perform this step manually	
	$sqlresult = `mysql -u $mysqluser -p$mysqlpass $mysqldb < sql/grsshopper_tables.sql`;
	print "Built database tables. ",$sqlresult,"<p>";
	
	# Connect to Database
	$Site->__db_connect();
	print "$dbsetup  <p>";
	print "Connected to database<p>";	
	
	# Write Config
	my $dbh = $Site->{dbh};
	$vars->{st_pub} = $vars->{st_email};
	$vars->{st_crea} = $vars->{st_email};	
	$vars->{st_reset_key} = $vars->{st_key};
	$vars->{st_cronkey} = $vars->{st_key};	
	my @configs = qw(st_name st_tag st_pub st_crea st_license st_timezone st_reset_key st_cronkey);
	foreach $config (@configs) {
	   &db_insert($dbh,"","person",{config_noun=>$config,config_value=>$vars->{$config}});		
	}
	print "Stored site config information in database<p>";
	
	# Create Admin and anon Accounts
	# Note: windows users must perform this step manually	
	my $site_admin_name = $vars->{site_admin_name};
	my $encryptedPsw = &encryptingPsw($vars->{site_admin_pwd}, 4);
	my $id_number = &db_insert($dbh,"","person",{person_title=>$site_admin_name,person_password=>$encryptedPsw,person_status=>"admin"});
	if ($id_number) { print qq|Created Site Administrator - <a href="admin.cgi">click here to login</a><p>|; }
	else { print qq|error creating admin user.|; }
	
		
		
	#&__multisite_form("Updated");						# Show the form again
 
 
  qq|
 Site Name :	
Stephen's Web
Site Tag :	
#oldaily
Publisher :	
stephen@downes.ca
Creator :	
stephen@downes.ca
License :	
CC By-NC-SA
Time Zone :	
America/Toronto
Reset Key :	
excalibur
Cron Key :	
excelsior
|;
   	
	print "Done";
  	
    }
    
    
    


sub __command {
	
	if ($vars->{cause} eq "file") {  $Site->__multisite_form($vars->{action}); }
	elsif ($vars->{cause} eq "url") {   $Site->__multisite_form($vars->{action}); }	
	else { __init_error($vars->{action}) }
	
} 



  sub __init_error {
  
	my ($action) = @_;
	print "Content-type: text/html\n\n";
	print qq|
			Initialization error. Did not recognize the following command: $action <p>
	|;
  
  
  }
  
