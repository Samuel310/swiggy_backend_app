import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:swiggybackend/modals/dish.dart';
import 'package:swiggybackend/services/hotal_data_service.dart';

class AddNewDish extends StatefulWidget {

  String hotel_id, branch_id;
  Dish dish;
  AddNewDish({this.hotel_id, this.branch_id, this.dish});

  @override
  _AddNewDishState createState() => _AddNewDishState();
}

class _AddNewDishState extends State<AddNewDish> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _dishName, _price;
  String _meals = '';
  String _title = 'Add new dish';

  @override
  void initState() {
    if(widget.dish != null){
      _dishName = widget.dish.dish_name;
      _price = widget.dish.price;
      _meals = widget.dish.meals;
      _title = 'Update dish';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(_title, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
                TextFormField(
                  initialValue: _dishName,
                  validator: (input){
                    if(input.isEmpty){
                      return 'Dish name should not be empty';
                    }
                    return null;
                  },
                  onSaved: (input){
                    _dishName = input;
                  },
                  decoration: inputDecoration('Dish name'),
                ),
                TextFormField(
                  initialValue: _price,
                  keyboardType: TextInputType.number,
                  validator: (input){
                    if(input.isEmpty){
                      return 'Price cannot be empty';
                    }
                    return null;
                  },
                  onSaved: (input){
                    _price = input;
                  },
                  decoration: inputDecoration('Price'),
                ),
                Row(
                  children: <Widget>[
                    Radio(value: 'Breakfast', groupValue: _meals, onChanged: (value) {setValue(value);}),
                    Text('Breakfast')
                  ],
                ),
                Row(
                  children: <Widget>[
                    Radio(value: 'Lunch', groupValue: _meals, onChanged: (value) {setValue(value);}),
                    Text('Lunch')
                  ],
                ),
                Row(
                  children: <Widget>[
                    Radio(value: 'Dinner', groupValue: _meals, onChanged: (value) {setValue(value);}),
                    Text('Dinner')
                  ],
                ),
                RaisedButton(
                  child: Text('Save'),
                  onPressed: (){
                    saveData();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint){
    return InputDecoration(
      hintText: hint,
      contentPadding: new EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
    );
  }

  void setValue(String value){
    setState(() {
      if(value == 'Breakfast'){
        _meals = value;
      }
      else if(value == 'Lunch'){
        _meals = value;
      }
      else if(value == 'Dinner'){
        _meals = value;
      }
    });
  }

  void saveData() async{
    final formState = _formKey.currentState;
    if(formState.validate()){
      if(_meals != ''){
        formState.save();
        String res;
        if(widget.dish != null){
          res = await HotelDataService().updateDish(widget.hotel_id, widget.branch_id, widget.dish.dish_id, _dishName, _price, _meals);
        }
        else{
          res = await HotelDataService().addDish(widget.hotel_id, widget.branch_id, _dishName, _price, _meals);
        }
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
          Navigator.pop(context);
        }
      }
    }
  }

}
