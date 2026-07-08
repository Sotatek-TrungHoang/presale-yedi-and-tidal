import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/ui/spacer.dart';

class AdvertLocation extends StatelessWidget {
  const AdvertLocation({required this.advert, super.key});

  final AdvertModel advert;

  @override
  Widget build(BuildContext context) {
    final address = advert.address;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Location",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        VSpacer(8),
        Text(address.formatted),
        VSpacer(20),
        if (address.coordinates != null) ...[
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: GoogleMap(
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  initialCameraPosition:
                      CameraPosition(target: address.coordinates!, zoom: 15),
                  mapType: MapType.normal,
                  markers: {
                    Marker(
                        markerId: MarkerId(address.id.toString()),
                        position: address.coordinates!)
                  }),
            ),
          ),
          VSpacer(20),
        ],
        ElevatedButton(
            onPressed: () {
              launchUrl(address.directionsUrl);
            },
            child: Text("Get Directions"))
      ],
    );
  }
}
