// CERTIFICAÇÃO DE REGISTRO DAS AUTOCLAVES IMPEDE O FUNCIONAMENTO SE NAO ESTIVER CADASTRADO 

import '../models/user_model.dart';

class AutoclaveAuthService {

  static bool isAutoclaveAuthorized(
    UserModel user,
    String serial,
  ){

    for(final a in user.autoclaves){

      if(a.serial == serial){
        return true;
      }

    }

    return false;

  }

}