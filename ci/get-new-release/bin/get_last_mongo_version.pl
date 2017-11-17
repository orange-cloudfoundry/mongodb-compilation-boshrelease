#!/usr/bin/env perl

use strict;
use warnings;

my $current_stable_release="";
my $valid_tar=0;
my $http_status="ko";

# getting all info from community page and putting them in an array
my @rel=`curl -s -L  https://www.mongodb.com/download-center`;

foreach my $i (@rel){
	# searching for version in array
	if ( $i =~ /Current Stable Release \((\d+.\d+.\d+)\)/ )
	{
		$current_stable_release = $1;
	}
}

if ($current_stable_release eq "")
	{die "information about last Mongodb stable version have not been found on provided address\n"}

print ("$current_stable_release\n");

# check if the src tar.gz is available
my $archive_name="mongodb-src-r${current_stable_release}.tar.gz";
my @tar_info=`curl -sI https://fastdl.mongodb.org/src/$archive_name`;

foreach my $i (@tar_info){
	if ( $i =~ /HTTP\/1.1 200 OK/ ){$http_status="ok";}
	if ( $i =~ /Content-Type: application\/x-gzip/){$valid_tar=1;}
}

if ($http_status eq "ko"){die "Download URL doesn't seem to be valid\n";}
if ( ! $valid_tar ){die "The file $archive_name on remote doesn't seem to be a valid archive\n";}
