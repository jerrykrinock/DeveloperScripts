#!/usr/bin/perl

=com

PURPOSE

This script will
    Get the latest version number by reading it from product's Info.plist
    Create a zip file, including the product and any accessories
    Create a dmg file, including the product and any accessories
        The dmg file has a Sparkle-compliant name.
    Create an archive folder named for this shipment.  This folder will contain:
        The dmg shipment
        The zip shipment
        dSYM files of product and any constituent products.
    Upload the disk image
    Delete the old disk image
    Download, change, and re-upload your Sparkle appcast.
    Upload the new zip file (overwriting old)
    Zip and upload "other uploads".  These are typically AppleScripts, source code,
        freebies, etc. that may be downloaded separately by users who want them.
    Upload revised documentation files
        Remembers last ship date, only uploads new/revised files.
    Tell Sandvox to upload any website changes
    Clean and rebuild project with a ^next^ (future) revision number that you will provide interactively.
    Upload updated source code files.

Most of the above steps are done in separate steps, and user interaction before each step allows you read the output and then either "proceed" (hit 'return'), "skip" the next step, or "abort" the script.  I've found this to be the best way since scripts and sub-scripts "don't always just work" ;), especially ftp to remote servers.  In general, if this script dies or you abort it at, say, step 8, you may restart it, enter 's' 7 times to "skip" the first 7 steps that were succesfully completed, then continue where it left off.

Remote server operations are done using ftp.
 
ARGUMENTS
 
This script takes one argument, the path to a text file (suggested name: AppName.shipconfig.txt) which provides the necessary parameters.

PREREQUISITES

In addition to expecting all the files and directories referenced in the configuration file passed as the argument,

• The following tools must be installed somewhere in one of your bash $PATH paths:
    syncremotedir.pl
    appcast.pl
    copyFilesListedInFile.pl
    syncdirsdiff.pl
    tuff-ftp-put.pl
    verifysparkledsa
• The following tools must be installed in the same directory as this script:    
    SSYMakeHelp.pl
    SetProjectVersion.scpt
    SetTargetVersion.scpt
    Directory "MultiMarkdown"
        Must contain a subdirectory named "bin" which must contain
            MultiMarkdown.pl
            SmartyPants.pl

=cut


use strict ;
use Config::Easy() ;  # the () is required so that nothing is done at import() time.
use File::Spec ;
use File::Temp ;
# The following are sparsely used because they do not copy resource forks.
use File::Copy ;
use File::Copy::Recursive ;
use IPC::Run ;
use File::Basename ;
use Net::FTP ;
require File::Util ;

# Sometimes this is necessary for modules in this directory to be found at compile time when running on my Mac:
use lib '/Users/jk/Documents/Programming/Scripts' ;

use SSYUtils2 ;


=com
From the documentation for Cwd,
"If you ask to override your chdir() built-in function,
  use Cwd qw(chdir);
then your PWD environment variable will be kept up to date. Note that it will only be kept up to date if all packages which use chdir import it from Cwd."
We certainlly want our PWD variable to be kept up to date, so we do it!...
=cut
use Cwd qw(chdir) ;
=com
# Archive::Zip was abandoned because it does not properly copy symbolic links.
use Archive::Zip qw( :ERROR_CODES :CONSTANTS ) ;
=cut


my $verbose = 1 ;

# Open access to configuration file specified as the argument
#my $configPath = '/Users/jk/Documents/Programming/Projects/Bookdog/Bookdog.shipconfig.txt' ;
my $configPath = $ARGV[0] ;
my $programName = SSYUtils2::programName() ;

print "$programName is beginning to ship with configuration file:\n   $configPath\n" ;
my $config = Config::Easy->new($configPath);

# Read Configuration Variables

# Basic Product Info
my $appName                       = $config->get('appName') ;
my $revisionBaseName              = $appName . "_" ;
my $appNameLower                  = $config->get('appNameLower') ;
my $dmgName                       = $config->get('dmgName') ;
my $zipName                       = $config->get('zipName') ;
my $familyLimitMajor              = $config->get('familyLimitMajor') ;
my $familyLimitMinor              = $config->get('familyLimitMinor') ;
if ($familyLimitMajor == 0) {
	$familyLimitMajor = 9999 ;
}
if ($familyLimitMinor == 0) {
	$familyLimitMinor = 9999 ;
}



# Xcode Build Info
my $xcodeAppPath                  = $config->get('xcodeAppPath') ;
my $buildTargetName               = $config->get('buildTargetName') ;

# Stripping Exceptions
# These are optional
$config->no_strict();
my $stripAllFromStr               = $config->get('stripAllFrom') ;
my @stripAllFrom                  = split /,/, $stripAllFromStr ;
my $stripOnlyNonGlobalFromStr     = $config->get('stripOnlyNonGlobalFrom') ;
my @stripOnlyNonGlobalFrom        = split /,/, $stripOnlyNonGlobalFromStr ;
$config->strict() ;

# Code Signing Info
my $codeSigningIdentity           = $config->get('codeSigningIdentity') ;
my $developerTeamId               = $config->get('developerTeamId') ;

# Local Client Paths
my $projectPath                   = SSYUtils2::prependHome($config->get('projectPath')) ;
my $xcconfigPath                  = SSYUtils2::prependHome($config->get('xcconfigPath')) ; 
my $commonAccessoriesPath         = SSYUtils2::prependHome($config->get('commonAccessoriesPath')) ;
my $dmgAccessoriesPath            = SSYUtils2::prependHome($config->get('dmgAccessoriesPath')) ;
my $helpBookSourcePath            = SSYUtils2::prependHome($config->get('helpBookSourcePath')) ;
my $helpBookLocalHtmlPath         = SSYUtils2::prependHome($config->get('helpBookLocalHtmlPath')) ;
my $updateDescriptionMarkdownPath = SSYUtils2::prependHome($config->get('updateDescriptionMarkdownPath')) ;
my $buildsReleasePath             = SSYUtils2::prependHome($config->get('buildsReleasePath')) ;
my $shipArchivesPath              = SSYUtils2::prependHome($config->get('shipArchivesPath')) ;
my $localAppcastPath              = SSYUtils2::prependHome($config->get('localAppcastPath')) ;
my $otherArchiveesStr             = $config->get('otherArchivees') ;
my @otherArchivees                = split /,/, $otherArchiveesStr ;
my $excludedDocumentsStr          = $config->get('excludedDocuments') ;
my @excludedDocuments             = split /,/, $excludedDocumentsStr ;
my $publishSiteScript             = SSYUtils2::prependHome($config->get('publishSiteScript')) ;

# Remote Server (Web Host) Account Info
my $serverDomain                  = $config->get('serverDomain') ;
my $ftpAccountName                = $config->get('ftpAccountName') ;
my $ftpAccountPassword            = $config->get('ftpAccountPassword') ;
 
# Appcast
my $appcastName                   = $config->get('appcastName') ;
my $nItemsToLeaveInAppcast        = $config->get('nItemsToLeaveInAppcast') ;
my $updateDescriptionName         = $config->get('updateDescriptionName') ;
my $appcastProductFileExtension   = $config->get('appcastProductFileExtension') ;
my $maximumSystemVersion          = $config->get('maximumSystemVersion') ;
if ($maximumSystemVersion == 0) {
	$maximumSystemVersion = undef ;
}

# Zip Archive Signature (for Sparkle)
my $zipSignerPath                 = SSYUtils2::prependHome($config->get('zipSignerPath')) ;
my $zipPrivateKeyPath             = SSYUtils2::prependHome($config->get('zipPrivateKeyPath')) ;

# Remote Server Paths
# Script assumes that all products, appcast and updateDescription are all
# in the same directory on the server, specified by one of these paths
# relative to the server's html landing
my $pathServerHtml                = $config->get('pathServerHtml') ;
my $pathServerHtmlToHelpBookDir   = $config->get('pathServerHtmlToHelpBookDir') ;
my $pathServerHtmlToProductsDirN  = $config->get('pathServerHtmlToProductsDirN') ;
my $pathServerHtmlToProductsDirA  = $config->get('pathServerHtmlToProductsDirA') ;
my $pathServerHtmlToProductsDirB  = $config->get('pathServerHtmlToProductsDirB') ;
my $pathServerHtmlToProductsDirD  = $config->get('pathServerHtmlToProductsDirD') ;
my $pathServerHtmlToProductsDirS  = $config->get('pathServerHtmlToProductsDirS') ;

# Other Uploads
my $otherUploadsStrings           = $config->get('otherUploads') ; 
my @otherUploadStrings            = split /;/, $otherUploadsStrings ;

# Alternate Remote Server (Web Host) Account Info
my $altServerDomain               = $config->get('altServerDomain') ;
my $ftpAltAccountName             = $config->get('ftpAltAccountName') ;
my $ftpAltAccountPassword         = $config->get('ftpAltAccountPassword') ;

my $userInputChar ;


print "\nAffirm that you considered running the regression tests in the PROJECT_DIR/Tests/Scripts.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to affirm.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}

print "\nHave you changed the (Core Data) Data Model for documents in this version?\n" ;
print "   Type 'y' for YES.\n" ;
print "   Type 'return' or any key other key for NO.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'y') {
	print "\nAha!  Please affirm that you have updated the HARD CODED VERSION REQUIREMENT.  (Do a project-wide Find for that PHRASE.)\n" ;
	print "   Type 'a' to abort this script and exit.\n" ;
	print "   Type 'return' or any key other key to affirm.\n" ;
	$userInputChar = SSYUtils2::getUserInputChar() ;
	if ($userInputChar eq 'a') {
		die "User aborted" ;
	}

	print "\nAffirm that you have provided a mapping model and if needed, a migration policy.\n" ;
	print "   Type 'a' to abort this script and exit.\n" ;
	print "   Type 'return' or any key other key to affirm.\n" ;
	$userInputChar = SSYUtils2::getUserInputChar() ;
	if ($userInputChar eq 'a') {
		die "User aborted" ;
	}
}

print "\nAffirm that you have edited any changes to Help Book's Markdown sources and screenshots.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to affirm.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}

print "\nAffirm that you have added the new section for this release to the Version History.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to affirm.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}

print "\nAffirm that you have added the new section for this release to the Update News.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to affirm.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}

print "\nAffirm that you updated the Localization files.\n" ;
print "The steps are:\n" ;
print "    * In BBEdit, save Localizable.strings\n    * Launch Localization Manager\n    * Open Recent: Sheepsystems.ldb\n    * Select file 'Localizable.strings'\n    * Click button 'Rescan'\n    * Click button 'Synchronize'\n    * Save\n    * Quit\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to affirm.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}

print "\nAffirm that you have defined or not HARD_EXPIRATION_STRING in LicensingParms.m.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to affirm.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}

print "\nAffirm that you have defined as desired DEMO_TRIAL_DAYS in the project.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to affirm.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}

print "\nAffirm that you have searched for and approved all 'SSYDBL or DB?' in the project source code.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to affirm.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}

print "\nAffirm that you have searched for and approved all '#if 11' in the project source code.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to affirm.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}

print "\nAffirm that you have executed a Product > Analyze in Xcode recently.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to affirm.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}

print "\nAffirm that you have analyzed this project with Deploymate recently.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to affirm.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}

print "\nAffirm that all open files affecting this project are currently saved in the Xcode GUI (because we are going to use SSYMakeHelp and xcodebuild, neither of which checks this with the Xcode GUI).\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to affirm.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}

my @sysargs ;

print "\nShould process Help Book from Markdown etc. sources and index it with hiutil?\n" ;
print "   Type 's' to skip this step.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to approve.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}
elsif ($userInputChar ne 's') {
	# Example command for SSYMakeHelp.pl:  /Users/jk/Documents/Programming/Scripts/SSYMakeHelp.pl /Users/jk/Documents/Programming/Projects/BookMacster/HelpBook/source /Users/jk/Documents/Programming/Projects/BookMacster/Resources/English.lproj/HelpBook/ sheepsystems.com bookmacster/HelpBook/
	my $makeHelpToolPath = SSYUtils2::colocatedToolPath("SSYMakeHelp.pl") ; 
	@sysargs = ($makeHelpToolPath, "\"$helpBookSourcePath\"", "\"$helpBookLocalHtmlPath\"", $serverDomain, $pathServerHtmlToHelpBookDir) ;
	print "Invoking SSYMakeHelp.pl with arguments: @sysargs\n" ;
	SSYUtils2::systemDoOrDie(@sysargs) ;
}

