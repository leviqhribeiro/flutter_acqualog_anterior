import 'package:canteiro/envs.dart';
import 'package:canteiro/main.dart';

void main(){
  Constants.setEnvironment(Environment.DEV);
  mainDelegate();
}