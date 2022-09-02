import 'package:flutter/material.dart';
import 'package:by_press_cmu/screen/register/success_screen.dart';
import 'package:by_press_cmu/constant.dart';
import 'package:by_press_cmu/model/user.dart';
import 'package:by_press_cmu/db/weight_database.dart';
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  late String name;
  late String surname;
  late int age ;
  late String gender;
  late String surgery;
  late double weight;
  late double bmi;
  String  dropdownValue = 'เพศ';
  String dropdownValue2 = 'ชนิดการผ่าตัด';
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: mPrimaryColor),
      body: Form(
        key: _formKey,
        child: Container(
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
            padding: const EdgeInsets.all(40),
            child:Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(

                      child: Text("ลงทะเบียนผู้ใช้ใหม่",style: TextStyle(color: mFourthColor , fontSize: 30)),
                    )
                ),
                TextFormField(
                  onChanged: (val){
                    setState(() {
                      name = val ;
                    });
                  },
                  // The validator receives the text that the user has entered.
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mFourthColor, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mFourthColor, width: 2.0),
                      ),
                      hintText: 'ชื่อ',
                      hintStyle: TextStyle(color: mFourthColor))
                  ,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  // The validator receives the text that the user has entered.
                  onChanged: (val){
                    setState(() {
                      surname = val ;
                    });
                  },
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mFourthColor, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mFourthColor, width: 2.0),
                      ),
                      hintText: 'นามสกุล',
                      hintStyle: TextStyle(color: mFourthColor)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                        child:TextFormField(
                          keyboardType: TextInputType.number,
                          onChanged: (val){
                            setState(() {
                              age = int.parse(val);

                            });
                          },
                          // The validator receives the text that the user has entered.
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: mFourthColor, width: 2.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: mFourthColor, width: 2.0),
                              ),
                              hintText: 'อายุ',
                              hintStyle: TextStyle(color: mFourthColor)),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        )
                    ),
                    SizedBox(width: 30)
                    ,
                    Flexible(
                      // child:TextFormField(
                      //   // The validator receives the text that the user has entered.
                      //   decoration: InputDecoration(
                      //       border: OutlineInputBorder(), hintText: 'เพศ' , hintStyle: TextStyle(color: mSecondaryColor)
                      //   ),
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter some text';
                      //     }
                      //     return null;
                      //   },
                      // )
                      child: Container(

                        child: DropdownButtonHideUnderline(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                canvasColor: mSecondaryColor,
                              ),
                                child: DropdownButton<String>(
                                  borderRadius: BorderRadius.circular(10),
                                  iconEnabledColor: mFourthColor,
                                  iconDisabledColor: mFourthColor,
                                  hint:Text("เพศ",style: TextStyle(color: mFourthColor)),
                                  isExpanded: true,
                                  value: null ??dropdownValue  ,
                                  elevation: 16,
                                  style: TextStyle(color: mThirdColor),


                                  items: <String>['เพศ','ชาย', 'หญิง', 'ไม่ระบุ']
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value,style: TextStyle(color: mFourthColor , fontFamily: 'kanit')),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      dropdownValue = newValue!;
                                      gender = dropdownValue;
                                    });
                                  },
                                )
                            )

                        ),
                      ),
                    )
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                        child:TextFormField(
                          keyboardType: TextInputType.number,
                          onChanged: (val){
                            setState(() {
                              weight = double.parse(val);

                            });
                          },
                          // The validator receives the text that the user has entered.
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: mFourthColor, width: 2.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: mFourthColor, width: 2.0),
                              ),
                              hintText: 'นํ้าหนัก',
                              hintStyle: TextStyle(color: mFourthColor)),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        )
                    ),
                    SizedBox(width: 30)
                    ,
                    Flexible(
                        child:TextFormField(
                          keyboardType: TextInputType.number,
                          onChanged: (val){
                            setState(() {
                              bmi = double.parse(val);
                            });
                          },
                          // The validator receives the text that the user has entered.
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: mFourthColor, width: 2.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: mFourthColor, width: 2.0),
                              ),
                              hintText: 'BMI',
                              hintStyle: TextStyle(color: mFourthColor)),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        )
                    ),
                  ],
                ),
                Container(

                  child: DropdownButtonHideUnderline(
                      child: Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: mSecondaryColor,
                          ),
                          child: DropdownButton<String>(
                            borderRadius: BorderRadius.circular(10),
                            iconEnabledColor: mFourthColor,
                            iconDisabledColor: mFourthColor,
                            hint:Text("ชนิดการผ่าตัด",style: TextStyle(color: mFourthColor)),
                            isExpanded: true,
                            value: null ??dropdownValue2  ,
                            elevation: 16,
                            style: TextStyle(color: mThirdColor),


                            items: <String>['ชนิดการผ่าตัด','CABG', 'OPCAB ']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,style: TextStyle(color: mFourthColor , fontFamily: 'kanit')),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue2 = newValue!;
                                surgery = dropdownValue2;
                              });
                            },
                          )
                      )

                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  constraints: BoxConstraints.tightFor(width: 250, height: 100),
                  child: GestureDetector(
                    onTap: () {
                      registerUser();
                    },
                    child: Text("ลงทะเบียน" , textAlign: TextAlign.center , style: TextStyle(color: mFourthColor ,decoration: TextDecoration.underline , fontSize: 20)),
                  ),
                )
              ],

            )

        ),
      )

    );
  }
  void registerUser() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {

      final newUser = await createUser();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SuccessScreen(user: newUser)),
      );
      }
    }

  Future createUser() async {
    final user = User(name: name, surname: surname, gender: gender, age: age, weight: weight ,bmi: bmi,surgery: surgery,createAt: DateTime.now());
    await WeightDatabase.instance.createUser(user);
    return user;
  }
}
