
use strict;
#use warnings;

use lib "lib";

use Cwd;
use English qw( -no_match_vars );
use Test::More 'no_plan';

my $deprecated = 0;    # run the deprecated tests.
my $network    = 0;    # run tests that require network
$network = 1 if $OSNAME =~ /freebsd|darwin/;
my $r;

BEGIN {
    use_ok('Provision::Unix');
    use_ok('Provision::Unix::Utility');
}
require_ok('Provision::Unix');
require_ok('Provision::Unix::Utility');

# let the testing begin

# basic OO mechanism
my $prov = Provision::Unix->new( debug => 0 );
my $util = Provision::Unix::Utility->new( prov => $prov, debug => 0 );
ok( defined $util, 'get Provision::Unix::Utility object' );
isa_ok( $util, 'Provision::Unix::Utility' );    # is it the right class?

# for internal use
if ( -e "Utility.t" ) { chdir "../"; }

# we need this stuff during subsequent tests
my $debug = 0;
my ($cwd) = cwd =~ /^([\/\w\-\s\.]+)$/;         # get our current directory

print "\t\twd: $cwd\n" if $debug;

my $tmp = "$cwd/t/trash";
mkdir $tmp, 0755;
if ( ! -d $tmp ) {
    $util->mkdir_system( dir => $tmp, debug => 0, fatal => 0 );
};
skip "$tmp dir creation failed!\n", 2 if ( ! -d $tmp );
ok( -d $tmp, "temp dir: $tmp" );
ok( $util->syscmd( "cp TODO $tmp/", debug => 0, fatal => 0 ),
    'cp TODO' );


# ask - asks a question and retrieves the answer
SKIP: {
    skip "annoying", 4 if 1 == 1;
    skip "ask is an interactive only feature", 4 unless $util->is_interactive;
    ok( $r = $util->ask( 'test yes ask',
            default  => 'yes',
            timeout  => 5
        ),
        'ask, proper args'
    );
    is( lc($r), "yes", 'ask' );
    ok( $r = $util->ask( 'any (non empty) answer' ),
        'ask, tricky' );

    # multiline prompt
    ok( $r = $util->ask( 'test any (non empty) answer',
            default  => 'just hit enter',
        ),
        'ask, multiline'
    );

    # default password prompt
    ok( $r = $util->ask( 'type a secret word',
            password => 1,
            default  => 'secret',
        ),
        'ask, password'
    );
}

# archive_expand
my $gzip = $util->find_bin( "gzip", fatal => 0, debug => 0 );
my $tar  = $util->find_bin( "tar",  fatal => 0, debug => 0 );
my $file = $util->find_bin( "file", fatal => 0, debug => 0 );

SKIP: {
    skip "gzip or tar is missing!\n", 6 unless ( -x $gzip && -x $tar && -x $file && -d $tmp );
    ok( $util->syscmd( "$tar -cf $tmp/test.tar TODO",
            debug => 0,
            fatal => 0
        ),
        "tar -cf test.tar"
    );
    ok( $util->syscmd( "$gzip -f $tmp/test.tar",
            debug => 0,
            fatal => 0
        ),
        'gzip test.tar'
    );

    my $archive = "$tmp/test.tar.gz";
    ok( -e $archive, 'temp archive exists' );

    ok( $util->archive_expand(
            archive => $archive,
            debug   => 0,
            fatal   => 0
        ),
        'archive_expand'
    );

    eval {
        ok( !$util->archive_expand(
                archie => $archive,
                debug  => 0,
                fatal  => 0
            ),
            'archive_expand'
        );
    };

    # clean up behind the tests
    ok( $util->file_delete( file => $archive, fatal => 0, debug => 0 ),
        'file_delete' );
}

#	TODO: { my $why = "archive_expand, requires a valid archive to expand";
#			this way to run them but not count them as failures
#			local $TODO = $why if (! -e $archive);
#			this way to skip them entirely and mark as TODO
#			todo_skip $why, 3 if (! -e $archive); #}

# cwd_source_dir
# dir already exists
ok( $util->cwd_source_dir( dir => $tmp, debug => 0 ), 'cwd_source_dir' );

# clean up after previous runs
if ( -f "$tmp/foo" ) {
    ok( $util->file_delete( file => "$tmp/foo", fatal => 0, debug => 0 ),
        'file_delete' );
}

