package Provision::Unix::Web::Lighttpd;
# ABSTRACT: provision www virtual hosts on lighttpd

use strict;
use warnings;

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

