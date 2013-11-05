#!/usr/bin/perl

use strict ;
use warnings ;

my $usage = "Usage is:\n   obfuscate.pl inPath outPath\nobfuscate.pl will read a file containing public key from file inPath, and produce at outPath a file containing a C-language #define definition for OBFUSCATED_PUBLIC_KEY.  That code defined OBFUSCATED_PUBLIC_KEY reconstructs an obfuscated version of the input public key into a nonretained NSData* publicKey.\n\nAlthough it is treated as binary data, inPath is typically a .pem file which includes the -----BEGIN PUBLIC KEY----- and -----END PUBLIC KEY----- headers and trailers.\n\noutfile is typically named ObfuscationCode.h and is #imported into the file which needs the public key to crunch the numbers.\n\nEach byte is encrypted independently using:\n   byteOut = (byteIn + k*slope + offset) % 0x100\n      where k = byte index and first byte has k=0\nEach time obfuscate.pl is run, a different pair of random values are assigned to slope and offset.\n\nTo use the product ObfuscationCode.h, include it in your app's Xcode project, and place the macro OBFUSCATED_PUBLIC_KEY in the function at the place where you need to define and assign NSData* publicKey.\n\nTip: If you run this script before you build each Release, each Release will be ofuscated with different values of slope and offset.\n" ;


my ($in, $out) = @ARGV;
die $usage unless $in;
die $usage unless $out;


my $payloadLen   =  451 ;
my $dataLen      = 1127 ;
my $locSlope     =  935 ;
my $locOffset    =  665 ;
my $locStartAt =  288 ;
my $locJumpH     =  598 ;
my $locJumpL     =  893 ;
my $maxJump      =  563 ;


my @dataOut ;
for (my $i=0; $i<$dataLen; $i++) {
	push (@dataOut, 0) ;
}

my $slope = randByte() ;
my $offset = randByte() ;
my $startAt = randByte() ;
my $jumpH = randByte() ;
my $jumpL = randByte() ;

print "Generated random parameters:\n" ;
print "     slope = $slope\n" ;
print "    offset = $offset\n" ;
print "   startAt = $startAt\n" ;
print "     jumpH = $jumpH\n" ;
print "     jumpL = $jumpL\n" ;

$dataOut[$locSlope] = $slope ;
$dataOut[$locOffset] = $offset ;
$dataOut[$locStartAt] = $startAt ;
$dataOut[$locJumpH] = $jumpH ;
$dataOut[$locJumpL] = $jumpL ;

my $jump = (0x100 * $jumpH + $jumpL) % $maxJump ;

print "Composited jump = $jump\n" ;


my @usedBytes = ($locSlope, $locOffset, $locStartAt, $locJumpH, $locJumpL) ;

my $currIn = 0 ;
my $currOut = $startAt ;
open(my $IN, "< $in") ;
binmode($IN) ;
while (read($IN,my $byteIn,1)) {
	my $ordIn = ord($byteIn) ;
	my $encodedByte = ($ordIn + $currIn*$slope + $offset) % 0x100 ;
	#my $charOut = chr($byteOut) ;
	$dataOut[$currOut] = $encodedByte ;
	my $charIn = $byteIn ;
	if (ord($charIn) == 10) {
		# It's a newline
		$charIn = "<LF>" ;
	}
	print "char=$charIn($ordIn) encoded to $encodedByte, written at byte $currOut\n" ;
	push (@usedBytes, $currOut) ;
	my $infiniteLoopBreaker = 0 ;
	while (isMember(\@usedBytes, $currOut)) {
		# 99.96% of the time, this loop executes only once.
		# 80% of program runs, this loop executes only once for all $byteIn
		$currOut = ($currOut + $jump + $infiniteLoopBreaker) % $dataLen ;
		$infiniteLoopBreaker++ ;
	}
	$currIn++ ;
}
close ($IN) ;

open(my $OUT, '>:raw', $out) or die "Could not open $out: $!" ;
# In the above, ':raw' is equivalent to using binmode

foreach my $byteOut (@dataOut) {
	print $OUT pack('C', $byteOut) ;
	# 'C' is a format string which says to output (non-ASCII) bytes
	# (Note that 'c' says to output ASCII bytes and prints a warning if $byteOut > 127)
}

close($OUT) ;

print "Obfuscated key has been written to $out\n" ;

sub randByte {
    return int(rand(247)) + 0x9
}

sub isMember {
	my $arrayRef = shift ;
	my $value = shift ;
	my $answer = ($value ~~ @$arrayRef) ;
	# ~~ is a neat trick!  See http://blogs.perl.org/users/mascip/2013/05/the-clearest-ways-to-check-if-a-list-contains.html
return $answer ;
}