my $pathToProduct = "$buildsReleasePath$appName.app" ;

my $currentXcodePath = `xcode-select -print-path` ;
chomp($currentXcodePath) ;
my $desiredXcodePath = $xcodeAppPath . "/Contents/Developer" ;
if ($currentXcodePath ne $desiredXcodePath) {
	print "\nThis Mac has Xcode path for xcodebuild not set to your desired path\n" ;
	print "   Current: $currentXcodePath\n" ;
	print "   Desired: $desiredXcodePath\n" ;
	print "   Please correct either by running command:\n" ;
	print "      sudo xcode-select -switch $xcodeAppPath\n" ;
	print "   or by changing the xcodeAppPath parameter in the configuration file to this script to reflect the current Xcode path.\n" ;
	die "Incorrect Xcode path" ;
}

print "\nActive Xcode is $currentXcodePath\n" ;
print "\nShould tell Xcode to perform final build?  (Needed to get new Help Book at least!)\n" ;
print "   Type 's' to skip this step.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to approve.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}
elsif ($userInputChar ne 's') {
	my $projectDir = dirname($projectPath) ;
	my $projectName = basename($projectPath) ;
	my $xcodeBuildCommand = "xcodebuild -project \"$projectName\" -target \"$buildTargetName\" -configuration Release build" ;
	#  $xcodeBuildCommand = "xcodebuild -project \"$projectName\" -scheme \"$buildTargetName\" -configuration Release archive ;" 
	# If I wanted to use Xcode's archiving, I would use the second line above, instead.  Here are the reasons why I don't use Xcode's archiving, and do not use it for non-Mac-App-Store builds…
	# (1) If you have a false start on a shipment, false-started archive remains, which must be deleted one at a time, with a confirmation dialog, in the Xcode GUI.  Uses a lot of disk space, not economical with SSD.  Deleting them "directly" is not convenient either; see next item.
	# (2) Archives get buried in a deep, un-rememberable directory.
	# (3) I see more actual warnings and fewer incorrect warnings from Core Data such as: cdtool[14715:f07] CoreData: warning: no NSValueTransformer with class name 'TransformStringsSetToData' was found for attribute 'unexportedDeletions' on entity 'Client_entity'
	# (4) Indications are that consituent targets (frameworks, etc.) seem to not get codesigned.  I've not investigate this.
	# Note that by using Xcode's 'build' action instead of 'archive' this means that I must do my own stripping and codesigning, which I do, below.
	# (5) The build action 'build' apparently only builds what needs to be built, which means that it takes only a few seconds for an immediate re-build.  But 'archive' always seems to take many minutes.
	print "Invoking $xcodeBuildCommand\n" ;
	print "   in directory $projectDir\n" ;
	# Note that xcodebuild will not take an input path as a parameter.
	# You must change the working directory to the project directory.
	# Also, for some reason, if I use /usr/bin/cd in the following, it "just doesn't work".
	my $buildTranscript = `source ~/.bash_profile ; cd "$projectDir" ; $xcodeBuildCommand` ;
	
	print "*** Build Transcript from xcodebuild ***\n $buildTranscript" ;
	
	print "\nAffirm that the above Build Transcript is acceptable.\n" ;

	my @lines = split("\n", $buildTranscript) ;
	#my @warnerrLines = grep(/warning/, @otoolLines) ;
	my @warnerrLines ;
	foreach my $line (@lines) {
		if ($line =~ m/warning:|error:/i) {
			push (@warnerrLines, $line) ;
		}
	}
	my $count = @warnerrLines ;
	print "We've found $count lines with warnings and errors:\n\n" ;
	my $i ;
	foreach my $warnerrLine (@warnerrLines) {
		$i++ ;
		print ("$i\t$warnerrLine\n") ;
	}

	print "   Type 'a' to abort this script and exit.\n" ;
	print "   Type 'return' or any key other key to affirm.\n" ;
	$userInputChar = SSYUtils2::getUserInputChar() ;
	if ($userInputChar eq 'a') {
		die "User aborted" ;
	}
}


my $fileUtil = File::Util->new() ;


# Get revision number from app's Info.plist.
my $revisionNumberString = extractBundleVersion($pathToProduct, 1) ;
my @revisionComps = split('\.', $revisionNumberString) ;
if (@revisionComps < 3) {
	# Add a "0" as the bug-fix component
	push(@revisionComps, 0) ;
}


# Compare package contents to last-shipped build.
# First, we need to find the previously-shipped build.
my @archiveDirNames = $fileUtil->list_dir($shipArchivesPath, qw/--no-fsdots --dirs-only/) ;
my $lastMaj = 0 ;
my $lastMin = 0 ;
my $lastBix = 0 ;
my $lastVersionDirName ;
for (my $i=0; $i<@archiveDirNames; $i++) {
	my $maj = 0 ;
	my $min = 0 ;
	my $bix = 0 ;
	my $archiveDirName = $archiveDirNames[$i] ;
	if ($archiveDirName =~ m/$revisionBaseName(\d+)\.(\d+)\.(\d+)/) {
		$maj = $1 ;
		$min = $2 ;
		$bix = $3 ;
	}
	elsif ($archiveDirName =~ m/$revisionBaseName(\d+)\.(\d+)/) {
		# This case handles no bugfix digit, for example "1.0"
		$maj = $1 ;
		$min = $2 ;
		$bix = 0 ;
	}
	
# Ignore prior, unshipped builds of the current version
    my $mustBePriorUnshippedBuildOfVersionNowBeingRebuilt  =
		 (
		   ($maj == $revisionComps[0])
		&& ($min == $revisionComps[1])
		&& ($bix == $revisionComps[2])
		) ;
		
	next if ($mustBePriorUnshippedBuildOfVersionNowBeingRebuilt) ;
	
	if ($maj <= $familyLimitMajor) {
		if ($min <= $familyLimitMinor) {
			if ($maj >= $lastMaj) {
				if ($maj > $lastMaj) {
					$lastMin = 0 ;
					$lastBix = 0 ;
				}
				if ($min >= $lastMin) {
					if ($min > $lastMin) {
						$lastBix = 0 ;
					}
					if ($bix >= $lastBix) {
						$lastMaj = $maj ;
						$lastMin = $min ;
						$lastBix = $bix ;
						$lastVersionDirName = $archiveDirName ;
					}
				}
			}
		}
	}	
}
my $lastShipVersion = "$lastMaj.$lastMin.$lastBix" ;
print "\nShould compare files in current built package with last-shipped version $lastShipVersion?\n" ;
print "   Type 's' to skip this step.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to approve.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}
elsif ($userInputChar ne 's') {
	my $lastShipDirPath = $shipArchivesPath . $lastVersionDirName ;
	# Unzip. -b says to treat all files as binary
	`cd \"$lastShipDirPath" ; /usr/bin/unzip -bo \"$zipName\"` ;
	my $unzippedFolder = "$lastShipDirPath/$appName" ;
	my $lastShipAppPath = "$unzippedFolder/$appName.app" ;
	# We use the unix 'diff' program, which can compare directory trees
	my $packageDiffsString = `diff -qr $lastShipAppPath $pathToProduct | grep -v -e 'DS_Store' -e 'Thumbs' | sort` ;
	my @diffs = split("\n", $packageDiffsString) ;
	my $nOnlyInLast = 0 ;
	my $nOnlyInThis = 0 ;
	my $nCodeSignatures = 0 ;
	my $nDiffers = 0 ;
	my $i ;
	my $onlyInLast = "Only in $lastShipDirPath" ;
	my $onlyInThis = "Only in $pathToProduct" ;
	my $onlyInLastLen = length("Only in $lastShipAppPath/") ;
	my $onlyInThisLen = length("$onlyInThis/") ;
	my @onlyInLasts ;
	my @onlyInThiss ;
	my $dieMsg ; # So we can postpone dying until after we clean up
	for ($i=0; $i<@diffs; $i++) {
		my $diff = $diffs[$i] ;
		# Find lines that begin in "Only in "
		if ($diff =~ m/\AOnly in/) {
			# Find lines that end in " _CodeSignature"
			if ($diff =~ m/ _CodeSignature\Z/) {
				$nCodeSignatures++ ;
			}
			elsif ($diff =~ m/\A$onlyInLast/) {
				$nOnlyInLast++ ;
				push(@onlyInLasts, substr($diff, $onlyInLastLen)) ;
			}
			elsif ($diff =~ m/\A$onlyInThis/) {
				$nOnlyInThis++ ;
				push(@onlyInThiss, substr($diff, $onlyInThisLen)) ;
			}
			else {
				$dieMsg = "Cannot interpret diff[1]: $diff." ;
				last ;
			}
		}
		# Find lines that end in " differ"
		elsif ($diff =~ m/ differ\Z/) {
			$nDiffers++ ;
		}
		else {
			$dieMsg = "Cannot interpret diff[2]: $diff." ;
			last ;
		}
	}
	if (!defined($dieMsg)) {
		printf("Differences found comparing to last shipped product version $lastShipVersion:\n") ;
		printf("          _CodeSignature (non-payload) files: %4d\n", $nCodeSignatures) ;
		printf("          Payload items only in last version: %4d\n", $nOnlyInLast) ;
		printf("          Payload items only in this version: %4d\n", $nOnlyInThis) ;
		printf("    Matched items which differ last vs. this: %4d\n", $nDiffers) ;
		if ($nOnlyInLast + $nOnlyInThis + $nCodeSignatures + $nDiffers != $i) {
			$dieMsg =  "Diffs don't add up." ;
		}
		
		if (!defined($dieMsg)) {
			if ($nOnlyInLast > 0) {
				print("Items only in last version:\n") ;
				for (my $i=0; $i<@onlyInLasts; $i++) {
					print("   In $onlyInLasts[$i]\n") ;
				}
			}
			else {
				print "Found 0 payload items only in last version.\n" ;
			}

			if ($nOnlyInThis > 0) {
				print("Items only in this version:\n") ;
				for (my $i=0; $i<@onlyInThiss; $i++) {
					print("   In $onlyInThiss[$i]\n") ;
				}
				print("OK to proceed?  If not type 'a' to abort.\n") ;
				$userInputChar = SSYUtils2::getUserInputChar() ;
				if ($userInputChar eq 'a') {
					$dieMsg =  "User aborted" ;
				}
			}
			else {
				print "Found 0 payload items only in this version.\n" ;
			}
		}
	}
	
	# Clean up
	`rm -Rdf \"$unzippedFolder\"` ;

	if ($dieMsg) {
		die ($dieMsg) ;
	}
}


# Check version of any Plugins in the product
my $pluginsPath = "$pathToProduct/Contents/Plugins" ;
if ($fileUtil->existent($pluginsPath)) {
	my @pluginNames = $fileUtil->list_dir($pluginsPath, qw/--no-fsdots --dirs-only/) ;
	for (my $i=0; $i<@pluginNames; $i++) {
		my $pluginPath = "$pluginsPath/$pluginNames[$i]" ;
		my $revisionNumberString = extractBundleVersion($pluginPath, 1) ;
		print "\nProduct contains version $revisionNumberString of $pluginNames[$i].  Did Xcode copy the latest/correct one?\n" ;
		print "   Type 'return' or any key other key to approve.\n" ;
		print "   Type 'a' to abort this script and exit.\n" ;
		$userInputChar = SSYUtils2::getUserInputChar() ;
		if ($userInputChar eq 'a') {
			die "User aborted" ;
		}
	}
}
else {
	print "\nContents/Plugins/ is **absent** from product package.  Is that OK?\n" ;
	print "   Type 'return' or any key other key to approve.\n" ;
	print "   Type 'a' to abort this script and exit.\n" ;
	$userInputChar = SSYUtils2::getUserInputChar() ;
	if ($userInputChar eq 'a') {
		die "User aborted" ;
	}
}

