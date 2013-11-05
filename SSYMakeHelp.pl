#!/usr/bin/perl

=com

SYNOPSIS

SSYMakeHelp.pl <options> sourceDir outputDir serverDomain serverPathToHelpBook [defaultNumberingLevel]

sourceDir is a path containing markdown files.  See REQUIREMENTS below.

outputDir is an existing directory which will be cleaned and into which all the output files comprising your new Help Book will be written.

serverDomain is the domain name, i.e. "mycompany.com" to which the Help Book will be uploaded.

serverPathToHelpBook is the path from the http landing to the Help Book on the server.  For example, if the Help Book will be at http://sheepsystems.com/bookmacster/HelpBook/, then serverPathToHelpBook should be bookmacster/HelpBook/.

defaultNumberingLevel is the numbering level used for pages which do not begin with a SSYMH-NUMBERING-LEVEL directive.  (See below.)  If this optional argument is absent, the default default numbering level becomes n=2.

OPTIONS

-d  Do not produce an index with hiutil.  This option is typically used to save time when producing drafts.  Do not ship a product produced with this option.

WHAT IT DOES

(incomplete)

* Generates a Help Book from markdown source files.

* Checks a specified source code file for string constants supposed to be help anchors in the generated Help Book, and makes sure that they exist in the book.

* Runs Apple's hiutil to index the generated Help Book.


OTHER PROGRAMS REQUIRED

A 'MultiMarkdown' directory with a subdirectory named 'bin', containing MultiMarkdown.pl and SmartyPants.pl, must be located in the same directory as this script.

Your bash $PATH must contain syncdirsdiff.pl.

REQUIREMENTS FOR THE MARKDOWN FILES IN sourceDir

The sourceDir must contain a root html file named "SSYMH.00.00.markdown" which populates the right column of the root/home/main page.  This file has a special syntax which is explained at the beginning of the sample SSYMH.00.00.markdown provided in the distribution.

The sourceDir should also contain MultiMarkdown source files with names of the form "SSYMH.xx.yy.zz.markdown", where xx.yy.zz is a section number.  The number of levels need not be three, but the place value per level should be 100; i.e. there can be only 99 subsections in a section.  The 00th subsection should be an "overview" of the section.  Leading zeros are required because the files must be processed in order.  You should be doing this already anyhow, unless it really makes your day to look in your filesystem browser and see files ordered as 1, 11, 12, ... 19, 2, 20, 21, ... .  

The last two arguments are only required if you would also like SSYMakeHelp.pl to produce an .htaccess file which will redirect identifier labels to the proper page if the produced Help Book is uploaded to an Apache web server.

Labels will be added automatically for headings in the markdown source for the first three levels:

# Level 1 Heading

## Level 2 Heading

### Level 3 Heading

Note that, in accordance with MultiMarkdown syntax, each of the above three must be on a line by themself; i.e. the entire line is the title, and must be preceded and followed by a blank line.

SSYMakeHelp thus supports four levels of heading

Level 0:  A "section heading" page with a single <h1> heading at the top
Level 1:  A "subsection page" with a single <h1> heading at the top
Level 3:  A "subsubsection" with an <h2> heading.  May be more than one on a page.
Level 4:  A "subsubsubsection" with an <h3> heading.  May be more than one on a page.

Processing of the markdown source into HTML consists of:

*  If your text editor has the "feature" of prepending the misnomered UTF-8 "byte order mark" (0xEF, 0xBB, 0xBF) onto your .markdown file, SSYMakeHelp.pl will remove it prior to SmartyPants getting screwed up by the high-bit characters and giving unexpected results later.
*  Encode high-bit characters into HTML entities.
#  Connect sentences with nonbreaking space followed by a space, so that it will be rendered as two spaces.
#  Process with SmartyPants
#  Process with Markdown
The order of the above processes reflects the fact that SmartyPants will produce unexpected results if its input contains any high-bit characters.

If an italicized phrase is followed by a punctuation character, move the punctuation character inside the italics.  This is because, although it is natural to not put the punctuation character inside the italics delimiters (asterisks), renderings by most web browsers I've seen leave an large, bad-looking gap between the last italicized character and the unitalicized punctuation character.

Your .markdown files may be encoded as UTF8 and may contain any characters in the UTF8 character set.  SSYMakeHelp.pl will take care of these before processing by SmartyPants.

Each .markdown file may begin with
SSYMH-NUMBERING-LEVEL n
where n is a number that controls which, if any, title lines in that page are prefixed with numbers:
  n
  0   No sections are numbered
  1   The title of the page is numbered.
         Example: "1.0  Introduction"
  2   and, first-level sections within pages are numbered
         Example: "1.0.1  History"
  3   and, second-level sections within pages are numbered
         Example: "1.0.1.1  Years 1999 BC to 1000 BC


Each .markdown file may contain the following placeholder line:
SSYMH-SECTION-TOC
with no spaces.  If it does, that line will be replaced with a <div> block containing a Table of Contents for the page.  The items of this table will be links to any child pages.

Each .markdown file may contain the following placeholder line:
SSYMH-PAGE-TOC
with no spaces.  If it does, that line will be replaced with a <div> block containing a Table of Contents for the page.  The items of this table will be links to any <h2> tags in the page, appearing in Markdown format as lines of the form:
## My Title [myLabel]
The "My Title" may contain Markdown syntax, for example to italicize a word,
** My *Clever* Title [myLabel]
If the label, i.e. [myLabel], is not provided, one will be created by removing spaces from the title.  The label must be globally unique.  (Obviously, the above two statements taken together indicate a potential problem.)

Image files in a subdirectory of sourceDir named 'rawScreenshots', with file extension .png, .jpg or .jpeg, will be copied, reduced to 85%, or lower if required to not exceed a width of 600 pixels, and added to a directory named 'images' in outputDir.  The idea is that, in a Help Book, it's good for screenshots to be reduced a little, which makes them a little fuzzy, so that the user realizes that the screenshot is not the real thing and doesn't get frustrated trying to click buttons in it.  With this feature, you can just dump all of your screenshots into the rawScreenshots folder, and they will appear, for example, in /path/to/outputDir/images/MyScreenshotName.png, reduced to 85%.  Then in your Help Book, you refer to such an image as <img src="images/MyScreenshotName.png" alt="" />


The CSS style sheet named "SSYMH.css" provided in the distribution should also be in your source directory.  You may modify it, of course.

To facilitate creating links to child pages on parent pages, each markdown file should have one and only one <h1> level title which, in markdown syntax, looks like this:
# My Title of This Page  [optionalLabel]

CHECKING HELP ANCHORS IN APP FOR BROKEN-NESS

To prevent broken links when your Help Book is revised, when referring to anchors in the Help Book in order to open Help Book pages in Help Viewer, in executable code, always refer to a NSString constant declared in a file named SSYMH.AppAnchors.h and defined in SSYMH.AppAnchors.m.  The latter file should be in sourceDir.  SSYMakeHelp will parse this file for any NSString* constants, check these and make sure they exist when generating the Help Book, logging any failures.

OPERATION

SSYMakeHelp.pl will remove any existing files and/or directories in outputDir, and then copy into it all items from sourceDir into outputDir, except for a directory named rawScreenshots, and except for markdown files which will be processed into html files consisting of an html header, a navigation bar, the processed HTML body including an optional Page Table of Contents and optional Section Table of Contents, and finally an html trailer.

OUTPUT FEATURES

The Help Book directory produced also contains a .htaccess file which contains redirects to the labels.  (Of course, this only works for Apache web servers.)  This is so that you can link to the labels directly from other html without having to know the page number.  For example, the url http://domain.com/path/to/HelpBook/aLabel will be redirected to something like http://domain.com/path/to/HelpBook/SSYMH.02.03.html#aLabel.  Ideally, your labels will change much less often than your page numbers, so this method will result in fewer broken links when your Help Book is subsequently revised.

Existing directories and files in the outputDir are compared with new versions and are left untouched if there are no changes.  Therefore, if you use a program such as SSYShipProduct.pl, which compares file modification dates before uploading, to upload the produced Help Book to a server, unchanged files and directories will not be unnecessarily uploaded.

LIMITATIONS

Unix file management programs are used.  Resource forks are ignored; therefore, for example, Mac OS Alias files in your source directory will not be properly copied.

Symbolic links in your source director are not copied either.

=cut


use strict ;

use File::Spec ;
use File::Temp ;
use IPC::Run ;
use Storable ;
use File::Util ;
use Getopt::Std ;

# The following is added for debugging, per this recommendation:
# http://groups.google.com/group/comp.lang.perl.misc/browse_thread/thread/41f9217de9321e7c#
require Carp; 
$SIG{INFO} = sub { Carp::cluck("SIGINFO") }; 
$SIG{QUIT} = sub { Carp::confess("SIGQUIT") }; 
# So that if this program gets stuck, you can press ^T to get a backtrace, and ^\ to get a backtrace and kill the program.

# Sometimes this is necessary for modules in this directory to be found at compile time when running on my Mac:
use lib '/Users/jk/Documents/Programming/Scripts' ;

