#!/usr/bin/env perl



#    gRSShopper 0.7  Harvester  0.5  -- gRSShopper harvester module
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
#           Harvester 
#
#-------------------------------------------------------------------------------




use strict;

print "Content-type: text/html; charset=utf-8\n\n";
print "OK";
use CGI::Carp qw(warningsToBrowser fatalsToBrowser); 
our $DEBUG = 1;							# Toggle debug



# Forbid bots

	die "HTTP/1.1 403 Forbidden\n\n403 Forbidden\n" if ($ENV{'HTTP_USER_AGENT'} =~ /bot|slurp|spider/);	
						

# Load gRSShopper

	use File::Basename;												
	use CGI::Carp qw(fatalsToBrowser);
	my $dirname = dirname(__FILE__);								
	require $dirname . "/grsshopper.pl";	

# Load modules

	our ($query,$vars) = &load_modules("admin");
	$vars->{msg} = "Messages<p>";


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


# Restrict to Admin

	if ($vars->{context} eq "cron") { &cron_tasks($dbh,$query,$ARGV); } else { &admin_only(); }		
	



$vars->{feed} = 7433;
$vars->{action} = "harvest";

my $action = $vars->{action};
for ($action) {					# There is always an action

	/queue/ && do { &harvest_queue(); last; 		};
	/harvest/ && do { &harvest_feed($vars->{feed}); last; 		};
	/export/ && do { &export_opml($dbh,$query); last;	};
	/import/ && do { &import_opml($dbh,$query); last;	};
	/opmlopts/ && do { &opmlopts($dbh,$query); last;	};

						# Go to Home Page


	exit;

}



# -------   Harvest Feed ------------------------------------------------------

# Harvests feed specified on input

sub harvest_feed {
	
	my ($feedid) = @_;
print "Hatrvesting $feedid";
	my $feedrecord = gRSShopper::Feed->new({dbh=>$dbh,id=>$feedid});
	$feedrecord->{crdate} = time;

	unless ($feedrecord) {
		&diag(1,"Could not find a record for feed number $feedid<br>\n");
		return;
	}	
	
	
	if ($feedrecord->{feed_type} =~ /twitter/i) {
		&harvest_twitter($feedrecord);
	} elsif ($feedrecord->{feed_type} =~ /facebook/i){
		&harvest_facebook($feedrecord);
	} else {
		
		use LWP::Simple;
		$feedrecord->{feedstring} = get($feedrecord->{feed_link});
		&get_url($feedrecord,$feedid);
		#print $feedrecord->{feedstring};
	}


my $str;


    use JSON::Parse 'parse_json';
    
    
    # Test file
	# open IN,"/var/www/downes/files/edx.json";
	# while (<IN>) { 
	# chomp;
	# $str .= $_;
	# }


	# Beak JSON Lines file into courses
	my @courses;
	while ($feedrecord->{feedstring} =~ s/{(.*?)}//s) { push @courses, $1; }

	# For each course
	my $courseinfo;
	foreach my $course (@courses) { 
print "$course <hr>";
		# Parse the JSON Data
		my $coursedata = parse_json ("{$course}");
		
		
		&save_course($coursedata);

		
	
	}
	


exit;

	

	
}	

sub save_course {
	
	my ($coursedata) = @_;
	

	
	# Normalize Harvested Data 
	my $fr;	# Feed Record holding new course data
	while (my ($fx,$fy) = each %$coursedata) { 
		$fr->{"course_".$fx} = $fy; 
	}

	# Initialize Course Data
	$fr->{course_crdate} = time;
	$fr->{course_creator} = $Person->{person_id};

	while (my ($fx,$fy) = each %$fr) { 
		print "$fx = $fy <br>"; 
	}
			
	# Save the Course
	my $courseid = &db_insert($dbh,$query,"course",$fr);
	print $courseid;
exit;	
	# Search for Provider
	my $providerid = &db_locate($dbh,$query,"provider",{provider_title=>$fr->{course_provider}});
	
	# Create provider if not found
	unless ($providerid) {
		$providerid = &save_provider($fr->{course_provider});
	}
	
	# Save graph of provider and course
	my $graphid = &db_insert($dbh,$query,"graph",{
		graph_tableone=>"course", graph_idone=>$courseid, graph_urlone=>$fr->{course_url},
		graph_tabletwo=>"provider", graph_idtwo=>$providerid, graph_urltwo=>"",
		graph_creator=>$Person->{person_id}, graph_crdate=>$fr->{course_crdate}, graph_type=>"course provider", graph_typeval=>""}); 
	
	return $graphid;
	
}


sub save_provider {
	
	
	my ($pr) = @_;
	
	# Initialize Provider Data
	$pr->{provider_title} = $pr;
	$pr->{provider_crdate} = time;
	$pr->{provider_creator} = $Person->{person_id};	
	
	# Save Provider Data
	my $providerid = &db_insert($dbh,$query,"provider",$pr);	
	
	# Return new provider ID
	return $providerid;
	
}
	
	
