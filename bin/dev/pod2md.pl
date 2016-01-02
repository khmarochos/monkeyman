#!/usr/bin/env perl

# Use pragmas
use strict;
use warnings;

use autodie qw(open close);

use File::Find;
use File::Path;
use Pod::Markdown::Github;

my $monkeyman_pod_directory = '/home/mmkeeper/monkeyman';
my $monkeyman_doc_directory = $monkeyman_pod_directory . '/doc';
my $podmarkdown = Pod::Markdown::Github->new;

find(\&wanted, "/home/mmkeeper/monkeyman");

sub wanted {
    my $pod_filename_short = $_;
    my $pod_filename_short_new = $pod_filename_short;
    if($pod_filename_short_new =~ s#^(.+\.p[lm])$#$1.md#) {
        my $pod_filename = $File::Find::name;
        if($pod_filename =~ qr#^${monkeyman_pod_directory}/(?:(.+)/)?(${pod_filename_short})$#) {
            my $md_directoryname = sprintf("%s/%s",
                $monkeyman_doc_directory,
                $1,
            );
            my $md_filename = sprintf("%s/%s",
                $md_directoryname,
                $pod_filename_short_new
            );
            if(defined($output)) {
                mkpath($md_directoryname);
                open(my $fh, '>', $md_filename);
                $parser->output_fh($out_file);
                close($fh);
            }
        }
    }
}
