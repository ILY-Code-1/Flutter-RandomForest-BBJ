// File: firestore_service.dart
// Service untuk menyimpan dan mengambil prediction sessions dari Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prediction_model.dart';
import '../models/comment_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection name
  static const String predictionsCollection = 'predictions';

  // Simpan prediction session ke Firestore
  Future<void> savePredictionSession(PredictionSessionModel session) async {
    try {
      await _firestore
          .collection(predictionsCollection)
          .doc(session.id)
          .set(session.toJson());
    } catch (e) {
      throw Exception('Gagal menyimpan prediksi: ${e.toString()}');
    }
  }

  // Get all predictions (untuk admin)
  Future<List<PredictionSessionModel>> getAllPredictions() async {
    try {
      final snapshot = await _firestore
          .collection(predictionsCollection)
          .orderBy('tanggalPrediksi', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PredictionSessionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil prediksi: ${e.toString()}');
    }
  }

  // Get predictions untuk user tertentu (untuk marketing)
  Future<List<PredictionSessionModel>> getUserPredictions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(predictionsCollection)
          .where('assignedUserIds', arrayContains: userId)
          .orderBy('tanggalPrediksi', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PredictionSessionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil prediksi: ${e.toString()}');
    }
  }

  // Get single prediction
  Future<PredictionSessionModel?> getPrediction(String id) async {
    try {
      final doc =
          await _firestore.collection(predictionsCollection).doc(id).get();
      if (doc.exists) {
        return PredictionSessionModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil prediksi: ${e.toString()}');
    }
  }

  // Update assigned users
  Future<void> updateAssignedUsers(String predictionId, List<String> userIds) async {
    try {
      await _firestore
          .collection(predictionsCollection)
          .doc(predictionId)
          .update({'assignedUserIds': userIds});
    } catch (e) {
      throw Exception('Gagal update assigned users: ${e.toString()}');
    }
  }

  // Add comment
  Future<void> addComment(String predictionId, CommentModel comment) async {
    try {
      final doc = await _firestore
          .collection(predictionsCollection)
          .doc(predictionId)
          .get();

      if (doc.exists) {
        final session = PredictionSessionModel.fromJson(doc.data()!);
        final updatedComments = [...session.comments, comment];
        
        await _firestore.collection(predictionsCollection).doc(predictionId).update({
          'comments': updatedComments.map((c) => c.toJson()).toList(),
        });
      }
    } catch (e) {
      throw Exception('Gagal menambah comment: ${e.toString()}');
    }
  }

  // Delete comment
  Future<void> deleteComment(String predictionId, String commentId) async {
    try {
      final doc = await _firestore
          .collection(predictionsCollection)
          .doc(predictionId)
          .get();

      if (doc.exists) {
        final session = PredictionSessionModel.fromJson(doc.data()!);
        final updatedComments = session.comments
            .where((c) => c.id != commentId)
            .toList();
        
        await _firestore.collection(predictionsCollection).doc(predictionId).update({
          'comments': updatedComments.map((c) => c.toJson()).toList(),
        });
      }
    } catch (e) {
      throw Exception('Gagal menghapus comment: ${e.toString()}');
    }
  }

  // Delete prediction (admin only)
  Future<void> deletePrediction(String predictionId) async {
    try {
      await _firestore.collection(predictionsCollection).doc(predictionId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus prediksi: ${e.toString()}');
    }
  }

  // Stream predictions untuk real-time updates
  Stream<List<PredictionSessionModel>> streamAllPredictions() {
    return _firestore
        .collection(predictionsCollection)
        .orderBy('tanggalPrediksi', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PredictionSessionModel.fromJson(doc.data()))
            .toList());
  }

  Stream<List<PredictionSessionModel>> streamUserPredictions(String userId) {
    return _firestore
        .collection(predictionsCollection)
        .where('assignedUserIds', arrayContains: userId)
        .orderBy('tanggalPrediksi', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PredictionSessionModel.fromJson(doc.data()))
            .toList());
  }
}
