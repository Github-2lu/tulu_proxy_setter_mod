import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tulu_proxy_setter/models/proxy.dart';
import 'package:tulu_proxy_setter/services/operations.dart';
import 'package:tulu_proxy_setter/ui/screens/proxy_table_screen.dart';
import 'package:tulu_proxy_setter/services/required_filepaths.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  Proxy? selectedProxy;
  List<Proxy>? proxies;
  Proxy? initialProxy;
  bool autoStartList = false;
  void _selectProxy() async {
    var proxy = await Navigator.of(context).push<Proxy?>(
      MaterialPageRoute(
        builder: (ctx) => ProxyTableScreen(
          proxies: proxies!,
          initSelectedProxy: selectedProxy,
        ),
      ),
    );
    setState(() {
      selectedProxy = proxy;
    });
  }

  void _getIniitialData() {
    createFolders();
    getInitialProxy().then((value) {
      setState(() {
        initialProxy = value;
      });
    });
    getProxies().then((value) {
      setState(() {
        proxies = value;
      });
    });

    getAutoStartStatus().then((value) {
      setState(() {
        autoStartList = value;
      });
    });
  }

  @override
  void initState() {
    _getIniitialData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    Widget content = const Center(
      child: CircularProgressIndicator(),
    );

    if (initialProxy != null && proxies != null) {
      content = Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text(
                    "Current Proxy",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text("Name: ${initialProxy!.name}"),
                  Text("Host: ${initialProxy!.host}"),
                  Text("Port: ${initialProxy!.port}"),
                  Text("No Proxy: ${initialProxy!.noProxy}")
                ],
              ),
              const SizedBox(
                width: 20,
              ),
              Column(
                children: [
                  const Text(
                    "Selected Proxy",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                      "Name: ${selectedProxy == null ? '' : selectedProxy!.name}"),
                  Text(
                      "Host: ${selectedProxy == null ? '' : selectedProxy!.host}"),
                  Text(
                      "Port: ${selectedProxy == null ? '' : selectedProxy!.port}"),
                  Text(
                      "No Proxy: ${selectedProxy == null ? '' : selectedProxy!.noProxy}")
                ],
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          IconButton(
            onPressed: () async {
              if (initialProxy!.name != "") {
                await Process.run("python3", [pythonFilePath, "-u"]);
                setState(() {
                  initialProxy =
                      Proxy(name: "", host: "", port: "", noProxy: "");
                });
              } else if (selectedProxy != null) {
                await Process.run("python3", [
                  pythonFilePath,
                  "-s",
                  selectedProxy!.name,
                  selectedProxy!.host,
                  selectedProxy!.port,
                  selectedProxy!.noProxy
                ]);
                setState(() {
                  initialProxy = selectedProxy;
                });
              }
            },
            icon: initialProxy!.host == ""
                ? Icon(
                    Icons.play_arrow,
                    size: min(screenWidth, screenHeight) * 0.3,
                  )
                : Icon(Icons.pause, size: min(screenWidth, screenHeight) * 0.3),
          ),
          ElevatedButton(
            onPressed: () {
              _selectProxy();
            },
            child: const Text("Choose Proxy"),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
              "These options are used to autostart single proxy or autostart list of proxies"),
          const Text("These options require restart"),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                  value: autoStartList,
                  onChanged: (value) async {
                    if (value == true) {
                      await Process.run("python3", [pythonFilePath, "-l"]);
                    } else {
                      await Process.run("python3", [pythonFilePath, "--ra"]);
                    }
                    setState(() {
                      autoStartList = value!;
                    });
                  }),
              const Text("AutoStart from list of proxies")
            ],
          )
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tulu Proxy Setter"),
      ),
      body: content,
    );
  }
}
