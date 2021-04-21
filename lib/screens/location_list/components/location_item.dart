import 'package:flutter/material.dart';
import 'package:mung_ge_mung_ge/models/mgLocation.dart';

class LocationItem extends StatelessWidget {
  LocationItem({
    required this.location,
    required this.clickFavorite,
  });

  final MgLocation location;
  final VoidCallback clickFavorite;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              location.name,
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              location.address_road,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            if (location.capacity != null)
              Text('${location.capacity}명 수용 가능'),
            if (location.institution != null)
              Text(location.institution!),
          ],
        ),
        Container(
          child: GestureDetector(
            onTap: () => clickFavorite(),
            child: Icon(location.favorite == true ? Icons.star : Icons.star_border),
          ),
        ),
      ],
    );
  }
}
