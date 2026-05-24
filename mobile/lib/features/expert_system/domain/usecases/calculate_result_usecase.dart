import 'package:tirta/features/expert_system/data/models/question_model.dart';
import 'package:tirta/features/expert_system/domain/entities/examination_result.dart';

/// Forward Chaining Inference Engine untuk deteksi awal TBC
///
/// Implementasi berdasarkan expert_system_tbc.md:
/// - Bobot terdiferensiasi per gejala (total maks 110)
/// - 5 level risiko
/// - Validasi konsistensi jawaban
/// - Bonus triad klasik TBC
/// - Override darurat batuk berdarah
class CalculateResultUsecase {
  static const int _totalMaxWeight = 110;

  ExaminationResult call(Map<String, bool> answers) {
    if (answers.length != 15) {
      throw ArgumentError('Expected 15 answers, got ${answers.length}');
    }

    // ============================================================
    // WORKING MEMORY
    // ============================================================
    final Set<String> workingMemory = {};
    final List<String> flags = [];
    int totalScore = 0;
    bool isUrgent = false;

    // ---- PHASE 1: Tambahkan semua fakta dari jawaban user ----
    answers.forEach((code, answer) {
      if (answer) {
        workingMemory.add('fact_${code}_true');
      }
    });

    // ---- PHASE 2: Hitung skor dan firing rules gejala ----

    // -- Gejala Utama --
    // RULE_001
    if (answers['G01'] == true) {
      workingMemory.add('ada_gejala_cardinal_batuk');
      totalScore += 10;
    }
    // RULE_002
    if (answers['G02'] == true) {
      workingMemory.add('ada_gejala_darurat');
      workingMemory.add('ada_gejala_cardinal_hemoptisis');
      totalScore += 15;
      isUrgent = true;
      flags.add('urgensi_tinggi');
    }
    // RULE_003
    if (answers['G03'] == true) {
      workingMemory.add('ada_gejala_sistemik_demam');
      totalScore += 10;
    }
    // RULE_004
    if (answers['G04'] == true) {
      workingMemory.add('ada_gejala_sistemik_keringat');
      totalScore += 10;
    }
    // RULE_005
    if (answers['G05'] == true) {
      workingMemory.add('ada_gejala_sistemik_BB_turun');
      totalScore += 10;
    }
    // RULE_006: Bonus Triad Klasik
    if (answers['G03'] == true &&
        answers['G04'] == true &&
        answers['G05'] == true) {
      workingMemory.add('ada_TRIAD_KLASIK_TBC');
      totalScore += 5; // bonus bobot triad
    }

    // -- Gejala Pendukung --
    // RULE_007
    if (answers['G06'] == true) {
      workingMemory.add('ada_gejala_respirasi_lanjut');
      totalScore += 5;
    }
    // RULE_008
    if (answers['G07'] == true) {
      workingMemory.add('ada_gejala_sistemik_lelah');
      totalScore += 5;
    }
    // RULE_009
    if (answers['G08'] == true) {
      workingMemory.add('ada_gejala_sistemik_anoreksia');
      totalScore += 5;
    }
    // RULE_010
    if (answers['G06'] == true &&
        answers['G07'] == true &&
        answers['G08'] == true) {
      workingMemory.add('ada_CLUSTER_GEJALA_PENDUKUNG_LENGKAP');
    }

    // -- Faktor Risiko --
    // RULE_011
    if (answers['G09'] == true) {
      workingMemory.add('ada_faktor_risiko_kontak');
      totalScore += 10;
    }
    // RULE_012
    if (answers['G10'] == true) {
      workingMemory.add('ada_faktor_risiko_no_BCG');
      totalScore += 5;
    }
    // RULE_013
    if (answers['G11'] == true) {
      workingMemory.add('ada_faktor_risiko_riwayat_TBC');
      totalScore += 5;
      flags.add('waspadai_MDR_TB');
    }
    // RULE_014
    if (answers['G12'] == true) {
      workingMemory.add('ada_faktor_risiko_imunosupresi');
      totalScore += 8;
    }
    // RULE_015
    if (answers['G13'] == true) {
      workingMemory.add('ada_faktor_risiko_lingkungan');
      totalScore += 3;
    }
    // RULE_016
    if (answers['G09'] == true && answers['G12'] == true) {
      workingMemory.add('ada_RISIKO_GANDA_TINGGI');
    }

    // -- Gejala Tambahan --
    // RULE_017
    if (answers['G14'] == true) {
      workingMemory.add('ada_gejala_TBC_ekstraparu');
      totalScore += 5;
    }
    // RULE_018
    if (answers['G15'] == true && answers['G01'] == true) {
      workingMemory.add('ada_gejala_resistansi_antibiotik');
      totalScore += 4;
    }
    // RULE_019
    if (answers['G15'] == true && answers['G01'] != true) {
      workingMemory.add('inkonsistensi_jawaban_G15');
      flags.add('perlu_validasi_ulang');
    }

    // ---- PHASE 3: Hitung persentase ----
    double percentage = (totalScore / _totalMaxWeight) * 100;
    percentage = double.parse(percentage.toStringAsFixed(1));
    // Clamp ke 0–100
    if (percentage > 100) percentage = 100.0;

    // ---- PHASE 4: Validasi ----
    final int countTrue = answers.values.where((v) => v).length;
    final int countMainSymptomTrue = [
      answers['G01'],
      answers['G02'],
      answers['G03'],
      answers['G04'],
      answers['G05'],
    ].where((v) => v == true).length;

    String validityStatus = 'TIDAK_VALID'; // default
    String validityMessage = '';

    // Cek kondisi TIDAK VALID dulu (RULE_023, 024, 025, dan tambahan)
    if (countTrue == 0) {
      // RULE_023
      validityMessage =
          'Tidak ada gejala yang dilaporkan. Tidak dapat melakukan analisis.';
    } else if (answers['G01'] != true &&
        answers['G02'] != true &&
        countTrue <= 1) {
      // RULE_024
      validityMessage =
          'Informasi gejala terlalu sedikit untuk analisis yang akurat.';
    } else if (workingMemory.contains('inkonsistensi_jawaban_G15')) {
      // RULE_025
      validityMessage =
          'Ditemukan inkonsistensi pada jawaban Anda (Q15). Mohon periksa ulang jawaban Anda.';
    } else if (percentage < 5.0 &&
        answers['G09'] != true &&
        answers['G11'] != true &&
        answers['G12'] != true) {
      // INVALID_4
      validityMessage =
          'Skor terlalu rendah tanpa faktor risiko signifikan.';
    } else {
      // Cek kondisi VALID
      // RULE_020
      if (answers['G01'] == true || answers['G02'] == true) {
        validityStatus = 'VALID';
      }
      // RULE_021
      else if (countMainSymptomTrue >= 3 && countTrue >= 5) {
        validityStatus = 'VALID';
      }
      // RULE_022
      else if (answers['G09'] == true && countTrue >= 2) {
        validityStatus = 'VALID';
      } else {
        validityMessage =
            'Pola gejala tidak mencukupi untuk validasi. Mohon konsultasi langsung ke tenaga medis.';
      }
    }

    // ---- PHASE 5: Tentukan Level Risiko & Rekomendasi ----
    String riskLevel = '';
    String recommendation = '';

    if (validityStatus == 'VALID') {
      // RULE_026–030
      if (percentage < 20) {
        riskLevel = 'sangat_rendah';
        recommendation =
            'Gejala Anda saat ini tidak menunjukkan indikasi TBC yang signifikan. '
            'Tetap jaga kesehatan dan konsultasikan ke dokter jika gejala muncul atau memburuk.';
      } else if (percentage < 40) {
        riskLevel = 'rendah';
        recommendation =
            'Terdapat beberapa faktor risiko ringan. Pantau kondisi Anda selama 1–2 minggu. '
            'Disarankan berkonsultasi ke puskesmas atau klinik terdekat jika gejala berlanjut.';
      } else if (percentage < 60) {
        riskLevel = 'sedang';
        recommendation =
            'Gejala Anda cukup bermakna dan memerlukan perhatian medis. '
            'Segera kunjungi puskesmas atau rumah sakit untuk pemeriksaan rontgen dada dan tes dahak.';
      } else if (percentage < 80) {
        riskLevel = 'tinggi';
        recommendation =
            'Pola gejala Anda sangat konsisten dengan TBC. Segera kunjungi fasilitas kesehatan '
            'dalam 1–2 hari ke depan. Hindari kontak dekat dengan orang lain sementara waktu.';
      } else {
        riskLevel = 'sangat_tinggi';
        recommendation =
            'Indikasi TBC sangat kuat. Segera ke dokter atau IGD rumah sakit hari ini. Jangan tunda.';
      }

      // Tambahan catatan berdasarkan flags
      if (flags.contains('waspadai_MDR_TB')) {
        recommendation +=
            '\n\nCatatan: Riwayat TBC sebelumnya meningkatkan risiko TBC resisten obat (MDR-TB). '
            'Informasikan riwayat ini kepada dokter.';
      }

      // Decision table: kontak erat + persentase >= 40%
      if (answers['G09'] == true && percentage >= 40) {
        recommendation +=
            '\n\nKontak erat dengan pasien TBC disertai gejala bermakna. '
            'Lakukan tes tuberkulin atau foto rontgen dada.';
      }

      // Decision table: imunitas rendah + persentase >= 30%
      if (answers['G12'] == true && percentage >= 30) {
        recommendation +=
            '\n\nKondisi imun rendah mempercepat progresi TBC. Prioritaskan pemeriksaan segera.';
      }

      // RULE_031: Override darurat batuk berdarah
      if (isUrgent) {
        recommendation =
            '⚠️ PERHATIAN: Batuk berdarah adalah gejala yang memerlukan penanganan segera. '
                'Kunjungi IGD atau fasilitas kesehatan terdekat sekarang.\n\n$recommendation';
      }
    } else {
      recommendation = validityMessage.isNotEmpty
          ? validityMessage
          : 'Hasil tidak dapat divalidasi. Disarankan untuk mengulang pemeriksaan atau langsung konsultasi ke tenaga medis.';
    }

    // ---- PHASE 6: Kumpulkan gejala yang terdeteksi ----
    final List<String> detectedSymptoms = [];
    answers.forEach((code, answer) {
      if (answer) {
        detectedSymptoms
            .add(QuestionModel.symptomLabels[code] ?? code);
      }
    });

    return ExaminationResult(
      score: totalScore,
      percentage: percentage,
      riskLevel: riskLevel,
      validityStatus: validityStatus,
      recommendation: recommendation,
      detectedSymptoms: detectedSymptoms,
      flags: flags,
      isUrgent: isUrgent,
      answers: answers,
    );
  }
}
