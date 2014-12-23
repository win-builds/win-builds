
<!DOCTYPE html>
<html>
<head>
<?php
$page = 'documentation';
$page_description = 'Documentation about installation, re-building, packaging, ...';
$page_title = 'Documentation';
include 'head.php';
?>
</head>

<body>
<?php include 'header.html'; ?>

<h1>Table Of Contents</h1>
<ul>
  <li><a href="#package_lists">Package lists</a></li>
  <li><a href="#toolchain_switching">Toolchain switching</a></li>
  <li><a href="#package_updates">Package updates</a>
    <ul>
      <li><a href="#package_updates__gui">Using the GUI</a></li>
      <li><a href="#package_updates__cli">Using the command-line Interface</a></li>
    </ul>
  </li>
  <li><a href="#win_builds_update">Updating from one win-builds release to another</a>
  <li><a href="#known_limitations">Known limitations</a>
    <ul>
      <li><a href="#known_limitations__proxies">Proxies</a></li>
    </ul>
  </li>
  <li>On dedicated pages:
    <ul>
      <li><a href="@@VERSION@@/msys-cygwin.html">MSYS and Cygwin</a></li>
      <li><a href="@@VERSION@@/linux.html">Linux and Build yourself</a></li>
      <li><a href="@@VERSION@@/packaging.html">Packaging</a></li>
    </ul>
  </li>
</ul>

<h1 id="package_lists">Package lists</h1>
All series combined, there are around 90 packages. They are enough to build 
GTK+, EFL and Qt applications and provide several networking components along 
with the toolchain itself.
<ul>
  <li>i686:
    <a href="@@VERSION@@/packages/windows_32/package_list.html">Package list</a>
    <a href="@@VERSION@@/logs/windows_32/">Build logs</a>
  </li>
  <li>x86_64:
    <a href="@@VERSION@@/packages/windows_64/package_list.html">Package list</a>
    <a href="@@VERSION@@/logs/windows_64/">Build logs</a>
  </li>
</ul>

<h1 id="toolchain_switching">Toolchain switching</h1>
<p>
  Since win-builds provides both 32 bits and 64 bits toolchains and doesn't 
  touch system settings, it is necessary to change these by hand.
</p>

  The only settings used are the <code>PATH</code> and 
  <code>PKG_CONFIG_LIBDIR</code> environment variables:

  <ul>
    <li>
      <code>PATH</code> (not on Cygwin):
      prepend <code>&lt;install-dir&gt;\bin</code>.
    </li>
    <li>
      <code>PKG_CONFIG_LIBDIR</code>:
      set to <code>&lt;install-dir&gt;\lib\pkgconfig</code> for 32 bits toolchains and <code>&lt;install-dir&gt;\lib64\pkgconfig</code> for 64 bits toolchains.
    </li>
  </ul>

<p>
  For Cygwin and MSYS, the preferred way to set these is through the win-builds-switch script as described in the <a href="@@VERSION@@/msys-cygwin.html#_change_toolchain_on_the_fly">documentation for these</a>.
</p>

<p>
  If you are using bare cmd.exe or an IDE, you need to refer to their 
  respective documentations for detail on how to set these environment
  variables.
</p>

<h1 id="package_updates">Package updates</h1>
<p>
  Yypkg handles the whole process of updating packages. More precisely, it will 
  make the system match the set of packages that are currently in the chosen 
  repository.
</p>

<h2 id="package_updates__gui">GUI</h2>
<p>
  Browse for the win-builds installation you wish to update, enter the 'bin' 
  directory and double-click on yypkg-@@VERSION@@.exe. The GUI will 
  appear, retrieve the current package list, display it and ask for
  confirmation before processing them.
</p>

<h2 id="package_updates__cli">Command-line</h2>
<p>
  Start a shell: cmd.exe, msys or cygwin. To start the update for all packages, 
run:
</p>
<pre>yypkg --web</pre>

<p>
  In order to restrict the packages to consider for update, use the --packages 
argument:
</p>
<pre>yypkg --web --packages &lt;package1&gt; &lt;package2&gt;</pre>

<h1 id="win_builds_update">Updating from one win-builds release to another</h1>
<p>
Starting with the the 1.4 release, it is possible to update easily from one 
version to another.
</p>

<p>
Simply download
<a href="@@VERSION@@/win-builds-@@VERSION@@.exe">win-builds-@@VERSION@@.exe</a> 
and replace the <code>bin/yypkg.exe</code> file from your installation with it. 
Then, double-click on this file, click on <code>Change Mirror</code> in the 
upper-left corner and replace <code>1.4.0</code> with <code>@@VERSION@@</code> 
in the URI.
</p>

<h1 id="known_limitations">Known limitations</h1>

<h2 id="known_limitations__proxies">Proxies</h2>
<p>
The yypkg package manager does not currently handle proxies. If the use of
proxies is required for your use of the Internet, you need to work-around the
issue until the next release (see <a
href="http://win-builds.org/bugs/index.php?do=details&amp;task_id=83&amp;project=1">
issue #83 in the bug tracker</a> for details).
</p>

<p>
The work-around involves downloading the files through a proxy-aware
application and pointing yypkg to them (the tutorial below uses
<code>wget</code> but any tool able to recursively download from
<code>HTTP</code> through proxies will work).
</p>

<p>
First set the <code>http_proxy</code> environment variable. For instance for
<code>cmd.exe</code>:
</p>
<pre>
set http_proxy=192.168.1.1:3142
</pre>

<p>
Run wget to mirror the files. For Windows, you can download a <a
href="wget-win-builds-for-proxies.tar.xz">portable installation of wget</a>.
The following command will create a directory named <code>@@VERSION@@</code>
suitable for both 32 and 64 bits.
</p>

<pre>
wget -r --no-parent --no-host-directories http://win-builds.org/@@VERSION@@/packages/
</pre>

<p>
Finally, <a href="@@VERSION@@/win-builds-@@VERSION@@.exe">download the
installer</a> and save it as <code>win-builds.exe</code> (or rename it
afterwards); run it by double-clicking on it. When prompted for the mirror,
provide the path to the <code>@@VERSION@@</code> directory that was created by
the mirroring process:
</p>
<pre>
C:\path\to\the\newly\created\directory\@@VERSION@@
</pre>

<p>
You should see a window similar to the following one. Note the middle field 
which prompts for a mirror.
</p>
<div style="text-align: center"><img src="install_mirror_path.png"></div>

<p>
When updating packages, simply re-run the <code>wget</code> command and then
double-click on <code>bin/yypkg.exe</code>.
</p>

<?php include 'footer.html'; ?>
</body>
</html>
