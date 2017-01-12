#!/usr/bin/env perl
print "Content-type: text/html\n\n";
print "YouTube download<p>";
use strict;
use warnings;


#
##  Calomel.org  ,:,  Download Youtube videos
##    Script Name : youtube_download.pl
##    Version     : 0.58
##    Valid from  : March 2016
##    URL Page    : https://calomel.org/youtube_wget.html
##    OS Support  : Linux, Mac OSX, OpenBSD, FreeBSD
#                `:`
## Two arguments
##    $1 Youtube URL from the browser
##    $2 prefix to the file name of the video (optional)
#

############  options  ##########################################

# Option: what file type do you want to download? The string is used to search
# in the youtube URL so you can choose mp4, webm, avi or flv.  mp4 is the most
# compatable and plays on android, ipod, ipad, iphones, vlc and mplayer.
my $fileType = "mp4";

# Option: what visual resolution or quality do you want to download? List
# multiple values just in case the highest quality video is not available, the
# script will look for the next resolution. You can choose "itag=22" for 720p,
# "itag=18" which means standard definition 640x380 and "itag=17" which is
# mobile resolution 144p (176x144). The script will always prefer to download
# the first listed resolution video format from the list if available.
my $resolution = "itag=22,itag=18";

# Option: How many times should the script retry if the download fails?
my $retryTimes = 2;

# Option: turn on DEBUG mode. Use this to reverse engineering this code if you are
# making changes or you are building your own youtube download script.
my $DEBUG=1;

#################################################################

# initialize global variables and sanitize the path
$ENV{PATH} = "/bin:/usr/bin:/usr/local/bin:/opt/local/bin";
my $prefix = "";
my $retry = 1;
my $retryCounter = 0;
my $user_url = "";
my $user_prefix = "";

# collect the URL from the command line argument
#chomp($user_url = $ARGV[0]);
$user_url = "https://www.youtube.com/watch?v=-b2_Ew4LTh8";
my $url = "$1" if ($user_url =~ m/^([a-zA-Z0-9\_\-\&\?\=\:\.\/]+)$/ or die "\nError: Illegal characters in YouTube URL\n\n" );

# declare the user defined file name prefix if specified
if (defined($ARGV[1])) {
   chomp($user_prefix = $ARGV[1]);
   $prefix = "$1" if ($user_prefix =~ m/^([a-zA-Z0-9\_\-\.\ ]+)$/ or die "\nError: Illegal characters in filename prefix\n\n" );
}

# if the url down below does not parse correctly we start over here
tryagain:

# make sure we are not in a tryagain loop by checking the counter
if ( $retryTimes < $retryCounter ) {
   print "\n\n Stopping the loop because the retryCounter has exceeded the retryTimes option.";
   print "\n The video may not be available at the requested resolution or may be copy protected.\n\n<p>";
   print "\nretryTimes counter = $retryTimes\n\n<p>" if ($DEBUG == 1);
   exit;
}

# download the html from the youtube page containing the page title and video
# url. The page title will be used for the local video file name and the url
# will be sanitized to download the video.
print "Downloading $url <p>";
my $html = `curl -sS -L --compressed -A "Mozilla/5.0 (compatible)" "$url"`  or die  "\nThere was a problem downloading the HTML page.\n\n";

# format the title of the page to use as the file name
my ($title) = $html =~ m/<title>(.+)<\/title>/si;
$title =~ s/[^\w\d]+/_/g or die "\nError: we could not find the title of the HTML page. Check the URL.\n\n";
$title = lc ($title);
$title =~ s/_youtube//ig;
$title =~ s/^_//ig;
$title =~ s/_amp//ig;
$title =~ s/_39_s/s/ig;
$title =~ s/_quot//ig;

# filter the URL of the video from the HTML page
my ($download) = $html =~ /"url_encoded_fmt_stream_map"(.*)/ig;

# Print the raw separated strings in the HTML page
#print "\n$download\n\n<p>" if ($DEBUG == 1);

# This is where we loop through the HTML code and select the file type and
# video quality. 
my @urls = split(',', $download);
OUTERLOOP:
foreach my $val (@urls) {
#   print "\n$val\n\n<p>";

    if ( $val =~ /$fileType/ ) {
       my @res = split(',', $resolution);
       foreach my $ress (@res) {
         if ( $val =~ /$ress/ ) {
         print "\n  html to url separation complete.\n\n<p>" if ($DEBUG == 1);
         print "$val\n <p>" if ($DEBUG == 1);
         $download = $val;
         last OUTERLOOP;
         }
       }
    }
}

# clean up by translating url encoding and removing unwanted strings
print "\n  Start regular expression clean up...\n<p>" if ($DEBUG == 1);
$download =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
$download =~ s/sig=/signature=/g;
$download =~ s/\\u0026/\&/g;
$download =~ s/(type=[^&]+)//g;
$download =~ s/(fallback_host=[^&]+)//g;
$download =~ s/(quality=[^&]+)//g;
$download =~ s/&+/&/g;
$download =~ s/&$//g;
$download =~ s/%2C/,/g;
$download =~ s/%252F/\//g;
$download =~ s/^:"url=//g;
$download =~ s/\"//g;
$download =~ s/\?itag=22&/\?/;

