#!/usr/bin/perl

$IN="$ARGV[0]";
open IN,"$IN";
print "----------------------------------------------------\n";
while (<IN>){
    if ( (/case .+ in/) || (/;;/) ){
 	do {$a=<IN>; chop($a);}until(  ($a=~/esac/)||($a=~/\)/) );
#### until esac and no show   *)
	if ( ($a!~/esac/)  &&  ($a!~/\s*\*/) ){
	($opt,$comment)=($a=~/(.+)\s+#\s+(.+)/);
	$opt=~s/^\s+//;
	$opt=~s/\)//;
	printf "  %-20s ... %s\n",$opt,$comment;
	} # no # means no comment
    }
    if (/esac/){break;}
}
close IN;
