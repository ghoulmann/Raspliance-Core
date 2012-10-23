#!/usr/bin/perl
require 'tklbam-lib.pl';

ReadParse();

redirect('?mode=restore') if $in{'cancel'};

unless($in{'confirmed'}) {
    
    ui_print_header(undef, "Confirm Rollback", "", undef, 0, 0);

    print ui_confirmation_form('', text('rollback_warning', rollback_timestamp()),
    
        undef,
        [ [ 'confirmed', text('rollback_confirm') ],
          [ 'cancel',  text('rollback_cancel') ] ], undef
        
        );

    ui_print_footer('/', $text{'index'});
    exit;

}

$timestamp = rollback_timestamp();
$command = "tklbam-restore-rollback --force";
ui_print_unbuffered_header(undef, text('rollback_title'), "", undef, 0, 0);
$error = htmlified_system($command);
if(!$error) {
    print text('rollback_summary', $timestamp) . '<br />';
}
print ui_form_start('index.cgi'), ui_hidden('mode', 'restore'), ui_submit('Back'), ui_form_end();
ui_print_footer('/', $text{'index'});

webmin_log('restore_rollback');
