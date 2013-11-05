#!/usr/bin/perl

=com
=cut

use strict ;
use File::Util ;

# Sometimes this is necessary for modules in this directory to be found at compile time when running on my Mac:
use lib '/Users/jk/Documents/Programming/Scripts' ;
use SSYUtils2 ;

# Command-line options
my $verbose = 0 ;
my @extensions ;
my @sourceDirs ;
my $goBackHours = undef ;

# In Perl, cleverly, $#ARGV is the number of arguments minus one.
if ($#ARGV == -1) {
	usageErrDie("This program requires arguments.  You provided $#ARGV.") ;
}

my $i = 0 ;

# Get leading string argument
my $targetString = $ARGV[$i++] ;

# Get "dash" arguments
while (substr($ARGV[$i], 0, 1) eq "-") {
my $option = substr($ARGV[$i], 1, 1) ; # First character after dash only
	# Process exclusive options that must be solitary in a dash/argument because they are followed by a value
	if ($option eq 'x') {
		my $extension = substr($ARGV[$i], 2) ;
		push(@extensions, $extension) ;
	}
	if ($option eq 'i') {
		$goBackHours = substr($ARGV[$i], 2) ;
		my $badChars = $goBackHours =~ m/[^\d]/ ;
		if ($badChars) {
			usageErrDie("Value of -i goBackHours must be an integer, decimal digits only") ;
		}
	}
	else {	
		# Process non-exclusive options with implicit value that can share dash/argument
		my $options = substr($ARGV[$i], 1) ; # all characters after dash
		if ($options =~ m/h/) {
			# User wants help
			usageErrDie("You requested help with -h.\n") ;
		}
		if ($options =~ m/v/) {
			$verbose = 1 ;
		}
	}
	
	$i++ ;
}

my $thresholdDate = undef ;
if (@extensions == 0) {
	# Just process stdin
	my $nRemovedLines = 0 ; # not used
	process($targetString, \$nRemovedLines, 0, 0, *STDIN) ;
}
else { 
	# Get directory arguments, adding trailing slashes if needed
	while ($i <= $#ARGV) {
		push(@sourceDirs, SSYUtils2::addTrailingSlashIfNone($ARGV[$i++])) ;
	}
	
	if (@sourceDirs == 0) {
		usageErrDie("ERROR.  Your command must have >0 source directory arguments or this program has nothing to do.") ;
	}
	
	if (defined($goBackHours)) {
		$thresholdDate = time() - 3600 * $goBackHours ;
	}

	if ($verbose) {
		my $xString = "" ;
		foreach my $x (@extensions) {
			if (length($xString) > 0) {
				$xString .= " " ;
			}
			$xString .= ".$x" ;
		}
		
		my $modDateClause = "" ;
		if (defined($thresholdDate)) {
			my $thresholdDateString = scalar localtime($thresholdDate) ;
			$modDateClause = "and modified after $thresholdDateString " ;
		}
		
		print "cleanLines.pl will remove any lines containing the string:\n   $targetString\nfrom any file whose extension is in the set {$xString}\n $modDateClause" . "and which is in any of the following directories:\n" ;
		foreach my $dir (@sourceDirs) {
			print "   $dir\n" ;
		}
		print "RESULTS…\n" ;
	}	
	
	
	my $fileUtil = File::Util->new() ;
	
	foreach my $dir (@sourceDirs) {
		if ($fileUtil->existent($dir)) {
			my @filenames = $fileUtil->list_dir($dir, qw/--no-fsdots/) ;
			my $nFilenames = @filenames ;
			if ($verbose) {
				print "Found $nFilenames files in $dir\n" ;
			}
		
			foreach my $name (@filenames) {
				my $path = "$dir$name" ;
		
				# Ensure $path has one of the target extensions
				my $qualified = 0 ;
				my $thisExtension = SSYUtils2::filenameExtension($name) ;
					foreach my $extension (@extensions) {
					if ($thisExtension eq $extension) {
						$qualified = 1 ;
						last ;
					}
				}
				
				if ($qualified) {
					my $fileStatsRef = SSYUtils2::fileStats($path) ;
					# Ensure $path is a directory, not a regular file or symbolic link
					if (($fileStatsRef->{'type'} eq 'd') || ($fileStatsRef->{'type'} eq 'l')) {
						$qualified = 0 ;
					}
					
					# Ensure path meets the threshold date
					if ($qualified) {
						if (defined($thresholdDate)) {
							if ($fileStatsRef->{'modDate'} < $thresholdDate) {
								$qualified = 0 ;
							}
						}
						
						if ($qualified) {
							my $textOut = "" ;
							my $nRemovedLines = 0 ;
							if (open(my $textIn, '<:utf8', $path)) {
								if ($verbose) {
									print "   Parsing qualified file: $name\n" ;
								}
								
								process($targetString, \$nRemovedLines, 1, \$textOut, $textIn) ;
							}
							else {
								die "Could not open to read file $path" ;
							}
							
							if ($nRemovedLines > 0) {
								my $filedOK = open (FILE, '>:utf8', "$path") ; 
							
								 # Print to file and append result to log
								if ($filedOK) {
									print FILE $textOut ;
									close (FILE) ;
								}
								else {
									die "Could not reopen to write file $path" ;
								}
								if ($verbose) {
									printf "      Removed $nRemovedLines lines\n" ;
								}
							}
						}
					}
				}
			}
		}
	}
}

