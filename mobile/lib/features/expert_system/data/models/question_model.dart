import 'package:tirta/features/expert_system/domain/entities/question.dart';

/// Knowledge Base pertanyaan sistem pakar TBC
/// Berdasarkan expert_system_tbc.md — 15 gejala dengan bobot terdiferensiasi
/// Total bobot maksimal: 110
class QuestionModel {
  static const List<Question> questions = [
    // ====== GEJALA UTAMA (G01–G05) ======
    Question(
      id: 1,
      code: 'G01',
      text:
          'Apakah Anda mengalami batuk terus-menerus (baik berdahak maupun kering) yang sudah berlangsung selama 2 minggu atau lebih?',
      hint:
          'Batuk yang dimaksud bisa berdahak atau batuk kering. Bukan batuk sesekali karena iritasi tenggorokan biasa.',
      category: 'utama',
      weight: 10,
    ),
    Question(
      id: 2,
      code: 'G02',
      text:
          'Apakah batuk Anda pernah disertai darah, atau dahak berwarna merah/coklat tua?',
      hint:
          'Bisa berupa bercak darah pada dahak, atau darah segar saat batuk. Jika belum pernah batuk sama sekali, jawab TIDAK.',
      category: 'utama',
      weight: 15,
    ),
    Question(
      id: 3,
      code: 'G03',
      text:
          'Apakah Anda sering merasa demam ringan (suhu tubuh sekitar 37–38°C), terutama pada sore atau malam hari, yang berlangsung lebih dari seminggu?',
      hint:
          'Bukan demam tinggi mendadak seperti flu biasa. Demam subfebril TBC cenderung berlangsung lama dan tidak terlalu tinggi.',
      category: 'utama',
      weight: 10,
    ),
    Question(
      id: 4,
      code: 'G04',
      text:
          'Apakah Anda sering berkeringat banyak di malam hari meskipun ruangan tidak panas, bahkan sampai membasahi pakaian/seprei?',
      hint:
          'Keringat malam yang dimaksud adalah keringat berlebihan yang terjadi saat tidur, bukan karena selimut terlalu tebal.',
      category: 'utama',
      weight: 10,
    ),
    Question(
      id: 5,
      code: 'G05',
      text:
          'Apakah berat badan Anda turun secara signifikan (lebih dari 5% dari berat awal) dalam 1–2 bulan terakhir tanpa sedang diet atau penyakit lain yang diketahui?',
      hint:
          'Contoh: jika berat badan Anda 60 kg, penurunan lebih dari 3 kg dalam sebulan tanpa alasan jelas.',
      category: 'utama',
      weight: 10,
    ),

    // ====== GEJALA PENDUKUNG (G06–G08) ======
    Question(
      id: 6,
      code: 'G06',
      text:
          'Apakah Anda sering merasakan sesak napas atau nyeri/rasa tidak nyaman di dada, terutama saat beraktivitas ringan hingga sedang?',
      hint:
          'Sesak yang dimaksud bukan karena asma yang sudah terdiagnosis atau penyakit jantung sebelumnya.',
      category: 'pendukung',
      weight: 5,
    ),
    Question(
      id: 7,
      code: 'G07',
      text:
          'Apakah Anda merasa lemah, lesu, dan mudah lelah secara berlebihan yang sudah berlangsung lebih dari 2 minggu, bahkan setelah istirahat cukup?',
      hint:
          'Berbeda dengan kelelahan biasa setelah kerja keras. Kelelahan TBC terasa menetap meski sudah tidur dan istirahat.',
      category: 'pendukung',
      weight: 5,
    ),
    Question(
      id: 8,
      code: 'G08',
      text:
          'Apakah nafsu makan Anda berkurang secara signifikan (malas makan, cepat kenyang, atau tidak berselera makan) dalam lebih dari 1 minggu terakhir?',
      hint:
          'Bukan karena sedang stres sesaat, tapi penurunan nafsu makan yang berlangsung terus-menerus.',
      category: 'pendukung',
      weight: 5,
    ),

    // ====== FAKTOR RISIKO (G09–G13) ======
    Question(
      id: 9,
      code: 'G09',
      text:
          'Apakah Anda pernah tinggal serumah, bekerja berdekatan, atau melakukan kontak rutin (hampir setiap hari) dengan seseorang yang sudah terdiagnosis TBC dalam 1 tahun terakhir?',
      hint:
          'Kontak sesekali tidak termasuk. Yang dihitung adalah kontak intens dan berulang.',
      category: 'risiko',
      weight: 10,
    ),
    Question(
      id: 10,
      code: 'G10',
      text:
          'Apakah Anda tidak yakin atau tidak pernah mendapatkan vaksin BCG (vaksin TBC yang biasanya diberikan saat bayi, meninggalkan bekas bulat kecil di lengan atas)?',
      hint:
          'Jika Anda tidak tahu atau tidak memiliki bekas vaksin BCG di lengan atas kiri, pilih YA.',
      category: 'risiko',
      weight: 5,
    ),
    Question(
      id: 11,
      code: 'G11',
      text:
          'Apakah Anda pernah didiagnosis dan menjalani pengobatan TBC sebelumnya, baik yang selesai tuntas maupun yang tidak diselesaikan (putus obat)?',
      hint:
          'Riwayat TBC sebelumnya, terutama yang putus obat, meningkatkan risiko TBC kambuh atau TBC resisten obat (MDR-TB).',
      category: 'risiko',
      weight: 5,
    ),
    Question(
      id: 12,
      code: 'G12',
      text:
          'Apakah Anda saat ini memiliki kondisi yang melemahkan sistem imun, seperti: HIV/AIDS, diabetes melitus yang tidak terkontrol, atau sedang mengonsumsi obat kortikosteroid/imunosupresan jangka panjang?',
      hint:
          'Kondisi imunitas rendah secara signifikan meningkatkan kerentanan terhadap TBC aktif.',
      category: 'risiko',
      weight: 8,
    ),
    Question(
      id: 13,
      code: 'G13',
      text:
          'Apakah Anda tinggal atau bekerja di tempat yang padat penghuni dan kurang ventilasi udara, seperti: kos-kosan sempit, lembaga pemasyarakatan, asrama, atau rumah dengan sirkulasi udara buruk?',
      hint:
          'Bakteri TBC menyebar melalui udara. Lingkungan padat dan tertutup mempercepat penularan.',
      category: 'risiko',
      weight: 3,
    ),

    // ====== GEJALA TAMBAHAN (G14–G15) ======
    Question(
      id: 14,
      code: 'G14',
      text:
          'Apakah Anda merasakan ada benjolan atau pembengkakan yang tidak nyeri di area leher, ketiak, atau selangkangan yang sudah ada lebih dari 2 minggu?',
      hint:
          'Pembengkakan kelenjar getah bening yang keras, tidak nyeri, dan bertahan lama bisa menjadi tanda TBC kelenjar atau TBC ekstraparu.',
      category: 'tambahan',
      weight: 5,
    ),
    Question(
      id: 15,
      code: 'G15',
      text:
          'Apakah batuk yang Anda alami tidak membaik atau bahkan memburuk meskipun sudah mengonsumsi antibiotik umum (seperti amoksisilin, eritromisin, atau sejenisnya) selama 1–2 minggu?',
      hint:
          'TBC tidak akan sembuh dengan antibiotik biasa. Jika belum pernah batuk atau batuk tidak pernah diobati, jawab TIDAK.',
      category: 'tambahan',
      weight: 4,
    ),
  ];

