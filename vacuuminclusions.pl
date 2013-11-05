#!/usr/bin/perl

use strict ;
use File::Basename ;
use File::Copy::Recursive ;

my $ok ;

if ($#ARGV < 0) {
	print "vacuuminclusions iterates through all source code files in an Xcode project and eliminates unnecessary #import and #include directives, except for \"counterpart\" directives which are not removed, as a matter of style\nusage:\n   vacuuminclusions <path/to/MyProject.xcodeproj>\n" ;
	exit(1) ;
}
my $xcodeprojPath = $ARGV[0] ;

# Invoke xcodecrack with options 'full path' and 'sort (alphanumerically)'
my $pathsString = `xcodecrack -f -s $xcodeprojPath` ;

my @paths = split("\n", $pathsString) ;

foreach my $path (@paths) {
	# See if the project builds
	
	
	# Read in the file
	my @allLines = () ;
	my @targetLineIndexes = () ;
	if (open(IN, $path)) {
		binmode (IN, ":utf8") ;
		my $filename = basename($path) ;
		print "Processing file: $name\n" ;
		my $i = 0 ;
		while (<IN>) {
			my $line = $_ ;
			push(@allLines, $line) ;
			if $line =~ m/\A\s?(#import |#include )/ {
				push (@targetLineIndexes, $i) ;
			}
			$i++ ;
		}
		close(IN) ;
	}
	else {
		die "Could not open to read file $path" ;
	}
	
	# Start with the *last* #include or #import
	@targetLineIndexes = reverse(@targetLineIndexes) ;
	
=com
do {
		my @lines = 
		
		
		# See if the project builds
	}
=cut		
	# If not, restore the removed line and write the file
	
	
}