# print the URL before adding the page title.
print "\n  The download url string: <br>\n\n$download\n<p>\n" if ($DEBUG == 1);

# check for &itag instances and either remove extras or add an additional
my $counter1 = () = $download =~ /&itag=\d{2,3}/g;
print "<p>\n  number of itag= (counter1): $counter1\n<p>" if ($DEBUG == 1);
if($counter1 > 1){ $download =~ s/&itag=\d{2,3}//; }
if($counter1 == 0){ $download .= '&itag=22' }

# save the URL starting with http(s)... 
my ($youtubeurl) = $download =~ /(https?:.+)/;

# is the URL in youtubeurl the variable? If not, go to tryagain above.
if (!defined $youtubeurl) {
    print "\n URL did not parse correctly. Let's try another mirror...\n<p>";
    $retryCounter++;
    sleep 2;
    goto tryagain;
}

# collect the title of the page
my ($titleurl) = $html =~ m/<title>(.+)<\/title>/si;
$titleurl =~ s/ - YouTube//ig;

# combine file variables into the full file name
my $filename = "unknown";
$filename = "$prefix$title.$fileType";

# url title to url encoding. all special characters need to be converted
$titleurl =~ s/([^A-Za-z0-9\+-])/sprintf("%%%02X", ord($1))/seg;

# combine the youtube url and title string
$download = "$youtubeurl\&title=$titleurl";

# Process check: Are we currently downloading this exact same video? Two of the
# same download processes will overwrite each other and corrupt the file.
my $running = `ps auwww | grep [c]url | grep -c "$filename"`;
print "\n <p> Is the same file name already being downloaded? $running" if ($DEBUG == 1);
if ($running >= 1)
  {
   print "\n  Already $running process, exiting.<p>" if ($DEBUG == 1);
   exit 0;
  };

# Print the long, sanitized youtube url for testing and debugging
print "\n <p> The following url will be passed to curl:\n" if ($DEBUG == 1);
print "<p>\n<textarea>$download</textarea>\n<p>\n" if ($DEBUG == 1);

# print the file name of the video being downloaded for the user 
print "<p>\n Download:   $filename  \n\n<p>" if ($retryCounter == 0 || $DEBUG == 1);

# print the itag quantity for testing
my $counter2 = () = $download =~ /&itag=\d{2,3}/g;
print "<p>\n  Does itag=1 ?  $counter2\n\n<p>" if ($DEBUG == 1);
if($counter2 < 1){
 print "<p>\n URL did not parse correctly (itag). <p>";
 exit;
}

# Background the script before the download starts. Use "ps" if you need to
# look for the process running or use "ls -al" to look at the file size and
# date.
fork and exit;

# Download the video, resume if necessary
print "Downloading to $filename <p>";
my $basefilename = $filename;
$filename = "/var/www/downes/files/videos/".$filename;
system("curl", "-sSRL", "-A 'Mozilla/5.0 (compatible)'", "-o", "$filename", "--retry", "5", "-C", "-", "$download");

# Print the exit error code
print "<p>\n  exit error code: $? <p>" if ($DEBUG == 1);

# Exit Status: Check if the file exists and we received the correct error code
# from the curl system call. If the download experienced any problems the
# script will run again and try to continue the download until the retryTimes
# count limit is reached.

if( $? == 0 && -e "$filename" && ! -z "$filename" )
   {
      print "<p>\n  Finished: $filename\n\n<p>" if ($DEBUG == 1);
   }
 else
   {
      print  "<p>\n  FAILED: $filename\n\n<p>" if ($DEBUG == 1);
      $retryCounter++;
      sleep $retryCounter;
      goto tryagain;
   }

# Convert the MP4 video to an MP3
my $outputfilename = $filename;
$outputfilename =~ s/\.mp4/\.mp3/i;
$basefilename  =~ s/\.mp4/\.mp3/i;

# print "Converting from $filename to $outputfilename<p>";
# system("ffmpeg", "-i","$filename","-vn","-ar","44100","-ac","2","-ab","128k","-f","mp3","$outputfilename");

# Print the exit error code
print "<p>\n  exit error code: $? <p>" if ($DEBUG == 1);
if( $? == 0 && -e "$filename" && ! -z "$filename" )
   {
      print "<p>\n  Finished: $filename\n\n<p>" if ($DEBUG == 1);
      
   #   print qq|<p><a href="http://www.downes.ca/files/videos/$basefilename">Click here</a>|;
            print qq|<p><a href="http://www.downes.ca/files/videos/$filename">Click here for video</a>|;
   }
 else
   {
      print  "<p>\n  FAILED: $filename\n\n<p>" if ($DEBUG == 1);
      $retryCounter++;
      sleep $retryCounter;
      goto tryagain;
   }
# ffmpeg -i source_video.avi -vn -ar 44100 -ac 2 -ab 192k -f mp3 sound.mp3

# gran_tsunami_ola_golpea_la_playa_loco_tsunami_2016.mp4
#### EOF #####