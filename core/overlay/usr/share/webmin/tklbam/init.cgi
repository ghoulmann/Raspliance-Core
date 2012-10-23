#!/usr/bin/perl

require 'tklbam-lib.pl';
ReadParse();

redirect('') if is_initialized();

my $init_error = undef;

validate_cli_args($in{'apikey'});

if($in{'apikey'}) {
    eval {
        tklbam_init($in{'apikey'});
        webmin_log('init');
        redirect('');
    };
    if ($@) {
        $init_error = $@;
    }
}

ui_print_header(undef, text('init_title'), "", undef, 0, 1);

print ui_subheading(text('init_apikey_title'));

print "<p>" . text('init_apikey_desc'). "</p>";

print ui_form_start(undef, 'post');

print "<b>".text('init_apikey').": </b>", ui_textbox("apikey", $in{'apikey'}, 20);
print ui_submit(text('init_button'));

print ui_form_end();

if($init_error) {
    $init_error =~ s/^(\w)/uc $1/e;
    print "<b><pre>$init_error</pre></b>";
} else {
    print '<br />';
    print text("init_about_tklbam");
}

ui_print_footer('/', $text{'index'});
