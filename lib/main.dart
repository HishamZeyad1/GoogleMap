import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map/gmap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  // runApp(const MyApp());
  runApp(MaterialApp(title: 'Google Map',home: GMap('Flutter Google Map'),));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Map',
      home: const MyHomePage(title: 'Flutter Google Map'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //service location=Enable[True/False];
  Position? currentLocation;
  double? latitude, longitude;
  CameraPosition? _kGooglePlex;

  // final Completer<GoogleMapController> _controller =Completer<GoogleMapController>();
  GoogleMapController? gmc;
  Set<Marker>? markers;

  Future<void> getPostion() async {
    bool services;
    services = await Geolocator.isLocationServiceEnabled();
    LocationPermission per;
    print(services);
    if (services == false) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Location Service',
        body: Text("The Location Service Not Enable"),
        //       desc: '',
        //       btnCancelOnPress: () {},
        // btnOkOnPress: () {},
      )..show();
    }
    per = await Geolocator.checkPermission();
    print(per);

    if (per == LocationPermission.denied) {
      per = await Geolocator.requestPermission();
    }
    if (per == LocationPermission.always && services == true) {
      GetLatAndLong();
    }
    print(per);
  }

  Future<void> GetLatAndLong() async {
    currentLocation =
        await Geolocator.getCurrentPosition().then((value) => value);
    latitude = currentLocation!.latitude;
    longitude = currentLocation!.longitude;

    // print("altitude: ${currentLocation!.altitude}");
    print("latitude: $latitude");
    print("longitude: $longitude");
    //الخدمة غير مدعومة في الموقعي قطاع غزة
    // List<Placemark> placemarks = await placemarkFromCoordinates(currentLocation!.latitude,currentLocation!.longitude);
    // List<Placemark> placemarks = await placemarkFromCoordinates(31.083150, 33.894583);
    // print(placemarks[0]);
    //(24.421362, 39.632681)
    //(27.483147, 41.710601)
    // double distanceInMeters = Geolocator.distanceBetween(24.421362, 39.632681, 27.483147, 41.710601);
    // double distanceKM=distanceInMeters/1000;
    // print("distanceKM:$distanceKM");
    _kGooglePlex = CameraPosition(
      target: LatLng(latitude!, longitude!),
      zoom: 10,
    );
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
      Marker(
        markerId: MarkerId("2"),
        position: LatLng(31.40, 34.38),
        draggable: true,
        onDragEnd: (LatLng) {
          print("onDragEnd:$LatLng");
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
            title: "الفرعي",
            onTap: () {
              print("2");
            }),
        onTap: () {
          print("Tap info Marker");
        },
      )
    };
    // await setMarkerCustomImage();
    setState(() {});
  }

  setMarkerCustomImage() async {
    markers!.add(Marker(
      markerId: MarkerId("3"),
      position: LatLng(31.261192, 34.319348),
      draggable: true,
      onDragEnd: (LatLng) {
        // markers!.remove(Marker(markerId: MarkerId("2")));
        // markers!.add(Marker(markerId: MarkerId("2"),position:LatLng ,icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        // ));
        print("onDragEnd:$LatLng");
      },
      icon: await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size.square(2)),
        "images/logo.png",
      ),
      infoWindow: InfoWindow(
          title: "الفرعي 2",
          onTap: () {
            print("3");
          }),
      onTap: () {
        print("Tap info Marker");
      },
    ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPostion();
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
                      // _controller.complete(controller);
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

      // Center(
      //   child: Padding(
      //
      //     padding: const EdgeInsets.all(50.0),
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: <Widget>[
      //         ElevatedButton(
      //           onPressed: ()async {
      //             // await GetLatAndLong();
      //             await getPostion();
      //
      //
      //           },
      //           child: Text("Get Location"),
      //           style: ElevatedButton.styleFrom(minimumSize: Size(120, 60)),
      //         ),
      //         SizedBox(height: 20,),
      //         Text(
      //           'Current Location:${currentLocation}',
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
//(24.421362, 39.632681)
//(27.483147, 41.710601)
//key
// AIzaSyAkj4FF93svE8v9-7LUfocSuzOHfF6HqTw
