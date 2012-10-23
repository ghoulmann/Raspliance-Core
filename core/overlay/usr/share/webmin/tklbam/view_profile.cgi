#!/usr/bin/perl
require 'tklbam-lib.pl';
ReadParse();


$profile_path = profile_path();
ui_print_header(text('profile_subtitle', $profile_path), text('profile_title'), "", undef, 0, 0);

$data = read_file_contents($profile_path);

print ui_textarea("data", $data, 20, 80, undef, 1);
print ui_form_start('edit_conf.cgi'), ui_hidden('mode', 'overrides'), ui_submit("Back"), ui_form_end();

ui_print_footer('/', $text{'index'});

