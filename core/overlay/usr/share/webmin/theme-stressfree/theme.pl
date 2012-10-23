#
# StressFree theme by David Harrison
# Last modified 2/12/2010
#
# gears mods by Dwi Kristianto
# last: 20 dec 2008 (early version)
#####################################

my $_module_name = $module_name || '';
my $_confdir;

sub theme_header {
  &load_theme_library();
  %themetext = &load_language($current_theme);

  my $dropdown_rows = 12;
  if ( defined( $tconfig{'dropdown_rows'} ) ) {
    $dropdown_rows = $tconfig{'dropdown_rows'};
  }

  print
"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n";
  print "<html>\n";
  local $os_type =
      $gconfig{'real_os_type'}
    ? $gconfig{'real_os_type'}
    : $gconfig{'os_type'};
  local $os_version =
      $gconfig{'real_os_version'}
    ? $gconfig{'real_os_version'}
    : $gconfig{'os_version'};
  print "<head>\n";

  if ( @_ > 0 ) {
    if ( $gconfig{'sysinfo'} == 1 ) {
      printf "<title>%s : %s on %s (%s %s)</title>\n",
        $_[0], $remote_user, &get_display_hostname(),
        $os_type, $os_version;
    }
    elsif ( $gconfig{'sysinfo'} == 4 ) {
      printf "<title>%s on %s (%s %s)</title>\n",
        $remote_user, &get_display_hostname(),
        $os_type,     $os_version;
    }
    else {
      print "<title>$_[0]</title>\n";
    }
    print $_[7] if ( $_[7] );
  }
  if ( $ENV{SCRIPT_NAME} =~ m'^/session_login\.cgi' ) {

    # Nothing - primary CSS file should not be loaded
    ;
  }
  else {
    print "$tconfig{'headhtml'}\n" if ( $tconfig{'headhtml'} );
  }
  if ( $tconfig{'headinclude'} ) {
    local $_;
    open( INC, "$theme_root_directory/$tconfig{'headinclude'}" );
    while (<INC>) {
      print;
    }
    close(INC);
  }
  if ( $ENV{SCRIPT_NAME} =~ m'^/session_login\.cgi' ) {
    print __logincss();
  }
  else {

    # Favicon...
    print
"<link rel=\"shortcut icon\" href=\"$gconfig{'webprefix'}/theme-stressfree/images/favicon.ico\">\n";

    print
"<link rel=\"stylesheet\" type=\"text/css\" href=\"$gconfig{'webprefix'}/theme-stressfree/theme.css\">\n";
    print
"<link rel=\"stylesheet\" type=\"text/css\" href=\"$gconfig{'webprefix'}/theme-stressfree/print.css\" media=\"print\">\n";
    print
"<script type=\"text/javascript\" src=\"$gconfig{'webprefix'}/theme-stressfree/javascript/protopacked.js\"></script>\n";
    print
"<script type=\"text/javascript\" src=\"$gconfig{'webprefix'}/theme-stressfree/javascript/application.js\"></script>\n";

    # RSS news link
    my $enable_rss = 1;
    if ( defined( $tconfig{'enable_rss'} ) ) {
      $enable_rss = $tconfig{'$enable_rss'};
    }
    if ( $enable_rss > 0 ) {
    print
"<link rel=\"alternate\" type=\"application/rss+xml\" title=\"RSS\" href=\"http://feeds.feedburner.com/StressFreeSolutions-Webmin/\">\n";
    }
    
    # Dropdown menu rows if scrollable
    print "<style type=\"text/css\">\n";
    print "div#menu ul li div.menuitems-scroll { ";
    print "height: " . $dropdown_rows * 25 . "px; ";
    print "}\n";
    print "</style>\n";

    print "<!--[if lt IE 7]>\n";
    print "<style type=\"text/css\">\n";
    print
"body { behavior: url($gconfig{'webprefix'}/theme-stressfree/csshover.htc); }\n";
    print "</style>\n";
    print
"<link rel=\"stylesheet\" type=\"text/css\" href=\"$gconfig{'webprefix'}/theme-stressfree/theme_ie6.css\">\n";
    print "<![endif]-->\n";
  }
  if ( $ENV{SCRIPT_NAME} =~ m'^/chooser.cgi' ) {
    print
"<link rel=\"stylesheet\" type=\"text/css\" href=\"$gconfig{'webprefix'}/theme-stressfree/chooser.css\">";
  }
  elsif ($ENV{SCRIPT_NAME} =~ m'^/file/upform\.cgi'
    || $ENV{SCRIPT_NAME} =~ m'^/filemanager/upform\.cgi'
    || $ENV{SCRIPT_NAME} =~ m'^/filemanager/upload\.cgi'
    || $ENV{SCRIPT_NAME} =~ m'^/file/upload\.cgi' )
  {
    print
"<link rel=\"stylesheet\" type=\"text/css\" href=\"$gconfig{'webprefix'}/theme-stressfree/fileupload.css\">";
  }

  print "</head>\n";

  print "<body " . $_[8] . ">\n";
  print "<div id=\"container\" class=\"".  $module_name . "\">";
  local $hostname = &get_display_hostname();
  local $version  = &get_webmin_version();
  local $prebody  = $tconfig{'prebody'};
  if ($prebody) {
    $prebody =~ s/%HOSTNAME%/$hostname/g;
    $prebody =~ s/%VERSION%/$version/g;
    $prebody =~ s/%USER%/$remote_user/g;
    $prebody =~ s/%OS%/$os_type $os_version/g;
    print "$prebody\n";
  }
  if ( $tconfig{'prebodyinclude'} ) {
    local $_;
    open( INC, "$theme_root_directory/$tconfig{'prebodyinclude'}" );
    while (<INC>) {
      print;
    }
    close(INC);
  }

  if ( defined(&theme_prebody) ) {
    &theme_prebody(@_);
  }
  print "<div id=\"content\">\n";
  print "<div id=\"header\"><div id=\"headerwrapper\"><div id=\"headercontent\">\n";
  if ( @_ > 1 ) {
    if ( $gconfig{'sysinfo'} == 2 && $remote_user ) {
      print "<div id=\"headerinfo\">\n";
      printf "%s%s logged into %s %s on %s (%s%s)</td>\n",
        $ENV{'ANONYMOUS_USER'} ? "Anonymous user" : "<tt>$remote_user</tt>",
        $ENV{'SSL_USER'}       ? " (SSL certified)"
        : $ENV{'LOCAL_USER'}   ? " (Local user)"
        : "",
        $text{'programname'},
        $version, "<tt>$hostname</tt>",
        $os_type, $os_version eq "*" ? "" : " $os_version";
      print "</div>\n";
    }
  }

  # Title is just text
  print "<div id=\"headertitle\">";
  print "<h1>$_[0]</h1>\n";
  print "<p>$_[9]</p>\n" if ( $_[9] );
  print "</div>\n";

  if ( @_ > 1 ) {
    print "<div id=\"headerservers\"><ul>";
    if ($gconfig{'log'} && &foreign_available("webminlog")) {
      print "<li><a href='javascript:showLogs();'>View log</a></li>";
    }
    if ( $ENV{'HTTP_WEBMIN_SERVERS'} ) {
      print "<li><a href='$ENV{'HTTP_WEBMIN_SERVERS'}'>",
        "$text{'header_servers'}</a></li>\n";
    }
    if ( !$_[5] && !$tconfig{'noindex'} ) {
      local @avail = &get_available_module_infos(1);
      local $nolo =
           $ENV{'ANONYMOUS_USER'}
        || $ENV{'SSL_USER'}
        || $ENV{'LOCAL_USER'}
        || $ENV{'HTTP_USER_AGENT'} =~ /webmin/i;
      if (   $gconfig{'gotoone'}
        && $main::session_id
        && @avail == 1
        && !$nolo )
      {
        print "<li><a href='$gconfig{'webprefix'}/session_login.cgi?logout=1'>",
          "$text{'main_logout'}</a></li>";
      }
      elsif ( $gconfig{'gotoone'} && @avail == 1 && !$nolo ) {
        print "<li><a href='$gconfig{'webprefix'}/switch_user.cgi'>",
          "$text{'main_switch'}</a></li>";
      }
      elsif ( !$gconfig{'gotoone'} || @avail > 1 ) {
        print
          "<li><a href='$gconfig{'webprefix'}/?cat=$module_info{'category'}'>",
          "$text{'header_webmin'}</a></li>\n";
      }
    }
    if ( !$_[4] && !$tconfig{'nomoduleindex'} ) {
      local $idx = $module_info{'index_link'};
      local $mi  = $module_index_link || "/$module_name/$idx";
      local $mt  = $module_index_name || $text{'header_module'};
      print "<li><a href=\"$gconfig{'webprefix'}$mi\">$mt</a></li>\n";
    }
    if ( ref( $_[2] ) eq "ARRAY" && !$ENV{'ANONYMOUS_USER'} ) {
      print "<li>", &hlink( $text{'header_help'}, $_[2]->[0], $_[2]->[1] ),
        "</li>\n";
    }
    elsif ( defined( $_[2] ) && !$ENV{'ANONYMOUS_USER'} ) {
      print "<li>", &hlink( $text{'header_help'}, $_[2] ), "</li>\n";
    }
    if ( $_[3] ) {
      local %access = &get_module_acl();
      if ( !$access{'noconfig'} && !$config{'noprefs'} ) {
        local $cprog =
          $user_module_config_directory ? "uconfig.cgi" : "config.cgi";
        print "<li><a href=\"$gconfig{'webprefix'}/$cprog?$module_name\">",
          $text{'header_config'}, "</a></li>\n";
      }
    }
    if ( $_[6] ) {
      print "<li>";
      local $links   = $_[6];
      local $find    = "<br />";
      local $replace = "</li><li>";
      $links =~ s/$find/$replace/g;
      print $links;
      print "</li>";
    }
    print "</ul></div>\n";
  }

  print "</div></div></div>\n";
  if (   $ENV{SCRIPT_NAME} =~ m'^/session_login\.cgi'
    || $ENV{SCRIPT_NAME} =~ m'^/chooser.cgi'
    || $ENV{SCRIPT_NAME} =~ m'^/file/upform\.cgi'
    || $ENV{SCRIPT_NAME} =~ m'^/filemanager/upform\.cgi'
    || $ENV{SCRIPT_NAME} =~ m'^/filemanager/upload\.cgi'
    || $ENV{SCRIPT_NAME} =~ m'^/file/upload\.cgi' )
  {

    # Do nothing
  }
  else {
    print "<div id=\"layout\">\n";
    print "<table id=\"contenttable\" summary=\"\" class=\"sidebar-hidden\">\n";
    print "<tbody><tr><td id=\"contentblock\">\n";
    print "<div id=\"contentcontainer\">\n";

    my $enable_sidebar = 1;
    if ( defined( $tconfig{'enable_sidebar'} ) ) {
      $enable_sidebar = $tconfig{'enable_sidebar'};
    }
    if ( $enable_sidebar > 0 ) {
      print "<div id=\"sysstats-open\">";
      print
"<a href=\"javascript:switchSidebar()\">$themetext{'sidebar_open'} &raquo;</a>\n";
      print "</div>\n";
    }
  }

  print "<div id=\"maincontent\">\n";

  if ( $ENV{SCRIPT_NAME} =~ m'^/file/' || $ENV{SCRIPT_NAME} =~ m'^/filemanager/' ) {
    print "<div class=\"filemanager\">";
  }
}

