#!/usr/bin/perl -w

# Original script from José Oliver Segura
# From Hex to % for signal strength by Nicolas Will, with help from GT, Feb. 1, 2008
# License unknown....
# Make sure that the tzap and channels.conf locations are correct
#
# Changes 2009-04-21
#   * moved channel.conf variable to beginning of script
#   * applied channel.conf to tzap arguments
#   * removed unused variables channelsFEC1 and channelsFEC2
#   * added ignoring of first X output lines to let tuner/decoder settle
#   * sorting output by frequency
#   * changed formating of output to be more readable
#   * added samplesPerChannel variable (used to be hard coded 10)

use strict;
use warnings;

my $tzap = "/usr/bin/tzap";
my $channelsConf = "$ENV{HOME}/.tzap/channels.conf";
my $ignoreFirstLines = 2 ; # sometimes ber/unc can be be extremely high after switching to a new channel
my $samplesPerChannel = 10 ;

my $tzapArgs = "-r -c $channelsConf";
my @channels;
my %channelsHz;
my %signalFreqAcum;
my %signalFreqCount;
my %berFreqAcum;
my %berFreqCount;
my %uncFreqAcum;
my %uncFreqCount;

sub loadChannels() {
        my $file = $channelsConf;
        open (CHANNELS,'<',$file) or die $!;
        while (<CHANNELS>) {
                chomp;
                my ($channelName,$value) = split (/:/);
		 $channelsHz{$channelName} = $value;
                push(@channels,$channelName);
        }
        close CHANNELS;
}

loadChannels();
print "Starting...\n";
foreach my $channel (@channels) {
	my $count = 0;
	my $ignore = $ignoreFirstLines;
	my $freq = $channelsHz{$channel};

	print "================================================================================";
	print "\n";
	print "Tunning channel $channel ($freq)\n";
        my $zapPid = open ZAP, "$tzap $tzapArgs \"$channel\" 2>&1 |" or die $! . ": $tzap $tzapArgs \"$channel\"";
	while ( $count < $samplesPerChannel && defined( my $line = <ZAP> )  ) {
     		chomp($line);
		if ($line =~ /FE_HAS_LOCK/) {
			if ($ignore > 0 ) {
				print "$line (Ignoring to let tuner/decoder settle.($ignore)\n";
				$ignore--;
				next;
			}
     			#print "$line\n";
			$count++;
			##
			## status 1f | signal a1ae | snr 0000 | ber 00000000 | unc 00000012 | FE_HAS_LOCK
			##
			$line =~ /.+signal (....).+ber (........).+unc (........).+/;
			my $signal = hex $1;
			my $ber = hex $2;
			my $unc = hex $3;
			$signalFreqAcum{$freq} += $signal;
			$signalFreqCount{$freq}++;
			$berFreqAcum{$freq} += $ber;
			$berFreqCount{$freq}++;
			$uncFreqAcum{$freq} += $unc;
			$uncFreqCount{$freq}++;
			print join("\t","Signal: ".int($signal/65536*100)."%","BER ".$ber,"UNC ".$unc),"\n";
		} else {
			print "$line\n";
		}
   	}
	close ZAP;
	print "\n";
}

print "Summary statistics:\n";
print "Signal\tFrequency  \tBer     \tUnc\n";
print "=========\t========\t========\t========\n";

# $qual{$freq}=$signalFreqAcum{$freq}/$signalFreqCount{$freq}/65536*100;

`rm $ENV{"HOME"}/.tzap/sorted`;
open OUT,">$ARGV[0]";
foreach my $freq (sort{$signalFreqAcum{$b}/$signalFreqCount{$b}<=>$signalFreqAcum{$a}/$signalFreqCount{$a}} keys(%signalFreqAcum)) {
	print OUT "$freq Hz\t";
	printf OUT "%6.1f %%\t",$signalFreqAcum{$freq}/$signalFreqCount{$freq}/65536*100;
	printf OUT "%8.1f",$berFreqAcum{$freq}/$berFreqCount{$freq};
	print OUT "\t";
	printf OUT "%8.1f",$uncFreqAcum{$freq}/$uncFreqCount{$freq};
	print OUT "\n";
	`cat $ENV{"HOME"}/.tzap/channels.conf | grep $freq >> $ENV{"HOME"}/.tzap/channels.conf_sorted`;
}
close OUT;
############# here I want to sort channels.conf

print `mv $ENV{"HOME"}/.tzap/channels.conf_sorted $ENV{"HOME"}/.tzap/channels.conf`;
print `ls $ENV{"HOME"}/.tzap/channels.conf`;
