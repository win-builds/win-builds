<!DOCTYPE html>
<html>
<head>
<?php
$page = 'comparison';
$page_description = 'Differences and comparison with other toolchains and packaging systems.';
$page_title = 'Comparison';
include 'head.php';
?>
</head>

<body>
<?php include 'header.html'; ?>

<p>
There are several other environments based on
<a href="http://mingw-w64.sourceforge.net">mingw-w64</a>. More than one being 
universally better than others, they target different goals and use various 
approaches. This page attempts to explain how they compare to Win-builds.
</p>

<p>
The first usual difference is the release frequency and therefore the amount of 
testing that can go in packages. The belief behind Win-builds is that it is 
better to play it safe when targeting Windows and that there are already enough 
bugs in the software world to not try to get even more by being bleeding-edge 
at all costs (this doesn't mean settling for old software either).
</p>

<p>
The second typical difference is that only Win-builds runs on both Windows and 
Linux (and possibly others) with most of the files shared between platforms. 
This should matter especially if you are using several systems during your 
development.
</p>

<h3>Compared to <a href="http://cygwin.com">Cygwin</a></h3>
<p>
<a href="http://cygwin.com">Cygwin</a> is a POSIX-like environment which runs 
on Windows and is installed through a package manager.
</p>

<p>
It offers many packages but the executables are built against cygwin, i.e. they 
use its POSIX compatibility layer which makes system function calls much slower 
and has <a href="http://cygwin.com/licensing.html">licensing impacts</a>.
</p>

<p>
However it includes compilation toolchains that target Windows directly and 
which output won't use the POSIX layer.
</p>

<p>
It is best to think of building Windows applications on Cygwin as a special 
case of cross-compilation which can also run the applications that have been 
cross-compiled. Cygwin provides a great platform for doing the build and 
using many UNIX tools.
</p>

<p>
Cygwin itself has very few packages with executables which don't use the POSIX 
layer but Win-builds can be used to provide native libraries that your 
application will use.
</p>

<h3>With Fedora/RHEL/CentOS and OpenSuse</h3>
<p>
Packages in these Linux distributions have existed for several years. There are 
many of them and they are well-maintained. It's possible to use the library 
packages on another Linux distribution or on Windows but it's not trivial 
either and will require a compatible toolchain.
</p>

<h3>With <a href="http://mxe.cc">MXE</a></h3>
<p>
This is not a binary distribution but a set of build recipes which can be run 
by invoking <code>make</code>. It has a larger set of recipes but builds only 
static libraries which make updates more difficult and make it harder to comply 
with licenses such as the LGPL. It also does not run on Windows. Since it 
builds everything, it can take a long time to install.
</p>

<h3>With Mingw-builds</h3>

<p>
TBD. Few notable differences: very bleeding-edge, many patches, only runs on 
Windows.
</p>

<?php include 'footer.html'; ?>
</body>
</html>
