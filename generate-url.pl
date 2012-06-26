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
use JSON;

my ($field,$value);
my $my_filename = basename($0, '');
our($opt_u,$opt_a,$opt_s,$opt_f);
my $site = "http://*.*.*.*/client/api?"; #Pls enter your Base URL & API Path.
getopt "uasf";

if(!defined($opt_u) || !defined($opt_a) || !defined($opt_s) || !defined($opt_f)){
    die("Usage:\n$my_filename -f <flag:1.URL, 2.response ,3.both> -u \"command=<cmd>\" -a <api_key> -s <secret_key>\n");
}
my $command = $opt_u;
my $api_key = $opt_a;
my $secret_key = $opt_s;
my $flag = $opt_f;			#Flag for output:1.URL, 2.response ,3.both

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
my $output = join("&",sort @list);

#step3
my $digest = hmac_sha1($output, $secret_key);   
my $base64_encoded = encode_base64($digest);chomp($base64_encoded);
my $url_encoded = $uri->encode($base64_encoded, 1); # encode_reserved option is set to 1
my $url = $site.$command."&apikey=".$api_key."&signature=".$url_encoded;

if($flag == 1 || $flag ==3){
	print "\nGenerate URL...\n".$url."\n\n";
	if($flag == 1){
		exit;
	}
}

### get URL ###
my $mech = WWW::Mechanize->new();
$mech->get($url);

if($command =~ /response=json/){	#json
	my $obj = from_json($mech->content);
	my $json = JSON->new->pretty(1)->encode($obj);
	print $json;			
}

else{								#XML
	my $xml = encode('cp932',$mech->content);	#cp932 for Win environment(ActivePerl)
	my $twig = XML::Twig->new(pretty_print => 'indented', );
	$twig->parse($xml);
	$twig->print;
}

exit;
