<!DOCTYPE html>
<html>
<head>
<?php
$page = 'support';
$page_description = 'How to get support: bug tracker, mailing-list, IRC.';
$page_title = 'Support';
include 'head.php';
?>
</head>

<body>
<?php include 'header.html'; ?>

<h1>Bug Tracker</h1>
For most issues and feature wishes, you can use the <a href="/bugs">bug tracker</a>.

<h1>IRC</h1>
You can also join the #mingw-w64 channel on OFTC (or on freenode where messages 
will be relayed to OFTC).

<h1>Mailing-lists</h1>
<ul>
<?php
function print_list($name, $description) {
  printf('<li>');
  printf('%s: <code>%s@lists.win-builds.org</code><br>', $description, $name);
  printf('Send an empty mail titled <code>subscribe</code> to <a href="mailto:%s-request@lists.win-builds.org?subscribe">%s-request@lists.win-builds.org</a>. Unsubscribe works the same way.<br>',
    $name, $name);
  printf('<a href="/lists/%s">Browse archives</a>.', $name);
  printf('</li>');
}
?>
<?php
print_list('users', 'For all questions');
print_list('security', 'Announces for security updates');
print_list('announce', 'Announces for updates');
?>
  <li>The <a href="https://lists.sourceforge.net/lists/listinfo/mingw-w64-public">mingw-w64 mailing-list</a> can also be appropriate.
</ul>

<?php include 'footer.html'; ?>
</body>
</html>
