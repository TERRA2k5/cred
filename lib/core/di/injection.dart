import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// This imports the generated file (it will show an error until you run Step 2)
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default is init
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt.init();