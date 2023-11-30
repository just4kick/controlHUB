import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class ObjectData {
  String name;
  bool isOn;
  int brightness;
  int speed;
  double temperature;

  ObjectData({
    required this.name,
    required this.isOn,
    required this.brightness,
    required this.speed,
    required this.temperature,
  });
}

DatabaseReference userRef =
    FirebaseDatabase.instance.reference().child("Changing value");

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Realtime Database Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/object': (context) => ObjectPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ObjectData> objects = [
    ObjectData(name: 'Light', isOn: false, brightness: 0, speed: 0, temperature: 0.0),
    ObjectData(name: 'Fan', isOn: false, brightness: 0, speed: 0, temperature: 0.0),
    ObjectData(name: 'Thermostat', isOn: false, brightness: 0, speed: 0, temperature: 0.0),
    // Add more objects as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Control'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: objects.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/object',
                arguments: objects[index],
              );
            },
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getDeviceIcon(objects[index].name),
                    size: 48,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 16),
                  Text(
                    objects[index].name,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getDeviceIcon(String name) {
    switch (name) {
      case 'Light':
        return Icons.lightbulb;
      case 'Fan':
        return Icons.air_rounded;
      case 'Thermostat':
        return Icons.thermostat;
      default:
        return Icons.device_unknown;
    }
  }
}

class ObjectPage extends StatefulWidget {
  @override
  _ObjectPageState createState() => _ObjectPageState();
}

class _ObjectPageState extends State<ObjectPage> {
  late ObjectData objectData;

  @override
  void initState() {
    super.initState();
    objectData = ObjectData(
      name: '',
      isOn: false,
      brightness: 0,
      speed: 0,
      temperature: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      objectData = args as ObjectData;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(objectData.name),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDeviceControlSection(),
            SizedBox(height: 16),
            _buildDeviceSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceControlSection() {
    switch (objectData.name) {
      case 'Light':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Light Control',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Power'),
              value: objectData.isOn,
              onChanged: _toggleLightStatus,
            ),
            SizedBox(height: 16),
            Slider(
              value: objectData.brightness.toDouble(),
              min: 0,
              max: 100,
              onChanged: _changeLightBrightness,
            ),
            SizedBox(height: 8),
            Text(
              'Brightness',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            _buildLightModes(),
          ],
        );
      case 'Fan':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Fan Control',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Power'),
              value: objectData.isOn,
              onChanged: _toggleFanStatus,
            ),
            SizedBox(height: 16),
            Slider(
              value: objectData.speed.toDouble(),
              min: 0,
              max: 100,
              onChanged: _changeFanSpeed,
            ),
            SizedBox(height: 8),
            Text(
              'Speed',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        );
      case 'Thermostat':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Thermostat Control',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => _decreaseTemperature(),
                ),
                Expanded(
                  child: Text(
                    '${objectData.temperature.toStringAsFixed(1)}°C',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _increaseTemperature(),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildTemperatureUnitToggle(),
          ],
        );
      default:
        return Container();
    }
  }

  Widget _buildDeviceSettingsSection() {
    switch (objectData.name) {
      case 'Light':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Light Settings',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            // Add light settings widgets as needed
          ],
        );
      case 'Fan':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Fan Settings',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            // Add fan settings widgets as needed
          ],
        );
      case 'Thermostat':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Thermostat Settings',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            // Add thermostat settings widgets as needed
          ],
        );
      default:
        return Container();
    }
  }

  Widget _buildLightModes() {
    // Add light modes widgets as needed
    return Container();
  }

  Widget _buildTemperatureUnitToggle() {
    // Add temperature unit toggle widget
    return Container();
  }

  void _toggleLightStatus(bool value) {
    setState(() {
      objectData.isOn = value;
    });
    _updateDatabase();
  }

  void _changeLightBrightness(double value) {
    setState(() {
      objectData.brightness = value.toInt();
    });
    _updateDatabase();
  }

  void _toggleFanStatus(bool value) {
    setState(() {
      objectData.isOn = value;
    });
    _updateDatabase();
  }

  void _changeFanSpeed(double value) {
    setState(() {
      objectData.speed = value.toInt();
    });
    _updateDatabase();
  }

  void _increaseTemperature() {
    setState(() {
      objectData.temperature += 0.5;
    });
    _updateDatabase();
  }

  void _decreaseTemperature() {
    setState(() {
      objectData.temperature -= 0.5;
    });
    _updateDatabase();
  }

  void _updateDatabase() {
    userRef.child(objectData.name).set(objectData.toJson());
  }
}

