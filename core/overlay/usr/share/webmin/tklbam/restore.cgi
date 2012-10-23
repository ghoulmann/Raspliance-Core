#!/usr/bin/perl
require 'tklbam-lib.pl';

ReadParse();

@vals = keys %in;
die unless @vals;

my ($op, $id, $skpp) = split(/:/, $vals[0], 3);

validate_cli_args($id);

if($op eq 'advanced') {
    ui_print_header(undef, text('restore_title'), "", undef, 0, 0);

    $hbr = tklbam_list($id);
    my ($id, $skpp, $created, $updated, $size, $label) = @$hbr;

    print ui_form_start('restore_run.cgi', 'form-data');
    print ui_hidden('id', $id), ui_hidden('skpp', lc($skpp));
    print ui_table_start(text('restore_title_options', $id, $label, $size), 'width=100%', 4);

    print ui_table_row(hlink(text('restore_timeago'), 'timeago'),
                       ui_textbox('time', '', 30), undef, ["align=right"]);
    print ui_table_row(hlink(text('restore_escrow'), 'escrow'),
    ui_upload('escrow', 25), undef, ['align=right']);

    print ui_table_row(hlink(text('restore_skip'), 'skip'), 
                       ui_checkbox('skip_packages', 1, text('restore_skip_packages')) . '<br />' .
                       ui_checkbox('skip_files', 1, text('restore_skip_files')) . '<br />' .
                       ui_checkbox('skip_database', 1, text('restore_skip_database')), 
                       undef, ["align=right"]);

    print ui_table_row(hlink(text('restore_limits'), 'limits'),
                       ui_textarea('limits', "", 3, 25), undef, ["align=right"]);

    print ui_table_end();

    print ui_form_end([[undef, text('restore_run')]]);
} elsif($op eq 'restore') {
    redirect("restore_run.cgi?id=$id&skpp=$skpp");
} else {
    error("Unsupported operation");
}

ui_print_footer('/', $text{'index'});
