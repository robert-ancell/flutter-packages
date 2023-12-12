// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'generator.dart';
import 'generator_tools.dart';

/// General comment opening token.
const String _commentPrefix = '//';

/// Documentation comment spec.
const DocumentCommentSpecification _docCommentSpec =
    DocumentCommentSpecification(_commentPrefix);

/// Options that control how Linux code will be generated.
class LinuxOptions {
  /// Creates a [LinuxOptions] object
  const LinuxOptions({
    this.headerIncludePath,
    this.namespace,
    this.copyrightHeader,
    this.headerOutPath,
  });

  /// The path to the header that will get placed in the source filed (example:
  /// "foo.h").
  final String? headerIncludePath;

  /// The namespace where the generated class will live.
  final String? namespace;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// The path to the output header file location.
  final String? headerOutPath;

  /// Creates a [LinuxOptions] from a Map representation where:
  /// `x = LinuxOptions.fromMap(x.toMap())`.
  static LinuxOptions fromMap(Map<String, Object> map) {
    return LinuxOptions(
      headerIncludePath: map['header'] as String?,
      namespace: map['namespace'] as String?,
      copyrightHeader: map['copyrightHeader'] as Iterable<String>?,
      headerOutPath: map['linuxHeaderOut'] as String?,
    );
  }

  /// Converts a [LinuxOptions] to a Map representation where:
  /// `x = LinuxOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (headerIncludePath != null) 'header': headerIncludePath!,
      if (namespace != null) 'namespace': namespace!,
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [LinuxOptions].
  LinuxOptions merge(LinuxOptions options) {
    return LinuxOptions.fromMap(mergeMaps(toMap(), options.toMap()));
  }
}

/// Class that manages all Linux code generation.
class LinuxGenerator extends Generator<OutputFileOptions<LinuxOptions>> {
  /// Constructor.
  const LinuxGenerator();

  /// Generates Linux file of type specified in [generatorOptions]
  @override
  void generate(
    OutputFileOptions<LinuxOptions> generatorOptions,
    Root root,
    StringSink sink, {
    required String dartPackageName,
  }) {
    assert(generatorOptions.fileType == FileType.header ||
        generatorOptions.fileType == FileType.source);
    if (generatorOptions.fileType == FileType.header) {
      const LinuxHeaderGenerator().generate(
        generatorOptions.languageOptions,
        root,
        sink,
        dartPackageName: dartPackageName,
      );
    } else if (generatorOptions.fileType == FileType.source) {
      const LinuxSourceGenerator().generate(
        generatorOptions.languageOptions,
        root,
        sink,
        dartPackageName: dartPackageName,
      );
    }
  }
}

/// Writes Linux header (.h) file to sink.
class LinuxHeaderGenerator extends StructuredGenerator<LinuxOptions> {
  /// Constructor.
  const LinuxHeaderGenerator();

  @override
  void writeFilePrologue(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('$_commentPrefix ${getGeneratedCodeWarning()}');
    indent.writeln('$_commentPrefix $seeAlsoWarning');
    indent.newln();
  }

  @override
  void writeFileImports(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    final String guardName = _getGuardName(generatorOptions.headerIncludePath);
    indent.writeln('#ifndef $guardName');
    indent.writeln('#define $guardName');

    indent.newln();
    _writeSystemHeaderIncludeBlock(indent, <String>[
      'flutter_linux/flutter_linux.h',
    ]);
    indent.newln();
  }

  @override
  void writeOpenNamespace(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.writeln('G_BEGIN_DECLS');
  }

