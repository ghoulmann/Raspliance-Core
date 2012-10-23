BEGIN { push(@INC, ".."); };

use WebminCore;
use POSIX qw(:termios_h);

init_config();

use constant STATUS_OK => 0;
use constant STATUS_NO_BACKUP => 10;
use constant STATUS_NO_APIKEY => 11;

use constant PATH_CRON_DAILY => "/etc/cron.daily/tklbam-backup";

use constant PATH_TKLBAM_CONF => '/etc/tklbam/conf';
use constant PATH_TKLBAM_OVERRIDES => "/etc/tklbam/overrides";
use constant PATH_TKLBAM_PROFILE => "/var/lib/tklbam/profile/dirindex.conf";

use constant PATH_TKLBAM_ROLLBACK => '/var/backups/tklbam-rollback';

use constant DEFAULT_CACHE_LIST_TTL => 300;

sub write_file_contents {
    my ($path, $buf) = @_;
    open(FH, ">" . $path)
        or die "open: $!";
    print FH $buf;
    close FH;
}

sub is_installed {
    return has_command("tklbam");
}

sub is_initialized {
    my ($exitcode, undef) = tklbam_status();
    
    if ($exitcode == STATUS_OK || $exitcode == STATUS_NO_BACKUP) {
        return 1;
    } elsif ($exitcode == STATUS_NO_APIKEY) {
        return 0;
    }
}

sub fmt_status {
    my ($exitcode, $output) = tklbam_status();
    if ($exitcode == STATUS_NO_APIKEY) {
        return "NOT INITIALIZED";
    } elsif ($exitcode == STATUS_NO_BACKUP) {
        return "No backups have yet been created.";
    } else {
        chomp $output;
        $output =~ s/.*?:\s+//;
        return $output;
    }
}

sub tklbam_status {
    my $output = backquote_command("tklbam-status --short");
    my $exitcode = $?;
    $exitcode = $exitcode >> 8 if $exitcode != 0;

    die "couldn't execute tklbam-status: $!" unless defined $output;

    return ($exitcode, $output)
}

sub tklbam_init {
    my ($apikey) = @_;
    my $output = backquote_command("tklbam-init $apikey 2>&1");
    die $output if $? != 0;
}

sub get_cron_daily {
    return (-x PATH_CRON_DAILY);
}

sub set_cron_daily {
    my ($flag) = @_;
    if ($flag) {
        unless (-e PATH_CRON_DAILY) {
            open(FH, ">" . PATH_CRON_DAILY) 
                or die "can't open file: " . PATH_CRON_DAILY;

            print FH "#!/bin/sh\n";
            print FH "tklbam-backup --quiet\n";
            close FH;
        }
        chmod 0755, PATH_CRON_DAILY;
    } else {
        chmod 0644, PATH_CRON_DAILY;
    }
}

sub get_overrides_path {
    return PATH_TKLBAM_OVERRIDES;
}

sub set_passphrase {
    my ($passphrase) = @_;
    my $output;
    my $error;

    $passphrase = "$passphrase\n";
    my $retval = execute_command("tklbam-passphrase", \$passphrase, \$output, \$error);
    die "tklbam-passphrase error: $error" if $retval != 0;
}

sub get_escrow {
    my ($path) = @_;
    my $error;
    $retval = execute_command("tklbam-escrow --no-passphrase $path", undef, undef, \$error);
    die "tklbam-escrow error: $error" if $retval != 0;
}

sub get_backup_id {
    my ($exitcode, $output) = tklbam_status();
    return unless ($exitcode == STATUS_OK);

    if($output =~ /Backup ID #(.*?),/) {
        return $1;
    }
}


sub _conf_read {
    return read_file_contents(PATH_TKLBAM_CONF);
}

sub _conf_write {
    my ($buf) = @_;
    return write_file_contents(PATH_TKLBAM_CONF, $buf);
}

sub _conf_parse {
    my ($conf) = @_;
    my @lines = split(/\n/, $conf);
    my %conf;
    foreach my $line (@lines) {
        $line =~ s/#.*//;
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;
        next if($line eq '');

        my ($key, $val) = split(/\s+/, $line);
        $key =~ s/-/_/g;
        $conf{$key} = $val;
    }
    return \%conf;
}

