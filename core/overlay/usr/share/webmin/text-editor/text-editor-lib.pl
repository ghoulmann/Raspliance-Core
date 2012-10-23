
do '../web-lib.pl';
&init_config();

if ($module_info{'usermin'}) {
	&switch_to_remote_user();
	&create_user_config_dirs();
	$files_list = "$user_module_config_directory/files";
	}
else {
	$files_list = "$module_config_directory/files";
	}

# list_files()
sub list_files
{
local @rv;
open(FILES, $files_list);
while(<FILES>) {
	s/\r|\n//g;
	push(@rv, $_);
	}
close(FILES);
return @rv;
}

# save_files(file, ...)
sub save_files
{
local $f;
open(FILES, ">$files_list");
foreach $f (@_) {
	print FILES $f,"\n";
	}
close(FILES);
}

1;

