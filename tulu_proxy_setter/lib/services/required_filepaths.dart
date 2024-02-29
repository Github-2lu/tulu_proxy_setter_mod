import 'dart:io';

final homePath = Platform.environment["HOME"];
final autoProxyFolderPath = "${homePath!}/.tuluproxysetter";

final autoStartFilesFolderPath = "$autoProxyFolderPath/autoStartFiles";
final proxyVarsFolderPath = "$autoProxyFolderPath/proxyVars";
const proxySetterFolderPath = "/etc/tuluproxysetter/proxySetter";
final autoStartDesktopFolderPath = "${homePath!}/.config/autostart";

final proxiesFilePath = "$autoStartFilesFolderPath/proxies.json";
const pythonFilePath = "$proxySetterFolderPath/proxyOP.py";
final autoStartFile = "$autoStartDesktopFolderPath/tuluautoproxy.desktop";
final currentProxypath = "$proxyVarsFolderPath/proxy";