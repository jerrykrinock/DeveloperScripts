#!/usr/bin/perl

use strict ;

use IPC::Run ;

# Edit the following section to reference your identifies…
my $codeSigningIdentity = "def8002d37ec43e764a8e05cf49a1552dfe91ce7" ;
my $developerTeamId = "4MAMECY9VS" ;
# The $codeSigningIdentity must be in your Mac OS X Keychain.  Supposedly, the Common Name, such as "Developer ID Application: Jerry Krinock" will also work.  But I've never tried it.∂


my $path = $ARGV[0] ;

my @pathComps = reverse(split("/", $path)) ;
my $basename = $pathComps[0] ;

printf "Extracted basename = $basename\n\n" ;

my $codeSignIdentifier = $basename . "-id" ;

# Construct Designated Requirements (DR)
# Signed by Apple anchor certificate...
my $reqmt1 = "anchor apple generic" ;
# Identifier is bundle identifier of this app...
# $reqmt2 specifies the codesign identifier and changes for each signable code object.
my $reqmt2 = "identifier \\\"$codeSignIdentifier\\\"" ;
# Is from the Mac App Store...
my $reqmt3 = "cert leaf[field.1.2.840.113635.100.6.1.9] exists" ;
# Is from a Developer ID authority
my $reqmt4 = "certificate 1[field.1.2.840.113635.100.6.2.6] exists" ;
# Has a Developer ID certificate
my $reqmt5 = "certificate leaf[field.1.2.840.113635.100.6.1.13] exists" ;
# Developer ID certificate must have proper Team ID.
my $reqmt6 = "certificate leaf[subject.OU] = \\\"$developerTeamId\\\" " ;
my $requirements = "\"=designated => $reqmt1 and $reqmt2 and (($reqmt3) or ($reqmt4 and $reqmt5 and $reqmt6))\"" ;

my $cmd = "/usr/bin/codesign --force --verbose --sign \"$codeSigningIdentity\" --requirements $requirements --identifier \"$codeSignIdentifier\" \"$path\"" ; 

my $cmdStdout = `$cmd` ;

printf "The codesign tool returned $?." ;

if ($? != 0) {
	die ("ERROR.  The codesign tool failed did not return 0.\nAborting.  Your tool has not been codesigned.\n")  ;
}

print "  That is good.\n" ;

my $command = "/usr/sbin/spctl" ;
my @args ;
my $stdin ;
my $stdout ;
my $stderr ;
my $exitOk ;

# Note that "spctl exits zero on success, or one if an operation has failed.  Exit code two indicates unrecognized or unsuitable arguments".  But IPC::Run:run() returns "TRUE when all subcommands exit with a 0 result code.  If an assessment operation results in denial but no other problem has occurred, the exit code is three."  But IPC::Run:run() returns "TRUE when all subcommands exit with a 0 result code."  Thus, success is indicated by $exitOk = 1.

# Before checking the product, first make sure that Gatekeeper is enabled
@args = ("--status") ;
$exitOk = IPC::Run::run [ $command, @args ], \$stdin, \$stdout, \$stderr ;
# Note that stdout and stderr end with line feeds
print "\nChecking Gatekeeper Status for $path.  Result:  exitOk=$exitOk\n   stdout: $stdout   stderr: $stderr\n" ;

my $assessmentsEnabled = (($stdout =~/assessments enabled/) && $exitOk) ;
if (!$assessmentsEnabled) {
	die ("Gatekeeper Assessments are not enabled for checking $path, according to command:\n   $command @args\nPlease run this command in Terminal:\n   sudo /usr/sbin/spctl --master-enable\nto fix this problem") ;
}

my @args = ("-a", "-v", $path) ;
$exitOk = IPC::Run::run [ $command, @args ], \$stdin, \$stdout, \$stderr ;
# Note that ends with line feed but stdout does not
print "\nGatekeeper Assessment Result:\n   exitOk=$exitOk\n   stdout: $stdout\n   stderr: $stderr\n" ;
# Oddly, spctl prints its result to stderr instead of stdout.
my $assessmentOk = (($stderr =~ m/source=Developer ID/) && ($stderr =~ m/: accepted/) && $exitOk) ;
if (!$assessmentOk) {
	die("Failed Developer ID for $path with command:\n$command @args") ;
}
