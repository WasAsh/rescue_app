import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rescue_app/models/case.dart';
import 'package:rescue_app/pages/home.dart';


class Issue2 extends StatefulWidget {

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

  Issue2({this.issueId , this.ownerId , this.issue , this.city , this.fullAddress , this.resType , this.phone , this.fullName , this.fireType , this.firePlace , this.injuryCount , this.injuryType});

  factory Issue2.fromDoc(DocumentSnapshot doc){
    return Issue2(
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
  _Issue2State createState() => _Issue2State(
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

class _Issue2State extends State<Issue2> {

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

  _Issue2State({this.issueId , this.ownerId , this.issue , this.fullAddress , this.resType , this.phone , this.fullName , this.city, this.fireType , this.firePlace , this.injuryCount , this.injuryType});

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
                    padding: const EdgeInsets.only(left:15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 40,),
                        Center(child: Text('Full Info' , style: TextStyle(fontWeight: FontWeight.bold),),) ,
                        SizedBox(height: 10,),
                        Text('Full Name: ${caseA.displayName}') ,
                        SizedBox(height: 10,),
                        Text('Phone Num: ${caseA.phone}') ,
                        SizedBox(height: 10,),
                        Text('Email: ${caseA.email}') ,
                        SizedBox(height: 10,),
                        Text('Full Address: $fullAddress') ,
                        SizedBox(height: 10,),
                        Text('Issue: $issue') ,
                        SizedBox(height: 10,),
                        Text('Injury Type: $injuryType') ,
                        SizedBox(height: 10,),
                        Text('Injury Count: $injuryCount') ,
                        SizedBox(height: 10,),
                        Text('Fire Type: $fireType') ,
                        SizedBox(height: 10,),
                        Text('Fire Place: $firePlace') ,
                        SizedBox(height: 10,),
                      ],
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
            title: Text(
              caseA.displayName ,
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildIssueTop() ,
        buildIssueBody() ,
        Divider(thickness: 2,),
        SizedBox(height: 15,)
      ],
    );
  }
}
