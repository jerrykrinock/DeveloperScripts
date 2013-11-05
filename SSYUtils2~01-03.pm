use strict ;
use IPC::Run ;

package SSYUtils2 ;


=item retrieveFromStorage()
Gets a hash from disk storage, using module 'Storable'.
param1: filesystem path of data previously stored by storeToStorage or 'Storable'
returns: A reference to the hash, or an empty hash if no file exists at the given path.
=cut
sub retrieveFromStorage {
	my $path = shift ;
	my $fileUtil = File::Util->new() ;
	my $hashRef ;
	if ($fileUtil->existent($path)) {
		print "Retrieving data at $path.\n" ;
		$hashRef = Storable::retrieve($path) ;
	}
	else {
		print "Creating empty hash because no stored data at $path.\n" ;
		$hashRef = {} ;
	}
	
	return $hashRef ;
}

=item storeToStorage()
Stores a hash to disk, using module 'Storable'.
If there are no key/values in given hash, deletes file at given path, if any.  (This is so that Storable::retrieve will not find an empty file and cause script to die.)
param1: Reference to hash to be stored
param2: filesystem path at which to store the hash
=cut
sub storeToStorage {
	my $hashRef = shift ;
	my $path = shift ;
	if (keys %$hashRef > 0) {
		my $ok = Storable::store($hashRef, $path) ;
		if (!$ok) {
			print "Could not store data at $path.\n" ;
		}
	}
	else {
		print "No data to store.  Removing $path.\n" ;
		unlink($path) ;
	}
}

sub scriptName {
	(my $volume, my $parentPath, my $filename) = File::Spec->splitpath(__FILE__) ;
	return $filename ;
}

sub scriptParentPath {
	(my $volume, my $parentPath, my $filename) = File::Spec->splitpath(__FILE__) ;
	return $parentPath ;
}

sub colocatedToolPath {
	my $otherToolName = shift ;
	return File::Spec->catdir(scriptParentPath(), $otherToolName) ;
}


=com
Given an inputValue and a number base, increases the number by incrementing the most significant digit in the given base and ignoring all lesser significant digits.  Examples, with base=100:
32804 --> 40000
30000 --> 40000
3584 --> 3600
4 --> 5
22 --> 23
987654321 --> 1000000000
87654321 --> 88000000
=cut
sub increaseToNextMostSignificantDigit {
	my $inputValue = shift ;
	my $base = shift ;
	my $currentPlaceValue = 1 ;
	my $answer ;
	my $done = 0 ;
	do {
		my $value = $inputValue/$currentPlaceValue ;
		if ($value >= $base) {
			$currentPlaceValue *= $base ;
		}
		else {
			$answer = (int($value) + 1) * $currentPlaceValue ;
			$done = 1 ;
		}
	} until ($done) ;
	
	return $answer ;
}

