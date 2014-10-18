<!DOCTYPE html>
<html>
<head>
<?php $page = 'index'; include 'head.php'; ?>
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

<div id="package-list">
  <div id="package-list-header">
    <div class="arrow arrow-left" id="package-list-prev" onclick="set_packages(-3)"></div>
    <a id="package-list-all" href="@@VERSION@@/packages/windows_32/package_list.html">Full package list</a>
    <div class="arrow arrow-right" id="package-list-next" onclick="set_packages(3)"></div>
  </div>
  <div id="package-list-list" class="flexbox"></div>
</div>

<div id="screenshot" style="text-align: center;">
  <img alt="Screenshot of the win-builds GUI package manager" src="screenshot.png">
</div>

<?php include 'footer.html'; ?>
</body>
</html>
