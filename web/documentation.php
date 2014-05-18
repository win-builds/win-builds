
<!DOCTYPE html>
<html>
<head>
<?php $page = 'documentation'; include 'head.php'; ?>
</head>

<body>
<?php include 'header.html'; ?>

<h1>Table Of Contents</h1>
<ul>
  <li><a href="#package_lists">Package lists</a></li>
  <li><a href="#toolchain_switching">Toolchain switching</a></li>
  <li><a href="#package_updates">Package updates</a></li>
  <li><a href="#known_issues">Known issues</a></li>
  <li>On dedicated pages:
    <ul>
      <li><a href="msys-cygwin.html">MSYS and Cygwin</a></li>
      <li><a href="linux.html">Linux</a></li>
      <li><a href="diy.html">Build yourself</a></li>
      <li><a href="packaging.html">Packaging</a></li>
    </ul>
  </li>
</ul>

<h1 id="package_lists">Package lists</h1>
All series combined, there are around 65 packages. They are enough to buld 
GTK+ and EFL applications and also provide several networking components plus 
the toolchain itself.
<ul>
  <li>i686:
    <a href="packages/windows_32/package_list.html">Package list</a>
    <a href="logs/windows_32/">Build logs</a>
  </li>
  <li>x86_64:
    <a href="packages/windows_64/package_list.html">Package list</a>
    <a href="logs/windows_64/">Build logs</a>
  </li>
</ul>

<h1 id="toolchain_switching">Toolchain switching</h1>
<p>
  Since win-builds provides both 32 bits and 64 bits toolchains and doesn't 
  touch system settings, it is necessary to change these by hand.
</p>

  The only settings used are the <pre style="display: inline">PATH</pre> and 
  <pre style="display: inline">PKG_CONFIG_LIBDIR</pre> environment variables:

  <ul>
    <li>
      <pre style="display: inline">PATH</pre>:
      prepend <pre style="display: inline">&lt;install-dir&gt;\bin</pre>.
    </li>
    <li>
      <pre style="display: inline">PKG_CONFIG_LIBDIR</pre>:
      set to <pre style="display: inline">&lt;install-dir&gt;\lib\pkgconfig</pre> for 32 bits toolchains and <pre style="display: inline">&lt;install-dir&gt;\lib64\pkgconfig</pre> for 64 bits toolchains.
    </li>
  </ul>

<p>
  For Cygwin and MSYS, the preferred way to set these is through the win-builds-switch script as described in the <a href="msys-cygwin.html#_change_toolchain_on_the_fly">documentation for these</a>.
</p>

<p>
  If you are using bare cmd.exe or an IDE, you need to refer to their 
  respective documentations for detail on how to set tese environment variables.
</p>

<h1 id="package_updates">Package updates</h1>
<p>
  Yypkg handles the whole process of updating packages. More precisely, it will 
  make the system match the set of packages that are currently in the chosen 
  repository.
</p>

<h2>Simple (full) updates</h2>
<p>
  Browse for the win-builds installation you wish to update, enter the 'bin' 
  directory and double-click on yypkg.exe; it will retrieve the current package 
  list, display the list of updates and ask for confirmation before processing 
  them.
</p>

<h2>Selective updates</h2>
  Start a shell: cmd.exe, msys or cygwin. To start the update for all packages, run: <pre>yypkg --web</pre>

  In order to restrict the packages to consider for update, use the --packages argument: <pre>yypkg --web --packages &lt;package1&gt; &lt;package2&gt;</pre>

<h1 id="package_lists">Package lists</h1>
<p>
  <ul>
    <li>Graphical installer is being reworked and is not available yet.</li>
    <li>Windows XP/2k3 don’t handle junctions and even hardlinks very well, making their removal by hand difficult.</li>
  </ul>
</p>

<?php include 'footer.html'; ?>
</body>
</html>
