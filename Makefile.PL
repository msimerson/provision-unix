#!/usr/bin/env perl

use strict;
use warnings;
use 5.008;
use English qw( -no_match_vars );
use inc::Module::Install;

name             'Provision-Unix';
abstract_from    'lib/Provision/Unix.pm';
author           'msimerson@cpan.org';
license          'perl';
perl_version     '5.008';
version_from     'lib/Provision/Unix.pm';

requires         'Config::Tiny'      => 0;
requires         'Getopt::Long'      => 2.37;
requires         'Params::Validate'  => .8;
requires         'Digest::MD5'       => 1;
requires         'LWP::UserAgent'    => 0;
requires         'URI'               => 0;

test_requires    'Test::More'        => 0;

# these are for module authors and tests
recommends        'Test::Pod'           => 0;
recommends        'Test::Pod::Coverage' => 0;
recommends        'Test::Perl::Critic'  => 0;

# these are for optional features
recommends        'Quota'               => 0;
recommends        'Mail::Send'          => 1;
recommends        'Proc::ProcessTable'  => 1;
recommends        'Apache::Admin::Config' => .9;
recommends        'Apache::ConfigFile'  => .9;
recommends        'JSON::XS'            => 0;
recommends        'NicTool'             => 0;

feature             'JSON Provisioning Agent',
                        -default          => 1,
                        'JSON::XS'        => 0;

feature             'Email Notices',
                        -default          => 0,
                        'Mail::Send'      => 1;

feature             'Apache Configuration',
                        -default                => 0,
                        'Apache::Admin::Config' => .9;

feature             'Filesystem Quotas',
                        -default      => 0,
                        'Quota'       => 1;

feature             'NicTool API integration',
                        -default      => 0,
                       'NicTool'      => 0;

#feature         'tinydns data files'    # not used.
#                    DNS::TinyDNS'    => 1;

clean_files           'Provision-Unix-*';
clean_files           'pod2htm*';
clean_files           't/trash';
clean_files           't/tinydns/root/data';
clean_files           't/tinydns/root/data.cdb';
clean_files           'MANIFEST.bak';
clean_files           'Makefile.old';

install_script        'bin/prov_dns';
install_script        'bin/prov_user';
install_script        'bin/prov_virtual';
install_script        'bin/prov_web';
install_script        'bin/remoteagent';

# inc and t are automatically not indexed
no_index              file      => 'bin/remoteagent';

die "No support for OS" if $OSNAME =~ /win32|cygwin/i;

WriteAll;
