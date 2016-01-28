# $Id: Atom.pm 150 2009-05-07 00:47:58Z swistow $

package Feed::Format::Atom;
use strict;

use base qw( Feed );
use XML::Atom::Feed;
use XML::Atom::Util qw( iso2dt );
use List::Util qw( first );
use DateTime::Format::W3CDTF;

use XML::Atom::Entry;
XML::Atom::Entry->mk_elem_accessors(qw( lat long ), ['http://www.w3.org/2003/01/geo/wgs84_pos#']);

use XML::Atom::Content;

sub identify {
    my $class   = shift;
    my $xml     = shift;
    my $tag     = $class->_get_first_tag($xml);
    return ($tag eq 'feed');
}


sub init_empty {
    my ($feed, %args) = @_;
    $args{'Version'} ||= '1.0';
    
    $feed->{atom} = XML::Atom::Feed->new(%args);
    $feed;
}

sub init_string {
    my $feed = shift;
    my($str) = @_;
    if ($str) {
        $feed->{atom} = XML::Atom::Feed->new(Stream => $str)
            or return $feed->error(XML::Atom::Feed->errstr);
    }
    $feed;
}

sub format { 'Atom' }

sub title { shift->{atom}->title(@_) }
sub link {
    my $feed = shift;
    if (@_) {
        $feed->{atom}->add_link({ rel => 'alternate', href => $_[0],
                                  type => 'text/html', });
    } else {
        my $l = first { !defined $_->rel || $_->rel eq 'alternate' } $feed->{atom}->link;
        $l ? $l->href : undef;
    }
}

sub self_link {
    my $feed = shift;
    if (@_) {
        my $uri = shift;
        $feed->{atom}->add_link({type => "application/atom+xml", rel => "self", href => $uri});
        return $uri;
    } 
    else
    {
        my $l =
            first
            { !defined $_->rel || $_->rel eq 'self' }
            $feed->{atom}->link;
            ;

        return $l ? $l->href : undef;
    }
}

sub description { shift->{atom}->tagline(@_) }
sub copyright   { shift->{atom}->copyright(@_) }
sub language    { shift->{atom}->language(@_) }
sub generator   { shift->{atom}->generator(@_) }
sub id          { shift->{atom}->id(@_) }
sub updated     { shift->{atom}->updated(@_) }
sub add_link    { shift->{atom}->add_link(@_) }
sub base        { shift->{atom}->base(@_) }

sub author {
    my $feed = shift;
    if (@_ && $_[0]) {
        my $person = XML::Atom::Person->new(Version => 1.0);
        $person->name($_[0]);
        $feed->{atom}->author($person);
    } else {
        $feed->{atom}->author ? $feed->{atom}->author->name : undef;
    }
}




sub modified {
    my $feed = shift;
    if (@_) {
        $feed->{atom}->modified(DateTime::Format::W3CDTF->format_datetime($_[0]));
    } else {
        return iso2dt($feed->{atom}->modified) if $feed->{atom}->modified;
        return iso2dt($feed->{atom}->updated)  if $feed->{atom}->updated;
        return undef;
    }
}

sub entries {
    my @entries;
    for my $entry ($_[0]->{atom}->entries) {
        push @entries, Feed::Entry::Format::Atom->wrap($entry);
    }

    @entries;
}

sub add_entry {
    my $feed  = shift;
    my $entry = shift || return;
    $entry    = $feed->_convert_entry($entry);
    $feed->{atom}->add_entry($entry->unwrap);
}

sub as_xml { $_[0]->{atom}->as_xml }

package Feed::Entry::Format::Atom;
use strict;

use base qw( Feed::Entry );
use XML::Atom::Util qw( iso2dt );
use Feed::Content;
use XML::Atom::Entry;
use List::Util qw( first );

sub init_empty {
    my $entry = shift;
    $entry->{entry} = XML::Atom::Entry->new(Version => 1.0);
    1;
}

sub format { 'Atom' }

sub title { shift->{entry}->title(@_) }
sub source { shift->{entry}->source(@_) }
sub updated { shift->{entry}->updated(@_) }
sub base { shift->{entry}->base(@_) }

sub link {
    my $entry = shift;
    if (@_) {
        $entry->{entry}->add_link({ rel => 'alternate', href => $_[0],
                                    type => 'text/html', });
    } else {
        my $l = first { !defined $_->rel || $_->rel eq 'alternate' } $entry->{entry}->link;
        $l ? $l->href : undef;
    }
}

sub summary {
    my $entry = shift;
    if (@_) {
		my %param;
		if (ref($_[0]) eq 'Feed::Content') {
			%param = (Body => $_[0]->body);
		} else {
			 %param = (Body => $_[0]);
		}
		$entry->{entry}->summary(XML::Atom::Content->new(%param, Version => 1.0));
    } else {
		my $s = $entry->{entry}->summary;
        # map Atom types to MIME types
        my $type = ($s && ref($s) eq 'Feed::Content') ? $s->type : undef;
        if ($type) {
            $type = 'text/html'  if $type eq 'xhtml' || $type eq 'html';
            $type = 'text/plain' if $type eq 'text';
        }
		my $body = $s;	
		if (defined $s && ref($s) eq 'Feed::Content') {
			$body = $s->body;
		}
        Feed::Content->wrap({ type => $type,
                                   body => $body });
    }
}

my %types = (
	'text/xhtml' => 'xhtml',
	'text/html'  => 'html',
	'text/plain' => 'text',
);