extension ObjectDataExtension on ObjectData {
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isOn': isOn,
      'brightness': brightness,
      'speed': speed,
      'temperature': temperature,
    };
  }
}















// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// class ObjectData {
//   String name;
//   bool isOn;
//   int brightness;
//   int speed;
//   double temperature;

//   ObjectData({
//     required this.name,
//     required this.isOn,
//     required this.brightness,
//     required this.speed,
//     required this.temperature,
//   });
// }

// DatabaseReference userRef =
//     FirebaseDatabase.instance.reference().child("Changing value");

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Realtime Database Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       initialRoute: '/',
//       routes: {
//         '/': (context) => HomePage(),
//         '/object': (context) => ObjectPage(),
//       },
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   List<ObjectData> objects = [
//     ObjectData(name: 'Light', isOn: false, brightness: 0, speed: 0, temperature: 0.0),
//     ObjectData(name: 'Fan', isOn: false, brightness: 0, speed: 0, temperature: 0.0),
//     ObjectData(name: 'Thermostat', isOn: false, brightness: 0, speed: 0, temperature: 0.0),
//     // Add more objects as needed
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Device Control'),
//       ),
//       body: GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//         ),
//         itemCount: objects.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               Navigator.pushNamed(
//                 context,
//                 '/object',
//                 arguments: objects[index],
//               );
//             },
//             child: Container(
//               margin: EdgeInsets.all(16),
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.3),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     _getDeviceIcon(objects[index].name),
//                     size: 48,
//                     color: Colors.blue,
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     objects[index].name,
//                     style: TextStyle(fontSize: 18),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   IconData _getDeviceIcon(String name) {
//     switch (name) {
//       case 'Light':
//         return Icons.lightbulb;
//       case 'Fan':
//         return Icons.air_rounded;
//       case 'Thermostat':
//         return Icons.thermostat;
//       default:
//         return Icons.device_unknown;
//     }
//   }
// }

// class ObjectPage extends StatefulWidget {
//   @override
//   _ObjectPageState createState() => _ObjectPageState();
// }

// class _ObjectPageState extends State<ObjectPage> {
//   late ObjectData objectData;

//   @override
//   void initState() {
//     super.initState();
//     objectData = ObjectData(
//       name: '',
//       isOn: false,
//       brightness: 0,
//       speed: 0,
//       temperature: 0.0,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final args = ModalRoute.of(context)?.settings.arguments;
//     if (args != null) {
//       objectData = args as ObjectData;
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(objectData.name),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildDeviceControlSection(),
//             SizedBox(height: 16),
//             _buildDeviceSettingsSection(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDeviceControlSection() {
//     switch (objectData.name) {
//       case 'Light':
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Light Control',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 16),
//             SwitchListTile(
//               title: Text('Power'),
//               value: objectData.isOn,
//               onChanged: _toggleLightStatus,
//             ),
//             Slider(
//               value: objectData.brightness.toDouble(),
//               min: 0,
//               max: 100,
//               onChanged: _changeLightBrightness,
//             ),
//             // Add more light control widgets as needed
//           ],
//         );
//       case 'Fan':
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Fan Control',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 16),
//             SwitchListTile(
//               title: Text('Power'),
//               value: objectData.isOn,
//               onChanged: _toggleFanStatus,
//             ),
//             Slider(
//               value: objectData.speed.toDouble(),
//               min: 0,
//               max: 100,
//               onChanged: _changeFanSpeed,
//             ),
//             // Add more fan control widgets as needed
//           ],
//         );
//       case 'Thermostat':
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Thermostat Control',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 16),
//             Row(
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.remove),
//                   onPressed: () => _decreaseTemperature(),
//                 ),
//                 Expanded(
//                   child: Text(
//                     '${objectData.temperature.toStringAsFixed(1)}°C',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 24),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.add),
//                   onPressed: () => _increaseTemperature(),
//                 ),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text('Celsius'),
//                 Switch(
//                   value: true, // Assuming Celsius is selected by default
//                   onChanged: (value) {},
//                 ),
//                 Text('Fahrenheit'),
//               ],
//             ),
//             // Add more thermostat control widgets as needed
//           ],
//         );
//       default:
//         return Container();
//     }
//   }

