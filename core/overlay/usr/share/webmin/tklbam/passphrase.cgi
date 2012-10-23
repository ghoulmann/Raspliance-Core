#!/usr/bin/perl
require 'tklbam-lib.pl';
ReadParse();

my $error;

redirect('') if $in{'cancel'};

if(defined($in{'passphrase'})) {
    if($in{'passphrase'} ne $in{'passphrase_confirm'}) {
        $error = text('passphrase_errorconfirm');
    } else {
        if($in{'passphrase'} or $in{'confirm'}) {
            eval {
                set_passphrase($in{'passphrase'});
                cache_expire('list');
                webmin_log('passphrase');
            };
            if($@) {
                my $exception = $@;
                ui_print_header(undef, text('passphrase_error'), "", undef, 0, 0);
                die $exception;
            }
            redirect('');
        } else {
            ui_print_header(undef, text('passphrase_confirm_title'), "", undef, 0, 0);
            print ui_confirmation_form('', text('passphrase_confirm_desc'), 
                [ [ "passphrase", "" ] ],
                [ [ "confirm", text('passphrase_confirm_remove') ],
                  [ "cancel",  text('passphrase_cancel') ] ], undef
                
                );

            ui_print_footer('/', $text{'index'});
            exit;
        }
    }
}

ui_print_header($error, text('passphrase_title'), "", undef, 0, 0);

print ui_form_start(undef, "post");
print ui_table_start(hlink(text('passphrase_subtitle'), 'passphrase'), undef, 2);
print ui_table_row(text('passphrase_new'), 
                   ui_password("passphrase", undef, 20));
print ui_table_row(text('passphrase_new_again'),
                   ui_password("passphrase_confirm", undef, 20));
print ui_table_row(undef, text('passphrase_emptydesc'), 2);
print ui_table_end();
print ui_form_end([['change', text('passphrase_change')],
                   ['cancel', text('passphrase_cancel')]]);

ui_print_footer('/', $text{'index'});

