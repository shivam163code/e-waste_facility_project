import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ewaste_center.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of e-waste centers from Firestore
  Stream<List<EwasteCenter>> getEwasteCenters() {
    return _db.collection('ewaste_centers').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => EwasteCenter.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  // Add a new facility
  Future<void> addCenter(EwasteCenter center) async {
    await _db.collection('ewaste_centers').add(center.toMap());
  }

  // Delete a facility
  Future<void> deleteCenter(String id) async {
    await _db.collection('ewaste_centers').doc(id).delete();
  }
}
