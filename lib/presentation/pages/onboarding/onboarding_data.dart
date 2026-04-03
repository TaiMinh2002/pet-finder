import 'package:flutter/material.dart';

class OnboardingData {
  final String label;
  final String title;
  final String subtitle;
  final Color color;

  const OnboardingData({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

final List<OnboardingData> onboardingPages = [
  OnboardingData(
    label: '1 / 3',
    title: 'Thú cưng lạc đường\nsẽ được tìm thấy',
    subtitle:
        'Đăng tin tìm kiếm chỉ trong 30 giây. Hàng nghìn mắt đang cùng bạn tìm.',
    color: const Color(0xFFFF6B6B),
  ),
  OnboardingData(
    label: '2 / 3',
    title: 'Bản đồ thông minh\ngần bạn nhất',
    subtitle:
        'Xem ngay vị trí các tin báo thất lạc xung quanh bạn theo thời gian thực.',
    color: const Color(0xFF4EAEFF),
  ),
  OnboardingData(
    label: '3 / 3',
    title: 'Cộng đồng yêu\nthú cưng cùng giúp',
    subtitle:
        'Kết nối với hàng chục ngàn người yêu động vật sẵn sàng hỗ trợ ngay.',
    color: const Color(0xFF56D49A),
  ),
];
