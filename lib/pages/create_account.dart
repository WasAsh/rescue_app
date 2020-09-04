import 'dart:async';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {

  String type , value ;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  submit(){
    final form = _formKey.currentState ;
    if(form.validate()){
      form.save() ;
      SnackBar snackBar = SnackBar(content: Text('مرحبا : $type'),);
      _scaffoldKey.currentState.showSnackBar(snackBar) ;
      Timer(Duration(seconds: 3) , (){
        Navigator.pop(context , type) ;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('تعديل البيانات'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25),
                  child: Center(
                    child: Text(
                      'من فضلك قم باختيار نوع الانقاذ' ,
                      style: TextStyle(
                        fontSize: 25 ,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          DropdownButtonFormField(
                            value: value,
                            items: [
                              DropdownMenuItem<String>(
                                child: Text('شرطي'),
                                value: 'شرطي',
                              ),
                              DropdownMenuItem(
                                child: Text('رجل اطفاء'),
                                value: 'رجل اطفاء',
                              ),
                              DropdownMenuItem(
                                child: Text('مسعف'),
                                value: 'مسعف',
                              ),
                            ],
                            onChanged: (item){
                              setState(() {
                                item = value ;
                              });
                            },
                            onSaved: (value) => type = value ,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelStyle: TextStyle(fontSize: 15) ,
                              hintText: 'نوع المنقذ' ,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  child: Container(
                    height: 50,
                    width: 350,
                    decoration: BoxDecoration(
                      color: Colors.grey ,
                      borderRadius: BorderRadius.circular(7) ,
                    ),
                    child: Center(
                      child: Text(
                        'تأكيد' ,
                        style: TextStyle(
                          color: Colors.white ,
                          fontSize: 15 ,
                          fontWeight: FontWeight.bold ,
                        ),
                      ),
                    ),
                  ),
                  onTap: submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
