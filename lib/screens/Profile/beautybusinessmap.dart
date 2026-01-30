import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/screens/Mackeups/salondetail.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BeautyBusinessMap extends StatefulWidget {
  String lat, long, salonname, opendays, id;
  BeautyBusinessMap({
    super.key,
    required this.lat,
    required this.long,
    required this.salonname,
    required this.opendays,
    required this.id,
  });

  @override
  State<BeautyBusinessMap> createState() => _BeautyBusinessMapState();
}

class _BeautyBusinessMapState extends State<BeautyBusinessMap> {
  GoogleMapController? mapController;
  List<Marker> markers = [];

  void addMarker(
    LatLng position,
    String salonname,
    String opendays,
    String salonid,
  ) async {
    final markerId = MarkerId(position.toString());

    final BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(10, 10)),
      'lib/assets/images/marker@2x.png',
    );
    print("position.toString() = ${position.toString()}");

    markers.add(
      Marker(
        markerId: markerId,
        position: position,
        infoWindow: InfoWindow(
          title: salonname,
          snippet: opendays,
          onTap: () {
            print("SalonDetailScreen");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => SalonDetailScreen(id: salonid, userType: "2"),
              ),
            );
          },
        ),
        icon: customMarker,
      ),
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    addMarker(
      LatLng(double.parse(widget.lat), double.parse(widget.long)),
      widget.salonname,
      widget.opendays,
      widget.id.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size kSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.kWhiteColor,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.kAppBArBGColor,
        automaticallyImplyLeading: false,
        elevation: 2.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                InkWell(
                  overlayColor: const MaterialStatePropertyAll(
                    AppColors.kWhiteColor,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Image.asset(ImageUtils.leftarrow),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  Languages.of(context)!.mapText,
                  style: Pallete.Quicksand16drkBlackBold,
                ),
              ],
            ),
          ],
        ),
      ),
      body: SizedBox(
        height: kSize.height,
        width: kSize.width,
        child: GoogleMap(
          key: ValueKey(markers.length),
          gestureRecognizers:
              Set()
                ..add(
                  Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
                )
                ..add(
                  Factory<ScaleGestureRecognizer>(
                    () => ScaleGestureRecognizer(),
                  ),
                )
                ..add(
                  Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
                ),
          markers: Set.from(markers),
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(
            target:
                markers.isEmpty
                    ? const LatLng(0, 0)
                    : LatLng(
                      markers.first.position.latitude,
                      markers.first.position.longitude,
                    ),
            zoom: 18.0,
          ),
          mapType: MapType.normal,
          onMapCreated: (controller) {
            setState(() {
              mapController = controller;
            });
          },
        ),
      ),
    );
  }
}
