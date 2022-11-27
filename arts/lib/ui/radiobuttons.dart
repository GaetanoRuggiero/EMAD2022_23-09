import 'package:flutter/material.dart';

enum SearchFilter { city, name }

class RadioFilter extends StatefulWidget {
  const RadioFilter({Key? key}) : super(key: key);

  @override
  State<RadioFilter> createState() => _RadioFilterState();
}

class _RadioFilterState extends State<RadioFilter> {
  SearchFilter? _filter = SearchFilter.city;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Città"),
          Radio<SearchFilter>(
            value: SearchFilter.city,
            groupValue: _filter,
            onChanged: (SearchFilter? value) {
              setState(() {
                _filter = value;
              });
            },
          ),
          const Text("Opera"),
          Radio<SearchFilter>(
            value: SearchFilter.name,
            groupValue: _filter,
            onChanged: (SearchFilter? value) {
              setState(() {
                _filter = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
