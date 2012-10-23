#!/usr/bin/perl

use File::Find;

###########################################################################
#
# Email: david.harrison@stress-free.co.nz
# Internet: http://www.stress-free.co.nz
#
# Javascript version originally contributed by Dwi Kristianto
#
###########################################################################


do './web-lib.pl';
$trust_unknown_referers = 1;
init_config();

my $manifest;
build_manifest();
if (length $manifest > 0) { chop $manifest; }

my $manifestfile = $root_directory . "/theme-stressfree/manifest.cgi";
my $write_secs = (stat($manifestfile))[9];

print "Content-type: text/javascript\n\n";
print "{\n";
print "\"betaManifestVersion\" : 1,\n";
print "\"version\" : \"wmg-$write_secs\",\n";
print "\"entries\" : [";
print $manifest;
print "\n]}";


sub build_manifest
{
opendir(DIR, $root_directory);
foreach $m (readdir(DIR)) {
        local $include = 1;
        if ($m =~ /^\./) {
            $include = 0;
        }
        if (!-d "$root_directory/$m") {
            $include = 0;
        }
        if ($m ne "theme-stressfree") {
            if (-e "$root_directory/$m/theme.info") {
                $include = 0;
            }
        }
        if ($include == 1) {
            File::Find::find( {wanted => \&wanted}, "$root_directory/$m");
        }
    }
closedir(DIR);
}

sub wanted {
   if ((/\.jpg$/) || (/\.png$/) || (/\.ico$/) || (/\.gif$/) || (/\.js$/) || (/\.css$/) || (/\.htc$/) || (/\.jar$/) ){
      my $file = $File::Find::name;
      $file =~ s/^\Q$root_directory\E//;
      $file = $gconfig{'webprefix'}.$file;
      $manifest .= "\n{ \"url\" : \"$file\" },";
   }
}