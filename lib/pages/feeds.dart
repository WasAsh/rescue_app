import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rescue_app/pages/home.dart';
import 'package:rescue_app/pages/issue_model.dart';



class Feeds extends StatefulWidget {

  final String rescueId ;
  Feeds({this.rescueId});

  @override
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> {

  final String currentResId =currentRes.id ;
  bool isLoading = false ;
  int issuesCount = 0 ;
  List<Issue> issues = [] ;

  @override
  void initState() {
    super.initState();
    getIssues();
  }

  getIssues() async {
    setState(() {
      isLoading = true ;
    });
    QuerySnapshot snapshot  = await issueRef.where('resType' , isEqualTo: currentRes.rescueType).getDocuments();
    setState(() {
      isLoading = false ;
      issuesCount = snapshot.documents.length ;
      issues = snapshot.documents.map((doc) => Issue.fromDoc(doc)).toList();
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
        title: Text('الطلبات'),
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
