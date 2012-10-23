#!/usr/bin/perl
###########################################################################
#
# Email: david.harrison@stress-free.co.nz 
# Internet: http://www.stress-free.co.nz 
#
###########################################################################

do './web-lib.pl';
&init_config();
&ReadParse();
%text = &load_language($current_theme);

print "Content-type: text/html\n\n";

unlink(_dirname(__FILE__) . '/nodonation');

print "<div id=\"donation\">";
print "<div id=\"donationmessage\">";
print "<h2>$text{'donate_thankyou'}</h2>";
print "</div></div>";

sub _dirname {
    # replacement for File::Basename::dirname
    my ($str) = @_;
    return undef unless defined $str;
    return '.'   unless $str;
    $str =~ tr/\/\\/\//s if $^O and $^O =~ /mswin|win32/i;
    return $str if $str =~ s@/([^/]+)$@@;
    return '.';
}