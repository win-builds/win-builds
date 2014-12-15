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

<?php

function print_toc($releases) {
  echo '<h1>Table Of Contents</h1>';

  echo '<ul>';
  foreach($releases as $rel) {
    printf('<li><a href="#%s-parent">%s - %s</a>',
      $rel['version'], $rel['version'], $rel['date']);
    printf('<ul>');
    foreach($rel['steps'] as $step) {
      printf('<li><a href="#%s">%s - %s</a></li>',
        $step['version'], $step['version'], $step['date']);
    }
    printf('</ul>');
    printf('</li>');
  }
  echo '</ul>';
}

function print_entries($releases) {
  foreach($releases as $rel) {
    printf('<h1><a href="%s" id="%s-parent">%s - %s</a></h1>',
      $rel['version'], $rel['version'], $rel['version'], $rel['date']);
    foreach($rel['steps'] as $steps) {
      printf('<h2><a href="%s" id="%s">%s - %s</a></h2>',
        $steps['version'], $steps['version'], $steps['version'], $steps['date']);
      printf('<ul>');
      foreach($steps['entries'] as $s) {
        printf('<li>%s</li>', $s);
      }
      printf('</ul>');
    }
  }
}

?>

<?php

$releases =
[
  [
    'version' => '1.5.0',
    'date' => 'TBA',
    'steps' =>
    [
      [
        'version' => '1.5-rc3',
        'date' => '15/12/2014',
        'entries' =>
        [
          'All applicable security updates done',
          'Package manager on Windows cleans upon exit',
          'Smaller installer on Windows',
          'libdvdread updated to videolan\'s version; libdvdnav and libdvdcss added',
          'Support for upgrading from 1.4 to 1.5 on Windows and Linux',
          'fribidi doesn\'t use glib\'s memory allocators anymore',
          'Cross-compilation support for qmake',
          'Much faster installation on Linux thanks to a stripped-down installatio of Qt',
          'Various improvements with the script which updates a shell with the right environment for the chosen toolchain on Linux and compatibility fixes for zsh',
        ]
      ],
      [
        'version' => '1.5-rc2',
        'date' => '03/12/2014',
        'entries' =>
        [
          'GUI package manager',
          'GUI installer',
          'Much simpler installation on Linux',
          'Updated installation instructions for Linux which are more straight-forward and cover more distributions',
          'Single executable installer on Windows',
          '30 more packages',
          'Usual very long list of small improvements and version updates',
          'More automated builds of packages on Linux, drastically shortening package development cycles',
          'Completed the documentation on packaging',
          'Put back default include paths for GCC on Windows',
          'Simpler switching between toolchains',
        ]
      ],
    ],
  ],
  [
    'version' => '1.4.0',
    'date' => '25/05/2014',
    'steps' =>
    [
      [
        'version' => '1.4.0',
        'date' => '25/05/2014',
        'entries' =>
        [
          'Documentation updates.',
          'Pango\'s cache is properly created at install.',
          'Post-inst actions failed if installation was not started from command-line.',
          'Fontconfig\'s font.conf had a hardcoded path.',
          'Yypkg retries downloads which have failed.',
          'Yypkg is fully compatible with OCaml 3.12.1.',
          'Checked build with Ubuntu 12.04.',
          'Yypkg always tries to guess its installation prefix now.',
          'Much improved download progress information.',
          'Add madplay and libid3tag (mostly to test libmad).',
          'Improved website.',
        ]
      ],
      [
        'version' => '1.4-beta1',
        'date' => '10/05/2014',
        'entries' =>
        [
          'Merged all the package manager executables together.',
          'The package manager is now its own installer.',
          'Much simpler install process on Windows.',
          'Updated packages, numerous small fixes.',
          'Easier package updates.',
          'Removal of the chroot for Linux usage.',
          'Cleaner and faster build process on Linux.',
          'Updated documentation.',
        ]
      ]
    ]
  ],
  [
    'version' => '1.3.0',
    'date' => '11/01/2014',
    'steps' =>
    [
      [
        'version' => '1.3.0',
        'date' => '11/01/2014',
        'entries' =>
        [
          'All executables in bin/ have the .exe extension now (applies to gcc.exe, openssl.exe, xmlwf.exe from expat).',
          'Many small fixes to the installer scripts for windows platforms.',
          'Update to mingw-w64 3.1.0 (maintenance release).',
          'Don\'t run gtk and gdk cache update tools on Cygwin on XP/2k3 (they crash); ask the user to run them from a fresh cmd.exe.',
          'The \'win-builds-switch\' script used \'exit\'; it now uses \'return\'.',
        ]
      ],
      [
        'version' => '1.3-rc1',
        'date' => '22/12/2013',
        'entries' =>
        [
          'Fixed the "mingw" symlink in the root dir on windows.',
          'Implement reparse point handling in Yypkg for the symlink fallback instead of calling mklink.exe (unavailable on XP).',
          'Fixed wrong mirror in the Linux chroot.',
          'Fix extra symlinks to gfortran binaries.',
          'Restore .exe extensions for GCC files.',
          'Some files weren\'t removed when uninstalling a package on Windows.',
          'Update libjpeg (fixes <a href="http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2013-6629">CVE-2013-6629</a>).',
          'The OCaml cross-compiler was unable to build bindings to C libraries.',
          'Check that the \'win-builds-switch.sh\' script is called in the right way by the user.',
        ]
      ],
      [
        'version' => '1.3-beta3',
        'date' => '11/12/2013',
        'entries' =>
        [
          'Fixes for dbus and yypkg.exe which was an old binary in 1.2.',
          'Improved documentation, add documentation for using with MSYS.',
          'The package metadata format changes (version field is now a free-form string).',
        ]
      ],
      [
        'version' => '1.3-beta2',
        'date' => '4/12/2013',
        'entries' =>
        [
          'Several fixes and mostly documentation or usability improvements.',
        ]
      ],
      [
        'version' => '1.3-beta1',
        'date' => '27/11/2013',
        'entries' =>
        [
          'improved symlink fallbacks on windows.',
          'proofread documentation.',
          'new yypkg binaries for windows.',
          'improved ocaml cross-compiler setup.',
          'general improvements and bug fixes.',
        ]
      ],
      [
        'version' => '1.3-alpha2',
        'date' => '14/11/2013',
        'entries' =>
        [
          'GCC 4.8, Mingw-w64 v3, package updates.',
          'Nice symlink fallbacks on Windows (junctions and hardlinks as appropriate).',
        ]
      ],
    ]
  ],
  [
    'version' => '1.2-rc1',
    'date' => '02/04/2013',
    'steps' =>
    [
      [
        'version' => '1.2-rc1',
        'date' => '02/04/2013',
        'entries' =>
        [
          'Fixes an issue with less in the chroot.',
          'Fix GCC\'s spec file, its --libdir on i686 and the location of libgcc_s_sjlj-1.dll.',
          'Create the GTK+ and Pango caches automatically.',
        ]
      ],
      [
        'version' => '1.2-beta1',
        'date' => '29/03/2013',
        'entries' =>
        [
          'Stabilizes the native i686 compiler and adds an experimental x86_64 one.',
          'Include a WIP OCaml cross-compiler to i686 and new yypkg binaries, built with it.',
          'On Windows, an SFX installer is provided.',
        ]
      ]
    ]
  ]
];

print_toc($releases);

print_entries($releases);

?>

<?php include 'footer.html'; ?>
</body>
</html>
