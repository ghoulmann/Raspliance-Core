#!/usr/bin/perl
require 'tklbam-lib.pl';

sub hidden_data {
    my ($in, @skip) = @_;
    my $buf;
    foreach my $var qw(skpp id force passphrase
                       time escrow escrow_filename
                       skip_packages skip_files skip_database limits) {
        next if grep { $_ eq $var } @skip;
        $buf .= ui_hidden($var, $in->{$var}) if defined $in->{$var};
    }
    return $buf;
}

sub print_passphrase_form {
    my ($in) = @_;

    print ui_form_start('restore_run.cgi', 'form-data');

    print hidden_data($in, "passphrase");

    my $id = $in->{'id'};
    my $escrow = $in{'escrow_filename'};
    $escrow =~ s|.*/||;

    my $title = ($escrow ? 
                 text('restore_passphrase_title_escrow', $escrow) :
                 text('restore_passphrase_title', $id));

    print ui_table_start($title);
    print ui_table_row(text('restore_passphrase'), 
                       ui_password("passphrase", undef, 20));
    print ui_table_row(undef, ui_submit(text('restore_passphrase_continue')));
    print ui_table_end();

    print ui_form_end();
}

sub print_incompatible_force {
    my ($in) = @_;

    print _ui_confirmation_form('restore_run.cgi', 'form-data',
                                text('restore_incompatible'),
                                undef,
                                [ [ 'force', text('restore_incompatible_confirm') ],
                                  [ 'cancel', text('restore_incompatible_cancel') ] ], 
                                hidden_data($in));

}

ReadParse(undef, "GET");
ReadParseMime() unless $in{'id'};

redirect('?mode=restore') if $in{'cancel'};

my $id = $in{'id'};
my $skpp = $in{'skpp'};
my $passphrase = $in{'passphrase'};
my $key = $in{'escrow'};

validate_cli_args($id, $in{'time'}, $in{'limits'});

if($skpp eq 'yes' and !$passphrase and !$key) {
    my $error;
    $error = text('restore_passphrase_empty') if defined $passphrase;
    ui_print_header($error, text('restore_passphrase_required'), '', undef, 0, 0);
    print_passphrase_form(\%in);
}

if($skpp eq 'no' or ($passphrase or $key)) {
    ui_print_unbuffered_header(undef, text('restore_restoring_title', $id), "", undef, 0, 0);

    my $command = "tklbam-restore $id --noninteractive";
    my $keyfile;

    if($in{'escrow'}) {
        umask(077);
        $keyfile = transname($in{'escrow_filename'});
        write_file_contents($keyfile, $in{'escrow'});
        $command .= " --keyfile=$keyfile";
    }

    if($in{'limits'}) {
        $limits = join(" ", split(/\s+/, $in{'limits'}));
        $command .= " --limits='$limits'";
    }
    $command .= " --time='$in{'time'}'" if $in{'time'};
    $command .= " --skip-files" if $in{'skip_files'};
    $command .= " --skip-packages" if $in{'skip_packages'};
    $command .= " --skip-database" if $in{'skip_database'};

    $command .= " --force" if $in{'force'};

    my $error = htmlified_system($command, "$passphrase\n");

    # execute command
    unlink($keyfile) if $keyfile;

    if($error == 11) { # 11 is code for BADPASSPHRASE
        # show passphrase dialog
        print_passphrase_form(\%in);
        
    } elsif($error == 10) { # 10 is code for INCOMPATIBLE
        print_incompatible_force(\%in);
    } else {

        print ui_form_start('index.cgi'), ui_hidden('mode', 'restore'), ui_submit('Back'), ui_form_end();
        unlink($keyfile) if $keyfile;

        delete $in{'passphrase'};
        webmin_log('restore', $command, $in{'id'}, \%in);
    }
}

ui_print_footer('/', $text{'index'});
