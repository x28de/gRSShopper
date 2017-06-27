#!/usr/bin/env perl
print "Content-type:text/html\n\n";

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
	
	
# Load Site	

our $Site = gRSShopper::Site->new({									# Create new Site object
	no_db		=>	'1',									#   no database
	context		=>	'initialize',
	data_dir	=>	'/var/www/cgi-bin/data/',		
});



if ($vars->{action}) {					# Perform Action, or

	if ($vars->{action} eq "command") { &__command(); }
	elsif ($vars->{action} eq "file") {  __multisite_form($vars->{action}); }
	elsif ($vars->{action} eq "db") {   __multisite_form($vars->{action}); }	
	elsif ($vars->{action} eq "Initialize Site") {   __initialize_site($vars); }
	else { __init_error($vars->{action}) }
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
	if ($action eq "file") {	
		
		
		print "Content-type: text/html\n\n";
		print qq|
			Please enter database information for $self->{st_host} 
			<br>
			Please provide database information in the form below:
			<form action="initialize.cgi" method="post">
			<br><table cellspacing=1 cellpadding=2>
			<input type="hidden" name="st_host" value="$self->{st_host}">
			<input type="hidden" name="cause" value="$cause">
			<tr><td align="right">Database Name</td><td><input type="text" name="db_name" value="$self->{database}->{name}"></td></tr>
			<tr><td align="right">Database Location</td><td><input type="text" name="db_loc" value="$self->{database}->{loc}"></td></tr>
			<tr><td align="right">Database Username</td><td><input type="text" name="db_usr" value="$self->{database}->{usr}"></td></tr>
			<tr><td align="right">Database Password</td><td><input type="password" name="db_pwd" value="$self->{database}->{pwd}"></td></tr>
			<tr><td></td><td><input type="submit" name="action" value="Initialize Site"></td></tr></table><br/><br/>Context: $cause<p>
			<a href="admin.cgi">Return to Admin</a>|;
			
	}
			
			
	elsif ($action eq "db") {
		
		print "Content-type: text/html\n\n";
			
		print "Need to create DB<p>";
		
	}
 
 
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
  
