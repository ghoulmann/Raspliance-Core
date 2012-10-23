#!/usr/bin/perl
require 'tklbam-lib.pl';
ReadParse();

error($text{'index_not_installed'}) unless (is_installed());
redirect("init.cgi") unless is_initialized();

#ui_print_header("<tt>".fmt_status()."</tt>", $module_info{'desc'}, "", undef, 0, 1);
ui_print_header(undef, $module_info{'desc'}, "", undef, 0, 1);

@tabs = ( [ 'backup', text('index_backup') ],
          [ 'restore', text('index_restore') ] );
print ui_tabs_start(\@tabs, 'mode', $in{'mode'} || 'backup');

print ui_tabs_start_tab('mode', 'backup');

printf '<h4>%s</h4>', fmt_status();

push(@links, "passphrase.cgi");
push(@titles, text('index_setpass'));
push(@icons, "images/passphrase.gif");

push(@links, "escrow.cgi");
push(@titles, text('index_download_escrow'));
push(@icons, "images/escrow.gif");

push(@links, "edit_conf.cgi");
push(@titles, text('index_advanced_conf'));
push(@icons, "images/conf.gif");

push(@links, "http://www.turnkeylinux.org/tklbam");
push(@titles, text('index_online_docs'));
push(@icons, "images/help.gif");

&icons_table(\@links, \@titles, \@icons, 4);

print ui_buttons_start();
print ui_buttons_row('save_cron.cgi', text('index_enable_daily'), 
                     text('index_enable_daily_desc'),
                     undef,
                     &ui_radio("enabled", get_cron_daily() ? "1" : "0",
                        [ [ 1, $text{'yes'} ],
                          [ 0, $text{'no'} ] ]));


print ui_buttons_row('backup.cgi', text('index_runbackup'), 
                     text('index_runbackup_desc'),
                     undef,
                     ui_submit(text('index_runbackup_simulate'), "simulate"));

print ui_buttons_end();

print ui_tabs_end_tab('mode', 'backup');
print ui_tabs_start_tab('mode', 'restore');

if(rollback_exists()) {
    print ui_subheading(text('index_rollback_title'));

    print "<table><tr>";
    print ui_form_start('restore_rollback.cgi', 'post');
    print "<td>";
    print text('index_rollback_timestamp', rollback_timestamp());
    print ui_submit(text('index_rollback'));
    print "</td>";
    print ui_form_end();
    print "</tr></table>";
}

print ui_subheading(text('index_list'));

$colalign = [undef, undef, undef, undef, undef, undef, 'align="center"'];

print ui_form_start('restore.cgi', 'post');
printf "<div style='text-align: right; padding-right: 5px'><a href='list_refresh.cgi'>%s</a></div>", text('index_list_refresh');

@hbrs = tklbam_list();

unless(@hbrs) {
    print '<b>'.text('index_list_nobackups').'</b>';
} else {
    print ui_columns_start( [text('index_list_id'), hlink(text('index_list_passphrase'), 'passphrase'), 
                             text('index_list_created'), text('index_list_updated'), 
                             text('index_list_size'), text('index_list_label'), 
                             text('index_list_action') ], 100, undef, $colalign);

    foreach $hbr (@hbrs) {
        my $id = $hbr->[0];
        my $skpp = lc $hbr->[1];
        print ui_columns_row([@$hbr, 
                                ui_submit(text('index_list_action_restore'),
                                          join(':', 'restore', $id, $skpp)) .
                                ui_submit(text('index_list_action_options'),
                                          join(':', 'advanced', $id, $skpp))
                                          ], $colalign);
    }

    print ui_columns_end();
}


print ui_form_end();

print ui_tabs_end_tab('mode', 'restore');

ui_print_footer('/', $text{'index'});

