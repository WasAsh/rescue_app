import 'package:cloud_firestore/cloud_firestore.dart';


class Case{
  final String id ;
  final String displayName ;
  final String email ;
  final String photoUrl ;
  final String phone ;

  Case({this.id , this.displayName , this.email , this.photoUrl , this.phone}) ;
  factory Case.fromDocument(DocumentSnapshot doc){
    return Case(
      id: doc['id'] ,
      displayName: doc['displayName'] ,
      email: doc['email'] ,
      photoUrl: doc['photoUrl'] ,
      phone: doc['phone'] ,
    );
  }
}