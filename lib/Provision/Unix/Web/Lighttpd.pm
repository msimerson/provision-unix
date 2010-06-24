package Provision::Unix::Web::Lighttpd;

use warnings;
use strict;

our $VERSION = '0.02';

use Carp;
use Params::Validate qw( :all );

use lib "lib";

use Provision::Unix;
my $prov = Provision::Unix->new;

sub new {
    my $class = shift;
    my $self  = {};
    bless( $self, $class );
    return $self;
}

1;

__END__

