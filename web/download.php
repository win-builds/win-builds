<!DOCTYPE html>
<html>
<head>
<?php $page = 'download'; include 'head.php'; ?>
</head>

<body>
<?php include 'header.html'; ?>

<h1>Windows</h1>

Installation on Windows can be done for MSYS, Cygwin or without them.
Download the <a href="@@VERSION@@/yypkg-@@VERSION@@.exe">package manager</a> (2.3MB) and:
<ul>
  <li>for use without MSYS or Cygwin: double-click on it</li>
  <li>for MSYS: run it from the command-line as: <pre style="display: inline">yypkg-@@VERSION@@.exe --deploy --host msys</pre> and read <a href="@@VERSION@@/msys-cygwin.html#_change_toolchain_on_the_fly">how to switch to the toolchain you want</a>.</li>
  <li>for Cygwin: run it from the command-line as: <pre style="display: inline">yypkg-@@VERSION@@.exe --deploy --host cygwin</pre> and read <a href="@@VERSION@@/msys-cygwin.html#_change_toolchain_on_the_fly">how to switch to the toolchain you want</a>. It will use the toolchain provided through Cygwin.</li>
</ul>

<p>
Packages are 65MB and size on disk is 400MB. Note that installation doesn't
change system settings and in particular doesn't change environment variables
like PATH or PKG_CONFIG_PATH/LIBDIR.
</p>

<p>
More information can be found in the <a href="documentation.html">documentation</a>; make sure to subscribe at least to the <a href="support.html">(security)
announces mailing-list</a>.
</p>

<h1>Linux</h1>
<p>
Installation on Linux builds GCC locally in order to have binaries which match the current Linux distribution. The whole process is automated.
</p>

<p>
The detailled explanations are in the <a
href="@@VERSION@@/linux.html">documentation for Linux</a>.
</p>

<h1>Other systems</h1>
<p>
It shall be possible to use win-builds on other systems too even if this has
not been tried so far. The main requirement is a POSIX system with a GNU
userspace and building will follow the steps in the <a
href="@@VERSION@@/linux.html">documentation for Linux</a>.
</p>

<?php include 'footer.html'; ?>
</body>
</html>
