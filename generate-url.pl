#!/usr/bin/perl -w

# by snumano 2011/07/30

use strict;
use warnings;
use Digest::SHA qw(hmac_sha1);
use Getopt::Std;
use File::Basename qw(basename);
use MIME::Base64;

my $output;
my $my_filename = basename($0, '');
our($opt_u,$opt_a,$opt_s);
my $site = "http://x.x.x.x:8080/client/api?"; #Pls enter proper URL
getopt "uas";

if(!defined($opt_u) || !defined($opt_a) || !defined($opt_s)){
    die("Usage:$my_filename -u \"command=<command>\" -a <api_key> -s <secret_key>\n");
}
my $command = $opt_u;
my $api_key = $opt_a;
my $secret_key = $opt_s;


# Create URL

#step1
my $api_key_encoded = $api_key;
my $query = $command."&apiKey=".$api_key_encoded;

#step2
$query = lc($query);
my @list = split(/&/,$query);
foreach  (sort @list){
    if(defined($output)){
	$output = $output."&".$_;
    }
    else{
	$output = $_;
    }
}
$output =~ s/^\&(.*)$/$1/;

print "OUTPUT:".$output."\n";    

#step3
my $digest = hmac_sha1($output, $secret_key);
print "DIGEST:".$digest."\n";    

my $base64_encoded = encode_base64($digest);
chomp($base64_encoded);
print "BASE64 ENCODED:".$base64_encoded."\n";    

my $url_encoded = &url_encode($base64_encoded);
print "URL ENCODED:".$url_encoded."\n";    

my $url = $site."apikey=".$api_key."&".$command."&signature=".$url_encoded;
print "URL:".$url."\n";    

exit;


sub url_encode {
    my $str = shift;
    $str =~ s/([^\w ])/'%'.unpack('H2', $1)/eg;
    $str =~ tr/ /+/;
    return $str;
}
