import 'package:flutter/material.dart';
import 'package:jsdict/models/models.dart';

class NameItem extends StatelessWidget {
  const NameItem({super.key, required this.name});

  final Name name;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => {},
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 22.0),
        title: Text(name.reading),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: name.meanings.map((e) => Text(e)).toList()
        )
      )
    );
  }
}