sub moveTrailingPunctuationInsideMarkdownItalics {
	my $string = shift ;
	# If an italicized phrase is followed by a punctuation character except a closing square bracket, move the punctuation character inside the italics.

	## First Pass ##
	$string =~ s/(\*{3}|\*)(\S)([^*]{2,}?)(\1)([^[\]\*\n[:alpha:][:digit:][:blank:]])/$1$2$3$5$4/g ;	
	# In the above, note that there are five subpatterns ():

	# $1  (\*{3}|\*) matches 3 or 1 leading asterisks.  3 is for bold+italic, which we want to match.  2 is for bold, which we don't want to match, 1 is for italic, which we want to match.  Note that we put the 3 before the 1 since otherwise, if there is 3, it will only match the 1.
	# $2  (\S) matches the first italicized character, which is required to be non-whitespace.  This is to insure that the end of an italicized phrase not be interpreted as the beginning of the next one.
	# $3  ([^*]{2,}?) matches the remainder of the italicized characters, not greedily, requiring that there be at least 2, and that none of them are an asterisk.  If it was greedy, multiple italicized phrases on same line would merge into one big one, with the result that only the last punctuation character would be moved inside the italics. 
	# $4  (\1) is a backreference to the first match.  If the first match was 1 asterisk, then this one must be 1 asterisk.  Same if the first match was 3 asterisks.
	# $5  ([^[]\*\n[:alpha:][:digit:][:blank:]]) matches the subject punctuation character that we want to move inside the italics.  Yes, all that for one stinkin' character!!  The idea is to match any punctuation characer except [, ], *, or newline.  Note that the ^ operator in a character class means "not what follows".  The pattern thus excludes these three characters, alpha characters (which *I hope* include non-ASCII characters), digit characters, and blank characters (space and tab) from the match, leaving only the other punctuation characters as possible matches.  The reason to exclude [ and ] is because it may appear at the beginning or end of italicized anchored text in Markdown syntax, for example: [*Apple*](http://apple.com).  In this case, moving the * after the ] would screw up Markdown and is definitely not what we want.  Note: I tried the simpler pattern, [[:punct:]^[\]\*\n], with and without backslash escapes.  The idea is that the characters before the ^ will be positive-matched and the characters after the ^ will be negative-matched.  But instead it matches all punctuation characters, including the [, ], * and newline.

	# Then, in the replacement pattern $1$2$3$5$4, we simply reverse the order of the closing asterisk(s) and the subject punctuation character.

	## Second Pass ##
	# For reasons which are too complicated to understand, the First Pass misses Case3, Case9, CaseA and CaseB
	# in the test suite given in testPreMarkdown below.  The following ad-hoc grep fixes those cases.
	$string =~ s/(\*\*|)\[(\*{3}|\*)(\S)([^*]{2,}?)(\2)\]\((.*)\)(\1)([^[\]\*\n[:alpha:][:digit:][:blank:]])/$1\[$2$3$4$8$5\]($6)$7/g ;
	# $1  (\*\*|) is either 2 asterisks or an empty string.  The 2 asterisks is for bold.
	# Then there is a literal [
	# $2  (\*{3}|\*) matches 3 or 1 leading asterisks.  3 is for bold+italic, which we want to match.  2 is for bold, which we don't want to match, 1 is for italic, which we want to match.  Note that we put the 3 before the 1 since otherwise, if there is 3, it will only match the 1.
	# $3  (\S) matches the first italicized character, which is required to be non-whitespace.  This is to insure that the end of an italicized phrase not be interpreted as the beginning of the next one.
	# $4  ([^*]{2,}?) matches the remainder of the italicized characters, not greedily, requiring that there be at least 2, and that none of them are an asterisk.  If it was greedy, multiple italicized phrases on same line would merge into one big one, with the result that only the last punctuation character would be moved inside the italics. 
	# $5  (\2) is a backreference to the second match.  If the second match was 1 asterisk, then this one must be 1 asterisk.  Same if the first match was 3 asterisks.
	# Then there are two literal characters, ](
	# $6  (.*) matches the URL inside the parentheses
	# $7  (\1) is a backreference to the first match, either 2 asterisks or an empty string.
	# $8  ([^[]\*\n[:alpha:][:digit:][:blank:]]) matches the subject punctuation character that we want to move inside the italics.  Yes, all that for one stinkin' character!!  The idea is to match any punctuation characer except [, ], *, or newline.  Note that the ^ operator in a character class means "not what follows".  The pattern thus excludes these three characters, alpha characters (which *I hope* include non-ASCII characters), digit characters, and blank characters (space and tab) from the match, leaving only the other punctuation characters as possible matches.  The reason to exclude [ and ] is because it may appear at the beginning or end of italicized anchored text in Markdown syntax, for example: [*Apple*](http://apple.com).  In this case, moving the * after the ] would screw up Markdown and is definitely not what we want.  Note: I tried the simpler pattern, [[:punct:]^[\]\*\n], with and without backslash escapes.  The idea is that the characters before the ^ will be positive-matched and the characters after the ^ will be negative-matched.  But instead it matches all punctuation characters, including the [, ], * and newline.

	return $string ;
}

