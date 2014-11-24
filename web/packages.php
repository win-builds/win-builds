<!DOCTYPE html>
<html>
<head>
<?php
$page = 'packages';
$page_description = 'List of packages in the Win-builds distribution.';
$page_title = 'Package list';
include 'head.php';
?>
</head>

<body>
<?php
include 'header.html';

include 'packages_common.php';
$sizes = repository_sizes('@@VERSION@@');
$packages = load_repositories('@@VERSION@@');
?>

<h1>Package List</h1>

<p>
Size of packages: <?=$sizes['compressed']?>.
</p>
<p>
Size on disk: <?=$sizes['expanded']?>.
</p>

<?php
function print_p($title, $content) {
  if (isset($content) && $content !== "") {
    if (isset($title ) && $title !== "") {
      $sep = ': ';
    }
    else {
      $sep = '';
    }
    printf('<p>%s%s%s</p>', $title, $sep, $content);
  }
}

foreach ($packages as $package) {
  $name = $package['name'];

  printf('<h2 id="%s">%s %s - %s</h2>',
    $name, $name, $package['version'], $package['description']);

  print_p('Size',
    sprintf('%s (compressed), %s (expanded)',
      $package['size_compressed'],
      $package['size_expanded']
    )
  );

  printf('<p>Logs: ');
  foreach($package['filename'] as $host => $filename) {
    $bits = bits_of_triplet($host);
    printf('<a href="@@VERSION@@/logs/windows_%d/%s">%d bits</a> ',
      $bits, $name, $bits);
  }
  printf('</p>');

  printf('<p>Binaries: ');
  foreach($package['filename'] as $host => $filename) {
    $bits = bits_of_triplet($host);
    printf('<a href="@@VERSION@@/packages/windows_%d/%s">%d bits</a> ',
      $bits, $filename, $bits);
  }
  printf('</p>');

  /* print_p('Packager', $package['packager_name']); */

  print_p('Comments', $package['comments']);

  print_p('Predicates', $package['predicates']);
}

include 'footer.html';
?>
</body>
</html>
