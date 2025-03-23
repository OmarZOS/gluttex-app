import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gluttex_play/components/QuizAnswerIndexes.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';

class GlutenFreeQuiz extends StatefulWidget {
  @override
  _GlutenFreeQuizState createState() => _GlutenFreeQuizState();
}

class _GlutenFreeQuizState extends State<GlutenFreeQuiz> {
  List<int> _selectedQuestions = [];
  int _currentQuestionIndex = 0;

  int _score = 0;
  int selectedAnswerId = 0;
  bool _isAnswerSelected = false; // 跟踪是否选择了答案

  @override
  void initState() {
    super.initState();
    _generateQuiz();
  }

  void _generateQuiz() {
    final random = Random();
    _selectedQuestions =
        List.generate(20, (_) => random.nextInt(quiz_answer_indexes.length));
  }

  void _answerQuestion(int tappedAnswerId) {
    setState(() {
      selectedAnswerId = selectedAnswerId;

      _isAnswerSelected = true;
    });

    Future.delayed(Duration(milliseconds: 500), () {
      if (selectedAnswerId ==
          quiz_answer_indexes[_selectedQuestions[_currentQuestionIndex]]) {
        _score++;
      }
      if (_currentQuestionIndex < 19) {
        setState(() {
          _currentQuestionIndex++;
          _isAnswerSelected = false;
        });
      } else {
        _showResults();
      }
    });
  }

  void _showResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Quiz Completed!",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Your score: $_score / 20",
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
                _generateQuiz();
              });
            },
            child: Text(
              "Play Again",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gluten-Free Quiz",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 进度条
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / 20,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 20),
              // 问题编号
              Text(
                "Question ${_currentQuestionIndex + 1}/20",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              // 问题文本
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    AppLocalizations.of(context)!.getLocalizedQuestion(
                        _selectedQuestions[_currentQuestionIndex]),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // 选项按钮
              ...AppLocalizations.of(context)!
                  .getLocalizedAnswerList(
                      _selectedQuestions[_currentQuestionIndex])
                  .split(",")
                  .asMap()
                  .entries
                  .map((entry) {
                int index = entry.key;
                String option = entry.value;
                bool isCorrect = index ==
                    quiz_answer_indexes[
                        _selectedQuestions[_currentQuestionIndex]];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: ElevatedButton(
                    onPressed: _isAnswerSelected
                        ? null
                        : () {
                            if (!_isAnswerSelected) {
                              _answerQuestion(index);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAnswerSelected
                          ? (isCorrect
                              ? Colors.green
                              : (selectedAnswerId == index
                                  ? Colors.red
                                  : Colors.white))
                          : Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        color: _isAnswerSelected ? Colors.white : Colors.blue,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: GlutenFreeQuiz(),
  ));
}