use SSYUtils2 ;

my $verbose = 1 ;

my %options=();
getopts("d",\%options) ;

my $doIndex = !defined($options{d}) ;

if ($doIndex) {
	print "The product will be indexed and ready to ship.\n" ;
}
else {
	print "Will skip indexing the product.  Do not ship this product.\n" ;
}

my $numberOfArguments = $#ARGV + 1 ;
my $sourceDir = $ARGV[0] ;
my $outputDir = $ARGV[1] ;
my $serverDomain = $ARGV[2] ;
my $serverPathToHelpBook = SSYUtils2::addTrailingSlashIfNone($ARGV[3]) ;
my $defaultNumberingLevel = 2 ;
if ($numberOfArguments > 4) {
	$defaultNumberingLevel = $ARGV[4] ;
}

# Warning!  When adding to this script, do not write files to $outputDir because it will be overwritten.  Write to $tempDir!!!

my $styleSheetFilename = "SSYMH.css" ;
my $pageTocPlaceholderLine = "SSYMH-PAGE-TOC\n" ;
my $sectionTocPlaceholderLine = "SSYMH-SECTION-TOC\n" ;
my $placeValuePerDot = 100 ; # Because each "digit" is two decimal digits = 10^2
my $placeValueSquared = $placeValuePerDot * $placeValuePerDot ;
my $placeValueCubed = $placeValueSquared * $placeValuePerDot ;
my $imagesDirName = "images" ;
my $identifierLookupFilename = "_Identifier_Lookup.data" ;
my $rawScreenshotsDirName = "rawScreenshots" ;
my $appHelpAnchorsFilename = "SSYMH.AppAnchors.m" ;
my $screenshotScaleFactor = .85 ;
my $screenshotMaxWidth = 600 ; # pixels
my $authorTocFilename = "_Table_of_Contents.html" ;
my $htaccessFilename = ".htaccess" ;
my $gMaxLabelLength = 24 ;
my $ok ;


my $programName = SSYUtils2::programName() ;

if (($outputDir eq "") || (!defined($outputDir))) {
	die "This script was invoked with parameter outputDir = \"\".  Executing would cause your entire startup drive to be replaced with the new Help Book.  Obviously this is not what you want.  Aborting!" ;
}

my $fileUtil = File::Util->new() ;

my @rawNames = $fileUtil->list_dir($sourceDir, ,'--no-fsdots') ;
# Note: list_dir provides @rawNames sorted alphabetically already.

$outputDir = SSYUtils2::addTrailingSlashIfNone($outputDir) ;
$sourceDir = SSYUtils2::addTrailingSlashIfNone($sourceDir) ;

# Note: To debug, without cleaning, change CLEANUP => 1 below to CLEANUP => 0
my $tempDir = SSYUtils2::addTrailingSlashIfNone(File::Temp::tempdir(CLEANUP => 1)) ;
print "Products will initially be written to temporary directory:\n   $tempDir\n" ;
my $nSources = @rawNames ;
print "Found $nSources files in source directory:\n   $sourceDir\n" ;

# This program requires two loops for the markdown files because, fundamentally, we need to know what all the sections are before we can create the hyperlinks in each page.  Therefore, the first loop finds the sections for markdown files, but for other files, which require no further processing, it just copies them to the final destination.
my $i ;
my @sectionNumbers ;
my %sectionFilenamesHash = () ;
my @sectionFilenames = () ;
for ($i=0; $i<@rawNames; $i++) {	
	# print "Processing: $rawNames[$i]\n" ;
	if (SSYUtils2::filenameExtension($rawNames[$i]) eq "markdown") {
		push @sectionFilenames, $rawNames[$i] ;
		my @splits = reverse(split(/\./, SSYUtils2::removePathExtension($rawNames[$i]))) ;
		my $j = 0 ;
		my $placeValue = $placeValueSquared ;
		my $nextDigit ;
		my $sectionNum = 0 ;
		my $done = 0 ;
		do {
			$nextDigit = $splits[$j] ;
			$nextDigit =~ m/(\d+)/ ;
			my $extractedNumber = $1 ;
			if ($extractedNumber eq $nextDigit) {
				# This piece of the split is a decimal number
				$sectionNum += $extractedNumber * $placeValue ;
				$placeValue *= $placeValuePerDot ;
				$j++ ;
			}
			else {
				# This piece of the split is not a decimal number.
				# It is the first part of the filename, "SSYMH"
				$done = 1 ;
			}
		} until ($done) ;
		
		$sectionFilenamesHash{$sectionNum} = $rawNames[$i] ;
		push @sectionNumbers, $sectionNum ;
	}
	elsif (
		# For some reason, I'm still getting .DS_Store in @rawNames even though I passed '--no-fsdots' flag to list_dir().  So, I exclude that now...
		# Do not copy hidden files (whose names begin with ".")
		(substr($rawNames[$i], 0, 1) ne ".")
		&&
		## Do not copy the rawScreenshots directory
		($rawNames[$i] ne $rawScreenshotsDirName)
		&&
		## Do not copy the Author's Table of Contents file
		($rawNames[$i] ne $authorTocFilename)
		&&
		## Do not copy the Identifier Lookup file
		($rawNames[$i] ne $identifierLookupFilename)
	) {
		# print "   Will copy: $sourceDir$rawNames[$i]\n          to: $tempDir$rawNames[$i]\n" ;
		SSYUtils2::systemDoOrDie("cp", "-fpRLX", qq{"$sourceDir$rawNames[$i]"}, qq{"$tempDir$rawNames[$i]"}) ;
		# Note: -X says to not copy extended attributes or resource forks
		print "Copied: $rawNames[$i]\n" ;
	}
}

# Process screenshots
my $rawScreenshotsDir = "$sourceDir$rawScreenshotsDirName/" ;
my $imagesDir = $tempDir . $imagesDirName . "/" ;
if ($fileUtil->existent($rawScreenshotsDir)) {
	my @screenshotNames = $fileUtil->list_dir($rawScreenshotsDir, qw/--no-fsdots/) ;
	my $nScreenshots = @screenshotNames ;
	print "Processing $nScreenshots screenshots...\n" ;
	for my $name (@screenshotNames) {
		my $pathIn = "$rawScreenshotsDir$name" ;
		if (
			(lc(SSYUtils2::filenameExtension($name)) eq "png")
			||
			(lc(SSYUtils2::filenameExtension($name)) eq "jpg")
			||
			(lc(SSYUtils2::filenameExtension($name)) eq "jpeg")
			) {
			print ("Processing screenshot $name\n") ;
			my $answer = `sips --getProperty pixelWidth $pathIn` ;
			# sips' answer is to echo the path, then a newline, then some whitespace, then the label "pixelWidth", then a colon, then more whitespace, then finally the number you asked for.  And I can't find any option to just gimme the answer.  Oh, well.  So we have to parse the stupid thing and hope that it doesn't break in a future version.  Maybe the most future-proof way would be to reverse the string, pick out the decimal digits which are now at the beginning, then re-reverse.  Here we go...
			$answer = reverse($answer) ;
			$answer =~ m/(\d+)/ ;
			$answer = $1 ;
			my $oldWidth = reverse($answer) ;
			# Now do the same stupid dance to get the oldHeight
			my $answer = `sips --getProperty pixelHeight $pathIn` ;
			$answer = reverse($answer) ;
			$answer =~ m/(\d+)/ ;
			$answer = $1 ;
			my $oldHeight = reverse($answer) ;
			my $newWidth = $oldWidth * $screenshotScaleFactor ;
			if ($newWidth > $screenshotMaxWidth) {
				$newWidth = $screenshotMaxWidth ;
			}

			my $pathOut = "$imagesDir$name" ;

			if ($oldWidth > $oldHeight) {
				`sips --resampleWidth $newWidth $pathIn --out $pathOut` ;
			}
			else {
				my $newHeight = ($newWidth/$oldWidth)*$oldHeight ;
				`sips --resampleHeight $newHeight $pathIn --out $pathOut` ;
			}
		}
	}
	
	rmdir($rawScreenshotsDir) ;
}


        
my $htmlTail = "</body>\n</html>\n" ;


# Now we do the second loop, processing the markdown files
# Define the variables which we shall populate
my $homeLabel ;
my %sectionToTitleHash = () ;
my @mainTocLinks = () ;
my %sectionToLabelHash = () ;
my %labelToSectionHash = () ;
my @linkDisplayTexts = () ;
my @identifiersImplemented ;
my $bookTitle = undef ;
my $appIconFilename = undef ;
my $faqTitle = undef ;
my $faqSubtitle = undef ;
my @faqSections = () ;
my @identifiersReferencedInFAQ = () ;
my @brokenInternalLinksType2 = () ;

$i = 0 ;
my $aMarkDisplayText = "-SSYMH-DISPTXT-" ;
my $aMarkLabel = "-SSYMH-IDLABEL-" ;
my $aMarkOtherAttributes = "-SSYMH-OTHRATR-" ;
# Each page must have a different title, because it is these titles that are shown as different "results" when the user clicks in the main menu "Help" and types text into the search field.
my $thisPageTitle ;
my $aLine ;

