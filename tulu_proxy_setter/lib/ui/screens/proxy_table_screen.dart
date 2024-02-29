import 'package:flutter/material.dart';
import 'package:tulu_proxy_setter/models/proxy.dart';
import 'package:tulu_proxy_setter/services/operations.dart';
import 'package:tulu_proxy_setter/ui/widgets/context_menu.dart';
import 'package:tulu_proxy_setter/ui/widgets/proxy_form.dart';
import 'package:tulu_proxy_setter/ui/widgets/proxy_search.dart';

class ProxyTableScreen extends StatefulWidget {
  final List<Proxy> proxies;
  final Proxy? initSelectedProxy;
  const ProxyTableScreen(
      {super.key, required this.proxies, required this.initSelectedProxy});

  @override
  State<ProxyTableScreen> createState() {
    return _ProxyTableState();
  }
}

class _ProxyTableState extends State<ProxyTableScreen> {
  Proxy? selectedProxy;
  List<Proxy> selectedProxies = [];
  String searchText = "";

  bool _checkProxyExist(String name, final Proxy? exceptProxy) {
    for (final proxy in widget.proxies) {
      if (proxy == exceptProxy) {
        continue;
      }
      if (proxy.name == name) {
        return true;
      }
    }
    return false;
  }

  void _addProxy(final Proxy proxy) {
    widget.proxies.add(proxy);
    _searchProxyText();
    writeProxiesJson(widget.proxies);
  }

  void _removeProxy(final Proxy proxy) {
    widget.proxies.remove(proxy);
    _searchProxyText();
    writeProxiesJson(widget.proxies);
  }

  void _searchProxyText() {
    List<Proxy> tempProxies = [];

    for (final proxy in widget.proxies) {
      if (proxy.name.toLowerCase().contains(searchText)) {
        tempProxies.add(proxy);
      }
    }

    setState(() {
      selectedProxies = tempProxies;
    });
  }

  void _changeSearchText(String str) {
    searchText = str;
    _searchProxyText();
  }

  @override
  void initState() {
    super.initState();
    selectedProxy = widget.initSelectedProxy;
    _searchProxyText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Proxies"),
        leading: IconButton(
          onPressed: () {
            if (!widget.proxies.contains(selectedProxy)) {
              selectedProxy = null;
            }
            Navigator.of(context).pop(selectedProxy);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          ProxySearch(
            onSearchTextChange: _changeSearchText,
          ),
          const SizedBox(
            width: 10,
          ),
          IconButton(
            onPressed: () async {
              var proxy = await showDialog(
                context: context,
                builder: (ctx) => ProxyForm(
                  onCheckProxyExist: _checkProxyExist,
                ),
              );
              if (proxy != null) {
                _addProxy(proxy);
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: selectedProxies.length,
        itemBuilder: (context, index) => ListTile(
          leading: Checkbox(
            value: selectedProxy == selectedProxies[index],
            shape: const CircleBorder(),
            onChanged: (value) {
              setState(() {
                selectedProxy = selectedProxies[index];
              });
            },
          ),
          title: Text(selectedProxies[index].name),
          subtitle: Text(
              "host: ${selectedProxies[index].host}  port: ${selectedProxies[index].port}  noProxy: ${selectedProxies[index].noProxy}"),
          trailing: ContextMenu(
            proxy: selectedProxies[index],
            onCheckProxyExist: _checkProxyExist,
            onAddProxy: _addProxy,
            onRemoveProxy: _removeProxy,
          ),
        ),
      ),
    );
  }
}
