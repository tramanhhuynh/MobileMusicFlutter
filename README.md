# 🎵 Melofy - Ứng dụng Nghe nhạc Di động

<div align="center">
  <img src="assets/vectors/logoMelofyFull.png" alt="Melofy Logo" width="200"/>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.7.2-blue.svg)](https://flutter.dev/)
  [![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

## 📱 Mô tả

**Melofy** là một ứng dụng nghe nhạc hiện đại được phát triển bằng Flutter, cung cấp trải nghiệm nghe nhạc chất lượng cao với giao diện đẹp mắt và các tính năng tiên tiến. Ứng dụng được thiết kế với kiến trúc Clean Architecture và sử dụng BLoC pattern để quản lý state.

## ✨ Tính năng chính

### 🎼 Phát nhạc
- **Phát nhạc chất lượng cao** với hỗ trợ nhiều định dạng
- **Mini player bar** cho trải nghiệm phát nhạc liền mạch
- **Điều khiển phát nhạc** đầy đủ (play, pause, next, previous)
- **Hiển thị lời bài hát** (lyrics) với file .lrc
- **Hiệu ứng CD spinner** khi phát nhạc

### 🏠 Trang chủ
- **Banner bài hát nổi bật** với hình ảnh đẹp mắt
- **Danh sách nhạc mới nhất** được cập nhật thường xuyên
- **Playlist đề xuất** dựa trên sở thích người dùng
- **Giao diện responsive** tối ưu cho mọi thiết bị

### 🔍 Tìm kiếm
- **Tìm kiếm bài hát** theo tên, nghệ sĩ
- **Tìm kiếm thông minh** với gợi ý kết quả
- **Lọc kết quả** theo nhiều tiêu chí khác nhau
- **Tìm kiếm YouTube Shorts** tích hợp

### 📚 Thư viện
- **Quản lý album** với thông tin chi tiết
- **Tạo và quản lý playlist** cá nhân
- **Thêm/xóa bài hát** vào playlist
- **Xem danh sách bài hát theo nghệ sĩ**
- **Giao diện grid/list** linh hoạt

### 👤 Hồ sơ người dùng
- **Đăng ký/Đăng nhập** với Firebase Authentication
- **Quản lý thông tin cá nhân**
- **Danh sách bài hát yêu thích**
- **Thống kê nghe nhạc**

### 🎬 YouTube Shorts
- **Xem video âm nhạc** từ YouTube
- **Tìm kiếm shorts** theo từ khóa
- **Phát video** tích hợp trong ứng dụng

## 🛠 Công nghệ sử dụng

### Frontend
- **Flutter 3.7.2** - Framework UI cross-platform
- **Dart** - Ngôn ngữ lập trình
- **Material Design 3** - Design system

### State Management
- **flutter_bloc** - BLoC pattern implementation
- **hydrated_bloc** - Persistent state management

### Backend & Database
- **Firebase Authentication** - Xác thực người dùng
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - Lưu trữ file media

### Audio & Media
- **just_audio** - Audio playback engine
- **sqflite** - Local database cho cache
- **image_picker** - Chọn ảnh từ gallery/camera

### UI/UX
- **shimmer** - Loading effects
- **flutter_svg** - SVG support
- **Custom fonts** - SpotifyMixUI font family

### Utilities
- **get_it** - Dependency injection
- **dartz** - Functional programming
- **equatable** - Value equality
- **http** - HTTP requests
- **url_launcher** - External links

## 📋 Yêu cầu hệ thống

- **Flutter SDK**: ^3.7.2
- **Dart SDK**: ^3.0.0
- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 11.0+
- **Firebase Project**: Đã cấu hình

## 🚀 Cài đặt

### 1. Clone repository
```bash
git clone https://github.com/your-username/MobileMusicFlutter.git
cd MobileMusicFlutter
```

### 2. Cài đặt dependencies
```bash
flutter pub get
```

### 3. Cấu hình Firebase
1. Tạo project trên [Firebase Console](https://console.firebase.google.com/)
2. Thêm ứng dụng Android/iOS
3. Tải file `google-services.json` (Android) hoặc `GoogleService-Info.plist` (iOS)
4. Đặt file vào thư mục tương ứng:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### 4. Chạy ứng dụng
```bash
# Chạy trên thiết bị được kết nối
flutter run

# Build APK cho Android
flutter build apk

# Build IPA cho iOS
flutter build ios
```

## 📁 Cấu trúc dự án

```
lib/
├── common/                 # Shared components
│   ├── bloc/              # Common BLoC implementations
│   ├── helpers/           # Utility functions
│   └── widgets/           # Reusable widgets
├── core/                  # Core functionality
│   ├── configs/           # App configurations
│   ├── services/          # Core services
│   └── usecase/           # Base use case
├── data/                  # Data layer
│   ├── models/            # Data models
│   ├── repository/        # Repository implementations
│   └── sources/           # Data sources (Firebase, API)
├── domain/                # Business logic layer
│   ├── entities/          # Business entities
│   ├── repository/        # Repository interfaces
│   └── usecases/          # Business use cases
├── presentation/          # UI layer
│   ├── auth/              # Authentication screens
│   ├── home/              # Home screen
│   ├── lib_page/          # Library screen
│   ├── profile/           # Profile screen
│   ├── search_page/       # Search screen
│   ├── song_player/       # Music player
│   └── youtube_shorts/    # YouTube integration
├── firebase_options.dart  # Firebase configuration
├── main.dart             # App entry point
└── service_locator.dart  # Dependency injection
```

## 🎨 Giao diện

Ứng dụng sử dụng thiết kế hiện đại với:
- **Dark theme** làm chủ đạo
- **Gradient backgrounds** đẹp mắt
- **Custom fonts** SpotifyMixUI
- **Smooth animations** và transitions
- **Responsive design** cho mọi kích thước màn hình

## 🔧 Tính năng kỹ thuật

### Clean Architecture
- **Separation of Concerns** rõ ràng
- **Dependency Injection** với GetIt
- **Repository Pattern** cho data access
- **Use Case Pattern** cho business logic

### State Management
- **BLoC Pattern** cho state management
- **Hydrated BLoC** cho persistent state
- **Event-driven architecture**

### Performance
- **Lazy loading** cho danh sách lớn
- **Image caching** và optimization
- **Audio streaming** hiệu quả
- **Background playback** support

## 👥 Tác giả

**Melofy Team**
- Email: tammai1899@gmail.com

---

<div align="center">
  <p>Made with ❤️ by Melofy Team</p>
</div>