  /// Mengembalikan daftar kategori gejala yang unik beserta labelnya
  static List<MapEntry<String, String>> getCategories() {
    return const [
      MapEntry('utama', 'Gejala Utama'),
      MapEntry('pendukung', 'Gejala Pendukung'),
      MapEntry('risiko', 'Faktor Risiko'),
      MapEntry('tambahan', 'Gejala Tambahan'),
    ];
  }

  /// Label gejala untuk ditampilkan pada daftar gejala terdeteksi
  static const Map<String, String> symptomLabels = {
    'G01': 'Batuk ≥ 2 minggu',
    'G02': 'Batuk berdarah (hemoptisis)',
    'G03': 'Demam subfebril sore/malam',
    'G04': 'Keringat malam berlebihan',
    'G05': 'Penurunan berat badan',
    'G06': 'Sesak napas / nyeri dada',
    'G07': 'Lemah dan mudah lelah',
    'G08': 'Nafsu makan menurun',
    'G09': 'Kontak dengan pasien TBC',
    'G10': 'Tidak/belum vaksin BCG',
    'G11': 'Riwayat TBC sebelumnya',
    'G12': 'Imunitas rendah (HIV, DM, imunosupresan)',
    'G13': 'Lingkungan padat/kurang ventilasi',
    'G14': 'Pembesaran kelenjar getah bening',
    'G15': 'Batuk tidak respons antibiotik umum',
  };
}