  @override
  void writeGeneralUtilities(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {}

  @override
  void writeEnum(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Enum anEnum, {
    required String dartPackageName,
  }) {
    const String namespace = 'My';
    final String enumName = '$namespace${anEnum.name}';
    final String snakeEnumName = _snakeCaseFromCamelCase(anEnum.name);
    final String upperSnakeEnumName =
        '${namespace}_$snakeEnumName'.toUpperCase();

    indent.newln();
    addDocumentationComments(
        indent, anEnum.documentationComments, _docCommentSpec);
    indent.addScoped('typedef enum {', '} $enumName;', () {
      final List<String> enumValues = <String>[];
      for (int i = 0; i < anEnum.members.length; i++) {
        final EnumMember member = anEnum.members[i];
        final String itemName =
            _snakeCaseFromCamelCase(member.name).toUpperCase();
        enumValues.add('${upperSnakeEnumName}_$itemName = $i');
      }
      indent.writeln(enumValues.join(', '));
    });
  }

  @override
  void writeDataClass(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    const String namespace = 'My';
    final String snakeNamespace = _snakeCaseFromCamelCase(namespace);
    final String className = '$namespace${classDefinition.name}';
    final String snakeClassName = _snakeCaseFromCamelCase(classDefinition.name);

    final String methodPrefix = '${snakeNamespace}_$snakeClassName';

    indent.newln();
    _writeDeclareFinalType(indent, namespace, classDefinition.name);

    indent.newln();
    final List<String> constructorArgs = <String>[];
    for (final NamedType field in classDefinition.fields) {
      final String fieldName = _snakeCaseFromCamelCase(field.name);
      final String type = _getType(namespace, field.type);
      constructorArgs.add('$type $fieldName');
    }
    indent.writeln(
        "$className* ${methodPrefix}_new(${constructorArgs.join(', ')});");

    for (final NamedType field in classDefinition.fields) {
      final String fieldName = _snakeCaseFromCamelCase(field.name);
      final String returnType = _getType(namespace, field.type);

      indent.newln();
      indent.writeln(
          '$returnType ${methodPrefix}_get_$fieldName($className* object);');
    }
  }

  @override
  void writeFlutterApi(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
    const String namespace = 'My';
    final String snakeNamespace = _snakeCaseFromCamelCase(namespace);
    final String className = '$namespace${api.name}';
    final String snakeClassName = _snakeCaseFromCamelCase(api.name);

    final String methodPrefix = '${snakeNamespace}_$snakeClassName';

    indent.newln();
    _writeDeclareFinalType(indent, namespace, api.name);

    indent.newln();
    indent.writeln(
        '$className* ${methodPrefix}_new(FlBinaryMessenger* messenger);');

    for (final Method method in api.methods) {
      final String methodName = _snakeCaseFromCamelCase(method.name);

      final List<String> asyncArgs = <String>['$className* object'];
      for (final Parameter param in method.parameters) {
        final String paramName = _snakeCaseFromCamelCase(param.name);
        final String paramType = _getType(namespace, param.type);
        asyncArgs.add('$paramType $paramName');
      }
      asyncArgs.addAll(<String>[
        'GCancellable* cancellable',
        'GAsyncReadyCallback callback',
        'gpointer user_data'
      ]);
      indent.newln();
      indent.writeln(
          "void ${methodPrefix}_${methodName}_async(${asyncArgs.join(', ')});");

      final List<String> finishArgs = <String>[
        '$className* object',
        'GAsyncResult* result'
      ];
      final String returnType =
          _getType(namespace, method.returnType, isOutput: true);
      if (returnType != 'void') {
        finishArgs.add('$returnType* return_value');
      }
      finishArgs.add('GError** error');
      indent.newln();
      indent.writeln(
          "gboolean ${methodPrefix}_${methodName}_finish(${finishArgs.join(', ')});");
    }
  }

  @override
  void writeHostApi(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
    const String namespace = 'My';
    final String snakeNamespace = _snakeCaseFromCamelCase(namespace);
    final String className = '$namespace${api.name}';
    final String snakeClassName = _snakeCaseFromCamelCase(api.name);

    final String methodPrefix = '${snakeNamespace}_$snakeClassName';
    final String vtableName = '${className}VTable';

    indent.newln();
    _writeDeclareFinalType(indent, namespace, api.name);

    indent.newln();
    indent.addScoped('typedef struct {', '} $vtableName;', () {
      for (final Method method in api.methods) {
        final String methodName = _snakeCaseFromCamelCase(method.name);

        final List<String> methodArgs = <String>['$className* object'];
        for (final Parameter param in method.parameters) {
          final String paramName = _snakeCaseFromCamelCase(param.name);
          final String paramType = _getType(namespace, param.type);
          methodArgs.add('$paramType $paramName');
        }
        if (method.isAsynchronous) {
          // FIXME: Pass handle
        } else {
          final String returnType =
              _getType(namespace, method.returnType, isOutput: true);
          if (returnType != 'void') {
            methodArgs.add('$returnType* return_value');
          }
          methodArgs.add('GError** error');
        }
        methodArgs.add('gpointer user_data');
        indent.writeln("gboolean (*$methodName)(${methodArgs.join(', ')});");
      }
    });

    indent.newln();
    indent.writeln(
        '$className* ${methodPrefix}_new(FlBinaryMessenger* messenger, const $vtableName* vtable, gpointer user_data, GDestroyNotify user_data_free_func);');
  }

  @override
  void writeCloseNamespace(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.newln();
    indent.writeln('G_END_DECLS');

    indent.newln();
    final String guardName = _getGuardName(generatorOptions.headerIncludePath);
    indent.writeln('#endif  // $guardName');
  }
}

/// Writes Linux source (.cc) file to sink.
class LinuxSourceGenerator extends StructuredGenerator<LinuxOptions> {
  /// Constructor.
  const LinuxSourceGenerator();

