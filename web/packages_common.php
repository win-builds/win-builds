<?php

function bits_of_triplet($bits) {
  switch ($bits) {
    case 'i686-w64-mingw32': return 32;
    case 'x86_64-w64-mingw32': return 64;
    default: return null;
  }
}

function version_without_build($version) {
  return preg_replace('/(.*)-\\d+/', '\1', $version);
}

function package_version($packages, $package) {
  return version_without_build($packages[$package]['version']);
}

function load_packages(&$packages, $file) {
  $xml = simplexml_load_file($file);
  foreach($xml->package as $package_node) {
    $name = (string) $package_node['name'];
    $host = (string) $package_node['host'];
    foreach($package_node->attributes() as $attr_key => $attr_value) {
      if ($attr_key === 'filename') {
        $packages[$name][$attr_key][$host] = (string) $attr_value;
      }
      else {
        $packages[$name][$attr_key] = (string) $attr_value;
      }
    }
    foreach($package_node->children() as $node_name => $node_content) {
      $packages[$name][$node_name] = (string) $node_content;
    }
  }
}

function load_repositories($version) {
  $l = [];
  load_packages($l, '../' . $version . '/packages/windows_32/package_list.xml');
  load_packages($l, '../' . $version . '/packages/windows_64/package_list.xml');
  return $l;
}

?>
