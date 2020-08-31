import 'package:cloud_firestore/cloud_firestore.dart';


class Rescue{

  final String id ;
  final String userName ;
  final String email ;
  final String photoUrl ;
  final String rescueType ;

  Rescue({this.id , this.userName , this.email , this.photoUrl , this.rescueType}) ;

  factory Rescue.fromDocument(DocumentSnapshot doc){
    return Rescue(
      id: doc['id'] ,
      userName: doc['userName'] ,
      email: doc['email'] ,
      photoUrl: doc['photoUrl'] ,
      rescueType: doc['rescueType'] ,
    );
  }

}