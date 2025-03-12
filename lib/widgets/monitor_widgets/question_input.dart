import 'package:flutter/material.dart';

class QuestionInput extends StatefulWidget {
  @override
  _QuestionInputState createState() => _QuestionInputState();
}

class _QuestionInputState extends State<QuestionInput> {
  List<String> questions = [];
  final TextEditingController _questionController = TextEditingController();

  void addQuestion() {
    if (questions.length < 5 && _questionController.text.isNotEmpty) {
      setState(() {
        questions.add(_questionController.text);
        _questionController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: _questionController, decoration: InputDecoration(labelText: "เพิ่มคำถาม")),
        ElevatedButton(onPressed: addQuestion, child: Text("เพิ่ม")),
        Column(
          children: questions.map((q) => ListTile(title: Text(q))).toList(),
        ),
      ],
    );
  }
}
