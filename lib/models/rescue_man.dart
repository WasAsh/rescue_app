import 'package:cloud_firestore/cloud_firestore.dart';


class Rescue{

  final String id ;
  final String userName ;
  final String fullName ;
  final String email ;
  final String photoUrl ;
  final String rescueType ;
  final String phone ;


  Rescue({this.id , this.fullName , this.userName , this.email , this.photoUrl , this.rescueType , this.phone}) ;

  factory Rescue.fromDocument(DocumentSnapshot doc){
    return Rescue(
      id: doc['id'] ,
      userName: doc['userName'] ,
      fullName: doc['fullName'],
      phone: doc['phone'] ,
      email: doc['email'] ,
      photoUrl: doc['photoUrl'] ,
      rescueType: doc['rescueType'] ,
    );
  }

}