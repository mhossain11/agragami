class HomeData {
  final String userDocId;
  final String name;
  final int totalTk;
  final String profileImage;

  const HomeData({
    this.userDocId = '',
    this.name = '',
    this.totalTk = 0,
    this.profileImage = '',
  });

  HomeData copyWith({
    String? userDocId,
    String? name,
    int? totalTk,
    String? profileImage,
  }) {
    return HomeData(
      userDocId: userDocId ?? this.userDocId,
      name: name ?? this.name,
      totalTk: totalTk ?? this.totalTk,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
