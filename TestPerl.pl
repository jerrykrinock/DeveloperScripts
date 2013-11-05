#!/usr/bin/perl


use strict ;

use File::Spec ;
use File::Temp ;
use IPC::Run ;
use Storable ;
use File::Util ;

# Sometimes this is necessary for modules in this directory to be found at compile time when running on my Mac:
use lib '/Users/jk/Documents/Programming/Scripts' ;

use SSYUtils2 ;

SSYUtils2::testPreMarkdown ;

