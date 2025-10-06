import 'package:flutter/material.dart';

enum MusicStatus {
  available,
  locked,
}

class MusicOption {
  final String id;
  final String name;
  final String? audioPath;
  final IconData icon;
  final MusicStatus status;

  const MusicOption({
    required this.id,
    required this.name,
    this.audioPath,
    required this.icon,
    this.status = MusicStatus.available,
  });
}

// 기본 제공 음악 옵션들
final List<MusicOption> defaultMusicOptions = [
  MusicOption(
    id: 'none',
    name: '없음',
    icon: Icons.music_off,
  ),
  MusicOption(
    id: 'cafe',
    name: '카페 소음',
    icon: Icons.coffee,
    audioPath: 'audios/cafe.wav',
  ),
  MusicOption(
    id: 'forest',
    name: '숲 소리',
    icon: Icons.forest,
    audioPath: 'audios/forest.wav',
  ),
  MusicOption(
    id: 'heavy_rain',
    name: '폭우',
    icon: Icons.thunderstorm,
    audioPath: 'audios/heavy_rain.wav',
  ),
  MusicOption(
    id: 'light_rain',
    name: '빗소리',
    icon: Icons.water_drop,
    audioPath: 'audios/light_rain.wav',
  ),
  MusicOption(
    id: 'beach',
    name: '해변',
    icon: Icons.beach_access,
    audioPath: 'audios/beach.wav',
  ),
  MusicOption(
    id: 'big_waves',
    name: '파도 소리',
    icon: Icons.waves,
    audioPath: 'audios/big_waves.wav',
  ),
  MusicOption(
    id: 'brook',
    name: '시냇물',
    icon: Icons.water,
    audioPath: 'audios/brook.wav',
  ),
  MusicOption(
    id: 'river',
    name: '강물',
    icon: Icons.stream,
    audioPath: 'audios/river.wav',
  ),
  MusicOption(
    id: 'waterfall',
    name: '폭포',
    icon: Icons.landscape,
    audioPath: 'audios/waterfall.wav',
  ),
  MusicOption(
    id: 'brown_noise',
    name: '브라운 노이즈',
    icon: Icons.graphic_eq,
    audioPath: 'audios/brown_noise.wav',
  ),
  MusicOption(
    id: 'breeze',
    name: '바람 소리',
    icon: Icons.air,
    audioPath: 'audios/breeze.wav',
  ),
  MusicOption(
    id: 'night_field',
    name: '밤 들판',
    icon: Icons.nightlight,
    audioPath: 'audios/night_field.wav',
  ),
  MusicOption(
    id: 'fish_tank',
    name: '어항',
    icon: Icons.pets,
    audioPath: 'audios/fish_tank.wav',
  ),
  MusicOption(
    id: 'underwater',
    name: '수중',
    icon: Icons.scuba_diving,
    audioPath: 'audios/underwater.wav',
  ),
];
