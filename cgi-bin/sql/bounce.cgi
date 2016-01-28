#!/usr/bin/env perl

# bounce.cgi


# Usage requires that incoming email be redirected to this script

# First check if you have pcre compiled into Posfix with postconf -m. Then you can set in main.cf:
# virtual_alias_maps = pcre:/etc/postfix/redirect.pcre
# and in /etc/postfix/redirect.pcre you put:
# /^user-.*@example\.com$/   somelocalalias
# and in /etc/aliases you add
# somelocalalias: |"/path/to/bounce.cgi"
# Don't forget to postalias /etc/aliases and afterwards reload Postfix with postfix reload.


	use CGI::Carp qw(fatalsToBrowser);


# print "Content-type: text/html\n\n";

 
# Forbid agents

if ($ENV{'HTTP_USER_AGENT'} =~ /bot|slurp|spider/) { 
  	print "Content-type: text/html; charset=utf-8\n";
	print "HTTP/1.1 403 Forbidden\n\n";
	print "403 Forbidden\n"; 
	exit; 
}


# Initialize gRSShopper Library

# FindBin doesn't work on ModCGI
#use FindBin qw($Bin);
#require "$Bin/grsshopper.pl";

use File::Basename;
my $basepath = dirname(__FILE__);
require $basepath . "/grsshopper.pl";

our ($query,$vars) = &load_modules("admin");			# Request Variables

our ($Site,$dbh) = &get_site("admin");				# Site
if ($vars->{context} eq "cron") { $Site->{context} = "cron"; }


our $Person = {}; bless $Person;				# Person  (still need to make this an object)
&get_person($dbh,$query,$Person);		
my $person_id = $Person->{person_id};



my $options = {}; bless $options;		# Initialize system variables
our $cache = {}; bless $cache;	


if ($vars->{api}) { print "ok"; exit; }

						# Restrict to Admin
if ($Site->{context} eq "cron") { &cron_tasks($dbh,$query,$ARGV); } else { &admin_only(); }






    use Net::IMAP::Simple;
    use Email::Simple;
    
        
print "Content-type: text/html\n\n";
print "<pre>Bounce<br>";

    # Create the object
    my $imap = Net::IMAP::Simple->new('mail.downes.ca') ||
       print "Unable to connect to IMAP: $Net::IMAP::Simple::errstr\n";

    # Log on
    if(!$imap->login('downes','D2vidhume')){
        print "Login failed: " . $imap->errstr . "\n";
        exit(64);
    }
    
    # Init Variables
    my $foundemails = "BOUNCED EMAILS\n\n";
    my @email_list;
    my $number_bounced = 0;
    my $failedtofind = "FAILED TO FIND\n\n";
    
    
    # Print the subject's of all the messages in the INBOX
    my $nm = $imap->select('INBOX');

    for(my $i = 1; $i <= $nm; $i++){

        my $es = Email::Simple->new(join '', @{ $imap->top($i) } );

#	my $from_header = $es->header("From");
	my @headers = $es->header_pairs;	

	my $key = 1; my $headers = (); my $keyname = ""; my $hvals="";
	foreach my $h (@headers) {
	    if ($key == 1) { $keyname = $h; $key = 0; $hvals .= "$h = ";} 
	    else { $key = 1; $headers->{$keyname} = $h; $hvals .=  "$h <br>\n";}
	}
	
	if ($headers->{Subject} =~ /returned/i || $headers->{Subject} =~ /failure/i) {
	    
		my $message = $imap->get( $i ) or print $imap->errstr;

		
		# Find bounce address							- Original-Recipient
		$message =~ s/Original-Recipient:\s*(.*?)\n//mig;
		my $em = $1;
		
		# Find bounce address							- Final-Recipient
		unless ($em) {
			$message =~ s/Final-Recipient:(.*?)\n//mig;		    
			$em = $1;
		}
		
		# Find bounce address							- Failed permanently		
		unless ($em) {
			$message =~ s/Delivery to the following recipient failed permanently:\s*(.*?)\s//mig;		    
			$em = "$1";
		}
		
		$em =~ s/rfc822;//ig;
		$em =~ s/^\s*(.*?)\s*$/$1/;
		
		if ($em) { $foundemails .= $em."\n"; push @email_list,$em; $number_bounced++; }
		else { $failedtofind .= $message . "\n\n----------------------------------------------------------------------\n\n";; }

	
		 
	}
	
#	my @received = $es->header("Received");
#	my $old_body = $es->body;
#	print "<hr>";
#	print "From: $from_header<br>";
#	print "Header: ",@headers,"<br>";
#	print "Received: ",@received,"<br>";
#	print "Body: $old_body <br><br>";
#	print $es->as_string;


#        printf("[%03d] %s\n<br>", $i, $es->header('Subject'));
    }
    
    
    
    
    
my $found_ids = "";    
foreach my $found_email (@email_list) {
	

		my $found_id = &db_locate($dbh,"person",{person_email=>$found_email});
		if ($found_id) {
			
			&db_delete($dbh,"person","person_id",$found_id);
			
			$found_ids .= "-- ".$found_id." --" . "\n";
		}
	
	
}    
    
    

my $admin_message = qq|

	$number_bounced $foundemails
	$failedtofind
	
	DELETED RECORDS
	
	$found_ids
|;


print $admin_message;

    $imap->quit;


my $Mailprog = "/usr/sbin/sendmail";
my $to = 'Stephen.Downes@nrc-cnrc.gc.ca';	
my $from = 'stephen@downes.ca';
$Site->{st_name} =~ s/&#39;/'/g;
my $subject = "Subject: $Site->{st_name} $number_bounced Bounced Emails";
	
open (MAIL,"|$Mailprog -t") or die "Can't find email program $Mailprog";


print MAIL "To: $to\nFrom: $from\n$subject\n\n$admin_message"
			or print "Email format error: $!";



