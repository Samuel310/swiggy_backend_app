import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swiggybackend/modals/branch.dart';
import 'package:swiggybackend/modals/dish.dart';
import 'package:swiggybackend/modals/hotel.dart';
import 'package:swiggybackend/services/admin_data_service.dart';

class HotelDataService {

  CollectionReference hotelCollections = Firestore.instance.collection('hotel');
  String hotel_id;
  String branch_id;

  HotelDataService({this.hotel_id}); // for getting stream of branches
  HotelDataService.withBranch({this.hotel_id, this.branch_id}); // for getting stream of dishes


  // gets all the stream of hotels
  Stream<List<Hotel>> get hotels {
    return hotelCollections.snapshots().map(_hotelListFromSnapshot);
  }

  // converts data snapshots into list of hotel objects
  List<Hotel> _hotelListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      print(doc.data);
      return Hotel(
        hotel_id: doc.documentID ?? 'EMPTY',
        hotel_name: doc.data['hotel_name'] ?? 'EMPTY',
      );
    }).toList();
  }

  // gets all the stream of branches
  Stream<List<Branch>> get branches {
    return hotelCollections.document(hotel_id).collection('branch').snapshots().map(_branchListFromSnapshot);
  }

  // converts data snapshots into list of branch objects
  List<Branch> _branchListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      print(doc.data);
      return Branch(
        branch_id: doc.documentID ?? 'EMPTY',
        branch_name: doc.data['branch_name'] ?? 'EMPTY',
      );
    }).toList();
  }

  // gets all the stream of dishes
  Stream<List<Dish>> get dishes {
    return hotelCollections.document(hotel_id).collection('branch').document(branch_id).collection('dishes').snapshots().map(_dishListFromSnapshot);
  }


  // converts data snapshots into list of dish objects
  List<Dish> _dishListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      return Dish(
        dish_id: doc.documentID ?? 'EMPTY',
        dish_name: doc.data['dish_name'] ?? 'EMPTY',
        price: doc.data['price'] ?? 'EMPTY',
        meals: doc.data['meals'] ?? 'EMPTY',
      );
    }).toList();
  }

  // for getting single hotel object
  Future<dynamic> getHotel(String hotelID) async{
    try{
      Hotel hotel;
      await hotelCollections.document(hotelID).snapshots().first.then(
              (value) {
            print(value.data);
            return hotel = Hotel(hotel_name: value.data['hotel_name'], hotel_id: value.documentID);
          }
      );
      return hotel;
    }catch (e){
      return e;
    }
  }

  // for getting single branch object
  Future<dynamic> getBranch(String hotelID, String branchID) async{
    try{
      Branch branch;
      await hotelCollections.document(hotelID).collection('branch').document(branchID).snapshots().first.then(
              (value) {
                print(value.data);
                return branch = Branch(branch_name: value.data['branch_name'], branch_id: value.documentID);
          }
      );
      return branch;
    }catch (e){
      return e;
    }
  }

  // for adding new hotel
  Future<String> addHotel(String hotelName) async {
    try{
      await hotelCollections.add({
        'hotel_name': hotelName,
      });
      return null;
    }
    catch(e){
      print('error occurred while adding');
      print(e);
    }
  }

  // for adding new branch
  Future<String> addBranch(String hotelID, String branchName) async{
    try{
      await hotelCollections.document(hotelID).collection('branch').add({
        'branch_name' : branchName
      });
      return null;
    }
    catch(e){
      print(e);
      return 'Error occurred';
    }
  }

  // for adding new dish
  Future<String> addDish(String hotelID, String branchID, String dishName, String price, String meals) async{
    try{
      await hotelCollections.document(hotelID)
        .collection('branch')
        .document(branchID)
        .collection('dishes')
        .add({
          'dish_name' : dishName,
          'price' : price,
          'meals' : meals
        });
      return null;
    }
    catch(e){
      print(e);
      return 'Error occurred';
    }
  }

  // for updating hotel name
  Future<String> updateHotelName(String hotel_id, String hotel_name) async{
    try{
      await hotelCollections.document(hotel_id).updateData({
        'hotel_name' : hotel_name
      });
      return null;
    }
    catch(e){
      print(e);
      return 'Error occured while updating';
    }
  }

  // for updating branch name
  Future<String> updateBranchName(String hotel_id, String branch_id, String branchName) async{
    try{
      await hotelCollections.document(hotel_id).collection('branch').document(branch_id).updateData({
        'branch_name' : branchName
      });
      return null;
    }
    catch(e){
      print(e);
      return 'Error occured while updating';
    }
  }

  // for updating dish data
  Future<String> updateDish(String hotelID, String branchID, String dishID, String dishName, String price, String meals) async{
    try{
      await hotelCollections.document(hotelID)
          .collection('branch')
          .document(branchID)
          .collection('dishes')
          .document(dishID).updateData({
        'dish_name' : dishName,
        'price' : price,
        'meals' : meals
      });
      return null;
    }
    catch(e){
      print(e);
      return 'Error occurred';
    }
  }

  // for deleting hotel and all the data related to that hotel
  Future deleteHotel(String hotel_id) async{
    await hotelCollections.document(hotel_id).collection('branch').getDocuments().then((value) {
      for (DocumentSnapshot ds in value.documents){
        hotelCollections.document(hotel_id).collection('branch').document(ds.documentID).collection('dishes').getDocuments().then((value) {
          for (DocumentSnapshot ds1 in value.documents){
            ds1.reference.delete();
          }
        });
        ds.reference.delete();
      }
    });
    await hotelCollections.document(hotel_id).delete();
    await AdminDataService().deactivateAdmins(hotel_id);
  }

  // for deleting branch and all the data related to branch
  Future deleteBranch(String hotel_id, String branch_id) async{
    print(hotel_id);
    print(branch_id);
    hotelCollections.document(hotel_id).collection('branch').document(branch_id).collection('dishes').getDocuments().then((value) {
      for (DocumentSnapshot ds1 in value.documents){
        ds1.reference.delete();
      }
    });
    await hotelCollections.document(hotel_id).collection('branch').document(branch_id).delete();
    await AdminDataService().deactivateBranchAdmins(hotel_id, branch_id);
  }

  // for deleting dish
  Future deleteDish(String hotel_id, String branch_id, String dish_id) async{
    await hotelCollections.document(hotel_id).collection('branch').document(branch_id).collection('dishes').document(dish_id).delete();
  }

}