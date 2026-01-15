# Dokumentasi Sistem Prediksi Nasabah BPR Bogor Jabar

## 📋 Daftar Isi
1. [Ringkasan](#ringkasan)
2. [Struktur Dokumentasi](#struktur-dokumentasi)
3. [Cara Menggunakan Diagram PlantUML](#cara-menggunakan-diagram-plantuml)
4. [Hasil Pengujian](#hasil-pengujian)
5. [Cara Membuka Dokumentasi HTML](#cara-membuka-dokumentasi-html)

---

## 🎯 Ringkasan

Dokumentasi ini berisi perancangan sistem dan hasil pengujian lengkap untuk **Sistem Prediksi Nasabah BPR Bogor Jabar** yang menggunakan algoritma Random Forest.

### Informasi Aplikasi
- **Nama Aplikasi**: Sistem Prediksi Nasabah BPR Bogor Jabar
- **Platform**: Flutter (Android/iOS)
- **Algoritma**: Random Forest dengan 7 Decision Trees
- **Database**: SQLite
- **Bahasa**: Dart/Flutter

---

## 📁 Struktur Dokumentasi

```
dokumentasi/
├── README.md                    # File ini
├── all_diagrams.txt            # Semua diagram PlantUML (Use Case, Activity, Sequence, Flowchart, Flowgraph)
├── blackbox_testing.html       # Dokumentasi Black Box Testing
├── whitebox_testing.html       # Dokumentasi White Box Testing
└── uat_testing.html           # Dokumentasi User Acceptance Testing
```

---

## 📊 Diagram PlantUML

File: **`all_diagrams.txt`**

### 1. Use Case Diagram (1 diagram)
Menampilkan seluruh fitur utama aplikasi dan interaksi dengan aktor (Staff Bank):
- Lihat Dashboard
- Input Data Manual
- Upload Data Excel
- Proses Prediksi
- Lihat Detail Prediksi
- Filter Data Nasabah
- Download Laporan PDF
- Lihat Riwayat Prediksi
- Hapus Riwayat

### 2. Activity Diagrams (6 diagram)
Diagram alur aktivitas untuk setiap fitur utama:
- Activity Diagram: Lihat Dashboard
- Activity Diagram: Input Data Manual
- Activity Diagram: Upload Data Excel
- Activity Diagram: Lihat Detail Prediksi
- Activity Diagram: Download Laporan PDF
- Activity Diagram: Lihat Riwayat Prediksi

### 3. Sequence Diagrams (4 diagram)
Diagram urutan interaksi antar komponen:
- Sequence Diagram: Input Data Manual & Prediksi
- Sequence Diagram: Upload Excel & Prediksi
- Sequence Diagram: Lihat Detail dengan Filter
- Sequence Diagram: Download Laporan PDF

### 4. Flowcharts (6 diagram)
Diagram alur logika program:
- Flowchart: Random Forest Predict Method
- Flowchart: Decision Tree Pohon 1 (Frekuensi & Saldo)
- Flowchart: Decision Tree Pohon 2 (Pendapatan & Usia)
- Flowchart: Validasi Form Input
- Flowchart: Validasi Data Excel
- Flowchart: Submit Prediksi Manual

### 5. Flowgraphs (3 diagram)
Diagram graph dengan analisis Cyclomatic Complexity:
- Flowgraph: Random Forest Predict Method (V(G) = 2)
- Flowgraph: Decision Tree Pohon 1 (V(G) = 2)
- Flowgraph: Validasi Form (V(G) = 7)

---

## 🔧 Cara Menggunakan Diagram PlantUML

### Opsi 1: Online PlantUML Editor
1. Buka [PlantUML Online Editor](https://www.plantuml.com/plantuml/uml/)
2. Copy kode diagram dari file `all_diagrams.txt`
3. Paste ke editor
4. Diagram akan ter-generate otomatis
5. Download sebagai PNG/SVG

### Opsi 2: VS Code Extension
1. Install extension "PlantUML" di VS Code
2. Buka file `all_diagrams.txt`
3. Copy satu diagram (dari `@startuml` sampai `@enduml`)
4. Buat file baru dengan ekstensi `.puml`
5. Paste kode diagram
6. Tekan `Alt+D` untuk preview

### Opsi 3: PlantUML Desktop
1. Download [PlantUML JAR](https://plantuml.com/download)
2. Install Java JRE jika belum ada
3. Copy diagram ke file `.puml`
4. Run: `java -jar plantuml.jar filename.puml`
5. Output PNG akan ter-generate

### Contoh Penggunaan:
```bash
# Untuk generate Use Case Diagram
java -jar plantuml.jar usecase_diagram.puml

# Untuk generate Activity Diagram
java -jar plantuml.jar activity_dashboard.puml
```

---

## ✅ Hasil Pengujian

### 1. Black Box Testing
**File**: `blackbox_testing.html`

**Ringkasan**:
- Total Test Cases: **58 pengujian**
- Status: **58 PASS, 0 FAIL**
- Persentase Keberhasilan: **100%**

**Kategori Pengujian**:
1. Fitur Dashboard (4 test cases)
2. Input Data Manual (9 test cases)
3. Upload Excel (9 test cases)
4. Detail Prediksi (9 test cases)
5. Download PDF (7 test cases)
6. Riwayat Prediksi (5 test cases)
7. Navigasi Aplikasi (6 test cases)

---

### 2. White Box Testing
**File**: `whitebox_testing.html`

**Ringkasan Cyclomatic Complexity**:
| Method | V(G) | Kategori |
|--------|------|----------|
| Random Forest Predict | 2 | Rendah (Baik) |
| Decision Tree Pohon 1 | 2 | Rendah (Baik) |
| Decision Tree Pohon 2 | 3 | Rendah (Baik) |
| Validasi Form | 7 | Sedang (Baik) |
| Validasi Excel | 5 | Sedang (Baik) |
| Submit Prediksi | 3 | Rendah (Baik) |

**Kesimpulan**:
- Semua method memiliki cyclomatic complexity ≤ 10 (kategori baik)
- 100% path coverage tercapai
- Tidak ada dead code atau unreachable paths
- Struktur kode bersih dan mudah dipelihara

**Mencakup**:
- Flowchart untuk setiap fungsi kritis
- Flowgraph dengan analisis cyclomatic complexity
- Independent paths untuk setiap fungsi
- Test cases untuk path coverage

---

### 3. User Acceptance Testing (UAT)
**File**: `uat_testing.html`

**Ringkasan**:
- Total Skenario: **26 skenario**
- Status: **26 PASS, 0 FAIL**
- Persentase Keberhasilan: **100%**

**Kategori Pengujian**:
1. Dashboard dan Statistik (2 skenario)
2. Input Data Manual (5 skenario)
3. Upload Data Excel (4 skenario)
4. Detail Hasil Prediksi (5 skenario)
5. Download Laporan PDF (3 skenario)
6. Riwayat Prediksi (3 skenario)
7. Navigasi dan Usability (4 skenario)

**Status Akhir**: ✅ **DITERIMA (ACCEPTED)**

**Kesimpulan**:
Sistem memenuhi semua kebutuhan bisnis dan siap untuk di-deploy ke production environment.

---

## 🌐 Cara Membuka Dokumentasi HTML

### Windows
1. Buka File Explorer
2. Navigate ke folder `dokumentasi`
3. Double-click pada file HTML yang ingin dibuka:
   - `blackbox_testing.html`
   - `whitebox_testing.html`
   - `uat_testing.html`
4. File akan terbuka di browser default

### Command Line
```bash
# Windows
start blackbox_testing.html

# Mac/Linux
open blackbox_testing.html
```

### Tips Viewing
- Gunakan browser modern (Chrome, Firefox, Edge) untuk tampilan optimal
- File HTML sudah di-styling dengan CSS internal
- Dapat di-print atau save as PDF dari browser
- Responsive dan dapat dibuka di mobile

---

## 📤 Export ke Word (.docx)

Untuk mengexport dokumentasi HTML ke format Word:

### Opsi 1: Copy-Paste dari Browser
1. Buka file HTML di browser
2. Select All (Ctrl+A)
3. Copy (Ctrl+C)
4. Buka Microsoft Word
5. Paste (Ctrl+V)
6. Format akan terjaga dengan baik

### Opsi 2: Print to PDF, lalu Convert
1. Buka file HTML di browser
2. Tekan Ctrl+P (Print)
3. Pilih "Save as PDF"
4. Gunakan online converter PDF to DOCX

### Opsi 3: Pandoc (Recommended)
```bash
# Install Pandoc terlebih dahulu
pandoc blackbox_testing.html -o blackbox_testing.docx
pandoc whitebox_testing.html -o whitebox_testing.docx
pandoc uat_testing.html -o uat_testing.docx
```

---

## 📝 Catatan Tambahan

### Format Dokumentasi
- **Diagram**: PlantUML text format (dapat di-generate ke gambar)
- **Testing**: HTML format (mudah dibuka dan di-print)
- **Bahasa**: Indonesia
- **Target Audience**: Mahasiswa, Dosen, Reviewer Skripsi/TA

### Kegunaan Dokumentasi
1. **Skripsi/Tugas Akhir**: Dapat digunakan untuk BAB 3 (Perancangan Sistem) dan BAB 4 (Pengujian)
2. **Presentasi**: Diagram dapat di-export sebagai gambar untuk slide
3. **Laporan Proyek**: Format HTML dapat di-convert ke Word/PDF
4. **Portfolio**: Dokumentasi lengkap untuk portfolio pengembang

---

## 🎓 Kesesuaian dengan Standar Akademik

Dokumentasi ini telah disusun sesuai dengan standar dokumentasi sistem informasi yang umum digunakan dalam:
- Tugas Akhir/Skripsi Teknik Informatika
- Laporan Pengembangan Sistem
- Software Design Document (SDD)
- Software Testing Document (STD)

### Metodologi yang Digunakan
- **Perancangan**: UML (Unified Modeling Language)
- **Testing**: Black Box, White Box, User Acceptance Testing (UAT)
- **Analisis Kode**: Cyclomatic Complexity Analysis
- **Coverage**: Path Coverage, Branch Coverage

---

## ✨ Fitur Utama Aplikasi

1. **Dashboard**: Melihat statistik prediksi
2. **Input Manual**: Form input data nasabah satu per satu
3. **Upload Excel**: Upload data nasabah dalam jumlah banyak
4. **Prediksi**: Menggunakan Random Forest dengan 7 Decision Trees
5. **Detail Hasil**: Lihat hasil prediksi dengan filter
6. **Summary**: Ringkasan nasabah aktif/tidak aktif
7. **Download PDF**: Export laporan dalam format PDF
8. **Riwayat**: Lihat dan kelola riwayat prediksi

---

## 🔍 Algoritma Random Forest

Aplikasi menggunakan **7 Decision Trees** dengan fokus berbeda:
1. **Pohon 1**: Frekuensi Transaksi & Saldo
2. **Pohon 2**: Pendapatan & Usia
3. **Pohon 3**: Lama Menjadi Nasabah & Pekerjaan
4. **Pohon 4**: Saldo Rata-rata & Frekuensi
5. **Pohon 5**: Kombinasi Pendapatan, Transaksi, Lama Nasabah
6. **Pohon 6**: Usia & Jenis Kelamin & Pendapatan
7. **Pohon 7**: Comprehensive - Semua Faktor

**Metode Voting**: Majority Voting (suara terbanyak menentukan final prediksi)

---

## 📞 Support

Untuk pertanyaan atau bantuan lebih lanjut mengenai dokumentasi ini:
- Lihat kode sumber di: `lib/` folder
- Baca komentar di setiap file untuk penjelasan detail
- Hubungi developer untuk klarifikasi

---

## 📄 Lisensi

Dokumentasi ini dibuat untuk keperluan akademik dan pengembangan Sistem Prediksi Nasabah BPR Bogor Jabar.

---

**Terakhir Diperbarui**: Januari 2026  
**Versi Dokumentasi**: 1.0  
**Status**: ✅ Complete

---

*Dokumentasi ini dibuat dengan ❤️ menggunakan PlantUML, HTML, dan Markdown*