# a dir to create
ok( $util->cwd_source_dir( dir => "$tmp/foo", debug => 0 ),
    'cwd_source_dir' );
print "\t\t wd: " . cwd . "\n" if $debug;

# go back to our previous working directory
chdir($cwd) or die;
print "\t\t wd: " . cwd . "\n" if $debug;

# chown_system
my $sudo_bin = $util->find_bin( 'sudo', debug => 0, fatal => 0 );
if ( $UID == 0 && $sudo_bin && -x $sudo_bin ) {

    # avoid the possiblity of a sudo call in testing
    ok( $util->chown_system(
            dir   => $tmp,
            user  => $<,
            debug => 0,
            fatal => 0
        ),
        'chown_system'
    );
}

# check_pidfile - deprecated (see pidfile_check)

# clean_tmp_dir
TODO: {
    my $why = " - no test written yet";
}
ok( $util->clean_tmp_dir( dir => $tmp, debug => 0 ), 'clean_tmp_dir' );

print "\t\t wd: " . cwd . "\n" if $debug;

# get_mounted_drives
ok( my $drives = $util->get_mounted_drives( debug => 0 ),
    'get_mounted_drives' );
isa_ok( $drives, 'HASH' );

# example code working with the mounts
#foreach my $drive (keys %$drives) {
#	print "drive: $drive $drives->{$drive}\n";
#}

# file_* tests

TODO: {
    my $why = " - user may not want to run extended tests";

    # this way to run them but not count them as failures
    local $TODO = $why if ( -e '/dev/null' );

#$extra = $util->yes_or_no( "can I run extended tests?", timeout=>5 );
#ok ( $extra, 'yes_or_no' );
}

# file_read
my $rwtest = "$tmp/rw-test";
ok( $util->file_write(
        file  => $rwtest,
        lines => ["erase me please"],
        debug => 0
    ),
    'file_write'
);
my @lines = $util->file_read( file => $rwtest, debug => 0 );
ok( @lines == 1, 'file_read' );

# file_append
# a typical invocation
ok( $util->file_write(
        file   => $rwtest,
        lines  => ["more junk"],
        append => 1,
        debug  => 0
    ),
    'file_append'
);

# file_archive
# a typical invocation
my $backup = $util->file_archive( file => $rwtest, debug => 0, fatal => 0 );
ok( -e $backup, 'file_archive' );
ok( $util->file_delete( file => $backup, debug => 0, fatal => 0 ),
    'file_delete' );

ok( !$util->file_archive( file => $backup, debug => 0, fatal => 0 ),
    'file_archive' );

#    eval {
#        # invalid param, will raise an exception
#	    $util->file_archive( fil=>$backup, debug=>0,fatal=>0 );
#    };
#	ok( $EVAL_ERROR , "file_archive");

# file_check_[readable|writable]
# typical invocation
ok( $util->is_readable( file => $rwtest, fatal => 0, debug => 1 ),
    'is_readable' );

# an invocation for a non-existing file (we already deleted it)
ok( !$util->is_readable( file => $backup, fatal => 0, debug => 0 ),
    'is_readable - negated' );

ok( $util->is_writable( file => $rwtest, debug => 0, fatal => 0 ),
    'is_writable' );

# file_get
SKIP: {
    skip "avoiding network tests", 2 if ( !$network );

    ok( $util->cwd_source_dir( dir => $tmp, debug => 0 ), 'cwd_source_dir' );

    ok( $util->file_get(
            url   => "http://mail-toaster.org/etc/maildrop-qmail-domain",
            debug => 0,
        ),
        'file_get'
    );

    ok( $util->file_get(
            url   => "http://mail-toaster.org/etc/maildrop-qmail-domain",
            dir   => $tmp,
            debug => 0,
        ),
        'file_get'
    );

    #    print getcwd . "\n";
    #    ok( $util->file_get(
    #            url   => "http://mail-toaster.org/Mail-Toaster.tar.gz",
    #            debug => 0,
    #        ), 'file_get'
    #    );
    #
## archive_expand
    #    ok( $util->archive_expand(
    #            archive => 'Mail-Toaster.tar.gz',
    #            debug   => 0,
    #            fatal   => 0
    #        ), 'archive_expand'
    #    );

}

chdir($cwd);
print "\t\t  wd: " . Cwd::cwd . "\n" if $debug;

