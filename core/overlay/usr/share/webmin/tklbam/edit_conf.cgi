#!/usr/bin/perl
require 'tklbam-lib.pl';
ReadParse();

ui_print_header(undef, text('conf_title'), "", undef, 0, 0);

@tabs = ( [ 'conf', text('conf_options') ],
          [ 'overrides', text('conf_overrides') ] );
print ui_tabs_start(\@tabs, 'mode', $in{'mode'} || 'conf');

# configuration options
print ui_tabs_start_tab('mode', 'conf');

$conf = conf_get();

print ui_form_start("save_conf.cgi", "post");
print ui_table_start(text('conf_options_title'), undef, 2);

print ui_table_row(hlink(text('conf_options_volsize'), "volsize"), ui_textbox("volsize", $conf->{'volsize'}, 3) . " MBs", 1);

print ui_table_row(hlink(text('conf_options_full_backup'), "full-backup"), ui_textbox("full_backup", $conf->{'full_backup'}, 3), 1);

print ui_table_end();
print ui_form_end([[undef, text('conf_options_save')]]);

print ui_tabs_end_tab('mode', 'conf');

# overrides
print ui_tabs_start_tab('mode', 'overrides');

$overrides_path = get_overrides_path();
$data = read_file_contents($overrides_path);

print ui_form_start("save_overrides.cgi", "post");
print ui_table_start(text('conf_overrides_title', $overrides_path));

print "<tr><td>";

if(profile_exists()) {
    print text('conf_overrides_profile', 'view_profile.cgi') . '<br />';
}
print ui_textarea("data", $data, 20, 80),"\n";
print "</td></tr>";

print ui_table_end();
print ui_form_end([[undef, text('conf_overrides_save')]]);

print ui_tabs_end_tab('mode', 'overrides');
print ui_tabs_end();

ui_print_footer('/', $text{'index'});
