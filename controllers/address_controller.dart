import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/sharPreferenceUtils.dart';

class AddressController extends GetxController {
  LatLng? latLong;
  late CameraPosition cameraPosition;
  late GoogleMapController controller;
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = {};
  var address;

  @override
  void onInit() {
    cameraPosition = CameraPosition(target: LatLng(0, 0), zoom: 14.0);
    getCurrentLocation();
    super.onInit();
  }

  void onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    update();
  }

  Future getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission != PermissionStatus.granted) {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission != PermissionStatus.granted) getLocation();
      return;
    }
    getLocation();
  }

  getLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position.latitude);

    latLong = new LatLng(position.latitude, position.longitude);
    cameraPosition = CameraPosition(target: latLong!, zoom: 20.0);
    // controller!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition!));

    markers.add(Marker(
        markerId: MarkerId("a"),
        draggable: true,
        position: latLong!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onDragEnd: (_currentLatLng) {
          latLong = _currentLatLng;
        }));
    getCurrentAddress();

    update();
  }

  getCurrentAddress() async {
    List<Placemark> placeMarks = await placemarkFromCoordinates(latLong!.latitude, latLong!.longitude!, localeIdentifier: 'en');
    var first = placeMarks.first;
    address = address = 'street ${first.street}';
    update();
  }

  saveAddress() {
    SharedPrefs.instance.setString("currentAddress", address);
    update();
  }
}
