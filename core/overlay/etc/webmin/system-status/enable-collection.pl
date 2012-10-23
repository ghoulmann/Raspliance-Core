#!/usr/bin/perl
open(CONF, "/etc/webmin/miniserv.conf");
while(<CONF>) {
        $root = $1 if (/^root=(.*)/);
        }
close(CONF);
$ENV{'PERLLIB'} = "$root";
$ENV{'WEBMIN_CONFIG'} = "/etc/webmin";
$ENV{'WEBMIN_VAR'} = "/var/webmin";
chdir("$root/system-status");
exec("$root/system-status/enable-collection.pl", @ARGV) || die "Failed to run $root/system-status/enable-collection.pl : $!";
