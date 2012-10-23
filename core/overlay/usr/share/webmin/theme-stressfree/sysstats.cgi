#!/usr/bin/perl
# Show server or domain information
# Based on right.cgi file from Webmin blue theme

do './web-lib.pl';
&init_config();
do './ui-lib.pl';
&ReadParse();
if (&get_product_name() eq "usermin") {
	$level = 3;
	}
else {
	$level = 0;
	}
%text = &load_language($current_theme);
$bar_width = 180;
foreach $o (split(/\0/, $in{'open'})) {
	push(@open, $o);
	$open{$o} = 1;
	}

print "Content-type: text/html\n\n";

print "<div id=\"sysstats-close\"><div>\n";
print "<a href=\"javascript:refreshSidebar()\">$text{'sidebar_refresh'}</a>";
print "<span> | </span>";
print "<a href=\"javascript:switchSidebar()\">$text{'sidebar_close'} &raquo;</a>";
print "</div></div>\n";

print "<div id=\"sysstats-detail\">\n";
if ($level == 0) {
	# Show general system information
	# Host and login info
	print "<p><label>$text{'sidebar_host'}</label>\n";
	print "<span>",&get_system_hostname(),"</span></p>\n";

	print "<p><label>$text{'sidebar_os'}</label>\n";
	if ($gconfig{'os_version'} eq '*') {
		print "<span>$gconfig{'real_os_type'}</span></p>\n";
		}
	else {
		print "<span>$gconfig{'real_os_type'} $gconfig{'real_os_version'}</span></p>\n";
		}

	print "<p><label>$text{'sidebar_webmin'}</label>\n";
	print "<span>",&get_webmin_version(),"</span></p>\n";

	# System time
	$tm = localtime(time());
	print "<p><label>$text{'sidebar_time'}</label>\n";
	print "<span>$tm</span></p>\n";

	# Load and memory info
	if (&foreign_check("proc")) {
		&foreign_require("proc", "proc-lib.pl");
		if (defined(&proc::get_cpu_info)) {
			@c = &proc::get_cpu_info();
			if (@c) {
				print "<p><label>$text{'sidebar_cpu'}</label>\n";
				print "<span>",&text('sidebar_load', @c),"</span></p>\n";
				}
			}
		if (defined(&proc::get_memory_info)) {
			@m = &proc::get_memory_info();
			if (@m && $m[0]) {
				print "<p><label>$text{'sidebar_real'}</label>\n";

				print "<span class=\"graph\">", &bar_chart($m[0], $m[0]-$m[1], 1),
				      "</span>\n";
                                      
				print "<span>",&nice_size($m[0]*1024)." total, ".
					    &nice_size(($m[0]-$m[1])*1024)." used</span></p>\n";
				}

			if (@m && $m[2]) {
				print "<p><label>$text{'sidebar_virt'}</label>\n";
                                
				print "<span class=\"graph\">", &bar_chart($m[2], $m[2]-$m[3], 1),
				      "</span>\n";

				print "<span>",&nice_size($m[2]*1024)." total, ".
					    &nice_size(($m[2]-$m[3])*1024)." used</span></p>\n";
				
				}
			}
		}

	# Disk space on local drives
	if (&foreign_check("mount")) {
		&foreign_require("mount", "mount-lib.pl");
		@mounted = &mount::list_mounted();
		$total = 0;
		$free = 0;
		foreach $m (@mounted) {
			if ($m->[2] eq "ext2" || $m->[2] eq "ext3" ||
			    $m->[2] eq "reiserfs" || $m->[2] eq "ufs" ||
			    $m->[1] =~ /^\/dev\//) {
				($t, $f) = &mount::disk_space($m->[2], $m->[0]);
				$total += $t*1024;
				$free += $f*1024;
				}
			}
		if ($total) {
			print "<p><label>$text{'sidebar_disk'}</label>\n";

			print "<span class=\"graph\">", &bar_chart($total, $total-$free, 1),
			      "</span>\n";

			print "<span>",&text('sidebar_used',
				   &nice_size($total),
				   &nice_size($total-$free)),"</span></p>\n";
			}
		}

	# Check for incorrect OS
	if (&foreign_available("webmin")) {
		&foreign_require("webmin", "webmin-lib.pl");
		%realos = &webmin::detect_operating_system(undef, 1);
		if ($realos{'os_version'} ne $gconfig{'os_version'} ||
		    $realos{'os_type'} ne $gconfig{'os_type'}) {
			print "<form action=\"webmin/fix_os.cgi\">\n";
			print "<label>",&webmin::text('os_incorrect',"</label>",
                                "<span>", $realos{'real_os_type'},
				$realos{'real_os_version'}),"</span><p>\n";
			print "<input type=\"submit\" ",
			      "value=\"$webmin::text{'os_fix'}\"/>\n";
			print "</form>\n";
			}
		}

	}
