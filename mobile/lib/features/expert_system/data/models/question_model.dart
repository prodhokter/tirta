import 'package:tirta/features/expert_system/domain/entities/question.dart';

class QuestionModel {
  static const List<Question> questions = [
    Question(
      id: 1,
      text: 'Apakah kamu mengalami batuk terus-menerus lebih dari 2 minggu (berdahak atau kering)?',
      category: 'pernapasan',
    ),
    Question(
      id: 2,
      text: 'Apakah dahak yang kamu keluarkan terkadang disertai darah?',
      category: 'pernapasan',
    ),
    Question(
      id: 3,
      text: 'Apakah kamu sering merasa sesak napas?',
      category: 'pernapasan',
    ),
    Question(
      id: 4,
      text: 'Apakah kamu merasakan nyeri di dada?',
      category: 'pernapasan',
    ),
    Question(
      id: 5,
      text: 'Apakah kamu mengalami demam ringan (meriang) yang berlangsung lebih dari sebulan?',
      category: 'sistemik',
    ),
    Question(
      id: 6,
      text: 'Apakah kamu berkeringat di malam hari meskipun tidak beraktivitas?',
      category: 'sistemik',
    ),
    Question(
      id: 7,
      text: 'Apakah nafsu makan kamu menurun drastis?',
      category: 'sistemik',
    ),
    Question(
      id: 8,
      text: 'Apakah berat badanmu turun tanpa sebab yang jelas?',
      category: 'sistemik',
    ),
    Question(
      id: 9,
      text: 'Apakah kamu sering merasa lemah dan mudah lelah?',
      category: 'sistemik',
    ),
    Question(
      id: 10,
      text: 'Apakah ada anggota keluarga / orang serumah yang menderita atau pernah menderita TBC?',
      category: 'risiko',
    ),
    Question(
      id: 11,
      text: 'Apakah kamu tinggal di lingkungan yang padat penduduk atau kurang ventilasi?',
      category: 'risiko',
    ),
    Question(
      id: 12,
      text: 'Apakah kamu merokok aktif atau pernah merokok?',
      category: 'risiko',
    ),
    Question(
      id: 13,
      text: 'Apakah kamu memiliki riwayat HIV/AIDS atau kondisi imun yang lemah?',
      category: 'risiko',
    ),
    Question(
      id: 14,
      text: 'Apakah kamu pernah didiagnosis atau diobati TBC sebelumnya?',
      category: 'riwayat',
    ),
    Question(
      id: 15,
      text: 'Apakah gejala batuk kamu tidak membaik meskipun sudah minum obat batuk biasa?',
      category: 'riwayat',
    ),
  ];

  static List<MapEntry<String, String>> getCategories() {
    return const [
      MapEntry('pernapasan', 'Gejala Pernapasan'),
      MapEntry('sistemik', 'Gejala Sistemik'),
      MapEntry('risiko', 'Faktor Risiko'),
      MapEntry('riwayat', 'Riwayat'),
    ];
  }
}