# Run lint on Localizable.strings files
print "\nShould run plutil lint on strings files?\n" ;
print "   Type 's' to skip this step.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to approve.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}
elsif ($userInputChar ne 's') {
	my $mainAppResources = "$buildsReleasePath$appName.app/Contents/Resources/" ;
	print "   Looking for lproj subdirectories in $mainAppResources\n" ;
	my @resourceNames = $fileUtil->list_dir($mainAppResources, qw/--no-fsdots --dirs-only/) ;
	for (my $i=0; $i<@resourceNames; $i++) {
		if (substr(reverse($resourceNames[$i]), 0, 6) eq "jorpl.") {
			print "      Found one: $resourceNames[$i]\n" ;
			my $lprojDirPath = $mainAppResources . $resourceNames[$i] ;
			my @filenames = $fileUtil->list_dir($lprojDirPath, qw/--no-fsdots --files-only/) ;
			for (my $j=0; $j<@filenames; $j++) {
				if (substr(reverse($filenames[$j]), 0, 8) eq "sgnirts.") {
					my $stringsFilePath = $lprojDirPath . "/" . $filenames[$j] ;
					my $stringsLint = `/usr/bin/plutil -lint "$stringsFilePath"` ;
					print $stringsLint ;
				}
			}
		}
	}
	print "\nDo the results look OK? (May be OK if this product has lproj subdirs buried in a framework.)\n" ;
	print "   Type 'a' to abort this script and exit.\n" ;
	print "   Type 'return' or any key other key to approve.\n" ;
	$userInputChar = SSYUtils2::getUserInputChar() ;
	if ($userInputChar eq 'a') {
		die "User aborted" ;
	}
}

# Extract architectures from main executable
my $mainAppExecutable = "$buildsReleasePath$appName.app/Contents/MacOS/$appName" ;
my $lipoOutput = `/usr/bin/lipo -info "$mainAppExecutable"` ;
my @lipoWords = split(" ", $lipoOutput) ;
# Unfortunately, lipoOutput contains a narrative.  Examples:
#    Non-fat file: /path/to/Whatever is architecture: i386
#    Architectures in the fat file: /path/to/Whatever are: i386 ppc
# We need to eliminate the narrative and just get the last few word(s), which are the archs
@lipoWords = reverse(@lipoWords) ;
my @architectures ;
foreach my $arch (@lipoWords) {
	# Assume that the last word of the narrative contains a colon (:).
	if ($arch =~ m/:/) {
		# This is the last word of the narrative.
		last ;
	}
	
	# $arch is really an architecture
	if ($arch =~ s/ppc7400/ppc/) {
		print "Note: ppc will be used instead of $arch since dwarfdump does not support ppc7400)\n" ;
		$arch = "ppc" ;
	}
	push (@architectures, $arch) ;
}

# Read minimum system version from product's Info.plist
my $minimumSystemVersion = extractInfoPlistKey($pathToProduct, "LSMinimumSystemVersion", 1) ;

# Make readable maximumSystemVersion
my $readableMaximumSystemVersion = $maximumSystemVersion ;
if (!defined($maximumSystemVersion)) {
	$readableMaximumSystemVersion = "<no-maximum>" ;
}

# Ask user if the version we're going to ship is the correct version.
my $archList = join(" ", @architectures) ;
print "Will ship $appName version \"$revisionNumberString\" for Mac OS X \"$minimumSystemVersion\" thru $readableMaximumSystemVersion, for architectures: $archList\n" ;
print "Is this what you want to ship?\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to approve.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	print "Please build so that the product you want to ship is at $buildsReleasePath$appName.app, then try this script again.\n" ;
	die "User aborted" ; ;
}

# Compose variable names based on revisionNumberString
my $revisionName = $revisionBaseName . "$revisionNumberString" ;
my $shipArchiveSubdirectory = "$shipArchivesPath$revisionName/" ;
my $dmgPathLocal="$shipArchiveSubdirectory$dmgName" ;
my $zipPathLocal="$shipArchiveSubdirectory$zipName" ;
print "DERIVED VARIABLES:\n" ;
print "shipArchiveSubdirectory: $shipArchiveSubdirectory\n" ;
print "dmgPathLocal:            $dmgPathLocal\n" ;
print "zipPathLocal:            $zipPathLocal\n\n" ;

print "Choose update channel:\n" ;
print "  '1' alpha only\n" ;
print "  '2' beta only (Use if alpha has a later version.)\n" ;
print "  '3' beta & alpha\n" ;
print "  '4' production only (Use if both alpha and beta have later versions)\n" ;
print "  '5' production & beta  (Use if alpha has later a version.)\n" ;
print "  '6' production, beta & alpha  (Use if this is the greatest AND latest.)\n" ;
print "  'd' (debug)      --->  $serverDomain/$pathServerHtmlToProductsDirD\n" ;
print "  's' (special)    --->  $serverDomain/$pathServerHtmlToProductsDirS\n" ;

my $ok ;
my $shipmentType ;

my $pathServerHtmlToProductsDir ;
my @serverAppcastPaths ;
while ($pathServerHtmlToProductsDir eq "") {
	$userInputChar = SSYUtils2::getUserInputChar() ;
	$shipmentType = $userInputChar ;
	if ($userInputChar eq '1') {
		$pathServerHtmlToProductsDir = $pathServerHtmlToProductsDirA ;
		push (@serverAppcastPaths,
		"$pathServerHtmlToProductsDirA$appcastName"
		) ;
	}
	elsif ($userInputChar eq '2') {
		$pathServerHtmlToProductsDir = $pathServerHtmlToProductsDirB ;
		push (@serverAppcastPaths,
		"$pathServerHtmlToProductsDirB$appcastName"
		) ;
	}
	elsif ($userInputChar eq '3') {
		$pathServerHtmlToProductsDir = $pathServerHtmlToProductsDirB ;
		push (@serverAppcastPaths,
		"$pathServerHtmlToProductsDirB$appcastName",
		"$pathServerHtmlToProductsDirA$appcastName"
		) ;
	}
	elsif ($userInputChar eq '4') {
		$pathServerHtmlToProductsDir = $pathServerHtmlToProductsDirN ;
		push (@serverAppcastPaths,
		"$pathServerHtmlToProductsDirN$appcastName"
		) ;
	}
	elsif ($userInputChar eq '5') {
		$pathServerHtmlToProductsDir = $pathServerHtmlToProductsDirN ;
		push (@serverAppcastPaths,
		"$pathServerHtmlToProductsDirN$appcastName",
		"$pathServerHtmlToProductsDirB$appcastName"
		) ;
	}
	elsif ($userInputChar eq '6'){
		$pathServerHtmlToProductsDir = $pathServerHtmlToProductsDirN ;
		push (@serverAppcastPaths,
		"$pathServerHtmlToProductsDirN$appcastName",
		"$pathServerHtmlToProductsDirB$appcastName",
		"$pathServerHtmlToProductsDirA$appcastName"
		) ;
	}
	elsif ($userInputChar eq 'd') {
		$pathServerHtmlToProductsDir = $pathServerHtmlToProductsDirD ;
	}
	elsif ($userInputChar eq 's') {
		$pathServerHtmlToProductsDir = $pathServerHtmlToProductsDirS ;
	}
	else {
		print "Bad answer, try again.\n" ;
	}
}	

my $updateDescriptionPath   = "$pathServerHtmlToProductsDir$updateDescriptionName" ;
my $updateDescriptionURL    = "http://$serverDomain/$updateDescriptionPath" ;
my $serverRootToProductsDir = $pathServerHtml . $pathServerHtmlToProductsDir ;

print "Will publish:\n" ;
print "   app: $appName version $revisionNumberString\n" ;
print "    to: $serverDomain/$serverRootToProductsDir\n" ;
print "Writing the update description (aka Release Notes) to:\n" ;
print "        $updateDescriptionPath\n" ;


print "\nShould inspect dSYM files?  ** NEEDED for dSYMs to be ARCHIVED later!!!\n" ;
print "   Type 's' to skip this step.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to approve.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
my @dSymPaths ; # Collect good dSYM paths for later, when moving to permanent archive subfolder
if ($userInputChar eq 'a') {
	die "User aborted" ;
}
elsif ($userInputChar ne 's') {
	my @dSymNames ;
	# The scanBundle subroutines dig in recursively
	scanBundleForDSyms($pathToProduct, \@dSymNames, "   ") ;

	# Check the dSYM file for each dSymName, and while we're at it form an array of dSymPaths.  @dSymNames and @dSymPaths will have corresponding elements.
	print "\nWill inspect dSYM files for architectures:" ;
	foreach my $arch (@architectures) {
		print " $arch" ;
	}
	print "\n" ;
	my $nGood = 0 ;
	my $nZeroSourceFiles = 0 ;
	my $nDiffFileCountForDiffArch = 0 ;
	my $nMissingDSym = 0 ;
	foreach my $dSymName (@dSymNames) {
		printf "   $dSymName\n" ;
		my $dSymPath = $buildsReleasePath . $dSymName . ".dSYM" ;
		if ($fileUtil->existent($dSymPath)) {
			my $isFirstArch = 1 ;
			my $firstNSourceFiles ;
			foreach my $arch (@architectures) {
				my $thisNSourceFiles = 0 ;
				my $dwarfDump ;
				my $cmd = "/usr/bin/dwarfdump --arch=$arch -r0 \"$dSymPath\"" ;
				my $dump = `$cmd` ;
				# Count the number of occurrences of the string "Compile Unit: "
				$thisNSourceFiles = $dump =~ s/Compile Unit://g ;
				my $notCountingArclite = "" ;
				my $hasArclite = ($dump =~ m|/SourceCache/arclite/arclite|) ;
				if ($hasArclite) {
					# Subtract one for arclite.m, which is apparently something that the linker inserts into an x86_64 build but not i386.
					$thisNSourceFiles-- ;
					$notCountingArclite = " (not counting arclite.m)" ;
				}
				printf "      $thisNSourceFiles source files symbolized for arch=$arch$notCountingArclite\n" ;

				push @dSymPaths, $dSymPath ;

				if ($isFirstArch) {
					$firstNSourceFiles = $thisNSourceFiles ;
					$isFirstArch = 0 ;
				}
				else {
					if ((length($thisNSourceFiles) == 0) && (length($thisNSourceFiles) == 0)) {
						$nZeroSourceFiles++ ;
						printf "      Warning:  Zero source files dSYMed for arch=$arch\n" ;
					}
					elsif ($firstNSourceFiles != $thisNSourceFiles) {
						printf "      Warning:  Different arch has dSYMed different count of source files\n" ;
						printf "         Try comparing the output of this command:\n" ;
						printf "             $cmd | grep AT_name\n" ;
						printf "         using different --arch= values:" ;
						@architectures = sort(@architectures) ;
						foreach my $archi (@architectures) {
							printf " $archi" ;
						}
						printf "\n" ;
							
						$nDiffFileCountForDiffArch++ ;
					}
					else {
						$nGood++ ;
					}
				}
			}
		}
		else {
			printf "      Warning:  Missing dSYM file for $dSymName\n" ;
			$nMissingDSym++ ;
		}
	}
	
	my $nExpectedDSyms = @dSymNames ;
	if ($nExpectedDSyms != $nGood) {
		print "\nAttention: Issues were found in dSYMs.  Summary:\n" ;
		printf("      %3d contain data for zero source files\n", $nZeroSourceFiles) ;
		printf("      %3d have diff source file counts for diff architectures\n", $nDiffFileCountForDiffArch) ;
		printf("      %3d No dSYM file found\n", $nMissingDSym) ;
		printf("      %3d Look good\n", $nGood) ;
		printf("      %3d Total Expected\n", $nExpectedDSyms) ;
		print "   Type 'return' or any key other key to continue DESPITE TROUBLE.\n" ;
		$userInputChar = SSYUtils2::getUserInputChar() ;
		if ($userInputChar eq 'a') {
			die "User aborted" ;
		}
	}
	else {
		printf "Found $nGood dSYM files, as expected, and all look good.\n" ;
	}
}

my $scratchDirOuter = File::Spec->catdir($buildsReleasePath, (SSYUtils2::programName() . "_Temp_" . $appName)) ;
my $scratchDirInner = File::Spec->catdir($scratchDirOuter, $appName) ;
my $scratchProductPkg = File::Spec->catdir($scratchDirInner, "$appName.app") ;

