import 'package:flutter/material.dart';

class ProxySearch extends StatefulWidget {
  final Function(String) onSearchTextChange;
  const ProxySearch({super.key, required this.onSearchTextChange});

  @override
  State<ProxySearch> createState() {
    return _ProxySearch();
  }
}

class _ProxySearch extends State<ProxySearch> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    _searchController.text = "";
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(5),
      child: SizedBox(
        width: screenWidth * 0.3,
        child: TextFormField(
          decoration: const InputDecoration(hintText: "Search"),
          controller: _searchController,
          onChanged: (value) {
            if (value.length >= 2) {
              widget.onSearchTextChange(value);
            } else {
              widget.onSearchTextChange("");
            }
          },
        ),
      ),
    );
  }
}
