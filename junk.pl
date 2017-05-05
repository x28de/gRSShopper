

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
print "Set field $table<br>";	
	my $tableid = &db_locate($dbh,"element",{element_title=>$table});
	my $table_data = &db_get_single_value($dbh,"element","element_data",$tableid);
	my @fieldlist = split /;/,$table_data;
   	foreach my $f (@fieldlist) {

   		my @f_items = split /,/,$f; $f = $f_items[0];
 
		$fields->{$f} = $table."_".$f;
	}
	
	return $fields

}









#          $dbh->{RaiseError} = 1;

#my $crvotetable = qq|CREATE TABLE `element` (
#  `element_id` int(15) NOT NULL auto_increment,
#  `element title` int(15) default NULL,
#  `element_edit` boolean default TRUE,
#  `element_view` boolean default TRUE,
#  `element_fields` text default NULL,
#  PRIMARY KEY  (`element_id`)
#) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;|;

#my $asth = $dbh -> prepare($crvotetable);
#	$asth -> execute();
# print "Content-type:text/html\n\n";
# print $@;

#my $t = time;
#print &tz_date($query,$t);

# my $eth = $dbh->prepare("TRUNCATE TABLE link");
# $eth->execute();

# my $eth = $dbh->prepare("TRUNCATE TABLE feed");
# $eth->execute();


#	my $alterstmt = "ALTER TABLE page MODIFY page_code longtext";
#	my $asth = $dbh -> prepare($alterstmt);
#	$asth -> execute();

#type value verb

#	my $alterstmt = "ALTER TABLE feed MODIFY feed_lastBuildDate varchar(64)";
#	my $asth = $dbh -> prepare($alterstmt);
#	$asth -> execute();


#	my $alterstmt = "ALTER TABLE post MODIFY post_comments int(5)";
#	my $asth = $dbh -> prepare($alterstmt);
#	$asth -> execute();

# my $sth = $dbh->prepare("TRUNCATE TABLE event");
# $sth->execute();

# my $eth = $dbh->prepare("DELETE FROM post WHERE post_type='Adelaide '");
# $eth->execute();

	
# fix_graph();



#	open IN,"/var/www/downes/files/bounceout.txt" or die "Cannot open filtemails.txt";		#
#	while (<IN>) {
#		chomp;
#		my $e = $_;

# my $eth = $dbh->prepare("DELETE FROM person WHERE person_email='$e'");
# $eth->execute();

#		print "$e deleted <br>";
#	}
#	close IN;




# -------  Mapping Select Source ---------------------------------------------


