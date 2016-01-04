#!/usr/bin/env perl

# Use pragmas
use strict;
use warnings;

use autodie qw(open close);

use File::Find;
use File::Path qw(make_path);
use Pod::Markdown::Github;

my $pod_directoryname = '/home/mmkeeper/monkeyman';
my $doc_directoryname = $pod_directoryname . '/doc';
find(\&wanted, $pod_directoryname);

sub wanted {
    my $pod_filename_short = $_;
    my $pod_filename_short_new = $pod_filename_short;
    if($pod_filename_short_new =~ s#^(.+\.p[lm])$#$1.md#) {
        my $pod_filename_long = $File::Find::name;
        if($pod_filename_long =~ qr#^\Q${pod_directoryname}\E/(?:(.+)/)?(\Q${pod_filename_short}\E)$#) {
            my $md_string;
            my $convertor = Pod::Markdown::Github->new();
            $convertor->output_string(\$md_string);
            $convertor->parse_file($pod_filename_long);
            if(length($md_string) > 1) {
                my $md_directoryname = sprintf("%s/%s", $doc_directoryname, $1);
                my $md_filename_long = sprintf("%s/%s", $md_directoryname, $pod_filename_short_new);
                make_path($md_directoryname);
                open(my $md_filehandle, '>', $md_filename_long);
                print($md_filehandle $md_string);
                close($md_filehandle);
                printf("%s --> %s\n",
                    $pod_filename_long,
                    $md_filename_long
               );
            }
        }
    }
}
