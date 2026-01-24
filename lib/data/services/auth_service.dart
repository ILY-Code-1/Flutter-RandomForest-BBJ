// File: auth_service.dart
// Service untuk Authentication menggunakan Firestore only

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection name
  static const String usersCollection = 'users_bbj';

  // Current user session
  UserModel? _currentUser;

  // Get current user
  UserModel? get currentUser => _currentUser;

  // Hash password
  // String _hashPassword(String password) {
  //   final bytes = utf8.encode(password);
  //   final digest = sha256.convert(bytes);
  //   return digest.toString();
  // }

  // Login dengan email dan password
  Future<UserModel?> signIn(String email, String password) async {
    try {
      // final hashedPassword = _hashPassword(password);

      // Query user by email
      final querySnapshot = await _firestore
          .collection(usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Email tidak ditemukan');
      }

      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();

      // Check password
      if (userData['password'] != password) {
        throw Exception('Password salah');
      }

      // Create user model (without password)
      final user = UserModel(
        id: userDoc.id,
        email: userData['email'] as String,
        nama: userData['nama'] as String,
        role: userData['role'] as String,
        createdAt: DateTime.parse(userData['createdAt'] as String),
      );

      _currentUser = user;
      return user;
    } catch (e) {
      throw Exception('Login gagal: ${e.toString()}');
    }
  }

  // Logout
  Future<void> signOut() async {
    _currentUser = null;
  }

  // Get user data dari Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return UserModel(
          id: doc.id,
          email: data['email'] as String,
          nama: data['nama'] as String,
          role: data['role'] as String,
          createdAt: DateTime.parse(data['createdAt'] as String),
        );
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil data user: ${e.toString()}');
    }
  }

  // Create user (hanya untuk admin)
  Future<UserModel> createUser({
    required String email,
    required String password,
    required String nama,
    required String role,
  }) async {
    try {
      // Check if email already exists
      final existingUser = await _firestore
          .collection(usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        throw Exception('Email sudah digunakan');
      }

      // Hash password
      // final hashedPassword = _hashPassword(password);

      // Create new document with auto-generated ID
      final docRef = _firestore.collection(usersCollection).doc();

      final userData = {
        'email': email,
        'password': password,
        'nama': nama,
        'role': role,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await docRef.set(userData);

      // Return user model without password
      return UserModel(
        id: docRef.id,
        email: email,
        nama: nama,
        role: role,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Gagal membuat user: ${e.toString()}');
    }
  }

  // Update user data
  Future<void> updateUser(
    String uid, {
    String? nama,
    String? role,
    String? password,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (nama != null) updates['nama'] = nama;
      if (role != null) updates['role'] = role;
      if (password != null) updates['password'] = password;

      await _firestore.collection(usersCollection).doc(uid).update(updates);
    } catch (e) {
      throw Exception('Gagal update user: ${e.toString()}');
    }
  }

  // Delete user
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(usersCollection).doc(uid).delete();
    } catch (e) {
      throw Exception('Gagal menghapus user: ${e.toString()}');
    }
  }

  // Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection(usersCollection).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel(
          id: doc.id,
          email: data['email'] as String,
          nama: data['nama'] as String,
          role: data['role'] as String,
          createdAt: DateTime.parse(data['createdAt'] as String),
        );
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil daftar user: ${e.toString()}');
    }
  }

  // Get marketing users only
  Future<List<UserModel>> getMarketingUsers() async {
    try {
      final snapshot = await _firestore
          .collection(usersCollection)
          .where('role', isEqualTo: 'marketing')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel(
          id: doc.id,
          email: data['email'] as String,
          nama: data['nama'] as String,
          role: data['role'] as String,
          createdAt: DateTime.parse(data['createdAt'] as String),
        );
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil daftar marketing: ${e.toString()}');
    }
  }

  // Check if logged in
  bool isLoggedIn() {
    return _currentUser != null;
  }
}