//   Widget _buildDeviceSettingsSection() {
//     switch (objectData.name) {
//       case 'Light':
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Light Settings',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 16),
//             // Add light settings widgets as needed
//           ],
//         );
//       case 'Fan':
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Fan Settings',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 16),
//             // Add fan settings widgets as needed
//           ],
//         );
//       case 'Thermostat':
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Thermostat Settings',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 16),
//             // Add thermostat settings widgets as needed
//           ],
//         );
//       default:
//         return Container();
//     }
//   }

//   void _toggleLightStatus(bool value) {
//     setState(() {
//       objectData.isOn = value;
//     });

//     userRef.child(objectData.name).child("isOn").set(value);
//   }

//   void _changeLightBrightness(double value) {
//     setState(() {
//       objectData.brightness = value.toInt();
//     });

//     userRef.child(objectData.name).child("brightness").set(value.toInt());
//   }

//   void _toggleFanStatus(bool value) {
//     setState(() {
//       objectData.isOn = value;
//     });

//     userRef.child(objectData.name).child("isOn").set(value);
//   }

//   void _changeFanSpeed(double value) {
//     setState(() {
//       objectData.speed = value.toInt();
//     });

//     userRef.child(objectData.name).child("speed").set(value.toInt());
//   }

//   void _increaseTemperature() {
//     setState(() {
//       objectData.temperature += 0.5;
//     });

//     userRef.child(objectData.name).child("temperature").set(objectData.temperature);
//   }

//   void _decreaseTemperature() {
//     setState(() {
//       objectData.temperature -= 0.5;
//     });

//     userRef.child(objectData.name).child("temperature").set(objectData.temperature);
//   }
// }










// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// class ObjectData {
//   String name;
//   bool isOn;
//   int brightness;
//   int speed;
//   double temperature;

//   ObjectData({
//     required this.name,
//     required this.isOn,
//     required this.brightness,
//     required this.speed,
//     required this.temperature,
//   });
// }

// DatabaseReference userRef =
//     FirebaseDatabase.instance.reference().child("Changing value");

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Realtime Database Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       initialRoute: '/',
//       routes: {
//         '/': (context) => HomePage(),
//         '/object': (context) => ObjectPage(),
//       },
//     );
//   }
// }

// class HomePage extends StatelessWidget {
//   final List<ObjectData> objects = [
//     ObjectData(name: 'Light', isOn: false, brightness: 0, speed: 0, temperature: 0.0),
//     ObjectData(name: 'Fan', isOn: false, brightness: 0, speed: 0, temperature: 0.0),
//     ObjectData(name: 'Thermostat', isOn: false, brightness: 0, speed: 0, temperature: 0.0),
//     // Add more objects as needed
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Device Control'),
//       ),
//       body: GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 1.2,
//         ),
//         itemCount: objects.length + 1,
//         itemBuilder: (context, index) {
//           if (index < objects.length) {
//             return Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16.0),
//               ),
//               child: InkWell(
//                 onTap: () {
//                   Navigator.pushNamed(
//                     context,
//                     '/object',
//                     arguments: objects[index],
//                   );
//                 },
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       _getIconForObjectName(objects[index].name),
//                       size: 60,
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       objects[index].name,
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           } else {
//             return Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16.0),
//               ),
//               child: InkWell(
//                 onTap: () {
//                   // Add more functionality here if needed
//                 },
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.add,
//                       size: 60,
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Add More',
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }

//   IconData _getIconForObjectName(String name) {
//     switch (name) {
//       case 'Light':
//         return Icons.lightbulb;
//       case 'Fan':
//         return Icons.ac_unit;
//       case 'Thermostat':
//         return Icons.thermostat;
//       // Add more cases as needed
//       default:
//         return Icons.device_unknown;
//     }
//   }
// }