sub theme_prebody {
  if ( $ENV{SCRIPT_NAME} =~ m'^/session_login\.cgi' ) {

    # Nothing
    ;
  }
  elsif ( $ENV{SCRIPT_NAME} =~ m'^/chooser.cgi' ) {

    # Nothing
    ;
  }
  elsif ($ENV{SCRIPT_NAME} =~ m'^/file/upform\.cgi'
    || $ENV{SCRIPT_NAME} =~ m'^/filemanager/upform\.cgi'
    || $ENV{SCRIPT_NAME} =~ m'^/filemanager/upload\.cgi'
    || $ENV{SCRIPT_NAME} =~ m'^/file/upload\.cgi' )
  {
    print "<div id=\"uploadtitle\"><span>$themetext{'theme_upload'}</span></div>";
    print "<div id=\"uploadoption\">";
    print "<ul>";
    print
"<li class=\"uploadclose\"><a href=\"javascript:self.close()\">$themetext{'theme_close'}</a></li>";
    print "</ul></div>";

  }
  else {
    print "\n<script type=\"text/javascript\">\n";
    print "initialize('$gconfig{'webprefix'}');\n";
    print "</script>\n";

    print '<div id="menu"><ul>';

    generate_menu();

    my $nolo =
         $ENV{'ANONYMOUS_USER'}
      || $ENV{'SSL_USER'}
      || $ENV{'LOCAL_USER'}
      || $ENV{'HTTP_USER_AGENT'} =~ /webmin/i;

    print
"\n<li id=\"searchbutton\" class=\"search-notselected\"><a href=\"#\" onclick=\"viewSearch()\">$themetext{'theme_search'}</a></li>";

    # Google Gears activation button
    my $enable_gears = 1;
    if ( defined( $tconfig{'enable_gears'} ) ) {
      $enable_gears = $tconfig{'enable_gears'};
    }
    if ( $enable_gears > 0 ) {
    print
"\n<li id=\"gearsstatus\" class=\"gearsstatus-notselected\"><a id=\"gearslink\" class=\"gears-disabled\" href=\"#\" onclick=\"webminGears.message_view(); return false;\">$themetext{'gears_title'}</a></li>";
    }
    
    if ( $main::session_id and !$nolo ) {
      print "\n<li id=\"logout\"><a href='"
        . $gconfig{'webprefix'}
        . "/session_login.cgi?logout=1'>",
        $text{'main_logout'}, "</a></li>";
    }
    elsif ( !$nolo ) {
      print
        "\n<li id=\"logout\"><a href='/switch_user.cgi'>",
        $text{'main_switch'}, '</a></li>';
    }
    print "</ul></div>\n\n";
    print "<div style=\"display: none;\" id=\"searchform\"><ul>";
    print
"<li class=\"searchbox\"><input autocomplete=\"off\" type=\"text\" id=\"searchfield\" name=\"searchfield\" size=\"25\"/></li>";
    print
      "<li class=\"searchtext\"><p>$themetext{'theme_search'}:</p></li></ul></div>";
    print
"<div class=\"autocomplete\" id=\"searchfield_choices\" style=\"display: none;\"></div>";
  }
}

