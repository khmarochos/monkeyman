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

use autodie qw(open close);

use Cwd qw(abs_path);
use File::Find;
use File::Path qw(make_path);
use Pod::Markdown::Github;

MonkeyMan->new(
    app_name => 'pod2md',
    app_description => 'Updates markdown documentation',
    app_version => '0.0.1',
    app_usage_help => sub { <<__END_OF_APP_USAGE_HELP__ },
Understands the following parameters:

    -p, --pod-directories <dir> ...

    -P, --pod-files <file> ... #under implementation

    -m, --markdown-direcrory <dir>
__END_OF_APP_USAGE_HELP__
    parameters_to_get => {
        'p|pod-directories=s@'      => 'pod_directories',
        'r|pod-root-directory=s'    => 'pod_root_directory',
        'm|markdown-directory=s'    => 'markdown_directory'
    },
    app_code => sub {

        my $mm = shift;
        my $log = $mm->get_logger;
        my $conf = $mm->get_configuration;
        my $parameters = $mm->get_parameters;

        my $pod_root_directoryname = abs_path(
            $parameters->has_pod_root_directory ?
                $parameters->get_pod_root_directory :
                MM_DIRECTORY_ROOT
        );
        $log->tracef("The source root directory is %s", $pod_root_directoryname);

        my $doc_root_directoryname = abs_path(
            defined($parameters->get_markdown_directory) ?
                $parameters->get_markdown_directory :
                $pod_root_directoryname . '/doc'
        );
        unless(defined($doc_root_directoryname)) {
            MonkeyMan::Exception->throwf("Can't find the documentation directory's absolute path");
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
                        $log->debugf("Have found the %s file (%s)", $pod_filename_long, $pod_filename_short);
                        if($pod_filename_long =~ qr#^\Q${pod_root_directoryname}\E(/(.+)/)?\Q${pod_filename_short}\E$#) {
                            my $md_directoryname = sprintf("%s/%s", $doc_root_directoryname, $2);
                            my $md_filename_long = sprintf("%s/%s", $md_directoryname, $pod_filename_short_new);
                            if($log->tracef(
                                "It would be nice to make sure if %s is newer than %s",
                                $pod_filename_long,
                                $md_filename_long
                            ) || 1) {
                                my $md_string;
                                my $convertor = Pod::Markdown::Github->new();
                                $convertor->output_string(\$md_string);
                                $convertor->parse_file($pod_filename_long);
                                if(length($md_string) > 1) {
                                    $log->infof("%s --> %s",
                                        $pod_filename_long,
                                        $md_filename_long
                                    );
                                    make_path($md_directoryname);
                                    open(my $md_filehandle, '>', $md_filename_long);
                                    print($md_filehandle $md_string);
                                    close($md_filehandle);
                                }
                            }
                        }
                    }
                }
            }, $pod_directoryname);
        }

    }
);
