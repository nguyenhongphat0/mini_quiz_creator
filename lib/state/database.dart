import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mini_quiz_creator/constants.dart';
import 'package:mini_quiz_creator/models/database.dart';
import 'package:http/http.dart' as http;

class DatabaseState extends ChangeNotifier {
  /// Internal, private state of the cart.
  Database? database;
  int selectedQuestionIndex = 0;
  String? questionContent;
  String? questionSrc;

  DatabaseState() {
    _init();
  }

  Future _init() async {
    final value = await http.get(Uri.parse('$GMAT_DATABASE_URL/index.json'));
    final database = Database.fromJson(jsonDecode(value.body));
    this.database = database;
    print(database);
    notifyListeners();
  }

  void selectQuestion(int index) {
    this.selectedQuestionIndex = index;
    notifyListeners();
  }

  List<String> get allQuestionIds {
    List<String> ids = [];
    ids.addAll(this.database?.cr.map((id) => "[CR] $id") ?? []);
    ids.addAll(this.database?.ds.map((id) => "[DS] $id") ?? []);
    ids.addAll(this.database?.ps.map((id) => "[PS] $id") ?? []);
    ids.addAll(this.database?.rc.map((id) => "[RC] $id") ?? []);
    ids.addAll(this.database?.sc.map((id) => "[SC] $id") ?? []);
    return ids;
  }
}
