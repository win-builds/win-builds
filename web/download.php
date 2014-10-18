<!DOCTYPE html>
<html>
<head>
<?php $page = 'download'; include 'head.php'; ?>
</head>

<body>
<?php include 'header.html'; ?>

<h1>Windows</h1>

Installation on Windows can be done for MSYS, Cygwin or without them.
Download the <a href="@@VERSION_DEV@@/yypkg-@@VERSION_DEV@@.zip">package manager</a> (2.3MB), extract it and run bin/yypkg-@@VERSION_DEV@@.exe.

For MSYS or Cygwin, also read <a href="@@VERSION_DEV@@/msys-cygwin.html#_change_toolchain_on_the_fly">how to switch to the toolchain you want</a>.

<p>
Packages are 85MB and size on disk is 470MB. Note that installation doesn't
change system settings and in particular doesn't change environment variables
like <code>PATH</code>, <code>PKG_CONFIG_PATH</code> and <code>PKG_CONFIG_LIBDIR</code>.
</p>

<p>
More information can be found in the <a href="documentation.html">documentation</a>; make sure to subscribe at least to the <a href="support.html">(security)
announces mailing-list</a>.
</p>

<p>
NOTE: the 64 bits toolchain requires a 64 bits host; installing on Windows XP 
or 2003 might work but is unsupported.
</p>

<h1>Linux</h1>
<p>
No fully cross-distribution binaries can be realistically provided on Linux. As 
such the process is slightly longer and on a <a 
href="@@VERSION_DEV@@/linux.html">separate page in the documentation</a>.
</p>

<p>
The process should take around 5 minutes of user time and from 15 to 60 minutes 
of CPU time (modern desktop to Atom-class notebook).
</p>

<h1>Other systems</h1>
<p>
It shall be possible to use win-builds on other systems too even if this has
not been tried so far. The main requirement is a POSIX system with a GNU
userspace (<code>sed</code>, <code>cp</code>, etc.). Building will follow the 
steps in the <a href="@@VERSION_DEV@@/linux.html">documentation for Linux</a>.
</p>

<?php include 'footer.html'; ?>
</body>
</html>
