#!/usr/bin/env perl
print "Content-type:text/html\n\n";

#-------------------------------------------------------------------------------
#
#	    gRSShopper 
#           Initialization Functions 
#           20 March 2017 - Stephen Downes
#
#-------------------------------------------------------------------------------

die "HTTP/1.1 403 Forbidden\n\n403 Forbidden\n" if
	($ENV{'HTTP_USER_AGENT'} =~ /bot|slurp|spider/);						# Forbid bots

use File::Basename;											# Load gRSShopper
use CGI::Carp qw(fatalsToBrowser);
my $dirname = dirname(__FILE__);								
require $dirname . "/grsshopper.pl";	

our ($query,$vars) = &load_modules("initialize");							# Load modules

our $Site = gRSShopper::Site->new({									# Create new Site object
	no_db		=>	'1',									#   no database
	context		=>	'initialize',
	data_dir	=>	'/var/www/cgi-bin/data/',		
});



if ($vars->{action}) {					# Perform Action, or

	if ($vars->{action} eq "command") { &__command(); }
	elsif ($vars->{action} eq "file") {  $Site->__multisite_form($vars->{action}); }
	elsif ($vars->{action} eq "url") {   $Site->__multisite_form($vars->{action}); }	
	elsif ($vars->{action} eq "Initialize Site") {   $Site->__initialize_site($vars); }
	else { __init_error($vars->{action}) }
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
  
