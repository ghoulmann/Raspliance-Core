#!/usr/bin/perl
require 'tklbam-lib.pl';

if ($ENV{'PATH_INFO'}) {
    $temp = transname();
    get_escrow($temp);

    @st = stat($temp);

    print "Content-Disposition: Attachment\n";
    print "Content-type: application/octet-stream\n";
    print "Content-size: $st[7]\n\n";

    open_readfile(FILE, $temp) || die "evil: $!";
    while(<FILE>) {
        print $_;
    }
    close(FILE);
    unlink($temp);

    webmin_log('escrow');
} else {
    $hostname = get_system_hostname();
    $backup_id = get_backup_id();

    $filename="$hostname";
    $filename = "$backup_id-$filename" if $backup_id;
    $filename .= ".secret";

    redirect('escrow.cgi/' . urlize($filename))
}

