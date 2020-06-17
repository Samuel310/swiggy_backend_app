import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiggybackend/modals/admin_type.dart';
import 'package:swiggybackend/screens/ba_home.dart';
import 'package:swiggybackend/screens/ha_home.dart';
import 'package:swiggybackend/screens/sa_home.dart';
import 'package:swiggybackend/services/admin_data_service.dart';
import 'package:swiggybackend/services/auth_service.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    
    return FutureBuilder(
      future: AdminDataService().getData(user.uid),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          AdminType adminType = snapshot.data;
          if(adminType.acc_type == 'super_admin'){
            return SuperAdminHomePage(adminType: adminType,);
          }
          else if(adminType.admin_status == 'active'){
            if(adminType.acc_type == 'hotel_admin'){
              return HotalAdminPage(adminType: adminType);
            }
            else if(adminType.acc_type == 'branch_admin'){
              return BranchAdminPage(adminType: adminType);
            }
            else{
              return Scaffold(
                body: SafeArea(child: Text('Loading')),
              );
            }
          }
          else{
            AuthService().deteteAccount();
            return Scaffold(
              body: SafeArea(child: Text('Deactivating account')),
            );
          }
        }
        else if(snapshot.hasError){
          return Scaffold(
            body: SafeArea(child: Text('Error occurred')),
          );
        }
        else{
          return Scaffold(
            body: SafeArea(child: Text('Loading')),
          );
        }
      },
    );
  }
}
