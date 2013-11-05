#!/usr/bin/perl

use strict ;
require File::Util ;

if (@ARGV != 1) {
	die "Usage:\n   checkdSYMS.pl /path/to/MyApp.app\nThis .app's parent directory should also contain the .dSYM files for the app's main executable and any constituent auxiliary executables, frameworks, loadable bundles, etc.  This is of course where they are normally deposited, if the parent directory is your Xcode \"Builds\" directory.  Specifically, this script will find executables in all the \"normal\" places -- the main executable, auxiliary executables in Contents/MacOS, auxiliary executables in Contents/Helpers, frameworks in Contents/Frameworks, and helpers or loadable bundles in Contents/Resources.  If you've got something weird like nested frameworks, it won't find those.\n" ;

}


my @components = split ("/", $ARGV[0]) ;
my $appName = @components[@components - 1] ;
$appName = substr($appName, 0, length($appName) - 4) ;
my $buildsReleasePath  = substr($ARGV[0], 0, length($ARGV[0]) - 4 - length($appName)) ;
printf ("Will check dSYM files for executables in $appName.app\n") ;
printf ("  in directory: $buildsReleasePath\n") ;

# Extract architectures from main executable
my $mainAppExecutable = "$buildsReleasePath$appName.app/Contents/MacOS/$appName" ;
my $otoolOutput = `/Developer/usr/bin/otool -fv "$mainAppExecutable"` ;
my @otoolLines = split("\n", $otoolOutput) ;
my @archLines = grep(/architecture /, @otoolLines) ;
my @architectures ;
foreach my $archLine (@archLines) {
	$archLine =~ s/architecture // ;
	push (@architectures, $archLine) ;
}
print "Main Executable \"$appName\" supports architectures:\n" ;
foreach my $arch (@architectures) {
	printf "   $arch\n" ;
}

my $fileUtil = File::Util->new() ;

my @rawNames ;
my $i ;
my @dSymNames ;

# Next, the executables in Contents/MacOS.  This directory had better exist, so we don't check for it.
my @executableNames ;
push @dSymNames, "$appName.app" ;
my $dirPath = "$buildsReleasePath$appName.app/Contents/MacOS" ;
# Script will fail here if Contents/MacOS does not exist:
my @rawNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --files-only/) ;
for ($i=0; $i<@rawNames; $i++) {
	# Exclude the application itself, because we've already got it -- with a .app extension
	if ($rawNames[$i] ne $appName) {
		push @dSymNames, $rawNames[$i] ;
	}
}


# Next, any executables in Contents/Helpers
$dirPath = "$buildsReleasePath$appName.app/Contents/Helpers" ;
if ($fileUtil->existent($dirPath)) {
	@rawNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --files-only/) ;
	for ($i=0; $i<@rawNames; $i++) {
		push @dSymNames, $rawNames[$i] ;
	}
}

# Next, any helper apps or loadable bundles in Contents/Resources
$dirPath = "$buildsReleasePath$appName.app/Contents/Resources" ;
if ($fileUtil->existent($dirPath)) {
	@rawNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --dirs-only/) ;
	my $dotApp = ".app" ;
	my $dotAppLength = length($dotApp) ;
	my $dotBundle = ".bundle" ;
	my $dotBundleLength = length($dotBundle) ;
	for ($i=0; $i<@rawNames; $i++) {
		# Only process names that have suffix $dotApp or $dotBundle
		if (index($rawNames[$i], $dotApp, length($rawNames[$i]) - $dotAppLength) > 0) {
			push @dSymNames, $rawNames[$i] ;
		}
		elsif (index($rawNames[$i], $dotBundle, length($rawNames[$i]) - $dotBundleLength) > 0) {
			push @dSymNames, $rawNames[$i] ;
		}
	}
}

# Next, any executables in the Contents/Frameworks
$dirPath = "$buildsReleasePath$appName.app/Contents/Frameworks" ;
if ($fileUtil->existent($dirPath)) {
	my @frameworkNames = $fileUtil->list_dir($dirPath, qw/--no-fsdots --dirs-only/) ;
	for ($i=0; $i<@frameworkNames; $i++) {
		my $frameworkDirPath = $dirPath . "/" . $frameworkNames[$i] ;
		@rawNames = $fileUtil->list_dir($frameworkDirPath, qw/--no-fsdots --files-only/) ;
		for (my $j=0; $j<@rawNames; $j++) {
			push @dSymNames, ($rawNames[$j] . ".framework") ;
		}
	}
}
		
my $n = @dSymNames ;

print "Checking dSYM files...\n" ;
my $trouble = 0 ;
foreach my $dSymName (@dSymNames) {
	printf "   $dSymName\n" ;
	my $dSymPath = $buildsReleasePath . $dSymName . ".dSYM" ;
	if ($fileUtil->existent($dSymPath)) {
		my $firstArch = 1 ;
		my $nSourceFiles ;
		foreach my $arch (@architectures) {
			my $nSourceFilesThis = 0 ;
			my $dwarfDump ;
			$_ = `/Developer/usr/bin/dwarfdump --arch=$arch -r0 "$dSymPath"` ;
			# Count the number of occurrences of the string "Compile Unit: "
			$nSourceFilesThis = s/Compile Unit: //g ;
			if (length($nSourceFilesThis) == 0) {
				$nSourceFilesThis = 0 ;
				$trouble = 1 ;
				printf "      Whoops! 0 source files dSYMed for arch=$arch.\n" ;
			}
			else {
				printf "      $nSourceFilesThis source files dSYMed for arch=$arch.\n" ;
			}
			
			if ($firstArch) {
				$nSourceFiles = $nSourceFilesThis ;
				$firstArch = 0 ;
			}
			elsif ($nSourceFiles != $nSourceFilesThis) {
				printf "      Whoops!  Different arch has dSYMed different count of source files.\n" ;
				$trouble = 1 ;
			}
		}
	}
	else {
		printf "      Whoops! No dSYM file for $dSymName\n" ;
		$trouble = 1 ;
	}
}

print("\n") ;

if ($trouble) {
	printf "You've got trouble with one or more dSYM files!  (See above.)\n" ;
	exit(1) ;
}

printf "All dSYM files appear to be OK.\n" ;

