# $Id: RSS.pm 150 2009-05-07 00:47:58Z swistow $

package stephentest;
use strict;


sub identify {
    my $class   = shift;
    my $xml     = shift;
    my $tag     = $class->_get_first_tag($xml);
    return ($tag eq 'rss' || $tag eq 'RDF');
}



1;
