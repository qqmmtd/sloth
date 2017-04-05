#!/usr/bin/perl

# add a file to tar

use strict;
use Archive::Tar;
use Getopt::Long;

## AMSS uses a GNU head, but not POSIX header.
$Archive::Tar::DO_NOT_USE_PREFIX = 1;

my $oTar = Archive::Tar->new();
my $sTar;
my $sPath;

my %options = (
    "tar" => \$sTar,
    "path" => \$sPath,
);

GetOptions(\%options, "tar=s", "path=s");

printf("%s+=%s\n", $sTar, $sPath);

if (defined($sTar) && defined($sPath)) {
    $oTar->read($sTar);
    my ($sFile, $sPathInTar) = split(/[:\n\r]/, $sPath);

    die "can't open input file $sFile" if !open(FILE,"<$sFile");
    ## get file size.
    my @args = stat($sFile);
    my $uiFize = $args[7];

    ## read all data.
    my $sFileData;
    read(FILE, $sFileData, $uiFize); 
    close(FILE);

    $oTar->add_data($sPathInTar, $sFileData);
    $oTar->write($sTar);
} else {
    printf("$0 --tar name.tar --path file/path:file/path/in/tar");
}

