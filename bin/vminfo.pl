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
            my $md_filename = sprintf("%s/%s/%s\n",
                $monkeyman_doc_directory,
                $1,
                $pod_filename_short_new
            );
            my $output = $podmarkdown->output_string($pod_filename);
            if(defined($output)) {
                mkpath($monkeyman_doc_directory);
                open(my $fh, '>', $md_filename);
                print($fh $output);
                close($fh);
            }
    }
}