  @override
  void writeFilePrologue(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('$_commentPrefix ${getGeneratedCodeWarning()}');
    indent.writeln('$_commentPrefix $seeAlsoWarning');
  }

  @override
  void writeFileImports(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.newln();
    indent.writeln('#include "${generatorOptions.headerIncludePath}"');
  }

  @override
  void writeDataClass(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    const String namespace = 'My';
    final String snakeNamespace = _snakeCaseFromCamelCase(namespace);
    final String className = '$namespace${classDefinition.name}';
    final String snakeClassName = _snakeCaseFromCamelCase(classDefinition.name);

    final String methodPrefix = '${snakeNamespace}_$snakeClassName';
    final String castMacro = methodPrefix.toUpperCase();
    final String testMacro =
        '${snakeNamespace}_IS_$snakeClassName'.toUpperCase();

    indent.newln();
    _writeObjectStruct(indent, namespace, classDefinition.name, () {
      indent.newln();
      for (final NamedType field in classDefinition.fields) {
        final String fieldName = _snakeCaseFromCamelCase(field.name);
        final String fieldType =
            _getType(namespace, field.type, isOutput: true);
        indent.writeln('$fieldType $fieldName;');
      }
    });

    indent.newln();
    _writeDefineType(indent, namespace, classDefinition.name);

    indent.newln();
    _writeDispose(indent, namespace, classDefinition.name, () {
      _writeCastSelf(indent, namespace, classDefinition.name);
    });

    indent.newln();
    _writeInit(indent, namespace, classDefinition.name, () {});

    indent.newln();
    _writeClassInit(indent, namespace, classDefinition.name, () {});

    final List<String> constructorArgs = <String>[];
    for (final NamedType field in classDefinition.fields) {
      final String fieldName = _snakeCaseFromCamelCase(field.name);
      final String type = _getType(namespace, field.type);
      constructorArgs.add('$type $fieldName');
    }
    indent.addScoped(
        "$className* ${methodPrefix}_new(${constructorArgs.join(', ')}) {", '}',
        () {
      indent.writeln(
          '$className* self = $castMacro(g_object_new(${methodPrefix}_get_type(), nullptr);');
      indent.writeln('return self;');
    });

    for (final NamedType field in classDefinition.fields) {
      final String fieldName = _snakeCaseFromCamelCase(field.name);
      final String returnType = _getType(namespace, field.type);

      indent.newln();
      indent.addScoped(
          '$returnType ${methodPrefix}_get_$fieldName($className* self) {', '}',
          () {
        indent.writeln('g_return_val_if_fail($testMacro(object), nullptr);');
        indent.writeln('return self->$fieldName;');
      });
    }
  }

