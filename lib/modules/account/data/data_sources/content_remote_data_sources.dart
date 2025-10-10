import 'package:NutriCam/modules/account/data/models/create_account_model.dart';
import 'package:NutriCam/modules/account/data/models/create_objetive_user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';


abstract class AccountRepository {
 // final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createAccountUserImpl(CreateAccountUserModel user);
  Future<bool> loginUserImpl(String email, String password);
  Future<void> logout();
  Future<void> createObjectiveUserImpl(ObjetiveUserModel model);


}
