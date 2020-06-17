import 'package:flutter/material.dart';
import 'package:swiggybackend/modals/admin_type.dart';
import 'package:swiggybackend/modals/branch.dart';
import 'package:swiggybackend/modals/dish.dart';
import 'package:swiggybackend/screens/add_dish.dart';
import 'package:swiggybackend/services/auth_service.dart';
import 'package:swiggybackend/services/hotal_data_service.dart';

class BranchAdminPage extends StatefulWidget {

  AdminType adminType;
  BranchAdminPage({this.adminType});

  @override
  _BranchAdminPageState createState() => _BranchAdminPageState();
}

class _BranchAdminPageState extends State<BranchAdminPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: HotelDataService().getBranch(widget.adminType.hotel_id, widget.adminType.branch_id),
      builder: (context, snapshot) {
        if(snapshot.hasError){
          return Text('Error occurred');
        }
        else if(snapshot.hasData){
          Branch branch = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: Text('Branch Admin Portal'),
              bottom: PreferredSize(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(branch.branch_name, style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),),
                ),
                preferredSize: Size.fromHeight(30.0),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () async{
                    await AuthService().signOut();
                  },
                  child: Text('Logout'),
                )
              ],
            ),
            body: StreamBuilder(
              stream: HotelDataService.withBranch(hotel_id: widget.adminType.hotel_id, branch_id: widget.adminType.branch_id).dishes,
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  List<Dish> dishList = snapshot.data;
                  return ListView.builder(
                    itemCount: dishList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onLongPress: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context){
                              return Container(
                                child: AddNewDish(hotel_id: widget.adminType.hotel_id, branch_id: widget.adminType.branch_id, dish: dishList[index]),
                              );
                            },
                          );
                        },
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(dishList[index].dish_name),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: (){
                                        _displayDeleteDialog(context, dishList[index].dish_name, widget.adminType.hotel_id, widget.adminType.branch_id, dishList[index].dish_id);
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text('Rs. ${dishList[index].price}', style: TextStyle(color: Colors.grey)),
                                    Text(dishList[index].meals, style: TextStyle(color: Colors.grey))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                else if(snapshot.hasError){
                  return Text('Error occured');
                }
                else{
                  return Text('Loading..');
                }
              },
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context){
                    return Container(
                      child: AddNewDish(hotel_id: widget.adminType.hotel_id, branch_id: widget.adminType.branch_id,),
                    );
                  },
                );
              },
            ),
          );
        }
        else{
          return Text('Loading');
        }
      },
    );
  }


  _displayDeleteDialog(BuildContext context, String dish_name, String hotel_id, String branch_id, String dish_id) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete dish'),
            content: Text('$dish_name dish will be deleted'),
            actions: <Widget>[
              FlatButton(
                child: new Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: new Text('Delete'),
                onPressed: () async{
                  await HotelDataService().deleteDish(hotel_id, branch_id, dish_id);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }


}