  @override
  void writeFlutterApi(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
    const String namespace = 'My';
    final String snakeNamespace = _snakeCaseFromCamelCase(namespace);
    final String className = '$namespace${api.name}';
    final String snakeClassName = _snakeCaseFromCamelCase(api.name);

    final String methodPrefix = '${snakeNamespace}_$snakeClassName';

    indent.newln();
    _writeObjectStruct(indent, namespace, api.name, () {});

    indent.newln();
    _writeDefineType(indent, namespace, api.name);

    indent.newln();
    _writeDispose(indent, namespace, api.name, () {
      _writeCastSelf(indent, namespace, api.name);
    });

    indent.newln();
    _writeInit(indent, namespace, api.name, () {});

    indent.newln();
    _writeClassInit(indent, namespace, api.name, () {});

    for (final Method method in api.methods) {
      final String methodName = _snakeCaseFromCamelCase(method.name);

      final List<String> asyncArgs = <String>['$className* object'];
      for (final Parameter param in method.parameters) {
        final String paramName = _snakeCaseFromCamelCase(param.name);
        final String paramType = _getType(namespace, param.type);
        asyncArgs.add('$paramType $paramName');
      }
      asyncArgs.addAll(<String>[
        'GCancellable* cancellable',
        'GAsyncReadyCallback callback',
        'gpointer user_data'
      ]);
      indent.newln();
      indent.addScoped(
          "void ${methodPrefix}_${methodName}_async(${asyncArgs.join(', ')}) {",
          '}',
          () {});

      final List<String> finishArgs = <String>[
        '$className* object',
        'GAsyncResult* result'
      ];
      final String returnType =
          _getType(namespace, method.returnType, isOutput: true);
      if (returnType != 'void') {
        finishArgs.add('$returnType* return_value');
      }
      finishArgs.add('GError** error');
      indent.newln();
      indent.addScoped(
          "gboolean ${methodPrefix}_${methodName}_finish(${finishArgs.join(', ')}) {",
          '}', () {
        indent.writeln('return TRUE;');
      });
    }
  }

