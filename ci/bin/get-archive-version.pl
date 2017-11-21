#!/usr/bin/env perl

use strict;
use warnings;

if ( $ARGV[0] eq "" ){
	die "You have to provide an archive";
}

my $archive=$ARGV[0];

my $result="";
if ( $archive =~ /(\d+.\d+.\d+).tar.gz/ ){
	$result=$1;
}

print ("$result\n");