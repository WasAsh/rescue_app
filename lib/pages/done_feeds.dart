import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rescue_app/pages/done_feeds_model.dart';
import 'package:rescue_app/pages/home.dart';



class DoneFeeds extends StatefulWidget {

  final String rescueId ;
  DoneFeeds({this.rescueId});


  @override
  _DoneFeedsState createState() => _DoneFeedsState();
}

class _DoneFeedsState extends State<DoneFeeds> {

  final String currentResId =currentRes.id ;
  bool isLoading = false ;
  int issuesCount = 0 ;
  List<Issue2> issues = [] ;

  @override
  void initState() {
    super.initState();
    getDoneIssues();
  }

  getDoneIssues() async {
    setState(() {
      isLoading = true ;
    });
    QuerySnapshot snapshot  = await Firestore.instance.collection('done').where('rescueId' , isEqualTo: currentRes.id).getDocuments();
    setState(() {
      isLoading = false ;
      issuesCount = snapshot.documents.length ;
      issues = snapshot.documents.map((doc) => Issue2.fromDoc(doc)).toList();
    });
  }

  buildIssues(){
    if(isLoading){
      return CircularProgressIndicator();
    }
    return Column(
      children: issues ,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Done feeds'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: ListView(
        children: <Widget>[
          buildIssues(),
        ],
      ),
    );
  }
}
