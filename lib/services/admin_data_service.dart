import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swiggybackend/modals/admin_type.dart';

class AdminDataService{

  CollectionReference adminsCollection = Firestore.instance.collection('admins');

  String hotel_id;
  String branch_id;

  // used to get the stream of hotel admins
  AdminDataService({this.hotel_id});

  // used to get stream of branch admins
  AdminDataService.withBranch({this.hotel_id, this.branch_id});

  // to get the list of hotel admins
  Stream<List<AdminType>> get hotels {
     return adminsCollection
         .where("hotel_id", isEqualTo: hotel_id)
         .where("branch_id", isEqualTo: 'none')
         .where("admin_status", isEqualTo: 'active')
         .snapshots().map(_AdminListFromSnapshot);
  }

  // for converting hotel admin snapshots into admin object
  List<AdminType> _AdminListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      return AdminType(
        acc_type: doc.data['admin_type'] ?? 'EMPTY',
        branch_id: doc.data['branch_id'] ?? 'EMPTY',
        hotel_id: doc.data['hotel_id'] ?? 'EMPTY',
        email: doc.data['email'] ?? 'EMPTY',
        admin_status: doc.data['admin_status'] ?? 'EMPTY',
        uid: doc.documentID ?? 'EMPTY'
      );
    }).toList();
  }

  // to get the list of branch admins
  Stream<List<AdminType>> get branches {
    return adminsCollection
        .where("hotel_id", isEqualTo: hotel_id)
        .where("branch_id", isEqualTo: branch_id)
        .where("admin_status", isEqualTo: 'active')
        .snapshots().map(_BranchListFromSnapshot);
  }

  // for converting branch admin snapshots into admin object
  List<AdminType> _BranchListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      return AdminType(
        acc_type: doc.data['admin_type'] ?? 'EMPTY',
        branch_id: doc.data['branch_id'] ?? 'EMPTY',
        hotel_id: doc.data['hotel_id'] ?? 'EMPTY',
        email: doc.data['email'] ?? 'EMPTY',
        admin_status: doc.data['admin_status'] ?? 'EMPTY',
        uid: doc.documentID ?? 'EMPTY'
      );
    }).toList();
  }

  // for retrieving current admin data who is logged in
  Future<dynamic> getData(String uid) async{
    try{
      AdminType adminType;
      await adminsCollection.document(uid).snapshots().first.then(
              (value) {
                print(value.data);
                return adminType = AdminType(acc_type: value.data['admin_type'], branch_id: value.data['branch_id'], hotel_id: value.data['hotel_id'], email: value.data['email'], admin_status: value.data['admin_status'], uid: value.documentID);
              }
      );
      return adminType;
    }catch (e){
      return e;
    }
  }

  // for adding admin data
  void addAdmin(String admin_type, String hotel_id, String branch_id, String email, String uid, String admin_status){
    adminsCollection.document(uid).setData({
      'admin_type' : admin_type,
      'hotel_id' : hotel_id,
      'branch_id' : branch_id,
      'email' : email,
      'admin_status' : admin_status
    });
  }

  // checks if admin exists in admin collection
  Future<bool> emailExistsInAdminsCollection(String email) async{
    int length = (await adminsCollection
        .where("email", isEqualTo: email)
        .getDocuments()).documents.length;
    print('email in admins collection : $length');
    return (length == 0) ? false : true;
  }

  // to change the admin_status form 'active' to 'in-active' for all the admins related to particular hotel
  Future deactivateAdmins(String hotel_id) async{
    QuerySnapshot querySnapshot = await adminsCollection.where("hotel_id", isEqualTo: hotel_id).getDocuments();
    List<DocumentSnapshot> docSnapList = querySnapshot.documents;
    for(final doc in docSnapList){
      adminsCollection.document(doc.documentID).updateData({
        'admin_status' : 'in-active'
      });
    }
  }

  // to change the admin_status form 'active' to 'in-active' for all the admins related to particular branch
  Future deactivateBranchAdmins(String hotel_id, String branch_id) async{
    QuerySnapshot querySnapshot = await adminsCollection
        .where("hotel_id", isEqualTo: hotel_id)
        .where("branch_id", isEqualTo: branch_id)
        .getDocuments();
    List<DocumentSnapshot> docSnapList = querySnapshot.documents;
    for(final doc in docSnapList){
      adminsCollection.document(doc.documentID).updateData({
        'admin_status' : 'in-active'
      });
    }
  }

  // to change the admin_status form 'active' to 'in-active' for particular admin
  Future deactivateSingleAdmin(String uid) async{
    await adminsCollection.document(uid).updateData({
      'admin_status' : 'in-active'
    });
  }

  // permanently deletes admin data form collection
  Future deleteAdmin(String uid) async{
    await adminsCollection.document(uid).delete();
  }

}