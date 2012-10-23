#!/usr/bin/perl
require 'tklbam-lib.pl';

ReadParse();

$overrides_path = get_overrides_path();
write_file_contents($overrides_path, $in{'data'});

redirect('edit_conf.cgi?mode=overrides');

webmin_log('save', 'overrides', undef, \%in);
