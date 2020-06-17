import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:swiggybackend/modals/admin_type.dart';
import 'package:swiggybackend/modals/hotel.dart';
import 'package:swiggybackend/screens/hotel_screen.dart';
import 'package:swiggybackend/services/auth_service.dart';
import 'package:swiggybackend/services/hotal_data_service.dart';

class SuperAdminHomePage extends StatefulWidget {

  AdminType adminType;
  SuperAdminHomePage({this.adminType});

  @override
  _SuperAdminHomePageState createState() => _SuperAdminHomePageState();
}

class _SuperAdminHomePageState extends State<SuperAdminHomePage> {

  TextEditingController _textFieldController = TextEditingController();
  HotelDataService _hotelDataService = HotelDataService();

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Super Admin Portal'),
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
        stream: _hotelDataService.hotels,
        builder: (context, snapshot) {
          if(snapshot.hasError){
            return Text('Error occurred');
          }
          else if(snapshot.hasData){
            List<Hotel> hotelList = snapshot.data;
            return ListView.builder(
              itemCount: hotelList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(hotelList[index].hotel_name),
                  subtitle: Text(hotelList[index].hotel_id),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onLongPress: () {
                    _textFieldController.text = '';
                    _displayUpdateDialog(context, hotelList[index].hotel_name, hotelList[index].hotel_id);
                  },
                  leading: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: (){
                      _displayDeleteDialog(context, hotelList[index].hotel_name, hotelList[index].hotel_id);
                    },
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HotelScreen(hotel: hotelList[index],)));
                  },
                );
              },
            );
          }
          else{
            return Text('Loading...');
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
            title: Text('Add new hotel'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Enter name"),
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
                    String res = await _hotelDataService.addHotel(_textFieldController.text);
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

  _displayUpdateDialog(BuildContext context, String hotel_name, String hotel_id) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Update hotel name'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: hotel_name),
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
                    String res = await _hotelDataService.updateHotelName(hotel_id, _textFieldController.text);
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

  _displayDeleteDialog(BuildContext context, String hotel_name, String hotel_id) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete hotel'),
            content: Text('All the admins and the $hotel_name data will be deleted '),
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
                  await HotelDataService().deleteHotel(hotel_id);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }


}
