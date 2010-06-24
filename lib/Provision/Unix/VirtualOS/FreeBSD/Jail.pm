package Provision::Unix::VirtualOS::FreeBSD::Jail;

use warnings;
use strict;

our $VERSION = '0.07';

use English qw( -no_match_vars );
use Params::Validate qw(:all);

my ( $prov, $vos, $util );

sub new {
    my $class = shift;

    my %p = validate( @_, { 'vos' => { type => OBJECT }, } );

    $vos  = $p{vos};
    $prov = $vos->{prov};

    my $self = { prov => $prov };
    bless( $self, $class );

    die "Not finished. Only ezjail is currently supported on FreeBSD";

    $prov->audit( $class . sprintf( " loaded by %s, %s, %s", caller ) );

    return $self;
}

sub create {

# Usage      : $virtual->create( name => 'mysql', ip=>'127.0.0.2' );
# Purpose    : create a virtual OS instance
# Returns    : true or undef on failure
# Parameters :
#   Required : name     - name/ID of the virtual instance
#            : ip       - IP address(es), space delimited
#   Optional : disk_root   - the root directory of the virt os
#            : template - a 'template' or tarball to pattern as
#            :

    my $self = shift;

    $EUID == 0
        or $prov->error( "Create function requires root privileges." );

    my $ctid = $vos->{name};
    my %std_opts = ( debug => $vos->{debug}, fatal => $vos->{fatal} );

    return $prov->error( "ctid $ctid already exists", %std_opts) 
        if $self->is_present();

    $prov->audit("\tctid '$ctid' does not exist, creating...");


}

sub console {
    my $self = shift;
    my $ctid = $vos->{name};
    my $cmd = $util->find_bin( 'jexec', debug => 0 );
    exec "$cmd $ctid su";
};

sub is_present {
    my $self = shift;
    my $homedir = $self->get_ve_home();
    return $homedir if -d $homedir;
    return;
};

sub get_ve_home {
    my $self = shift;
    my $ctid = $vos->{name} || shift;
    return if ! $ctid;
    return "/usr/jails/$ctid";
};

sub enable {
};
sub destroy {
};
sub disable {
};
sub restart {
};
sub start {
};
sub stop {
};
sub set_password {
};

1;

__END__

