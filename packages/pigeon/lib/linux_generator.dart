// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'functional.dart';
import 'generator.dart';
import 'generator_tools.dart';
import 'pigeon_lib.dart' show Error;

/// General comment opening token.
const String _commentPrefix = '//';

const String _voidType = 'void';

/// Documentation comment spec.
const DocumentCommentSpecification _docCommentSpec =
    DocumentCommentSpecification(_commentPrefix);

const String _defaultCodecSerializer = 'flutter::StandardCodecSerializer';

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
    var namespace = 'My';
    var enumName = '${namespace}${anEnum.name}';
    var snakeEnumName = _snakeCaseFromCamelCase(anEnum.name);
    var upperSnakeEnumName = '${namespace}_${snakeEnumName}'.toUpperCase();

    indent.newln();
    addDocumentationComments(
        indent, anEnum.documentationComments, _docCommentSpec);
    indent.addScoped('typedef enum {', '} ${enumName};', () {
      var enumValues = <String>[];
      for (var i = 0; i < anEnum.members.length; i++) {
        var member = anEnum.members[i];
        var itemName = _snakeCaseFromCamelCase(member.name).toUpperCase();
        enumValues.add('${upperSnakeEnumName}_${itemName} = $i');
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
    var namespace = 'My';
    var snakeNamespace = _snakeCaseFromCamelCase(namespace);
    var upperNamespace = namespace.toUpperCase();
    var className = '${namespace}${classDefinition.name}';
    var snakeClassName = _snakeCaseFromCamelCase(classDefinition.name);
    var upperSnakeClassName = snakeClassName.toUpperCase();

    var methodPrefix = '${snakeNamespace}_${snakeClassName}';

    indent.newln();
    indent.writeln(
        'G_DECLARE_FINAL_TYPE(${className}, ${methodPrefix}, ${upperNamespace}, ${upperSnakeClassName}, GObject)');
    indent.newln();
    var constructorArgs = <String>[];
    for (var field in classDefinition.fields) {
      var fieldName = _snakeCaseFromCamelCase(field.name);
      var type = _getType(field.type);
      constructorArgs.add('$type $fieldName');
    }
    indent.writeln(
        "${className}* ${methodPrefix}_new(${constructorArgs.join(', ')});");

    for (var field in classDefinition.fields) {
      var fieldName = _snakeCaseFromCamelCase(field.name);
      var returnType = _getType(field.type);

      indent.newln();
      indent.writeln(
          '${returnType} ${methodPrefix}_get_${fieldName}(${className}* object);');
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
    var namespace = 'My';
    var snakeNamespace = _snakeCaseFromCamelCase(namespace);
    var upperNamespace = namespace.toUpperCase();
    var className = '${namespace}${api.name}';
    var snakeClassName = _snakeCaseFromCamelCase(api.name);
    var upperSnakeClassName = snakeClassName.toUpperCase();

    var methodPrefix = '${snakeNamespace}_${snakeClassName}';

    indent.newln();
    indent.writeln(
        'G_DECLARE_FINAL_TYPE(${className}, ${methodPrefix}, ${upperNamespace}, ${upperSnakeClassName}, GObject)');
    indent.newln();
    indent.writeln(
        '${className}* ${methodPrefix}_new(FlBinaryMessenger* messenger);');

    for (var method in api.methods) {
      var methodName = _snakeCaseFromCamelCase(method.name);

      var asyncArgs = ['${className}* object'];
      for (var param in method.parameters) {
        var paramName = _snakeCaseFromCamelCase(param.name);
        var paramType = _getType(param.type);
        asyncArgs.add('${paramType} ${paramName}');
      }
      asyncArgs.addAll([
        'GCancellable* cancellable',
        'GAsyncReadyCallback callback',
        'gpointer user_data'
      ]);
      indent.newln();
      indent.writeln(
          "void ${methodPrefix}_${methodName}_async(${asyncArgs.join(', ')});");

      var finishArgs = ['${className}* object', 'GAsyncResult* result'];
      var returnType = _getType(method.returnType, isOutput: true);
      if (returnType != 'void') {
        finishArgs.add('${returnType}* return_value');
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
    var namespace = 'My';
    var snakeNamespace = _snakeCaseFromCamelCase(namespace);
    var upperNamespace = namespace.toUpperCase();
    var className = '${namespace}${api.name}';
    var snakeClassName = _snakeCaseFromCamelCase(api.name);
    var upperSnakeClassName = snakeClassName.toUpperCase();

    var methodPrefix = '${snakeNamespace}_${snakeClassName}';
    var vtableName = '${className}VTable';

    indent.newln();
    indent.writeln(
        'G_DECLARE_FINAL_TYPE(${className}, ${methodPrefix}, ${upperNamespace}, ${upperSnakeClassName}, GObject)');
    indent.newln();
    indent.addScoped('typedef struct {', '} ${vtableName};', () {
      for (var method in api.methods) {
        var methodName = _snakeCaseFromCamelCase(method.name);

        var methodArgs = ['${className}* object'];
        for (var param in method.parameters) {
          var paramName = _snakeCaseFromCamelCase(param.name);
          var paramType = _getType(param.type);
          methodArgs.add('${paramType} ${paramName}');
        }
        if (method.isAsynchronous) {
          // FIXME: Pass handle
        } else {
          var returnType = _getType(method.returnType, isOutput: true);
          if (returnType != 'void') {
            methodArgs.add('${returnType}* return_value');
          }
          methodArgs.add('GError** error');
        }
        methodArgs.add('gpointer user_data');
        indent.writeln("gboolean (*${methodName})(${methodArgs.join(', ')});");
      }
    });
    indent.newln();
    indent.writeln(
        '${className}* ${methodPrefix}_new(FlBinaryMessenger* messenger, const ${vtableName}* vtable, gpointer user_data, GDestroyNotify user_data_free_func);');
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
    indent.newln();
  }

  @override
  void writeFileImports(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.writeln('#include "${generatorOptions.headerIncludePath}"');
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
  }) {}

  @override
  void writeGeneralUtilities(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {}

  @override
  void writeDataClass(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {}

  @override
  void writeClassEncode(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefintion, {
    required String dartPackageName,
  }) {}

  @override
  void writeClassDecode(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {}

  @override
  void writeFlutterApi(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {}

  @override
  void writeHostApi(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {}
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

String _snakeCaseFromCamelCase(String camelCase) {
  return camelCase.replaceAllMapped(RegExp(r'[A-Z]'),
      (Match m) => '${m.start == 0 ? '' : '_'}${m[0]!.toLowerCase()}');
}

String _getType(TypeDeclaration type, {bool isOutput = false}) {
  var namespace = 'My';

  if (type.isEnum) {
    return '${namespace}${type.baseName}';
  } else if (type.isClass) {
    return '${namespace}${type.baseName}*';
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
