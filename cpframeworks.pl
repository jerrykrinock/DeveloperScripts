#!/usr/bin/perl

=com

PURPOSE

This script can be used in Xcode projects for copying private frameworks to the product's Contents/Frameworks.  It replaces the "Copy Files Build Phase" for this purpose, using the same pbxcp tool, but has several advantages, listed below.

1. Copy Files always copys the "Release" configuration regardless of the current configuration being built.  (You don't notice this when running products from within Xcode, because some "clever" trickery in Xcode apparently tells the app to load the proper, e.g. Debug, framework, instead of the one in its package.)

This can bite you in at least two ways:

1.1  Although you get the correct framework when running in Xcode, the wrong (packaged) framework runs when running a non-Release product by doubleclicking in the Finder, or after copying it to another Mac.  Once, I wanted to find a crash by copying a ReleaseUnstripped configuration of my app on an old Powerbook (PowerPC) running Panther.  Instead, without telling me, my test ran with the Release build, which was, at the time, down-rev.  Not a happy day.

1.2  If you clean the Release version of a framework and then do a non-Release build of the app, during the Copy Files (to Frameworks) build phase, pbxcp will fail with a source-directory-not-found error. Another unhappy day troubleshooting why my clean-and-build-all-configurations script failed unpredictably.

2.  The Copy Files build phase will not accept (as drags) frameworks which are not linked in the main .app.  Sometimes I have bundles which use a later minimum deployment OS than the main app, and such a bundle may need frameworks also using the later OS.  They cannot be linked into the main app, but still must be copied into Contents/Frameworks.

3.  Even in "Release" builds, with -strip-debug-symbols enabled, pbxcp does not strip out the Headers, and the top-level symlinks to the Headers, in the frameworks copied to the product. This script detects when a build is "Release" and does so.


USAGE

If you are copying private frameworks from other Xcode projects, you already know that you must have configured in Xcode Preferences > Building (or at least in all relevant projects) a Customized Location for all of your Build Products.  The full path to the this with the current-configuration subdirectory  (e.g. "Debug" or "Release") appended is available in Run Shell Script build phases as $BUILT_PRODUCTS_DIR, $TARGET_BUILD_DIR, $CONFIGURATION_BUILD_DIR.  (In my projects, the three values have always been identical but there are subtle differences that are explained in Apple's "Xcode Build Setting Reference".)  I've created a "Scripts" directory relative to that and have placed this script in it.  So, in my case, I add a line such as the following to my Run Script Build Phase:

"$BUILT_PRODUCTS_DIR/../../Scripts/cpframeworks.pl" "$BUILT_PRODUCTS_DIR" "$PRODUCT_NAME.app" MyPrivateFramework1 MyPrivateFramework2 MyPrivateFramework3 etc.

=cut

use strict ;
use File::Spec ;

my $programName = programName() ;

my $nArgs = $#ARGV + 1 ;

if ($nArgs < 2) {
	print "error: cpframeworks.pl requires at least 2 arguments, got $nArgs.\nNote: Requires at least 3 arguments to do anything useful.\n" ;
	usageErrDie() ;
}

my $buildPath = addTrailingSlashIfNone($ARGV[0]) ;
my $productFullName = $ARGV[1] ;

my @pathComps = split /\//, $buildPath ;
my $nComps = @pathComps ;
my $buildConfig = $pathComps[$nComps-1] ;

print "$programName: Build config is: $buildConfig.\n" ;
my $success ;
my $productFrameworksDir = "$buildPath$productFullName/Contents/Frameworks" ;

# Remove old Frameworks directory in product and replace with an empty one.
# Why not just let pbxcp overwrite any old frameworks that happen to be there? 
# Well, a stupid thing seems to happen with cp.  In case a target framework already
# exists in the destination, cp will fail with two errors of the form:
#    "cannot overwrite directory <...> with non-directory <...>
# when it attempts to overwrite any symbolic link to a directory.  There are two such symlinks
# in any framework:
#    xxx.framework/Resources
#    xxx.framework/Versions/Current
# Therefore, to avoid this error we first remove the existing destination so that
# the subsequent copy can proceed without any stupid "overwrite" conflicts.
# I'm not sure whether or not pbxcp suffers from this same problem as cp, but in case it
# does, or ever does, you can't argue that copying over a clean slate is less error-prone.
unlink $productFrameworksDir ;
$success = mkdir $productFrameworksDir, 0777 ;

my $i = 2 ;
my $frameworkName ;
while ($frameworkName = $ARGV[$i]) {
	# Construct the basic pbxcp command as array @sysargs
	my @sysargs = ("/Developer/Library/PrivateFrameworks/DevToolsCore.framework/Resources/pbxcp",  "-exclude",  ".DS_Store", "-exclude", "CVS", "-exclude", ".svn", "-resolve-src-symlinks") ;

	# If "Release" build, append 'strip-debug-symbols' argument to @sysargs
	if ($buildConfig eq "Release") {
		# Add argument which tells pbxcp to debug symbols from any executable(s) in the copied framework
		push @sysargs, "-strip-debug-symbols" ;
	}

	# Append source path to @sysargs
	push @sysargs, "$buildPath$frameworkName.framework" ;

	# Append destination path to @sysargs
	push @sysargs, "$productFrameworksDir"  ;

	# Copy the current frameworkName by executing @sysargs which will execute pbxcp
	print ("$programName: Copying $frameworkName.framework to $productFullName/Contents/Frameworks") ;
	systemDoOrDie(@sysargs) ;
	
	# If "Release" build, strip all private framework Headers, and symbolic links to them,
	# from the copied framework.
	if ($buildConfig eq "Release") {
		my $headerPath ;

		printf "$programName: Stripped headers, their symlinks, and debug syms in executable(s) from copied $frameworkName.framework\n" ;
		# Remove the two possible top-level symbolic links
		$headerPath = "$productFrameworksDir/$frameworkName.framework/Headers" ;
		unlink $headerPath ;
		$headerPath = "$productFrameworksDir/$frameworkName.framework/PrivateHeaders" ;
		unlink $headerPath ;
		
		# Remove the two possible originals
		$headerPath = "$productFrameworksDir/$frameworkName.framework/Versions/A/Headers/" ;
		unlink $headerPath ;
		$headerPath = "$productFrameworksDir/$frameworkName.framework/Versions/A/PrivateHeaders/" ;
		unlink $headerPath ;
	}
	
	$i++ ;
}

sub usageErrDie {
	print ("usage is:\n$programName fullPathToCurrentBuildDir productFullName [frameworkName1] [frameworkName2,] ...\n") ;
	print ("$programName will invoke /Developer/Library/PrivateFrameworks/DevToolsCore.framework/Resources/pbxcp\n") ;
	print ("in order to copy frameworkName1, frameworkName2, ... to the Contents/Resources of productFullName.\n") ;
	print ("See source code to learn why this is better than using a Copy Files Build Phase in Xcode.\n") ;
	print ("Argument productFullName should include the extension such as .app or .bundle.\n") ;
	print ("As is required by Xcode, the app and all frameworks must be built in the same fullPathToCurrentBuildDir.\n") ;
	print ("The last component of this path is normally a Build Configuration such as \"Release\", \"Debug\", etc.\n") ;
	print ("If this last component is \"Release\", this tool will strip debug symbols (as done by pbxcp) and will\n") ;
	print ("also strip headers and the top-level symlinks to them from the copied frameworks.\n") ;
	print ("Author: Jerry Krinock <jerry\@sheepsystems.com>\n") ;
	die ;
}

sub addTrailingSlashIfNone {
	my $path = shift ;
	if ($path eq "/") {
		$path = "" ;
	}
	else {
		# Add trailing slash if absent
		# Easier to work on beginning of string than end, so...
		$path = reverse($path) ;
		if (!(substr($path, 0, 1) eq "/")) {
			$path = "/" . $path ;
		}
		$path = reverse($path) ;
	}
	return $path ;
}

sub commandStringFromArray {
    # Recover the array argument, which perl has flattened
    my @sysargs ;
	my $s ;
    while (my $someArg = shift) {
		$s .=  $someArg ;
		$s .= " " ;
	}
	
	return $s ;
}

# This function allows glob expansion.  Spaces in arguments must be quoted or escaped.
sub systemDoOrDie {
    # First argument to this function should be the command
    # Subsequent arguments should be the space-separated "arguments" to the command
    # Each space makes a new argument, thus a command option such as
    #   -o /some/path
    # should be passed as two arguments, "-o" and "/some/path"
    # Of course, since perl flattens arrays passed to functions, all
    # or part of the arguments may be concatenated into array(s)
    
    # Recover the array argument, which perl has flattened
    my @sysargs ;
    while (my $arg = shift) {
    	push @sysargs, $arg ;
    }
    my $commandName = @sysargs[0] ;
    my $commandString = commandStringFromArray(@sysargs) ;
	# There are two ways to do this, and both work if there are no metacharacters such as the asterisk (*) in the command.  The first way is:
	# system(@sysargs) ; # Literally interprets and thus spoils operation of metacharacters
	# So, instead we use the second way:
	system($commandString) ; # Always works even if metacharacters.
	# $? seems to have the same value as the return value of system()
	# I use the former since it is more convenient.
	if ($? != 0) {
		stop ("Failed with status=$? executing:\n   $commandString\nDied") ;
	}
	if ($? == -1) {
		print "$programName: Failed to execute:\n   $commandString\nError message:\n   $!\n";
	}
	elsif ($? & 127) {
		printf "$programName: Failed while executing command:\n   $commandString\nFailed with signal %d, %s coredump.\n",
			($? & 127),  ($? & 128) ? 'with' : 'without';
	}
	else {
		printf "$programName: Got return %d while executing:\n   $commandString\n", $? >> 8;
	}
	
	return $? ;
}

sub programName() {
	my @pathPieces = File::Spec->splitpath($0) ;
	return @pathPieces[2] ;
}
