#!/usr/bin/perl
################################
#
# one problem - in help it makes one \n more in exported
#
################################
$INITPERL="#!/usr/bin/env perl";


$OUT="$ARGV[0].exported";
$PLFUNC=0;

open IN,"$ARGV[0]";
while ($line=<IN>){
 if (  $line!~/^\s*#/ ){
  if( $line=~/^\s*perl /){
      ($what)=($line=~/^\s*perl\s+(.+?)\s/);
      ($xxx,$params)=($line=~/^\s*perl\s+(.+?)\s+(.+)/);
      $whatF=$what;
      $whatF=~s/\./_/;  # remove .pl
      $perlfunc{$what}="### including $what PERL CODE##################################\n
function $whatF {
perl - \$1 \$2 \$3 \$4 \$5 \$6 \$7 \$8 \$9<< 'EOF'
$INITPERL\n";
      open SRC,"$what"; while (<SRC>){if ($_!~/^#/){$perlfunc{$what}.=$_;}}close SRC;
      $perlfunc{$what}.="\nEOF\n}\n";
      $perlfunc{$what}.="### end of include $what PERL CODE#############################\n\n";
   }
 }
} #while
close IN;

#foreach $j (keys %perlfunc){
#    print "key :$j\n";
#    print $perlfunc{$j};
#}
#exit;
$LNUM=0;
open IN,"$ARGV[0]";
open OUT,">$OUT";
while ($line=<IN>){
    $LNUM+=1;
 if (  $line!~/^\s*#/ ){
   if ( $line=~/^\s*source /){
    ($what)=($line=~/^\s*source\s+(.+)/);
    print OUT "### including $what ##################################\n";
    open SRC,"$what"; while (<SRC>){if ($_!~/^#/){print OUT;}}close SRC;
    print OUT "### end of include $what #############################\n\n";
   }elsif( $line=~/^\s*perl /){
      ($what)=($line=~/^\s*perl\s+(.+?)\s/);
      ($xxx,$params)=($line=~/^\s*perl\s+(.+?)\s+(.+)/);
      $whatF=$what;
      $whatF=~s/\./_/;  # remove .pl

      print OUT "###        call of $what CODE#############################\n";
      print OUT "$whatF $params\n";
      print OUT "### end of call of $what CODE#############################\n";
      $PLFUNC=$PLFUNC+1;
   }else{
    print OUT $line;
   }
 }else{
  print OUT "$line";
  if ($LNUM==1){foreach $j (keys %perlfunc){print OUT $perlfunc{$j};} }
 }
} #while
close IN;
close OUT;
print `chmod +x $OUT; ls -l $OUT`;
