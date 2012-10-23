#!/usr/bin/perl
# Show a list of files to edit, and the contents of one

require './text-editor-lib.pl';
&ReadParse();
&header($text{'index_title'}, "", undef, 1, 1);
print "<hr>\n";

$file = $in{'newfile'} || $in{'file'};

# File chooser input
@files = &list_files();
$newfile = $file if (&indexof($file, @files) < 0);
print "<form action=index.cgi>\n";
print "<table>\n";
print "<tr> <td valign=top><b>$text{'index_file'}</b></td>\n";
print "<td><input name=newfile size=50 value='$newfile'> ",
	&file_chooser_button("newfile"),"</td>\n";
print "<td valign=top><input type=submit value='$text{'index_ok'}'></td> </tr>\n";
if (@files) {
	print "<tr> <td></td> <td>";
	print "<select name=file>\n";
	foreach $f (sort { $a cmp $b } @files) {
		printf "<option %s>%s\n",
			$f eq $file ? "selected" : "", $f;
		}
	print "</select></td> </tr>\n";
	}
print "</table></form>\n";

# Editor input
if ($file) {
	$dos = 0;
	print "<form action=save.cgi method=post enctype=multipart/form-data>\n";
	print "<input type=hidden name=file value='$file'>\n";
	print &text('index_editing', "<tt>$file</tt>"),"<br>\n";
	print "<textarea name=data rows=$config{'rows'} cols=$config{'cols'} $config{'wrap'}>";
	$existing = open(FILE, $file);
	while(<FILE>) {
		$dos = 1 if (/\r/);
		s/\r//g;
		print &html_escape($_);
		}
	close(FILE);
	print "</textarea><br>\n";
	if ($existing) {
		print "<input type=hidden name=dos value='$dos'>\n";
		}
	else {
		print "<input type=checkbox name=dos value=1> ",
		      "$text{'index_dos'}<br>\n";
		}
	print "<input type=submit value='$text{'save'}'></form>\n";
	}

print "<hr>\n";
&footer("/", $text{'index'});

