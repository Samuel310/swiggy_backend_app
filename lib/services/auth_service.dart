import 'package:firebase_auth/firebase_auth.dart';
import 'package:swiggybackend/modals/admin_type.dart';
import 'package:swiggybackend/services/admin_data_service.dart';
import 'package:swiggybackend/services/admin_registeration.dart';

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AdminDataService _adminDataService = AdminDataService();
  final AdminRegisteration _adminRegisteration = AdminRegisteration();

  // auth change user stream
  Stream<FirebaseUser> get user {
    return _auth.onAuthStateChanged;
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } catch (e) {
      print(e.toString());
      return e.message;
    }
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    AdminType adminType = await _adminRegisteration.getAdminData(email);
    if(adminType != null){
      try {
        AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        _adminDataService.addAdmin(adminType.acc_type, adminType.hotel_id, adminType.branch_id, adminType.email, result.user.uid, 'active');
        _adminRegisteration.deleteAdminData(email);
        return null;
      } catch (error) {
        print(error.toString());
        return error.message;
      }
    }
    else{
      return 'Account cannot be created';
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future deteteAccount() async {
    try {
      FirebaseUser user = await _auth.currentUser();
      await _adminDataService.deleteAdmin(user.uid);
      await user.delete();
    } catch (error) {
      print(error.toString());
    }
  }

}