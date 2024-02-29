import 'dart:convert';
import 'dart:io';

import 'package:tulu_proxy_setter/models/proxy.dart';
import 'package:tulu_proxy_setter/services/required_filepaths.dart';

void createFolders() async {
  Process.run("mkdir", ["-p", autoStartFilesFolderPath]);
  Process.run("mkdir", ["-p", proxyVarsFolderPath]);
  Process.run("mkdir", ["-p", autoStartDesktopFolderPath]);
}

Future<List<Proxy>> getProxies() async {
  List<Proxy> proxies = [];
  try {
    File proxiesPtr = File(proxiesFilePath);

    String proxiesStr = await proxiesPtr.readAsString();
    List<dynamic> jsonObj = jsonDecode(proxiesStr);

    for (final jsonProxy in jsonObj) {
      proxies.add(Proxy.fromJson(jsonProxy));
    }
  } on Exception {
    print("File does not exist");
  }

  return proxies;
}

Future<Proxy> getInitialProxy() async {
  String name = "", host = "", port = "", noProxy = "";
  if (await File(currentProxypath).exists()) {
    var proxyFile = await File(currentProxypath).readAsLines();
    name = proxyFile[0].split("=")[1];
    host = proxyFile[1].split("=")[1].split(":")[0];
    port = proxyFile[1].split("=")[1].split(":")[1];

    for (final line in proxyFile) {
      if (line.contains("no_proxy")) {
        noProxy = line.split("=")[1];
      }
    }
  }
  return Proxy(name: name, host: host, port: port, noProxy: noProxy);
}

Future<bool> getAutoStartStatus() async {
  return await File(autoStartFile).exists();
}

void writeProxiesJson(List<Proxy> proxies) {
  final content = json.encode([for (final proxy in proxies) proxy.toJson()]);
  File proxyFile = File(proxiesFilePath);
  proxyFile.writeAsString(content);
}

Future<String> getCurrentWifi() async {
  var wifiName = "";
  try {
    var res = await Process.run("iwgetid", ["-r"]);
    wifiName = res.stdout.toString();
  } on Exception {
    wifiName = "";
  }
  return wifiName.split("\n")[0];
}
