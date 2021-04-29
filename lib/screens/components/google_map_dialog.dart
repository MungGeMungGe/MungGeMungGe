import 'package:flutter/material.dart';
import 'package:mung_ge_mung_ge/models/location.dart';
import 'package:intl/intl.dart';

class GoogleMapDialog extends StatelessWidget {
  final Location location;
  final void Function(int locationSeq, String smokeDate, String smokeTime) addSmokeCount;

  GoogleMapDialog({
    required this.location,
    required this.addSmokeCount,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${location.name}'),
      content: Text('흡연 횟수: ${location.count}'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            var smokeDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
            var smokeTime = DateFormat("hh:mm:ss").format(DateTime.now());
            addSmokeCount(location.seq, smokeDate, smokeTime);
            Navigator.pop(context);
          },
          child: Text('흡연횟수 추가'),
        ),
      ],
    );
  }
}
