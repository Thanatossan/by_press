import 'package:flutter/material.dart';
import 'package:by_press_cmu/constant.dart';
import 'package:flutter_svg/svg.dart';
import 'package:by_press_cmu/screen/home/home_screen.dart';
import 'SelectBondedDevicePage.dart';
import 'ChatPage.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';
import 'package:by_press_cmu/global-variable.dart' as globals;
import 'package:by_press_cmu/screen/main/main_screen.dart';
import 'package:by_press_cmu/model/user.dart';
import 'package:by_press_cmu/screen/selectDevice/select_device_screen.dart';
class BluetoothSetting extends StatefulWidget {
  final User user;
  BluetoothSetting({
    Key? key,
    required this.user,
  }) : super(key: key);
  @override
  _BluetoothSettingState createState() => _BluetoothSettingState();
}

class _BluetoothSettingState extends State<BluetoothSetting> {


  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  String _address = "...";
  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;
  bool isConnected = false;
  // BackgroundCollectingTask? _collectingTask;

  bool _autoAcceptPairingRequests = false;
  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: mPrimaryColor,
            leading:  new IconButton(
              icon: new Icon(Icons.arrow_back),
              onPressed: () => Navigator.push(
                  context,MaterialPageRoute(builder: (context) => HomeScreen())
              ),
            )),
        body:
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors:[
                    mPrimaryColor,
                    mSecondaryColor
                  ]
              )
          ),
          child: ListView(
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.fromLTRB(0, 15, 10,0),
                  child:
                      Center(child: Text("ตั้งค่า Bluetooth",style: TextStyle(color: mFourthColor , fontSize: 30)))
              ),

              // Divider(),

              SwitchListTile(
                title: Text('Enable Bluetooth',style: TextStyle(color: mFourthColor , fontSize: 25)),
                value: _bluetoothState.isEnabled,
                activeColor: mSecondaryColor,
                inactiveThumbColor: mSecondaryColor,
                onChanged: (bool value) {
                  // Do the request and update with the true value then
                  future() async {
                    // async lambda seems to not working
                    if (value)
                      await FlutterBluetoothSerial.instance.requestEnable();
                    else
                      await FlutterBluetoothSerial.instance.requestDisable();
                  }
                  future().then((_) {
                    setState(() {});
                  });
                },
              ),
              ListTile(
                title: Text('Bluetooth Status',style: TextStyle(color: mFourthColor , fontSize: 20)),
                subtitle: Text(_bluetoothState.toString(),style: TextStyle(color: mFourthColor )),
                trailing: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(mFourthColor.withOpacity(0.8)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ))),
                  child:Text('Paired Device',style: TextStyle( color: mThirdColor )),
                  onPressed: () {
                    FlutterBluetoothSerial.instance.openSettings();
                  },
                ),
              ),
              // SwitchListTile(
              //   title: const Text('Auto-try specific pin when pairing'),
              //   subtitle: const Text('Pin 1234'),
              //   value: _autoAcceptPairingRequests,
              //   onChanged: (bool value) {
              //     setState(() {
              //       _autoAcceptPairingRequests = value;
              //     });
              //     if (value) {
              //       FlutterBluetoothSerial.instance.setPairingRequestHandler(
              //               (BluetoothPairingRequest request) {
              //             print("Trying to auto-pair with Pin 1234");
              //             if (request.pairingVariant == PairingVariant.Pin) {
              //               return Future.value("1234");
              //             }
              //             return Future.value(null);
              //           });
              //     } else {
              //       FlutterBluetoothSerial.instance
              //           .setPairingRequestHandler(null);
              //     }
              //   },
              // ),
              ListTile(
                title: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(mFourthColor.withOpacity(0.8)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ))),
                  child: Text('Connect to paired device',style: TextStyle( color: mThirdColor )),
                  onPressed: () async {
                    final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return SelectBondedDevicePage(checkAvailability: false);
                        },
                      ),
                    );

                    if (selectedDevice != null) {
                      print('Connect -> selected ' + selectedDevice.address);
                      globals.selectedDevice = selectedDevice ;
                      globals.isConnected = true;
                    } else {
                      print('Connect -> no device selected');
                    }
                  },
                ),
                // subtitle: isConnected ? Text('Connect to ' + globals.selectedDevice.name.toString()): Text('')
              ),
              // isConnected ? Text('Connect to ' + globals.selectedDevice.name.toString()):null
              SizedBox(height: 300),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                constraints: BoxConstraints.tightFor(width: 250, height: 50),
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(mFourthColor.withOpacity(0.8)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ))),
                  onPressed: () {
                    if (globals.selectedDevice.name != "Non-connected") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MainScreen(user: globals.user)),
                        //   MaterialPageRoute(builder: (context) => HomeScreen())
                      );
                    }
                  },
                  child: Text('Next', style: TextStyle(color: mThirdColor, fontSize: 20)),
                ),
              )
            ],

          ),
        )

    );
  }
}
