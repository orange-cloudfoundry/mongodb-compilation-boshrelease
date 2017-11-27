#!/usr/bin/env perl

use strict;
use warnings;

if ( $ARGV[0] ne "-p" && $ARGV[0] ne "-v" ){
	die "you have to specify what information you want\n\t-p(ipeline)\n\t-v(ersion)\n";
}

if ( $ARGV[1] eq "" ){
	die "you have to specify an archive name\n"
}

my $archive=$ARGV[1];

my $version="";
my $prefix="";
if ( $archive =~ /(^.*)(\d+.\d+.\d+).tar.gz/ ){
	$prefix=$1;
	$version=$2;
}
if ( $ARGV[0] eq "-p"){
	print ("$prefix\n");
}else{
	print ("$version\n");
}