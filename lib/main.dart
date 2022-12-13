import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
    if (per == LocationPermission.always && services==true) {
      GetLatAndLong();
    }
    print(per);
  }

  Future<void> GetLatAndLong() async {
    currentLocation =
        await Geolocator.getCurrentPosition().then((value) => value);
    print("altitude: ${currentLocation!.altitude}");
    print("latitude: ${currentLocation!.latitude}");
    print("longitude: ${currentLocation!.longitude}");
    //الخدمة غير مدعومة في الموقعي قطاع غزة
    // List<Placemark> placemarks = await placemarkFromCoordinates(currentLocation!.latitude,currentLocation!.longitude);
    // List<Placemark> placemarks = await placemarkFromCoordinates(31.083150, 33.894583);
    // print(placemarks[0]);
    //(24.421362, 39.632681)
    //(27.483147, 41.710601)
    double distanceInMeters = Geolocator.distanceBetween(24.421362, 39.632681, 27.483147, 41.710601);
    double distanceKM=distanceInMeters/1000;
    print("distanceKM:$distanceKM");
    setState(() {});
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
      body: Center(
        child: Padding(

          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: ()async {
                  // await GetLatAndLong();
                  await getPostion();


                },
                child: Text("Get Location"),
                style: ElevatedButton.styleFrom(minimumSize: Size(120, 60)),
              ),
              SizedBox(height: 20,),
              Text(
                'Current Location:${currentLocation}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//(24.421362, 39.632681)
//(27.483147, 41.710601)