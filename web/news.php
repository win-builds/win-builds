<!DOCTYPE html>
<html>
<head>
<?php
$page = 'news';
$page_description = 'News';
$page_title = 'News';
include 'head.php';
?>
</head>

<body>
<?php include 'header.html'; ?>

<h1><a href="1.5.0">1.5.0 - TBA</a></h1>
<h2><a href="1.5-rc2">1.5-rc2 - 03/12/2014</a></h2>
<ul>
  <li>GUI package manager</li>
  <li>GUI installer</li>
  <li>Much simpler installation on Linux</li>
  <li>Updated installation instructions for Linux which are more straight-forward and cover more distributions</li>
  <li>Single executable installer on Windows</li>
  <li>30 more packages</li>
  <li>Usual very long list of small improvements and version updates</li>
  <li>More automated builds of packages on Linux, drastically shortening package development cycles</li>
  <li>Completed the documentation on packaging</li>
  <li>Put back default include paths for GCC on Windows</li>
  <li>Simpler switching between toolchains</li>
</ul>

<h1><a href="1.4.0">1.4.0 - 25/05/2014</a></h1>
<h2><a href="1.4.0">1.4.0 final - 25/05/2014</a></h2>
<ul>
  <li>Documentation updates.</li>
  <li>Pango's cache is properly created at install.</li>
  <li>Post-inst actions failed if installation was not started from command-line.</li>
  <li>Fontconfig's font.conf had a hardcoded path.</li>
  <li>Yypkg retries downloads which have failed.</li>
  <li>Yypkg is fully compatible with OCaml 3.12.1.</li>
  <li>Checked build with Ubuntu 12.04.</li>
  <li>Yypkg always tries to guess its installation prefix now.</li>
  <li>Much improved download progress information.</li>
  <li>Add madplay and libid3tag (mostly to test libmad).</li>
  <li>Improved website.</li>
</ul>

<h2><a href="1.4-beta1">1.4-beta1 - 10/05/2014</a></h2>
<ul>
  <li>Merged all the package manager executables together.</li>
  <li>The package manager is now its own installer.</li>
  <li>Much simpler install process on Windows.</li>
  <li>Updated packages, numerous small fixes.</li>
  <li>Easier package updates.</li>
  <li>Removal of the chroot for Linux usage.</li>
  <li>Cleaner and faster build process on Linux.</li>
  <li>Updated documentation.</li>
</ul>

<h1><a href="1.3.0">1.3.0 - 11/01/2014</a></h1>
<h2><a href="1.3.0">1.3.0 final - 11/01/2014</a></h2>
<ul>
  <li>All executables in bin/ have the .exe extension now (applies to gcc.exe, openssl.exe, xmlwf.exe from expat).</li>
  <li>Many small fixes to the installer scripts for windows platforms.</li>
  <li>Update to mingw-w64 3.1.0 (maintenance release).</li>
  <li>Don't run gtk and gdk cache update tools on Cygwin on XP/2k3 (they crash); ask the user to run them from a fresh cmd.exe.</li>
  <li>The 'win-builds-switch' script used 'exit'; it now uses 'return'.</li>
</ul>

<h2><a href="1.3-rc1">1.3-rc1 - 22/12/2013</a></h2>
<ul>
  <li>Fixed the "mingw" symlink in the root dir on windows.</li>
  <li>Implement reparse point handling in Yypkg for the symlink
  <li>fallback instead of calling mklink.exe (unavailable on XP).</li>
  <li>Fixed wrong mirror in the Linux chroot.</li>
  <li>Fix extra symlinks to gfortran binaries.</li>
  <li>Restore .exe extensions for GCC files.</li>
  <li>Some files weren't removed when uninstalling a package on Windows.</li>
  <li>Update libjpeg (fixes <a href="http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2013-6629">CVE-2013-6629</a>).</li>
  <li>The OCaml cross-compiler was unable to build bindings to C libraries.</li>
  <li>Check that the 'win-builds-switch.sh' script is called in the right way by the user.</li>
</ul>

<h2><a href="1.3-beta3">1.3-beta3 - 11/12/2013</a></h2>
<ul>
  <li>Fixes for dbus and yypkg.exe which was an old binary in 1.2.</li>
  <li>Improved documentation, add documentation for using with MSYS.</li>
  <li>The package metadata format changes (version field is now a free-form string).</li>
</ul>

<h2><a href="1.3-beta2">1.3-beta2 - 4/12/2013</a></h2>
<ul>
  <li>Several fixes and mostly documentation or usability improvements.</li>
</ul>

<h2><a href="1.3-beta1">1.3-beta1 - 27/11/2013</a></h2>
<ul>
  <li>Improved symlink fallbacks on Windows.</li>
  <li>Proofread documentation.</li>
  <li>New yypkg binaries for Windows.</li>
  <li>Improved OCaml cross-compiler setup.</li>
  <li>General improvements and bug fixes.</li>
</ul>

<h2><a href="1.3-alpha2">1.3-alpha2 - 14/11/2013</a></h2>
<ul>
  <li>GCC 4.8, Mingw-w64 v3, package updates.</li>
  <li>Nice symlink fallbacks on Windows (junctions and hardlinks as appropriate).</li>
</ul>

<h1><a href="1.2-rc1">1.2-rc1 - 02/04/2013</a></h1>
<h2><a href="1.2-rc1">1.2-rc1 final - 02/04/2013</a></h2>
<ul>
  <li>Fixes an issue with less in the chroot.</li>
  <li>Fix GCC's spec file, its --libdir on i686 and the location of libgcc_s_sjlj-1.dll.</li>
  <li>Create the GTK+ and Pango caches automatically.</li>
</ul>

<h2><a href="1.2-beta1">1.2-beta1 - 29/03/2013</a></h2>
<ul>
  <li>Stabilizes the native i686 compiler and adds an experimental x86_64 one.</li>
  <li>Include a WIP OCaml cross-compiler to i686 and new yypkg binaries, built with it.</li>
  <li>On Windows, an SFX installer is provided.</li>
</ul>

<?php include 'footer.html'; ?>
</body>
</html>
