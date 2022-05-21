import 'package:flutter/widgets.dart';
import 'package:sleepaid/data/auth_data.dart';

class BluetoothProvider with ChangeNotifier{
  AuthData authData = AuthData();

  setTempToggleLoggedIn(){
    authData.isLoggedIn = !authData.isLoggedIn;
    notifyListeners();
  }
}