# scratchDirInner is required because Sparkle expects us to zip a *directory* named $appName which *contains* $appName.app.

# scratchDirOuter is: /Users/jk/Documents/Programming/Builds/Release/SSYShipProduct_Temp_BookMacster
# scratchDirInner is: /Users/jk/Documents/Programming/Builds/Release/SSYShipProduct_Temp_BookMacster/BookMacster
# scratchProductPkg is: /Users/jk/Documents/Programming/Builds/Release/SSYShipProduct_Temp_BookMacster/BookMacster/BookMacster.app


print "\nShould make a temporary \"scratch\" directory and copy app product and accessories to it?\n" ;
print "   The \"scratch\" product will temporarily be at:\n" ;
print "     $scratchProductPkg\n" ;
print "   Type 's' to skip this step.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to approve.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}
elsif ($userInputChar ne 's') {
	# Make new subfolder for this revision
	SSYUtils2::makeDirectoryOrDie($scratchDirOuter) ;
	chdir($scratchDirOuter) or die "Failed cd to $scratchDirOuter" ;
	printf "Changed working directory to:\n   %s\n", SSYUtils2::currentWorkingDirectory() ;

	# Start it out by copying the Accessories directory to the temporary directory
	# and renaming it.  This has everything we need except the app
	SSYUtils2::copyDirectoryOrDie("\"$commonAccessoriesPath\"", "\"$scratchDirInner\"") ;
	
	# Copy the app (an important non-accessory!) to the newly-renamed directory
	SSYUtils2::copyDirectoryOrDie("\"$buildsReleasePath$appName.app\"", "\"$scratchProductPkg\"") ;
}

# Note that we have not stripped anything yet, and will not strip the original product which is in $buildsReleasePath.  Our reason is that this is the product accessed by Xcode, and if we stripped it, then rebuilt in Xcode for some reason before cleaning, the GenerateDSYMFile build steps in Xcode would generate .dSYM files from executables that have already had their symbols stripped, resulting in empty dSYM files that has no symbols (Apple Bug ID 7145893).  Also, we have not done Code Signing yet since that must be done after stripping.





print "\nShould strip all executables in the package?\n" ;
print "   Type 's' to skip this step.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to approve.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}
elsif ($userInputChar ne 's') {
	my @pathsToStrip ;
	my @stripOptions ;
	# The scanBundle subroutines dig in recursively
	scanBundleForStripping($scratchProductPkg, \@pathsToStrip, \@stripOptions, "   ") ;
	
	# Now modify @stripOptions by replacing any item whose default strip option has been overridden by inclusion into the stripAllFrom or stripOnlyNonGlobalFrom configuration settings.
	for (my $i=0; $i<@pathsToStrip; $i++) {
		my $name = SSYUtils2::lastPathComponent($pathsToStrip[$i]) ;
		my $stripAll = 0 ;
		my $stripOnlyNonGlobal = 0 ;
	
		foreach my $specialName (@stripAllFrom) {
			if ($specialName eq $name) {
				$stripOptions[$i] = "" ;
				printf "Default overridden: Will strip all symbols from $name.\n"
			}
		}
		foreach my $specialName (@stripOnlyNonGlobalFrom) {
			if ($specialName eq $name) {
				$stripOptions[$i] = "-x" ;
				printf "Default overridden: Will strip only non-global symbols from $name.\n"
			}
		}
	}

	my $nPathsToStrip = @pathsToStrip ;
	my $nTroubles = 0 ;
	for (my $i=0; $i<@pathsToStrip; $i++) {
		my $j = $i+1 ;
		my $name = SSYUtils2::lastPathComponent($pathsToStrip[$i]) ;
		print "   Stripping with options \"$stripOptions[$i]\" : $name ($j/$nPathsToStrip)\n" ;
		# The following two lines are equivalent.  One is commented out.
		# if (-e $pathsToStrip[$i]) {
		if ($fileUtil->existent($pathsToStrip[$i])) {
			my $sizeBeforeStrip = `/usr/bin/stat -f \"%z\" \"$pathsToStrip[$i]\"` ;
			printf "     Bytes before: %8d\n", $sizeBeforeStrip ;

			my @sysargs = ("/usr/bin/strip") ;
			if (length($stripOptions[$i]) > 0) {
				push @sysargs, $stripOptions[$i] ;
			}
			push @sysargs, "\"$pathsToStrip[$i]\"" ;
			SSYUtils2::systemDoOrDie(@sysargs) ;

			my $sizeAfterStrip = `/usr/bin/stat -f \"%z\" \"$pathsToStrip[$i]\"` ;
			printf "     Bytes after : %8d\n", $sizeAfterStrip ;
		}
		else {
			print "   TROUBLE!  No executable found for $name.\n" ;
			print "      Complete path is:\n         \"$pathsToStrip[$i]\"\n" ;
			$nTroubles++ ;
		}
	}
	
	if ($nTroubles > 0) {
		print "\nThere was TROUBLE found with $nTroubles items.\n" ;
		print "   Type 'a' to abort this script and exit.\n" ;
		print "   Type 'return' or any key other key to continue DESPITE TROUBLE.\n" ;
		$userInputChar = SSYUtils2::getUserInputChar() ;
		if ($userInputChar eq 'a') {
			die "User aborted" ;
		}
	}
}


print "\nShould check architectures of all executables in the package?\n" ;
print "   Type 's' to skip this step.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to approve.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}
elsif ($userInputChar ne 's') {
	my @pathsToExecutables ;
	# The scanBundle subroutines dig in recursively
	scanBundleForArchitectures($scratchProductPkg, \@pathsToExecutables, "   ") ;

	print "\nArchitecture Check Results:\n" ;
	for (my $i=0; $i<@pathsToExecutables; $i++) {
		# Things we'll need for IPC::Run::run()
		my $command = "/usr/bin/lipo" ;
		my @args ;
		my $stdin ;
		my $stdout ;
		my $stderr ;
		my $exitOk ;
		
		# If path is a .app or .plugin, append /Contents/MacOS
		my $path = $pathsToExecutables[$i] ;
		if (($path =~ m/.app$/) || ($path =~ m/.plugin$/)) {
			$path = $path . "/Contents/MacOS" ;
		}
		# If we are in a MacOS or framework (version "A", "B", etc.), find the executable file and append it.  It should be the only regular file in there.
		if (($path =~ m</MacOS$>) || ($path =~ m</A$>) || ($path =~ m</B$>) || ($path =~ m</C$>)) {
			my @filenames = $fileUtil->list_dir($path, qw/--no-fsdots 	--files-only/) ;
			my $executableName = $filenames[0] ;
			$path = "$path/$executableName" ;
		}
		
		my $filename = basename($path) ;
		
		@args = ("-info", $path) ;
		$exitOk = IPC::Run::run [ $command, @args ], \$stdin, \$stdout, \$stderr ;
		# stdout will be one of two forms:
		#  Non-fat file: /path/to/executableName is architecture: x86_64
		#  Architectures in the fat file: /path/to/executableName are: x86_64 i386
		# In either case we can split at colons and take the third substring
		my @stdouts = split(":", $stdout) ;
		my $archsString = $stdouts[2] ;
		# Sort because, oddly, lipo lists archs in random order.
		$archsString = join(" ", sort(split(" ", $archsString))) ;
		# stdout did end in a newline, but the above split+join stripped that.
		# In the following line, "A" means "A text (ASCII) string, will be space padded".
		my $pad_length = 25 ;
		$filename = pack("A$pad_length", $filename) ;
		print "$filename:  $archsString\n" ;
	}
}

if(defined($codeSigningIdentity)) {
	print "\nShould perform Code Signing on all executables in the package?\n" ;
	print "   Type 's' to skip this step.\n" ;
	print "   Type 'a' to abort this script and exit.\n" ;
	print "   Type 'return' or any key other key to approve.\n" ;
	$userInputChar = SSYUtils2::getUserInputChar() ;
	if ($userInputChar eq 'a') {
		die "User aborted" ;
	}
	elsif ($userInputChar ne 's') {
		codesignDeveloperID($scratchProductPkg, $codeSigningIdentity) ;
	}
}


print "\nShould create a new permanent archive subfolder for packaged shipments?\n" ;
print "   Type 's' to skip this step.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to approve.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}
elsif ($userInputChar ne 's') {
	# Make a new subfolder in shipArchivesPath into which we'll archive the
	# .dmg and .zip we're going to publish
	SSYUtils2::makeDirectoryOrDie("$shipArchiveSubdirectory") ; 
}


print "\nShould create the zip archive of app product and accessories?\n" ;
print "   Type 's' to skip this step.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to approve.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}
elsif ($userInputChar ne 's') {
	# Create our zip archive of the files we just copied
	# When using zip, it is important that you cd to the parent of the thing that you want to zip and then give zip, as it last argument, the relative path to what you want to zip.  If you give it a full path, you'll get Russian dolls of directories when you unzip.
	chdir($scratchDirOuter) or die "Failed cd to $scratchDirOuter" ;
	printf "Changed working directory to:\n   %s\n", SSYUtils2::currentWorkingDirectory() ;
	# Note that I cannot specify the output path for zip; it goes to the current directory, which is $scratchDirOuter.
	@sysargs = ("zip", "-r", "-y", "\"$zipName\"", "\"$appName\"") ;
	print "zipping product and accessories\n" ;
	SSYUtils2::systemDoOrDie(@sysargs) ;
}


print "\nShould add additional dmg-only shipping accessories to temp?\n" ;
print "   Type 's' to skip this step.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to approve.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}
elsif ($userInputChar ne 's') {
	SSYUtils2::copyContentsOfDirectoryToOtherExistingDirectoryOrDie("\"$dmgAccessoriesPath\"", "\"$scratchDirInner\"") ;
}


print "\nShould create disk image?\n" ;
print "   Type 's' to skip this step.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to approve.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ; ;
}
elsif ($userInputChar ne 's') {
	# Since I cannot specify the output path for zip, I do it the same way for dmg
	# Just work in the current directory, which is $scratchDirOuter.
	chdir($scratchDirOuter) or die "Failed cd to $scratchDirOuter" ;  # In case user skipped the previous chdir in product zip
	printf "Changed working directory to:\n   %s\n", SSYUtils2::currentWorkingDirectory() ;
	@sysargs = ("hdiutil", "create", "-verbose", "-srcfolder", "\"$scratchDirInner\"", "-format", "UDZO", "-scrub", "-imagekey", "zlib-level=9", "-ov", "\"$dmgName\"") ; 
	# UDZO means compressed
	# zlib-level = 9 says to take a long time and compress as much as possible
	# -ov says to overwrite old dmg if any is found
	SSYUtils2::systemDoOrDie(@sysargs) ;
	
	# Make the disk image "Internet Enabled".  This causes the .dmg to automatically trash
	# itself after it has been decompressed.
	@sysargs = ("hdiutil", "internet-enable", "\"$dmgName\"") ;
	SSYUtils2::systemDoOrDie(@sysargs) ;
}


print "\nShould move zip and/or dmg and copy dSYM archives and otherArchivees to permanent archive subfolder?\n" ;
print "   Type 's' to skip this step.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to approve.\n" ;
my $didMoveDmg = 0 ;
my $didMoveZip = 0 ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ; ;
}
elsif ($userInputChar ne 's') {
	chdir($scratchDirOuter) or die "Failed cd to $scratchDirOuter" ;  # One last time for good measure.
	printf "Changed working directory to:\n   %s\n", SSYUtils2::currentWorkingDirectory() ;
	$didMoveDmg = move("$dmgName", "$shipArchiveSubdirectory$dmgName") ;
	$didMoveZip = move("$zipName", "$shipArchiveSubdirectory$zipName") ;

	chdir($buildsReleasePath) or die "Failed cd to $buildsReleasePath" ;  
	printf "Changed working directory to:\n   %s\n", SSYUtils2::currentWorkingDirectory() ;
	printf "Will try copying to: $shipArchiveSubdirectory\n" ;
	# Append the dSYM paths that we collected above, during Inspect dSYMS
	push @otherArchivees, @dSymPaths ;
	foreach my $otherArchivee (@otherArchivees) {
		@sysargs = ("cp", "-RLfp", "\"$otherArchivee\"", "\"$shipArchiveSubdirectory\"") ;
		SSYUtils2::systemDoOrDie(@sysargs) ;
		printf("   Tried: $otherArchivee\n") ;
	}
}

