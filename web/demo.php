<!DOCTYPE html>
<html>
<head>
<?php include 'head.html'; ?>
<script>
  function playback_rate(rate) {
    var video = document.getElementById('video');
    video.playbackRate = rate;
  }
  function hide_all() {
    var children = document.getElementById('captions').children;
    for (var i = 0; i < children.length; i++) {
      children[i].style.display = 'none';
    }
  }
  function reset_all() {
    hide_all();
    playback_rate(1);
  }
  function show(id) {
    var e = document.getElementById(id);
    if (e != null) {
      e.style.display = '';
    }
  }
  var data = [
    { start: 9,   cb: function() { reset_all(); show('caption-9')  } },
    { start: 16,  cb: function() { reset_all(); show('caption-16') } },
    { start: 21,  cb: function() { reset_all(); show('caption-21') } },
    { start: 36,  cb: function() { reset_all(); show('caption-36') } },
    { start: 41,  cb: function() { reset_all(); show('caption-41') } },
    { start: 44,  cb: function() { reset_all(); show('caption-44') } },
    { start: 52,  cb: function() { reset_all(); show('caption-52') } },
    { start: 74,  cb: function() { reset_all(); show('caption-74') } },
    { start: 101, cb: function() { reset_all(); show('caption-101') } },
    { start: 107, cb: function() { reset_all(); show('caption-107') } },
    { start: 116, cb: function() { reset_all(); show('caption-116') } },
    { start: 135, cb: function() { reset_all(); show('caption-135') } },
    { start: 140, cb: function() { reset_all(); show('caption-140'); playback_rate(4) } },
    { start: 160, cb: function() { hide_all() } },
    { start: 203, cb: function() { reset_all(); show('caption-203') } },
    { start: 210, cb: function() { reset_all(); show('caption-210') } },
    { start: 220, cb: function() { reset_all(); show('caption-220') } },
    { start: 233, cb: function() { reset_all(); show('caption-233') } },
    { start: 240, cb: function() { reset_all(); show('caption-240') } },
    { start: 245, cb: function() { reset_all(); show('caption-245') } },
    { start: 262, cb: function() { reset_all(); show('caption-262') } }
  ];
  data.reverse();
  function ontimeupdate_cb() {
    var video = document.getElementById('video');
    data.some(function(e, _i, _a) {
      if (e.start <= video.currentTime) {
        e.cb();
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
  <source src="win-builds-demo.webm#t=9" type="video/webm" />
  <source src="win-builds-demo.mp4#t=9" type="video/mp4" />
  Your browser does not support HTML5 video.
</video>
<div id="captions">
  <div id="caption-9" class="caption">
    First thing is to <a href=http://win-builds.org/@@VERSION@@>download the bootstrap binaries</a>.
  </div>
  <div id="caption-16" class="caption">
    This puts us on the documentation page which covers most scenarios and provides the detailled installation instructions.
  </div>
  <div id="caption-21" class="caption">
    The bootstrap binaries are packaged in a zip file for now (installer has not been rebuilt yet) and we will simply extract them on the desktop.
  </div>
  <div id="caption-36" class="caption">
    We then need a command prompt (until the installer is available).
  </div>
  <div id="caption-41" class="caption">
    Now, let's enter the directory that we've just extracted.
  </div>
  <div id="caption-44" class="caption">
    The YYPREFIX environment variable tells the 'yypkg' package manager which directory to install in.
  </div>
  <div id="caption-52" class="caption">
    'yypkg -init' will create directories and configuration files with default values.
  </div>
  <div id="caption-74" class="caption">
    The '-config -setpreds ...' allows filtering out packages: those which don't match the given predicate will not be installed. It is a safety option to avoid mixing i686 and x86_64 binaries by mistake.
  </div>
  <div id="caption-101" class="caption">
    Our last command starts the downloads and installation.
  </div>
  <div id="caption-107" class="caption">
    Packages are downloaded into 'var/cache/packages'.
  </div>
  <div id="caption-116" class="caption">
    There are around 60MB of data in this package series; it usually take one or two minutes.
  </div>
  <div id="caption-135" class="caption">
    Some packages like GCC are quite bigger than the average.
  </div>
  <div id="caption-140" class="caption">
    Playback speed is increased through JS during the package download.
  </div>
  <div id="caption-203" class="caption">
    Once everything is downloaded, installation starts. Packages install very quickly.
  </div>
  <div id="caption-210" class="caption">
    ENOENT errors above are harmless: many packages use POSIX symlinks; for few of these symlinks it's not yet possible to provide them on Windows.
  </div>
  <div id="caption-220" class="caption">
    POSIX symlinks to files are hardlinks and POSIX symlinks to directories are junction points; for our needs they provide a good equivalent to POSIX symlinks.
  </div>
  <div id="caption-233" class="caption">
    Installation finished.
  </div>
  <div id="caption-240" class="caption">
    The 'mingw' directory is an NTFS junction which replaces the original POSIX symlink.
  </div>
  <div id="caption-245" class="caption">
    Browsing around a bit and showing the various documentations, data and files that have been installed.
  </div>
  <div id="caption-262" class="caption">
    And last thing: listing all the packages that are now installed with the 'yypkg -list' command.
  </div>
</div>

<?php include 'footer.html'; ?>
</body>
</html>
