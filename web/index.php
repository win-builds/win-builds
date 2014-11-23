<!DOCTYPE html>
<html>
<head>
<?php
$page = 'index';
$page_description = 'Up-to-date, comprehensive and easy-to-use packaging system for Windows with a cute GUI.';
$page_title = '(Free) Software Packaging and Building For Windows';
include 'head.php';
?>
</head>

<body>
<?php include 'header.html'; ?>

<?php

include 'packages_common.php';
$packages = load_repositories('@@VERSION@@');
$package_count = count($packages);

?>

<h1>(Free) Software Building and Packaging For Windows</h1>

<p>
  Win-builds creates binary packages of libraries and tools for Windows from
  source. It provides a package manager and runs on Windows, MSYS, Cygwin and
  Linux. It is entirely free software.
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
      <li><a href="packages.html"><?=$package_count?> libraries and tools on Windows</a></li>
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
      <li>GCC <?=package_version($packages, 'gcc')?> - C, C++</li>
      <li>Mingw-w64 <?=package_version($packages, 'mingw-w64')?></li>
    </ul>
  </div>
  <div class="hl">
    <h2 class="hl-title">Scripted, clean, reproducible</h2>
    <ul class="hl-list">
      <li>Be in control of your infrastructure</li>
      <li>Customize as you wish</li>
      <li>Well-documented</li>
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
  <a href="download.html">
    <img alt="Screenshot of the win-builds GUI package manager" src="screenshot.png">
  </a>
</td>
<td>
  <div style="height: 548px; overflow-y: scroll;">
    <ul class="package-list">
<?php

foreach ($packages as $package) {
  $name = $package['name'];
  $version = $package['version'];
  $description = $package['description'];
  echo "<li class=\"package-list-item\"><a href=\"packages.html#$name\" title=\"$name $version - $description\">$name</a></li>";
}
?>
    </ul>
  </div>
</td>
</table>

<?php include 'footer.html'; ?>
</body>
</html>
