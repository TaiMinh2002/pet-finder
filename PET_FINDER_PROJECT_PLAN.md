# PetFinder - Ứng Dụng Tìm Thú Cưng Thất Lạc Cộng Đồng

## 1. Tổng Quan Dự Án

**Tên dự án:** PetFinder  
**Mô tả:** Ứng dụng di động xây dựng "bảng thông báo" cho cộng đồng nuôi thú cưng đăng tin vật nuôi bị lạc hoặc tìm được, kèm ảnh chụp và vị trí bản đồ. Hoạt động offline-first.  
**Đối tượng:** Người nuôi thú cưng, tình nguyện viên, cộng đồng

---

## 2. Tech Stack (Miễn Phí)

| Thành phần | Công nghệ | Chi phí |
|------------|-----------|---------|
| Framework | Flutter | $0 |
| Map | flutter_map + OpenStreetMap | $0 |
| Auth | Firebase Auth | $0 |
| Database | Firestore | $0 |
| Image Storage | Cloudinary | $0 (25MB/tháng) |
| Local DB | Hive | $0 |
| Notifications | Firebase Cloud Messaging | $0 |

---

## 3. Cấu Trúc Màn Hình (12-13 màn hình)

### Navigation Flow
```
Splash (1)
    ↓
Onboarding (3 trang)
    ↓
Dashboard (Container - Bottom Navigation Bar)
    ├── Tab 1: Map View
    ├── Tab 2: Post List
    ├── Tab 3: Create Post
    ├── Tab 4: Notifications
    └── Tab 5: Profile
```

### Chi tiết Màn hình

| # | Màn hình | Loại | Parent |
|---|----------|------|--------|
| 1 | Splash | Standalone | - |
| 2 | Onboarding - Trang 1 | PageView | - |
| 3 | Onboarding - Trang 2 | PageView | - |
| 4 | Onboarding - Trang 3 | PageView + Button | - |
| 5 | Dashboard | Bottom Nav | - |
| 6 | Map View | Tab | Dashboard |
| 7 | Post List | Tab | Dashboard |
| 8 | Create Post | Tab | Dashboard |
| 9 | Notifications | Tab | Dashboard |
| 10 | Profile | Tab | Dashboard |
| 11 | Post Detail | Push | Map/List |
| 12 | Select Location | Push | Create Post |
| 13 | Settings | Push | Profile |

### UI Specifications
- **Onboarding:** 3 trang (Giới thiệu app → Tính năng chính → Kêu gọi hành động)
- **Navigation:** Bottom Navigation Bar với 5 tabs
- **Create Post:** Tab riêng trong bottom nav (không dùng FAB)

---

## 4. Database Design

### 4.1. Firestore (Cloud)

```
📁 firestore
├── 📂 users
│   └── {uid}
│       ├── uid: string
│       ├── name: string
│       ├── email: string
│       ├── phoneNumber: string
│       ├── avatarUrl: string
│       ├── createdAt: timestamp
│       ├── updatedAt: timestamp
│       └── settings: map
│           ├── notificationsEnabled: boolean
│           ├── notificationRadius: number
│           └── language: string
│
├── 📂 posts
│   └── {postId}
│       ├── id: string
│       ├── userId: string
│       ├── type: string ("lost" | "found" | "resolved")
│       ├── petType: string ("dog" | "cat" | "other")
│       ├── petName: string
│       ├── breed: string
│       ├── color: string
│       ├── description: string
│       ├── lostDate: timestamp
│       ├── latitude: double
│       ├── longitude: double
│       ├── locationName: string (quận/huyện)
│       ├── images: array<string> (max 5 Cloudinary URLs)
│       ├── contactMethod: string ("phone" | "zalo" | "both")
│       ├── phoneNumber: string
│       ├── isAnonymous: boolean
│       ├── isVip: boolean
│       ├── isActive: boolean
│       ├── createdAt: timestamp
│       ├── updatedAt: timestamp
│       └── viewCount: number
│
├── 📂 notifications
│   └── {notifId}
│       ├── id: string
│       ├── userId: string
│       ├── postId: string
│       ├── type: string
│       ├── title: string
│       ├── body: string
│       ├── isRead: boolean
│       ├── createdAt: timestamp
│       └── data: map
│
└── 📂 user_settings
    └── {uid}
        ├── notificationRadius: number
        ├── notificationTypes: array<string>
        ├── quietHoursStart: string
        ├── quietHoursEnd: string
        └── notifyEnabled: boolean
```

### 4.2. Hive (Local - Offline First)

```
📁 hive_boxes
├── users          → UserModel
├── posts          → PostModel
├── pending_posts  → PostModel (chờ sync)
├── search_history → SearchHistoryModel
├── favorite_posts → List<String> (post IDs)
└── app_settings   → AppSettingsModel
```

### 4.3. Data Models

#### UserModel
```dart
class UserModel extends HiveObject {
  String uid;
  String? name;
  String? email;
  String? phoneNumber;
  String? avatarUrl;
  DateTime createdAt;
  DateTime? updatedAt;
}
```

#### PostModel
```dart
class PostModel extends HiveObject {
  String id;
  String userId;
  String type;           // "lost", "found", "resolved"
  String petType;       // "dog", "cat", "other"
  String? petName;
  String? breed;
  String? color;
  String? description;
  DateTime lostDate;
  double latitude;
  double longitude;
  String locationName;
  List<String> images;  // max 5
  String contactMethod;
  String? phoneNumber;
  bool isAnonymous;
  bool isVip;
  bool isSynced;        // ✅ trạng thái sync
  DateTime createdAt;
  DateTime updatedAt;
}
```