elsif ($level == 3) {
	# Show Usermin user's information
	print "<h3>$text{'sidebar_header5'}</h3>\n";

	# Host and login info
	print "<p><label>$text{'sidebar_host'}</label>\n";
	print "<span>",&get_system_hostname(),"</span></p>\n";

	print "<p><label>$text{'sidebar_os'}</label>\n";
	if ($gconfig{'os_version'} eq '*') {
		print "<span>$gconfig{'real_os_type'}</span></p>\n";
		}
	else {
		print "<span>$gconfig{'real_os_type'} $gconfig{'real_os_version'}</span></p>\n";
		}

	# System time
	$tm = localtime(time());
	print "<p><label>$text{'sidebar_time'}</label>\n";
	print "<span>$tm</span></p>\n";

	# Disk quotas
	if (&foreign_installed("quota")) {
		&foreign_require("quota", "quota-lib.pl");
		$n = &quota::user_filesystems($remote_user);
		$usage = 0;
		$quota = 0;
		for($i=0; $i<$n; $i++) {
			if ($quota::filesys{$i,'hblocks'}) {
				$quota += $quota::filesys{$i,'hblocks'};
				$usage += $quota::filesys{$i,'ublocks'};
				}
			elsif ($quota::filesys{$i,'sblocks'}) {
				$quota += $quota::filesys{$i,'sblocks'};
				$usage += $quota::filesys{$i,'ublocks'};
				}
			}
		if ($quota) {
			$bsize = $quota::config{'block_size'};
			print "<label>$text{'sidebar_uquota'}</label>\n";

			print "<span class=\"graph\">",&bar_chart($quota, $usage, 1),
			      "</span>\n";

			print "<span>",&text('sidebar_out',
				&nice_size($usage*$bsize),
				&nice_size($quota*$bsize)),"</span>\n";
			}
		}
	}

print "</div>\n";


# bar_chart(total, used, blue-rest)
# Returns HTML for a bar chart of a single value
sub bar_chart
{
local ($total, $used, $blue) = @_;
local $rv;
$rv .= sprintf "<img src=\"$gconfig{'webprefix'}/theme-stressfree/images/bar_red.gif\" width=\"%s\" height=\"10\">",
	int($bar_width*$used/$total)+1;
if ($blue) {
	$rv .= sprintf "<img src=\"$gconfig{'webprefix'}/theme-stressfree/images/bar_blue.gif\" width=\"%s\" height=\"10\">",
		$bar_width - int($bar_width*$used/$total)-1;
	}
else {
	$rv .= sprintf "<img src=\"$gconfig{'webprefix'}/theme-stressfree/images/bar_white.gif\" width=\"%s\" height=\"10\">",
		$bar_width - int($bar_width*$used/$total)-1;
	}
return $rv;
}

# bar_chart_three(total, used1, used2, used3)
# Returns HTML for a bar chart of three values, stacked
sub bar_chart_three
{
local ($total, $used1, $used2, $used3) = @_;
local $rv;
local $w1 = int($bar_width*$used1/$total)+1;
local $w2 = int($bar_width*$used2/$total);
local $w3 = int($bar_width*$used3/$total);
$rv .= sprintf "<img src=\"$gconfig{'webprefix'}/theme-stressfree/images/bar_red.gif\" width=\"%s\" height=\"10\">", $w1;
$rv .= sprintf "<img src=\"$gconfig{'webprefix'}/theme-stressfree/images/bar_purple.gif\" width=\"%s\" height=\"10\">", $w2;
$rv .= sprintf "<img src=\"$gconfig{'webprefix'}/theme-stressfree/images/bar_blue.gif\" width=\"%s\" height=\"10\">", $w3;
$rv .= sprintf "<img src=\"$gconfig{'webprefix'}/theme-stressfree/images/bar_grey.gif\" width=\"%s\" height=\"10\">",
	$bar_width - $w1 - $w2 - $w3;
return $rv;
}

