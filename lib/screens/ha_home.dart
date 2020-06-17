import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:swiggybackend/modals/admin_type.dart';
import 'package:swiggybackend/modals/branch.dart';
import 'package:swiggybackend/modals/hotel.dart';
import 'package:swiggybackend/screens/dishes_screen.dart';
import 'package:swiggybackend/services/auth_service.dart';
import 'package:swiggybackend/services/hotal_data_service.dart';

class HotalAdminPage extends StatefulWidget {
  
  AdminType adminType;
  HotalAdminPage({this.adminType});

  @override
  _HotalAdminPageState createState() => _HotalAdminPageState();
}

class _HotalAdminPageState extends State<HotalAdminPage> {

  TextEditingController _textFieldController = TextEditingController();

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: HotelDataService().getHotel(widget.adminType.hotel_id),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          Hotel hotel = snapshot.data;
          return Scaffold(
              appBar: AppBar(
                title: Text('Hotel Admin Portal'),
                bottom: PreferredSize(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(hotel.hotel_name, style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),),
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
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                _displayDialog(context);
              },
            ),
            body: StreamBuilder(
              stream: HotelDataService(hotel_id: hotel.hotel_id).branches,
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
                        leading: IconButton(
                          icon: Icon(Icons.delete), 
                          onPressed: () {
                            _displayDeleteDialog(context, widget.adminType.hotel_id, branchList[index].branch_id, branchList[index].branch_name);
                          },
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DishesScreen(hotel: hotel, branch: branchList[index], canAddDish: false)));
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
        else if(snapshot.hasError){
          return Container(
            child: SafeArea(child: Text('Error occurred')),
          );
        }
        else{
          return Container(
            child: SafeArea(child: Text('Error occurred')),
          );
        }
      },
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
                    String res = await HotelDataService().addBranch(widget.adminType.hotel_id, _textFieldController.text);
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
