#!/usr/bin/env perl

use strict;
use warnings;


# getting all info from community page and putting them in an array
my $current_stable_release="";
my $_current_stable_release=`curl -s https://api.github.com/repos/facebook/rocksdb/releases/latest|jq -r "select(.tag_name)|.tag_name"
` ||die "information about last rocksdb stable version have not been found on provided address\n";
if ( $_current_stable_release =~ /\D+([.\d+]*)/ )
{
	$current_stable_release=$1;
}


# https://github.com/mongodb/mongo-tools/archive/r3.6.0-rc4.tar.gz

print ("$current_stable_release\n");

if ($current_stable_release ne "")
{
	# check if the src tar.gz is available
	my $valid_tar=0;
	my $http_status="ko";
	my $archive_name="mongodb-src-r${current_stable_release}.tar.gz";
	my @tar_info=`curl -sI https://codeload.github.com/facebook/rocksdb/tar.gz/v${current_stable_release}`;

	foreach my $i (@tar_info){
		if ( $i =~ /HTTP\/1.1 200 OK/ ){$http_status="ok";}
		if ( $i =~ /Content-Type: application\/x-gzip/){$valid_tar=1;}
	}

	if ($http_status eq "ko"){die "Download URL doesn't seem to be valid\n";}
	if ( ! $valid_tar ){die "The file $archive_name on remote doesn't seem to be a valid archive\n";}
}