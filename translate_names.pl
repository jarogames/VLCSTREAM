#!/usr/bin/perl

$FIL=shift;

open IN,"$FIL";

while ($li=<IN>){
    
    (@li)=split/:/, $li;
#    print "@li\n\n";
    $li[0]=~s/\s+//g;       # no spaces to easy html
    $li[0]=~s/\(.+?\)//g;   # no operator in parentheses
    $li[0]=~s/\//_/g;       # slash in ctd ctart
    $li[0]=~s/\-/_/g;       # minus to _ 
    $li[0]=lc($li[0]);      #lower case
    #  france: kraviny
    $name=~s/\Ô/O/g; 
    $name=~s/\é/e/g; 
    $name=~s/\'/_/g; 
    $name=~s/\>/_/g; 
    print join(":",@li) ;
#    print "$li[0]\n";

}


close IN;

