import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:motion_sensors/motion_sensors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:url_launcher/url_launcher.dart';
import 'lib.dart' as global;
import 'package:location/location.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_sensors/flutter_sensors.dart';

void main() {
  runApp(PhoneDropDetector());
}

class PhoneDropDetector extends StatefulWidget {
  @override
  _PhoneDropDetectorState createState() => _PhoneDropDetectorState();
}

class _PhoneDropDetectorState extends State<PhoneDropDetector> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ], supportedLocales: [
      Locale('en', 'US'),
    ], home: realapp());
  }
}

class realapp extends StatefulWidget {
  const realapp({Key? key}) : super(key: key);

  @override
  State<realapp> createState() => _realappState();
}

class _realappState extends State<realapp> {
  late double _acceleration;
  bool _dropped = false;
  late Timer _timer;
  int timer = 10;
  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  Future<void> _getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    setState(() {
      global.lat = _locationData.latitude!;

      global.lon = _locationData.longitude!;
    });
  }

  @override
  void initState() {
    super.initState();
    _getLocation();

    motionSensors.accelerometer.listen((AccelerometerEvent event) {
      setState(() {
        _acceleration =
            sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));
      });

      if (_acceleration != null && _acceleration > 100) {
        // Phone has been dropped
        setState(() {
          _dropped = true;
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            _timer = Timer(Duration(seconds: 10), () {
              String message =
                  "i am crashed my location: latitue ${global.lat} and longitude ${global.lon}";
              List<String> recipients = [global.globalString];
              sendSMS(message: message, recipients: recipients);
              Navigator.of(context).pop();
              Fluttertoast.showToast(
                  msg: "sending sms",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  textColor: Colors.white,
                  fontSize: 16.0);
            });
            return AlertDialog(
              title: Text("Accident detected"),
              content: Text(
                  "accident detected do you want to report to your friends?."),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("cancel")),
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    String message =
                        "i am crashed my location: latitue ${global.lat} and longitude ${global.lon}";
                    List<String> recipients = [global.globalString];
                    sendSMS(message: message, recipients: recipients);
                    Fluttertoast.showToast(
                        msg: "sending sms",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    Navigator.of(context).pop();
                    setState(() {
                      _dropped = false;
                    });
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("dropper"),
          centerTitle: true,
          elevation: 10,
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const settings()),
                  );
                },
                icon: Icon(Icons.settings))
          ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _dropped ? "wait! accident detected!" : " no accident detected ",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            if (_dropped)
              TextButton(
                child: Text(
                  "report",
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  String message =
                      "i am crashed my location: latitue ${global.lat} and longitude ${global.lon}";
                  List<String> recipients = [global.globalString];
                  sendSMS(message: message, recipients: recipients);
                  Fluttertoast.showToast(
                      msg: "sending sms",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      textColor: Colors.white,
                      fontSize: 16.0);
                  setState(() {
                    _dropped = false;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}

class settings extends StatefulWidget {
  const settings({Key? key}) : super(key: key);

  @override
  State<settings> createState() => _settingsState();
}

class _settingsState extends State<settings> {
  TextEditingController firstNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(60.0),
          child: Column(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter emergency  number with country code',
                ),
              ),
              Padding(padding: EdgeInsets.all(15.0)),
              ElevatedButton(
                  onPressed: () {
                    Fluttertoast.showToast(
                        msg: "saved",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    setState(() {
                      global.globalString = firstNameController.text;
                    });
                  },
                  child: Text("save"))
            ],
          ),
        ));
  }
}