print "\nThe dmg and/or zip should now be in:\n" ;
print "      $shipArchiveSubdirectory\n" ;
print "    You should now do a Final Inspection before uploading.\n" ;
print "    Recommended Final Inspection Items:\n    * Open a document in Deployment version of OS X\n* Agent or Helper operation\n    * Demo License retrival\n    * Purchase\n    * AppleScripts or Automator Actions\n    * Make sure that Localizable.strings files are UTF-16, not UTF-8.\n    * Make sure that Help button(s) work.\n    * Check out any revised pages in Help Book.\n    * Run localized to a foreign language and check any new strings.\n       (For Bookdog, type Launchbar shortcut 'bdll'\n" ;
print "\nAffirm that the product passed Final Inspection.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to affirm.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}


print "Should upload zip from $zipPathLocal?\n" ;
print "   Type 's' to skip this step.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to approve.  Note that, after this point, you\n" ;
print "       **MUST** continue on to update the Sparkle feed, or else users will get\n" ;
print "       an ugly \"Error Extracting Archive\" due to mismatched DSA signatures !!\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ; ;
}
elsif ($userInputChar ne 's') {
	print "uploading from: $zipPathLocal\n" ;
	print "            to: $serverRootToProductsDir$zipName\n" ;

	# tuff-ftp-put will die() if anything goes wrong.
	system("tuff-ftp-put.pl  \"$zipPathLocal\" \"$serverRootToProductsDir\" $zipName $serverDomain $ftpAccountName $ftpAccountPassword") ;
}


my $nAppcasts = @serverAppcastPaths ;
print "\nShould update $nAppcasts appcasts?  If you have uploaded the zip, you MUST do this (see above).\n" ;
print "   Type 's' to skip this step.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to approve.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ; ;
}
elsif ($userInputChar ne 's') {
	chdir($shipArchiveSubdirectory) or die "Failed cd to $shipArchiveSubdirectory" ;
	printf "Changed working directory to:\n   %s\n", SSYUtils2::currentWorkingDirectory() ;
	my $signZipCmd = "ruby \"$zipSignerPath\" \"$zipName\" \"$zipPrivateKeyPath\"" ;
	print "Will sign zip with:\n   $signZipCmd\n" ;
	my $updateSignature = `$signZipCmd` ;
	chomp($updateSignature) ;
	print "Signing the zip product for Sparkle yielded signature:\n   $updateSignature\n" ;
	my $nChars = length($updateSignature) ;
	my $nMin = 60 ;
	my $nMax = 64 ;
	if (($nChars > $nMax) || ($nChars < $nMin)){
		die "Got $nChars characters in updateSignature.  Not accepted.\n" ;
	}
	
	my $publicKeyResourceFilename = extractInfoPlistKey($pathToProduct, "SUPublicDSAKeyFile", 1) ; 
	
	my $publicKeyPath = $pathToProduct . "/Contents/Resources/$publicKeyResourceFilename" ;

	open (my $file, '<', $publicKeyPath) or die "Could not open $publicKeyResourceFilename in app resources.  $!\n" ;
	my $publicKey = "" ;
	while (<$file>) {
		chomp;
		if (/BEGIN PUBLIC KEY/) {
		}
		elsif (/END PUBLIC KEY/) {
			last ;
		}
		else {
			$publicKey .= $_ ;
		}
	}
	close($file) ;
	my $keyLen = length($publicKey) ;
	if ($keyLen != 1108) {
		die "Length of Public key in $publicKeyPath is $keyLen characters.  Expected 1108.\n" ;
	}

	my $verifyCmd = "verifysparkledsa -v \"$updateSignature\" \"$publicKey\" \"$zipName\"" ;
	print "Will verify $zipName with signature:\n   $updateSignature\nand public key:\n$publicKey\n" ;
	my $verifyResult = `$verifyCmd` ;
	print $verifyResult ;
	if ($? != 0) {
		die "Signature for Sparkle on zip package failed to verify." ;
	}	


	my $appcastProductFilename ;
	if ($appcastProductFileExtension eq "dmg") {
		$appcastProductFilename = $dmgName ;
	}
	elsif ($appcastProductFileExtension eq "zip") {
		$appcastProductFilename = $zipName ;
	}
	else {
		die "appcastProductFilename $appcastProductFilename not supported.\n" ;
	}

	print "Will appcast:\n     Product Filename:\n      $appcastProductFilename\n  Minimum System Version:\n$minimumSystemVersion\n  Maximum System Version:\n$maximumSystemVersion\n       Description URL:\n      $updateDescriptionURL\n" ;
	
	foreach my $serverAppcastPath (@serverAppcastPaths) {
		# Third sysarg should be "-cvs" for safe mode asking "OK to do this?" before publishing, "-cv" for "just publish"
		@sysargs = ("appcast.pl", "-a", "-cv", "-m$nItemsToLeaveInAppcast", "\"-w$serverAppcastPath\"") ;
		if ($minimumSystemVersion) {
			push @sysargs, "\"-i$minimumSystemVersion\"" ;
		}
		if ($maximumSystemVersion) {
			push @sysargs, "\"-i$maximumSystemVersion\"" ;
		}
		if ($shipmentType eq 'p') {
			push @sysargs, "\"-y$localAppcastPath\"" ;
		}
		push @sysargs, "\"-k$updateSignature\"" ;
		if ($shipmentType eq 'p') {
			push @sysargs, "\"-y$localAppcastPath\"" ;
		}
		push @sysargs, ("\"$appName\"", $appcastProductFilename, "\"$revisionNumberString\"", "\"$serverDomain\"", "\"$ftpAccountName\"", "\"$ftpAccountPassword\"", "\"$pathServerHtml\"", "\"$pathServerHtmlToProductsDir\"", "\"$updateDescriptionURL\"") ;

		print "Will invoke appcast.pl like this\n" ;
		foreach my $argument (@sysargs) {
			print "$argument " ;
			}
		print "\n" ;

		SSYUtils2::systemDoOrDie(@sysargs) ;
	}
}


print "\nShould smarty-markdown and upload latest Update Description?  (Needed for Sparkle!)\n" ;
print "   Type 's' to skip this step.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to approve.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ; ;
}
elsif ($userInputChar ne 's') {
	print "reading markdown file\n" ;
	open (SOURCEDATA, $updateDescriptionMarkdownPath) ;
	my $j = 0 ;
	my @sourceLines ;
	while (my $aLine = <SOURCEDATA>) {
		$aLine = SSYUtils2::preMarkdown ($aLine, $j, $updateDescriptionMarkdownPath) ;
		push @sourceLines, $aLine ;
		$j++ ;	
	}
	my $markdownSource = join ("", @sourceLines) ;
	# Process through smartMarkdown
	print "processing markdown to HTML\n" ;
	my $htmlBody = SSYUtils2::smartMarkdown($markdownSource, SSYUtils2::scriptParentPath()) ;	
	
	# Add HTML head and tail
	print "adding HTML head and tail\n" ;
	my $htmlHead = <<HTMLHEAD ;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!-- To make changes, edit the Markdown source, not this file! -->
<html>
<head>
	<title>Update News for $appName</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<style TYPE="text/css">
	<!--
		.Normal { font-family: "Arial", "Osaka", "Verdana", "Helvetica"; font-size:12.0px; font-weight:normal }
		h1 { font-size:16.0px; font-weight:bold }
		h2 { font-size:12.0px; font-weight:bold }
	-->
	</style>
</head>

<body>
<span class=Normal>
HTMLHEAD
	my $htmlTail = "</span>\n</body>\n</html>\n" ;
	my $html = $htmlHead . $htmlBody . $htmlTail ;

	# Write to file
	print "writing local file\n" ;
	(my $junk1, my $updateDescriptionDir, my $updateDescriptionMarkdownFilename) = File::Spec->splitpath($updateDescriptionMarkdownPath) ;
	my $updateDescriptionLocalHtmlPath = File::Spec->catdir(($updateDescriptionDir, $updateDescriptionName)) ;
	my $didWriteOK = open(HTML,">$updateDescriptionLocalHtmlPath") ; 
	print HTML $html ;
	close(HTML) ;


	print "creating upload path\n" ;
	my $updateDescriptionRemoteFullPath="ftp://$ftpAccountName:$ftpAccountPassword\@$serverDomain/$pathServerHtml$updateDescriptionPath" ;
	print "uploading from: $updateDescriptionLocalHtmlPath\n" ;
	print "            to: $updateDescriptionRemoteFullPath\n" ;
	@sysargs = ("ftp", "-u", "\"$updateDescriptionRemoteFullPath\"", "\"$updateDescriptionLocalHtmlPath\"") ;
	SSYUtils2::systemDoOrDie(@sysargs) ;
	print "uploaded Update Description\n" ;
	
	print "\nReminder: Before clicking 'Submit' to MacUpdate, be careful to examine all fields.  The web browser's autofill can be your enemy!  Type any key to continue.\n" ;
	$userInputChar = SSYUtils2::getUserInputChar() ;

	print "\nShould post to MacUpdate now?\n" ;
	print "   Type 's' to skip this step.\n" ;
	print "   Type 'a' to abort this script and exit.\n" ;
	print "   Type 'return' or any key other key to approve.\n" ;
	$userInputChar = SSYUtils2::getUserInputChar() ;
	if ($userInputChar eq 'a') {
		die "User aborted" ; ;
	}
	elsif ($userInputChar ne 's') {
		# pbcopy copies to clipboard
		`echo \"$htmlBody\" | /usr/bin/pbcopy` ;

		print"\nUpdate News HTML is now on your clipboard.  According to Warren Mills <warren\@macupdate.com>, MacUpdate allows only three HTML tags in 'Description' and 'Release Notes': <strong>, <break>, and <ul>.  Type any key to continue\n" ;  
		$userInputChar = SSYUtils2::getUserInputChar() ;

		`open http://www.macupdate.com/developers/update/` ;
	}

}

print "\nShould upload revised Help Book from $helpBookLocalHtmlPath?\n" ;
print "   Type 's' to skip this step.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to approve.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ; ;
}
elsif ($userInputChar ne 's') {
	@sysargs = ("syncremotedir.pl", "-v", "-x.DS_Store", "-xSSYMH.AppAnchors.h", "-xSSYMH.AppAnchors.m") ;
	my @xOptions ;
	foreach my $excludedDocument (@excludedDocuments) {
		my $xString = "-x'" ;
		$xString .= $excludedDocument ;
		$xString .= "'" ;
		push @xOptions, $xString ;
	}
	push @sysargs, @xOptions ;
	# Append the six string arguments required by syncremotedir.pl
	push @sysargs, "\"$pathServerHtmlToHelpBookDir\"", "\"$helpBookLocalHtmlPath\"", "\"$serverDomain\"", "\"$ftpAccountName\"", "\"$ftpAccountPassword\"", "\"$pathServerHtml\"" ;
	SSYUtils2::systemDoOrDie(@sysargs) ;
	print "uploaded documentation\n" ;
}

print "\nShould upload disk image?\n" ;
print "   Type 'return' or any key except 'n' to approve.\n" ;
print "   Type 's' to skip this step.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ; ;
}
elsif ($userInputChar ne 's') {
	print "uploading from: $dmgPathLocal\n" ;
	print "            to: $serverRootToProductsDir$dmgName\n" ;

	# tuff-ftp-put will die() if anything goes wrong.
	system("tuff-ftp-put.pl  \"$dmgPathLocal\" \"$serverRootToProductsDir\" $dmgName $serverDomain $ftpAccountName $ftpAccountPassword") ;
}	

print "\nShould publish website?\n" ;
print "   Type 's' to skip this step.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any key other key to approve.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ; ;
}
elsif ($userInputChar ne 's') {
	@sysargs = ("open", "\"$publishSiteScript\"") ;
	SSYUtils2::systemDoOrDie(@sysargs) ;
	print "publishing website (in separate forked process)\n" ;
}


