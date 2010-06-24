
use Test::More tests => 6;

use lib "lib";

BEGIN {
    use_ok('Provision::Unix');
    use_ok('Provision::Unix::User');
    use_ok('Provision::Unix::DNS');
    use_ok('Provision::Unix::Web');
    use_ok('Provision::Unix::Utility');
    use_ok('Provision::Unix::VirtualOS');
}

diag("Testing Provision::Unix $Provision::Unix::VERSION, Perl $], $^X");