sub preMarkdown {
	my $string = shift ;
	my $lineNumber = shift ;
	my $filename = shift ;

	if ($lineNumber == 0) {
		# This is the first line.
		# Check for UTF8 byte order mark and if found, remove it.
		if (
			(ord(substr($string, 0, 1)) == 0xEF)
			&&
			(ord(substr($string, 1, 1)) == 0xBB)
			&&
			(ord(substr($string, 2, 1)) == 0xBF)
			) {
				print(" Removing UTF8 mark (3 bytes) from beginning of $filename.\n") ;
				print("   (Recommended: Save markdown files without Byte Order Mark!)\n") ;
				$string = substr($string, 3) ;
		}
	}
	
	utf8::decode($string) ;
	# Convert non-ASCII characters into HTML Entities.  There is a Perl Module method for doing this,
	#  HTML::Entities::encode_entities($string) ;
	# Unfortunately the above method also converts control characters and the <, &, >, ' and " characters which would destroy any in-line HTML in the .markdown file.  These character classes will be handled by SmartyPants anyhow.  All we want to encode at this point is the high-bit characters.  We do this conversion using the following "Perl one liner" ripped from http://www.cl.cam.ac.uk/~mgk25/unicode.html#perl (which also has a few other useful Perl one-liners related to Unicode.) 
	$string =~ s/([^\x00-\x7f])/sprintf("&#%d;", ord($1))/ge ;
	
	$string = moveTrailingPunctuationInsideMarkdownItalics($string) ;

	# Replace two spaces between sentences with &nbsp; and then one space
	$string =~ s/(\S)(.+?)  (\S)/$1$2&nbsp; $3/g ;
	
	
	# The following line is actually not necessary in Perl,
	# but it makes things easier for C programmers to read!
	return $string ;
}

# Subroutine used in testing preMarkdown
sub test1PreMarkdown {
	my $string = shift ;
	$string .= "\n" ;
	print("BEFORE: $string") ;
	$string = preMarkdown($string, 2, undef) ;
	my $ok ;
	my $bad ;
	$ok = ($string =~ m/&nbsp; / ) ;
	if (!$ok) {
		chomp($string) ;
		$string .= "  FAILED - entity is broken\n" ;
	}
	# string1 = string with all instances of ** removed
	my $string1 = $string ;
	# Eliminate double asterisks since these are bold and don't need to be moved inside
	$string1 =~ s/\*\*//g ;
	# Eliminate the first half of the string; we're only interested in the second half
	$string1 =~ s/(.*)Evil(.*)/$2/ ;
	my $bad = ($string1 =~ m/\*.*\./ ) ;
	chomp($string1) ;
	if ($bad) {
		chomp($string) ;
		$string .= "  FAILED - single asterisk followed later by dot\n" ;
	}
	
	print(" AFTER: $string") ;
	return $string ;
}

# Top-level subroutine for testing preMarkdown
sub testPreMarkdown {
	my $string ;

	my $pmd = "" ; #preMarkedDown string
	$pmd .= test1PreMarkdown("<br>Cats are not *[Evil]().*  Case1:  Italicized whole thing") ;
	$pmd .= test1PreMarkdown("<br>Cats are not *[Evil]()*.  Case2:  Italicized anchor") ;
	$pmd .= test1PreMarkdown("<br>Cats are not [*Evil*]().  Case3:  Italicized text only") ;
	$pmd .= test1PreMarkdown("<br>Cats are not **[Evil]().**  Case4:  Bolded whole thing") ;
	$pmd .= test1PreMarkdown("<br>Cats are not **[Evil]()**.  Case5:  Bolded anchor") ;
	$pmd .= test1PreMarkdown("<br>Cats are not [**Evil**]().  Case6:  Bolded text only") ;
	$pmd .= test1PreMarkdown("<br>Cats are not ***[Evil]().***  Case7:  Botalicized whole thing") ;
	$pmd .= test1PreMarkdown("<br>Cats are not ***[Evil]()***.  Case8:  Botalicized anchor") ;
	$pmd .= test1PreMarkdown("<br>Cats are not [***Evil***]().  Case9:  Botalicized text only") ;
	$pmd .= test1PreMarkdown("<br>Cats are not **[*Evil*]()**.  CaseA:  Italicized text, bolded anchor") ;
	$pmd .= test1PreMarkdown("<br>Cats are not **[*Evil*]().**  CaseB:  Italicized text, bolded whole thing") ;
	$pmd .= test1PreMarkdown("<br>Cats are not *[**Evil**]()*.  CaseC:  Bolded text, italicized anchor") ;
	$pmd .= test1PreMarkdown("<br>Cats are not *[**Evil**]().*  CaseD:  Bolded text, italicized whole thing") ;
	
	my $html = smartMarkdown($pmd, scriptParentPath()) ;
	print "\n\n<html>$html</html>\n\n" ;
}


=com
Applies the SmartyPants and Markdown or MultiMarkdown tools to a given string of Markdown syntax and returns the HTML output.
First argument is string to be processed.
Second argument is the *parent* directory of the 'MultiMarkdown' directory (which contains subdirectory 'bin' which contains MultiMarkdown.pl and SmartyPants.pl.)

