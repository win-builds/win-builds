<!DOCTYPE html>
<html>
<head>
<?php include 'head.html'; ?>
</head>

<body>
<?php include 'header.html'; ?>

<h1>Support</h1>

<h2>Bug Tracker</h2>
For most issues and feature wishes, you can use the <a href="bugs">bug tracker</a>.

<h2>IRC</h2>
You can also join the #mingw-w64 channel on OFTC (or on freenode where messages 
will be relayed to OFTC).

<h2>Mailing-lists</h2>
<ul>
<?php
function print_list($name, $description) {
  printf('<li>');
  printf('%s: <code>%s AT lists.win-builds.org</code><br>', $description, $name);
  printf('Subscribe by sending an email titled <code>subscribe</code> to <code>%s-request AT lists.win-builds.org</code>. Unscribe instructions are similar.<br>',
    $name);
  printf('<a href="/lists/%s">Archives can be browsed freely</a>.', $name);
  printf('</li>');
}
?>
<?php
print_list('users', 'For all questions related to win-builds');
print_list('security', 'To receive notifications about security updates');
print_list('announce', 'To receive notifications about new versions');
?>
  <li>The <a href="https://lists.sourceforge.net/lists/listinfo/mingw-w64-public">mingw-w64 mailing-list</a> can also be appropriate.
</ul>

<h2>Mail</h2>
If really none of the above fits your situation, you can send an e-mail to adrien AT notk.org.

<?php include 'footer.html'; ?>
</body>
</html>
