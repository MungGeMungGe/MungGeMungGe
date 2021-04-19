import 'package:flutter/material.dart';
import 'package:mung_ge_mung_ge/models/location.dart';

class GoogleMapDialog extends StatelessWidget {
  final Location location;

  GoogleMapDialog({
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${location.name}'),
      content: Text('${location.seq}'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('흡연횟수 추가'),
        ),
      ],
    );
  }
}