// class ObjectPage extends StatefulWidget {
//   @override
//   _ObjectPageState createState() => _ObjectPageState();
// }

// class _ObjectPageState extends State<ObjectPage> {
//   late ObjectData objectData;

//   @override
//   void initState() {
//     super.initState();
//     objectData = ObjectData(
//       name: '',
//       isOn: false,
//       brightness: 0,
//       speed: 0,
//       temperature: 0.0,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final args = ModalRoute.of(context)?.settings.arguments;
//     if (args != null) {
//       objectData = args as ObjectData;
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(objectData.name),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (objectData.name == 'Light') ..._buildLightControls(),
//             if (objectData.name == 'Fan') ..._buildFanControls(),
//             if (objectData.name == 'Thermostat') ..._buildThermostatControls(),
//           ],
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildLightControls() {
//     return [
//       Text(
//         'Current Status',
//         style: TextStyle(fontSize: 24),
//       ),
//       SizedBox(height: 16),
//       Switch(
//         value: objectData.isOn,
//         onChanged: _toggleLightStatus,
//       ),
//       SizedBox(height: 16),
//       Text(
//         'Brightness: ${objectData.brightness}',
//         style: TextStyle(fontSize: 18),
//       ),
//       Slider(
//         value: objectData.brightness.toDouble(),
//         min: 0,
//         max: 100,
//         divisions: 100,
//         onChanged: _changeLightBrightness,
//       ),
//       SizedBox(height: 16),
//       // Add more controls for light if needed
//     ];
//   }

//   List<Widget> _buildFanControls() {
//     return [
//       Text(
//         'Current Status',
//         style: TextStyle(fontSize: 24),
//       ),
//       SizedBox(height: 16),
//       Switch(
//         value: objectData.isOn,
//         onChanged: _toggleFanStatus,
//       ),
//       SizedBox(height: 16),
//       Text(
//         'Speed: ${objectData.speed}',
//         style: TextStyle(fontSize: 18),
//       ),
//       Slider(
//         value: objectData.speed.toDouble(),
//         min: 0,
//         max: 10,
//         divisions: 10,
//         onChanged: _changeFanSpeed,
//       ),
//       SizedBox(height: 16),
//       // Add more controls for fan if needed
//     ];
//   }

//   List<Widget> _buildThermostatControls() {
//     return [
//       Text(
//         'Current Status',
//         style: TextStyle(fontSize: 24),
//       ),
//       SizedBox(height: 16),
//       Switch(
//         value: objectData.isOn,
//         onChanged: _toggleThermostatStatus,
//       ),
//       SizedBox(height: 16),
//       Text(
//         'Temperature: ${objectData.temperature.toStringAsFixed(1)}°C',
//         style: TextStyle(fontSize: 18),
//       ),
//       Slider(
//         value: objectData.temperature,
//         min: 0,
//         max: 30,
//         divisions: 30,
//         onChanged: _changeThermostatTemperature,
//       ),
//       SizedBox(height: 16),
//       // Add more controls for thermostat if needed
//     ];
//   }

//   void _toggleLightStatus(bool value) {
//     setState(() {
//       objectData.isOn = value;
//     });

//     int statusValue = objectData.isOn ? 1 : 0;
//     userRef.child(objectData.name).child("isOn").set(statusValue);
//   }

//   void _changeLightBrightness(double value) {
//     setState(() {
//       objectData.brightness = value.toInt();
//     });

//     userRef.child(objectData.name).child("brightness").set(objectData.brightness);
//   }

//   void _toggleFanStatus(bool value) {
//     setState(() {
//       objectData.isOn = value;
//     });

//     int statusValue = objectData.isOn ? 1 : 0;
//     userRef.child(objectData.name).child("isOn").set(statusValue);
//   }

//   void _changeFanSpeed(double value) {
//     setState(() {
//       objectData.speed = value.toInt();
//     });

//     userRef.child(objectData.name).child("speed").set(objectData.speed);
//   }

//   void _toggleThermostatStatus(bool value) {
//     setState(() {
//       objectData.isOn = value;
//     });

//     int statusValue = objectData.isOn ? 1 : 0;
//     userRef.child(objectData.name).child("isOn").set(statusValue);
//   }

//   void _changeThermostatTemperature(double value) {
//     setState(() {
//       objectData.temperature = value;
//     });

//     userRef.child(objectData.name).child("temperature").set(objectData.temperature);
//   }
// }


// best so far

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// class ObjectData {
//   String name;
//   int count;
//   bool isOn;
//   double speed;

//   ObjectData({
//     required this.name,
//     required this.count,
//     required this.isOn,
//     required this.speed,
//   });
// }

// DatabaseReference userRef =
//     FirebaseDatabase.instance.reference().child("Changing value");

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Realtime Database Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       initialRoute: '/',
//       routes: {
//         '/': (context) => HomePage(),
//         '/object': (context) => ObjectPage(),
//       },
//     );
//   }
// }

// class HomePage extends StatelessWidget {
//   final List<ObjectData> objects = [
//     ObjectData(name: 'Light', count: 0, isOn: false, speed: 1.0),
//     ObjectData(name: 'Fan', count: 0, isOn: false, speed: 1.0),
//     ObjectData(name: 'Thermostat', count: 0, isOn: false, speed: 1.0),
//     // Add more objects as needed
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Device Control'),
//       ),
//       body: GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 1.0,
//         ),
//         itemCount: objects.length + 1,
//         itemBuilder: (context, index) {
//           if (index < objects.length) {
//             return Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16.0),
//               ),
//               child: InkWell(
//                 onTap: () {
//                   Navigator.pushNamed(
//                     context,
//                     '/object',
//                     arguments: objects[index],
//                   );
//                 },
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       _getIconForObjectName(objects[index].name),
//                       size: 60,
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       objects[index].name,
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           } else {
//             return Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16.0),
//               ),
//               child: InkWell(
//                 onTap: () {
//                   // Add more functionality here if needed
//                 },
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.add,
//                       size: 60,
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Add More',
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }

