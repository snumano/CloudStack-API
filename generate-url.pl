#!/usr/local/bin/perl -w

# created by snumano 2011/07/30
# revised by snumano 2011/08/01

use strict;
use warnings;
use Digest::SHA qw(hmac_sha1);
use Getopt::Std;
use File::Basename qw(basename);
use MIME::Base64;
#use WWW::Mechanize;

my $output;
my $command_encoded;
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
my @command = split(/&/,$command);
foreach (@command){
    if(/(.+)\s*=\s*(.+)/){
        my $key = $1;
        my $val = $2;
        $val = url_encode($val);
        $val =~ s/\+/%20/g;
        $_ = $key."=".$val;

        if(defined($command_encoded)){
            $command_encoded .= "&".$_;
        }
        else{
            $command_encoded = $_;
        }
    }
}

my $query = $command_encoded."&apiKey=".$api_key;

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


=pod
# get URL
my $mech = WWW::Mechanize->new();
$mech->get( $url );
print $mech->content;
=cut

exit;


sub url_encode {
    my $str = shift;
    $str =~ s/([^\w ])/'%'.unpack('H2', $1)/eg;
    $str =~ tr/ /+/;
    return $str;
}