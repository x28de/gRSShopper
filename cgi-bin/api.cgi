#!/usr/bin/env perl

#    gRSShopper 0.7  API 0.01  -- gRSShopper api module
#    7 May 2017 - Stephen Downes

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

	use File::Basename;												
	use CGI::Carp qw(fatalsToBrowser);
	my $dirname = dirname(__FILE__);								
	require $dirname . "/grsshopper.pl";	
								

# Load modules

	our ($query,$vars) = &load_modules("api");


# Load Site

	our ($Site,$dbh) = &get_site("api");									





# Get Person  (still need to make this an object)

	our $Person = {}; bless $Person;				
	&get_person($dbh,$query,$Person);		
	my $person_id = $Person->{person_id};
	



# Restrict to Admin

	&admin_only();		
		



my $str; while (my ($x,$y) = each %$vars) 	{ $str .= "$x = $y <br>\n"; }
&send_email('stephen@downes.ca','stephen@downes.ca', 'api in',$str); 


	


if ($vars->{updated}) { 


	if ($vars->{type} eq "text" || $vars->{type} eq "wysihtml5" || $vars->{type} eq "select") {  &api_textfield_update(); }

	elsif ($vars->{type} eq "keylist") { &api_keylist_update();  }

	elsif ($vars->{file_name}) { &api_file_upload();





    # Identify, Save and Associate File

#	my $file;
#	if ($query->param("file_name")) { $file = &upload_file($query); }		# Uploaded File
#	elsif ($vars->{file_url}) { $file = &upload_url($vars->{file_url}); }		# File from URL
	}


#my $return = &form_graph_list("post","60231","author");

	


	print $return;
	exit;

}


	print "Content-type: text/html\n\n";
	print "ok";
	exit;



# API Keylist Update
#
# Find or, if not found, create a new $key record named $value
# Then create a graph entry linking the new $key with $table $id
#

sub api_keylist_update {

	my ($table,$key) = split /_/,$vars->{name};
	my $id = $vars->{table_id};
	my $value = $vars->{value};

	# Split list of input $value by ;
	my @keynamelist = split /;/,$value;

	# For each member of the list...
	foreach my $keyname (@keynamelist) {			

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

}



sub api_textfield_update {

my $str; while (my ($x,$y) = each %$vars) 	{ $str .= "$x = $y <br>\n"; }
&send_email('stephen@downes.ca','stephen@downes.ca', 'testfield update',$str); 

	my $id_number = &db_update($dbh,$vars->{table_name}, {$vars->{name} => $vars->{value}}, $vars->{table_id});
	if ($id_number) { &api_ok();   } else { &api_error(); }
	#die "api failed to update $vars->{table_name}  $vars->{table_id}";
    #enless ($id_number);


}

sub api_ok {


	print "&nbsp;&nbsp;&nbsp;&nbsp;ok!";
	exit;

}

sub api_error {


	print "300 API Error - failed to update $vars->{table_name}  $vars->{table_id} \n";
	exit;

}

sub api_file_upload {

						



    # Upload the file

    my $file = &upload_file($query); 

    $str .= "Uploaded<br>";
    while (my ($x,$y) = each %$file) 	{ $str .= "$x = $y <br>\n"; }

	# Save file data in database

	api_save_file($file);




	

	
}

sub api_save_file {

	my ($file) = @_;

	# Reject unless there's a full file name
	return unless ($file->{fullfilename});

	# Save the file
	my $file_record = &save_file($file);
	die "Error saving file" unless ($file_record);

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


my $str; while (my ($x,$y) = each %$vars) 	{ $str .= "$x = $y <br>\n"; }
while (my ($x,$y) = each %$file) 	{ $str .= "$x = $y <br>\n"; }
$str .= "Graph: $graphid <p>"; 


&send_email('stephen@downes.ca','stephen@downes.ca', 'file upload',$str);




	

return;

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
