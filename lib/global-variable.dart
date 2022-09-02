library my_prj.globals;
import 'package:by_press_cmu/model/user.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

late User user;
bool isLoggedIn = false;
BluetoothDevice selectedDevice = BluetoothDevice(name: "Non-connected",address: "0") ;
bool isConnected = false;
bool changeToText = false;
bool isStartMeasure =false;
String pathUser = "";
String pathTest = "";
int deviceId = 1 ;
String FileName = "user";