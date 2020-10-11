// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$Controller on ControllerBase, Store {
  final _$valorAtom = Atom(name: 'ControllerBase.valor');

  @override
  int get valor {
    _$valorAtom.reportRead();
    return super.valor;
  }

  @override
  set valor(int value) {
    _$valorAtom.reportWrite(value, super.valor, () {
      super.valor = value;
    });
  }

  final _$ControllerBaseActionController =
      ActionController(name: 'ControllerBase');

  @override
  dynamic dropDow(int novoValor) {
    final _$actionInfo = _$ControllerBaseActionController.startAction(
        name: 'ControllerBase.dropDow');
    try {
      return super.dropDow(novoValor);
    } finally {
      _$ControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
valor: ${valor}
    ''';
  }
}
