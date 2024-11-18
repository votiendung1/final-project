import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // lấy instancce của firebase auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // lấy người dùng hiện tại
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // đăng nhập
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      // đăng nhập người dùng
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // đăng ký
  Future<UserCredential> signUpWithEmailPassword(String email, password) async {
    try {
      // đăng ký người dùng
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Kiểm tra lỗi cụ thể từ FirebaseAuth
      if (e.code == 'email-already-in-use') {
        throw Exception('email-already-in-use');
      } else {
        throw Exception(e.message ?? 'Đã xảy ra lỗi.');
      }
    }
  }

  // đăng xuất
  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }
}