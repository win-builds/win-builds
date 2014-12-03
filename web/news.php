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

<h1><a href="1.4.0">1.4.0 - 25/05/2014</a></h1>
  Documentation updates.<br>
  Pango's cache is properly created at install.<br>
  Post-inst actions failed if installation was not started from command-line.<br>
  Fontconfig's font.conf had a hardcoded path.<br>
  Yypkg retries downloads which have failed.<br>
  Yypkg is fully compatible with OCaml 3.12.1.<br>
  Checked build with Ubuntu 12.04.<br>
  Yypkg always tries to guess its installation prefix now.<br>
  Much improved download progress information.<br>
  Add madplay and libid3tag (mostly to test libmad).<br>
  Improved website.<br>

<h1><a href="1.4-beta1">1.4-beta1 - 10/05/2014</a></h1>
  Merged all the package manager executables together.<br>
  The package manager is now its own installer.<br>
  Much simpler install process on Windows.<br>
  Updated packages, numerous small fixes.<br>
  Easier package updates.<br>
  Removal of the chroot for Linux usage.<br>
  Cleaner and faster build process on Linux.<br>
  Updated documentation.<br>

<h1><a href="1.3.0">1.3.0 - 11/01/2014</a></h1>
  All executables in bin/ have the .exe extension now (applies to gcc.exe, openssl.exe, xmlwf.exe from expat).<br>
  Many small fixes to the installer scripts for windows platforms.<br>
  Update to mingw-w64 3.1.0 (maintenance release).<br>
  Don't run gtk and gdk cache update tools on Cygwin on XP/2k3 (they crash); ask the user to run them from a fresh cmd.exe.<br>
  The 'win-builds-switch' script used 'exit'; it now uses 'return'.

<h1><a href="1.3-rc1">1.3-rc1 - 22/12/2013</a></h1>
  Fixed the "mingw" symlink in the root dir on windows.<br>
  Implement reparse point handling in Yypkg for the symlink
  fallback instead of calling mklink.exe (unavailable on XP).<br>
  Fixed wrong mirror in the Linux chroot.<br>
  Fix extra symlinks to gfortran binaries.<br>
  Restore .exe extensions for GCC files.<br>
  Some files weren't removed when uninstalling a package on Windows.<br>
  Update libjpeg (fixes
<a href="http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2013-6629">CVE-2013-6629</a>).<br>
  The OCaml cross-compiler was unable to build bindings to C libraries.<br>
  Check that the 'win-builds-switch.sh' script is called in the right way by the user.

<h1><a href="1.3-beta3">1.3-beta3 - 11/12/2013</a></h1>
  Fixes for dbus and yypkg.exe which was an old binary in 1.2.<br>
  Improved documentation, add documentation for using with MSYS.<br>
  The package metadata format changes (version field is now a free-form string).<br>

<h1><a href="1.3-beta2">1.3-beta2 - 4/12/2013</a></h1>
  Several fixes and mostly documentation or usability improvements.

<h1><a href="1.3-beta1">1.3-beta1 - 27/11/2013</a></h1>
  Improved symlink fallbacks on Windows.<br>
  Proofread documentation.<br>
  New yypkg binaries for Windows.<br>
  Improved OCaml cross-compiler setup.<br>
  General improvements and bug fixes.<br>

<h1><a href="1.3-alpha2">1.3-alpha2 - 14/11/2013</a></h1>
  GCC 4.8, Mingw-w64 v3, package updates.<br>
  Nice symlink fallbacks on Windows (junctions and hardlinks as appropriate).

<h1><a href="1.2-rc1">1.2-rc1 - 02/04/2013</a></h1>
  Fixes an issue with less in the chroot.<br>
  Fix GCC's spec file, its --libdir on i686 and the location of libgcc_s_sjlj-1.dll.<br>
  Create the GTK+ and Pango caches automatically .

<h1><a href="1.2-beta1">1.2-beta1 - 29/03/2013</a></h1>
  Stabilizes the native i686 compiler and adds an experimental x86_64 one.<br>
  Include a WIP OCaml cross-compiler to i686 and new yypkg binaries, built with it.<br>
  On Windows, an SFX installer is provided.

<?php include 'footer.html'; ?>
</body>
</html>