  @override
  void writeHostApi(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
    const String namespace = 'My';
    final String snakeNamespace = _snakeCaseFromCamelCase(namespace);
    final String className = '$namespace${api.name}';
    final String snakeClassName = _snakeCaseFromCamelCase(api.name);

    final String methodPrefix = '${snakeNamespace}_$snakeClassName';
    final String vtableName = '${className}VTable';

    indent.newln();
    _writeObjectStruct(indent, namespace, api.name, () {});

    indent.newln();
    _writeDefineType(indent, namespace, api.name);

    indent.newln();
    _writeDispose(indent, namespace, api.name, () {
      _writeCastSelf(indent, namespace, api.name);
    });

    indent.newln();
    _writeInit(indent, namespace, api.name, () {});

    indent.newln();
    _writeClassInit(indent, namespace, api.name, () {});

    indent.newln();
    indent.addScoped(
        '$className* ${methodPrefix}_new(FlBinaryMessenger* messenger, const $vtableName* vtable, gpointer user_data, GDestroyNotify user_data_free_func) {',
        '}',
        () {});
  }
}

String _getGuardName(String? headerFileName) {
  const String prefix = 'PIGEON_';
  if (headerFileName != null) {
    return '$prefix${headerFileName.replaceAll('.', '_').toUpperCase()}_';
  } else {
    return '${prefix}H_';
  }
}

void _writeSystemHeaderIncludeBlock(Indent indent, List<String> headers) {
  headers.sort();
  for (final String header in headers) {
    indent.writeln('#include <$header>');
  }
}

void _writeDeclareFinalType(Indent indent, String namespace, String name) {
  final String snakeNamespace = _snakeCaseFromCamelCase(namespace);
  final String upperNamespace = namespace.toUpperCase();
  final String className = '$namespace$name';
  final String snakeClassName = _snakeCaseFromCamelCase(name);
  final String upperSnakeClassName = snakeClassName.toUpperCase();
  final String methodPrefix = '${snakeNamespace}_$snakeClassName';

  indent.writeln(
      'G_DECLARE_FINAL_TYPE($className, $methodPrefix, $upperNamespace, $upperSnakeClassName, GObject)');
}

void _writeDefineType(Indent indent, String namespace, String name) {
  final String snakeNamespace = _snakeCaseFromCamelCase(namespace);
  final String className = '$namespace$name';
  final String snakeClassName = _snakeCaseFromCamelCase(name);
  final String methodPrefix = '${snakeNamespace}_$snakeClassName';

  indent.writeln('G_DEFINE_TYPE($className, $methodPrefix, G_TYPE_OBJECT)');
}

void _writeObjectStruct(
    Indent indent, String namespace, String name, Function func) {
  final String className = '$namespace$name';

  indent.addScoped('struct _$className {', '};', () {
    indent.writeln('GObject parent_instance;');
    indent.newln();

    func(); // ignore: avoid_dynamic_calls
  });
}

void _writeDispose(
    Indent indent, String namespace, String name, Function func) {
  final String snakeNamespace = _snakeCaseFromCamelCase(namespace);
  final String snakeClassName = _snakeCaseFromCamelCase(name);
  final String methodPrefix = '${snakeNamespace}_$snakeClassName';

  indent.addScoped(
      'static void ${methodPrefix}_dispose(GObject *object) {', '}', () {
    func(); // ignore: avoid_dynamic_calls
    indent.writeln(
        'G_OBJECT_CLASS(${methodPrefix}_parent_class)->dispose(object);');
  });
}

void _writeInit(Indent indent, String namespace, String name, Function func) {
  final String snakeNamespace = _snakeCaseFromCamelCase(namespace);
  final String className = '$namespace$name';
  final String snakeClassName = _snakeCaseFromCamelCase(name);
  final String methodPrefix = '${snakeNamespace}_$snakeClassName';

  indent.addScoped('static void ${methodPrefix}_init($className* self) {', '}',
      () {
    func(); // ignore: avoid_dynamic_calls
  });
}

void _writeClassInit(
    Indent indent, String namespace, String name, Function func) {
  final String snakeNamespace = _snakeCaseFromCamelCase(namespace);
  final String className = '$namespace$name';
  final String snakeClassName = _snakeCaseFromCamelCase(name);
  final String methodPrefix = '${snakeNamespace}_$snakeClassName';

  indent.addScoped(
      'static void ${methodPrefix}_class_init(${className}Class* klass) {', '}',
      () {
    indent.writeln('G_OBJECT_CLASS(klass)->dispose = ${methodPrefix}_dispose;');
    func(); // ignore: avoid_dynamic_calls
  });
}

void _writeCastSelf(Indent indent, String namespace, String name) {
  final String snakeNamespace = _snakeCaseFromCamelCase(namespace);
  final String className = '$namespace$name';
  final String snakeClassName = _snakeCaseFromCamelCase(name);
  final String castMacro = '${snakeNamespace}_$snakeClassName'.toUpperCase();

  indent.writeln('$className* self = $castMacro(object);');
}

String _snakeCaseFromCamelCase(String camelCase) {
  return camelCase.replaceAllMapped(RegExp(r'[A-Z]'),
      (Match m) => '${m.start == 0 ? '' : '_'}${m[0]!.toLowerCase()}');
}

String _getType(String namespace, TypeDeclaration type,
    {bool isOutput = false}) {
  if (type.isEnum) {
    return '$namespace${type.baseName}';
  } else if (type.isClass) {
    return '$namespace${type.baseName}*';
  } else if (type.baseName == 'void') {
    return 'void';
  } else if (type.baseName == 'bool') {
    return 'gboolean';
  } else if (type.baseName == 'int') {
    return 'int64_t';
  } else if (type.baseName == 'double') {
    return 'double';
  } else if (type.baseName == 'String') {
    return isOutput ? 'gchar*' : 'const gchar*';
  } else {
    return 'FlValue*';
  }
}
