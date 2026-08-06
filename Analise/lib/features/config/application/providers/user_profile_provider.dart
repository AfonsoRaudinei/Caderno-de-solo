import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/config/application/providers/config_providers.dart';
import 'package:soloforte/features/config/domain/entities/user_profile_data.dart';

export 'package:soloforte/features/config/domain/entities/user_profile_data.dart';

class UserProfileNotifier extends AsyncNotifier<UserProfileData> {
  @override
  Future<UserProfileData> build() async {
    return ref.read(getUserProfileUsecaseProvider).call();
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfileData>(
  UserProfileNotifier.new,
);
