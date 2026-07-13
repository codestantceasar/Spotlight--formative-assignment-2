import 'package:cloud_firestore/cloud_firestore.dart';

class OpportunityService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getOpportunities() {
    return firestore.collection('opportunities').snapshots();
  }
}