my $nextRevisionNumberString ;

foreach my $otherUploadString (@otherUploadStrings) {
	my @otherUploadValues  = split /,/, $otherUploadString ;
	my $nValues = @otherUploadValues ;
	if ($nValues != 4) {
		print "Found $nValues, need 4 comma-separated values for other upload:\n   $otherUploadString\nin config file\n   $configPath\n" ;
		stop ("Bad configuration. ") ;
	}
	my $source = SSYUtils2::prependHome($otherUploadValues[0]) ;
	my $followSymlinks = $otherUploadValues[2] ;
	my $doCodesign = $otherUploadValues[3] ;
	my $doCodesignString = "" ;
	if ($doCodesign) {
		$doCodesignString = ", codesign" ;
	}
	if (!(($followSymlinks == 0) || ($followSymlinks == 1))) {
		print "last comma-separated value should be 0 or 1 in other upload:\n   $otherUploadString\nin config file\n   $configPath\n" ;
		stop ("Bad configuration. ") ;
	}
	
	print "\nShould zip" . $doCodesignString . " and upload $source?\n" ;
	print "   Type 's' to skip this step.\n" ;
	print "   Type 'a' to abort this script and exit.\n" ;
	print "   Type 'return' or any key other key to approve.\n" ;
	$userInputChar = SSYUtils2::getUserInputChar() ;
	if ($userInputChar eq 'a') {
		die "User aborted" ; ;
	}
	elsif ($userInputChar ne 's') {
		(my $sourceVolume, my $sourceParentPath, my $sourceFilename) = File::Spec->splitpath($source) ;
		my $destin = $pathServerHtml . $otherUploadValues[1] . ".zip" ;
		my $zipname = SSYUtils2::filenameOfPath($otherUploadValues[1]) ;
		# When using zip, it is important that you cd to the parent of the thing that you want to zip and then give zip, as it last argument, the relative path to what you want to zip.  If you give it a full path, you'll get Russian dolls of directories when you unzip.
		chdir($sourceParentPath) or die "Failed cd to $sourceParentPath" ;
		printf "Changed working directory to:\n   %s\n", SSYUtils2::currentWorkingDirectory() ;
		
		if ($doCodesign) {
			codesignDeveloperID($source, $codeSigningIdentity) ;
		}

		# zip it.
		@sysargs = ("zip", "-r") ;
		if (!$followSymlinks) {
			push @sysargs, "-y" ;
			print "zip will not follow symlinks while zipping $source\n" ;
		}
		else {
			print "zip will follow symlinks while zipping $source\n" ;
		}
		my $tempZipFile = File::Temp->tmpnam() ;
		push @sysargs, "\"$tempZipFile\"", "\"$sourceFilename\"" ;
		SSYUtils2::systemDoOrDie(@sysargs) ;

		# upload it.
		my $tempZipFileDotZip = "$tempZipFile.zip" ;
		my $zipRemoteFullPath="ftp://$ftpAccountName:$ftpAccountPassword\@$serverDomain/$destin" ;
		@sysargs = ("ftp", "-u", "\"$zipRemoteFullPath\"", "\"$tempZipFileDotZip\"") ;
		SSYUtils2::systemDoOrDie(@sysargs) ;
		SSYUtils2::removeFileOrDie($tempZipFileDotZip) ;
	}
}

print "\nRemoving temporary directory because it is no longer needed.)\n" ;
SSYUtils2::removeDirectoryOrDie($scratchDirOuter) ;

print "\nDone uploading $appName version $revisionNumberString and other uploads.\n" ;

print "\nPlease commit all source code now.\n" ;
print "   Type 'a' to abort this script and exit.\n" ;
print "   Type 'return' or any other key to continue.\n" ;
$userInputChar = SSYUtils2::getUserInputChar() ;
if ($userInputChar eq 'a') {
	die "User aborted" ;
}

if (defined($xcconfigPath)) {
	print "\nRecommend immediately rolling rev $xcconfigPath\n" ;
	print "Should roll rev now?\n" ;
	print "   Type 's' to skip this step.\n" ;
	print "   Type 'a' to abort this script and exit.\n" ;
	print "   Type 'return' or any key other key to approve.\n" ;
	$userInputChar = SSYUtils2::getUserInputChar() ;
	if ($userInputChar eq 'a') {
		die "User aborted" ; ;
	}
	elsif ($userInputChar ne 's') {
		my $nextRevisionNumberString ;
		print "You have just shipped $revisionNumberString.\n" ;
		while (($nextRevisionNumberString == undef) && ($userInputChar ne 's') && ($userInputChar ne 'a')) {
			print "Please enter the ^^NEXT^^ version of \"$appName\"\n" ;
			$nextRevisionNumberString = <STDIN> ;
			chomp $nextRevisionNumberString ;
		
			print "Next version: $nextRevisionNumberString\n" ;
			print "   Type 's' to skip this step.\n" ;
			print "   Type 'a' to abort this script and exit.\n" ;
			print "   Type 'r' to re-enter next version number.\n" ;
			print "   Type 'return' or any key other key to approve.\n" ;
			$userInputChar = SSYUtils2::getUserInputChar() ;
			if ($userInputChar eq 'r') {
				$nextRevisionNumberString = undef ;
			}
		}
	
		if ($userInputChar eq 'a') {
			die "User aborted" ; ;
		}
		elsif ($userInputChar ne 's') {
			print ("Will set CURRENT_PROJECT_VERSION to $nextRevisionNumberString in $xcconfigPath\n") ;
	
			# Read the file, producing new contents by replacing any existing CURRENT_PROJECT_VERSION with new value.
			open (my $xcconfigFileIn, '<:encoding(UTF-8)', $xcconfigPath) or die "Could not read $xcconfigPath.  $!\n" ;
			my $configContents = "" ;
			my $didReplace = 0 ;
			while (<$xcconfigFileIn>) {
				if (/CURRENT_PROJECT_VERSION/) {
					$configContents .= "CURRENT_PROJECT_VERSION = $nextRevisionNumberString\n" ;
					$didReplace = 1 ;
				}
				else {
					$configContents .= $_ ;
				}
			}
			if (!$didReplace) {
				$configContents .= "CURRENT_PROJECT_VERSION = $nextRevisionNumberString\n" ;
			}
			close($xcconfigFileIn) ;
			
			# Write the file, with the new contents
			open (my $xcconfigFileOut, '>:encoding(UTF-8)', $xcconfigPath) or die "Could not write $xcconfigPath.  $!\n" ;
			print $xcconfigFileOut $configContents ;
			close ($xcconfigFileOut) ; 
		}
	}
}

printf "\n%s is complete.\n", SSYUtils2::programName() ;

print "Set a to-do to send emails to bug reporters in a couple days, or else direct beta testers to http://sheepsystems.com/files/...(beta tester's page)\n" ;


sub scanBundleForDSyms {
	my $rootPath = shift ;
	my $dSymNamesRef = shift ;
	my $indent = shift ;

	print ($indent . "Searching for dSYM-able executables in:\n$indent   $rootPath\n") ;

	my @rawNames ;

	# First, the bundle itself.
	push @$dSymNamesRef, "$appName.app" ;
	
	my $i ;

	# Next, any executables in Contents/MacOS.
	my $dirPath = "$rootPath/Contents/MacOS" ;
	if ($fileUtil->existent($dirPath)) {
		print ($indent . "   Contents/MacOS/...\n") ;
		@rawNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --files-only/) ;
		for ($i=0; $i<@rawNames; $i++) {
			push @$dSymNamesRef, $rawNames[$i] ;
		}
	}
	
	# Next, any executables, or helper apps in Contents/Helpers.
	$dirPath = "$rootPath/Contents/Helpers" ;
	if ($fileUtil->existent($dirPath)) {
		print ($indent . "   Contents/Helpers/...\n") ;
		# Executables
		@rawNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --files-only/) ;
		for ($i=0; $i<@rawNames; $i++) {
			push @$dSymNamesRef, $rawNames[$i] ;
		}

		# Helper apps
		@rawNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --dirs-only/) ;
		my $dotApp = ".app" ;
		my $dotAppLength = length($dotApp) ;
		for ($i=0; $i<@rawNames; $i++) {
			# This is the recursion
			scanBundleForDSyms ("$dirPath/$rawNames[$i]", $dSymNamesRef, , "$indent   ") ;
		}
	}
	
	# Next, any helper apps or loadable bundles in Contents/Resources (which, according to TN2206, there should not be any of)
	$dirPath = "$rootPath/Contents/Resources" ;
	if ($fileUtil->existent($dirPath)) {
		print ($indent . "   Contents/Resources/...\n") ;
		@rawNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --dirs-only/) ;
		my $dotApp = ".app" ;
		my $dotAppLength = length($dotApp) ;
		my $dotBundle = ".bundle" ;
		my $dotBundleLength = length($dotBundle) ;
		for ($i=0; $i<@rawNames; $i++) {
			if (index($rawNames[$i], $dotApp, length($rawNames[$i]) - $dotAppLength) > 0) {
				push @$dSymNamesRef, $rawNames[$i] ;
			}
			if (index($rawNames[$i], $dotBundle, length($rawNames[$i]) - $dotBundleLength) > 0) {
				push @$dSymNamesRef, $rawNames[$i] ;
			}
		}
	}
	
	# Next, the executables in any frameworks in Contents/Frameworks 
	$dirPath = "$rootPath/Contents/Frameworks" ;	
	if ($fileUtil->existent($dirPath)) {
		print ($indent . "   Contents/Frameworks/...\n") ;
		scanFrameworksForDSyms($dirPath, $dSymNamesRef) ;
	}

	# Next, any plugins in Contents/Plugins 
	$dirPath = "$rootPath/Contents/Plugins" ;
	if ($fileUtil->existent($dirPath)) {
		print ($indent . "   Contents/Plugins/...\n") ;
		my @pluginNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --dirs-only/) ;
		my $dotPlugin = ".plugin" ;
		my $dotPluginLength = length($dotPlugin) ;
		for ($i=0; $i<@pluginNames; $i++) {
			if (index($pluginNames[$i], $dotPlugin, length($pluginNames[$i]) - $dotPluginLength) > 0) {
				push @$dSymNamesRef, $pluginNames[$i] ;
			}
		}
	}
}

sub scanFrameworksForDSyms {
	my $dirPath = shift ;
	my $dSymNamesRef = shift ;
	if ($fileUtil->existent($dirPath)) {
		my @frameworkNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --dirs-only/) ;
		for (my $i=0; $i<@frameworkNames; $i++) {
			my $frameworkDirPath = $dirPath . "/" . $frameworkNames[$i] ;
			# The following line picks out the name of the framework executable(s), by getting all regular files which are immediate children of Whatever.framework.  Usually, there will be only one, a symlink to the framework executable which is buried in /Versions/A
			my @rawNames = $fileUtil->list_dir($frameworkDirPath, qw/--no-fsdots --files-only/) ;
			for (my $j=0; $j<@rawNames; $j++) {
				push @$dSymNamesRef, ($rawNames[$j] . ".framework") ;
			}
			
			# Recurse into subframeworks
			my $subframeworksDir = "$frameworkDirPath/Versions/A/Frameworks" ;
			scanFrameworksForDSyms($subframeworksDir, $dSymNamesRef) ;
		}
	}
}