sub map_form_source {

	my ($dbh,$query,$mapping) = @_;
	my $vars = $query->Vars;

	my $input_type_selected = {};
	$input_type_selected->{$mapping->{mapping_stype}} = " checked";

#while (my($mx,$my) = each %$mapping) { print "$mx = $my <br>"; }
	my $output = qq|<hr><h4>Define Mapping Source Feeds</h4>
		<p>A mapping will be executed provided a certain input condition is met. Here we 
		define what that condition may be. You can select a feed if it is a...
		<dl>
		<table border=1 cellpadding=5 cellspacing=0 style="color:#91c6e7">|;

						# Specific Feed
	my $mapfeedid = $mapping->{mapping_specific_feed};
	$output .= qq|<tr>
		<td valign="top" width="25%">
		<input type="radio" name="mapping_stype" value="mapping_specific_feed"  
		$input_type_selected->{mapping_specific_feed}>
		Specific Feed:</td>
		<td valign="top" width="75%">
		<select name="mapping_specific_feed" >|;
		
	my $stmt = qq|SELECT feed_id,feed_title FROM feed ORDER BY feed_title|;
	my $sth = $dbh->prepare($stmt);
	$sth->execute();
	while (my $feed = $sth -> fetchrow_hashref()) {
		my $selected; if ($mapfeedid eq $feed->{feed_id}) { $selected = " selected"; }
		my $ft = substr($feed->{feed_title},0,35);
		$output .= qq|<option value="$feed->{feed_id}" $selected> $ft </option>\n|;
	}
	$output .=  qq|</select></td></tr>|;

						# Feed Type
	$output .= qq|<tr>
		<td valign="top" width="25%">	
		<input type="radio" name="mapping_stype"  value="mapping_feed_type"  
		$input_type_selected->{mapping_feed_type}> Feed Type</td>
		<td valign="top" width="75%">
		<input type="text" name="mapping_feed_type" 
		value="$mapping->{mapping_field_type}" size="40">
		[<a href="Javascript:alert('Enter feed types (eg., rss, opml, atom, ical)');">Help</a>]
		</td></tr>|;


						# Feed Field
	$output .= qq|<tr>
		<td valign="top" width="25%">	
		<input type="radio" name="mapping_stype" value=mapping_feed_fields  
		$input_type_selected->{mapping_feed_fields}> Feed Fields</td>
		<td valign="top" width="75%">
		<input type="text" name="mapping_feed_fields" 
		value="$mapping->{mapping_feed_fields}" size="40">
		[<a href="Javascript:alert('Enter field (eg., enclosure, start_date, width)');">Help</a>]
		</td></tr>|;


						# Feed Field Value Pair
	$output .= qq|<tr>
		<td valign="top" width="25%">	
		<input type="radio" name="mapping_stype" value="mapping_feed_value_pair"  
		$input_type_selected->{mapping_feed_value_pair}> Value Pair</td>
		<td valign="top" width="75%">
		<input type="text" name="mapping_field_value_pair" 
		value="$mapping->{mapping_field_value_pair}" size="40">
		[<a href="Javascript:alert('Enter a field and a value (eg., title:OLDaily)');">Help</a>]
		</td></tr>|;


	$output .= qq|</table></dl></p>|;
	return $output;
}



# -------  Map Form Field Values -----------------------------------------------

sub map_form_field_values {

	my ($dbh,$query,$mapping) = @_;
	my $vars = $query->Vars;
	my @dest_columns = &db_columns($dbh,$mapping->{mapping_dtable});

	my $output = qq|<h4>Set Destination Table Values</h4>
		<p>When a new destination record is created, these values will be set:</p><dl>
		<table border=1 cellpadding=5 cellspacing=0 style="color:#91c6e7">\n
		<tr><td><i>Field Name</i></td><td><i>Value</td></tr>|;	
		
						# get existing values, if any, and display
	my @existing;					
	my $tvals = $mapping->{mapping_values};
	my @tvallist = split ";",$tvals;
	foreach my $tval (@tvallist) {
		my ($tvfield,$tvval) = split ",",$tval;
		my $elname = "mapping_value_".$tvfield;
		$output .= qq|<tr><td align="right">$tvfield</td>
					<td><input name="$elname" type="text" size="20"
					value="$tvval"></td></tr>|;
		push @existing,$tvfield;			
	}
	
						# print blank for new value
	$output .=  qq|<tr><td align="right"><select name="mapping_tval_field">|;
	foreach my $dc (@dest_columns) {
			next if $dc =~ /\Q_id\E/i;
			next if (&index_of($dc,\@existing) >= 0);	
			my $match = $dc;
			my $prefix = $mapping->{mapping_dtable}."_";
			$match =~ s/\Q$prefix\E//;
			$output .=  qq|<option value="$dc">$match</option>\n|;
		}
	$output .=  qq|</select></td><td><input name="mapping_tval_value"
		type="text" size="20"></td></tr></table></dl><br/>|;
	
	return $output;				


}



# -------  Map Form Mappings -----------------------------------------------

