#!/usr/bin/env perl

# Use pragmas
use strict;
use warnings;

# Find the libraries-directory
use FindBin qw($Bin);
use lib("$Bin/../../lib");

use MonkeyMan;
use MonkeyMan::Constants qw(:directories);
use MonkeyMan::Exception;

MonkeyMan->new(
    app_name => 'pod2mkd',
    app_description => 'Updates markdown documentation',
    app_version => 'v0.0.1',
    app_usage_help => sub { <<__END_OF_APP_USAGE_HELP__ },
Understands the following parameters:

    -p, --pod-directories <dir>
        [req] [mul] Where POD sources are located
    -r, --pod-root-directory <dir>
        [opt]       Where is the directory tree's root
    -m, --markdown-direcrory <dir>
        [req]       Where to put MD results
    -f, --force
        [opt]       To ignore mtime
__END_OF_APP_USAGE_HELP__
    parameters_to_get => {
        'p|pod-directories=s@'      => 'pod_directories',
        'r|pod-root-directory=s'    => 'pod_root_directory',
        'm|markdown-directory=s'    => 'markdown_directory',
        'f|force'                   => 'force'
    },
    app_code => sub {

### THE CODE GOES HERE ###

use autodie qw(open close);
use Cwd qw(abs_path);
use File::Find;
use File::Path qw(make_path);
use Pod::Markdown::Github;

my $mm = shift;
my $log = $mm->get_logger;
my $conf = $mm->get_configuration;
my $parameters = $mm->get_parameters;

unless(defined($parameters->get_pod_directories)) {
    MonkeyMan::Exception->throwf("No POD directories defined");
}

my $pod_root_directoryname = abs_path(
    defined($parameters->get_pod_root_directory) ?
        $parameters->get_pod_root_directory :
        MM_DIRECTORY_ROOT
);
unless(defined($pod_root_directoryname)) {
    MonkeyMan::Exception->throwf("Can't find the project's root directory's absolute path");
}
$log->tracef("The project's root directory is %s", $pod_root_directoryname);

my $doc_root_directoryname = abs_path(
    defined($parameters->get_markdown_directory) ?
        $parameters->get_markdown_directory :
        $pod_root_directoryname . '/doc'
);
unless(defined($doc_root_directoryname)) {
    MonkeyMan::Exception->throwf("Can't find the documentation root directory's absolute path");
}
$log->tracef("The documentation root directory is %s", $doc_root_directoryname);

foreach my $pod_directoryname (@{ $parameters->get_pod_directories }) {
    $pod_directoryname = abs_path($pod_directoryname);
    $log->debugf("Processing the %s directory", $pod_directoryname);
    find({
        follow => 1,
        wanted => sub {
            my $pod_filename_short = $_;
            my $pod_filename_short_new = $pod_filename_short;
            if($pod_filename_short_new =~ s#^(.+\.p[lm])$#$1.md#) {
                my $pod_filename_long = $File::Find::name;
                unless($pod_filename_long =~ qr#^\Q${pod_root_directoryname}\E(/(.+)/)?\Q${pod_filename_short}\E$#) {
                    $log->warnf("The %s file didn't match the verifying regex", $pod_filename_long);
                } else {
                    $log->debugf("Have found the %s file", $pod_filename_long);
                    my $mkd_directoryname = sprintf("%s/%s", $doc_root_directoryname, $2);
                    my $mkd_filename_long = sprintf("%s/%s", $mkd_directoryname, $pod_filename_short_new);
                    my $pod_file_mtime = (stat($pod_filename_long))[9];
                    my $mkd_file_mtime = (stat($mkd_filename_long))[9] || 0;
                    unless($parameters->get_force || $pod_file_mtime >= $mkd_file_mtime) {
                        $log->tracef("The source doesn't seem to be updated since the target had")
                    } else {
                        my $mkd_string;
                        my $convertor = Pod::Markdown::Github->new();
                        $convertor->output_string(\$mkd_string);
                        $convertor->parse_file($pod_filename_long);
                        if(length($mkd_string) > 1) {
                            make_path($mkd_directoryname);
                            open(my $mkd_filehandle, '>', $mkd_filename_long);
                            print($mkd_filehandle $mkd_string);
                            close($mkd_filehandle);
                            $log->infof("%s --> %s",
                                $pod_filename_long,
                                $mkd_filename_long
                            );
                        }
                    }
                }
            }
        }
    }, $pod_directoryname);
}

### THE CODE STOPS ###

    }
);
