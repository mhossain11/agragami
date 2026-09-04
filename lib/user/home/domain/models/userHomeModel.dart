class HomeData {
  final String userDocId;
  final String userId;
  final String name;
  final int totalTk;
  final String profileImage;

  const HomeData({
    this.userDocId = '',
    this.userId='',
    this.name = '',
    this.totalTk = 0,
    this.profileImage = '',
  });

  HomeData copyWith({
    String? userDocId,
    String? userId,
    String? name,
    int? totalTk,
    String? profileImage,
  }) {
    return HomeData(
      userDocId: userDocId ?? this.userDocId,
      userId:  userId ?? this.userId,
      name: name ?? this.name,
      totalTk: totalTk ?? this.totalTk,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