sub map_form_mappings {

	my ($dbh,$query,$mapping) = @_;
	my $vars = $query->Vars;
	
	my $mapping_prefix = $mapping->{mapping_prefix} || "link";  	# Set prefix and define source columns
	my @source_columns = ();	
	if ($mapping_prefix eq "link") {
		@source_columns = qw|title description type link category guid created issued author authorname authorurl modified base localcat feedid feedname lat long owner_url identifier parent star host sponsor sponsor_url access start finish|;
	}

	
						# get column list for destination
						
	my @dest_columns = &db_columns($dbh,$mapping->{mapping_dtable});	
	
						# print options table headings
	my $output = qq|<h4>Map Table Elements</h4>
		<dl><table border=1 cellpadding=5 cellspacing=0 style="color:#91c6e7">\n
		<tr><td><i>Source</i></td><td>&nbsp;</td><td><i>Destination: $mapping->{mapping_dtable}</i></td></tr>|;	
		
						# Set up hash of existing mappings
	my $mapping_hash = {};
	my @mappinglist = split ";",$mapping->{mapping_mappings};
	foreach my $ml (@mappinglist) {
		my ($mlf,$mlv) = split ",",$ml;
			$mapping_hash->{$mlf} = $mlv;
	}
		
						# print table
	foreach my $sc (@source_columns) {
		next if $sc =~ /\Q_id\E/i;
		my $sp = $mapping_prefix . "_";
		$sc =~ s/\Q$sp\E//;
		my $spc = $mapping_prefix."_".$sc;
		$output .= qq|<tr><td align="right">$sc</td><td> ---> </td>\n|;
		$output .= qq|<td><select name="$spc">\n|;
		$output .= qq|<option value="null"></option>\n|;		
		foreach my $dc (@dest_columns) {
		
			# Create option text
			next if $dc =~ /\Q_id\E/i;
			my $match = $dc;
			my $prefix = $mapping->{mapping_dtable}."_";
			$match =~ s/\Q$prefix\E//;
				
			# print the option	
			$output .=  qq|<option value="$dc"|;
			if ($mapping_hash->{$spc} eq $dc) {		# Print existing mappings
				$output .=  " selected";
			} else {									# Autogenerate new mappings
				if ($sc eq $match) { $output .=  " selected"; }
			}
			$output .=  qq|>$match</option>\n|;
			
		}
	
		$output .=  qq|</select></td></tr>|;
	}
	$output .=  "</table></dl>";
	return $output;
}






# -------  Mapping Select Destination -------------------------------------------

sub map_form_destination {

	my ($dbh,$query,$mapping) = @_;
	my $vars = $query->Vars;

	my $output =  qq|<h4>Define Destination Table</h4>
		<p>Select a destination table: 
		<select name="mapping_dtable">\n|;
		
						# Define list of destination tables
	my @tables = qw|author box event feed file journal link page person post presentation publication project task template topic|;
		
						# Print list of destination tables
	foreach my $t (@tables) {
		my $sel = "";
		if ($t eq $mapping->{mapping_dtable}) { $sel = " selected"; }
		$output .= qq|<option value="$t"$sel>$t</option>\n|;
	}
	$output .= qq|</select></p>\n|;

						# Mapping Priority
	my $priority = $mapping->{mapping_priority} || 1;
	$output .=  qq|<h4>Define Mapping Priority</h4>
		<p>Higher Number = Higher Priority. <b>Priority:
		<input type="text" name="mapping_priority" value="$priority" size="5"></p>|;	

	return $output;

}











	

# -------  Mapping Instructions -----------------------------------------------
	
sub map_instructions {

	my ($dbh,$query,$mapping) = @_;
	my $vars = $query->Vars;

	my $output = qq|
		<h1>Edit Feed Mapping</h1>
		<p>A <i>mapping</i> is a way to direct where you want harvested data
		to be stored. The mapping source is always a feed, while the mapping
		destination is always a database table.</p>|;
	if ($vars->{new_dtable}) {
		$output .=  qq|<p>You have now selected a new mapping source and destination table. Now, 
				specify mapping from input fields to output fields. Some default
                        mappings have been suggested.</p>|;
	}

	$output .= "<p>Editing: <b>". ($mapping->{mapping_title} || "New Mapping") ."</b></p>";
	return $output;

}



