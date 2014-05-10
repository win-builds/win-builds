<!DOCTYPE html>
<html>
<head>
<?php $page = 'download'; include 'head.php'; ?>
</head>

<body>
<?php include 'header.html'; ?>

<h1>Windows</h1>

Installation on Windows can be done for MSYS, Cygwin or without them.
Download the <a href="@@VERSION@@/yypkg-@@VERSION@@.exe">package manager</a> (2MB) and:
<ul>
  <li>for use without MSYS or Cygwin: double-click on it</li>
  <li>for MSYS: run it from the command-line as <pre style="display: inline">yypkg-@@VERSION@@.exe --deploy --host msys</pre></li>
  <li>for Cygwin: run it from the command-line as <pre style="display: inline">yypkg-@@VERSION@@.exe --deploy --host cygwin</pre></li>
</ul>

<p>
It downloads and manages the complete set of packages (around 65MB compressed, 
400MB uncompressed).
</p>

<p>
More information can be found in the <a href="@@VERSION@@">documentation</a>; 
make sure to subscribe at least to the <a href="support.html">(security) 
announces mailing-list</a>.
</p>

<p>
If you have neither MSYS nor Cygwin installed but want to install one of them, 
refer to the <a href="@@VERSION@@/msys-cygwin.html">corresponding 
documentation</a>.
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
It shall be possible to use win-builds on other systems too even if this has not been tried so far. The main requirement is a POSIX system with a GNU userspace.
</p>

<?php include 'footer.html'; ?>
</body>
</html>
