import 'package:flutter/material.dart';
import 'package:tulu_proxy_setter/models/proxy.dart';
import 'package:tulu_proxy_setter/ui/widgets/proxy_form.dart';

enum MenuOptions { Edit, Delete }

class ContextMenu extends StatefulWidget {
  final Proxy proxy;
  final Function(String, Proxy?) onCheckProxyExist;
  final Function(Proxy) onAddProxy;
  final Function(Proxy) onRemoveProxy;
  const ContextMenu(
      {super.key,
      required this.proxy,
      required this.onCheckProxyExist,
      required this.onAddProxy,
      required this.onRemoveProxy});

  @override
  State<ContextMenu> createState() {
    return _ContextMenuState();
  }
}

class _ContextMenuState extends State<ContextMenu> {
  MenuOptions? selectedOption;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      initialValue: selectedOption,
      itemBuilder: (context) => [
        PopupMenuItem(
            onTap: () async {
              // print(widget.proxy.name);
              var proxy = await showDialog<Proxy>(
                  context: context,
                  builder: (ctx) => ProxyForm(
                        proxy: widget.proxy,
                        onCheckProxyExist: widget.onCheckProxyExist,
                      ));

              if (proxy != null) {
                widget.onRemoveProxy(widget.proxy);
                widget.onAddProxy(proxy);
              }
            },
            value: MenuOptions.Edit,
            child: Text(MenuOptions.Edit.name)),
        PopupMenuItem(
            onTap: () {
              widget.onRemoveProxy(widget.proxy);
            },
            value: MenuOptions.Delete,
            child: Text(MenuOptions.Delete.name))
      ],
    );
  }
}
