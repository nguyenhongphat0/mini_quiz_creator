import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_quiz_creator/main.dart';
import 'package:mini_quiz_creator/state/creator.dart';
import 'package:mini_quiz_creator/state/database.dart';
import 'package:mini_quiz_creator/widgets/question_detail.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CreatorScreen extends StatelessWidget {
  final _nameController = TextEditingController(text: "ZStudio GMAT Test 1");
  final _durationController = TextEditingController(text: "30");
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          Row(
            children: [
              SizedBox(
                width: 320,
                child: Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true),
                              style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.fontSize),
                            ),
                            TextField(
                              controller: _durationController,
                              decoration: InputDecoration(
                                labelText: 'Duration (minutes)',
                                hintText: '30',
                              ),
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                              ],
                              keyboardType: TextInputType.number,
                            ),
                            Consumer<DatabaseState>(
                              builder: (context, database, child) =>
                                  Consumer<CreatorState>(
                                builder: (context, creator, child) =>
                                    Autocomplete(
                                  onSelected: (option) {
                                    if (creator.questionIds.contains(option)) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              showCloseIcon: true,
                                              content: Text(
                                                  "Question already in the quiz!")));
                                    } else {
                                      creator.addQuestion(option);
                                    }
                                  },
                                  optionsViewBuilder: (BuildContext context,
                                      AutocompleteOnSelected<String> onSelected,
                                      Iterable<String> options) {
                                    return Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              maxHeight: 400, maxWidth: 280),
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            itemCount: options.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final String option =
                                                  options.elementAt(index);
                                              return InkWell(
                                                onTap: () {
                                                  onSelected(option);
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Text(option),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  fieldViewBuilder: (BuildContext context,
                                      TextEditingController
                                          textEditingController,
                                      FocusNode focusNode,
                                      VoidCallback onFieldSubmitted) {
                                    return TextField(
                                      controller: textEditingController,
                                      focusNode: focusNode,
                                      onSubmitted: (value) {
                                        onFieldSubmitted();
                                        textEditingController.clear();
                                        FocusScope.of(context)
                                            .requestFocus(focusNode);
                                      },
                                      decoration: InputDecoration(
                                        label: Text("Add question to the quiz"),
                                        hintText: "Question ID",
                                        suffixIcon: Tooltip(
                                          message: "View Question Bank",
                                          child: IconButton(
                                            icon: Icon(Icons.launch),
                                            onPressed: () {
                                              launchUrlString(
                                                  "https://nguyenhongphat0.github.io/gmat_question_bank/");
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  optionsBuilder:
                                      (TextEditingValue textEditingValue) {
                                    return database.allQuestionIds.where(
                                        (questionId) => questionId
                                            .toLowerCase()
                                            .contains(textEditingValue.text
                                                .trim()
                                                .toLowerCase()));
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: SortableList()),
                    ],
                  ),
                ),
              ),
              Expanded(child: QuizPreview())
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                child:
                    Consumer<CreatorState>(builder: (context, creator, child) {
                  return FloatingActionButton.extended(
                    onPressed: () async {
                      _alert(String message) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            showCloseIcon: true, content: Text(message)));
                      }

                      try {
                        if (_nameController.text.isEmpty) {
                          throw 'Give your quiz a name!';
                        }
                        if (creator.questionIds.length == 0) {
                          throw 'Your quiz is empty, put in some questions!';
                        }
                        final questionIds =
                            creator.questionIds.map((id) => id.substring(5));
                        final answers = creator.answers;
                        for (var questionId in questionIds) {
                          if (answers[questionId] == null ||
                              ((answers[questionId] is List) &&
                                  (jsonDecode(questionId) as List)
                                      .contains(-1))) {
                            throw 'Please provide the answers for each question!';
                          }
                        }
                        final response = await supabase
                            .from('gmat_quizzes')
                            .insert({
                              'name': _nameController.text,
                              'duration': _durationController.text,
                              'author': supabase.auth.currentUser?.email,
                              'question_ids': json.encode(questionIds.toList()),
                              "answers": json.encode(answers)
                            })
                            .select()
                            .single();
                        final id = response['id'];
                        _alert("Quiz ID: $id");

                        if (id == null) {
                          throw 'Unkown error!';
                        }
                      } on PostgrestException catch (e) {
                        _alert(e.details.toString());
                      } catch (e) {
                        _alert(e.toString());
                      }
                    },
                    label: Text("Build Quiz"),
                    icon: Icon(Icons.done_all),
                  );
                }),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class QuizPreview extends StatelessWidget {
  QuizPreview({
    super.key,
  });

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<CreatorState>(
      builder: (context, creator, child) => SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            ...creator.questionIds.map(
              (questionId) {
                final id = questionId.substring(5);
                return Container(
                  key: ValueKey(questionId),
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: CircleAvatar(
                          child: Text(
                              "${creator.questionIds.indexOf(questionId) + 1}"),
                        ),
                      ),
                      Expanded(
                        child: creator.questions.containsKey(id)
                            ? QuestionDetail(
                                question: creator.questions[id]!,
                              )
                            : FutureBuilder(
                                future: creator.loadQuestion(id),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  } else {
                                    final question = snapshot.data!;
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((timeStamp) {
                                      scrollController.animateTo(
                                        scrollController
                                            .position.maxScrollExtent,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeOut,
                                      );
                                    });
                                    return QuestionDetail(
                                      question: question,
                                    );
                                  }
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class SortableList extends StatefulWidget {
  @override
  _SortableListState createState() => _SortableListState();
}

class _SortableListState extends State<SortableList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CreatorState>(
      builder: (context, creator, child) => ReorderableListView(
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final String item = creator.questionIds.removeAt(oldIndex);
            creator.insertQuestion(newIndex, item);
          });
        },
        children: creator.questionIds
            .asMap()
            .map((index, item) => MapEntry(
                  index,
                  ListTile(
                    key: ValueKey(item),
                    title: Text("$item"),
                    leading: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        creator.removeQuestionAt(index);
                      },
                    ),
                    onTap: () {
                      print('Tapped on item $index');
                    },
                    onLongPress: () {
                      print('Long pressed item $index');
                    },
                    enabled: true,
                    selected: false,
                    dense: false,
                  ),
                ))
            .values
            .toList(),
      ),
    );
  }
}
