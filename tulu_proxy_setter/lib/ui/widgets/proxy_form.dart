import 'package:flutter/material.dart';
import 'package:tulu_proxy_setter/models/proxy.dart';
import 'package:tulu_proxy_setter/services/operations.dart';

class ProxyForm extends StatefulWidget {
  final Proxy? proxy;
  final Function(String, Proxy?) onCheckProxyExist;
  const ProxyForm({
    super.key,
    this.proxy,
    required this.onCheckProxyExist,
  });

  @override
  State<ProxyForm> createState() {
    return _ProxyFormState();
  }
}

class _ProxyFormState extends State<ProxyForm> {
  final _formkey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  var _enteredName = '';
  var _enteredHost = '';
  var _enteredPort = '';
  var _enteredNoProxy = '';
  bool isWifiNameAvailable = false;

  void _saveProxy() {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      // print(_enteredName);

      Navigator.of(context).pop(Proxy(
          name: _enteredName,
          host: _enteredHost,
          port: _enteredPort,
          noProxy: _enteredNoProxy));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getCurrentWifi().then((value) {
      setState(() {
        _enteredName = value;
        isWifiNameAvailable = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: CircularProgressIndicator(),
    );
    if (widget.proxy != null || isWifiNameAvailable == true) {
      content = AlertDialog(
        title: const Text("Add/Delete Proxy"),
        content: Form(
          key: _formkey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue:
                    widget.proxy == null ? _enteredName : widget.proxy!.name,
                decoration: const InputDecoration(
                    label: Text("Name"), hintText: "Enter name of the network"),
                maxLength: 50,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length > 50) {
                    return "Enter Name with less than 50 characters";
                  } else if (widget.onCheckProxyExist(value, widget.proxy)) {
                    return "Network Name already Exist";
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _enteredName = newValue!;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue:
                          widget.proxy == null ? '' : widget.proxy!.host,
                      decoration: const InputDecoration(
                          label: Text("Host"),
                          hintText:
                              "Enter host name with http or https or other"),
                      maxLength: 30,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().length > 30) {
                          return "Enter Host with less than 50 characters";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _enteredHost = newValue!;
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      initialValue:
                          widget.proxy == null ? '' : widget.proxy!.port,
                      decoration: const InputDecoration(
                          label: Text("Port"),
                          hintText: "Enter +ve interger as port number"),
                      maxLength: 5,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().length > 5) {
                          return "Enter Port with less than 5 characters";
                        } else if (int.tryParse(value) == null ||
                            int.tryParse(value)! < 0) {
                          return "Enter +ve integer value in port";
                        }
                        return null;
                      },
                      onSaved: ((newValue) {
                        _enteredPort = newValue!;
                      }),
                    ),
                  )
                ],
              ),
              TextFormField(
                initialValue: widget.proxy == null ? '' : widget.proxy!.noProxy,
                decoration: const InputDecoration(
                    label: Text("No Proxy"),
                    hintText: "Enter ip address which will not have proxy"),
                maxLength: 50,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length > 50) {
                    return "Enter No Proxy with less than 50 characters";
                  }
                  return null;
                },
                onSaved: ((newValue) {
                  _enteredNoProxy = newValue!;
                }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel")),
                  ElevatedButton(
                      onPressed: _saveProxy, child: const Text("Save"))
                ],
              )
            ],
          ),
        ),
      );
    }
    return content;
  }
}
