import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:swiggybackend/modals/admin_type.dart';
import 'package:swiggybackend/modals/branch.dart';
import 'package:swiggybackend/modals/hotel.dart';
import 'package:swiggybackend/services/admin_data_service.dart';
import 'package:swiggybackend/services/admin_registeration.dart';

class BranchAdminList extends StatefulWidget {
  
  Hotel hotel;
  Branch branch;
  BranchAdminList({this.hotel, this.branch});

  @override
  _BranchAdminListState createState() => _BranchAdminListState();
}

class _BranchAdminListState extends State<BranchAdminList> {

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
        title: Text('Branch Admins'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _displayDialog(context);
        },
      ),
      body: StreamBuilder(
        stream: AdminDataService.withBranch(hotel_id: widget.hotel.hotel_id, branch_id: widget.branch.branch_id).branches,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List<AdminType> admins = snapshot.data;
            return ListView.builder(
              itemCount: admins.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(admins[index].email),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _displayDeleteDialog(context, admins[index].uid);
                    },
                  ),
                );
              },
            );
          }
          else if(snapshot.hasError){
            return Text('error occurred');
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
            title: Text('Add new branch admin'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Enter email"),
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
                    String res = await AdminRegisteration().addAdmin(_textFieldController.text, widget.hotel.hotel_id, widget.branch.branch_id, 'branch_admin');
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

  _displayDeleteDialog(BuildContext context, String uid) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete branch admin'),
            content: Text('This admin will be removed and the account will be deleted'),
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
                  await AdminDataService().deactivateSingleAdmin(uid);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

}
