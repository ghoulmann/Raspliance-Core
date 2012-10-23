#!/usr/bin/perl
# Save some edited file

require './text-editor-lib.pl';
&ReadParseMime();
&error_setup($text{'save_err'});

&open_lock_tempfile(FILE, ">$in{'file'}") || &error($!);
$in{'data'} =~ s/\r//g;
if ($in{'dos'}) {
	$in{'data'} =~ s/\n/\r\n/g;
	}
&print_tempfile(FILE, $in{'data'});
&close_tempfile(FILE);

@files = &list_files();
push(@files, $in{'file'});
&save_files(&unique(@files));
&webmin_log("save", "file", $in{'file'});

&redirect("index.cgi?file=".&urlize($in{'file'}));

