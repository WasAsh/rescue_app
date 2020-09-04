import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rescue_app/models/rescue_man.dart';
import 'package:rescue_app/pages/create_account.dart';
import 'package:rescue_app/pages/done_feeds.dart';
import 'package:rescue_app/pages/feeds.dart';
import 'package:rescue_app/pages/on_prog_feeds.dart';


final GoogleSignIn googleSignIn = GoogleSignIn();
final caseRef = Firestore.instance.collection('case');
final rescueRef = Firestore.instance.collection('rescue') ;
final issueRef = Firestore.instance.collection('issues') ;
final StorageReference storageRef = FirebaseStorage.instance.ref();
final DateTime timeStamp = DateTime.now();
Rescue currentRes ;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool isAuth = false ;
  PageController pageViewController ;
  final _formKey = GlobalKey<FormState>();
  int pageIndex = 0;
  String phone , fullName ;
  List<String> rescueTypeItems = <String>['شرطي', 'مسعف' , 'رجل اطفاء'];
  var selectedRescue;

  //ensure that user signed in or not
  @override
  void initState() {
    super.initState();
    pageViewController = PageController();
    //1
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account) ;
    } , onError: (err){
      print('Error is $err') ;
    });
    //2
    googleSignIn.signInSilently(suppressErrors: false).then((account){
      handleSignIn(account);
    }).catchError((err){
      print('Error is $err');
    });
  }

  handleSignIn(GoogleSignInAccount account){
    if(account != null){
      createUserInFireStore() ;
      setState(() {
        isAuth = true ;
      });
    }else{
      setState(() {
        isAuth = false ;
      });
    }
  }

  login(){
    googleSignIn.signIn() ;
  }
  signOut(){
    googleSignIn.signOut() ;
  }

  @override
  void dispose() {
    pageViewController.dispose();
    super.dispose();
  }

  //create user in firestore
  createUserInFireStore() async {
    final GoogleSignInAccount rescue = googleSignIn.currentUser ;
    DocumentSnapshot doc = await rescueRef.document(rescue.id).get();

    if(!doc.exists){
      final resType = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccount()));
      rescueRef.document(rescue.id).setData({
        'id' : rescue.id ,
        'displayName' : rescue.displayName ,
        'fullName' : null ,
        'photoUrl' : rescue.photoUrl ,
        'email' : rescue.email ,
        'rescueType' : resType ,
        'phone' : null ,
        'timeStamp' : timeStamp ,
      });
      doc = await rescueRef.document(rescue.id).get();
    }
    currentRes = Rescue.fromDocument(doc) ;
    print(currentRes.email) ;
  }

  //handle page changing
  onPageChanged(int index){
    setState(() {
      this.pageIndex = index ;
    });
  }

  onTap(int index){
    pageViewController.animateToPage(
      index ,
      duration: Duration(milliseconds: 300) ,
      curve: Curves.bounceInOut ,
    );
  }

//draw widgets
  Scaffold buildAuthScreen(){
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Scaffold(
            appBar: AppBar(
              title: Text('الرئيسية'),
              centerTitle: true,
              backgroundColor: Colors.red,
              actions: <Widget>[
                RaisedButton.icon(
                  icon: Icon(Icons.cancel),
                  label: Text('تسجيل الخروج'),
                  onPressed: signOut,
                  color: Colors.red,
                ),
              ],
            ),
            body: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 30 , right: 10 , left: 10),
                  child: Text(
                    'مرحباً بك : من فضلك قم بتحديث ملفك الشخصي عند اول استخدام للتطبيق بواسطة الذهاب الى الصفحه المخصصة لذلك عن طريق' ,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black ,
                      fontSize: 20 ,
                      fontWeight: FontWeight.bold ,
                    ),
                  ),
                ),
                FlatButton(
                  child: Text('تعديل البيانات' , style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                  onPressed: (){
                    showModalBottomSheet(
                        context: context ,
                        builder: (context){
                          return ListView(
                            children: <Widget>[
                              Container(
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(top: 25),
                                      child: Center(
                                        child: Text(
                                          'تعديل البيانات الشخصية' ,
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
                                              TextFormField(
                                                autovalidate: true,
                                                validator: (val){
                                                  if(val.trim().length < 6 || val.isEmpty){
                                                    return('الرقم المدخل غير صحيح') ;
                                                  }else if(val.trim().length > 15){
                                                    return('الرقم المدخل غير صحيح') ;
                                                  }else{
                                                    return null ;
                                                  }
                                                },
                                                onSaved: (val) => phone = val,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  icon: Icon(Icons.phone) ,
                                                  labelText: 'رقم الهاتف' ,
                                                  labelStyle: TextStyle(fontSize: 12) ,
                                                  hintText: '01234567890' ,
                                                ),
                                              ),
                                              SizedBox(height: 10,) ,
                                              TextFormField(
                                                autovalidate: true,
                                                validator: (val){
                                                  if(val.trim().length < 6 || val.isEmpty){
                                                    return('الاحرف قليلة جدا') ;
                                                  }else if(val.trim().length > 30){
                                                    return('الاحرف كثيرة جدا') ;
                                                  }else{
                                                    return null ;
                                                  }
                                                },
                                                onSaved: (val) => fullName = val,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  icon: Icon(Icons.person) ,
                                                  labelText: 'الاسم بالكامل' ,
                                                  labelStyle: TextStyle(fontSize: 12) ,
                                                ),
                                              ),
                                              SizedBox(height: 10,) ,
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
                                      onTap: (){
                                        final form = _formKey.currentState ;
                                        if(form.validate()){
                                          form.save() ;
                                          rescueRef.document(currentRes.id).updateData({
                                            'fullName' : fullName,
                                            'phone' :  phone,
                                          });
                                          Timer(Duration(seconds: 1) , (){
                                            Navigator.pop(context) ;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ) ;
                        }
                    );
                  },
                ),
              ],
            ),
          ),
          Feeds(rescueId: currentRes?.id ),
          OnProgressFeeds(rescueId: currentRes?.id),
          DoneFeeds(rescueId: currentRes?.id),
        ],
        controller: pageViewController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Colors.red,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.arrow_back) , title: Text('الرئيسية' , style: TextStyle(fontSize: 13),)),
          BottomNavigationBarItem(icon: Icon(Icons.feedback) , title: Text('الطلبات' , style: TextStyle(fontSize: 13),)),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_filled) , title: Text('قيد التنفيذ' , style: TextStyle(fontSize: 13),)),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle) , title: Text('منتهية' , style: TextStyle(fontSize: 13),)),
        ],
      ),
    );
  }

  Widget buildUnAuthScreen(){
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight ,
            end: Alignment.bottomLeft ,
            colors: [
              Colors.grey ,
              Colors.red.shade700,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '218 Rescue App' ,
              style: TextStyle(
                fontSize: 40 ,
                fontWeight: FontWeight.bold,
                color: Colors.black ,
              ),
            ),
            SizedBox(height: 10,),
            Text(
              'تطبيق المنقذ' ,
              style: TextStyle(
                fontSize: 20 ,
                fontWeight: FontWeight.bold,
                color: Colors.black38 ,
              ),
            ),
            SizedBox(height: 120,),
            Text(
              'تسجيل الدخول باستخدام حساب غوغل' ,
              style: TextStyle(
                fontSize: 20 ,
                fontWeight: FontWeight.bold,
                color: Colors.black ,
              ),
            ),
            GestureDetector(
              onTap: (){
                login();
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('img/google.png') ,
                    fit: BoxFit.cover ,
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
