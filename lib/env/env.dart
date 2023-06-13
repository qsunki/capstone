import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: ".env")
abstract class Env {
  @EnviedField(varName: 'OPEN_AI_API_KEY')
  static const apiKey = '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';
}

