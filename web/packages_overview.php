<!DOCTYPE html>
<html>
<head>
<?php
$page = 'packages_overview';
$page_description = 'List of packages in the Win-builds distribution.';
$page_title = 'Package list';
include 'head.php';
?>
</head>

<body>
<?php
include 'header.html';

echo "<h1>Package List</h1>";

include 'temp/packages_overview_data.php';

foreach ($packages as $package) {
  $name = $package[0];
  $version = $package[1];
  $build = $package[2];
  echo "<h2 id=\"$name\">$name</h2>";
  echo "<p>";
  echo "$name $version Build $build: <a href=\"logs/windows_32/$name\">32 bits</a> <a href=\"logs/windows_64/$name\">64 bits</a>";
  echo "</p>";
}

include 'footer.html';
?>
</body>
</html>