//   IconData _getIconForObjectName(String name) {
//     switch (name) {
//       case 'Light':
//         return Icons.lightbulb;
//       case 'Fan':
//         return Icons.ac_unit;
//       case 'Thermostat':
//         return Icons.thermostat;
//       // Add more cases as needed
//       default:
//         return Icons.lightbulb;
//     }
//   }
// }

// class ObjectPage extends StatefulWidget {
//   @override
//   _ObjectPageState createState() => _ObjectPageState();
// }

// class _ObjectPageState extends State<ObjectPage> {
//   late ObjectData objectData;

//   @override
//   void initState() {
//     super.initState();
//     objectData = ObjectData(
//       name: '',
//       count: 0,
//       isOn: false,
//       speed: 1.0,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final args = ModalRoute.of(context)?.settings.arguments;
//     if (args != null) {
//       objectData = args as ObjectData;
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(objectData.name),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Current Status',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Counter: ${objectData.count}',
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _updateValue,
//               child: Text('Toggle Value'),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _toggleStatus,
//               child: Text(objectData.isOn ? 'On' : 'Off'),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Speed: ${objectData.speed.toInt()}',
//               style: TextStyle(fontSize: 18),
//             ),
//             Slider(
//               value: objectData.speed,
//               min: 1,
//               max: 100,
//               divisions: 99,
//               onChanged: _changeSpeed,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _updateValue() {
//     setState(() {
//       objectData.count++;
//     });

//     Map<String, dynamic> userDataMap = {
//       "name": objectData.name,
//       "count": objectData.count,
//       "isOn": objectData.isOn,
//       "speed": objectData.speed,
//     };

//     userRef.child(objectData.name).set(userDataMap);
//   }

//   void _toggleStatus() {
//     setState(() {
//       objectData.isOn = !objectData.isOn;
//     });

//     int statusValue = objectData.isOn ? 1 : 0;
//     userRef.child(objectData.name).child("isOn").set(statusValue);
//   }

//   void _changeSpeed(double value) {
//     setState(() {
//       objectData.speed = value;
//     });

//     int speedValue = value.round();
//     userRef.child(objectData.name).child("speed").set(speedValue);
//   }
// }













// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// class ObjectData {
//   String name;
//   int count;
//   bool isOn;
//   double speed;

//   ObjectData({
//     required this.name,
//     required this.count,
//     required this.isOn,
//     required this.speed,
//   });
// }

// DatabaseReference userRef =
//     FirebaseDatabase.instance.reference().child("Changing value");

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Realtime Database Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       initialRoute: '/',
//       routes: {
//         '/': (context) => HomePage(),
//         '/object': (context) => ObjectPage(),
//       },
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   List<ObjectData> objects = [
//     ObjectData(name: 'Light', count: 0, isOn: false, speed: 1.0),
//     ObjectData(name: 'Fan', count: 0, isOn: false, speed: 1.0),
//     ObjectData(name: 'Thermostat', count: 0, isOn: false, speed: 1.0),
//     // Add more objects as needed
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Device Control'),
//       ),
//       body: GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//         ),
//         itemCount: objects.length,
//         itemBuilder: (context, index) {
//           return IconButton(
//             icon: Icon(Icons.lightbulb),
//             onPressed: () {
//               Navigator.pushNamed(
//                 context,
//                 '/object',
//                 arguments: objects[index],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class ObjectPage extends StatefulWidget {
//   @override
//   _ObjectPageState createState() => _ObjectPageState();
// }

// class _ObjectPageState extends State<ObjectPage> {
//   late ObjectData objectData;

//   @override
//   void initState() {
//     super.initState();
//     objectData = ObjectData(
//       name: '',
//       count: 0,
//       isOn: false,
//       speed: 1.0,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final args = ModalRoute.of(context)?.settings.arguments;
//     if (args != null) {
//       objectData = args as ObjectData;
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(objectData.name),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Current Status',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Counter: ${objectData.count}',
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _updateValue,
//               child: Text('Toggle Value'),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _toggleStatus,
//               child: Text(objectData.isOn ? 'On' : 'Off'),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Speed: ${objectData.speed.toInt()}',
//               style: TextStyle(fontSize: 18),
//             ),
//             Slider(
//               value: objectData.speed,
//               min: 1,
//               max: 100,
//               divisions: 99,
//               onChanged: _changeSpeed,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _updateValue() {
//     setState(() {
//       objectData.count++;
//     });

//     Map<String, dynamic> userDataMap = {
//       "name": objectData.name,
//       "count": objectData.count,
//       "isOn": objectData.isOn,
//       "speed": objectData.speed,
//     };

//     userRef.child(objectData.name).set(userDataMap);
//   }

//   void _toggleStatus() {
//     setState(() {
//       objectData.isOn = !objectData.isOn;
//     });

//     int statusValue = objectData.isOn ? 1 : 0;
//     userRef.child(objectData.name).child("isOn").set(statusValue);
//   }

//   void _changeSpeed(double value) {
//     setState(() {
//       objectData.speed = value;
//     });

//     int speedValue = value.round();
//     userRef.child(objectData.name).child("speed").set(speedValue);
//   }
// }























// project base mark




// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// DatabaseReference userRef =
//     FirebaseDatabase.instance.reference().child("Changing value");

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   int count = 0;
//   bool isOn = false;
//   double speed = 1.0;

//   void _updateValue() {
//     setState(() {
//       ++count;
//     });

//     Map<String, dynamic> userDataMap = {"value": "Divyangshu", "count": count};
//     userRef.set(userDataMap);
//   }

//   void _toggleStatus() {
//     setState(() {
//       isOn = !isOn;
//     });

//     int statusValue = isOn ? 1 : 0;
//     userRef.child("status").set(statusValue);
//   }

//   void _changeSpeed(double value) {
//     setState(() {
//       speed = value;
//     });

//     int speedValue = value.round();
//     userRef.child("speed").set(speedValue);
//   }

//   @override
//   void initState() {
//     super.initState();
//     userRef.onValue.listen((event) {
//       if (event.snapshot.value != null) {
//         var snapshotValue = event.snapshot.value as Map<dynamic, dynamic>;
//         setState(() {
//           count = snapshotValue['count'] as int;
//           isOn = snapshotValue['status'] == 1;
//           speed = snapshotValue['speed'].toDouble();
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Realtime Database Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Realtime Database Example'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Check the value in Realtime Database\n\n',
//                 style: TextStyle(fontSize: 24),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Counter: $count',
//                 style: TextStyle(fontSize: 18),
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _updateValue,
//                 child: Text('Toggle Value'),
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _toggleStatus,
//                 child: Text(isOn ? 'On' : 'Off'),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Speed: ${speed.toInt()}',
//                 style: TextStyle(fontSize: 18),
//               ),
//               Slider(
//                 value: speed,
//                 min: 1,
//                 max: 100,
//                 divisions: 99,
//                 onChanged: _changeSpeed,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }












































// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// DatabaseReference userRef =
//     FirebaseDatabase.instance.reference().child("Changing value");

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   int count = 0;
//   bool isOn = false;

//   void _updateValue() {
//     setState(() {
//       ++count;
//     });

//     Map<String, dynamic> userDataMap = {"value": "Divyangshu", "count": count};
//     userRef.set(userDataMap);
//   }

//   void _toggleStatus() {
//     setState(() {
//       isOn = !isOn;
//     });

//     int statusValue = isOn ? 1 : 0;
//     userRef.child("status").set(statusValue);
//   }

//   @override
//   void initState() {
//     super.initState();
//     userRef.onValue.listen((event) {
//       if (event.snapshot.value != null) {
//         var snapshotValue = event.snapshot.value as Map<dynamic, dynamic>;
//         setState(() {
//           count = snapshotValue['count'] as int;
//           isOn = snapshotValue['status'] == 1;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Realtime Database Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Realtime Database Example'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Check the value in Realtime Database\n\n',
//                 style: TextStyle(fontSize: 24),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Counter: $count',
//                 style: TextStyle(fontSize: 18),
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _updateValue,
//                 child: Text('Toggle Value'),
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _toggleStatus,
//                 child: Text(isOn ? 'On' : 'Off'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// DatabaseReference userRef =
//     FirebaseDatabase.instance.reference().child("Changing value");

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   int count = 0;

//   void _updateValue() {
//     setState(() {
//       ++count;
//     });

//     Map<String, dynamic> userDataMap = {"value": "Divyangshu", "count": count};
//     userRef.set(userDataMap);
//   }

//   @override
//   void initState() {
//     super.initState();
//     userRef.onValue.listen((event) {
//       if (event.snapshot.value != null) {
//         var snapshotValue = event.snapshot.value as Map<dynamic, dynamic>;
//         setState(() {
//           count = snapshotValue['count'] as int;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Realtime Database Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Realtime Database Example'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Check the value in Realtime Database\n\n',
//                 style: TextStyle(fontSize: 24),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Counter: $count',
//                 style: TextStyle(fontSize: 18),
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _updateValue,
//                 child: Text('Toggle Value'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// DatabaseReference userRef =
//     FirebaseDatabase.instance.reference().child("Changing value");

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   int count = 0;

//   @override
//   void initState() {
//     super.initState();
//     userRef.onValue.listen((event) {
//       if (event.snapshot.value != null) {
//         var snapshotValue = event.snapshot.value as Map<dynamic, dynamic>;
//         setState(() {
//           count = snapshotValue['count'] as int;
//         });
//       }
//     });
//   }

//   void _updateValue() {
//     Map<String, dynamic> userDataMap = {"value": "Divyangshu", "count": ++count};
//     userRef.set(userDataMap);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Realtime Database Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Realtime Database Example'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Check the value in Realtime Database\n\n',
//                 style: TextStyle(fontSize: 24),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Count: $count',
//                 style: TextStyle(fontSize: 18),
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _updateValue,
//                 child: Text('Toggle Value'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }










// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// DatabaseReference userRef =
//     FirebaseDatabase.instance.reference().child("Changing value");

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   int number = 0;
//   void _updateValue() {
//     Map userDataMap = {"value": "Divyangshu", "age": ++number};
//     userRef.set(userDataMap);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Realtime Database Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Realtime Database Example'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Check the value in Realtime Database\n\n',
//                 style: TextStyle(fontSize: 24),
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _updateValue,
//                 child: Text('Toggle Value'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


























// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';


// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }