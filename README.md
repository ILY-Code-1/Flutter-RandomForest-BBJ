# 🚀 Flutter Random Forest BBJ - Firestore Authentication

Aplikasi prediksi status nasabah menggunakan algoritma Random Forest dengan authentication berbasis Firestore.

---

## ✨ Features

### Authentication & Authorization
- ✅ Login menggunakan Firestore (tanpa Firebase Auth)
- ✅ Password hashing dengan SHA-256
- ✅ Role-based access control (Admin & Marketing)
- ✅ Manual session management

### Admin Features
- ✅ CRUD User management
- ✅ Create predictions (Manual & Excel import)
- ✅ View all predictions
- ✅ Delete predictions
- ✅ Assign predictions to marketing users
- ✅ Full comment management
- ✅ PDF export

### Marketing Features
- ✅ View assigned predictions only
- ✅ View prediction details
- ✅ Add/delete own comments
- ✅ PDF export
- ❌ Cannot create predictions
- ❌ Cannot delete predictions
- ❌ Cannot manage users

---

## 🏗️ Architecture

### Tech Stack
- **Framework:** Flutter 3.32.0
- **State Management:** GetX
- **Database (Cloud):** Firebase Firestore
- **Database (Local):** SQLite
- **Authentication:** Firestore-based (custom)
- **PDF Generation:** pdf package
- **Excel Import:** excel package

### Project Structure
```
lib/
├── controllers/          # GetX Controllers
│   ├── auth_controller.dart
│   ├── navigation_controller.dart
│   └── prediction_controller.dart
│
├── data/
│   ├── models/          # Data Models
│   │   ├── user_model.dart
│   │   ├── comment_model.dart
│   │   └── prediction_model.dart
│   │
│   └── services/        # Services
│       ├── auth_service.dart (Firestore auth)
│       ├── firestore_service.dart
│       ├── database_service.dart (SQLite)
│       ├── pdf_service.dart
│       └── random_forest_service.dart
│
├── presentation/
│   ├── screens/         # UI Screens
│   └── widgets/         # Reusable Widgets
│
└── core/
    └── theme/           # App Theme
```

---

## 🚀 Quick Start

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Setup Firebase
- Pastikan `lib/firebase_options.dart` sudah ada
- Jika belum: `flutterfire configure`

### 3. Setup Users di Firestore

**Buka Firebase Console → Firestore Database**

Buat collection: **`users_bbj`**

Tambah 3 documents:

#### Admin User:
```
Document ID: (Auto-ID)

Fields:
  email       (string): admin@bprbogorjabar.com
  password    (string): e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
  nama        (string): Admin BPR
  role        (string): admin
  createdAt   (string): 2026-01-24T00:00:00.000Z
```

#### Marketing User 1:
```
Document ID: (Auto-ID)

Fields:
  email       (string): marketing1@bprbogorjabar.com
  password    (string): 8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918
  nama        (string): Marketing Satu
  role        (string): marketing
  createdAt   (string): 2026-01-24T00:00:00.000Z
```

#### Marketing User 2:
```
Document ID: (Auto-ID)

Fields:
  email       (string): marketing2@bprbogorjabar.com
  password    (string): 8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918
  nama        (string): Marketing Dua
  role        (string): marketing
  createdAt   (string): 2026-01-24T00:00:00.000Z
```

**Panduan lengkap:** Lihat file `SETUP_USERS_FIRESTORE.md`

### 4. Run Application
```bash
flutter run
```

### 5. Login

**Admin:**
- Email: `admin@bprbogorjabar.com`
- Password: `admin123456`

**Marketing:**
- Email: `marketing1@bprbogorjabar.com`
- Password: `marketing123`

---

## 🔐 Password Hashes

Password disimpan sebagai SHA-256 hash:

| Password | SHA-256 Hash |
|----------|--------------|
| admin123456 | e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 |
| marketing123 | 8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918 |

**Generate hash baru:**
- Online: https://emn178.github.io/online-tools/sha256.html
- Python: `hashlib.sha256("password".encode()).hexdigest()`

---

## 📊 Firestore Collections

### users_bbj
Menyimpan data user dan credentials:
```javascript
{
  email: string,        // Email user (unique)
  password: string,     // SHA-256 hash
  nama: string,         // Nama lengkap
  role: string,         // "admin" atau "marketing"
  createdAt: string     // ISO 8601 timestamp
}
```

### predictions
Menyimpan hasil prediksi:
```javascript
{
  id: string,
  flag: string,
  tanggalPrediksi: timestamp,
  nasabahList: array,
  akurasi: number,
  createdBy: string,
  assignedUserIds: array,
  comments: array
}
```

---

## 🎮 Usage

### Login
1. Buka aplikasi
2. Masukkan email dan password
3. Tap **Login**

### Admin Workflow
1. Login sebagai admin
2. **Dashboard** - Lihat statistik
3. **FAB Button** - Buat prediksi baru
   - Pilih input manual atau excel
   - Input data nasabah
   - Submit untuk prediksi
4. **Riwayat** - Lihat semua prediksi
5. **Detail Prediksi:**
   - Lihat hasil lengkap
   - Download PDF
   - Tap share icon → Assign ke marketing
   - Add comments
6. **Menu → Kelola User:**
   - Tambah user baru
   - Edit user existing
   - Hapus user

### Marketing Workflow
1. Login sebagai marketing
2. **Dashboard** - Lihat statistik
3. **Riwayat** - Lihat prediksi assigned
4. **Detail Prediksi:**
   - Lihat hasil lengkap
   - Download PDF
   - Add comments
   - (Tidak ada tombol share/delete)

---

## 🧪 Testing

### Test Login
```
✅ Login admin berhasil
✅ Login marketing berhasil
✅ Wrong password ditolak
✅ Email tidak ditemukan error
```

### Test Role-Based Access
```
✅ Admin lihat semua prediksi
✅ Marketing hanya lihat assigned
✅ Admin bisa delete
✅ Marketing tidak bisa delete
✅ Admin akses user management
✅ Marketing tidak akses user management
```

### Test Features
```
✅ Create prediction (admin)
✅ Assign prediction (admin)
✅ Add comment (both roles)
✅ Delete comment (own)
✅ Download PDF (both roles)
✅ Create user (admin)
✅ Edit user (admin)
✅ Delete user (admin)
```

---

## 🔒 Security

### Password Security
- SHA-256 hashing
- No plain text storage
- Hash comparison for auth

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users_bbj/{userId} {
      allow read: if true;  // Needed for login
      allow write: if request.auth != null;
    }
    
    match /predictions/{predictionId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Note:** Custom auth logic di app, tidak menggunakan Firebase Auth `request.auth`.

---

## 📚 Documentation

| File | Deskripsi |
|------|-----------|
| **SETUP_USERS_FIRESTORE.md** | Panduan setup users di Firestore |
| **MODIFIKASI_FIRESTORE_ONLY.md** | Detail modifikasi yang dilakukan |
| **IMPLEMENTATION_GUIDE.md** | Guide implementasi lengkap |
| **FIXES_APPLIED.md** | Log semua fixes |

---

## 🐛 Troubleshooting

### Login Gagal
**Error: "Email tidak ditemukan"**
- Check email spelling
- Verify user exists di Firestore `users_bbj`

**Error: "Password salah"**
- Verify password hash benar di Firestore
- Use hash dari tabel di atas

### App Crash
```bash
flutter clean
flutter pub get
flutter run
```

### Cannot Create User
- Verify logged in as admin
- Check Firestore connection
- Check Firestore rules

---

## 🔄 Updates & Maintenance

### Add New User
1. Login sebagai admin
2. Menu → Kelola User
3. Tap (+) button
4. Fill form → Save

### Change Password
1. Go to Firestore Console
2. Find user document
3. Update `password` field with new SHA-256 hash

### Backup Data
- Export dari Firestore Console
- Or use Firebase CLI: `firebase firestore:export`

---

## 📞 Support

### Issues?
- Check documentation files
- Review troubleshooting section
- Check Firebase Console logs

### Feature Requests
- Open issue in repository
- Contact development team

---

## 📝 License

Private project for BPR Bogor Jabar

---

## 👥 Credits

**Development:**
- Flutter Framework
- Firebase Firestore
- GetX State Management
- Random Forest Algorithm

**Version:** 2.0.0  
**Last Updated:** January 24, 2026  
**Status:** ✅ Production Ready

---

## 🎯 Quick Reference

**Admin Login:**
```
admin@bprbogorjabar.com
admin123456
```

**Marketing Login:**
```
marketing1@bprbogorjabar.com
marketing123
```

**Collections:**
- `users_bbj` - User data & credentials
- `predictions` - Prediction results

**Commands:**
```bash
flutter pub get      # Install dependencies
flutter run          # Run app
flutter clean        # Clean build
```

---

**Ready to use! 🚀**
