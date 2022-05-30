import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../Constants/constants.dart';
import '../Message_box/Inbox.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //String Address = 'address';
  static var Address;
  final message = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
Future<void> GetAddressFromLatLong(Position position) async{
    List<Placemark> placemark = await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemark[0];
    Address = '${place.street},${place.administrativeArea}';
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Crime Spotter',
          style: TextStyle(
            color: PrimaryColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.messenger_outline_sharp,
            color: PrimaryColor,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Message()),
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: PrimaryColor,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(

        child: Column(
          children: [
            Form(
                key: _formKey,
                child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: message,
                    validator: (value){
                      if (value!.isEmpty){
                        return ("Type Your message");
                      }
                    },
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: PrimaryColor,
                          ),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: PrimaryColor,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        hintText: "Type Your message here"),
                  ),
                ),
                TextButton(
                    child: Text("sent".toUpperCase(),
                        style: TextStyle(fontSize: 14)),
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(15)),
                        foregroundColor:
                        MaterialStateProperty.all<Color>(Kwhite),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            PrimaryColor),
                        shape: MaterialStateProperty.all<
                            RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: PrimaryColor)))),
                    onPressed: () {
                      final msg = message.text;
                      sentMsg(message: msg);
                    }),
              ],
            )),

            Container(

              height: 200,
              child: Column(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("hello Mr Vishwa ! If you are facing any Emergency situation feel free to press 119 button ",style: TextStyle(
                      fontWeight: FontWeight.w300,

                    ),),
                  ),
                  Center(
                   child: CupertinoActivityIndicator(
                     radius: 20,
                     color: PrimaryColor,
                   ),
                  ),
                ],
              ),
            ),
            TextButton(
                child: Text("119 Call".toUpperCase(),
                    style: TextStyle(fontSize: 14)),
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.all(15)),
                    foregroundColor:
                    MaterialStateProperty.all<Color>(Kwhite),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        PrimaryColor),
                    shape: MaterialStateProperty.all<
                        RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            side: BorderSide(color: PrimaryColor)))),
                onPressed: () async {
                  Position position = await _determinePosition();
                  print(position.latitude);
                  print(Address);
                  GetAddressFromLatLong(position);
                  if (Address==null){
                    print('try again');
                 }else{
                    final lat = position.latitude;
                    final lng = position.longitude;
                    final location = Address;
                    sentLoc(location: location,lat: lat,lng: lng);
                    print('done');
                  }
                }),

          ],
        ),
      ),
    );
  }
  Future sentMsg({required String message}) async {
    final docUser = FirebaseFirestore.instance.collection('inbox').doc();
    final json = {
      'name' : "vishwa",
      'message' : message,
    };
    await docUser.set(json);
  }
  Future sentLoc({required String location ,required double lat,required double lng }) async {
    final docUser = FirebaseFirestore.instance.collection('alert').doc();
    final json = {
      'name' : "vishwa",
      'location' : location,
      'lat' : lat,
      'lng' : lng,
    };
    await docUser.set(json);
  }

}

