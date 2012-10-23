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

print "Content-type: text/html\n\n";

my $searchVariable = $in{'Search'};

# Build a list of all modules
&read_acl(\%acl);
$user = $ENV{'REMOTE_USER'};

local $risk = $gconfig{'risk_'.$base_remote_user};
local $minfo;
foreach $minfo (&get_all_module_infos(1)) {
	next if (!&check_os_support($minfo));
	if ($risk) {
		# Check module risk level
		next if ($risk ne 'high' && $minfo->{'risk'} &&
			 $minfo->{'risk'} !~ /$risk/);
		}
	else {
		# Check specific ACL
		next if (!$acl{$base_remote_user,$minfo->{'dir'}} &&
			 !$acl{$base_remote_user,"*"});
		}
	push(@modules, $minfo);
}
@modules = sort { $a->{'desc'} cmp $b->{'desc'} } @modules;

my $categorytext;
my %listedmodules = ();
my %hitCache = ();
$i='0';
foreach $m (@modules) {
    $x='0';
    if ($m->{'longdesc'} =~ m/$searchVariable/i){
          $x++;
        }
        if( $m->{'desc'} =~ m/$searchVariable/i){
          $x++;
        }
        if( $m->{'name'} =~ m/$searchVariable/i) {
          $x++;
        }
    if($x>0){
       my $_catname = $m->{'category'};
        $_catname = "\xa0" if $cat eq '__NO_MODS__';
        # Check if module has been listed yet
        my $moduleindex = $_catname . "-" . $m->{'name'};
            if(exists $listedmodules{$moduleindex}){
               # Module alreay exists, skip
        } else {
               # Result found
               my $tempString = $hitCache{$x};
               my $description = $m->{'longdesc'} || $m->{'desc'} || $m->{'name'} || '';
               $i++;
               $tempString .= "<li><a href=\"$gconfig{'webprefix'}/$m->{'dir'}\"  title=\""
            . $description . "\"><span class=\"informal\"> $m->{'desc'} </span><span class=\"linktext\">$m->{'dir'}</span></a></li>\n";
           $hitCache{$x} = $tempString;

           $listedmodules{$moduleindex} = "true";
      }
   }
}
my @sortedList = sort { $hitCache{$a} cmp $hitCache{$b} } keys %hitCache;

foreach $key(@sortedList){
    $categorytext .= $hitCache{$key};
}
if($i > '0'){ 
    $categorytext = "<ul>" . $categorytext . "</ul>";
}    
print $categorytext;