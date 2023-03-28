import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mini_quiz_creator/main.dart';
import 'package:mini_quiz_creator/models/question.dart';
import 'package:http/http.dart' as http;

class CreatorState extends ChangeNotifier {
  List<String> questionIds = [];
  Map<String, Question> questions = {};
  Map<int, Map<String, dynamic>> quizAnswers = {};
  Map<String, dynamic> answers = {};
  bool submissionLoading = false;
  int selectedQuizIndex = 0;
  int selectedSubmissionIndex = 0;
  Map<String, dynamic>? currentQuizAnswers;

  List<String> get dbQuestionIds {
    return questionIds.map((id) => id.substring(5)).toList();
  }

  Future<Question> loadQuestion(String questionId) async {
    if (questions[questionId] != null) {
      return Future.value(questions[questionId]);
    }
    return http
        .get(Uri.parse(
            'https://nguyenhongphat0.github.io/gmat-database/$questionId.json'))
        .then((value) {
      final question = Question.fromJson(jsonDecode(value.body));
      questions[questionId] = question;
      return question;
    });
  }

  Future<Map<String, dynamic>> loadQuizAnswers(int quizId) async {
    if (quizAnswers[quizId] != null) {
      return Future.value(quizAnswers[quizId]);
    }
    final result = await supabase
        .from('gmat_quiz_answers')
        .select('answers')
        .eq('quiz_id', quizId)
        .single();
    if (result != null) {
      final answers = jsonDecode(result['answers']);
      quizAnswers[quizId] = answers;
      return answers;
    }
    return {};
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

  Future<void> replaceQuestionList(List<String> questionIds, int quizId) async {
    this.submissionLoading = true;
    notifyListeners();
    this.currentQuizAnswers = await loadQuizAnswers(quizId);
    final res = await Future.wait(questionIds.map((id) => loadQuestion(id)));
    this.questionIds =
        res.map((question) => "[${question.type}] ${question.id}").toList();
    this.submissionLoading = false;
    notifyListeners();
  }

  void giveAnswer(String questionId, dynamic answer) {
    this.answers[questionId] = answer;
    notifyListeners();
  }

  Future<void> replaceAnswerList(String answers) async {
    this.answers = jsonDecode(answers);
    notifyListeners();
  }
}
