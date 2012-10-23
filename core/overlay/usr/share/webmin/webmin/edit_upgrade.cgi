#!/usr/bin/perl

require './webmin-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'upgrade_title'}, "");

print "<p>Webmin and its modules are installed and upgraded via APT.</p>";

&ui_print_footer("", $text{'index_return'});
