#!/usr/bin/perl -w

# by snumano

use strict;
use warnings;
use Digest::SHA qw(hmac_sha1);
use Getopt::Std;
use File::Basename qw(basename);
use MIME::Base64;
use WWW::Mechanize;
use Encode;
use XML::Twig;
use URI::Encode;

my $output;
my ($field,$value);

my $my_filename = basename($0, '');
our($opt_u,$opt_a,$opt_s);
my $site = "http://*.*.*.*/client/api?"; # Pls change your Base URL & API Path
getopt "uas";

if(!defined($opt_u) || !defined($opt_a) || !defined($opt_s)){
    die("Usage:$my_filename -u \"command=<command>\" -a <api_key> -s <secret_key>\n");
}
my $command = $opt_u;
my $api_key = $opt_a;
my $secret_key = $opt_s;

my $uri = URI::Encode->new();

### Generate URL ###
#step1

my $query = $command."&apiKey=".$api_key;
my @list = split(/&/,$query);
foreach  (@list){
	if(/(.+)\=(.+)/){
		$field = $1;
		$value = $uri->encode($2, 1); # encode_reserved option is set to 1
		$_ = $field."=".$value;
	}
}

#step2
foreach  (@list){
	$_ = lc($_);
}
$output = join("&",sort @list);

#step3
my $digest = hmac_sha1($output, $secret_key);   
my $base64_encoded = encode_base64($digest);chomp($base64_encoded);
my $url_encoded = $uri->encode($base64_encoded, 1); # encode_reserved option is set to 1
my $url = $site."apikey=".$api_key."&".$command."&signature=".$url_encoded;

print "\nGenerate URL...\n".$url."\n\n";    


### get URL ###
my $mech = WWW::Mechanize->new();
$mech->get($url);
my $xml = encode('cp932',$mech->content);

my $twig = XML::Twig->new(pretty_print => 'indented', );
$twig->parse($xml);
$twig->print;

exit;