Generates error if SmartyPants.pl is not available.  Also generates error if one of Markdown.pl or MultiMarkdown.pl are not available.
If both are available, uses MultiMarkdown.pl.
=cut
sub smartMarkdown {
	my $string = shift ;
	my $smartyMarkdownToolDir = shift ;
	$smartyMarkdownToolDir = File::Spec->catdir($smartyMarkdownToolDir, "MultiMarkdown") ;
	$smartyMarkdownToolDir = File::Spec->catdir($smartyMarkdownToolDir, "bin") ;
	my $markdownPath = File::Spec->catdir($smartyMarkdownToolDir, "Multimarkdown.pl") ;
	my $fileUtil = File::Util->new() ;

	if (!$fileUtil->existent($markdownPath)) {
		$markdownPath = File::Spec->catdir($smartyMarkdownToolDir, "Markdown.pl") ;
	}
	
	my $smartyPantsPath = File::Spec->catdir($smartyMarkdownToolDir, "SmartyPants.pl") ;
		
	$string = trimWhitespace($string) ;


	# I could not find anywhere in John Gruber's documentation the recommended order of Markdown vs. SmartyPants processing.  I guessed SmartyPants first, and that worked until I tried to encode a link with a title like this:
	#   An [example](http://url.com/ "Title")
	# SmartyPants encoded the quotes, which created a mess.
	# Conclusion: Process text through Markdown first, then SmartyPants.

	# (Multi)Markdown Processing
	# If the first line has a colon in it, MultiMarkdown will interpret it to be a metadata definition.  To keep this from happening, always prepend a newline.
	$string = "\n" . $string ;
# This is where it gets stuck:
	$string = getStdoutWithStdinFromCmd($markdownPath, $string) ;

	# Markdown adds a leading <p>\n, and a trailing </p> to its output.  We don't wan't these.  So we test for and remove them.  Note that we only remove them if both are present, since an html string ending in </p> could be the end of the last paragraph, which is innocent.
	if (
		(substr($string, 0, 3) eq "<p>")
		&&
		(substr($string, length($string) - 5, 4) eq "</p>")
	) {
		$string = substr($string, 3) ;
		$string = substr($string, 0, length($string) - 5) ;
	}

	# SmartyPants Processing
	$string = getStdoutWithStdinFromCmd($smartyPantsPath, $string) ;
	# SmartyPants sometimes adds a newline to the end.  Trim it off.
	$string = trimWhitespace($string) ;

	return $string ;
}

=com
Execute a given external program (command).  The program must take input from stdin.  The program's stdout is returned.

Provide the command, with any command-line options, as the first parameter, and the input data as the second parameter.

Use this in lieu of open2() and the methods of Expect.pm, both of which will hang indefinitely unless the program supports unbuffered I/O, typically a -u option.

However, it has bee noted that this will fail if the input contains a $.  For a better answer, see:
http://groups.google.com/group/comp.lang.perl.misc/browse_thread/thread/1d03a9080746098d/9df476304e65f735?lnk=raot#9df476304e65f735
=cut
sub getStdoutWithStdinFromCmd {
	my $cmd = shift ;
	my $stdin = shift ; 
	my $timeout = shift ;

	# This one-liner does not work if there are " or $ in the command
	# return `echo \"$stdin\" | \"$cmd\"` ;
	
=com
	# This method works if the target command/program can  read from a file as its last argument.:, except one needs to add the utf8 incantations.
	# Write stdin to temp file
	my $tempFilePath = File::Temp->tmpnam() ;
	my $didWriteOK = open (TEMP,">$tempFilePath") ; 
	print TEMP $stdin ;
	close (TEMP) ;
	
	# Execute command
	my $stdout = `\"$cmd\" \"$tempFilePath\"` ;
	
	# Clean up temporary file
	unlink($tempFilePath) ;
=cut

	if (!defined($timeout)) {
		$timeout = 9999999 ;
	}

# This is where it gets stuck:
	my $daLen = length($stdin) ; my $shortCmd = (length($cmd) > 16) ? substr($cmd, -16, length($cmd)) : $cmd ; print "Stuck? SSYUtils2.pm:getStdoutWithStdinFromCmd, cmd=$shortCmd  stdinlen=$daLen\n",  ;
	IPC::Run::run [$cmd], \$stdin, \my $stdout, \my $err, IPC::Run::timeout($timeout) 
	or die "$cmd failed: $?"; 
	print "Passed stuck\n" ;
	
	return $stdout ; 
}

