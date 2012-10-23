#!/usr/bin/perl
require 'tklbam-lib.pl';

ReadParse();
set_cron_daily($in{'enabled'});
redirect('');

webmin_log('save', 'cron', $in{'enabled'} ? 'enabled' : 'disabled', \%in);
