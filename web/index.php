<!DOCTYPE html>
<html>
<head>
<?php
$page = 'index';
$page_description = 'Up-to-date, comprehensive and easy-to-use packaging system for Windows with GUI.';
$page_title = '(Free) Software Packaging and Building For Windows';
include 'head.php';
?>
<script>
<?php include 'package-list.js'; ?>
</script>
</head>

<body>
<?php include 'header.html'; ?>

<h1>Win-builds - (Free) Software Building and Packaging For Windows</h1>

<p>
  Win-builds creates binary packages of libraries and tools for Windows from
  source. It provides a package manager and runs on Windows, MSYS, Cygwin and
  Linux.
</p>

<div class="flexbox">
  <div class="hl">
    <h2 class="hl-title">From any OS</h2>
    <ul class="hl-list">
      <li>Run from MSYS, Cygwin or bare Windows</li>
      <li>On Linux, build only the cross-compiler, reuse all other packages</li>
      <li>Or use the virtual machines and containers</li>
    </ul>
  </div>
  <div class="hl">
    <h2 class="hl-title">Large, coherent set of packages</h2>
    <ul class="hl-list">
      <li>Qt, Curl, EFL, freetype, GTK+, lua, openssl, sqlite, wget, zlib, ...</li>
      <li><a href="@@VERSION@@/packages/windows_32/package_list.html">90 libraries and tools on Windows</a></li>
    </ul>
  </div>
  <div class="hl">
    <h2 class="hl-title">Quick and simple installs</h2>
    <ul class="hl-list">
      <li>Set up a complete development environment in 5 minutes on a broadband connection</li>
      <li>Test without any setup thanks to prepared virtual machines</li>
      <li>GUI for easy usage</li>
    </ul>
  </div>
  <div class="hl">
    <h2 class="hl-title">32/64bits</h2>
    <ul class="hl-list">
      <li>GCC 4.8.3 - C, C++</li>
      <li>Mingw-w64 3.2.0</li>
    </ul>
  </div>
  <div class="hl">
    <h2 class="hl-title">Scripted, clean, reproducible</h2>
    <ul class="hl-list">
      <li>Be in control of your infrastructure</li>
      <li>Customize as you wish</li>
      <li>Fully-documented</li>
    </ul>
  </div>
  <div class="hl">
    <h2 class="hl-title">Security updates</h2>
    <ul class="hl-list">
      <li>Packages get security updates</li>
      <li><a href="support.html">Announces and security advisories through mailing-lists</a></li>
    </ul>
  </div>
</div>

<table style="margin: auto;"><tr>
<td id="screenhot">
  <img alt="Screenshot of the win-builds GUI package manager" src="screenshot.png">
</td>
<td>
  <div style="height: 548px; overflow-y: scroll;">
    <ul class="package-list">
      <li class="package-list-item">SDL2</li>
      <li class="package-list-item">a52dec</li>
      <li class="package-list-item">atk</li>
      <li class="package-list-item">binutils</li>
      <li class="package-list-item">c-ares</li>
      <li class="package-list-item">ca-certificates</li>
      <li class="package-list-item">cairo</li>
      <li class="package-list-item">check</li>
      <li class="package-list-item">curl</li>
      <li class="package-list-item">dbus</li>
      <li class="package-list-item">dejavu-fonts-ttf</li>
      <li class="package-list-item">djvulibre</li>
      <li class="package-list-item">efl</li>
      <li class="package-list-item">elementary</li>
      <li class="package-list-item">expat</li>
      <li class="package-list-item">ffmpeg</li>
      <li class="package-list-item">flac</li>
      <li class="package-list-item">fontconfig</li>
      <li class="package-list-item">freetype</li>
      <li class="package-list-item">fribidi</li>
      <li class="package-list-item">gcc</li>
      <li class="package-list-item">gdb</li>
      <li class="package-list-item">gdk-pixbuf2</li>
      <li class="package-list-item">gendef</li>
      <li class="package-list-item">genidl</li>
      <li class="package-list-item">genpeimg</li>
      <li class="package-list-item">gettext</li>
      <li class="package-list-item">giflib</li>
      <li class="package-list-item">glib-networking</li>
      <li class="package-list-item">glib2</li>
      <li class="package-list-item">gmp</li>
      <li class="package-list-item">gnutls</li>
      <li class="package-list-item">gperf</li>
      <li class="package-list-item">gtk+2</li>
      <li class="package-list-item">harfbuzz</li>
      <li class="package-list-item">icu4c</li>
      <li class="package-list-item">jansson</li>
      <li class="package-list-item">json-c</li>
      <li class="package-list-item">lame</li>
      <li class="package-list-item">lcms</li>
      <li class="package-list-item">lcms2</li>
      <li class="package-list-item">libao</li>
      <li class="package-list-item">libarchive</li>
      <li class="package-list-item">libdvdread</li>
      <li class="package-list-item">libffi</li>
      <li class="package-list-item">libgcrypt</li>
      <li class="package-list-item">libgpg-error</li>
      <li class="package-list-item">libid3tag</li>
      <li class="package-list-item">libjpeg</li>
      <li class="package-list-item">libmad</li>
      <li class="package-list-item">libmangle</li>
      <li class="package-list-item">libmpc</li>
      <li class="package-list-item">libmpeg2</li>
      <li class="package-list-item">libogg</li>
      <li class="package-list-item">libpng</li>
      <li class="package-list-item">libsigc++</li>
      <li class="package-list-item">libsndfile</li>
      <li class="package-list-item">libsoup</li>
      <li class="package-list-item">libtasn1</li>
      <li class="package-list-item">libtheora</li>
      <li class="package-list-item">libtiff</li>
      <li class="package-list-item">libvorbis</li>
      <li class="package-list-item">libxml2</li>
      <li class="package-list-item">libxslt</li>
      <li class="package-list-item">lua</li>
      <li class="package-list-item">madplay</li>
      <li class="package-list-item">make</li>
      <li class="package-list-item">mingw-w64</li>
      <li class="package-list-item">mpfr</li>
      <li class="package-list-item">nettle</li>
      <li class="package-list-item">openjpeg</li>
      <li class="package-list-item">openssl</li>
      <li class="package-list-item">opus</li>
      <li class="package-list-item">pango</li>
      <li class="package-list-item">pcre</li>
      <li class="package-list-item">pixman</li>
      <li class="package-list-item">pkg-config</li>
      <li class="package-list-item">qt</li>
      <li class="package-list-item">sox</li>
      <li class="package-list-item">sqlite</li>
      <li class="package-list-item">wget</li>
      <li class="package-list-item">widl</li>
      <li class="package-list-item">win-iconv</li>
      <li class="package-list-item">winpthreads</li>
      <li class="package-list-item">winstorecompat</li>
      <li class="package-list-item">x264</li>
      <li class="package-list-item">xz</li>
      <li class="package-list-item">zlib</li>
      <li class="package-list-item">zz_config</li>
    </ul>
  </div>
</td>
</table>

<?php include 'footer.html'; ?>
</body>
</html>
