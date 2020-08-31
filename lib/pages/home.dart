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
  int pageIndex = 0;

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
      final rescueType = await Navigator.push(context , MaterialPageRoute(builder: (context) => CreateAccount()));
      rescueRef.document(rescue.id).setData({
        'id' : rescue.id ,
        'displayName' : rescue.displayName ,
        'photoUrl' : rescue.photoUrl ,
        'email' : rescue.email ,
        'rescueType' : rescueType ,
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
          Column(
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
