class Quest {
  final String userId;
  final String id;
  final String title;
  final String description;
  final String category; // 'Academic', 'Fitness', 'Life'
  final String difficulty; // 'Easy', 'Medium', 'Hard'
  final int expReward;
  final String status; // 'Pending', 'Completed', 'Failed'
  final String mediaProofPath; // path to the camera image
  final String deadline; // ISO 8601 string

  Quest({
    required this.userId,
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.expReward,
    required this.status,
    required this.mediaProofPath,
    required this.deadline,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'exp_reward': expReward,
      'status': status,
      'media_proof_path': mediaProofPath,
      'deadline': deadline,
    };
  }

  factory Quest.fromMap(Map<String, dynamic> map) {
    return Quest(
      userId: map['user_id'] as String,
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] ?? '',
      category: map['category'] as String,
      difficulty: map['difficulty'] as String,
      expReward: map['exp_reward'] as int,
      status: map['status'] as String,
      mediaProofPath: map['media_proof_path'] ?? '',
      deadline: map['deadline'] as String,
    );
  }

  Quest copyWith({
    String? userId,
    String? id,
    String? title,
    String? description,
    String? category,
    String? difficulty,
    int? expReward,
    String? status,
    String? mediaProofPath,
    String? deadline,
  }) {
    return Quest(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      expReward: expReward ?? this.expReward,
      status: status ?? this.status,
      mediaProofPath: mediaProofPath ?? this.mediaProofPath,
      deadline: deadline ?? this.deadline,
    );
  }
}
