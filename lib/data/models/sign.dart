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
    this.mainImagePath,
    this.stepTwoImagePath,
    this.stepThreeImagePath,
    this.instructionOverride,
    this.subtitleLabel = 'Sign Language',
    this.hasVideo = false,
    this.videoPath,
  });

  final String id;
  final String word;
  final String emoji;
  final String categoryId;
  final String illustrationDescription;
  final String signDescription;
  final String narration;
  final HandGestureType handGesture;

  /// Optional overrides. When null, falls back to [imageAsset].
  final String? mainImagePath;
  final String? stepTwoImagePath;

  /// When null, the lesson uses a 2-step layout. Set a path for 3 steps.
  final String? stepThreeImagePath;

  final String? instructionOverride;
  final String subtitleLabel;

  /// When true, the lesson hero shows a play control for [videoAsset].
  /// Drop the file at the convention path and set this to true.
  final bool hasVideo;

  /// Optional override for the demo video. Defaults to [defaultVideoAsset].
  final String? videoPath;

  /// Shared category-detail / preview illustration.
  String get imageAsset => 'assets/signs/$id.webp';

  /// Large hero circle + step 1 circle.
  String get mainImageAsset => mainImagePath ?? imageAsset;

  /// Step 2 circle (defaults to the same placeholder until unique art exists).
  String get stepTwoImageAsset => stepTwoImagePath ?? imageAsset;

  /// Optional step 3 — null means a 2-step screen.
  String? get stepThreeImageAsset => stepThreeImagePath;

  /// Tip card copy under the step circles.
  String get instructionText => instructionOverride ?? signDescription;

  /// Convention: `assets/signs/<id>/<id>_video.mp4`
  static String defaultVideoAsset(String id) =>
      'assets/signs/$id/${id}_video.mp4';

  /// Demo video for the hero circle, or null when [hasVideo] is false.
  String? get videoAsset =>
      hasVideo ? (videoPath ?? defaultVideoAsset(id)) : null;
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

enum LessonStep { word, signSteps, practice }
