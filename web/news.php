<!DOCTYPE html>
<html>
<head>
<?php include 'head.html'; ?>
</head>

<body>
<?php include 'header.html'; ?>

<h1>News</h1>

<h3><a href="1.3-rc1">1.3-rc1 - 22/12/2013</a></h3>
  Fixed the "mingw" symlink in the root dir on windows.<br>
  Implement in C the logic to create and delete reparse points for the symlink
  fallback instead of calling mklink.exe (which is not available on XP).<br>
  Fixed wrong mirror in the Linux chroot.<br>
  Fix extra symlinks to gfortran binaries.<br>
  Restore .exe extensions for GCC files.<br>
  Some files weren't removed when uninstalling a package on Windows.<br>
  Update libjpeg (fixes
<a href="http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2013-6629">CVE-2013-6629</a>).<br>
  The OCaml cross-compiler was unable to build bindings to C libraries.<br>
  Check that the 'win-builds-switch.sh' script is called in the right way by the user.

<h3><a href="1.3-beta3">1.3-beta3 - 11/12/2013</a></h3>
  Fixes for dbus and yypkg.exe which was an old binary in 1.2, improved
  documentation, documentation for using with MSYS. The package metadata format
  changes (the version field is now a free-form string).

<h3><a href="1.3-beta2">1.3-beta2 - 4/12/2013</a></h3>
  Several fixes and mostly documentation or usability improvements.

<h3><a href="1.3-beta1">1.3-beta1 - 27/11/2013</a></h3>
  Improved symlink fallbacks on Windows, proofread documentation, new yypkg binaries for Windows, improved OCaml cross-compiler setup, general improvements and bug fixes.

<h3><a href="1.3-alpha2">1.3-alpha2 - 14/11/2013</a></h3>
  GCC 4.8, Mingw-w64 v3, package updates, nice symlink fallbacks on Windows (junctions and hardlinks as appropriate).

<h3><a href="1.2-rc1">1.2-rc1 - 02/04/2013</a></h3>
  Fixes an issue with less, GCC's spec file, its --libdir on i686, the location of libgcc_s_sjlj-1.dll and creates the GTK+ and Pango caches automatically .

<h3><a href="1.2-beta1">1.2-beta1 - 29/03/2013</a></h3>
  Stabilizes the native i686 compiler and adds an experimental x86_64 one. It includes a WIP OCaml cross-compiler to i686 and new yypkg binaries, built with it. On Windows, an SFX installer is provided.

<?php include 'footer.html'; ?>
</body>
</html>
