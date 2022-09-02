import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
// import 'package:by_press_cmu/screen/test/first.dart';
import 'package:by_press_cmu/screen/home/home_screen.dart';
import 'package:by_press_cmu/constant.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:typed_data';
import 'package:by_press_cmu/model/user.dart';
import 'package:by_press_cmu/model/weightTest.dart';
import 'package:by_press_cmu/db/weight_database.dart';
import 'package:by_press_cmu/screen/bluetooth/bluetooth_setting.dart';
import 'package:by_press_cmu/global-variable.dart' as globals;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:excel/excel.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sqflite_common_porter/utils/csv_utils.dart';
import 'package:firebase_storage/firebase_storage.dart'as firebase_storage;
import 'package:firebase_core/firebase_core.dart';
class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class MainScreen extends StatefulWidget {
  final User user;
  final BluetoothDevice server = globals.selectedDevice;
  MainScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  static final clientID = 0;
  BluetoothConnection? connection;
  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';

  final TextEditingController textEditingController =
  new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);
  bool isStartMeasure = false;
  bool isDisconnecting = false;
  String stringMessage = "";
  double newton = 0.0;
  double secondValueInt = 0.0;
  double thirdValueInt = 0.0;
  double firstValueInt = 0.0;
  int firstInt = 0;
  int secondInt = 0;
  int thirdInt = 0;
  double valueLeft = 0.0;
  double valueRight = 0.0;
  Color currentColor = Colors.redAccent;

  double secondValue= 0.0;
  double thirdValue = 0.0;
  Image imagePointerStart = Image.asset(
    'assets/icons/start.png',
    fit: BoxFit.cover, // this is the solution for border
    width: 100,
  );
  Image imagePointer = Image.asset(
    'assets/icons/start.png',
    fit: BoxFit.cover,
    width: 100,
  );

  AlertUserPressed(context) {
    Alert(
      context: context,
      desc: "เลือกนามสกุลของไฟล์ข้อมูล",
      content: TextField(
          decoration: InputDecoration(
            icon: Icon(Icons.attach_file),
            labelText: 'กรอกชื่อไฟล์ข้อมูล',
          ),
          onChanged: (val) {
            setState(() {
              globals.FileName = val;
            });
          }
      ),
      buttons: [
        DialogButton(
            child: Text(
              ".xlsx",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () => exportUserDataXlsx(globals.FileName),
            color: mSecondaryColor
        ),
        DialogButton(
            child: Text(
              ".csv",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () => exportUserDataCsv(globals.FileName),
            color: mPrimaryColor
        )
      ],
    ).show();
  }

  AlertTestPressed(context) {
    Alert(
      context: context,
      desc: "เลือกนามสกุลของไฟล์ข้อมูล",
      content: TextField(
          decoration: InputDecoration(
            icon: Icon(Icons.attach_file),
            labelText: 'กรอกชื่อไฟล์ข้อมูล',
          ),
          onChanged: (val) {
            setState(() {
              globals.FileName = val;
            });
          }
      ),
      buttons: [
        DialogButton(
            child: Text(
              ".xlsx",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () => exportTestDataXlsx(globals.FileName),
            color: mSecondaryColor
        ),
        DialogButton(
            child: Text(
              ".csv",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () => exportTestDataCsv(globals.FileName),
            color: mPrimaryColor
        )
      ],
    ).show();
  }
  firebase_storage.UploadTask uploadString(String putStringText,String filename) {
    // Create a Reference to the file
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('testDataCSV')
        .child('/'+filename);
    print(ref.toString());
    // Start upload of putString
    return ref.putString(putStringText,
        metadata: firebase_storage.SettableMetadata(
            contentLanguage: 'en',
            customMetadata: <String, String>{'example': 'putString'}));
  }
  firebase_storage.UploadTask uploadXlsx(Uint8List file,String filename) {
    // Create a Reference to the file
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('testDataXlsx')
        .child('/'+filename);

    // Start upload of putString
    return ref.putData(file);
  }

  void exportUserDataCsv(String InputFileName) async{
    await EasyLoading.show();
    final userData = await WeightDatabase.instance.exportUserData();
    print(userData);
    var csvUser = mapListToCsv(userData);
    print(csvUser);
    var fileString = csvUser;
    String filename = "userData_" + InputFileName +".csv";
    print(userData.toString());
    uploadString(fileString.toString(),filename);

    await EasyLoading.dismiss();

  }

  void exportUserDataXlsx(String InputFileName) async{
    // requestPermission(_permission);
    await EasyLoading.show();
    final userData = await WeightDatabase.instance.exportUserData();
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    var csvUser = mapListToCsv(userData);
    // print(csvUser);
    List<String> header = csvUser!.substring(0,csvUser.indexOf('\n')).split(',');
    sheetObject.insertRowIterables(header,0);
    csvUser = csvUser.substring(csvUser.indexOf('\n')+1);
    print(csvUser);
    final numLines = '\n'.allMatches(csvUser).length + 1;
    print(numLines);

    for (var i=1; i<= numLines;i++){
      List<String> dataList = [];
      if(i !=numLines){
        dataList = csvUser!.substring(0,csvUser.indexOf('\n')).split(',');
        csvUser = csvUser.substring(csvUser.indexOf('\n')+1);
        sheetObject.insertRowIterables(dataList,i);
      }
      else{
        dataList = csvUser!.split(',');
        sheetObject.insertRowIterables(dataList,i);
      }
      print(dataList);
    }

    List<int>? fileBytes = excel.save();
    Uint8List data = Uint8List.fromList(fileBytes!);
    String filename = "userData_" + InputFileName +".xlsx";
    uploadXlsx(data,filename);
    await EasyLoading.dismiss();

  }
  void exportTestDataCsv(String InputFileName) async{
    await EasyLoading.show();
    final testData  =await WeightDatabase.instance.exportTestData();
    var csvTest = mapListToCsv(testData);
    var fileString = csvTest;
    String filename = "TestData_" + InputFileName +".csv";
    uploadString(fileString.toString(),filename);
    print("export testData");

    await EasyLoading.dismiss();
  }
  void exportTestDataXlsx(String InputFileName) async{
    // requestPermission(_permission);
    await EasyLoading.show();
    final testData  =await WeightDatabase.instance.exportTestData();
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    var csvUser = mapListToCsv(testData);
    // print(csvUser);
    List<String> header = csvUser!.substring(0,csvUser.indexOf('\n')).split(',');
    sheetObject.insertRowIterables(header,0);
    csvUser = csvUser.substring(csvUser.indexOf('\n')+1);
    print(csvUser);
    final numLines = '\n'.allMatches(csvUser).length + 1;
    print(numLines);

    for (var i=1; i<= numLines;i++){
      List<String> dataList = [];
      if(i !=numLines){
        dataList = csvUser!.substring(0,csvUser.indexOf('\n')).split(',');
        csvUser = csvUser.substring(csvUser.indexOf('\n')+1);
        sheetObject.insertRowIterables(dataList,i);
      }
      else{
        dataList = csvUser!.split(',');
        sheetObject.insertRowIterables(dataList,i);
      }
      print(dataList);
    }

    List<int>? fileBytes = excel.save();
    Uint8List data = Uint8List.fromList(fileBytes!);
    String filename = "TestData_" + InputFileName +".xlsx";
    uploadXlsx(data,filename);
    await EasyLoading.dismiss();

  }
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
    connectDevice();
  }
  void connectDevice() async{
    // await EasyLoading.show();
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
    // await EasyLoading.dismiss();
  }
  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }
    isStartMeasure = false;
    super.dispose();
  }
  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    // print(dataString);
    int index = buffer.indexOf(13);
    if (~index != 0) {

      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ?
            _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );

        if(backspacesCounter>0){
          stringMessage = _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter);
        }
        else{
          stringMessage = _messageBuffer + dataString.substring(0, index);
        }
        stringMessage = stringMessage.trim();

        if(stringMessage.length<50){

          print(stringMessage);
          stringMessage = stringMessage.trim();
          String delimiter = ";";
          int firstIndex = stringMessage.indexOf(delimiter);
          if(firstIndex != -1){
            String firstString = stringMessage.substring(0,firstIndex);
            String stringValue = stringMessage.substring(firstIndex+1,stringMessage.length);
            int lastIndex = stringValue.indexOf(delimiter);
            if(lastIndex != -1){
              String secondString = stringValue.substring(0,lastIndex);
              String thirdString = stringValue.substring(lastIndex+1,stringValue.length);
              try{
                firstValueInt = double.parse((double.parse(firstString)).toStringAsFixed(0)) ;
                secondValueInt = double.parse((double.parse(secondString)).toStringAsFixed(0)) ;
                thirdValueInt = double.parse((double.parse(thirdString)).toStringAsFixed(0));

                  if(firstValueInt<0){
                    secondValueInt = 0;
                  }
                  if(secondValueInt<0){
                    secondValueInt = 0;
                  }
                  if (thirdValueInt<0){
                    thirdValueInt = 0;
                  }
                  firstValueInt = firstValueInt.abs();
                  secondValueInt = secondValueInt.abs();
                  thirdValueInt = thirdValueInt.abs();
                  firstInt = firstValueInt.toInt();
                  secondInt = secondValueInt.toInt();
                  thirdInt = thirdValueInt.toInt();


              }catch(e){
                firstValueInt = firstValueInt;
                secondValueInt = secondValueInt;
                thirdValueInt = thirdValueInt;
              }
            }
          }
        }


        _messageBuffer = dataString.substring(index);

      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
          0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }

    // print(messages.map((_message) =>
    // _message.text.trim()));


  }
  Future createTest() async{
    final weightTest = WeightTest(userId: globals.user.id, time: DateTime.now(), first: firstValueInt, second: secondValueInt, third: thirdValueInt);
    await WeightDatabase.instance.addTest(weightTest);
    return weightTest;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: mPrimaryColor,

        actions: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8,horizontal: 3),
            child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(mSecondaryColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9.0),
                      ))),
              onPressed: () {
                AlertUserPressed(context);
              },
              child: Text('บันทึกข้อมูลผู้ใช้งาน'),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8,horizontal: 3),
            child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(mSecondaryColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9.0),
                      ))),
              onPressed: () {
                AlertTestPressed(context);
              },
              child: Text('บันทึกข้อมูลทดสอบ'),
            ),
          )
        ],
      ),

      body: Container(
        child: Column(
          children: [
            Container(
              height: 150,
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
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [

                    Column(

                      children: [
                        Text('แรง1',style: TextStyle(color: mFourthColor,fontSize: 20)),
                        Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(

                            shape: BoxShape.circle,
                            color:mFourthColor,
                          ),
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(firstInt.toString(),style: TextStyle(color: Color(0xFFF9D835),fontSize: 30)),
                            ],
                          ),
                        ),
                        Text('mmHg',style: TextStyle(color: mFourthColor,fontSize: 20)),
                      ],
                    ),
                    SizedBox(width: 20),
                    Column(
                      children: [
                        Text('แรง2',style: TextStyle(color: mFourthColor,fontSize: 20)),
                        Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(

                            shape: BoxShape.circle,
                            color:mFourthColor,
                          ),
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(secondInt.toString(),style: TextStyle(color: Color(0xFFF56E7A5),fontSize: 30)),
                            ],
                          ),
                        ),
                        Text('mmHg',style: TextStyle(color: mFourthColor,fontSize: 20)),
                      ],
                    ),
                    SizedBox(width: 20),
                    Column(
                      children: [
                        Text('แรง3',style: TextStyle(color: mFourthColor,fontSize: 20)),
                        Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(

                            shape: BoxShape.circle,
                            color:mFourthColor,
                          ),
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(thirdInt.toString(),style: TextStyle(color: Color(0xFFFF56C75),fontSize: 30)),
                            ],
                          ),
                        ),
                        Text('mmHg',style: TextStyle(color: mFourthColor,fontSize: 20)),
                      ],
                    )

                  ],

                ),
              )
              ,
            ),
            // Line(),
            SizedBox(height: 5),
            Padding(padding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 20.0),
                child:
                Container(
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/profile.svg'),
                      SizedBox(width:10),
                      Text(widget.user.name +" "+ widget.user.surname,style: TextStyle(fontSize: 18)),


                    ],
                  ),
                )
            ),

            Container(

              constraints: BoxConstraints.tightFor(width: 200, height: 50),
              child:ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(mSecondaryColor),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          )
                      )
                  ),
                  onPressed: () {
                    createTest();
                  },

                  child:

                  Text("บันทึกค่า",style: TextStyle(color: Colors.white , fontSize: 25))


              ),
            ),
            Container(
              width: 220,
              height: 440,
              decoration:  BoxDecoration(
                image:  DecorationImage(image: AssetImage("assets/icons/hand.png"), fit: BoxFit.cover,),
              ),
              child:Padding(
                  padding: EdgeInsets.fromLTRB(20, 150, 0, 0),
                  child: Column(

                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFFF56C75)),
                          shape: BoxShape.circle,
                          color:mFourthColor,
                        ),
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(thirdInt.toString(),style: TextStyle(color: Color(0xFFFF56C75),fontSize: 30)),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFF56E7A5)),
                          shape: BoxShape.circle,
                          color:mFourthColor,
                        ),
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(secondInt.toString(),style: TextStyle(color: Color(0xFFF56E7A5),fontSize: 30)),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFF9D835)),
                          shape: BoxShape.circle,
                          color:mFourthColor,
                        ),
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(firstInt.toString(),style: TextStyle(color: Color(0xFFF9D835),fontSize: 30)),
                          ],
                        ),
                      ),

                    ],
                  )
              )
              ,
            )
          ],
        ),
      ),
      // bottomNavigationBar: ButtonAppBluetooth(),
    );
  }
}