=com
Trims whitespace from both ends of string
=cut
sub trimWhitespace($) {
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub trimWhitespaceLeading($) {
	my $string = shift;
	$string =~ s/^\s+//;
	return $string;
}

sub trimWhitespaceTrailing($) {
	my $string = shift;
	$string =~ s/\s+$//;
	return $string;
}

sub getUserInputChar {
	return substr <STDIN>, 0, 1 ;
}

sub makeDirectoryOrDie {
	my $source = shift ;
	# Remove in case it already exists
	removeDirectoryOrDie($source) ;
	my $ok = mkdir($source, 0777) ;
	if (!$ok) {
		print "Could not make directory:\n   $source\n" ;
		stop ("Aborting due to error $!") ;
	}
	else {
		print "Made directory:\n   $source\n" ;
	}
}

sub removeDirectoryOrDie {
	my $source = shift ;
	my $ok = File::Copy::Recursive::pathrmdir($source) ;
	if ($ok == 1) {
		print "Removed:\n   $source\n" ;
	}
	else {
		print "Did not remove nonexistent or non-directory: $source\n" ;
	}
}

sub removeFileOrDie {
	my $source = shift ;
	my $ok = unlink($source) ;
	if ($ok == 1) {
		printf "Removed:\n   %s/$source\n", currentWorkingDirectory() ;
	}
	else {
		print "Did not remove nonexistent or non-regular file: $source\n" ;
	}
}

# This function allows glob expansion.  Spaces in arguments must be quoted or escaped.
sub copyFileOrDie {
	my $source = shift ;
	my $destin = shift ;
	my @sysargs = ("cp",  "-f", $source, $destin) ;
	systemDoOrDie(@sysargs) ;
=com
The following "perl way" does not copy resource forks :(
The "Alias to your Mac's Applications" is a resource-fork-only file.
	my $source = shift ;
	my $destin = shift ;
	my $ok = copy($source, $destin) ;
	if (!$ok) {
		print "Could not copy file:\n   $source\nto $destin\n" ;
		die "Aborting due to error" ;
	}
	else {
		print "Copied: $source\n    to: $destin\n" ;
	}
=cut
}

# This function allows glob expansion.  Spaces in arguments must be quoted or escaped.
sub copyDirectoryOrDie {
	my $source = shift ;
	my $destin = shift ;
	my @sysargs = ("cp", "-Rfp", $source, $destin) ;
	systemDoOrDie(@sysargs) ;
=com
The following "perl way" does not copy resource forks :(
The "Alias to your Mac's Applications" is a resource-fork-only file.
	my $ok = File::Copy::Recursive::dircopy($source, $destin) ;
	if (!$ok) {
		print "Could not copy directory:\n   $source\nto $destin\n" ;
		die "Aborting due to error" ;
	}
	else {
		print "Copied: $source\n    to: $destin\n" ;
	}
=cut
}

# This function allows glob expansion.  Spaces in arguments must be quoted or escaped.
sub copyContentsOfDirectoryToOtherExistingDirectoryOrDie {
	my $source = shift ;
	my $destin = shift ;
	my $sourceGlob = addTrailingSlashIfNone($source) . "*" ;
	my @sysargs = ("cp", "-Rfp", $sourceGlob, $destin) ;
	systemDoOrDie(@sysargs) ;
	
=com
The following "perl way" does not copy resource forks :(
The "Alias to your Mac's Applications" is a resource-fork-only file.
To apply a function to different files, check out the glob function or
the File::Find module. You probably want to wrap your copy command in a
loop of some sort, because perl doesn't know whether you want to copy
the each file to a file of the same name in a different directory, or
to a different name in the same directory, or copy all of the files to
a single, concatenated file. You will have to tell it.
	my @files = glob($source) ;
    my $ok ;
    foreach my $currSource (@files) {
    	my @pathPieces = File::Spec->splitpath($currSource) ;
    	my $filename = @pathPieces[2] ;
    	my $currDestin = "$destin" ;
    	$ok = copy($currSource, $currDestin) ;
    	if (!$ok) {
    		# Maybe it failed because it was a directory
    		copyDirectoryOrDie("\"$currSource\"", "\"$currDestin\"") ;
    	}
    }
=cut
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
    
	my $programName = programName() ;

    # Recover the array argument, which perl has flattened
    my @sysargs ;
    while (my $arg = shift) {
    	push @sysargs, $arg ;
    }
    #push @sysargs, ">" ;
    #push @sysargs, "/dev/null" ;
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
	
	return $? ;
}

sub prependHome {
	my $p2 = shift ;
	my $p1 = $ENV{HOME} ;
	return "$p1/$p2" ;
}

sub undefToStringRef {
	my $var_ref = shift ;
	if (!defined($$var_ref)) {
		$$var_ref = "<undefined>" ;
	}
}

sub undefToString {
	my $var = shift ;
	if (!defined($var)) {
		$var = "<undefined>" ;
	}
	return $var ;
}

sub formatVariable {
	my $varName = shift ;
	my $varValue = shift ;
	my $safeValue = undefToString($varValue) ;
	return sprintf ("%24s: %s\n", $varName, $safeValue) ;
}

=com
Returns a string of array elements joined by $joiner,
and prefixed with the number of elements.
Undefined elements are replaced by "<undefined>".
The actual array referenced is not modified.
If one argument, array is @_ (not a reference!) ;
If no arguments, $joiner defaults to "\n".
=cut
sub describeArrayRefJoinWith {
	my $joiner = shift ;
	my $actualArrayRef = shift ;
	if (!$joiner) {
		$joiner = "\n" ;
	}
	my @arrayCopy ;
	if ($actualArrayRef) {
		@arrayCopy = @$actualArrayRef ;
	}
	else {
		@arrayCopy = @_ ;
	}
	
	my $answer = "" ;
	for my $element (@arrayCopy) {
		undefToStringRef(\$element) ;
	}
	my $n = @arrayCopy ;
	my $elementList = join($joiner, @arrayCopy) ;
	return "$n elements:\n$elementList" ;
}

sub describeArrayRef {
	return describeArrayRefJoinWith("\n", shift) ;
}

sub printArrayRef {
	my $descrip = describeArrayRef(shift) ;
	print "$descrip\n" ;
}

sub describeHashRef {
    my $hashRef = shift ;
    my @keys = sort (keys(%$hashRef)) ;
    my $descrip = '' ;
    for my $key (@keys) {
		$descrip .= formatVariable($key, $hashRef->{$key}) ;
	}
	
	return $descrip ;
}

sub printMarkerAndHashRef {
    my $marker = shift ;
    my $hashName = shift ;
    my $hashRef = shift ;
	my $hashDesc = describeHashRef($hashRef) ;
	print "$marker: $hashName is:\n$hashDesc" ;
}

sub printvar {
	my $varName = shift ;
	my $varValue = shift ;
	if (!defined($varValue)) {
		$varValue = "<undef>" ;
	}
	printf ("%32s = %s\n", $varName, $varValue) ;
}

sub filenameOfPath {
	my $arg = shift ;
	my @pathPieces = File::Spec->splitpath($arg) ;	
	my $filename = @pathPieces[2] ;
	return $filename ;
}

sub programName {
	return filenameOfPath($0) ;
}

sub currentWorkingDirectory {
	return $ENV{'PWD'} ;
	# I also tried to do this "the right way, using high-level API".
	# However, the answer that I get from the following is ".".  Duh.
	# return File::Spec->curdir() ;
}

sub printArrayWithNewlines {
    while (my $element = shift) {
    	print "   $element\n" ;
    }
}

sub printMarkerAndArrayRef {
    my $marker = shift ;
    my $arrayName = shift ;
    my $arrayRef = shift ;
	my $arrayDesc = describeArrayRef($arrayRef) ;
	print "$marker: $arrayName is: $arrayDesc\n" ;
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

sub removePathExtension {
	my $path = shift ;
	my $wholeLen = length($path) ;
	my $rev = reverse($path) ;
	my $i = 0 ;
	my $done = 0 ;
	while (!$done) {
		my $len = $wholeLen - $i - 1 ;
		if (
				($i >= $wholeLen)
				||
				(substr($rev, $i, 1) eq "/")
			) {
			# Last path component has no extension
			# Reset $i to original value minus the one that will be added at the end of this loop.
			$i = -1 ;
			$done = 1 ;
		}
		elsif (substr($rev, $i, 1) eq ".") {
			$done = 1 ;
		}
		$i++ ;
	}
	my $newLen = $wholeLen - $i ;
	return substr($path, 0, $newLen) ;
}

# Returns the last path component of a path separated by "/" characters, including the trailing slash if the last component ends in a trailing slash.
sub lastPathComponent {
	my $path = shift ;
	my @splits = split (/\//, $path) ;
	my @rev = reverse(@splits) ;
	my $lpc = $rev[0] ;
	if (substr(reverse($path), 0, 1) eq "/") {
		$lpc .= "/" ;
	}
	return $lpc ;
}

sub filenameExtension {
	my $path = shift ;
	my $filename = lastPathComponent($path) ;
	my @splits = split(/\./, $filename) ;
	return $splits[@splits - 1] ; # last element
}

sub removeIfSuffix {
	my $suffix = shift ;
	my $path = shift ;
	my $suffixLen = length($suffix) ;
	my $wholeLen = length($path) ;
	my $end = substr($path, $wholeLen - $suffixLen, $suffixLen) ;
	my $answer ;
	if ($end eq $suffix) {
		$answer = substr($path, 0, $wholeLen - $suffixLen) ;
	}
	else {
		$answer = $path ;
	}
	
	return $answer ;
}

# An enhanced "die" which also prints the current directory, handy for debugging when a script is invoking system processes!
sub stop {
	printf "$_.  Current directory is:\n   %s\n", currentWorkingDirectory() ;
	die (shift) ;
}

sub scriptPath {
	return __FILE__ ;
}

=com
Given a full path to a filesystem item, returns a reference to a hash containing information about the item.  The inner information hashes have the following keys and values:
  'modDate' = File modification time in seconds since Unix epoch
  'type' = 
      'f' = regular file (includes Mac OS alias, Path Finder alias)
      'd' = directory
      'l' = symbolic link
      '?' = unknown
      Note: The above codes are copied from the CPAN module File::Listing.
=cut
sub fileStats {
	my $path = shift ;
	#print "Processing $path\n" ;
	
	 # The format string "%LT%Dm %N" we give stat -f is because
	 #    %LT = low-level (L) format for file type (T)
	 #             Regular files are "", directories are "/"
	 #    %Dm = decimal (D) format for file modification time (m)
	 my $statString = `stat -n -f "%LT%Dm" "$path"` ;
	 #print "statString: $statString\n" ;
	 $statString =~ m|([^\d]?)(\d+)| ;
	 my $type = $1 ;
	 my $modDate = $2 ;
	 
	 # Decode the file type
	 if (length($type) == 0) {
		$type = 'f' ;
	 }
	 elsif ($type eq '/') {
		$type = 'd' ;
	 }
	 elsif ($type eq '@') {
		$type = 'l' ;
	 }
	 else {
		$type = '?' ;
	 }
	 
	 # Cool how you can just declare a reference, start treating it as a hash reference, and Perl is smart enough to make a hash for you.
	 my $valuesRef ;
	 $valuesRef->{'modDate'} = $modDate ;
	 $valuesRef->{'type'} = $type ;
	
	return $valuesRef ;
}

=com
Do not use this function because Archive::Zip does not properly zip symlinks.  Contrary to the documentation, when zipping, this module zips symlinks to directories as empty directories.  Also, sumlinks to regular files get "followed".
sub zipDirectoryOrDie {
	my $source = shift ;
	my $zipSource = shift ;
	my $zipFile = shift ;
	
	# Create a Zip file
	my $zip = Archive::Zip->new();
	my $ok ;
	
	# Add the source directory
	$ok = $zip->addTree($source,$zipSource) ;
	if (!$ok) {
		print "Added tree: $source\n    in zip archive as:\n$zipSource\n" ;
	}
	else {
		print "Could not zip tree:\n   $source\ninto zip as:\n   $zipSource\n" ;
		die "Aborting due to error" ;
	}
	
	# Save the Zip file
	my $msg ;
	$ok = $zip->writeToFileNamed($zipFile) ;
	if ($ok == AZ_OK) {
		 $msg = "Succeeded writing zip archive" ;
	}
	else {
		 $msg = "Error writing zip archive" ;
	}
	$msg .= " from:\n	$source\nas:\n	$zipSource\nto:\n	$zipFile\n" ;
	if ($ok == AZ_OK) {
		print ($msg) ;
	}
	else {
		die ($msg) ;
	}
}
=cut

1
