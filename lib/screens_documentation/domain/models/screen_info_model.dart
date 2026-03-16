import 'package:freezed_annotation/freezed_annotation.dart';

part 'screen_info_model.freezed.dart';

@freezed
class ScreenInfoModel with _$ScreenInfoModel {
  const factory ScreenInfoModel({
    String? id, // Firestore document ID
    required String screenName,
    required String screenNameAr,
    required String routeName,
    required String description,
    required String descriptionAr,
    required String filePath,
    required List<String> businessLogic,
    required List<String> businessLogicAr,
    required List<String> keyFeatures,
    required List<String> keyFeaturesAr,
    required List<String> dataModels,
    required List<String> providers,
    required List<String> useCases,
    required List<String> childScreens,
    required Map<String, String> apiEndpoints,
    required String stateManagement,
    String? screenshot, // Firebase Storage URL or local path
  }) = _ScreenInfoModel;
}