# chown
my $uid = getpwuid($UID);
my $gid = getgrgid($GID);
my $root = 'root';
my $grep = $util->find_bin( 'grep', debug =>  0 );
my $wheel = `$grep wheel /etc/group` ? 'wheel' : 'root';

SKIP: {
    skip "the temp file for file_ch* is missing!", 4 if ( !-f $rwtest );

    # this one should work
    ok( $util->chown(
            file  => $rwtest,
            uid   => $uid,
            gid   => $gid,
            debug => 0,
            sudo  => 0,
            fatal => 0
        ),
        'chown uid'
    );

    if ( $UID == 0 ) {
        ok( $util->chown(
                file  => $rwtest,
                uid   => $root,
                gid   => $wheel,
                debug => 0,
                sudo  => 0,
                fatal => 0
            ),
            'chown user'
        );
    }

    # try a user/group that does not exist
    ok( !$util->chown(
            file  => $rwtest,
            uid   => 'frobnob6i',
            gid   => 'frobnob6i',
            debug => 0,
            sudo  => 0,
            fatal => 0
        ),
        'chown nonexisting uid'
    );

    # try a user/group that I may not have permission to
    if ( $UID != 0 && lc($OSNAME) ne 'irix') {
        ok( !$util->chown(
                file  => $rwtest,
                uid   => $root,
                gid   => $wheel,
                debug => 0,
                sudo  => 0,
                fatal => 0
            ),
            'chown no perms'
        );
    }
}

# tests system_chown because sudo is set, might cause testers to freak out
#		ok ($util->chown( file => $rwtest,
#			uid=>$uid, gid=>$gid, debug=>0, sudo=>1, fatal=>0 ), 'chown');
#		ok ( ! $util->chown( file => $rwtest,
#			uid=>'frobnob6i', gid=>'frobnob6i', debug=>0, sudo=>1, fatal=>0 ), 'chown');
#		ok ( ! $util->chown( file => $rwtest,
#			uid=>$root, gid=>$wheel,debug=>0, sudo=>1,fatal=>0), 'chown');

# chmod
# get the permissions of the file in octal file mode
use File::stat;
my $st = stat($rwtest) or warn "No $tmp: $!\n";
my $before = sprintf "%lo", $st->mode & 07777;

#$util->syscmd( "ls -al $rwtest" );   # use ls -al to view perms

# change the permissions to something slightly unique
if ( lc($OSNAME) ne 'irix' ) {
# not sure why this doesn't work on IRIX, and since IRIX is EOL and nearly 
# extinct, I'm not too motivated to find out why.
    ok( $util->chmod(
            file_or_dir => $rwtest,   mode        => '0700',
            debug       => 0,         fatal       => 0,
        ),
        'chmod'
    );

# file_mode
    my $result_mode = $util->file_mode(
        file  => $rwtest,
        debug => 0,
    );
    cmp_ok( $result_mode, '==', 700, 'file_mode' );

#$util->syscmd( "ls -al $rwtest" );

# and then set them back
    ok( $util->chmod(
            file_or_dir => $rwtest,
            mode        => $before,
            debug       => 0, fatal => 0,
        ),
        'chmod'
    );
};

#$util->syscmd( "ls -al $rwtest" );

# file_write
ok( $util->file_write(
        file  => $rwtest,
        lines => ["17"],
        debug => 0,
        fatal => 0
    ),
    'file_write'
);

#$ENV{PATH} = ""; print `/bin/cat $rwtest`;
#print `/bin/cat $rwtest` . "\n";

# files_diff
# we need two files to work with
$backup = $util->file_archive( file => $rwtest, debug => 0 );

# these two files are identical, so we should get 0 back from files_diff
ok( !$util->files_diff( f1 => $rwtest, f2 => $backup, debug => 0 ),
    'files_diff' );

# now we change one of the files, and this time they should be different
ok( $util->file_write(
        file   => $rwtest,
        lines  => ["more junk"],
        debug  => 0,
        append => 1
    ),
    'file_write'
);
ok( $util->files_diff( f1 => $rwtest, f2 => $backup, debug => 0 ),
    'files_diff' );

# make it use md5 checksums to compare
$backup = $util->file_archive( file => $rwtest, debug => 0 );
ok( !$util->files_diff(
        f1    => $rwtest,
        f2    => $backup,
        debug => 0,
        type  => 'binary'
    ),
    'files_diff'
);