### 4.4. Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /posts/{postId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    match /notifications/{notifId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

---

## 5. MVP Features (10 tuần)

| # | Tính năng | Priority | Tuần |
|---|-----------|----------|------|
| 1 | Auth (Firebase - email/phone/Google) | ✅ Bắt buộc | 1-2 |
| 2 | Splash + Onboarding 3 trang | ✅ | 1-2 |
| 3 | Dashboard + Bottom Nav | ✅ | 1-2 |
| 4 | Hive setup + local storage | ✅ | 1-2 |
| 5 | Map View + OSM + markers | ✅ | 3-4 |
| 6 | Vị trí người dùng (Geolocator) | ✅ | 3-4 |
| 7 | Select Location trên map | ✅ | 3-4 |
| 8 | Create Post form + validation | ✅ | 5 |
| 9 | Cloudinary image upload | ✅ | 5-6 |
| 10 | Save post to Firestore | ✅ | 5-6 |
| 11 | Post List view | ✅ | 7 |
| 12 | Post Detail view | ✅ | 7 |
| 13 | Search & Filter | ✅ | 7-8 |
| 14 | Offline-first sync (Hive ↔ Firestore) | ✅ | 8 |
| 15 | Liên hệ (gọi, Zalo, SMS) | ✅ | 9 |
| 16 | Chia sẻ (Facebook, copy link) | ✅ | 9 |
| 17 | Push Notification (FCM) | ✅ | 9 |
| 18 | Profile + Settings | ✅ | 10 |
| 19 | Testing + Bug fixes | ✅ | 10 |

### UI Only (chức năng sau này mới dùng):
- Chat List UI
- Chat Detail UI
- My Posts
- Edit Profile

---

## 6. Offline-First Flow

```
USER ACTION
    │
    ▼
1. SAVE TO HIVE (ngay lập tức)
   → PostModel(isSynced: false)
    │
    ├─────────────────────┐
    ▼                     ▼
 OFFLINE              ONLINE
    │                     │
    ▼                     ▼
 Queue sync       Push to Firestore
 (pending)        → success: isSynced = true
```

---

## 7. Chi Phí Ước Tính

| Hạng mục | Chi phí |
|----------|---------|
| Firebase Spark | Miễn phí |
| Cloudinary | Miễn phí (25MB/tháng) |
| Google Play (1 lần) | $25 |
| Apple Developer (năm) | $99 (nếu cần iOS) |

---

## 8. Cấu Trúc Thư Mục Đề Xuất

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── api_constants.dart
│   ├── errors/
│   │   └── exceptions.dart
│   ├── network/
│   │   └── connectivity_service.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   └── location_utils.dart
│   └── theme/
│       ├── app_theme.dart
│       └── app_colors.dart
│
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── hive_service.dart
│   │   │   └── local_storage.dart
│   │   └── remote/
│   │       ├── firebase_service.dart
│   │       ├── firestore_service.dart
│   │       └── cloudinary_service.dart
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── post_model.dart
│   │   └── notification_model.dart
│   └── repositories/
│       ├── auth_repository.dart
│       ├── post_repository.dart
│       └── user_repository.dart
│
├── domain/
│   ├── entities/
│   │   ├── user.dart
│   │   └── post.dart
│   └── repositories/
│       ├── i_auth_repository.dart
│       └── i_post_repository.dart
│
├── presentation/
│   ├── blocs/
│   │   ├── auth/
│   │   ├── post/
│   │   ├── map/
│   │   └── notification/
│   ├── pages/
│   │   ├── splash/
│   │   ├── onboarding/
│   │   ├── dashboard/
│   │   ├── map/
│   │   ├── post_list/
│   │   ├── post_detail/
│   │   ├── create_post/
│   │   ├── notifications/
│   │   ├── profile/
│   │   └── settings/
│   └── widgets/
│       ├── common/
│       ├── map/
│       └── post/
│
└── main.dart
```

---

## 9. Các Package Cần Thiết (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  
  # Map
  flutter_map: ^7.0.0
  latlong2: ^0.9.0
  
  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_messaging: ^15.0.0
  
  # Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Image
  image_picker: ^1.0.7
  cloudinary_sdk: ^3.0.0
  
  # Location
  geolocator: ^12.0.0
  geocoding: ^3.0.0
  
  # Network
  connectivity_plus: ^6.0.0
  
  # Utils
  url_launcher: ^6.2.0
  share_plus: ^9.0.0
  permission_handler: ^11.3.0
  uuid: ^4.3.0
  intl: ^0.19.0
  
  # UI
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  flutter_slidable: ^3.1.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```

---

## 10. Câu Hỏi Đã Xác Nhận

| Câu hỏi | Trả lời |
|---------|---------|
| Kinh nghiệm Flutter | Trung bình |
| MVP scope | Đầy đủ hơn (offline-first, notifications) |
| Chat trong app | UI only (sau này mới dùng) |
| Monetization | Chưa cần |
| Auth methods | Firebase Auth (email + phone + Google) |
| Image storage | Cloudinary |
| Onboarding | 3 trang |
| Navigation | Bottom Navigation Bar |
| Create Post | Tab riêng |
| User schema | Đầy đủ (name, email, phone, avatar, settings) |
| Max images | 5 ảnh |
| Search history | Có (lưu vào Hive) |

---

*Document created: Tháng 3/2026*
