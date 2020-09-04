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
  List<String> rescueTypeItems = <String>['Police', 'Ambulance' , 'Firefighting'];
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
              title: Text('Home'),
              centerTitle: true,
              backgroundColor: Colors.red,
              actions: <Widget>[
                FlatButton(
                  child: Text('Edit Profile'),
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
                                          'Enter ur phone number' ,
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
                                                    return('The number is not correct') ;
                                                  }else if(val.trim().length > 12){
                                                    return('The number is too long') ;
                                                  }else{
                                                    return null ;
                                                  }
                                                },
                                                onSaved: (val) => phone = val,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  icon: Icon(Icons.phone) ,
                                                  labelText: 'Phone number' ,
                                                  labelStyle: TextStyle(fontSize: 12) ,
                                                  hintText: '01234567890' ,
                                                ),
                                              ),
                                              SizedBox(height: 10,) ,
                                              TextFormField(
                                                autovalidate: true,
                                                validator: (val){
                                                  if(val.trim().length < 6 || val.isEmpty){
                                                    return('The name is not correct') ;
                                                  }else if(val.trim().length > 30){
                                                    return('The name is too long') ;
                                                  }else{
                                                    return null ;
                                                  }
                                                },
                                                onSaved: (val) => fullName = val,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  icon: Icon(Icons.person) ,
                                                  labelText: 'Full Name' ,
                                                  labelStyle: TextStyle(fontSize: 12) ,
                                                ),
                                              ),
                                              SizedBox(height: 10,) ,
//                                              DropdownButton(
//                                                items: rescueTypeItems
//                                                    .map((value) => DropdownMenuItem(
//                                                  child: Text(value),
//                                                  value: value,
//                                                ),
//                                                ).toList(),
//                                                onChanged: (selectedRescueType){
//                                                  setState(() {
//                                                    selectedRescue = selectedRescueType ;
//                                                  });
//                                                },
//                                                value: selectedRescue,
//                                                isExpanded: false,
//                                                hint: Text('Select Rescue Type'),
//                                              ),
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
                                            'Submit' ,
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
//                                          SnackBar snackBar = SnackBar(content: Text('Welcome !'),);
//                                          _scaffoldKey.currentState.showSnackBar(snackBar) ;
                                          rescueRef.document(currentRes.id).updateData({
                                            'fullName' : fullName,
                                            'phone' :  phone,
//                                            'rescueType' : selectedRescue ,
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
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'LogOut' ,
                  style: TextStyle(
                    color: Colors.red ,
                    fontSize: 20 ,
                  ),
                ),
                RaisedButton(
                  child: Icon(Icons.arrow_back),
                  onPressed: signOut,
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
          BottomNavigationBarItem(icon: Icon(Icons.arrow_back)),
          BottomNavigationBarItem(icon: Icon(Icons.feedback)),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_filled)),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle)),
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
              Colors.grey.shade700,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Rescue App !' ,
              style: TextStyle(
                fontSize: 30 ,
                color: Colors.white ,
              ),
            ),
            SizedBox(height: 10,),
            Text(
              'Sign In By Google !' ,
              style: TextStyle(
                fontSize: 40 ,
                color: Colors.white ,
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
