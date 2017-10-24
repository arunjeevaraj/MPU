#!/usr/bin/perl -w
use strict;

my $orig_sdf = "./netlists/top_synth.sdf";
my $sdf_fixed = "./netlists/top_synth.fixed.sdf";
my $i_orig = "";

# Open elc_lib & elc_lib_fixed and replace area in
open(orig_file,$orig_sdf)
  or die "Failed to open file: ${orig_sdf} $!\n";
open(sdf_fixed,"> ${sdf_fixed}")
  or die "Failed to open file: ${sdf_fixed} $!\n";

while(defined(my $i = <orig_file>)) {

    $i =~ s/\(REMOVAL \(posedge /\(HOLD \(posedge /g;
    $i =~ s/\(IOPATH ((S|R)B) Q/\(IOPATH \(negedge $1\) Q/g;
    $i =~ s/\(PERIOD \(posedge CK\)/\(PERIOD CK/g;
    $i =~ s/^[ \t]*\(PERIOD \(negedge CK\).*//g;
    $i =~ s/([ ]*)\(HOLD ([A-Z0-9]+) \(posedge CK\)(.*)/$1\(HOLD \(posedge $2\) \(posedge CK\)$3\n$1\(HOLD \(negedge $2\) \(posedge CK\)$3/g; 
	$i =~ s/([ ]*)\(SETUP ([A-Z0-9]+) \(posedge CK\)(.*)/$1\(SETUP \(posedge $2\) \(posedge CK\)$3\n$1\(SETUP \(negedge $2\) \(posedge CK\)$3/g; 
 
    print sdf_fixed $i;
    
    

}

close(orig_file);
close(sdf_fixed)
  or die "Error while closing file '${sdf_fixed}': $! \n";

