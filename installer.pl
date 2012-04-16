#!/usr/bin/perl

use warnings;
use Time::HiRes;
# DEPENDENCIES
# Builtin
# Additional
use JSON;

my @packages = qw(libc busybox perl sed binutils m4 gawk gmp mpfr mpc gcc zlib make patch perl-compress-raw-zlib bzip2 perl-compress-raw-bzip2 xz unzip zip perl-json perl-io-compress pppkg config-minimal curses dialog kernel);

sub die_error {
	my ($text, $errcode) = @_;
	if(!defined($errcode)) {$errcode=1;}
	draw_popup($text);
	exit($errcode);
}
sub draw_appinst {
	my ($text, $prog, $height) = @_;
	if(!defined($height)) {$height=0;}
	system("dialog --gauge '".$text."' 0 0 ".int($prog)." </dev/null");
}
sub draw_popup {
	my $text = shift;
	my $tl = length($text)+4;
	system("dialog","--infobox",$text,"0","0");
}
my $pkg_len = @packages;
my $pkg_drop = 100.0/$pkg_len;
my $dir = `dialog --title "Twili Linux installer" --stdout --inputbox "Where to install Twili Linux?" 8 60`;
if($dir eq "") { die_error("Directory not specified!",1); }
draw_popup("Preparing installer...");
my $prefix = $dir . "/";
my $time = 0;
system("mkdir -p ".$prefix."etc");
system("cp files/pppkg.json ".$prefix."etc/");
draw_popup("Downloading repo...");
system("files/pppkg -P " . $prefix . " -u 2>&1 >/dev/null") == 0
	or die_error("Couldn't download repo!",2);
for(my $i=0;$i<$pkg_len;$i++) {
	draw_appinst("Installing " . $packages[$i] . "...",$i*$pkg_drop);
	open(PPPKG, "files/pppkg -P " . $prefix . " -di " . $packages[$i] . " 2>&1 |")
		or die_error("Couldn't download package " . $packages[$i] . "!",3);
	while(defined(my $info=<PPPKG>))
	{
		if($time<(Time::HiRes::time()-0.05))
		{
			my $tinfo = $info;
			$tinfo=~s/\n//;
			if(length($info)>32){
				$tinfo = substr($info,0,30) . "...";
			}
			draw_appinst("Installing " . $packages[$i] . "...\n\n".$info,$i*$pkg_drop);
			$time=Time::HiRes::time();
		}
	}
}
exit(0);