sub process {
	my $targetString = shift ;
	my $nRemovedLinesRef = shift ;
	my $useTextOut = shift ;
	my $textOutRef = shift ;
	my ($textIn) = @_ ;
	while (<$textIn>) {
		my $line = $_ ;
		# Note: \Q tells Perl to not parse the contents as a regular expression, so that quantifier characters like '+' or '*' are interpreted literally.
		if (($line =~ m/\Q$targetString/)) {
			$$nRemovedLinesRef++ ;
		}
		else {
			# line does not contain $targetString
			if ($useTextOut) {
				$$textOutRef .= $line ;
			}
			else {
				print $line ;
			}
		}
	}
}

sub usageErrDie {
	my $msg = shift ;
	if ($msg) {
		print ("USAGE ERROR: " . $msg . "\n") ;
	}

	print ("cleanLines.pl  Removes any lines containing a given string, from either stdin, or from text files with given filename extension(s)\nUsage - Choose one of these two invocation forms:\n   cleanLines.pl\n   cleanLines.pl targetString [-hv] [-i<goBackHours>] -x<extension1> [-x<extension2> …] path1 path2 …\nThe first form is implied if there are no -x arguments.  Text is processed from stdin and returned in stdout.\nThe second form is for processing files (or getting help).\nArguments are:\n   targetString  The string, whose presence in a line will trigger its removal.  The match is case-sensitive.  Doublequote if it contains spaces or globbing characters.\n   -h  Print help and exit\n   -v  Verbose output to stdout\n   -i<goBackHours>  optional argument, for efficiency, tells the program to process only recently-modified files, ignoring files whose modification date is older than this number of hours prior to the current time.  Value must be an integer decimal number.\n   -x<extension>  Tells the program to process files whose filename extension is the given <extension>.  Obviously, at least one -x option is required because otherwise the program will have nothing to do.\n   <path>  Process files in <path>.  Again, obviously, at least one <path> is required because otherwise the program will have nothing to do.  Each path will be treated as a directory regardless of whether or not it ends in a path separator slash.  This program does not recurse into subdirectories.  This program does follow symbolic links.\nComplete Example Invocation:\n   cleanLines.pl \"/*SSYDBL*/\" -d1316324554 -xc -xcpp -xm /Users/jk/Documents/Programming/Projects/FileGoBack/FileGoBack /Users/jk/Documents/Programming/CategoriesObjC /Users/jk/Documents/Programming/ClassesObjC /Users/jk/Documents/Programming/ProtocolsObjC\nThe above example removes any line containing the string \"/*SSYDBL*/\" from any .c, .cpp or .m files modified after Sep 2011-09-18 05:42:34 GMT in the four directory paths listed.\nReport bugs etc. to Jerry Krinock <jerry\@sheepsystems.com>\n") ;
	exit(1) ;
}