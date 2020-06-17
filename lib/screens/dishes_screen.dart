import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:swiggybackend/modals/branch.dart';
import 'package:swiggybackend/modals/dish.dart';
import 'package:swiggybackend/modals/hotel.dart';
import 'package:swiggybackend/screens/add_dish.dart';
import 'package:swiggybackend/screens/branch_admin_list.dart';
import 'package:swiggybackend/services/admin_data_service.dart';
import 'package:swiggybackend/services/hotal_data_service.dart';

class DishesScreen extends StatefulWidget {

  Hotel hotel;
  Branch branch;
  bool canAddDish;

  DishesScreen({this.hotel, this.branch, this.canAddDish});

  @override
  _DishesScreenState createState() => _DishesScreenState();
}

class _DishesScreenState extends State<DishesScreen> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hotel.hotel_name),
        bottom: PreferredSize(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text('${widget.branch.branch_name} branch', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),),
          ),
          preferredSize: Size.fromHeight(30.0),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.supervised_user_circle),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => BranchAdminList(hotel: widget.hotel, branch: widget.branch,)));
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: HotelDataService.withBranch(hotel_id: widget.hotel.hotel_id, branch_id: widget.branch.branch_id).dishes,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List<Dish> dishList = snapshot.data;
            return ListView.builder(
              itemCount: dishList.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onLongPress: () {
                    if(widget.canAddDish) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context){
                          return Container(
                            child: AddNewDish(hotel_id: widget.hotel.hotel_id, branch_id: widget.branch.branch_id, dish: dishList[index]),
                          );
                        },
                      );
                    }
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
                              Visibility(
                                visible: widget.canAddDish,
                                child: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: (){
                                    _displayDeleteDialog(context, dishList[index].dish_name, widget.hotel.hotel_id, widget.branch.branch_id, dishList[index].dish_id);
                                  },
                                ),
                              )
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
      floatingActionButton: Visibility(
        visible: widget.canAddDish,
        child: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: (){
            showModalBottomSheet(
              context: context,
              builder: (context){
                return Container(
                  child: AddNewDish(hotel_id: widget.hotel.hotel_id, branch_id: widget.branch.branch_id, dish: null),
                );
              },
            );
          },
        ),
      )
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

