class FaqQuestion {
  FaqQuestion({this.answer, this.question});

  String? question;
  String? answer;

  factory FaqQuestion.fromJson(Map<String, dynamic> json) =>
      FaqQuestion(question: json["question"], answer: json["answer"]);
}