# now we change one of the files, and this time they should be different
sleep 1;
ok( $util->file_write(
        file   => $rwtest,
        lines  => ["extra junk"],
        debug  => 0,
        append => 1
    ),
    'file_write'
);
ok( $util->files_diff(
        f1    => $rwtest,
        f2    => $backup,
        debug => 0,
        type  => 'binary'
    ),
    'files_diff'
);

# file_is_newer
#

# find_bin
# a typical invocation
my $rm = $util->find_bin( "rm", debug => 0, fatal => 0 );
ok( $rm && -x $rm, 'find_bin' );

# a test that should fail
ok( !$util->find_bin( "globRe", fatal => 0, debug => 0 ), 'find_bin' );

# a shortcut that should work
$rm = $util->find_bin( "rm", debug => 0 );
ok( -x $rm, 'find_bin' );

# fstab_list
my $fs = $util->fstab_list( debug => 1 );
if ($fs) {
    ok( $fs, 'fstab_list' );

    #foreach (@$fs) { print "\t$_\n"; };
}

# get_dir_files
my (@list) = $util->get_dir_files( dir => "/etc" );
ok( -e $list[0], 'get_dir_files' );

# get_my_ips
SKIP: {
    skip "avoiding network tests", 1 if ( !$network );

    # need to update this so it works on netbsd & solaris
    ok( $util->get_my_ips( exclude_internals => 0 ), 'get_my_ips' );
}

# get_the_date
my $mod = "Date::Format";
if ( eval "require $mod" ) {

    ok( @list = $util->get_the_date( debug => 0 ), 'get_the_date' );

    my $date = $util->find_bin( "date", debug => 0 );
    cmp_ok( $list[0], '==', `$date '+%d'`, 'get_the_date day' );
    cmp_ok( $list[1], '==', `$date '+%m'`, 'get_the_date month' );
    cmp_ok( $list[2], '==', `$date '+%Y'`, 'get_the_date year' );
    cmp_ok( $list[4], '==', `$date '+%H'`, 'get_the_date hour' );
    cmp_ok( $list[5], '==', `$date '+%M'`, 'get_the_date minutes' );

    # this will occasionally fail tests
    #cmp_ok( $list[6], '==', `$date '+%S'`, 'get_the_date seconds');

    @list = $util->get_the_date( bump => 1, debug => 0 );
    cmp_ok( $list[0], '!=', `$date '+%d'`, "get_the_date day: $list[0]" );
    if ( $list[0] < 28 ) {
        cmp_ok( $list[1], '==', `$date '+%m'`, "get_the_date month: $list[1]" );
    }
    cmp_ok( $list[2], '==', `$date '+%Y'`, 'get_the_date year' );
    cmp_ok( $list[4], '==', `$date '+%H'`, 'get_the_date hour' );
    cmp_ok( $list[5], '==', `$date '+%M'`, 'get_the_date minutes' );
}
else {
    ok( 1, 'get_the_date - skipped (Date::Format not installed)' );
}

# graceful_exit

# install_if_changed
$backup = $util->file_archive( file => $rwtest, debug => 0, fatal => 0 );

# call it the new way
ok( $util->install_if_changed(
        newfile  => $backup,
        existing => $rwtest,
        mode     => '0644',
        debug    => 0,
        notify   => 0,
        clean    => 0,
    ),
    'install_if_changed'
);

# install_from_sources_php
# sub is incomplete, so are the tests.

# install_from_source
ok( $util->install_from_source(
        package => "ripmime-1.4.0.6",
        site    => 'http://www.pldaniels.com',
        url     => '/ripmime',
        targets        => [ 'make', 'make install' ],
        bintest        => 'ripmime',
        debug          => 0,
        source_sub_dir => 'mail',
        test_ok        => 1,
    ),
    'install_from_source'
);

ok( !$util->install_from_source(
        debug   => 0,
        package => "mt",
        site    => "mt",
        url     => "dl",
        fatal   => 0,
        test_ok => 0
    ),
    'install_from_source'
);

# is_process_running
my $process_that_exists 
    = lc($OSNAME) eq 'darwin' ? 'launchd' 
    : lc($OSNAME) eq 'freebsd' ? 'cron'  
    : 'init';      # init does not run in a freebsd jail

