class Sign {
  const Sign({
    required this.id,
    required this.word,
    required this.emoji,
    required this.categoryId,
    required this.illustrationDescription,
    required this.signDescription,
    required this.narration,
    this.handGesture = HandGestureType.openClose,
  });

  final String id;
  final String word;
  final String emoji;
  final String categoryId;
  final String illustrationDescription;
  final String signDescription;
  final String narration;
  final HandGestureType handGesture;

  /// Placeholder illustration asset for this sign, e.g. assets/signs/yes.webp
  String get imageAsset => 'assets/signs/$id.webp';
}

enum HandGestureType {
  openClose,
  fistBump,
  wave,
  point,
  thumbsUp,
  pinch,
  flatHand,
  circle,
  crossArms,
  touchChin,
  rubBelly,
  brushTeeth,
  clap,
  hugMotion,
  drinkMotion,
  eatMotion,
}

enum LessonStep { word, illustration, animation, practice }