sub scanBundleForStripping {
	my $rootPath = shift ;
	my $pathsToStripRef = shift ;
	my $stripOptionsRef = shift ;
	my $indent = shift ;

	print ($indent . "Searching for strippable code files in:\n$indent   $rootPath\n") ;

	my @rawNames ;

	my $i ;

	# Next, any executables in Contents/MacOS.  
	my $dirPath = "$rootPath/Contents/MacOS" ;
	if ($fileUtil->existent($dirPath)) {
		print ($indent . "   Contents/MacOS/...\n") ;
		@rawNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --files-only/) ;
		for ($i=0; $i<@rawNames; $i++) {
			# All executables should be stripped.
			push @$pathsToStripRef, $dirPath . "/" . $rawNames[$i] ;
			push @$stripOptionsRef, "" ; # default stripping (all)
		}
	}
	
	# Next, any executables, or helper apps in Contents/Helpers.
	$dirPath = "$rootPath/Contents/Helpers" ;
	if ($fileUtil->existent($dirPath)) {
		print ($indent . "   Contents/Helpers/...\n") ;
		# Executables
		@rawNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --files-only/) ;
		for ($i=0; $i<@rawNames; $i++) {
			push @$pathsToStripRef, $dirPath . "/" . $rawNames[$i] ;
			push @$stripOptionsRef, "" ; # default stripping (all)
		}

		# Helper apps
		@rawNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --dirs-only/) ;
		my $dotApp = ".app" ;
		my $dotAppLength = length($dotApp) ;
		for ($i=0; $i<@rawNames; $i++) {
			# This is the recursion
			scanBundleForStripping ("$dirPath/$rawNames[$i]", $pathsToStripRef, $stripOptionsRef, , "$indent   ") ;
		}
	}
	
	# Next, any helper apps or loadable bundles in Contents/Resources (which, according to TN2206, there should not be any of)
	$dirPath = "$rootPath/Contents/Resources" ;
	if ($fileUtil->existent($dirPath)) {
		print ($indent . "   Contents/Resources/...\n") ;
		@rawNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --dirs-only/) ;
		my $dotApp = ".app" ;
		my $dotAppLength = length($dotApp) ;
		my $dotBundle = ".bundle" ;
		my $dotBundleLength = length($dotBundle) ;
		for ($i=0; $i<@rawNames; $i++) {
			if (index($rawNames[$i], $dotApp, length($rawNames[$i]) - $dotAppLength) > 0) {
				push @$pathsToStripRef, $dirPath . "/" . $rawNames[$i] . "/Contents/MacOS/" . SSYUtils2::removePathExtension($rawNames[$i]) ;
				push @$stripOptionsRef, "" ; # default stripping (all)
			}
			if (index($rawNames[$i], $dotBundle, length($rawNames[$i]) - $dotBundleLength) > 0) {
				push @$pathsToStripRef, $dirPath . "/" . $rawNames[$i] . "/Contents/MacOS/" . SSYUtils2::removePathExtension($rawNames[$i]) ;
				push @$stripOptionsRef, "-x" ; # strip local symbols only
			}
		}
	}
	
	# Next, the executables in any frameworks in Contents/Frameworks 
	$dirPath = "$rootPath/Contents/Frameworks" ;	
	if ($fileUtil->existent($dirPath)) {
		print ($indent . "   Contents/Frameworks/...\n") ;
		scanFrameworksForStripping($dirPath, $pathsToStripRef, $stripOptionsRef) ;
	}

	# Next, any plugins in Contents/Plugins 
	$dirPath = "$rootPath/Contents/Plugins" ;
	if ($fileUtil->existent($dirPath)) {
		print ($indent . "   Contents/Plugins/...\n") ;
		my @pluginNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --dirs-only/) ;
		my $dotPlugin = ".plugin" ;
		my $dotPluginLength = length($dotPlugin) ;
		for ($i=0; $i<@pluginNames; $i++) {
			if (index($pluginNames[$i], $dotPlugin, length($pluginNames[$i]) - $dotPluginLength) > 0) {
				my $pluginPath = $dirPath . "/" . $pluginNames[$i] ;
				push @$pathsToStripRef, $pluginPath . "/Contents/MacOS/" . substr($pluginNames[$i], 0, length($pluginNames[$i]) - $dotPluginLength) ;
				push @$stripOptionsRef, "-x" ; # strip local symbols only
			}
		}
	}
}

sub scanFrameworksForStripping {
	my $dirPath = shift ;
	my $pathsToStripRef = shift ;
	my $stripOptionsRef = shift ;
	if ($fileUtil->existent($dirPath)) {
		my @frameworkNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --dirs-only/) ;
		for (my $i=0; $i<@frameworkNames; $i++) {
			my $frameworkDirPath = $dirPath . "/" . $frameworkNames[$i] ;
			# The following line picks out the name of the framework executable(s), by getting all regular files which are immediate children of Whatever.framework.  Usually, there will be only one, a symlink to the framework executable which is buried in /Versions/A
			my @rawNames = $fileUtil->list_dir($frameworkDirPath, qw/--no-fsdots --files-only/) ;
			for (my $j=0; $j<@rawNames; $j++) {
				push @$pathsToStripRef, $frameworkDirPath . "/Versions/A/" .  SSYUtils2::removePathExtension($rawNames[$j]) ;
				push @$stripOptionsRef, "-x" ; # strip local symbols only
			}
			
			# Recurse into subframeworks
			my $subframeworksDir = "$frameworkDirPath/Versions/A/Frameworks" ;
			scanFrameworksForStripping($subframeworksDir, $pathsToStripRef, $stripOptionsRef) ;
		}
	}
}

sub scanBundleForArchitectures {
	my $rootPath = shift ;
	my $pathsToExecutablesRef = shift ;
	my $indent = shift ;

	print ($indent . "Searching for architectured executables in:\n$indent   $rootPath\n") ;

	my @rawNames ;
	my $i ;

	my $dirPath = "$rootPath/Contents/MacOS" ;
	if ($fileUtil->existent($dirPath)) {
		print ($indent . "   Contents/MacOS/...\n") ;
		# Script will fail here if Contents/MacOS does not exist:
		@rawNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --files-only/) ;
		for ($i=0; $i<@rawNames; $i++) {
			push @$pathsToExecutablesRef, $dirPath . "/" . $rawNames[$i] ;
		}
	}
	
	# Next, any executables, or helper apps in Contents/Helpers.
	$dirPath = "$rootPath/Contents/Helpers" ;
	if ($fileUtil->existent($dirPath)) {
		print ($indent . "   Contents/Helpers/...\n") ;

		# Executables
		@rawNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --files-only/) ;
		for ($i=0; $i<@rawNames; $i++) {
			push @$pathsToExecutablesRef, $dirPath . "/" . $rawNames[$i] ;
		}

		# Helper apps
		@rawNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --dirs-only/) ;
		my $dotApp = ".app" ;
		my $dotAppLength = length($dotApp) ;
		for ($i=0; $i<@rawNames; $i++) {
			# This is the recursion
			scanBundleForArchitectures ("$dirPath/$rawNames[$i]", $pathsToExecutablesRef, "$indent   ") ;
		}
	}
	
	# We skip Contents/Resources since there should not be any code in there.  Only code has architecture.
	
	# Next, the executables in any frameworks in Contents/Frameworks 
	$dirPath = "$rootPath/Contents/Frameworks" ;	
	if ($fileUtil->existent($dirPath)) {
		print ($indent . "   Contents/Frameworks/...\n") ;
		scanFrameworksForArchitectures($dirPath, $pathsToExecutablesRef, "$indent   ") ;
	}

	# Next, any plugins in Contents/Plugins 
	$dirPath = "$rootPath/Contents/Plugins" ;
	if ($fileUtil->existent($dirPath)) {
		print ($indent . "   Contents/Plugins/...\n") ;
		my @pluginNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --dirs-only/) ;
		my $dotPlugin = ".plugin" ;
		my $dotPluginLength = length($dotPlugin) ;
		for ($i=0; $i<@pluginNames; $i++) {
			if (index($pluginNames[$i], $dotPlugin, length($pluginNames[$i]) - $dotPluginLength) > 0) {
				my $pluginPath = $dirPath . "/" . $pluginNames[$i] ;
				push @$pathsToExecutablesRef, $pluginPath ;				
			}
		}
	}
}

sub scanFrameworksForArchitectures {
	my $dirPath = shift ;
	my $pathsToExecutablesRef = shift ;
	if ($fileUtil->existent($dirPath)) {
		my @frameworkNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --dirs-only/) ;
		for (my $i=0; $i<@frameworkNames; $i++) {
			my $frameworkDirPath = $dirPath . "/" . $frameworkNames[$i] ;
			# The following line picks out the name of the framework executable(s), by getting all regular files which are immediate children of Whatever.framework.  Usually, there will be only one, a symlink to the framework executable which is buried in /Versions/A
			my @rawNames = $fileUtil->list_dir($frameworkDirPath, qw/--no-fsdots --files-only/) ;
			for (my $j=0; $j<@rawNames; $j++) {
				push @$pathsToExecutablesRef, $frameworkDirPath . "/Versions/A" ;
			}
			
			# Recurse into subframeworks
			my $subframeworksDir = "$frameworkDirPath/Versions/A/Frameworks" ;
			scanFrameworksForArchitectures($subframeworksDir, $pathsToExecutablesRef) ;
		}
	}
}


