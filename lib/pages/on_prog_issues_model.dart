import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rescue_app/models/case.dart';
import 'package:rescue_app/pages/home.dart';


class Issue1 extends StatefulWidget {

  final String issueId ;
  final String ownerId ;
  final String rescueId ;
  final String issue ;
  final String fullAddress ;
  final String resType ;
  final String phone ;
  final String displayName ;

  Issue1({this.issueId , this.ownerId , this.rescueId , this.issue , this.fullAddress , this.resType , this.phone , this.displayName});

  factory Issue1.fromDoc(DocumentSnapshot doc){
    return Issue1(
      issueId: doc['issueId'],
      ownerId: doc['ownerId'],
      rescueId: doc['rescueId'],
      issue: doc['issue'],
      fullAddress: doc['fullAddress'],
      resType: doc['resType'],
      phone: doc['phone'],
      displayName: doc['displayName'],
    );
  }

  @override
  _Issue1State createState() => _Issue1State(
      issueId: this.issueId ,
      ownerId: this.ownerId ,
      rescueId: this.rescueId ,
      issue: this.issue ,
      fullAddress: this.fullAddress ,
      resType: this.resType ,
      phone: this.phone ,
      displayName: this.displayName
  );
}

class _Issue1State extends State<Issue1> {

  final String issueId ;
  final String ownerId ;
  final String rescueId ;
  final String issue ;
  final String fullAddress ;
  final String resType ;
  final String phone ;
  final String displayName ;

  _Issue1State({this.issueId , this.ownerId , this.rescueId , this.issue , this.fullAddress , this.resType , this.phone , this.displayName});

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
                        Text('Rescue Type: $resType') ,
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
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: (){
                Firestore.instance.collection('done').document(currentRes.id).setData({
                  'issueId' : issueId ,
                  'ownerId' : ownerId ,
                  'rescueId' : currentRes.id ,
                  'issue' : issue ,
                  'name' : caseA.displayName ,
                  'email' : caseA.email ,
                  'phone' : caseA.phone ,
                  'rescueType' : resType ,
                  'fullAddress' : fullAddress ,
                }).whenComplete(() =>{
                  Firestore.instance.collection('inProgress').document(currentRes.id).delete()
                });
              },
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
        Text('Rescue Type : $resType') ,
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