sub theme_footer {
	
  for(my $i=0; $i+1<@_; $i+=2) {
  	print "<div id=\"footerlinks\">";
    my $url = $_[$i];
    if ($url ne '/' || !$tconfig{'noindex'}) {
      if ($url eq '/') {
        $url = "/?cat=$this_module_info{'category'}";
      }
      elsif ($url eq '' && &get_module_name()) {
        $url = "/".&get_module_name()."/".
        $this_module_info{'index_link'};
      }
      elsif ($url =~ /^\?/ && &get_module_name()) {
        $url = "/".&get_module_name()."/$url";
      }
      $url = "$gconfig{'webprefix'}$url" if ($url =~ /^\//);
      if ($i == 0) {
        print "<a href=\"$url\" class=\"img\"><img alt=\"<-\" src=\"$gconfig{'webprefix'}/images/left.gif\"></a>\n";
      } else {
        print " | ";
      }
      print " <a href=\"$url\">",&text('main_return', $_[$i+1]),"</a>\n";
    }
    print "</div>";
  }
  
  if ( ( $ENV{SCRIPT_NAME} =~ m'^/session_login\.cgi' ) ) {

    #nothing
    ;
  }
  elsif ( ( $ENV{SCRIPT_NAME} =~ m'^/chooser.cgi' ) ) {

    #nothing
    ;
  }
  elsif ($ENV{SCRIPT_NAME} =~ m'^/file/upform\.cgi'
    || $ENV{SCRIPT_NAME} =~ m'^/filemanager/upform\.cgi'
    || $ENV{SCRIPT_NAME} =~ m'^/filemanager/upload\.cgi'
    || $ENV{SCRIPT_NAME} =~ m'^/file/upload\.cgi' )
  {
    print '</div>';
  }
  else {
    if ( $ENV{SCRIPT_NAME} =~ m'^/file/' || $ENV{SCRIPT_NAME} =~ m'^/filemanager/' ) {
      print "</div>";
    }
    if ( -e __dirname(__FILE__) . '/nodonation' ) {
      print __donatemessage();
    }
    print "\n</div>";

    if (   $ENV{SCRIPT_NAME} =~ m'^/session_login\.cgi'
      || $ENV{SCRIPT_NAME} =~ m'^/chooser.cgi'
      || $ENV{SCRIPT_NAME} =~ m'^/file/upform\.cgi'
      || $ENV{SCRIPT_NAME} =~ m'^/filemanager/upform\.cgi'
      || $ENV{SCRIPT_NAME} =~ m'^/filemanager/upload\.cgi'
      || $ENV{SCRIPT_NAME} =~ m'^/file/upload\.cgi' )
    {

      # nothing
    }
    else {
      print "</div></td>\n";

      my $enable_sidebar = 1;
      if ( defined( $tconfig{'enable_sidebar'} ) ) {
        $enable_sidebar = $tconfig{'enable_sidebar'};
      }
      if ( $enable_sidebar > 0 ) {
        print "<td id=\"sidebar\" class=\"sidebar-hidden\">\n";
        print "<div id=\"sidebar-info\"></div></td>\n";
      }
      print "</tr></tbody></table>\n";
      print "</div>\n";
    }
    print "\n<div id=\"footer\">"
      . $ENV{'REMOTE_USER'}
      . ( $gconfig{nohostname} ? '' : '@' . get_display_hostname() )
      . "</div>\n";
    print "</div></div>\n\n";

    ## Form for loading logs
    print "
<form class=\"hiddenform\" name=\"sfViewAllLogs\" id=\"sfViewAllLogs\" method=\"get\" action=\"$gconfig{'webprefix'}/webminlog/search.cgi\">
<input type=\"hidden\" name=\"tall\" id=\"tall\" value=\"4\" />
<input type=\"hidden\" name=\"uall\" id=\"uall\" value=\"1\" />
<input type=\"hidden\" name=\"mall\" id=\"mall\" value=\"0\" />
<input type=\"hidden\" name=\"mall\" id=\"mall\" value=\"1\" />
</form>
<form class=\"hiddenform\" name=\"sfViewModuleLogs\" id=\"sfViewModuleLogs\" method=\"get\" action=\"$gconfig{'webprefix'}/webminlog/search.cgi\">
<input type=\"hidden\" name=\"tall\" id=\"tall\" value=\"4\" />
<input type=\"hidden\" name=\"uall\" id=\"uall\" value=\"1\" />
<input type=\"hidden\" name=\"mall\" id=\"mall\" value=\"0\" />
<input type=\"hidden\" name=\"module\" id=\"module\" value=\"\" />
</form>";

    my $enable_gears = 1;
    if ( defined( $tconfig{'enable_gears'} ) ) {
      $enable_gears = $tconfig{'enable_gears'};
    }
    if ( $enable_gears > 0 ) {
        ## dwi mods for gears
        print "\n";
        print "<!--google gears : start-->
<div id=\"gears-info-box\" class=\"info-box\" style=\"display: none;\">
  <div id=\"gears-msg1\">
    <h3 class=\"info-box-title\"><span>$themetext{'gears_msg1_title'}</span></h3>
    <p>$themetext{'gears_msg1_s1'}.<br/>
       <a href=\"http://gears.google.com/\" target=\"_blank\">$themetext{'gears_msg1_s2'}</a>.</p>

    <p><strong>$themetext{'gears_warning'}</strong>.</p>
    <div class=\"submit\">
      <a href=\"javascript:webminGears.message_view();\">$themetext{'theme_cancel'}</a>
      <button onclick=\"window.open('http://gears.google.com/?action=install', '_blank'); return true;\" class=\"button\">$themetext{'gears_install'}</button>
    </div>
  </div>

  <div id=\"gears-msg2\" style=\"display: none;\">
    <h3 class=\"info-box-title\"><span>$themetext{'gears_msg2_title'}</span></h3>
    <p>$themetext{'gears_msg2_s1'}.</p>
    <p>$themetext{'gears_msg2_s2'}.</p>

    <p><strong>$themetext{'gears_warning'}</strong>.</p>
    <div class=\"submit\">
            <a href=\"javascript:webminGears.message_view();\">$themetext{'theme_cancel'}</a>
            <button class=\"button\" onclick=\"webminGears.getPermission();\">$themetext{'gears_enable'}</button>
        </div>
  </div>

  <div id=\"gears-msg3\" style=\"display: none;\">
    <h3 class=\"info-box-title\"><span>$themetext{'gears_msg3_title'}</span></h3>
    <p>$themetext{'gears_msg3_s1'}.</p>
    <p>$themetext{'gears_msg3_s2'}.</p>
    <p>$themetext{'gears_msg3_s3'}
            <span id=\"gears-upd-number\">&nbsp;</span>
            <span id=\"gears-wait\">&nbsp;</span>
        </p>
    <div class=\"submit\">
            <a href=\"javascript:webminGears.message_view();\">$themetext{'theme_close'}</a>
        </div>
  </div>

  <div id=\"gears-msg4\" class=\"small\" style=\"display: none;\">
    <p>$themetext{'gears_msg4_s1'} <strong id=\"mfver\">&nbsp;</strong></p>
  </div>
</div>
<!--google gears : end-->";
    }
  }
  print "</body></html>";
}

sub theme_popup_header {
  print
"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n";
  print "<html>\n";
  print "<head>\n";
  print "<title>$_[0]</title>\n";
  print $_[1];
  print "$tconfig{'headhtml'}\n" if ( $tconfig{'headhtml'} );
  if ( $tconfig{'headinclude'} ) {
    local $_;
    open( INC, "$theme_root_directory/$tconfig{'headinclude'}" );
    while (<INC>) {
      print;
    }
    close(INC);
  }
  print "<link rel='stylesheet' href='/popup.css' type='text/css'>";
  print "</head>\n";
  print "<body " . $_[8] . " " . $_[2] . ">\n";
}

sub generate_menu {
  my $old_menu = 0;

  if ( defined( $tconfig{'old_menu'} ) ) {
    $old_menu = $tconfig{'old_menu'};
  }

  if ( $old_menu == 1 ) {
    standard_menu();
  }
  else {
    installed_menu();
  }
}

sub installed_menu {

  @cats = &get_visible_modules_categories();
  @modules = map { @{ $_->{'modules'} } } @cats;

  # By default dropdowns and menu icons are enabled
  # If enable_dropdowns=0 in theme config then do not show dropdown menus
  # If enable_menuicons=0 in theme config then do not show dropdown icons
  my $enable_dropdowns = 1;
  my $enable_menuicons = 1;
  my $enable_scrollbar = 1;

  if ( defined( $tconfig{'enable_dropdowns'} ) ) {
    $enable_dropdowns = $tconfig{'enable_dropdowns'};
  }
  if ( defined( $tconfig{'enable_menuicons'} ) ) {
    $enable_menuicons = $tconfig{'enable_menuicons'};
  }
  if ( defined( $tconfig{'enable_scrollbar'} ) ) {
    $enable_scrollbar = $tconfig{'enable_scrollbar'};
  }

  unless ($_icons) {
    my $_iconmap =
        __dirname(__FILE__)
      . '/icon_map'
      . ( $gconfig{'product'} eq 'usermin' ? '_usermin' : '' );
    do $_iconmap;
    do $_confdir . '/icon_map' if $_confdir;
  }

  my $default_icon = $_icons->{_DEFAULT_} || 'default16x16.png';

  foreach $c (@cats) {

    if ( $c->{'code'} eq 'webmin' || $c->{'code'} eq 'usermin' ) {
      $mods .= "<li class=\"webmin\">";
    }
    elsif ($c->{'code'} eq 'unused') {
      $mods .= "<li class=\"unused\">";
    }
    else {
      $mods .= "<li>";
    }
    $mods .= "<a href=\"$gconfig{'webprefix'}/?cat="
      . $c->{'code'} . "\">" . $c->{'desc'} . "</a>";

    if ( $enable_dropdowns > 0 ) {
      $mods .= "<div class=\"menuitems-";
      if ( $enable_scrollbar > 0 ) {
        $mods .= "scroll";
      }
      else {
        $mods .= "noscroll";
      }
      $mods .= "\"><ul>";

      foreach my $minfo ( @{ $c->{'modules'} } ) {
        $mods .=
          "<li><a title=\""
          . __htmlify2( $minfo->{'longdesc'}
            || $minfo->{'desc'}
            || $minfo->{'name'}
            || '' )
          . "\" href=\"$gconfig{webprefix}/$minfo->{'dir'}/$minfo->{index_link}\">";

        if ( $enable_menuicons > 0 ) {

          my $icon = $default_icon;
          if ( exists( $_icons->{ $minfo->{dir} } ) ) {
            $icon = $_icons->{ $minfo->{dir} };
          }
          else {
            if ( -e "$root_directory/$minfo->{dir}/images/icon.gif" ) {
              $icon = "../" . $minfo->{dir} . "/images/icon.gif";
            }
          }
          $mods .= "<div class=\"menuicon\" style=\"background:url('$gconfig{webprefix}/icons/$icon') left center no-repeat; background-size: 16px; -moz-background-size: 16px;\">";
        }
        $mods .= "<div class=\"menuitem\">" . ( $minfo->{'desc'} || $minfo->{'name'} || '' ) . "</div>";
        if ( $enable_menuicons > 0 ) {
            $mods .= "</div>"
        }
        $mods .= "</a></li>\n";
      }

      $mods .= "</ul></div></li>";
    }
  }
  print $mods;
}

sub standard_menu {

  my $_webmin_version = get_webmin_version();

  get_miniserv_config( \%miniserv ) unless %miniserv;

  $_confdir = $miniserv{'env_WEBMIN_CONFIG'} . "/theme-stressfree/style-config"
    if $miniserv{'env_WEBMIN_CONFIG'};

  #@modules =();
  unless (@modules) {
    if ( $gconfig{'product'} eq 'webmin' and $_webmin_version >= 1.14 ) {
      eval '   @modules = &get_visible_module_infos(); ';
    }
    else {
      @modules = &get_available_module_infos(1);
    }
  }

  &ReadParse() unless %in;

  my $_in_cat = ( defined( $in{'cat'} ) ? $in{'cat'} : $gconfig{'deftab'} || '' );

  $_in_cat = '__GET_FROM_MODULE__' if $_module_name;

  if (   $gconfig{"notabs_${base_remote_user}"} == 2
    || $gconfig{"notabs_${base_remote_user}"} == 0 && $gconfig{'notabs'} )
  {
    $_in_cat = '__NO_MODS__';
  }

  $_in_cat = "" if $_in_cat eq '_OTHERS_';

  if ( $ENV{SCRIPT_NAME} eq "/config.cgi"
    || ( $gconfig{'product'} eq 'usermin' && $ENV{SCRIPT_NAME} eq "/uconfig.cgi" ) )
  {
    ( undef, $_module_name ) = split( /\?/, $ENV{'REQUEST_URI'}, 2 );
    $_in_cat = '__GET_FROM_MODULE__';
  }

  print __catmods( $_in_cat, \@modules );
}

sub __catmods {

  # By default dropdowns and menu icons are enabled
  # If enable_dropdowns=0 in theme config then do not show dropdown menus
  # If enable_menuicons=0 in theme config then do not show dropdown icons
  my $enable_dropdowns = 1;
  my $enable_menuicons = 1;
  my $enable_scrollbar = 1;

  if ( defined( $tconfig{'enable_dropdowns'} ) ) {
    $enable_dropdowns = $tconfig{'enable_dropdowns'};
  }
  if ( defined( $tconfig{'enable_menuicons'} ) ) {
    $enable_menuicons = $tconfig{'enable_menuicons'};
  }
  if ( defined( $tconfig{'enable_scrollbar'} ) ) {
    $enable_scrollbar = $tconfig{'enable_scrollbar'};
  }

  my ( $cat, $mods_ar ) = @_;
  my ( $icon_map, $_dump, $catname );

  #  our(%catnames);

  unless ($_icons) {
    my $_iconmap =
        __dirname(__FILE__)
      . '/icon_map'
      . ( $gconfig{'product'} eq 'usermin' ? '_usermin' : '' );
    do $_iconmap;
    do $_confdir . '/icon_map' if $_confdir;
  }

  my $default_icon = $_icons->{_DEFAULT_} || 'default16x16.png';

  &read_file( "$config_directory/webmin.catnames", \%catnames ) unless %catnames;

  my ( $mods, $gotos, %xpcats, %saw_cat );

  my %menucategories = ();
  my %listedmodules  = ();

  MOD: foreach my $m ( @{$mods_ar} ) {

    $m->{'category'} = 'usermin'
      if $gconfig{'product'} eq 'usermin' and $m->{'category'} eq 'webmin';
    $m->{'category'} = '' if $m->{'category'} eq 'others';

    my $_catname = $m->{'category'};

    $_catname = "\xa0" if $cat eq '__NO_MODS__';

    my $moduleindex  = $_catname . "-" . $m->{'name'};
    my $categorytext = $menucategories{$_catname};

    $catname ||= $_catname;

    my $newcategorytext =
        "<li><a title=\""
      . __htmlify2( $m->{'longdesc'} || $m->{'desc'} || $m->{'name'} || '' )
      . "\" href=\"$gconfig{webprefix}/$m->{'dir'}/$m->{index_link}\">";

    if ( $enable_menuicons > 0 ) {

      my $icon = $default_icon;
      if ( exists( $_icons->{ $m->{dir} } ) ) {
        $icon = $_icons->{ $m->{dir} };
      }
      else {
        if ( -e "$root_directory/$m->{dir}/images/icon.gif" ) {
          $icon = "../" . $m->{dir} . "/images/icon.gif' width='16' height='16";
        }
      }
      $newcategorytext .=
          "<img class='modicon' src='$gconfig{webprefix}/icons/$icon' alt=\""
        . __htmlify2( $m->{'longdesc'} || $m->{'desc'} || $m->{'name'} || '' )
        . "\" border=\"0\"><span class=\"iconitem\">";
    }
    else {
      $newcategorytext .= "<span class=\"noiconitem\">";
    }

    $newcategorytext =
        $newcategorytext
      . ( $m->{'desc'} || $m->{'name'} || '' )
      . "</span></a></li>\n";

    $menucategories{$_catname} = $categorytext . $newcategorytext;

    $listedmodules{$moduleindex} = "true";

  }

  while ( my ( $key, $value ) = each(%menucategories) ) {
    if ( $key eq 'webmin' || $key eq 'usermin' ) {

      my $_catname =
           $catnames{$key}
        || $text{ "category_" . $key }
        || __htmlify2( $key || 'Others' );

      $mods .= "<li class=\"webmin\">";

      $mods .=
        "<a href=\"$gconfig{'webprefix'}/?cat=" . $key . "\">" . $_catname . "</a>";
      if ( $enable_dropdowns > 0 ) {
        $mods .= "<div class=\"menuitems-";
        if ( $enable_scrollbar > 0 ) {
          $mods .= "scroll";
        }
        else {
          $mods .= "noscroll";
        }
        $mods .= "\"><ul>" . $value . "</ul></div></li>";
      }
    }
  }

  while ( my ( $key, $value ) = each(%menucategories) ) {
    if ( $key ne 'webmin' && $key ne 'usermin' ) {

      my $_catname =
           $catnames{$key}
        || $text{ "category_" . $key }
        || __htmlify2( $key || 'Others' );

      $mods .=
        "<li><a href=\"$gconfig{'webprefix'}/?cat=" . $key . "\">" . $_catname . "</a>";
      if ( $enable_dropdowns > 0 ) {
        $mods .= "<div class=\"menuitems-";
        if ( $enable_scrollbar > 0 ) {
          $mods .= "scroll";
        }
        else {
          $mods .= "noscroll";
        }
        $mods .= "\"><ul>" . $value . "</ul></div></li>";
      }
    }
  }
  return $mods;
}

sub __htmlify2 {
  my ($str) = @_;
  return '' unless $str;
  $str =~ s/</&lt\;/g;
  $str =~ s/>/&gt\;/g;
  $str =~ s/\"/&quot\;/g;
  $str =~ s/'/&\#39\;/g;
  return $str;
}

sub __dirname {

  # replacement for File::Basename::dirname
  my ($str) = @_;
  return undef unless defined $str;
  return '.'   unless $str;
  $str =~ tr/\/\\/\//s if $^O and $^O =~ /mswin|win32/i;
  return $str if $str =~ s@/([^/]+)$@@;
  return '.';
}

sub __donatemessage {
  my $mods = "
  <div id=\"donation\">
  <form method=\"post\" action=\"https://www.paypal.com/cgi-bin/webscr\" target=\"_blank\">
  <div id=\"donationbutton\">
  <input type=\"hidden\" value=\"_s-xclick\" name=\"cmd\"  /> <input border=\"0\" type=\"image\" alt=\"Make payments with PayPal - it's fast, free and secure!\" name=\"submit\" src=\"https://www.paypal.com/en_US/i/btn/x-click-but21.gif\"  /> <input type=\"hidden\" value=\"-----BEGIN PKCS7-----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-----END PKCS7-----\" name=\"encrypted\"  />
  </div>
  <div id=\"donationmessage\">
  <p>Please support the hosting and continued development of this theme by making a Paypal donation (recommended US&#36;5.00).
  If you have donated or do not want to <a href=\"#\" onclick=\"donateHide()\">press here</a> to remove this reminder message.<br />
  NOTE: Firefox 1.0 users open <a href=\"$gconfig{'webprefix'}/donate.cgi\" target=\"_blank\">this link</a> and then refresh this page.
  </p>
  </div>
  </form>
  </div>";

  return $mods;
}

sub __logincss {
  my $logo = $gconfig{'webprefix'} . '/theme-stressfree/images/webminlogo.gif';
  if ( $gconfig{'product'} eq 'usermin' ) {
    $logo = $gconfig{'webprefix'} . '/theme-stressfree/images/userminlogo.gif';
  }
  if ( defined( $tconfig{'logo'} ) ) {
    if ( $tconfig{'logo'} ne "" ) {
      $logo = $tconfig{'logo'};
    }
  }

  my $css = "<style type=\"text/css\"><!--
        body {
            background: url($gconfig{'webprefix'}/theme-stressfree/images/background.gif) top left repeat-x #476DAB;
            font-family: 'Trebuchet MS', 'Bitstream Vera Sans', Verdana, Geneva, Arial, Helvetica, sans-serif;
            font-size: 12px;
            margin-top: 60px;
        }
        hr {
            display: none;
        }
        h3 {
            position: absolute;
            width: 100%;
            background: #faf9eb;
            font-size: 1.3em;
            border-bottom: 1px solid #333;
            padding: 8px 0 8px 0;
            margin: 0;
            text-align: center;
            top: 0;
            left: 0;
            color: #333;
            font-weight: normal;
        }
        table {
            border: 0px none;
            background: none;
        }
        center {
            background: url($gconfig{'webprefix'}/theme-stressfree/images/loginbackground.gif) top left no-repeat;
            width: 320px;
            height: 370px;
            margin: auto;
        }
        table.ui_table table {
            margin: 20px 25px 0 25px;
            width: 269px;
        }
        table tr {
            background: none;
        }
        table tr td {
            font-size: 10px;
            color: #666;
            border: 0px;
        }
        table tr td tt {
            font-family: 'Trebuchet MS', 'Bitstream Vera Sans', Verdana, Geneva, Arial, Helvetica, sans-serif;
        }
        table tr td b {
            font-weight: normal;
            font-size: 12px;
            color: black;
        }
        table tr.tabheader td {
            text-align: center;
            background: none;
            padding-top: 150px!important;
            background: url($logo) center 12px no-repeat;
        }
        table tr.tabheader td b {
            font-weight: normal;
            font-size: 18px;
            color: white;
        }
        table tr td.ui_label b {
        	display: block;
        	text-align: right;
        	padding-top: 3px;
        }
        table td.ui_value input.ui_textbox, table td.ui_value input.ui_password {
        	width: 140px;
        }
        INPUT {
            visibility: visible;
        }
        INPUT {
            background: white;
            font-family: 'Trebuchet MS', 'Bitstream Vera Sans', Verdana, Geneva, Arial, Helvetica, sans-serif;
            font-size: 12px;
            color: #070B2C;
        }
        INPUT[type=checkbox] {
            border: 1px solid #999;
            height: 12px;
            width: 12px;
            margin: 0px;
            margin-top: 3px;
            padding: 0px;
        }
        INPUT[type=submit] {
            border: 1px solid #666;
            padding: 4px;
            margin: 0px;
            margin-right: 30px;
            padding-top:1px;
            padding-bottom: 1px;
            font-weight: bold;
            background: url($gconfig{'webprefix'}/theme-stressfree/images/button.gif) repeat-x top left white;
        }
        INPUT[type=reset] {
            border: 1px solid #666;
            padding: 4px;
            padding-top:1px;
            padding-bottom: 1px;
            margin: 0px;
            margin-left: 30px;
            font-weight: bold;
            background: url($gconfig{'webprefix'}/theme-stressfree/images/button.gif) repeat-x top left white;
        }
        INPUT[type=submit]:hover {
            background: url($gconfig{'webprefix'}/theme-stressfree/images/button_hover.gif) repeat-x top left white;
        }
        INPUT[type=reset]:hover {
            background: url($gconfig{'webprefix'}/theme-stressfree/images/button_hover.gif) repeat-x top left white;
        }
        --></style>";
  return $css;
}

