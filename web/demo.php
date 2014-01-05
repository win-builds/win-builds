<!DOCTYPE html>
<html>
<head>
<?php include 'head.html'; ?>
<script>
  var data = [
    { start: 0,   id: 'caption-0'   },
    { start: 7,   id: 'caption-7'   },
    { start: 15,  id: 'caption-15'  },
    { start: 21,  id: 'caption-21'  },
    { start: 24,  id: 'caption-24'  },
    { start: 29,  id: 'caption-29'  },
    { start: 39,  id: 'caption-39'  },
    { start: 54,  id: 'caption-54'  },
    { start: 65,  id: 'caption-65'  },
    { start: 87,  id: 'caption-87'  },
    { start: 117, id: 'caption-117' },
    { start: 128, id: 'caption-128' }
  ];

  data.reverse();

  function hide_all() {
    var children = document.getElementById('captions').children;
    for (var i = 0; i < children.length; i++) {
      children[i].style.display = 'none';
    }
  }

  function ontimeupdate_cb() {
    var video = document.getElementById('video');
    data.some(function(e, _i, _a) {
      if (e.start <= video.currentTime) {
        hide_all();

        var e = document.getElementById(e.id);
        if (e != null) {
          e.style.display = '';
        }

        return true;
      }
      else {
        return false;
      }
    })
  }
</script>
</head>

<body>
<?php include 'header.html'; ?>

<h1>Demo of the installation on Windows 2012</h1>

<video id="video" controls width="1024" height="768" ontimeupdate="ontimeupdate_cb()">
  <source src="win-builds-demo.webm#t=0" type="video/webm" />
  <source src="win-builds-demo.mp4#t=0" type="video/mp4" />
  Your browser does not support HTML5 video or doesn't handle either webm/vpx or mp4/h264.
</video>
<div id="captions">
  <div id="caption-0" class="caption">
    First thing is to <a href=http://win-builds.org/@@VERSION@@>download the bootstrap binaries</a>.
  </div>
  <div id="caption-7" class="caption">
    This puts us on the documentation page which covers most scenarios and provides the detailled installation instructions.
  </div>
  <div id="caption-15" class="caption">
    The bootstrap binaries are packaged in a zip file for now (installer has not been rebuilt yet) and we will simply extract them on the desktop.
  </div>
  <div id="caption-21" class="caption">
    For an installation outside of MSYS*/Cygwin, we simply run 'win-install.bat'.
  </div>
  <div id="caption-24" class="caption">
    It copies a few files, setups the installation directory and starts downloading the packages.<br>
    There is roughly 60MB of packages to download; it's usually one or two minutes of download (above is using a gigabit link).
  </div>
  <div id="caption-29" class="caption">
    Installation is fairly quick. Note that symlink-related messages are harmless.
  </div>
  <div id="caption-39" class="caption">
    After packages have been installed, the script will update fontconfig, pango, gdk and gtk+ caches.
  </div>
  <div id="caption-54" class="caption">
    The 32b variant has been installed. The script then installs the 64b variant.<br>
    Meanwhile we can look at a few things that have been installed.
  </div>
  <div id="caption-65" class="caption">
    Demo application of the <a href="http://gtk.org">GTK+</a> graphical toolkit (with a few rough corners on Windows currently).
  </div>
  <div id="caption-87" class="caption">
    Configuration application of <a href="http://enlightenment.org">Elementary</a>, another graphical toolkit.
  </div>
  <div id="caption-117" class="caption">
    Demo application of <a href="http://enlightenment.org">Elementary</a>, another graphical toolkit.
  </div>
  <div id="caption-128" class="caption">
    End of the demo. Check the <a href="stable">Documentation/Downloads</a> page for more infos.
  </div>
</div>

<?php include 'footer.html'; ?>
</body>
</html>