$r = $util->is_process_running($process_that_exists);
if ( $r ) {   
    # ignore failures
    ok( $r, "is_process_running, $process_that_exists" ) or diag system "/bin/ps -ef; /bin/ps ax";
};
ok( !$util->is_process_running("nonexistent"), "is_process_running, nonexistent" );

# is_tainted

# logfile_append

$mod = "Date::Format";
if ( eval "require $mod" ) {
    ok( $util->logfile_append(
            file  => $rwtest,
            prog  => $0,
            lines => ['running tests'],
            debug => 0
        ),
        'logfile_append'
    );

    #print `/bin/cat $rwtest` . "\n";

    ok( $util->logfile_append(
            file  => $rwtest,
            prog  => $0,
            lines => [ 'test1', 'test2' ],
            debug => 0
        ),
        'logfile_append'
    );

    #print `/bin/cat $rwtest` . "\n";

    ok( $util->logfile_append(
            file  => $rwtest,
            prog  => $0,
            lines => [ 'test1', 'test2' ],
            debug => 0
        ),
        'logfile_append'
    );
}

# mailtoaster
#

# mkdir_system
my $mkdir = "$tmp/bar";
ok( $util->mkdir_system( dir => $mkdir, debug => 0 ), 'mkdir_system' );
ok( $util->chmod( file_or_dir => $mkdir, mode => '0744', debug => 0, fatal => 0 ),
    'chmod' );
ok( rmdir($mkdir), 'mkdir_system' );

# path_parse
my $pr = "/usr/bin";
my $bi = "awk";
ok( my ( $up1dir, $userdir ) = $util->path_parse("$pr/$bi"), 'path_parse' );
ok( $pr eq $up1dir,  'path_parse' );
ok( $bi eq $userdir, 'path_parse' );

# pidfile_check
# will fail because the file is too new
ok( !$util->pidfile_check( pidfile => $rwtest, debug => 0, fatal => 0 ),
    'pidfile_check' );

# will fail because the file is a directory
ok( !$util->pidfile_check( pidfile => $tmp, debug => 0, fatal => 0 ),
    'pidfile_check' );

# proper invocation
ok( $util->pidfile_check(
        pidfile => "${rwtest}.pid",
        debug   => 0,
        fatal   => 0
    ),
    'pidfile_check'
);

# verify the contents of the file contains our PID
my ($pid)
    = $util->file_read( file => "${rwtest}.pid", debug => 0, fatal => 0 );
ok( $PROCESS_ID == $pid, 'pidfile_check' );

# regext_test
ok( $util->regexp_test(
        exp    => 'toast',
        string => 'mailtoaster rocks',
        debug  => 0
    ),
    'regexp_test'
);

# sources_get
# do I really want a test script download stuff? probably not.

# source_warning
ok( $util->source_warning( package => 'foo', debug => 0 ), 'source_warning' );

# sudo
if ( !$< == 0 && $sudo_bin && -x $sudo_bin ) {
    ok( $util->sudo( debug => 0 ), 'sudo' );
}
else {
    ok( !$util->sudo( debug => 0, fatal => 0 ), 'sudo' );
}

# syscmd
my $tmpfile = '/tmp/provision-unix-test';
ok( $util->syscmd( "touch $tmpfile", fatal => 0, debug => 0), 'syscmd +');
ok( ! $util->syscmd( "rm $tmpfile.nonexist", fatal => 0, debug => 0), 'syscmd -');
ok( $util->syscmd( "rm $tmpfile", fatal => 0, debug => 0), 'syscmd +');
ok( $util->syscmd( "$rm $tmp/maildrop-qmail-domain",
        fatal => 0,
        debug => 0
    ),
    'syscmd +'
) if $network;

# file_delete
ok( $util->file_delete( file => $backup, debug => 0 ), 'file_delete' );
ok( !$util->file_delete( file => $backup, debug => 0, fatal => 0 ),
    'file_delete' );

ok( $util->file_delete( file => $rwtest,       debug => 0, ), 'file_delete' );
ok( $util->file_delete( file => "$rwtest.md5", debug => 0, ), 'file_delete' );

ok( $util->clean_tmp_dir( dir => $tmp, debug => 0 ), 'clean_tmp_dir' );

# yes_or_no
ok( $util->yes_or_no( "test", timeout => 5, debug => 0 ),
    'yes_or_no' );

