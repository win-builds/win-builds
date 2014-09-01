var package_list_div;
var current_index = 0;
var packages = [];

function set_packages(delta) {
  if (delta === undefined) { delta = 3 };
  package_list_div.innerHTML = "";
  current_index = (current_index + delta + packages.length) % packages.length;
  for (var j = 0; j < 3; j++) {
    var p = packages[(current_index + j) % packages.length];
    var box = document.createElement("div");
    var title = document.createElement("span");
    var descr = document.createElement("span");
    title.appendChild(document.createTextNode(p.name + " " + p.version));
    descr.appendChild(document.createTextNode(p.description));
    box.appendChild(title);
    box.appendChild(document.createElement("br"));
    box.appendChild(descr);
    box.classList.add("package-example");
    package_list_div.appendChild(box);
  }
}

var http_request = new XMLHttpRequest();
http_request.open("GET", "/package_list.json", true);
http_request.onreadystatechange = function() {
  var done = 4, ok = 200;
  if (http_request.readyState === done && http_request.status === ok) {
    var l = JSON.parse(http_request.responseText);

    var a_all = document.getElementById("package-list-all");
    a_all.removeChild(a_all.firstChild);
    a_all.appendChild(document.createTextNode(l.length + " packages (click for full list)"));

    package_list_div = document.getElementById("package-list-list");

    for (var i = 0; i < l.length; i++) {
      var index = Math.floor(Math.random() * l.length);
      packages.push(l[index]);
      l.splice(index, 1);
    }
    window.setInterval(set_packages, 7000);
    set_packages(3);
  }
};

http_request.send(null);