sub _conf_update_option {
    my ($conf, $key, $val) = @_;
    $key =~ s/_/-/g;
    unless($conf =~ s/^(\s*$key\s+).*/\1$val/gm) {
        $conf .= "\n$key $val\n";
    }
    return $conf;
}

sub _conf_format {
    my ($conf, $parsed) = @_;
    foreach my $key (keys %$parsed) {
        $conf = _conf_update_option($conf, $key, $parsed->{$key});
    }
    return $conf;
}

sub conf_get {
    return _conf_parse(_conf_read());
}

sub conf_set {
    my ($options) = @_;
    my $orig;
    eval {
        $orig = _conf_read();
    };
    if($@) {
        $orig = "";
    }
    _conf_write(_conf_format($orig, $options));
}

sub profile_exists {
    return (-e PATH_TKLBAM_PROFILE);
}

sub profile_path {
    return PATH_TKLBAM_PROFILE;
}

sub rollback_exists {
    return 1 if -d PATH_TKLBAM_ROLLBACK;
}

sub rollback_timestamp {
    my @st = stat(PATH_TKLBAM_ROLLBACK);
    return scalar(localtime($st[10]));
}

sub term_set_noecho {
    my ($fh) = @_;

    my $term = POSIX::Termios->new();
    $term->getattr(fileno($fh));
    my $oterm = $term->getlflag();
    my $echo = ECHO | ECHOK | ICANON;
    my $noecho = $oterm & ~$echo;
    $term->setlflag($noecho);
    $term->setattr(fileno($fh), TCSANOW);
}

sub htmlified_system {
    my ($command, $input) = @_;

    print '<div style="font-family: andalemono, monospace">';
    print "<b>&gt; $command</b><br />";

    foreign_require("proc", "proc-lib.pl");
    local ($fh, $pid) = &foreign_call("proc", "pty_process_exec", $command);

    term_set_noecho($fh);

    print $fh $input 
        if $input;

    $| = 1;

    while($line = <$fh>) {
        $line = html_escape($line) . "<br />";
        print $line;
    }
    print '</div>';
    close($fh);
    waitpid($pid, 0);


    return $? >> 8;
}

sub _cache_path {
    my ($name) = @_;

    my $dir = $user_module_config_directory || $module_config_directory;
    make_dir($dir, 0755);
    return "$dir/cache.$name";
}

sub cache_get {
    my ($name, $ttl) = @_;
    my $path = _cache_path($name);
    my @st = stat($path);

    return if !@st or ((time() - $st[9]) > $ttl);

    return read_file_contents($path);
}

sub cache_set {
    my ($name, $data) = @_;
    my $path = _cache_path($name);

    write_file_contents($path, $data);
}

sub cache_expire {
    my ($name) = @_;
    my $path = _cache_path($name);
    unlink $path if -e $path;
}

sub tklbam_list {
    my ($id) = @_;

    my $cache_list_ttl = $config{'cache_list_ttl'} || DEFAULT_CACHE_LIST_TTL;

    my $output = cache_get('list', $cache_list_ttl);
    if(!$output) {
        $output = backquote_command('tklbam-list 2>&1');
        die $output if $? != 0;

        cache_set('list', $output);
    }

    $output =~ s/^#.*?\n//;
    my @hbrs;
    foreach my $line (split(/\n/, $output)) {
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;
        
        my @hbr = split(/\s+/, $line, 6);
        push @hbrs, \@hbr;
    }

    return @hbrs unless defined $id;
    foreach my $hbr (@hbrs) {
        next if $hbr->[0] ne $id;
        return $hbr;
    }
}

sub validate_cli_args {
    foreach my $arg (@_) {
        next unless defined $arg;
        error(sprintf("Invalid input %s", html_escape($arg))) 
            unless $arg =~ /^[:\/\s\w\d\-\.]*$/;
    }
}

sub _ui_confirmation_form
{
    my ($cgi, $method, $message, $hiddens, $buttons, $others, $warning) = @_;
    my $rv;
    $rv .= "<center class=ui_confirmation>\n";
    $rv .= &ui_form_start($cgi, $method);
    foreach my $h (@$hiddens) {
        $rv .= &ui_hidden(@$h);
        }
    $rv .= "<b>$message</b><p>\n";
    if ($others) {
        $rv .= $others."<p>\n";
        }
    $rv .= &ui_form_end($buttons);
    $rv .= "</center>\n";
    return $rv;
}

1;

