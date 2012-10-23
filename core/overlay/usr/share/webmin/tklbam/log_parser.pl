# log_parser.pl
# Functions for parsing this module's logs

do 'tklbam-lib.pl';

=head2 parse_webmin_log(user, script, action, type, object, &params)

Converts logged information from this module into human-readable form

=cut
sub parse_webmin_log
{
    my ($user, $script, $action, $type, $object, $p) = @_;
    my @noargs = qw(init passphrase escrow restore_rollback);
    if(grep { $_ eq $action } (@noargs)) {
        return text("log_$action");
    } elsif($action eq 'save') {
        return text("log_${action}_${type}_${object}") if $type eq 'cron';
        return text("log_${action}_${type}");
    } elsif($action eq 'backup') {
        return text("log_${action}_${type}");
    } elsif($action eq 'restore') {
        return text("log_$action", html_escape($object));
    } else {
        return;
    }

}

