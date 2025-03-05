import 'package:flutter/material.dart';
import 'package:menuapp/themes/dark_mode.dart';
import 'package:menuapp/themes/light_mode.dart';
class ThemeProvider with ChangeNotifier{
  ThemeData _themeData = lightMode;

  ThemeData get themeData =>  _themeData;

  bool get isDarkMode => _themeData == darkMode;
  set themeData(ThemeData _themeData){
    _themeData=themeData;
    notifyListeners();

  }
  void toggle(){
if(_themeData == lightMode){
  _themeData = darkMode;

}else{
  _themeData = lightMode;
}
  }




}