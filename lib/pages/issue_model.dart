import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rescue_app/models/case.dart';
import 'package:rescue_app/pages/home.dart';


class Issue extends StatefulWidget {

  final String issueId ;
  final String ownerId ;
  final String issue ;
  final String fullAddress ;
  final String resType ;
  final String city ;
  final String phone ;
  final String fullName ;
  final String fireType ;
  final String firePlace ;
  final String injuryCount ;
  final String injuryType ;

  Issue({this.issueId , this.ownerId , this.issue , this.city , this.fullAddress , this.resType , this.phone , this.fullName , this.fireType , this.firePlace , this.injuryCount , this.injuryType});

  factory Issue.fromDoc(DocumentSnapshot doc){
    return Issue(
      issueId: doc['issueId'],
      ownerId: doc['ownerId'],
      issue: doc['issue'],
      fullAddress: doc['fullAddress'],
      resType: doc['resType'],
      phone: doc['phone'],
      city: doc['city'],
      fullName: doc['fullName'],
      fireType: doc['fireType'],
      firePlace: doc['firePlace'],
      injuryCount: doc['injuryCount'],
      injuryType: doc['injuryType'],
    );
  }

  @override
  _IssueState createState() => _IssueState(
    issueId: this.issueId ,
    ownerId: this.ownerId ,
    issue: this.issue ,
    fullAddress: this.fullAddress ,
    resType: this.resType ,
    phone: this.phone ,
    fullName: this.fullName ,
    city: this.city ,
    fireType: this.fireType,
    firePlace: this.firePlace,
    injuryCount: this.injuryCount,
    injuryType: this.injuryType,
  );
}

class _IssueState extends State<Issue> {

  final String issueId ;
  final String ownerId ;
  final String issue ;
  final String fullAddress ;
  final String resType ;
  final String city ;
  final String phone ;
  final String fullName ;
  final String fireType ;
  final String firePlace ;
  final String injuryCount ;
  final String injuryType ;

  _IssueState({this.issueId , this.ownerId , this.issue , this.fullAddress , this.resType , this.phone , this.fullName , this.city, this.fireType , this.firePlace , this.injuryCount , this.injuryType});

  buildIssueTop(){
    return FutureBuilder(
      future: caseRef.document(ownerId).get(),
      builder: (context , snapShot){
        if(!snapShot.hasData){
          return CircularProgressIndicator() ;
        }
        Case caseA = Case.fromDocument(snapShot.data);
        print(caseA.displayName) ;
        return GestureDetector(
          onTap: (){
            showModalBottomSheet(
              context: context ,
              builder: (context){
                return Padding(
                  padding: const EdgeInsets.only(left:15 , right: 15),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(height: 20,),
                        Center(child: Text('البيانات بالكامل' , style: TextStyle(fontWeight: FontWeight.bold ,fontSize: 18),),) ,
                        SizedBox(height: 10,),
                        Directionality(textDirection:TextDirection.rtl ,child: Text('الاسم بالكامل: ${caseA.displayName}')) ,
                        SizedBox(height: 10,),
                        Directionality(textDirection: TextDirection.rtl,child: Text('رقم الهاتف: ${caseA.phone}')) ,
                        SizedBox(height: 10,),
                        Directionality(textDirection: TextDirection.rtl,child: Text('الايميل: ${caseA.email}')) ,
                        SizedBox(height: 10,),
                        Directionality(textDirection: TextDirection.rtl,child: Text('العنوان بالكامل: $fullAddress')) ,
                        SizedBox(height: 10,),
                        Directionality(textDirection: TextDirection.rtl,child: Text('الطلب: $issue')) ,
                        SizedBox(height: 10,),
                        Directionality(textDirection: TextDirection.rtl,child: Text('نوع الطلب: $resType')) ,
                        SizedBox(height: 10,),
                        Directionality(textDirection: TextDirection.rtl,child: Text('نوع الاصابة(اسعاف): $injuryType')) ,
                        SizedBox(height: 10,),
                        Directionality(textDirection: TextDirection.rtl,child: Text('عدد الاصابات(اسعاف): $injuryCount')) ,
                        SizedBox(height: 10,),
                        Directionality(textDirection: TextDirection.rtl,child: Text('نوع الحريق(حريق): $fireType')) ,
                        SizedBox(height: 10,),
                        Directionality(textDirection: TextDirection.rtl,child: Text('مكان الحريق(حريق): $firePlace')) ,
                        SizedBox(height: 10,),
                      ],
                    ),
                  ),
                );
              }
            );
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(caseA.photoUrl),
            ),
            trailing: IconButton(
              icon: Icon(Icons.done_outline),
              onPressed: ()  {
                Firestore.instance.collection('inProgress').document(currentRes.id).setData({
                  'issueId' : issueId ,
                  'ownerId' : ownerId ,
                  'rescueId' : currentRes.id ,
                  'issue' : issue ,
                  'fullName' : fullName ,
                  'email' : caseA.email ,
                  'phone' : caseA.phone ,
                  'rescueType' : resType ,
                  'fullAddress' : fullAddress ,
                  'injuryType' : injuryType ,
                  'injuryCount' : injuryCount ,
                  'fireType' : fireType ,
                  'firePlace' : firePlace ,
                }).whenComplete(() =>{
                  Firestore.instance.collection('issues').document(issueId).delete()
                });
              },
            ),
            title: Text(
              fullName ,
              style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
                caseA.phone
            ),
          ),
        );
      },
    );
  }
  buildIssueBody(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Issue : $issue ') ,
        Text('Full Address : $fullAddress'),
        Text('Rescue Type : $resType') ,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        buildIssueTop() ,
        Padding(padding: EdgeInsets.only(left: 30), child: buildIssueBody(),) ,
        Divider(thickness: 2,),
        SizedBox(height: 15,)
      ],
    );
  }
}