sub codesignDeveloperID {
	my $productPath = shift ;
	my $codeSigningIdentity = shift ;

	# We shall use IPC::Run::run() for noisy programs that would otherwise noise up the system's stdout or stderr, or whose stdout or stderr contains data which we need to parse.
	# Things we'll need for IPC::Run::run().
	my $command ;
	my @args ;
	my $stdin ;
	my $stdout ;
	my $stderr ;
	my $exitOk ;

	# The 'codesign' tool will make up its own code signing "identitifer" based on a couple of different inputs, but I don't like the idea of leaving such an important parameter up to a somewhat indeterminate algorithm.  Also, usually you want all executables in the package to be signed with the same identity, and to do that the identity must be passed to codesign explicitly.  Therefore, this script consructs an appropriate identifier for each item.  (Note that I said same identi*ty*, not identi*fier*.  Code signing identifiers should be unique.)
	
	# Apple's codesign utility does not seem to support file globbed paths, so we use File::Util to get arrays of the contents of the known directories that may have executables that need to be signed.
	
	my @pathsToSign ;
	my @codeSignIdentifiers ;
	# The scanBundle subroutines dig in recursively
	# @pathsToSign and @codeSignIdentifiers will have corresponding elements.
	scanBundleForCodesign($productPath, \@pathsToSign, \@codeSignIdentifiers, "   ") ;
	# Starting in Mac OS X 10.9, the codesign tool requires that code components of any bundle to be signed be signed first.  In other words, bundles must be signed in order, from the inside out.  Because our traversal was outside in, we need to reverse these results.  Note that this cannot be done inside scanBundle because that function calls itself recursively.
	@pathsToSign = reverse(@pathsToSign) ;
	@codeSignIdentifiers = reverse(@codeSignIdentifiers) ;
	
	my $nPaths = @pathsToSign ;
	print "Found $nPaths signable files.  Files must and will be be signed starting from the innermost and working up to the root.  Here are the paths to be signed, and the identifiers which will be used, in order of how they will be signed:\n" ;
	for (my $i=0; $i<$nPaths; $i++) {
		print "$pathsToSign[$i]\n" ;
		print "   will be signed with identifier: $codeSignIdentifiers[$i]\n" ;
	}

	# We'll need the bundle identifier to use as code signing identifier
	my $mainBundleIdentifier = extractBundleIdentifier($productPath) ;
	
	# Construct Designated Requirements (DR)
	# Signed by Apple anchor certificate...
	my $reqmt1 = "anchor apple generic" ;
	# Identifier is bundle identifier of this app...
	# $reqmt2 specifies the codesign identifier and changes for each signable code object.  It is therefore computed in the loop below.
	# Is from the Mac App Store...
	my $reqmt3 = "cert leaf[field.1.2.840.113635.100.6.1.9] exists" ;
	# Is from a Developer ID authority
	my $reqmt4 = "certificate 1[field.1.2.840.113635.100.6.2.6] exists" ;
	# Has a Developer ID certificate
	my $reqmt5 = "certificate leaf[field.1.2.840.113635.100.6.1.13] exists" ;
	# Developer ID certificate must have proper Team ID.
	my $reqmt6 = "certificate leaf[subject.OU] = \\\"$developerTeamId\\\" " ;

	my $nPathsToSign = @pathsToSign ;
	my $nTroubles = 0 ;
	for (my $i=0; $i<@pathsToSign; $i++) {
		my $j = $i+1 ;
		my $pathToSign = $pathsToSign[$i] ;
		my $name = SSYUtils2::lastPathComponent(SSYUtils2::removeIfSuffix("/Versions/A", $pathToSign)) ;
		print "\Signing component: $j/$nPathsToSign: $name\n" ;

		# I tried checking for file existence here but got really strange results.  So at this time there is no test.  Script will fail if Code Signing fails for any item.
		if (1) {
			my $codeSignIdentifier = $codeSignIdentifiers[$i] ;
			my $reqmt2 = "identifier \\\"$codeSignIdentifier\\\"" ;
			my $requirements = "\"=designated => $reqmt1 and $reqmt2 and (($reqmt3) or ($reqmt4 and $reqmt5 and $reqmt6))\"" ;
			@sysargs = ("/usr/bin/codesign", "--force", "--verbose", "--sign", "\"$codeSigningIdentity\"", "--requirements", $requirements, "--identifier", "\"$codeSignIdentifier\"", "\"$pathToSign\"") ; 
			SSYUtils2::systemDoOrDie(@sysargs) ;
		}
		else {
			print "   TROUBLE!  No file found for $name.\n" ;
			print "      Complete path is:\n         \"$pathToSign\"\n" ;
			$nTroubles++ ;
		}
	}

	if ($nTroubles > 0) {
		print "\nThere was TROUBLE found with $nTroubles items.\n" ;
		print "   Type 'a' to abort this script and exit.\n" ;
		print "   Type 'return' or any key other key to continue DESPITE TROUBLE.\n" ;
		$userInputChar = SSYUtils2::getUserInputChar() ;
		if ($userInputChar eq 'a') {
			die "User aborted" ;
		}
	}
	
	# Verify code signatures
	@sysargs = ("/usr/bin/codesign", "--verify", "\"$productPath\"") ; 
	my $verifyFailed = SSYUtils2::systemDoOrDie(@sysargs) ;
	if ($verifyFailed) {
		die "Code Signing's Verification failed" ;
	}
	else {
		print "\nCode Signing verified OK -- Yeah!\n" ;
		print "List of code signing identifiers used...\n" ;
		for (my $i=0; $i<@pathsToSign; $i++) {
			print "   $codeSignIdentifiers[$i]\n" ;
		}
	}
	

	# Verify for Gatekeeper
	my $pathToVerify = $pathsToSign[-1] ;  # -1 = last element in list
	print "Will verify for Gatekeeper:\n   $pathToVerify\n" ;
=com	
	I thought this was going to require sudo, but it does not!
	print "\nShould run spctl to verify for Gatekeeper?\n" ;
	print "   Type 's' to skip this step.\n" ;
	print "   Type 'a' to abort this script and exit.\n" ;
	print "   Type 'return' or any key other key to approve.\n" ;
	$userInputChar = SSYUtils2::getUserInputChar() ;
	if ($userInputChar eq 'a') {
		die "User aborted" ;
	}
	elsif ($userInputChar ne 's') {
		`osascript -e \"tell application \\"Terminal.app\\" to do script \\"sudo /usr/sbin/spctl --master-enable ; spctl -a -v $pathToProduct\\"\"` ;
	}
=cut	
	
	$command = "/usr/sbin/spctl" ;
	$stdout = "<NO-STDOUT>" ;
	$stderr = "<NO-STDERR>" ;

	# Note that "spctl exits zero on success, or one if an operation has failed.  Exit code two indicates unrecognized or unsuitable arguments".  But IPC::Run:run() returns "TRUE when all subcommands exit with a 0 result code.  If an assessment operation results in denial but no other problem has occurred, the exit code is three."  But IPC::Run:run() returns "TRUE when all subcommands exit with a 0 result code."  Thus, success is indicated by $exitOk = 1.

	# Before checking the product, first make sure that Gatekeeper is enabled
	@args = ("--status") ;
	$exitOk = IPC::Run::run [ $command, @args ], \$stdin, \$stdout, \$stderr ;
	# Note that stdout and stderr end with line feeds
	print "\nGatekeeper Status Result:  exitOk=$exitOk\n   stdout: $stdout   stderr: $stderr" ;
	
	my $assessmentsEnabled = (($stdout =~/assessments enabled/) && $exitOk) ;
	if (!$assessmentsEnabled) {
		die ("Gatekeeper Assessments are not enabled, according to command:\n   $command @args\nPlease run this command in Terminal:\n   sudo /usr/sbin/spctl --master-enable\nto fix this problem") ;
	}
	
	my @args = ("-a", "-v", $pathToVerify) ;
	$exitOk = IPC::Run::run [ $command, @args ], \$stdin, \$stdout, \$stderr ;
	# Note that ends with line feed but stdout does not
	print "\nGatekeeper Assessment Result:  exitOk=$exitOk\n   stdout: $stdout\n   stderr: $stderr" ;
	# Oddly, spctl prints its result to stderr instead of stdout.
	my $assessmentOk = (($stderr =~ m/source=Developer ID/) && ($stderr =~ m/: accepted/) && $exitOk) ;
	if (!$assessmentOk) {
		die("Failed Gatekeeper test for Developer ID with command:\n$command @args") ;
	}
}

sub scanBundleForCodesign {
	my $rootPath = shift ;
	my $pathsToSignRef = shift ;
	my $codeSignIdentifiersRef = shift ;
	my $indent = shift ;

	print ($indent . "Searching for signable items in:\n$indent   $rootPath\n") ;

	my @rawNames ;

	# First, the bundle itself.  We mimic the default behavior of the codesign tool by assigning its bundle identifier to the codesign identifier.
	push @$pathsToSignRef, $rootPath ;
	my $bundleIdentifier = extractBundleIdentifier($rootPath, $1) ;
	push @$codeSignIdentifiersRef, $bundleIdentifier ;
	
	my $i ;

	# Next, any executables in Contents/MacOS, but do not sign the "main" executable (CFBundleExecutable).  Although signing this seems to be harmless; it just replaces the signature which was applied when the whole bundle was signed; I don't like the idea of signing things twice.
	my $dirPath = "$rootPath/Contents/MacOS" ;
	if ($fileUtil->existent($dirPath)) {
		print ($indent . "   Contents/MacOS/...\n") ;
		my $mainExecutableName = extractInfoPlistKey($rootPath, "CFBundleExecutable", 1) ;
		@rawNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --files-only/) ;
		for ($i=0; $i<@rawNames; $i++) {
			if ($rawNames[$i] eq $mainExecutableName) {
				# Do not add the main executable to @$pathsToSignRef, because the bundle is already in there, and codesign will sign the main executable when signing the bundle.
				printf("Skip signing the main executable $mainExecutableName because these are treated when its bundle is treated.\n") ;
				next ;
			}
			push @$pathsToSignRef, $dirPath . "/" . $rawNames[$i] ;
			push @$codeSignIdentifiersRef, $rawNames[$i] ;
		}
	}
	
	# Next, any executables, or helper apps in Contents/Helpers.
	$dirPath = "$rootPath/Contents/Helpers" ;
	if ($fileUtil->existent($dirPath)) {
		print ($indent . "   Contents/Helpers/...\n") ;

		# Executables
		@rawNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --files-only/) ;
		for ($i=0; $i<@rawNames; $i++) {
			push @$pathsToSignRef, $dirPath . "/" . $rawNames[$i] ;
			push @$codeSignIdentifiersRef, $rawNames[$i] ;
		}

		# Helper apps
		@rawNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --dirs-only/) ;
		my $dotApp = ".app" ;
		my $dotAppLength = length($dotApp) ;
		for ($i=0; $i<@rawNames; $i++) {
			# This is the recursion
			scanBundleForCodesign ("$dirPath/$rawNames[$i]", $pathsToSignRef, $codeSignIdentifiersRef, "$indent   ") ;
		}
	}
	
	# We skip Contents/Resources since there should not be any code in there.  Only code gets signed.
	
	# Next, the executables in any frameworks in Contents/Frameworks 
	$dirPath = "$rootPath/Contents/Frameworks" ;	
	if ($fileUtil->existent($dirPath)) {
		print ($indent . "   Contents/Frameworks/...\n") ;
		scanFrameworksForCodesign($dirPath, $pathsToSignRef, $codeSignIdentifiersRef) ;
	}

	# Next, any plugins in Contents/Plugins 
	$dirPath = "$rootPath/Contents/Plugins" ;
	if ($fileUtil->existent($dirPath)) {
		print ($indent . "   Contents/Plugins/...\n") ;
		my @pluginNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --dirs-only/) ;
		my $dotPlugin = ".plugin" ;
		my $dotPluginLength = length($dotPlugin) ;
		for ($i=0; $i<@pluginNames; $i++) {
			if (index($pluginNames[$i], $dotPlugin, length($pluginNames[$i]) - $dotPluginLength) > 0) {
				my $pluginPath = $dirPath . "/" . $pluginNames[$i] ;
				push @$pathsToSignRef, $pluginPath ;				
				push @$codeSignIdentifiersRef, $pluginNames[$i] ;
			}
		}
	}
}

sub scanFrameworksForCodesign {
	my $dirPath = shift ;
	my $pathsToSignRef = shift ;
	my $codeSignIdentifiersRef = shift ;
	
	if ($fileUtil->existent($dirPath)) {
		my @frameworkNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --dirs-only/) ;
		for (my $i=0; $i<@frameworkNames; $i++) {
			my $frameworkDirPath = $dirPath . "/" . $frameworkNames[$i] ;
			# The following line picks out the name of the framework executable(s), by getting all regular files which are immediate children of Whatever.framework.  Usually, there will be only one, a symlink to the framework executable which is buried in /Versions/A
			my @rawNames = $fileUtil->list_dir($frameworkDirPath, qw/--no-fsdots --files-only/) ;
			for (my $j=0; $j<@rawNames; $j++) {
				# The following is per Apple TN 2206 which says "To avoid problems when signing frameworks make sure that you sign a specific version as opposed to the whole framework ... This is the right way:
				#   codesign -s my-signing-identity ../FooBarBaz.framework/Versions/A
				push @$pathsToSignRef, $frameworkDirPath . "/Versions/A" ;
				push @$codeSignIdentifiersRef, $frameworkNames[$i] ;
			}
			
			# Recurse into subframeworks
			my $subframeworksDir = "$frameworkDirPath/Versions/A/Frameworks" ;
			scanFrameworksForCodesign($subframeworksDir, $pathsToSignRef, $codeSignIdentifiersRef) ;
		}
	}
}

sub extractBundleIdentifier {
	my $path = shift ;
	my $dieIfFail = shift ;
	
	return (extractInfoPlistKey($path, "CFBundleIdentifier", $dieIfFail)) ;
}
	
sub extractBundleVersion {
	my $path = shift ;
	my $dieIfFail = shift ;
	
	return (extractInfoPlistKey($path, "CFBundleVersion", $dieIfFail)) ;
}

sub extractInfoPlistKey {
	my $path = shift ;
	my $key = shift ;
	my $dieIfFail = shift ;
	
	my $infoPlistPath = "$path/Contents/Info.plist" ;

	# We shall use IPC::Run::run() for noisy programs that would otherwise noise up the system's stdout or stderr, or whose stdout or stderr contains data which we need to parse.
	# Things we'll need for IPC::Run::run().
	my $command ;
	my @args ;
	my $stdin ; # Leave as undef
	my $stdout = "<??>" ;
	my $stderr = "<??>" ;
	my $exitOk ;
	my $msg  ; # Leave as undef
	$command = '/usr/libexec/PlistBuddy' ;
	# IPC::Run() quotes arguments, so in the following, we do not add \".
	@args = ("-c", "Print:$key", "$infoPlistPath") ;
	my $value ;
	# Note that PlistBuddy exits zero on success.  But IPC::Run:run() returns "TRUE when all subcommands exit with a 0 result code.
	$exitOk = IPC::Run::run [ $command, @args ], \$stdin, \$stdout, \$stderr ;
	if ($exitOk) {
		if (!defined($stdout)) {
			$msg = "Did not get $key from $infoPlistPath\nGot stdout: $stdout\nGot stderr: $stderr" ;
		}
		else {
			if (length($stdout) < 1) {
				$msg = "Got empty $key \"$stdout\" from $infoPlistPath\nGot stderr: $stderr" ;
			}
			else {
				# Success
				$value = $stdout ;
				chomp($value) ;
			}
		}
	}
	else {
		$msg = "Error while reading $key from $infoPlistPath" ;
	}
	
	if (!$value && $dieIfFail) {
		die($msg) ;
	}
	
	return $value ;
}