sub content {
    my $entry = shift;
    if (@_) {
        my %param;
        my $base;
        if (ref($_[0]) eq 'Feed::Content') {
			if (defined $_[0]->type && defined $types{$_[0]->type}) {
	            %param = (Body => $_[0]->body, Type => $types{$_[0]->type});
			} else {
	            %param = (Body => $_[0]->body);
			}
            $base = $_[0]->base if defined $_[0]->base;
        } else {
            %param = (Body => $_[0]);
        }
        $entry->{entry}->content(XML::Atom::Content->new(%param, Version => 1.0));
        $entry->{entry}->content->base($base) if defined $base;
    } else {
        my $c = $entry->{entry}->content;

        # map Atom types to MIME types
        my $type = $c ? $c->type : undef;
        if ($type) {
            $type = 'text/html'  if $type eq 'xhtml' || $type eq 'html';
            $type = 'text/plain' if $type eq 'text';
        }

        Feed::Content->wrap({ type => $type,
                                   base => $c ? $c->base : undef, 
                                   body => $c ? $c->body : undef });
    }
}

sub category {
    my $entry = shift;
    my $ns = XML::Atom::Namespace->new(dc => 'http://purl.org/dc/elements/1.1/');
    if (@_) {
        $entry->{entry}->add_category({ term => $_ }) for @_;
        return 1
    } else {


        my @category = ($entry->{entry}->can('categories')) ? $entry->{entry}->categories : $entry->{entry}->category;
        my @return = @category
            ? (map { $_->label || $_->term } @category)
            : $entry->{entry}->getlist($ns, 'subject');

        return wantarray? @return : $return[0];
    }
}

sub author {
    my $entry = shift;
    if (@_ && $_[0]) {
        my $person = XML::Atom::Person->new(Version => 1.0);
        $person->name($_[0]);
        $entry->{entry}->author($person);
    } else {
        $entry->{entry}->author ? $entry->{entry}->author->name : undef;
    }
}

sub id { shift->{entry}->id(@_) }

sub issued {
    my $entry = shift;
    if (@_) {
        $entry->{entry}->issued(DateTime::Format::W3CDTF->format_datetime($_[0])) if $_[0];
    } else {
        $entry->{entry}->issued ? iso2dt($entry->{entry}->issued) : undef;
    }
}

sub modified {
    my $entry = shift;
    if (@_) {
        $entry->{entry}->modified(DateTime::Format::W3CDTF->format_datetime($_[0])) if $_[0];
    } else {
        return iso2dt($entry->{entry}->modified) if $entry->{entry}->modified;
        return iso2dt($entry->{entry}->updated)  if $entry->{entry}->updated;
        return undef;
    }
}

sub lat {
    my $entry = shift;
    if (@_) {
   $entry->{entry}->lat($_[0]) if $_[0];
    } else {
   $entry->{entry}->lat;
    }
}

sub long {
    my $entry = shift;
    if (@_) {
   $entry->{entry}->long($_[0]) if $_[0];
    } else {
   $entry->{entry}->long;
    }
}


sub enclosure {
    my $entry = shift;

    if (@_) {
        my $enclosure = shift;
        my $method    = ($Feed::MULTIPLE_ENCLOSURES)? 'add_link' : 'link';
        $entry->{entry}->$method({ rel => 'enclosure', href => $enclosure->{url},
                                length => $enclosure->{length},
                                type   => $enclosure->{type} });
        return 1;
    } else {
        my @links = grep { defined $_->rel && $_->rel eq 'enclosure' } $entry->{entry}->link;
        return undef unless @links;
        my @encs = map { Feed::Enclosure->new({ url => $_->href, length => $_->length, type => $_->type }) } @links ;
        return ($Feed::MULTIPLE_ENCLOSURES)? @encs : $encs[-1];
    }
}


# Specialized 

sub grog {
    my $entry = shift;
    @_ ? $entry->{entry}{grog} = $_[0] : $entry->{entry}{grog};
}

sub start {
    my $item = shift->{entry};
    if (@_) {
        $item->{event}{start} = $_[0];
    } else {
        return $item->{event}{start};
    }
}

sub finish {
    my $item = shift->{entry};
    if (@_) {
        $item->{event}{finish} = $_[0];
    } else {
        return $item->{event}{finish};
    }
}


sub star {
    my $item = shift->{entry};
    if (@_) {
        $item->{event}{star} = $_[0];
    } else {
        return $item->{event}{star};
    }
}

sub host {
    my $item = shift->{entry};
    if (@_) {
        $item->{event}{host} = $_[0];
    } else {
        return $item->{event}{host};
    }
}

sub sponsor {
    my $item = shift->{entry};
    if (@_) {
        $item->{event}{sponsor} = $_[0];
    } else {
        return $item->{event}{sponsor};
    }
}

sub environment {
    my $item = shift->{entry};
    if (@_) {
        $item->{event}{environment} = $_[0];
    } else {
        return $item->{event}{environment};
    }
}

sub eid {
    my $item = shift->{entry};
    if (@_) {
        $item->{event}{identifier} = $_[0];
    } else {
        return $item->{event}{identifier};
    }
}

sub parent {
    my $item = shift->{entry};
    if (@_) {
        $item->{event}{parent} = $_[0];
    } else {
        return $item->{event}{parent};
    }
}

sub owner_url {
    my $item = shift->{entry};
    if (@_) {
        $item->{event}{owner_url} = $_[0];
    } else {
        return $item->{event}{owner_url};
    }
}

sub sponsor_url {
    my $item = shift->{entry};
    if (@_) {
        $item->{event}{sponsor_url} = $_[0];
    } else {
        return $item->{event}{sponsor_url};
    }
}

sub access {
    my $item = shift->{entry};
    if (@_) {
        $item->{event}{access} = $_[0];
    } else {
        return $item->{event}{access};
    }
}

sub event_type {
    my $item = shift->{entry};
    if (@_) {
        $item->{event}{type} = $_[0];
    } else {
        return $item->{event}{type};
    }
}


1;
