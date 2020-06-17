import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:swiggybackend/modals/branch.dart';
import 'package:swiggybackend/modals/hotel.dart';
import 'package:swiggybackend/screens/dishes_screen.dart';
import 'package:swiggybackend/screens/hotal_admin_list.dart';
import 'package:swiggybackend/services/admin_data_service.dart';
import 'package:swiggybackend/services/hotal_data_service.dart';

class HotelScreen extends StatefulWidget {

  Hotel hotel;
  HotelScreen({this.hotel});

  @override
  _HotelScreenState createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> {

  TextEditingController _textFieldController = TextEditingController();

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hotel.hotel_name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.supervised_user_circle),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => HotalAdminsList(hotel: widget.hotel,)));
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _displayDialog(context);
        },
      ),
      body: StreamBuilder(
        stream: HotelDataService(hotel_id: widget.hotel.hotel_id).branches,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List<Branch> branchList = snapshot.data;
            return ListView.builder(
              itemCount: branchList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(branchList[index].branch_name),
                  subtitle: Text(branchList[index].branch_id),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onLongPress: () {
                    _textFieldController.text = '';
                    _displayUpdateDialog(context, widget.hotel.hotel_id, branchList[index].branch_id, branchList[index].branch_name);
                  },
                  leading: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: (){
                      _displayDeleteDialog(context, widget.hotel.hotel_id, branchList[index].branch_id, branchList[index].branch_name);
                    },
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DishesScreen(hotel: widget.hotel, branch: branchList[index], canAddDish: true,)));
                  },
                );
              },
            );
          }
          else if(snapshot.hasError){
            return Text('Error occurred');
          }
          else{
            return Text('Loading..');
          }
        },
      ),

    );
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add new branch'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Enter branch name"),
            ),
            actions: <Widget>[
              FlatButton(
                child: new Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: new Text('Add'),
                onPressed: () async{
                  if(_textFieldController.text != ''){
                    String res = await HotelDataService().addBranch(widget.hotel.hotel_id, _textFieldController.text);
                    if(res != null){
                      Fluttertoast.showToast(
                          msg: res,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                    else{
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ],
          );
        });
  }

  _displayUpdateDialog(BuildContext context, String hotel_id, String branch_id, String branch_name) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Update hotel name'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: branch_name),
            ),
            actions: <Widget>[
              FlatButton(
                child: new Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: new Text('Update'),
                onPressed: () async{
                  if(_textFieldController.text != ''){
                    String res = await HotelDataService().updateBranchName(hotel_id, branch_id, _textFieldController.text);
                    if(res != null){
                      Fluttertoast.showToast(
                          msg: res,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                    else{
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ],
          );
        });
  }

  _displayDeleteDialog(BuildContext context, String hotel_id, String branch_id, String branch_name) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete hotel'),
            content: Text('All the admins and the $branch_name data will be deleted '),
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
                  await HotelDataService().deleteBranch(hotel_id, branch_id);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

}
