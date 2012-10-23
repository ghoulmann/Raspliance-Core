#!/usr/bin/perl
require 'tklbam-lib.pl';

cache_expire('list');
redirect('?mode=restore');
