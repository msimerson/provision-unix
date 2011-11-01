package Provision::Unix::DNS::BIND;
# ABSTRACT: Provision BIND DNS entries

use strict;
use warnings;

our $VERSION = '0.02';


1;

__END__


=head1 SYNOPSIS

Provision DNS entries for a BIND DNS server. Not sure yet about backend support
for bind. There is likely a CPAN module for publishing records to a BIND zone 
file, but what about database backend? subclass them? (probably)

    use Provision::Unix::DNS::BIND;

    my $foo = Provision::Unix::DNS::BIND->new();
    ...


=head1 BUGS

Please report any bugs or feature requests to C<bug-unix-provision-dns at rt.cpan.org>, or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Provision-Unix>.  I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Provision::Unix::DNS::BIND


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Provision-Unix>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Provision-Unix>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Provision-Unix>

=item * Search CPAN

L<http://search.cpan.org/dist/Provision-Unix>

=back

=cut