foreach my $filename (@sectionFilenames) {
	print("Processing $filename ...\n") ;

	my $htmlFilename ;
	if ($i == 0) {
		$htmlFilename = "index" ;
	}
	else {
		$htmlFilename = SSYUtils2::removePathExtension($filename) ;
	}
	$htmlFilename .= ".html" ;
	push @mainTocLinks, $htmlFilename ;

	my $navLinks = "" ;
	my $sectionNumber = $sectionNumbers[$i] ;
	my $maj = int($sectionNumber/$placeValueCubed) ;
	my $min = int(($sectionNumber % $placeValueCubed)/$placeValueSquared) ;
	my $string2 = sprintf ("%02d.%02d", $maj, $min) ;
	my $parentSectionNumber = $placeValueCubed * int($sectionNumber / $placeValueCubed) ;
	
	# Construct line of Navigation Links
	# All pages have a link to the Home Page.  We start with that.
	my $navLinks = "<td><a href=\"index.html\">Home</a>" ;
	# Add link to Parent Page, if applicable
	my $parentLink ;
	if (
		($parentSectionNumber == $sectionNumber) # This is a major section
		||
		($parentSectionNumber == 0) # This is a preface section such as 0.1, 0.2, etc.
		) {
		$parentLink = "index" ;
	}
	else {
	# The current page is NOT a major section, so we also have 
		# a Parent Page.
		$parentLink = $sectionFilenamesHash{$parentSectionNumber} ;
		# parentLink has extension .markdown.  We must replace that with .html.
		$parentLink = SSYUtils2::removePathExtension($parentLink) ;
	}
	$parentLink = "href=\"$parentLink.html\"" ;
	$navLinks .= " | <a $parentLink>Parent</a></td>\n" ;
	# Add the "Page Navigation" label in the middle
	$navLinks .= "\t\t<td class=\"navLinkTitle\">&#8592; Go &#8594;</td>\n" ;
	# Compute filename of to Prior Page, unless this is the first page
	my $prevFilename = undef ;
	if ($i > 0) {
		$prevFilename = $sectionFilenames[$i-1] ;
		$prevFilename = SSYUtils2::removePathExtension($prevFilename) ;
	}
	# Compute filename of to Next Page, unless this is the last page
	my $nextFilename = undef ;
	if ($i < @sectionNumbers - 1) {
		$nextFilename = $sectionFilenames[$i+1] ;
		$nextFilename = SSYUtils2::removePathExtension($nextFilename) ;
	}
	# Append Prior and/or Next Page links to our Navigation Links
	my $hyperPrior = "<a href=\"$prevFilename.html\">Prior</a>" ;
	my $hyperNext = "<a href=\"$nextFilename.html\">Next</a>" ;
	if ($prevFilename && $nextFilename) {
		$navLinks .= "\t\t<td>$hyperPrior | $hyperNext</td>" ;
	}
	elsif ($prevFilename) {
		$navLinks .= "\t\t<td>$hyperPrior</td>" ;
	}
	elsif ($nextFilename) {
		$navLinks .= "\t\t<td>$hyperNext</td>" ;
	}
	# Done constructing line of Navigation Links

	my $numberingLevel = $defaultNumberingLevel ;
	
	# Prepare to read in the markdown source line by line
	# Since we're in a loop processing multiple files,
	# re-set all of the local process variables.
	my $sourceFilePath = $sourceDir. $filename ;
	my @sourceLines ;
	my @h2Titles = () ;
	my @h2Labels = () ;
	my $h2Index = 0 ;
	my $h3Index = 0 ;
	my $h4Index = 0 ;
	my $h5Index = 0 ;
	my $j = 0 ;
	# The following local variables are for processing the Home Page ($i==0) only
	my $isInComment = 0 ;
	my @linesInCurrentSection = () ;
	# Any text before the newline which begins the first section,
	# generally the comment section, is in section number 0.
	my $currentSectionNumber = 0 ;
	# Read the .markdown file line by line.  For each line,
	#    Perform preMarkdown (see below)
	#    Gather info needed to create and place the Page TOC, if any
	#    Gather info needed the place the Section TOC, if any.
	open (SOURCEDATA, $sourceFilePath) ;
	while ($aLine = <SOURCEDATA>) {
		if (substr($aLine, 0, 21) eq "SSYMH-NUMBERING-LEVEL") { 
			$aLine =~ m/(\d+)/ ;
			$numberingLevel = $1 ;
			next ;
		}
	
		# Perform the preMarkdown.  The preMarkdown does:
		#  * Check for UTF8 Byte Order Mark and removes it if found
		#  * Perform UTF8 decoding
		#  * Convert non-ASCII characters into HTML Entities
		#  * Replace any two consecutive spaces between sentences with
		#    one space and nonbreaking space (&#160;)
		#  * Move any trailing punctuation characters inside Markdown italics.
		$aLine = SSYUtils2::preMarkdown ($aLine, $j, $filename) ;
		if ($i == 0) {
			# This is the Home Page markdown source.  Do special parsing.
			
			# See if we are in a multiline HTML comment delimited by <!--  ... -->
			if ($aLine =~ m/<!--/) {
				$isInComment = 1 ;
			}
			elsif ($aLine =~ m/-->/) {
				$isInComment = 0 ;
			}
			
			if (!$isInComment) {
				if ($aLine eq "\n") {
					# We've encountered an empty line, a section delimiter.
					# Close and process the previous section, if any
					if (@linesInCurrentSection == 0) {
						# This is a blank line before the first section.
						# Do nothing
					}					
					elsif ($currentSectionNumber == 1) {
						my $topFaqMarkdownList = "" ;
						foreach my $daLine (@linesInCurrentSection) {
							if (!defined($bookTitle)) {
								# First line of first section, the Help Book title
								$bookTitle = $daLine ;
								chomp($bookTitle) ;
								$homeLabel = concoctLabel($bookTitle) ;
								$sectionToTitleHash{"00.00.00.00"} = $bookTitle ;
								$sectionToLabelHash{"00.00.00.00"} = $homeLabel ;
								$labelToSectionHash{$homeLabel} = "00.00.00.00" ;
							}
							elsif (!defined($appIconFilename)) {
								# Second line of first section, the app icon filename
								$appIconFilename = $daLine ;
								chomp($appIconFilename) ;
							}
							elsif (!defined($faqTitle)) {
								# Third line of first section, the title of the FAQ section
								$faqTitle = $daLine ;
								$faqTitle = SSYUtils2::smartMarkdown($faqTitle, SSYUtils2::scriptParentPath()) ;
								markAndPushIncompleteHyperlinks(\$faqTitle, \@linkDisplayTexts) ;
								chomp($faqTitle) ;
							}
							elsif (!defined($faqSubtitle)) {
								# Fourth line of first section, the subtitle of the FAQ section
								$faqSubtitle = $daLine ;
								$faqSubtitle = SSYUtils2::smartMarkdown($faqSubtitle, SSYUtils2::scriptParentPath()) ;
								markAndPushIncompleteHyperlinks(\$faqSubtitle, \@linkDisplayTexts) ;
								chomp($faqSubtitle) ;
							}
						}
						
					}
					elsif (@linesInCurrentSection > 2) {
						# We have a valid regular (non-first) section
						# Build a hash of data which we shall use later to add
						# this into index.html.
						my %sectionHash = {} ;
						$sectionHash{'imageFilename'} = $linesInCurrentSection[0] ;
						my $string ;
						$string = $linesInCurrentSection[1] ;
						$string = SSYUtils2::smartMarkdown($string, SSYUtils2::scriptParentPath()) ;
						markAndPushIncompleteHyperlinks(\$string, \@linkDisplayTexts) ;
						$sectionHash{'title'} = $string ;
						$string = $linesInCurrentSection[2] ;
						$string = SSYUtils2::smartMarkdown($string, SSYUtils2::scriptParentPath()) ;
						markAndPushIncompleteHyperlinks(\$string, \@linkDisplayTexts) ;
						$sectionHash{'faqDetail'} = $string ;
						chomp(%sectionHash) ;
						# Above, removes trailing newlines from values but not keys.
						# Remaining linesInCurrentSelection are a Markdown list.
						# Well, not exactly.  They need newlines before and after.
						# But we can fix that.
						# Interspersed in here we also create a loggable version of the list.

						# Push a reference to the hash of data onto our array
						push(@faqSections, \%sectionHash) ;
					}
					
					# Remove all linesInCurrentSection, to clean
					# it out for the next section
					@linesInCurrentSection = () ;
					$currentSectionNumber++ ;
				}
				else {
					push (@linesInCurrentSection, $aLine) ;
				}
			}
		}	
		else {
			# Extract any titles and labels and push onto hashes.
			# Note that this is not necessary and not done for the
			# Home Page SSYMH.00.00, flagged by $i==0.  
			# That's because the Home Page' title is the name of
			# the Help Book, we already pushed this onto the hashes
			# when we extracted $bookTitle above in the $i==0
			# iteration, and there should be no other titles or
			# labels in SSYMY.00.00.markdown.
	
			# Extract Level 1 titles and their labels, if any
			if (substr($aLine, 0, 2) eq "# ") {
				# $aLine is the title, i.e. the <h1> heading, for this page
				# For example, it may be something like
				#     # True *Documents* -- use *Import* and *Export* [truDocImex]\n
	
				my $title ;
				my $label ;
				$aLine = extractTitleAndLabelFromLine($aLine, \$title, \$label) ;
				
				$thisPageTitle = $title ;
				# In Mac OS X 10.5, Help Indexer can't handle html tags such as <em> </em> in title tags
				$thisPageTitle =~ s/<[\/a-zA-Z]+?>//g ;
	
				my $string4 = $string2 . ".00.00" ;
				
				if (defined($labelToSectionHash{$label})) {
					die "Proposed label for section $string4, \"$label\", already exists for section $labelToSectionHash{$label}.  Duplicate labels in a Help Book are not allowed."
				}
				$sectionToLabelHash{$string4} = $label ;
				$sectionToTitleHash{$string4} = $title ;
				$labelToSectionHash{$label} = $string4 ;
				if ($numberingLevel > 0) {
					$aLine = "# $maj.$min &#160;" . substr($aLine, 2) ;
				}
			}

			# Extract Level 2 titles and their labels, if any
			if (substr($aLine, 0, 3) eq "## ") {
				# $aLine titles a section within the page, i.e. a <h2> heading
				# For example, it may be something like
				#     ## True *Documents* -- use *Import* and *Export* [truDocImex]\n
	
				my $title ;
				my $label ;
				$aLine = extractTitleAndLabelFromLine($aLine, \$title, \$label) ;
				push @h2Titles, $title ;
				push @h2Labels, $label ;
				
				$h2Index++ ;
				my $string4 = $string2 . sprintf (".%02d.00", $h2Index) ;
	
				if (defined($labelToSectionHash{$label})) {
					die "Proposed label for section $string4, \"$label\", already exists for section $labelToSectionHash{$label}.  Duplicate labels in a Help Book are not allowed."
				}
				$sectionToLabelHash{$string4} = $label ;
				$sectionToTitleHash{$string4} = $title ;
				$labelToSectionHash{$label} = $string4 ;
				if ($numberingLevel > 1) {
					$aLine = "## $maj.$min.$h2Index &#160;" . substr($aLine, 3) ;
				}
				$h3Index = 0 ;
			}
	
			# Extract Level 3 titles and their labels, if any
			if (substr($aLine, 0, 4) eq "### ") {
				# $aLine titles a subsection within the page, i.e. a <h3> heading
				# For example, it may be something like
				#     ### Cats -- Evil!!\n
	
				my $title ;
				my $label ;
				$aLine = extractTitleAndLabelFromLine($aLine, \$title, \$label) ;
				
				$h3Index++ ;
				my $string4 = $string2 . sprintf (".%02d.%02d", $h2Index, $h3Index) ;
	
				if (defined($labelToSectionHash{$label})) {
					die "Proposed label for section $string4, \"$label\", already exists for section $labelToSectionHash{$label}.  Duplicate labels in a Help Book are not allowed."
				}
				$sectionToLabelHash{$string4} = $label ;
				$sectionToTitleHash{$string4} = $title ;
				$labelToSectionHash{$label} = $string4 ;
				if ($numberingLevel > 2) {
					$aLine = "### $maj.$min.$h2Index$h3Index &#160;" . substr($aLine, 4) ;
				}
				$h4Index = 0 ;
			}
	
			# Extract Level 4 titles and their labels, if any
			if (substr($aLine, 0, 5) eq "#### ") {
				# $aLine titles a subsection within the page, i.e. a <h4> heading
				# For example, it may be something like
				#     #### Cats -- Evil!!\n
	
				my $title ;
				my $label ;
				$aLine = extractTitleAndLabelFromLine($aLine, \$title, \$label) ;
				
				$h4Index++ ;
				my $string4 = $string2 . sprintf (".%02d.%02d.%02d", $h2Index, $h3Index, $h4Index) ;
	
				if (defined($labelToSectionHash{$label})) {
					die "Proposed label for section $string4, \"$label\", already exists for section $labelToSectionHash{$label}.  Duplicate labels in a Help Book are not allowed."
				}
				$sectionToLabelHash{$string4} = $label ;
				$sectionToTitleHash{$string4} = $title ;
				$labelToSectionHash{$label} = $string4 ;
				if ($numberingLevel > 3) {
					$aLine = "#### $maj.$min.$h2Index$h3Index$h4Index &#160;" . substr($aLine, 4) ;
				}
				$h5Index = 0 ;
			}

			# Extract Level 5 titles and their labels, if any
			if (substr($aLine, 0, 6) eq "##### ") {
				# $aLine titles a subsection within the page, i.e. a <h5> heading
				# For example, it may be something like
				#     ##### Cats -- Evil!!\n
	
				my $title ;
				my $label ;
				$aLine = extractTitleAndLabelFromLine($aLine, \$title, \$label) ;
				
				$h5Index++ ;
				my $string4 = $string2 . sprintf (".%02d.%02d.%02d", $h2Index, $h3Index, $h4Index, $h5Index) ;
	
				if (defined($labelToSectionHash{$label})) {
					die "Proposed label for section $string4, \"$label\", already exists for section $labelToSectionHash{$label}.  Duplicate labels in a Help Book are not allowed."
				}
				$sectionToLabelHash{$string4} = $label ;
				$sectionToTitleHash{$string4} = $title ;
				$labelToSectionHash{$label} = $string4 ;
				if ($numberingLevel > 4) {
					$aLine = "##### $maj.$min.$h2Index$h3Index$h4Index$h5Index &#160;" . substr($aLine, 4) ;
				}
			}
		}
	

		# Push the extracted line.  Note that we waited until the end in
		# case we didn't parse a label and extractTitleAndLabelFromLine needed
		# to concoct one.)
		push @sourceLines, $aLine ;
		$j++ ;
	}
	close(SOURCEDATA) ;
	
	# The remainder of the actions in this loop do not apply to the Home
	# Page.  Most of them are for producing an HTML file from the input
	# Markdown file.  In the case of the Home Page, we do not produce an
	# HTML file but instead forward the information parsed into 
	# construction of the index.html file which occurs later.
	if ($i==0) {
		$i=1 ;
		next ;
	}

	# Iterate through @sourceLines again, this time in order to
	# construct and splice in any Page Table of Contents and/or
	# Section Table Of contents.
	$j = 0 ;
	for $aLine (@sourceLines) {
		if ($aLine eq $pageTocPlaceholderLine) {
			# Construct and splice in the Page Table of Contents block
			my $toc = "\t&#160; &#160; &#160; &#160;<b>Topics on this Page</b>\n\t<ul>\n" ;
			my $iTOC = 0 ;
			foreach my $title (@h2Titles) {
				my $label = $h2Labels[$iTOC] ;
				$toc .= "\t\t<li><a href=\"#$label\">$title</a></li>\n" ;
				$iTOC++ ;
			}
			$toc .= "\t</ul>\n" ;	
			$toc = "<div class=\"pageContents\">\n" . $toc . "</div>\n" ;
			
			# Replace the single placeholder line with the generated $toc.
			splice @sourceLines, $j, 1, ($toc) ;
		}
		elsif ($aLine eq $sectionTocPlaceholderLine) {
			# Construct and splice in the Section Table of Contents block

			# Find the range of @sectionFilenames that represent subsections of this section
			my $nextSectionNumber = SSYUtils2::increaseToNextMostSignificantDigit($sectionNumber, $placeValuePerDot) ;
			my $k = 0 ;
			my $lowestSubsectionIndex = undef ;
			my $highestSubsectionIndex = 0 ;
			foreach my $candidate (@sectionNumbers) {
				if ($sectionNumbers[$k] > $sectionNumber) {
					if (!defined($lowestSubsectionIndex)) {
						$lowestSubsectionIndex = $k ;
					}
					
					if ($sectionNumbers[$k] < $nextSectionNumber) {
						$highestSubsectionIndex = $k ;
					}
				}
				$k++ ;
			}
			
			# Construct and splice in the Section Table of Contents block
			my $toc = "\t&#160; &#160; &#160; &#160;<b>Topic Pages in Chapter $maj</b>\n\t<ul>\n" ;
			my $iTOC = 0 ;
			my $subsectionIndex = 1 ;
			for(my $iTOC=$lowestSubsectionIndex; $iTOC<=$highestSubsectionIndex; $iTOC++) {
				my $linkedMarkdownFilename = $sectionFilenames[$iTOC] ;
				my $linkedHtml = SSYUtils2::removePathExtension($linkedMarkdownFilename) . ".html" ;
				my $childFullPath = $sourceDir . $linkedMarkdownFilename ;
				my $linkedTitle = extractTitleFromMarkdownFile($childFullPath) ;
				
				# Append a line for this child page to the table of contents under construction.
				my $tocEntry = "\t\t<li><a href=\"$linkedHtml\">$maj.$subsectionIndex &#160;$linkedTitle</a></li>\n" ;
				$toc .= $tocEntry ;
				$subsectionIndex++ ;
			}
			$toc .= "\t</ul>\n" ;	
			$toc = "<div class=\"pageContents\">\n" . $toc . "</div>\n" ;
			
			# Replace the single placeholder line with the generated $toc.
			splice @sourceLines, $j, 1, ($toc) ;
		}
		$j++
	}
	
	# Convert @sourceLines back to a string
	my $htmlBody = join ("", @sourceLines) ;
	
	# Process through smartMarkdown
	$htmlBody = SSYUtils2::smartMarkdown($htmlBody, SSYUtils2::scriptParentPath()) ;
	$htmlBody .= "\n" ;
	
	markAndPushIncompleteHyperlinks(\$htmlBody, \@linkDisplayTexts) ;
	
	# Search for and push identifiers
	my $foundIdentifier = 1 ;
	my $htmlCopy = $htmlBody ;
	while ($foundIdentifier) {
		$foundIdentifier = ($htmlCopy =~ s/id="(.+?)"//) ;
		my $identifier = $1 ;
		if ($foundIdentifier) {
			print("   Found id=\"$identifier\"\n") ;
			my $isDupe ;
			foreach my $existingIdentifier (@identifiersImplemented) {
				if ($existingIdentifier eq $identifier) {
					$isDupe = 1 ;
					last ;
				}
			}
			
			if (!$isDupe) {
				push @identifiersImplemented, $identifier ;
			}
		}
	}

	# We declare the inner help pages as HTML5, so that we can use HTML5-only goodies such as <canvas>.
	my $headAndBodyTag = <<HEADANDBODYTAG ;
<!DOCTYPE html>
<html>
<head>
	<title>$thisPageTitle</title>
	<link rel="stylesheet" href="$styleSheetFilename" type="text/css" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="generator" content="SSYMakeHelp.pl" />
</head>

<body id="normalBody">

HEADANDBODYTAG
	
	my $navLinks = <<NAVLINKS ;
<table class="navLinks">
	<tr>
		$navLinks
	</tr>
</table>

NAVLINKS
# In the above, class="navLinks" was id="navLinks", but HTML validator bitched that I had two of th same id in the same document (one at top, one at bottom) and this is illegal.  So I changed it to "class" and also in SSYMH.css, I changed the #navlinks to .navlinks in two places.  See http://p2p.wrox.com/css-cascading-style-sheets/37436-purpose-hash-css-style.html if this doesn't work.
	
	my $break = "<br />\n" ;
	my $html = $headAndBodyTag . $navLinks . $break . $htmlBody . $break . $navLinks . $htmlTail ;
	
	# Construct html filename with full path
	my $bareFilename = SSYUtils2::removePathExtension($filename) ;
	my $htmlPath = "$tempDir$bareFilename.html" ;

	print (" Generated $bareFilename.html\n") ;

	# Write to file
	my $didWriteOK = open(HTML,">$htmlPath") ; 
	print HTML $html ;
	close(HTML) ;
	
	$i++ ;
}


# Generate HTML for the Author's Table of Contents, 
# also JavaScript for looking up href for id

# We declare it has HTML5, because there is no reason not to.
my $authorTocHtml = <<AUTHORTOCHEADER ;
<!DOCTYPE html>
<html>
<head>
	<title>$bookTitle : Author's Table of Contents</title>
	<style type="text/css">
		tr {
			font-family: sans-serif;
			font-size: small;
			line-height: 100%;
		}
	</style>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="generator" content="SSYMakeHelp.pl" />
</head>

<body>

<table>
AUTHORTOCHEADER

# Add Lines

$i = 0 ;

my $indentationUnit = "&#160;&#160;&#160;" ;
my @indentations ;

$indentations[0] = "" ;
for ($i=1; $i<4; $i++) {
	$indentations[$i] =  $indentations[$i-1] . $indentationUnit ;
}


$i = 0 ;
my $javascriptSectionForId = "" ;
for my $secNum (sort keys %sectionToLabelHash) {
	$authorTocHtml .= "<tr>" ;
	
	$secNum =~ m/(\d\d)\.(\d\d)\.(\d\d).(\d\d)/ ;
	my $s1 = $1 ;
	my $s2 = $2 ;
	my $s3 = $3 ;
	my $s4 = $4 ;
	my $level = 4 ;
	if ($s4 eq "00") {
		$level = 3 ;
		if ($s3 eq "00") {
			$level = 2 ;
			if ($s2 eq "00") {
				$level = 1 ;
			}
		}
	}

	my $title = $sectionToTitleHash{$secNum} ;
	my $label = $sectionToLabelHash{$secNum} ;
	my $labelColumn = sprintf("%16s ", $label) ;

	my $rowHtml = "<td>$label</td><td>$indentations[$level-1]$secNum</td><td>$indentations[$level-1]$title</td>" ;
	$rowHtml .= "</tr>\n" ;
	$authorTocHtml .= $rowHtml ;
	
	
	my $javaSectionForIdClause = <<JAVASECTIONFORIDCLAUSE ;
		else if (anId == "$label") {
			sec = "$s1.$s2" ;
		}
JAVASECTIONFORIDCLAUSE
	$javascriptSectionForId .= $javaSectionForIdClause ;
	
	$i++ ;
}
$authorTocHtml .= "</table>\n" ;
$authorTocHtml .= $htmlTail  ;

# Write the Author TOC file
my $authorTocPath = $sourceDir . $authorTocFilename ;
my $didWriteOK = open (AUTHORTOC,">$authorTocPath") ; 
print AUTHORTOC $authorTocHtml ;
close (AUTHORTOC) ;
print "Generated Author's Table of Contents\n" ;

# In the next sections, we retrieve from storage and iterate through firstly $displayLinkToIdentifier hash, then secibdkt iterate through @linkDisplayTexts, which are the display texts that had empty href="" in the html files we just generated, and see if there are any that do not already have identifiers in storage.  If so, we prompt the user for new identifiers, add them to the hash, store the new hash to disk, and finally generate javascript for the displayTextToIdentifier lookup JavaScript function.

# Read in our file of so-far-known displayLinkToIdentifier
my $identifierLookupPath = "$sourceDir$identifierLookupFilename" ;
print ("Will read stored identifiers from $identifierLookupPath\n") ;
my $displayLinkToIdentifierHashRef = SSYUtils2::retrieveFromStorage($identifierLookupPath) ;
my $nAlreadyDone = 0 ;
my $notAssigned = "NOT_ASSIGNED" ;
print  ("Previously-entered Identifier Values read from disk:\n") ;
printf ("%32s   used?     %s\n", "Identifier", "for Link Display Text") ;
printf ("%32s -------     %s\n", "----------", "---------------------") ;
for my $key (sort keys %$displayLinkToIdentifierHashRef) {
	my $value = $displayLinkToIdentifierHashRef->{$key} ;
	if ($value ne $notAssigned) {
		my $used = "-used" ;
		foreach my $displayText (@linkDisplayTexts) {
			if ($displayText eq $key) {
				$nAlreadyDone++ ;
				$used= "+used" ;
				last ;
			}
		}
		printf ("%32s ($used) <-- %s\n", $value, $key) ;
	}
}
my $nManually = @linkDisplayTexts - $nAlreadyDone ;
my $newDisplayLinkToIdentifierHashRef = {} ;
print "$nAlreadyDone identifiers were assigned using data read from disk.\n" ;
print "$nManually must be entered manually.\n" ;
print "To look up, use your newly-generated Author's Table of Contents here:\n   file://$authorTocPath\n" ;
print "To learn which section is referencing an identifier, search above for \"Must get URL to hyperlink\".\n" ;
my $aborted ;
my $nDone = 0 ;
foreach my $displayText (@linkDisplayTexts) {
	my $identifier = $displayLinkToIdentifierHashRef->{$displayText} ;
	if (!defined($identifier) || ($identifier eq $notAssigned)) {
		$identifier = $newDisplayLinkToIdentifierHashRef->{$displayText} ;
	}
	if (!defined($identifier)) {
		if ($aborted) {
			$identifier = $notAssigned ;
		}
		else {
			print("Enter id for \"$displayText\", or \"?\" to skip this, or \"*\" to skip all. (Done $nDone/$nManually)\n") ;
			$identifier = <STDIN> ;
			chomp ($identifier) ;
			if ($identifier eq "*") {
				$aborted = 1 ;
				$identifier = $notAssigned ;
			}
			elsif ($identifier eq "?") {
				$identifier = $notAssigned ;
			}
			else {
				push @identifiersImplemented, $identifier ;
			}
			$newDisplayLinkToIdentifierHashRef->{$displayText} = $identifier ;
			
			# Save newDisplayLinkToIdentifierHash to its file
			# Note: We do this here, so as to not lose entries so far in the event of a power failure or crash.  It is also done at the end of this loop.
			SSYUtils2::storeToStorage($newDisplayLinkToIdentifierHashRef, $identifierLookupPath) ;
			$nDone++ ;
		}
	}
	
	$newDisplayLinkToIdentifierHashRef->{$displayText} = $identifier ;
}
# Note that, comparing $displayLinkToIdentifierHashRef to $newDisplayLinkToIdentifierHashRef, we see that the latter has added new items and deleted items that are no longer used.

print "Parsing out help anchors in $appHelpAnchorsFilename ...\n" ;
my @appHelpAnchors  ;
my $appAnchorsPath = $sourceDir . $appHelpAnchorsFilename ;
my $openedAppAnchorsFileOk = open (APPANCHORS, $appAnchorsPath) ;
if ($openedAppAnchorsFileOk) {
	# This C file should be ASCII, so no binmode or utf8 incantations are necessary.
	my $nAppHelpAnchors = 0 ;
	while (my $aLine = <APPANCHORS>) {
		# Search for a text string such as "NSString * someIdentifier = @"targetAnchor" ;"
		$aLine =~ m/NSString\s*\*\s*const\s*\w+\s*=\s*\@\"(\w+)\"\s*;/ ;
		my $appHelpAnchor = $1 ;
		if (!$appHelpAnchor) {
			# Putting "const" before "NSString *" is also legal
			# Search for a text string such as "const NSString * someIdentifier = @"targetAnchor" ;"
			$aLine =~ m/const\s*NSString\s*\*\s*\w+\s*=\s*\@\"(\w+)\"\s*;/ ;
			my $appHelpAnchor = $1 ;
		}
		if ($appHelpAnchor) {
			print "  Found anchor: $appHelpAnchor\n" ;
			push @appHelpAnchors, $appHelpAnchor ;
			$nAppHelpAnchors++ ;
		}
	}
	print "Will check $nAppHelpAnchors Help Anchors found in $appHelpAnchorsFilename\n" ;
}
else {
	print "Warning! Could not open file $appAnchorsPath.\n  -- Assuming your app does not reference any help anchors\n  -- Not checking any help anchors for brokenness!\n" ;
}

# Check Help Anchors found in app
my $nBrokenAnchorsInApp = 0 ;
foreach my $appHelpAnchor (@appHelpAnchors) {
	my $ok = 0 ;
	foreach my $identifierImplemented (@identifiersImplemented) {
		if ( $identifierImplemented eq $appHelpAnchor) {
			$ok = 1 ;
			last ;
		}
	}
	
	if (!$ok) {
		$nBrokenAnchorsInApp++ ;
		print "ERROR.  Broken Help Anchor in app.  No id=\"$appHelpAnchor\"\n" ;
		print "You must remove or replace this Help Anchor in SSYMH.AppAnchors.c\n" ;
	}
}
if ($nBrokenAnchorsInApp == 0) {
	print "   All help anchors in SSYMH.AppAnchors.c are ok.\n" ;
}

# Check for broken links in FAQ (right side of Home Page)
my $nIdentifiersReferencedInFAQ = @identifiersReferencedInFAQ ;
print "Will check $nIdentifiersReferencedInFAQ links referenced from FAQ section of SSYMH.00.00.markdown\n" ;
my $nBrokenLinksInFAQ = 0 ;
foreach my $identifierFromFAQ (@identifiersReferencedInFAQ) {
	my $ok = 0 ;
	foreach my $identifierImplemented (@identifiersImplemented) {
		if ( $identifierImplemented eq $identifierFromFAQ) {
			$ok = 1 ;
			last ;
		}
	}
	
	if (!$ok) {
		$nBrokenLinksInFAQ++ ;
		print "ERROR.  Broken link in your FAQ.  No id=\"$identifierFromFAQ\"\n" ;
		print "You must remove or replace this identifier in SSYMH.00.00.markdown\n" ;
	}
}
if ($nBrokenLinksInFAQ == 0) {
	print "   All identifiers in FAQ of SSYMH.00.00.markdown are ok.\n" ;
}

print "Checking for broken internal links of type 1...\n" ;
# Check and make sure that all required ids exist (no broken internal links)
my @identifiersRequired = values (%$newDisplayLinkToIdentifierHashRef) ;
my $nBroken = 0 ;
foreach my $identifierRequired (@identifiersRequired) {
	my $ok = 0 ;
	foreach my $identifierImplemented (@identifiersImplemented) {
		if ( $identifierImplemented eq $identifierRequired) {
			$ok = 1 ;
			last ;
		}
	}
	
	if (!$ok) {
		$nBroken++ ;
		print "WARNING.  Type 1 Broken internal link.  No id=\"$identifierRequired\"\n" ;
		
		# Delete any key/value pairs in $newDisplayLinkToIdentifierHashRef which have this value
		while (my ($key, $value) = each (%$newDisplayLinkToIdentifierHashRef) ) {
			if (
				($value eq $identifierRequired)
				&&
				($value ne $notAssigned)
				) {
				delete $newDisplayLinkToIdentifierHashRef->{$key} ;
				print "   On disk, deleted identifier $identifierRequired for displayText \"$key\"\n" ;
			}
		}
	}
}
if ($nBroken == 0) {
	print "   You have zero (0) Type 1 Broken internal links.  Good.\n" ;
}

# Save newDisplayLinkToIdentifierHash to its file
SSYUtils2::storeToStorage($newDisplayLinkToIdentifierHashRef, $identifierLookupPath) ;

# Reprocess output files to replace anchorMarkers with anchors
foreach my $filename (@sectionFilenames) {
	$filename = reverse($filename) ;
	$filename =~ s/nwodkram/lmth/ ;
	$filename = reverse($filename) ;
	my $path = $tempDir . $filename ;
	my $newHtml = "" ;

	open (HTML, '+<', $path) ;
	# The HTML file should be all ASCII at this point, so no binmode or utf8 incantations are necessary.
	my $lineNum = 1 ;
	while ($aLine = <HTML>) {
		fillMarkedHyperlinks(\$aLine, $newDisplayLinkToIdentifierHashRef, \%labelToSectionHash, \@brokenInternalLinksType2) ;
		$newHtml .= $aLine ;
		$lineNum++ ;
	}
	
	# All I wanted to do was read text from a file, modify it, and then rewrite it.  What a nightmare.  At first, simply copying and pasting in code to read and write, I tried to close and then re-open the file.  I had trouble for two hours, which may have been because I was writing to $outputDir instead of $tempDir, or it may have been because of the following, or both.  From perlfunc documentation for seek():  "Once you hit EOF on your read, and then sleep for a while, you might have to stick in a seek() to reset things. The seek doesn't change the current position, but it does clear the end-of-file condition on the handle, so that the next <FILE> makes Perl try again to read something. We hope."
	# Hmmmmmm.  Well, opening the file as above with read + write access, i.e. '+<', then doing the following, seems to work and makes sense...
	truncate(HTML, 0) ;
	seek(HTML, 0, 0) ;
	print HTML $newHtml ;
	close(HTML) ;
}


# Generate index.html.

# We declare the root help page (index.html) as XHTML 1.0, because if declared it as HTML, without the <?xml declaration, validation would fail because the AppleTitle and AppleIcon <meta> elements in the header are not defined in the WHATWG Wiki.
my $indexHtml = <<INDEXHTMLHEAD ;
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>$bookTitle</title>
	
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="AppleTitle" content="$bookTitle" />
	<meta name="AppleIcon" content="images/$appIconFilename" />
	<meta name="generator" content="SSYMakeHelp.pl" />
	<link rel="stylesheet" href="SSYMH.css" type="text/css" />
</head>

<body class="homePage">

	<div class="divLeft">
	<div>
	<a href="$homeLabel"></a>

INDEXHTMLHEAD

# Add sections to Left Column

my $majorSectionEnding = "\r" ;
$i = 1 ;
for my $link (@mainTocLinks) {
	my $tocItem  ;

	my $isMajor = ($link =~ m/00.html/) ;
	$link =~ m/(\d+)\.(\d+)\.html/ ;
	my $secNumMaj = $1 ;
	my $secNumMin = $2 ;
	my $secNum2 = "$secNumMaj.$secNumMin" ;
	my $secNum4 = $secNum2 . ".00.00" ;
	
	my $label = $sectionToLabelHash{$secNum4} ;
	my $title = $sectionToTitleHash{$secNum4} ;
	my $labelColumn = sprintf("%16s", $label) ;
	
	my $prefixSecNum ;	
	if ($isMajor) {
		$prefixSecNum = $secNumMaj ;
	}
	else {
		$prefixSecNum = $secNumMin ;
	}
	# Remove leading zeros, append "." and space
	$prefixSecNum =~ s/0?(\d+)/$1. / ;

	my $style ;
	if ($isMajor) {
		if ($i != 0) {
			#Append ending of previous section
			$indexHtml .= $majorSectionEnding ;
		}
		$style = "chapterHeading" ;
	}
	else {
		$style = "item" ;
	}
	
	$tocItem = <<TOC_ITEM ;
	<div class="$style">
		<a href="$link">$prefixSecNum$title</a>
	</div>
TOC_ITEM

	$indexHtml .= $tocItem ;
	
	$i++ ;
}
# Remove newline from last TOC_ITEM
$indexHtml = substr($indexHtml, 0, -1) ;

# Append ending of last section
$indexHtml .= $majorSectionEnding ;

# Construct end of Left Column and beginning of the Right Column
	my $endLeftBeginRight = <<ENDLEFTBEGINRIGHT ;
	</div>
	</div>

	<div class="divRight">
	<div>
		<div class="mainIcon">
			<img src="images/$appIconFilename" alt="" height="120" width="120" border="0" />
			
		</div>
		<div class="mainTitle">
			<h1>$bookTitle</h1>
        </div>
        
		<table id="faqTable" class="faqTableClass">
		
			<tr class="faqTitleRow">
				<td></td>
				<td><span class="faqTitle">$faqTitle</span></td>
			</tr>
			<tr class="faqSubtitleRow">
				<td></td>
				<td><span class="faqSubtitle">$faqSubtitle</span></td>
			</tr>
ENDLEFTBEGINRIGHT

# Append end of Left Column and beginning of the Right Column
$indexHtml .= $endLeftBeginRight ;

# Construct rows of the FAQ table.  Each row is one section
my $faqTableString = "" ;
foreach my $sectionHashRef (@faqSections) {
	my %sectionHash = %$sectionHashRef ;
	my $sectionListItemsString = "" ;
	my $title = $sectionHash{'title'} ;
	fillMarkedHyperlinks(\$title, $newDisplayLinkToIdentifierHashRef, \%labelToSectionHash, \@brokenInternalLinksType2) ;
	my $faqDetail = $sectionHash{'faqDetail'} ;
	fillMarkedHyperlinks(\$faqDetail, $newDisplayLinkToIdentifierHashRef, \%labelToSectionHash, \@brokenInternalLinksType2) ;

	my $tableRowHtml = <<FAQTABLEROW ;
			<tr>
				<td class="faqImageClass">
					<img src="images/$sectionHash{'imageFilename'}" alt="" class="faqImageClass"/>
				</td>
				<td class="faqTextClass">
					<h2>$title</h2>
					<span class="faqDetail">$faqDetail</span>
				</td>
			</tr>
FAQTABLEROW
	
	$indexHtml .= $tableRowHtml ;
}
	
my $indexHtmlEnd = <<INDEXHTMLEND ;
		</table>
	</div>
	</div>
INDEXHTMLEND

$indexHtml .= $indexHtmlEnd ;
$indexHtml .= $htmlTail ;

# Write index.html file
my $indexPath = $tempDir . "index.html" ;
my $didWriteOk = open (INDEXHTML,">$indexPath") ; 
if ($didWriteOk) {
	print INDEXHTML $indexHtml ;
	close (INDEXHTML) ;
	my $length = length($indexHtml) ;
	print "Wrote $length chars to $indexPath\n" ;
}
else {
	die "Could not open file at $indexPath" ;
}

# SSYUtils2::printMarkerAndHashRef("1000", sectionToLabelHash, \$sectionToLabelHash) ;

if (defined($serverDomain) && defined($serverPathToHelpBook)) {
	# Generate .htaccess for redirecting links to website 
	
	my $htaccessText = "" ;
	for my $secNum (sort keys %sectionToLabelHash) {
		
		$secNum =~ m/(\d\d)\.(\d\d)\.(\d\d).(\d\d)/ ;
		my $s1 = $1 ;
		my $s2 = $2 ;
		my $title = $sectionToTitleHash{$secNum} ;
		my $label = $sectionToLabelHash{$secNum} ;
	
		my $redirect = "redirect 302 /$serverPathToHelpBook$label http://$serverDomain/$serverPathToHelpBook" .  "SSYMH.$s1.$s2.html#$label\n" ;
		
		$htaccessText .= $redirect ;
	}
	
	# Write the htaccess file
	my $htaccessPath = $tempDir . $htaccessFilename ;
	$didWriteOK = open (HTACCESS,">$htaccessPath") ; 
	print HTACCESS $htaccessText ;
	close (HTACCESS) ;
	my $nChars = length($htaccessText) ;
	print "Generated htaccess file ok=$didWriteOK with $nChars chars at path:\n   $htaccessPath\n" ;
}


# Apparently, the name of the .helpindex file is supposed to be the same
# as the name of the Help Book, which is its parent directory name.
my $helpIndexFilename = SSYUtils2::lastPathComponent($outputDir) ;
# Remove trailing slash (by first adding in case there is none)
$helpIndexFilename = SSYUtils2::addTrailingSlashIfNone($helpIndexFilename) ;
$helpIndexFilename = substr($helpIndexFilename, 0, (length($helpIndexFilename) - 1)) ;
my $helpIndexPath = $tempDir . $helpIndexFilename . ".helpindex" ;

if ($doIndex) {
	print "Will index Help Book using hiutil.  This will take a minute or so.\n" ;
	print "   Source Dir: $tempDir\n" ;
	print "   Generating: $helpIndexPath\n" ;
	SSYUtils2::systemDoOrDie("/usr/bin/hiutil", "--create -av -f", "$helpIndexPath", "$tempDir") ;
	print "Indexing complete.  Will read anchors using hiutil.\n" ;
	my $indexedAnchors = `/usr/bin/hiutil --list-anchors -v -f $helpIndexPath` ;
	my $nIndexedAnchors = 0 ;
	my $didFindEndline = 1 ;
	while ($didFindEndline) {
		$didFindEndline = $indexedAnchors =~ s/\n// ;
		if ($didFindEndline) {
			$nIndexedAnchors++ ;
		}
	}
	print "$nIndexedAnchors anchors were indexed by Help Indexer (hiutil)\n" ;
}

# Sync outputDir so that it looks like tempDir.  We use the synchDirsDiff program because it leaves untouched files untouched, which reduces unnecessary uploading, as explained in documentation.
my @sysargs = ("syncdirsdiff.pl", "$tempDir", "$outputDir") ;
SSYUtils2::systemDoOrDie(@sysargs) ;

if ($nBroken) {
	print "RE-WARNING: You must re-run this program to fix $nBroken broken internal links of Type 1.  (They were printed above.)\n" ;
}

my $nBrokenType2 = scalar(@brokenInternalLinksType2) ;
if ($nBrokenType2 == 0) {
	print "   You have zero (0) Type 2 Broken internal links.  Good.\n" ;
}
else {
	print "WARNING: There are $nBrokenType2 broken links of Type 2.  If you have not already fixed them, you must search for them in the source and fix them.  In any case you must re-run this script to get them plugged in\nHere they are:\n" ;
	foreach my $brokenLink (@brokenInternalLinksType2) {
		print "    $brokenLink\n";
	}
}

if ($nBrokenAnchorsInApp) {
	print "RE-WARNING: There are $nBrokenAnchorsInApp help anchors in your app's SSYMH.AppAnchors.m file which are not defined in your Help Book.  (They were printed above.)\n" ;
}

if ($nBrokenLinksInFAQ) {
	print "RE-WARNING: There are $nBrokenLinksInFAQ links in the FAQ section of your SSYMH.00.00.markdown file which are not defined in your Help Book.  (They were printed above.)\n" ;
}

=com
Shell commands to open the products (not implemented yet):

my $helpBookPath = $tempDir . "index.html"
# Open finished Help Book in Safari:
open -b com.apple.safari $helpBookPath
# Open finished HelpBook in Help Viewer:
open -b com.apple.helpviewer $helpBookPath

# Open finished Author's Table of Contents in Safari:
open -b com.apple.safari $authorTocPath
=cut

print ("\n$programName is done.  Your new Help Book is ready for inspection here:\n   file://$outputDir" . "index.html\n") ;
print ("\nCheck above for any Parse or other errors printed in the lines following \"Will index Help Book using hiutil\".  Any such errors are caused by either failed HTML validation or failed XML validation, and will cause your Help Book to maulfunction in the app.  Todo: Invoke hiutil with IPC::Run so that this script can parse its output for errors.\n") ;
if (!$doIndex) {
	print("However, your Help Book is NOT INDEXED so DO NOT SHIP it.\n") ;
}

=com
# Index documentation
if [ -a "/usr/bin/hiutil" ]; then
  # Using hiutil on Snow Leopard
  /usr/bin/hiutil --create "$VPWebExportOutputDirectory"Help/" --file "$VPWebExportOutputDirectory"Help/Help.helpindex"
else
  # Using Help Indexer.app
  "/Developer/Applications/Utilities/Help Indexer.app/Contents/MacOS/Help Indexer" "$VPWebExportOutputDirectory"Help/"
fi
=cut

######## Subroutines ##########

sub normalizeDisplayText {
	my $s = shift ;
	# Remove html tags:
	$s =~ s/<[\/a-zA-Z]+?>//g ;
	# Make lowercase:
	return lc($s) ;
}

sub extractTitleFromMarkdownFile {
	my $title = undef ;
	my $file = shift ;
	my $ok = open (FILE, $file) ;
	if ($ok) {
		while ((my $line = <FILE>) && (!defined($title))) {
			# We're looking for the first line that begins with "# ", since this is the Markdown syntax for an <h1> tag.  The whole thing will look something like this:
			# # My Title of This Page [optionalLabel]
			my $label ; # Not used
			extractTitleAndLabelFromLine($line, \$title, \$label) ;
		}
	}
	close(FILE) ;
	return $title ;
}


sub concoctLabel {
	my $label = shift ;
	# Remove any non-word character
	$label =~ s/\W//g ;
	
	# Remove and stash the first character, making it lower case.
	my $firstChar = lc(substr($label, 0, 1)) ;
	$label = substr($label, 1) ;
	
	my $revLabel = reverse($label) ;
	my $nCut = 1 ;
	my $maxLabelBodyLength = $gMaxLabelLength - 1 ;
	while (
			(length($revLabel) > $maxLabelBodyLength)
			&&
			($nCut > 0)
		) {
		# Remove the first vowel (which is actually the last vowel of the non-reversed label)
		$nCut = $revLabel =~ s/[aeiouy]// ;
	}
	
	$label = reverse($revLabel) ;
	# In case it's still too long,
	$label = substr($label, 0, $maxLabelBodyLength) ;
	
	return $firstChar . $label ;
}

=com
There are two cases of an "incomplete" hyperlink.
Case 1: An empty href=""
Case 2: An identifier href="someIdentifier"
In Case 1, we need to look up the identifier from the display text and then look up the filename and sub-page identifier (i.e. #section) from the identifier.  In Case 2, we only need to do the latter.
In either case, all we do at this point is replace the incomplete hyperlink with our marker-ized version, and add the display text to our list of needed display texts.
=cut
sub  markAndPushIncompleteHyperlinks {
	my $stringRef = shift ;
	my $linkDisplayTextsRef = shift ;
	while ($$stringRef =~ s/href="(\w*?)"([^>]*?)>(.+?)<\/a>/$aMarkLabel$1$aMarkOtherAttributes$2$aMarkDisplayText$3<\/a>/) {
		# $1 will be the identifier, or more likely, an empty string if no label.
		#    Note that its subpattern, \w*?, will pick up legal in-book identifiers
		#    which are word characters with no spaces and no punctuation, but will
		#    ignore references which are already completed such as #onThisPage,
		#    SSYMH.12.34.html or http://apple.com/someDoc, because all of these
		#    have punctuation characters of some kind in them.
		# $2 will be any other attribute strings, but usually an empty string
		#    Note that its subpattern, [^>]*?, will pick up anything except
		#    the > which closes the tag
		# $3 is the displayText
		#    Note that its subpattern .+? will pick up anything except a newline
		my $identifier = $1 ;
		my $displayText = $3 ;

		# Only add displayText to @$linkDisplayTextsRef if we don't have an identifier.
		if (length($identifier) < 1) {
			# To reduce the number of displayText entries possibly in half, remove tags such as <em> etc., and also make it lowercase.
			$displayText = normalizeDisplayText($displayText) ;
	
			# Ignore duplicates
			my $isDupe ;
			foreach my $existingDisplayText (@$linkDisplayTextsRef) {
				if ($existingDisplayText eq $displayText) {
					$isDupe = 1 ;
					last ;
				}
			}
			
			if (!$isDupe) {
				print "   Must get URL to hyperlink \"$displayText\"\n" ;
				push @$linkDisplayTextsRef, $displayText ;
			}
		}
	}
}

sub fillMarkedHyperlinks {
	my $aLineRef = shift ;
	my $newDisplayLinkToIdentifierHashRef = shift ;
	my $labelToSectionHashRef = shift ;
	my $brokenInternalLinksType2ArrayRef = shift ;
	
	my $nReplaceAttempts = 0 ;
	my $nReplaceSuccesses = 0 ;
	while ($$aLineRef =~ m/$aMarkLabel(\w*?)$aMarkOtherAttributes(.*?)$aMarkDisplayText(.+?)<\/a>/) {
		my $identifier = $1 ;
		my $otherAttributesString = $2 ;
		my $displayText = $3 ;
		my $targetString = $aMarkLabel . $identifier . $aMarkOtherAttributes . $otherAttributesString . $aMarkDisplayText . $displayText . "<\/a>" ;
		# In the above, we backslashed the forward slash since targetString is going to be used as a search string in a s/// operation which uses forward slash as delimiter.
		if (length($identifier) < 1) {
			# Identifier was not given in source, must be looked up based on
			# the displayText.
			my $normalizedDisplayText = normalizeDisplayText($displayText) ;
			$identifier = $newDisplayLinkToIdentifierHashRef->{$normalizedDisplayText} ;
			if (!$identifier) {
				print "WARNING.  Broken internal link.  No id found for normalized display text \"$normalizedDisplayText\"\n" ;
				$identifier = $notAssigned ;
			}
		}
		
		my $filename = $$labelToSectionHashRef{$identifier} ;
		# filename is of the form "00.00.00.00".
		# We need to only keep the beginning "00.00."
		my $fileNumber = substr($filename, 0, 6) ;
		if (length($fileNumber) != 6) {
			push(@$brokenInternalLinksType2ArrayRef, $identifier) ;
			$filename = "BROKEN-LINK-TYPE-2.html" ;
		}
		else {
			$filename = "SSYMH." . $fileNumber . "html" ;
		}

		# Now watch this.  When $targetString is plugged as the search-target string in the upcoming s/// construction, any literal "(" or ")" will be mistaken for denoting a capture substring.  Therefore we must escape those: 
		$targetString =~ s/\(/\\\(/ ;  # Replaces any "(" with "\("
		$targetString =~ s/\)/\\\)/ ;  # Replaces any ")" with "\("a
		my $didReplace = $$aLineRef =~ s/$targetString/href="$filename#$identifier"$otherAttributesString>$displayText<\/a>/ ;
		if ($didReplace) {
			$nReplaceSuccesses++ ;
		}
		$nReplaceAttempts++ ;
		if ($nReplaceAttempts > 25) {
			print ("  Failed: otherAttributesString = $otherAttributesString\n") ;
			print ("  Failed: displayText = $displayText\n") ;
			print ("  Failed: identifier = $identifier\n") ;
			print ("  Failed: didReplace = $didReplace\n") ;
			print ("  Failed: nReplaceAttempts = $nReplaceAttempts\n") ;
			print ("  Failed: nReplaceSuccesses = $nReplaceSuccesses\n") ;
			print ("  Failed: targetString = $targetString\n") ;
			print ("  Failed: aLine = $$aLineRef\n") ;
			die "Too many tries ($nReplaceAttempts)" ;
		}
	}
}

=com
Given a string which is an heading in MultiMarkdown syntax, for example
## This is a Title  [someLabel]
will extract the "This is a Title" and "someLabel.
If no label is present, will concoct one by remove whitespace from title
First parm is the line of text from which to extract
Second parm is reference to title to be extracted.
Third parm is reference to label to be extracted.
Will return the given string, in MultiMarkdown syntax, with the label appended if one was concocted.
=cut
sub extractTitleAndLabelFromLine {
	my $mmdString = shift ; # MultiMarkdown String
	my $titleRef = shift ;
	my $labelRef = shift ;
	$$titleRef = undef ;
	$$labelRef = undef ;

	# Extract the label, if any
	# The label is the thing in square brackets
	my $inputHasLabel = ($mmdString =~ m/\[(\w+)\]/) ;
	if ($inputHasLabel) {
		# $1 is the last successful pattern match, i.e. (\w+),
		# i.e. the label we want.
		$$labelRef = $1 ;
	}

	# Construct the search pattern for pound signs and title.  Note the double backslashes, because we need literal backslashes in the search pattern.
	my $pattern = "(#+)\\s+(.+)\\s+" ;
	if ($inputHasLabel) {
		$pattern .= "\\[$$labelRef\\]\\s+" ;
	}

	# Extract the pound signs and title , and concoct label if none.
	my $ok = ($mmdString =~ m/$pattern/) ;
	if ($ok) {
		my $poundSigns = $1 ;
		$$titleRef = $2 ;
		# It is possible that title may have some additional text at the end of the line, for example,
		#     Earth.&#160; Earth is the third planet from the sun...
		# The demarcation between the title and the text will be a punctuation character(s) (optional) followed by some &#160; and space character(s).
		$$titleRef =~ s/(.+?)[[:punct:]]??\s?&#160;\s+(.+)/$1/ ;
		# Because the .+ subpattern must match whitespace to get multiple words, $$titleRef will now include a whitespace at the end.  Get rid of that.
		$$titleRef = SSYUtils2::trimWhitespaceTrailing($$titleRef) ;
		my $labelSeed = $$titleRef ;
		# Because Markdown ignores Markdown syntax within
		# <div> blocks, and because Markdown will undesirably
		# encode the tags in it, we must pass the title through Markdown now,
		# before enclosing it in its <div>
		$$titleRef = SSYUtils2::moveTrailingPunctuationInsideMarkdownItalics($$titleRef) ;
		$$titleRef = SSYUtils2::smartMarkdown($$titleRef, SSYUtils2::scriptParentPath()) ;
		if (!$inputHasLabel) {
			# Label must be concocted
			$$labelRef = concoctLabel($labelSeed) ;
			$mmdString = "$poundSigns $$titleRef [$$labelRef]" ;
		}
	}
	return $mmdString ;
}


