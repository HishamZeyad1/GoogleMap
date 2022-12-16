import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GMap extends StatefulWidget {
  late String title;

  GMap(this.title);

  @override
  State<GMap> createState() => _GMapState();
}

class _GMapState extends State<GMap> {
  //service location=Enable[True/False];
  Position? currentLocation;
  double? latitude, longitude;
  CameraPosition? _kGooglePlex;

  // final Completer<GoogleMapController> _controller =Completer<GoogleMapController>();
  GoogleMapController? gmc;
  Set<Marker>? markers;
  StreamSubscription<Position>? positionStream;
  // final LocationSettings locationSettings = LocationSettings(
  //   accuracy: LocationAccuracy.high,
  //   distanceFilter: 100,
  // );
  late LocationSettings locationSettings;


  Future<bool> isLocationServiceEnabled() async {
    bool services = await Geolocator.isLocationServiceEnabled();
    print(services);
    if (services == false) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Location Service',
        body: Text("The Location Service Not Enable"),
        //       desc: '',
        //       btnCancelOnPress: () {},
        // btnOkOnPress: () {},
      )..show();
    }
    return services;
  }
  Future<bool> isAllowedPermission() async {
    LocationPermission per = await Geolocator.checkPermission();

    if (per == LocationPermission.denied) {
      per = await Geolocator.requestPermission();
    }
    if (per == LocationPermission.denied ||
        per == LocationPermission.deniedForever)
      return false;
    else if (per == LocationPermission.always ||
        per == LocationPermission.whileInUse)
      return true;
    else
      return false;
  }

  Future<void> getPostion() async {
    bool isLocationEnabled = await isLocationServiceEnabled();
    bool allowPermission = await isAllowedPermission();
    if (isLocationEnabled && allowPermission) {
      GetLatAndLong();
    }
  }

  Future<void> GetLatAndLong() async {
    currentLocation =
        await Geolocator.getCurrentPosition().then((value) => value);
    latitude = currentLocation!.latitude;
    longitude = currentLocation!.longitude;
    print("latitude: $latitude");
    print("longitude: $longitude");

    //Google Map set CameraPosition to my location (latitude,longitude)
    _kGooglePlex = CameraPosition(
      target: LatLng(latitude!, longitude!),
      zoom: 10,
    );
    //Google Map set its markers to my location (latitude,longitude)
    markers = {
      Marker(
        markerId: MarkerId("1"),
        position: LatLng(latitude!, longitude!),
        infoWindow: InfoWindow(
          title: "الرئيسي",
          onTap: () {
            print("1");
            print("Tap info Marker");
          },
        ),
        onTap: () {
          print("Tap Marker");
        },
      ),
      // Marker(
      //   markerId: MarkerId("2"),
      //   position: LatLng(31.40, 34.38),
      //   draggable: true,
      //   onDragEnd: (LatLng) {
      //     print("onDragEnd:$LatLng");
      //   },
      //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      //   infoWindow: InfoWindow(
      //       title: "الفرعي",
      //       onTap: () {
      //         print("2");
      //       }),
      //   onTap: () {
      //     print("Tap info Marker");
      //   },
      // )
    };
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("=====initState=====");
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 10),
          //(Optional) Set foreground notification config to keep the app alive
          //when going to the background
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText:
            "Example app will continue to receive your location even when you aren't using it",
            notificationTitle: "Running in Background",
            enableWakeLock: true,
          )
      );
    }
    else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
      );
    }
    else {
      locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }
    getPostion();
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
              if(markers!=null)
                {
                  markers!.remove(Marker(markerId: MarkerId("1"),));
                  markers!.add(Marker(
                    markerId: MarkerId("1"),
                    position: LatLng(latitude!, longitude!),
                    infoWindow: InfoWindow(
                      title: "الرئيسي",
                      onTap: () {
                        print("1");
                        print("Tap info Marker");
                      },
                    ),
                    onTap: () {
                      print("Tap Marker");
                    },
                  ),);
                  if(gmc!=null)
                  gmc!.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(latitude!, longitude!),
                    ),
                  );
                }
              print("update");
      // print(position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _kGooglePlex == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _kGooglePlex!,
                    markers: markers!,
                    onTap: (latlng) {
                      markers!.remove(Marker(markerId: MarkerId("2")));
                      markers!.add(Marker(
                        markerId: MarkerId("2"),
                        position: latlng,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen),
                      ));
                      setState(() {});
                    },
                    onMapCreated: (GoogleMapController controller) {
                      gmc = controller;
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    // gmc!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(21.257062,39.859601),zoom: 8/**/,bearing: 90,tilt:90 )));
                    // gmc!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(21.257062,39.859601),zoom: 8/**/,bearing: 90,tilt:90 )));
                    LatLng xy =
                        await gmc!.getLatLng(ScreenCoordinate(x: 10, y: 10));
                    print(xy);
                  },
                  child: Text("Go to Maka"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200, 50),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
    );
  }
}
