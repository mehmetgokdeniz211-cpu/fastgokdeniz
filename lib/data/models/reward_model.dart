class RewardModel {
  final int id;
  final String name;
  final String icon;
  final int pointsRequired;
  final String description;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  RewardModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.pointsRequired,
    required this.description,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      pointsRequired: json['pointsRequired'],
      description: json['description'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'pointsRequired': pointsRequired,
      'description': description,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  RewardModel copyWith({
    int? id,
    String? name,
    String? icon,
    int? pointsRequired,
    String? description,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return RewardModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      description: description ?? this.description,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

class UserStats {
  final int totalScanned;
  final int totalPoints;
  final List<RewardModel> rewards;

  UserStats({
    required this.totalScanned,
    required this.totalPoints,
    required this.rewards,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalScanned: json['totalScanned'] ?? 0,
      totalPoints: json['totalPoints'] ?? 0,
      rewards: (json['rewards'] as List?)
          ?.map((r) => RewardModel.fromJson(r))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalScanned': totalScanned,
      'totalPoints': totalPoints,
      'rewards': rewards.map((r) => r.toJson()).toList(),
    };
  }
}
