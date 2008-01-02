#!/usr/bin/perl5

use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use HTTP::Cookies;
$ua = LWP::UserAgent->new;
$ua->timeout(10);
##$ua->proxy(['http'],'http://proxy03.fm.intel.com:911');

if (-e "/tmp/cookies.txt") { unlink "/tmp/cookies.txt"; } $ua->cookie_jar(HTTP::Cookies->new(file => "/tmp/cookies.txt", autosave => 1));


my %opt1 = ( username => "debr5836",
             password => "fractals",
	     login    => "Log in" );

my $resp = $ua->post("http://82.165.251.152/forum/login.php",\%opt1);
my $str = $resp->as_string();

my %opt2 = ( mode    => "reply",
	     t       => 11681 );
$resp = $ua->post("http://82.165.251.152/forum/posting.php",\%opt2);
$str = $resp->as_string();
$str =~ /sid=([0-9a-f]+)/; my $sid = $1;

my %opt3 = ( subject => "this is a test",
             message => "Im testing my phpspammer.  JCirri says this is OK.  I'm not exacly an U63r H4xx0r.",
	     mode    => "reply",
	     t       => 11681,
	     sid     => $sid,
	     post    => "submit" );
$resp = $ua->post("http://82.165.251.152/forum/posting.php",\%opt3);
$str = $resp->as_string();
print "$str\n";

