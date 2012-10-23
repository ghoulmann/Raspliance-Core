#!/usr/bin/perl
require 'tklbam-lib.pl';

ReadParse();
error_setup("Conf save error");

if($in{'volsize'} !~ /^\d+$/) {
    error("invalid volume size '$in{'volsize'}'");
}

if($in{'full_backup'} !~ /^\d+[MWD]$/) {
    error("invalid full backup frequency '$in{'full_backup'}'");
}

conf_set({'volsize' => $in{'volsize'},
         'full_backup' => $in{'full_backup'}});

redirect('edit_conf.cgi');

webmin_log('save', 'conf', undef, \%in);
