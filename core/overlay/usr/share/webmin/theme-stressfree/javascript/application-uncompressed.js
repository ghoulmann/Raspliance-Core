var webminpath = '';
var searchVisible = false;
var gearsVisible = false;

// The following path code has been supplied by Rob Shinn:
// http://www.stress-free.co.nz/stressfree_webmin_theme_version_204_released#comment-19519
function dirname(path) {
	return path.match( /.*\// );
}

function basename(path) {
	return path.replace( /.*\//, "" );
}

// This code is ugly, but it does identify what the derived path is.
var myParent = dirname(location.pathname)[0];
if (myParent != "/") {
	var testPath = dirname(myParent.substring(0,myParent.lastIndexOf('/')-1))[0];
	var testPath1 = testPath.substring(0,testPath.lastIndexOf('/'));
}
if (myParent.indexOf('link.cgi', 0) >= 0) {
	if (basename(testPath1) == 'link.cgi') {
		webminpath = myParent;
	} else {
		webminpath = testPath;
	}
} else {
	webminpath = '';
}

function initialize(path) {
  // Set the path if it has not already been defined
  if (path != '') {
	  webminpath = path;
  }

  var prev_onload = window.onload;
  window.onload = function() {
    if (prev_onload != null) {
      prev_onload();
    }
    if($('gearslink') != undefined) {
        $('gearslink').className = webminGears.status_class();
    }
    loadSidebar();

    new Ajax.Autocompleter("searchfield", "searchfield_choices", webminpath
        + "/search.cgi", {
      paramName : "Search",
      minChars : 2,
      afterUpdateElement : openUrl
    });
  }
}

function loadSidebar() {
  if (Cookie.get('sidebar') == 'true') {
    // Display the sidebar
    displaySidebar();
  }
}

function switchSidebar() {
  var sidebarClass = $('contenttable').className;
  var visible = true;

  if (sidebarClass == 'sidebar-hidden') {
    visible = false;
  }
  if (!visible) {
    // Display the sidebar
    displaySidebar();
  } else {
    // Hide the sidebar
    hideSidebar();
  }
}

function displaySidebar() {
  // Display the systats sidebar div
  refreshSidebar();
  Cookie.set('sidebar', 'true', 365);
  $('contenttable').className = 'sidebar-visible';
  $('sidebar').className = 'sidebar-visible';
  $('sysstats-open').style.display = 'none';
}

function hideSidebar() {
  // Hide the systats sidebar div
  Cookie.set('sidebar', 'false', 365);
  $('contenttable').className = 'sidebar-hidden';
  $('sidebar').className = 'sidebar-hidden';
  $('sysstats-open').style.display = 'block';
}

function refreshSidebar() {
  // Load the systats into the sidebar div
  var sidebarUrl = webminpath + '/sysstats.cgi';
  new Ajax.Updater('sidebar-info', sidebarUrl, {
    asynchronous : true
  });
}

function viewSearch() {
  if (!searchVisible) {
    if (gearsVisible) {
      webminGears.message_view();
    }
    $('searchbutton').className = 'search-selected';
    $('searchform').style.display = 'block';
    $('searchfield').focus();
    searchVisible = true;
  } else {
    $('searchbutton').className = 'search-notselected';
    $('searchform').style.display = 'none';
    searchVisible = false;
  }
  return false;
}

function showLogs() {
  var url = '' + window.location;
  var sl1 = url.indexOf('//');
  var mod = '';
  if (sl1 > 0) {
    var sl2 = url.indexOf('/', sl1 + 2);
    if (sl2 > 0) {
      var sl3 = url.indexOf('/', sl2 + 1);
      if (sl3 > 0) {
        mod = url.substring(sl2 + 1, sl3);
      } else {
        mod = url.substring(sl2 + 1);
      }
    }
  }
  var sl4 = mod.indexOf('?');
  if (sl4 >= 0) {
    mod = mod.substring(0, sl4);
  }
  if (mod && mod.indexOf('.cgi') <= 0) {
    // Show one module's logs
    document.sfViewModuleLogs.module.value = mod;
    document.sfViewModuleLogs.submit();
  } else {
    document.sfViewAllLogs.submit();
  }
}

function openUrl() {
  // Open the url specified by the selected search result
  var url = webminpath + '/' + $('searchfield').value;
  document.location.href = url;
}

function donateHide() {
  // Load the donate page into the donation div
  var donateUrl = webminpath + '/donate.cgi';
  new Ajax.Updater('donation', donateUrl, {
    asynchronous : true
  });
}

// Prototype/Cookie code from http://gorondowtl.sourceforge.net/wiki/Cookie
var Cookie = {
  set : function(name, value, daysToExpire) {
    var expire = '';
    if (daysToExpire != undefined) {
      var d = new Date();
      d.setTime(d.getTime() + (86400000 * parseFloat(daysToExpire)));
      expire = '; expires=' + d.toGMTString();
    }
    return (document.cookie = escape(name) + '=' + escape(value || '')
        + expire);
  },
  get : function(name) {
    var cookie = document.cookie.match(new RegExp(
        '(^|;)\\s*' + escape(name) + '=([^;\\s]*)'));
    return (cookie ? unescape(cookie[2]) : null);
  },
  erase : function(name) {
    var cookie = Cookie.get(name) || true;
    Cookie.set(name, '', -1);
    return cookie;
  },
  accept : function() {
    if (typeof navigator.cookieEnabled == 'boolean') {
      return navigator.cookieEnabled;
    }
    Cookie.set('_test', '1');
    return (Cookie.erase('_test') === '1');
  }
};

webminGears = {

  createStore : function() {
    if ('undefined' == typeof google || !google.gears)
      return;

    if ('undefined' == typeof localServer) {
      localServer = google.gears.factory.create("beta.localserver");
    }
    var manifestUrl = webminpath + '/manifest.cgi';
    store = localServer.createManagedStore('webminGears');
    store.manifestUrl = manifestUrl;
    store.checkForUpdate();
    this.message();
  },

  getPermission : function() {
    if ('undefined' != typeof google && google.gears) {
      if (!google.gears.factory.hasPermission) {
        google.gears.factory.getPermission('webminGears',
            '/theme-stressfree/images/webminlogo.gif');
      }
      try {
        this.createStore();
      } catch (e) {
      } // silence if canceled
    }
  },

  message_version : function() {
    var t = this, msg4 = $('gears-msg4'), mfver = $('mfver');
    msg4.style.display = store.currentVersion ? 'block' : 'none';
    if (mfver)
      mfver.innerHTML = store.currentVersion;
  },

  message : function(show) {
    var t = this, msg1 = $('gears-msg1'), msg2 = $('gears-msg2'), msg3 = $('gears-msg3'), num = $('gears-upd-number'), wait = $('gears-wait');
    var msg4 = $('gears-msg4'), mfver = $('mfver');

    if (!msg1)
      return;

    if ('undefined' != typeof google && google.gears) {
      if (google.gears.factory.hasPermission) {
        msg1.style.display = msg2.style.display = 'none';
        msg3.style.display = 'block';

        if ('undefined' == typeof store)
          t.createStore();

        store.oncomplete = function() {
          wait.innerHTML = ' <strong>update completed..</strong>';
          t.message_version();
        };
        store.onerror = function() {
          wait.innerHTML = ' <br /><strong>error:</strong>' + store.lastErrorMessage + '<br />';
          t.message_version();
        };
        store.onprogress = function(e) {
          if (msg4.style.display != 'block')
            t.message_version();
          if (num)
            num.innerHTML = (' ' + e.filesComplete + ' / ' + e.filesTotal);
        };

      } else {
        msg1.style.display = msg3.style.display = msg4.style.display = 'none';
        msg2.style.display = 'block';
      }
    }
  },

  message_view : function() {
    if (searchVisible) {
      viewSearch();
    }
    if (!gearsVisible) {
      var t = this;
      t.message();
      gearsVisible = true;
      $('gearsstatus').className = 'gearsstatus-selected';
      $('gears-info-box').style.display = 'block';
    } else {
      gearsVisible = false;
      $('gearsstatus').className = 'gearsstatus-notselected';
      $('gears-info-box').style.display = 'none';
    }
  },

  status_class : function() {

    var status = 'gears-disabled';

    if ('undefined' != typeof google && google.gears) {
      if (google.gears.factory.hasPermission) {
        status = 'gears-enabled';
      }
    }
    return status;
  }
};

// Copyright 2007, Google Inc.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
// 3. Neither the name of Google Inc. nor the names of its contributors may be
// used to endorse or promote products derived from this software without
// specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
// WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
// EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
// OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
// OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// Sets up google.gears.*, which is *the only* supported way to access Gears.
//
// Circumvent this file at your own risk!
//
// In the future, Gears may automatically define google.gears.* without this
// file. Gears may use these objects to transparently fix bugs and compatibility
// issues. Applications that use the code below will continue to work seamlessly
// when that happens.

( function() {
  // We are already defined. Hooray!
  if (window.google && google.gears) {
    return;
  }

  var factory = null;

  // Firefox
  if (typeof GearsFactory != 'undefined') {
    factory = new GearsFactory();
  } else {
    // IE
    try {
      factory = new ActiveXObject('Gears.Factory');
      // privateSetGlobalObject is only required and supported on IE
      // Mobile on
      // WinCE.
      if (factory.getBuildInfo().indexOf('ie_mobile') != -1) {
        factory.privateSetGlobalObject(this);
      }
    } catch (e) {
      // Safari
      if ((typeof navigator.mimeTypes != 'undefined')
          && navigator.mimeTypes["application/x-googlegears"]) {
        factory = document.createElement("object");
        factory.style.display = "none";
        factory.width = 0;
        factory.height = 0;
        factory.type = "application/x-googlegears";
        document.documentElement.appendChild(factory);
      }
    }
  }

  // *Do not* define any objects if Gears is not installed. This mimics the
  // behavior of Gears defining the objects in the future.
  if (!factory) {
    return;
  }

  // Now set up the objects, being careful not to overwrite anything.
  //
  // Note: In Internet Explorer for Windows Mobile, you can't add properties
  // to
  // the window object. However, global objects are automatically added as
  // properties of the window object in all browsers.
  if (!window.google || 'undefined' == typeof google) {
    google = {};
  }

  if (!google.gears) {
    google.gears = {
      factory : factory
    };
  }
})();