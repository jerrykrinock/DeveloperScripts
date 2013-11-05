#!/usr/bin/perl

# For some reason, after I migrated from the Early 2006 Mac Mini to the Late 2009 Mac Mini, I got an error when reading the _Identifier_Lookup.data file during making the Help Book.  So I manually translated _Identifier_Lookup.data to a tab-return text file, _Identifier_Lookup.txt, by reverse-engineering it, and then recreatead _Identifier_Lookup.data using this script.  Tedious, but it worked.

use strict ;

use File::Spec ;
use File::Temp ;
use IPC::Run ;
use Storable ;
use File::Util ;

# The following is added for debugging, per this recommendation:
# http://groups.google.com/group/comp.lang.perl.misc/browse_thread/thread/41f9217de9321e7c#
require Carp; 
$SIG{INFO} = sub { Carp::cluck("SIGINFO") }; 
$SIG{QUIT} = sub { Carp::confess("SIGQUIT") }; 
# So that if this program gets stuck, you can press ^T to get a backtrace, and ^\ to get a backtrace and kill the program.

# Sometimes this is necessary for modules in this directory to be found at compile time when running on my Mac:
use lib '/Users/jk/Documents/Programming/Scripts' ;

use SSYUtils2 ;

my $aLine ;

my $sourceFilePath = "/Users/jk/Documents/Programming/Projects/BookMacster/HelpBook/source/_Identifier_Lookup.txt" ;

open (SOURCEDATA, $sourceFilePath) ;
my %displayLinkToIdentifierHash ;
while ($aLine = <SOURCEDATA>) {
print("LINE: $aLine") ;
	chomp($aLine) ;
	$aLine =~ m/(\w+)\t([\w\s[:punct:]^\r\n]+)/;
	my $identifier = $1 ;
	my $displayText = $2 ;
	print("displayText: $displayText    identifier: $identifier\n") ;
	$displayLinkToIdentifierHash{$displayText} = $identifier ;
}
close(SOURCEDATA) ;
	

my $identifierLookupPath = "/Users/jk/Documents/Programming/Projects/BookMacster/HelpBook/source/_Identifier_Lookup.data" ;


SSYUtils2::storeToStorage(\%displayLinkToIdentifierHash, $identifierLookupPath) ;

