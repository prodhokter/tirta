class Question {
  final int id;
  final String code;
  final String text;
  final String hint;
  final String category;
  final int weight;

  const Question({
    required this.id,
    required this.code,
    required this.text,
    required this.hint,
    required this.category,
    required this.weight,
  });
}
