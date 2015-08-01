#!/usr/bin/perl

%name = ();
%freq = (); 




$HOME=$ENV{"HOME"};
open IN,"$HOME/.tzap/channels.conf";
$spl="";
$list="";
while ($line=<IN>){
    chop($line);
    (@li)=(split /:/,$line);
##    print "$spl$li[0] frequency=$li[1] program=$li[12] ";
    $list.="$spl$li[0] frequency=$li[1] program=$li[12] ";
    $spl="-- ";
#=======================/tmp/dvb_multiplex
    $name=$li[0];
    if ($name!~/service_id/){ # i remove not correct tunes
	$prog=$li[12];
	$freq=$li[1];
	$freq=~s/000000//;
	if (! exists $name{$prog} ){ # can happen ctd_ctart as service264 @490mhz
	    $name{$prog}=$li[0];
	}
	if (! exists $freq{$prog} ){ # 1st frequency = strongest
	    $freq{$prog}=$freq;  #print "..set..$freq/$prog/$name{$prog}..";
	}
#	if (! exists $FREQ{$prog}){
	push( @{$FREQ{$prog} }, $freq."MHz" );
#	}
	# print "$prog:   $freq MHz   $name{$prog}\n";
    } # service_id make a big mass .......not correct tunes
} # while 
#print "\n";
$list.="\n";
close IN;
########################################################
#foreach $i (keys %freq) {  
#    print "PRG,FREQ $name{$i} $freq{$i}: @{$FREQ{$i}}\n";
#}
#exit;
########################################################
open OUT,">/tmp/dvb_multiplex.tmp";
   foreach $i (values %freq) {  
     print OUT "${i}MHz\n";
   }
close OUT;
`cat /tmp/dvb_multiplex.tmp | sort -n | uniq > /tmp/dvb_multiplex`;

# ###########$list=`cat /tmp/dvbstream`;
# @a=split /\-\-/, $list;
# print "\n\nALL @a\n";
# %name = ();
# %freq = ();
   
# open OUT,">/tmp/dvb_multiplex";
#    foreach $i  (@a) {
#     ($name)=($i=~/^\s*\d+\.([\w\s\/\-]+)\s*frequency/);
#      # lowecase, rem /  - 
#      $name=lc($name);
#      $name=~s/\/.*$//g;
#      $name=~s/\-/_/g;

#     ($freq)=($i=~/frequency=(\d\d\d)/);
#     ($prog)=($i=~/program=(\d+)/);
# #   print "$freq  $name \t $prog \n";
#    $freq{$freq}="";
#    $name{$prog}=$name;
#    }
#    foreach $i (keys %freq) {  # sorted previously
#      print OUT "${i}MHz\n";
#    }
# close OUT;


 #  print "=========\n";
# one thing - dvb_titles must have all mulitplexes ....not only the 1st one
open OUT,">/tmp/dvb_titles";    #   PRG and MHz
foreach $i (sort {$a <=> $b} keys %name) { 
    #print "NAME=$name{$i}($i) $freq{$i}MHz .. \n";
#    print OUT "$name{$i} $freq{$i}MHz\n";  # can be two+ frequences on row
    print OUT "$name{$i} @{$FREQ{$i}}\n";

}
close OUT;


open OUT,">/tmp/dvb_titles_progN";
foreach $i (sort {$a <=> $b} keys %name)  {
    print OUT "$name{$i} $i\n";
}
close OUT;



# name freq program
#/tmp/dvbstream



