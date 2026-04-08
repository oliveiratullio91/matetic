import 'package:flutter/material.dart';

import 'app/matetic_app.dart';
import 'core/state/campaign_progress.dart';
import 'core/state/player_profile_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CampaignProgressController.instance.load();
  await PlayerProfileController.instance.load();
  runApp(const MateticApp());
}
