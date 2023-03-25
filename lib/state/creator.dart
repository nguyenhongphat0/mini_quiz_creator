import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mini_quiz_creator/models/question.dart';
import 'package:http/http.dart' as http;

class CreatorState extends ChangeNotifier {
  /// Internal, private state of the cart.
  List<String> questionIds = [];
  Map<String, Question> questions = {};
  Map<String, dynamic> answers = {};

  Future<Question> loadQuestion(String questionId) async {
    return http
        .get(Uri.parse(
            'https://nguyenhongphat0.github.io/gmat-database/$questionId.json'))
        .then((value) {
      final question = Question.fromJson(jsonDecode(value.body));
      questions[questionId] = question;
      return question;
    });
  }

  void addQuestion(String questionId) {
    questionIds.add(questionId);
    notifyListeners();
  }

  void insertQuestion(int index, String questionId) {
    questionIds.insert(index, questionId);
    notifyListeners();
  }

  String removeQuestionAt(int index) {
    final questionid = questionIds.removeAt(index);
    notifyListeners();
    return questionid;
  }

  void giveAnswer(String questionId, dynamic answer) {
    this.answers[questionId] = answer;
    notifyListeners();
  }
}
