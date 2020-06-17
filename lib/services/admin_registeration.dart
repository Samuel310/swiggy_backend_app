import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swiggybackend/modals/admin_type.dart';
import 'package:swiggybackend/services/admin_data_service.dart';

class AdminRegisteration {
  
  CollectionReference admin_registerations = Firestore.instance.collection('admin_registerations');
  
  Future addAdmin(String email, String hotel_id, String branch_id, String adminType) async{
    bool isExists = await AdminDataService().emailExistsInAdminsCollection(email);
    if(!isExists){
      bool isExistsInRegisteration = await emailExistsInRegisterationCollection(email);
      if(!isExistsInRegisteration){
        admin_registerations.add({
          'email': email,
          'admin_type': adminType,
          'hotel_id' : hotel_id,
          'branch_id' : branch_id
        });
      }
      else{
        return 'email already added, Account creation pending';
      }
    }
    else{
      return 'email already exists';
    }
  }

  Future<bool> emailExistsInRegisterationCollection(String email) async{
    int length = (await admin_registerations
            .where("email", isEqualTo: email)
        .getDocuments()).documents.length;
    return (length == 0) ? false : true;
  }

  Future<AdminType> getAdminData(String email) async{
    try{
      AdminType adminType;
      await admin_registerations.where("email", isEqualTo: email).getDocuments().then((value) {
        return adminType = AdminType(email: value.documents[0].data['email'], acc_type: value.documents[0].data['admin_type'], hotel_id: value.documents[0].data['hotel_id'], branch_id: value.documents[0].data['branch_id']);
      });
      print(adminType.email);
      return adminType;
    }catch (e){
      return null;
    }
  }
  
  void deleteAdminData(String email) async{
    admin_registerations.where("email", isEqualTo: email).getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents){
        ds.reference.delete();
      }
    });
  }
  
}