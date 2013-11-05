#!/usr/bin/perl

use strict;
use warnings;
use autodie;

sub my_handle {
    my ($handle) = @_;
    my $content = '';

    ## slurp mode
    {
        local $/;
        $content = <$handle> ;
    }

    ## or line wise
    #while (my $line = <$handle>){
    #    $content .= $line;
    #}

    print $content; # or do something else with $content

    return 1;
}

my_handle(*STDIN); # pass the handle around

exit 0;