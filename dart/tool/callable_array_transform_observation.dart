import 'package:linkedspec_dart/linkedspec_dart.dart';

Map<String, Object?> callablePipelineError(Object error) {
  final row = <String, Object?>{
    'error': error.toString(),
    'class': error.runtimeType.toString(),
  };
  if (error is RuntimeInterpreterException) {
    row['error_json'] = error.toJson();
  } else if (error is GeneratedSourceException) {
    row['error_json'] = error.toJson();
  }
  return row;
}

Map<String, Object?> observeCallableTransform(Object? Function() operation) {
  try {
    return {'value': operation()};
  } catch (error) {
    return callablePipelineError(error);
  }
}
