import 'package:cloud_firestore/cloud_firestore.dart';

class BencanaFirestoreService {
  // inisiasi database dan nama koleksi
  final _collection = FirebaseFirestore.instance.collection('bencana');

  // method menambah bencana (gunakan set bukan add karena kita sudah punya id)
  Future<void> setBencana(String id, Map<String, dynamic> data) async {
    await _collection.doc(id).set(data);
  }

  Future<List<Map<String, dynamic>>> getAllBencana() async {
    final snapshot = await _collection
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<void> updateBencana(String id, Map<String, dynamic> data) async {
    await _collection.doc(id).update(data);
  }

  Future<void> deleteBencana(String id) async {
    await _collection.doc(id).delete();
  }
}
