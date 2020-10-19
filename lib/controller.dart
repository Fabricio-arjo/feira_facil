import 'package:mobx/mobx.dart';
part "controller.g.dart";

class Controller = ControllerBase with _$Controller;

abstract class ControllerBase with Store {
  @observable
  String mensagemErro = "";

  @action
  validaCampo(String campoEmpty) {
    if (campoEmpty.isEmpty) {
      mensagemErro = "Informe uma descrição.";
    } else {
      mensagemErro = "";
    }
  }

  @action
  resetCampo() {
    mensagemErro = "";
  }
}
