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
  }

  @override
  void writeFileImports(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.newln();
    final String guardName = _getGuardName(generatorOptions.headerIncludePath);
    indent.writeln('#ifndef $guardName');
    indent.writeln('#define $guardName');

    indent.newln();
    indent.writeln('#include <flutter_linux/flutter_linux.h>');
  }

  @override
  void writeOpenNamespace(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.newln();
    indent.writeln('G_BEGIN_DECLS');
  }

  @override
  void writeEnum(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Enum anEnum, {
    required String dartPackageName,
  }) {
    const String namespace = 'My';
    final String enumName = _getClassName(namespace, anEnum.name);

    indent.newln();
    addDocumentationComments(
        indent, anEnum.documentationComments, _docCommentSpec);
    indent.addScoped('typedef enum {', '} $enumName;', () {
      final List<String> enumValues = <String>[];
      for (int i = 0; i < anEnum.members.length; i++) {
        final EnumMember member = anEnum.members[i];
        final String itemName =
            _getEnumValue(namespace, anEnum.name, member.name);
        enumValues.add('$itemName = $i');
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
    final String className = _getClassName(namespace, classDefinition.name);

    final String methodPrefix =
        _getMethodPrefix(namespace, classDefinition.name);

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
    final String className = _getClassName(namespace, api.name);

    final String methodPrefix = _getMethodPrefix(namespace, api.name);

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
    final String className = _getClassName(namespace, api.name);

    final String methodPrefix = _getMethodPrefix(namespace, api.name);
    final String vtableName = '${className}VTable';

    for (final Method method
        in api.methods.where((Method method) => !method.isAsynchronous)) {
      final String responseName = _getResponseName(api.name, method.name);
      final String responseClassName = _getClassName(namespace, responseName);
      final String responseMethodPrefix =
          _getMethodPrefix(namespace, responseName);

      indent.newln();
      _writeDeclareFinalType(indent, namespace, responseName);

      final String returnType = _getType(namespace, method.returnType);
      indent.newln();
      indent.writeln(
          "$responseClassName* ${responseMethodPrefix}_new($returnType return_value);");

      indent.newln();
      indent.writeln(
          '$responseClassName* ${responseMethodPrefix}_new_error(const gchar* code, const gchar* message, FlValue* details);');
    }

    indent.newln();
    _writeDeclareFinalType(indent, namespace, api.name);

    indent.newln();
    indent.addScoped('typedef struct {', '} $vtableName;', () {
      for (final Method method in api.methods) {
        final String methodName = _snakeCaseFromCamelCase(method.name);
        final String responseName = _getResponseName(api.name, method.name);
        final String responseClassName = _getClassName(namespace, responseName);

        final List<String> methodArgs = <String>['$className* object'];
        for (final Parameter param in method.parameters) {
          final String paramName = _snakeCaseFromCamelCase(param.name);
          final String paramType = _getType(namespace, param.type);
          methodArgs.add('$paramType $paramName');
        }
        final String returnType;
        if (method.isAsynchronous) {
          methodArgs
              .add('FlBasicMessageChannelResponseHandle* response_handle');
          returnType = 'void';
        } else {
          returnType = '$responseClassName*';
        }
        methodArgs.add('gpointer user_data');
        indent.writeln("$returnType (*$methodName)(${methodArgs.join(', ')});");
      }
    });

    indent.newln();
    indent.writeln(
        '$className* ${methodPrefix}_new(FlBinaryMessenger* messenger, const $vtableName* vtable, gpointer user_data, GDestroyNotify user_data_free_func);');

    for (final Method method
        in api.methods.where((Method method) => method.isAsynchronous)) {
      final String methodName = _snakeCaseFromCamelCase(method.name);
      final String returnType = _getType(namespace, method.returnType);

      indent.newln();
      final List<String> respondArgs = <String>[
        '$className* self',
        'FlBasicMessageChannelResponseHandle* response_handle',
        '$returnType return_value'
      ];
      indent.writeln(
          "void ${methodPrefix}_respond_$methodName(${respondArgs.join(', ')});");

      indent.newln();
      final List<String> respondErrorArgs = <String>[
        '$className* self',
        'FlBasicMessageChannelResponseHandle* response_handle',
        'const gchar* code',
        'const gchar* message',
        'FlValue* details'
      ];
      indent.writeln(
          "void ${methodPrefix}_respond_error_$methodName(${respondErrorArgs.join(', ')});");
    }
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
    final String className = _getClassName(namespace, classDefinition.name);
    final String snakeClassName = _snakeCaseFromCamelCase(classDefinition.name);

    final String methodPrefix =
        _getMethodPrefix(namespace, classDefinition.name);
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
      bool haveSelf = false;
      for (final NamedType field in classDefinition.fields) {
        final String fieldName = _snakeCaseFromCamelCase(field.name);
        final String? clear = _getClear(field, 'self->$fieldName');
        if (clear != null) {
          if (!haveSelf) {
            _writeCastSelf(indent, namespace, classDefinition.name, 'object');
            haveSelf = true;
          }
          indent.writeln('$clear;');
        }
      }
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
    indent.newln();
    indent.addScoped(
        "$className* ${methodPrefix}_new(${constructorArgs.join(', ')}) {", '}',
        () {
      _writeObjectNew(indent, namespace, classDefinition.name);
      for (final NamedType field in classDefinition.fields) {
        final String fieldName = _snakeCaseFromCamelCase(field.name);
        final String value = _referenceValue(field, fieldName);

        indent.writeln('self->$fieldName = $value;');
      }
      indent.writeln('return self;');
    });

    for (final NamedType field in classDefinition.fields) {
      final String fieldName = _snakeCaseFromCamelCase(field.name);
      final String returnType = _getType(namespace, field.type);

      indent.newln();
      indent.addScoped(
          '$returnType ${methodPrefix}_get_$fieldName($className* self) {', '}',
          () {
        indent.writeln(
            'g_return_val_if_fail($testMacro(self), ${_getDefaultValue(namespace, field.type)});');
        indent.writeln('return self->$fieldName;');
      });
    }

    indent.newln();
    indent.addScoped(
        'static FlValue* ${methodPrefix}_to_list($className* self) {', '}', () {
      indent.writeln('FlValue* values = fl_value_new_list();');
      for (final NamedType field in classDefinition.fields) {
        final String fieldName = _snakeCaseFromCamelCase(field.name);
        indent.writeln(
            'fl_value_append_take(values, ${_makeFlValue(namespace, field.type, 'self->$fieldName')});');
      }
      indent.writeln('return values;');
    });

    indent.newln();
    indent.addScoped(
        'static $className* ${methodPrefix}_new_from_list(FlValue* values) {',
        '}', () {
      final List<String> checks = <String>[
        'fl_value_get_type(values) != FL_VALUE_TYPE_LIST'
      ];
      for (int i = 0; i < classDefinition.fields.length; i++) {
        final NamedType field = classDefinition.fields[i];
        checks.add(
            'fl_value_get_type(fl_value_get_list_value(values, $i)) != ${_getFlValueType(field.type)}');
      }
      indent.addScoped("if (${checks.join(' || ')}) {", '}', () {
        indent.writeln('return nullptr;');
      });
      indent.newln();
      final List<String> args = <String>[];
      for (int i = 0; i < classDefinition.fields.length; i++) {
        final NamedType field = classDefinition.fields[i];
        args.add(_fromFlValue(
            namespace, field.type, 'fl_value_get_list_value(values, $i)'));
      }
      indent.writeln('return ${methodPrefix}_new(${args.join(', ')});');
    });
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
    final String className = _getClassName(namespace, api.name);

    final String methodPrefix = _getMethodPrefix(namespace, api.name);

    indent.newln();
    _writeObjectStruct(indent, namespace, api.name, () {
      indent.writeln('FlBinaryMessenger* messenger;');
    });

    indent.newln();
    _writeDefineType(indent, namespace, api.name);

    indent.newln();
    _writeDispose(indent, namespace, api.name, () {
      _writeCastSelf(indent, namespace, api.name, 'object');
      indent.writeln('g_clear_object(&self->messenger);');
    });

    indent.newln();
    _writeInit(indent, namespace, api.name, () {});

    indent.newln();
    _writeClassInit(indent, namespace, api.name, () {});

    indent.newln();
    indent.addScoped(
        '$className* ${methodPrefix}_new(FlBinaryMessenger* messenger) {', '}',
        () {
      _writeObjectNew(indent, namespace, api.name);
      indent.writeln('self->messenger = g_object_ref(messenger);');
      indent.writeln('return self;');
    });

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
    final String className = _getClassName(namespace, api.name);

    final String methodPrefix = _getMethodPrefix(namespace, api.name);
    final String vtableName = '${className}VTable';

    final String codecName = '${api.name}Codec';
    final String codecClassName = _getClassName(namespace, codecName);
    final String codecMethodPrefix = '${methodPrefix}_codec';

    indent.newln();
    _writeDeclareFinalType(indent, namespace, codecName,
        parentClassName: 'FlStandardMessageCodec');

    indent.newln();
    _writeObjectStruct(indent, namespace, codecName, () {},
        parentClassName: 'FlStandardMessageCodec');

    indent.newln();
    _writeDefineType(indent, namespace, codecName,
        parentType: 'fl_standard_message_codec_get_type()');

    for (final EnumeratedClass customClass in getCodecClasses(api, root)) {
      final String customClassName = _getClassName(namespace, customClass.name);
      final String snakeCustomClassName =
          _snakeCaseFromCamelCase(customClassName);
      indent.newln();
      indent.addScoped(
          'static gboolean write_${snakeCustomClassName}(FlStandardMessageCodec* codec, GByteArray* buffer, $customClassName* value, GError** error) {',
          '}', () {
        indent.writeln('uint8_t type = ${customClass.enumeration};');
        indent.writeln('g_byte_array_append(buffer, &type, sizeof(uint8_t));');
        indent.writeln(
            'g_autoptr(FlValue) values = ${snakeCustomClassName}_to_list(value);');
        indent.writeln(
            'return fl_standard_message_codec_write_value(codec, buffer, values, error);');
      });
    }

    indent.newln();
    indent.addScoped(
        'static gboolean ${methodPrefix}_write_value(FlStandardMessageCodec* codec, GByteArray* buffer, FlValue* value, GError** error) {',
        '}', () {
      indent.addScoped(
          'if (fl_value_get_type(value) == FL_VALUE_TYPE_CUSTOM) {', '}', () {
        indent.addScoped('switch (fl_value_get_custom_type(value)) {', '}', () {
          for (final EnumeratedClass customClass
              in getCodecClasses(api, root)) {
            indent.writeln('case ${customClass.enumeration}:');
            indent.nest(1, () {
              final String snakeNamespace = _snakeCaseFromCamelCase(namespace);
              final String snakeClassName =
                  _snakeCaseFromCamelCase(customClass.name);
              final String castMacro =
                  _getClassCastMacro(namespace, customClass.name);
              indent.writeln(
                  'return write_${snakeNamespace}_${snakeClassName}(codec, buffer, $castMacro(fl_value_get_custom_value_object(value)), error);');
            });
          }
        });
      });

      indent.newln();
      indent.writeln(
          'return FL_STANDARD_MESSAGE_CODEC_CLASS(${codecMethodPrefix}_parent_class)->write_value(codec, buffer, value, error);');
    });

    for (final EnumeratedClass customClass in getCodecClasses(api, root)) {
      final String customClassName = _getClassName(namespace, customClass.name);
      final String snakeCustomClassName =
          _snakeCaseFromCamelCase(customClassName);
      indent.newln();
      indent.addScoped(
          'static FlValue* read_${snakeCustomClassName}(FlStandardMessageCodec* codec, GBytes* buffer, size_t* offset, GError** error) {',
          '}', () {
        indent.writeln(
            'g_autoptr(FlValue) values = fl_standard_message_codec_read_value(codec, buffer, offset, error);');
        indent.addScoped('if (values == nullptr) {', '}', () {
          indent.writeln('return nullptr;');
        });
        indent.newln();
        indent.writeln(
            'g_autoptr($customClassName) value = ${snakeCustomClassName}_new_from_list(values);');
        indent.addScoped('if (value == nullptr) {', '}', () {
          indent.writeln(
              'g_set_error(error, FL_MESSAGE_CODEC_ERROR, FL_MESSAGE_CODEC_ERROR_FAILED, "Invalid data received for MessageData");');
          indent.writeln('return nullptr;');
        });
        indent.newln();
        indent.writeln(
            'return fl_value_new_custom_object_take(${customClass.enumeration}, G_OBJECT(value));');
      });
    }

    indent.newln();
    indent.addScoped(
        'static FlValue* ${methodPrefix}_read_value_of_type(FlStandardMessageCodec* codec, GBytes* buffer, size_t* offset, int type, GError** error) {',
        '}', () {
      indent.addScoped('switch (type) {', '}', () {
        for (final EnumeratedClass customClass in getCodecClasses(api, root)) {
          final String snakeNamespace = _snakeCaseFromCamelCase(namespace);
          final String snakeClassName =
              _snakeCaseFromCamelCase(customClass.name);
          indent.writeln('case ${customClass.enumeration}:');
          indent.nest(1, () {
            indent.writeln(
                'return read_${snakeNamespace}_${snakeClassName}(codec, buffer, offset, error);');
          });
        }

        indent.writeln('default:');
        indent.nest(1, () {
          indent.writeln(
              'return FL_STANDARD_MESSAGE_CODEC_CLASS(${codecMethodPrefix}_parent_class)->read_value_of_type(codec, buffer, offset, type, error);');
        });
      });
    });

    indent.newln();
    _writeInit(indent, namespace, codecName, () {});

    indent.newln();
    _writeClassInit(indent, namespace, codecName, () {
      indent.writeln(
          'FL_STANDARD_MESSAGE_CODEC_CLASS(klass)->write_value = ${methodPrefix}_write_value;');
      indent.writeln(
          'FL_STANDARD_MESSAGE_CODEC_CLASS(klass)->read_value_of_type = ${methodPrefix}_read_value_of_type;');
    }, hasDispose: false);

    indent.newln();
    indent.addScoped(
        'static $codecClassName* ${codecMethodPrefix}_new() {', '}', () {
      _writeObjectNew(indent, namespace, codecName);
      indent.writeln('return self;');
    });

    for (final Method method in api.methods) {
      final String responseName = _getResponseName(api.name, method.name);
      final String responseClassName = _getClassName(namespace, responseName);
      final String responseMethodPrefix =
          _getMethodPrefix(namespace, responseName);

      if (method.isAsynchronous) {
        indent.newln();
        _writeDeclareFinalType(indent, namespace, responseName);
      }

      indent.newln();
      _writeObjectStruct(indent, namespace, responseName, () {
        indent.writeln('FlValue* value;');
      });

      indent.newln();
      _writeDefineType(indent, namespace, responseName);

      indent.newln();
      _writeDispose(indent, namespace, responseName, () {
        _writeCastSelf(indent, namespace, responseName, 'object');
        indent.writeln('g_clear_pointer(&self->value, fl_value_unref);');
      });

      indent.newln();
      _writeInit(indent, namespace, responseName, () {});

      indent.newln();
      _writeClassInit(indent, namespace, responseName, () {});

      final String returnType = _getType(namespace, method.returnType);
      indent.newln();
      indent.addScoped(
          "${method.isAsynchronous ? 'static ' : ''}$responseClassName* ${responseMethodPrefix}_new($returnType return_value) {",
          '}', () {
        _writeObjectNew(indent, namespace, responseName);
        indent.writeln('self->value = fl_value_new_list();');
        indent.writeln(
            "fl_value_append_take(self->value, ${_makeFlValue(namespace, method.returnType, 'return_value')});");
        indent.writeln('return self;');
      });

      indent.newln();
      indent.addScoped(
          '${method.isAsynchronous ? 'static ' : ''}$responseClassName* ${responseMethodPrefix}_new_error(const gchar* code, const gchar* message, FlValue* details) {',
          '}', () {
        _writeObjectNew(indent, namespace, responseName);
        indent.writeln('self->value = fl_value_new_list();');
        indent.writeln(
            'fl_value_append_take(self->value, fl_value_new_string(code));');
        indent.writeln(
            'fl_value_append_take(self->value, fl_value_new_string(message));');
        indent.writeln('fl_value_append(self->value, details);');
        indent.writeln('return self;');
      });
    }

    indent.newln();
    _writeObjectStruct(indent, namespace, api.name, () {
      indent.writeln('FlBinaryMessenger* messenger;');
      indent.writeln('const ${className}VTable* vtable;');
      indent.writeln('gpointer user_data;');
      indent.writeln('GDestroyNotify user_data_free_func;');

      indent.newln();
      for (final Method method in api.methods) {
        final String methodName = _snakeCaseFromCamelCase(method.name);
        indent.writeln('FlBasicMessageChannel* ${methodName}_channel;');
      }
    });

    indent.newln();
    _writeDefineType(indent, namespace, api.name);

    for (final Method method in api.methods) {
      final String methodName = _snakeCaseFromCamelCase(method.name);
      final String responseName = _getResponseName(api.name, method.name);
      final String responseClassName = _getClassName(namespace, responseName);

      indent.newln();
      indent.addScoped(
          'static void ${methodName}_cb(FlBasicMessageChannel* channel, FlValue* message, FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {',
          '}', () {
        _writeCastSelf(indent, namespace, api.name, 'user_data');

        indent.newln();
        indent.addScoped(
            'if (self->vtable == nullptr || self->vtable->$methodName == nullptr) {',
            '}', () {
          indent.writeln('return;');
        });

        final List<String> checks = <String>[];
        final List<String> methodArgs = <String>[];
        if (method.parameters.isEmpty) {
          checks.add('fl_value_get_type(message) != FL_VALUE_TYPE_NULL');
        } else {
          checks.add('fl_value_get_type(message) != FL_VALUE_TYPE_LIST');
          checks.add(
              'fl_value_get_length(message) != ${method.parameters.length}');
          for (int i = 0; i < method.parameters.length; i++) {
            final Parameter param = method.parameters[i];
            checks.add(
                'fl_value_get_type(fl_value_get_list_value(message, $i)) != ${_getFlValueType(param.type)}');
            methodArgs.add(_fromFlValue(
                namespace, param.type, 'fl_value_get_list_value(message, $i)'));
          }
        }

        indent.newln();
        indent.addScoped("if (${checks.join(' || ')}) {", '}', () {
          indent.writeln('return;');
        });

        indent.newln();
        if (method.isAsynchronous) {
          final List<String> vfuncArgs = <String>['self'];
          vfuncArgs.addAll(methodArgs);
          vfuncArgs.addAll(['response_handle', 'self->user_data']);
          indent.writeln("self->vtable->$methodName(${vfuncArgs.join(', ')});");
        } else {
          final List<String> vfuncArgs = <String>['self'];
          vfuncArgs.addAll(methodArgs);
          vfuncArgs.add('self->user_data');
          indent.writeln(
              "g_autoptr($responseClassName) response = self->vtable->$methodName(${vfuncArgs.join(', ')});");
          indent.addScoped('if (response == nullptr) {', '}', () {
            indent.writeln(
                'g_warning("No response returned to ${api.name}.${method.name}");');
            indent.writeln('return;');
          });

          indent.newln();
          indent.writeln('g_autoptr(GError) error = NULL;');
          indent.addScoped(
              'if (!fl_basic_message_channel_respond(channel, response_handle, response->value, &error)) {',
              '}', () {
            indent.writeln(
                'g_warning("Failed to send response to ${api.name}.${method.name}: %s", error->message);');
          });
        }
      });
    }

    indent.newln();
    _writeDispose(indent, namespace, api.name, () {
      _writeCastSelf(indent, namespace, api.name, 'object');
      indent.writeln('g_clear_object(&self->messenger);');
      indent.addScoped('if (self->user_data != nullptr) {', '}', () {
        indent.writeln('self->user_data_free_func(self->user_data);');
      });
      indent.writeln('self->user_data = nullptr;');

      indent.newln();
      for (final Method method in api.methods) {
        final String methodName = _snakeCaseFromCamelCase(method.name);
        indent.writeln('g_clear_object(&self->${methodName}_channel);');
      }
    });

    indent.newln();
    _writeInit(indent, namespace, api.name, () {});

    indent.newln();
    _writeClassInit(indent, namespace, api.name, () {});

    indent.newln();
    indent.addScoped(
        '$className* ${methodPrefix}_new(FlBinaryMessenger* messenger, const $vtableName* vtable, gpointer user_data, GDestroyNotify user_data_free_func) {',
        '}', () {
      _writeObjectNew(indent, namespace, api.name);
      indent.writeln('self->messenger = g_object_ref(messenger);');
      indent.writeln('self->vtable = vtable;');
      indent.writeln('self->user_data = user_data;');
      indent.writeln('self->user_data_free_func = user_data_free_func;');

      indent.newln();
      indent.writeln(
          'g_autoptr($codecClassName) codec = ${codecMethodPrefix}_new();');
      for (final Method method in api.methods) {
        final String methodName = _snakeCaseFromCamelCase(method.name);
        final String channelName =
            makeChannelName(api, method, dartPackageName);
        indent.writeln(
            'self->${methodName}_channel = fl_basic_message_channel_new(messenger, "$channelName", FL_MESSAGE_CODEC(codec));');
        indent.writeln(
            'fl_basic_message_channel_set_message_handler(self->${methodName}_channel, ${methodName}_cb, self, nullptr);');
      }

      indent.newln();
      indent.writeln('return self;');
    });

    for (final Method method
        in api.methods.where((Method method) => method.isAsynchronous)) {
      final String returnType = _getType(namespace, method.returnType);
      final String methodName = _snakeCaseFromCamelCase(method.name);
      final String responseName = _getResponseName(api.name, method.name);
      final String responseClassName = _getClassName(namespace, responseName);
      final String responseMethodPrefix =
          _getMethodPrefix(namespace, responseName);

      indent.newln();
      final List<String> respondArgs = <String>[
        '$className* self',
        'FlBasicMessageChannelResponseHandle* response_handle',
        '$returnType return_value'
      ];
      indent.addScoped(
          "void ${methodPrefix}_respond_$methodName(${respondArgs.join(', ')}) {",
          '}', () {
        indent.writeln(
            'g_autoptr($responseClassName) response = ${responseMethodPrefix}_new(return_value);');
        indent.writeln('g_autoptr(GError) error = nullptr;');
        indent.addScoped(
            'if (!fl_basic_message_channel_respond(self->${methodName}_channel, response_handle, response->value, &error)) {',
            '}', () {
          indent.writeln(
              'g_warning("Failed to send response to ${api.name}.${method.name}: %s", error->message);');
        });
      });

      indent.newln();
      final List<String> respondErrorArgs = <String>[
        '$className* self',
        'FlBasicMessageChannelResponseHandle* response_handle',
        'const gchar* code',
        'const gchar* message',
        'FlValue* details'
      ];
      indent.addScoped(
          "void ${methodPrefix}_respond_error_$methodName(${respondErrorArgs.join(', ')}) {",
          '}', () {
        indent.writeln(
            'g_autoptr($responseClassName) response = ${responseMethodPrefix}_new_error(code, message, details);');
        indent.writeln('g_autoptr(GError) error = nullptr;');
        indent.addScoped(
            'if (!fl_basic_message_channel_respond(self->${methodName}_channel, response_handle, response->value, &error)) {',
            '}', () {
          indent.writeln(
              'g_warning("Failed to send response to ${api.name}.${method.name}: %s", error->message);');
        });
      });
    }
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

void _writeDeclareFinalType(Indent indent, String namespace, String name,
    {String parentClassName = 'GObject'}) {
  final String upperNamespace = namespace.toUpperCase();
  final String className = _getClassName(namespace, name);
  final String snakeClassName = _snakeCaseFromCamelCase(name);
  final String upperSnakeClassName = snakeClassName.toUpperCase();
  final String methodPrefix = _getMethodPrefix(namespace, name);

  indent.writeln(
      'G_DECLARE_FINAL_TYPE($className, $methodPrefix, $upperNamespace, $upperSnakeClassName, $parentClassName)');
}

void _writeDefineType(Indent indent, String namespace, String name,
    {String parentType = 'G_TYPE_OBJECT'}) {
  final String className = _getClassName(namespace, name);
  final String methodPrefix = _getMethodPrefix(namespace, name);

  indent.writeln('G_DEFINE_TYPE($className, $methodPrefix, $parentType)');
}

void _writeObjectStruct(
    Indent indent, String namespace, String name, Function func,
    {String parentClassName = 'GObject'}) {
  final String className = _getClassName(namespace, name);

  indent.addScoped('struct _$className {', '};', () {
    indent.writeln('$parentClassName parent_instance;');
    indent.newln();

    func(); // ignore: avoid_dynamic_calls
  });
}

void _writeDispose(
    Indent indent, String namespace, String name, Function func) {
  final String methodPrefix = _getMethodPrefix(namespace, name);

  indent.addScoped(
      'static void ${methodPrefix}_dispose(GObject *object) {', '}', () {
    func(); // ignore: avoid_dynamic_calls
    indent.writeln(
        'G_OBJECT_CLASS(${methodPrefix}_parent_class)->dispose(object);');
  });
}

void _writeInit(Indent indent, String namespace, String name, Function func) {
  final String className = _getClassName(namespace, name);
  final String methodPrefix = _getMethodPrefix(namespace, name);

  indent.addScoped('static void ${methodPrefix}_init($className* self) {', '}',
      () {
    func(); // ignore: avoid_dynamic_calls
  });
}

void _writeClassInit(
    Indent indent, String namespace, String name, Function func,
    {bool hasDispose = true}) {
  final String className = _getClassName(namespace, name);
  final String methodPrefix = _getMethodPrefix(namespace, name);

  indent.addScoped(
      'static void ${methodPrefix}_class_init(${className}Class* klass) {', '}',
      () {
    if (hasDispose) {
      indent
          .writeln('G_OBJECT_CLASS(klass)->dispose = ${methodPrefix}_dispose;');
    }
    func(); // ignore: avoid_dynamic_calls
  });
}

void _writeObjectNew(Indent indent, String namespace, String name) {
  final String className = _getClassName(namespace, name);
  final String methodPrefix = _getMethodPrefix(namespace, name);
  final String castMacro = _getClassCastMacro(namespace, name);

  indent.writeln(
      '$className* self = $castMacro(g_object_new(${methodPrefix}_get_type(), nullptr));');
}

void _writeCastSelf(
    Indent indent, String namespace, String name, String variableName) {
  final String className = _getClassName(namespace, name);
  final String castMacro = _getClassCastMacro(namespace, name);
  indent.writeln('$className* self = $castMacro($variableName);');
}

String _snakeCaseFromCamelCase(String camelCase) {
  return camelCase.replaceAllMapped(RegExp(r'[A-Z]'),
      (Match m) => '${m.start == 0 ? '' : '_'}${m[0]!.toLowerCase()}');
}

String _getClassName(String namespace, String name) {
  return '$namespace$name';
}

String _getClassCastMacro(String namespace, String name) {
  final String snakeNamespace = _snakeCaseFromCamelCase(namespace);
  final String className = _getClassName(namespace, name);
  final String snakeClassName = _snakeCaseFromCamelCase(name);
  return '${snakeNamespace}_$snakeClassName'.toUpperCase();
}

String _getResponseName(String name, String methodName) {
  final String upperMethodName =
      methodName[0].toUpperCase() + methodName.substring(1);
  return '$name${upperMethodName}Response';
}

String _getMethodPrefix(String namespace, String name) {
  final String snakeNamespace = _snakeCaseFromCamelCase(namespace);
  final String snakeName = _snakeCaseFromCamelCase(name);
  return '${snakeNamespace}_$snakeName';
}

String _getEnumValue(String namespace, String enumName, String memberName) {
  final String snakeEnumName = _snakeCaseFromCamelCase(enumName);
  final String snakeMemberName = _snakeCaseFromCamelCase(memberName);
  return '${namespace}_${snakeEnumName}_$snakeMemberName'.toUpperCase();
}

String _getType(String namespace, TypeDeclaration type,
    {bool isOutput = false}) {
  if (type.isClass) {
    return '${_getClassName(namespace, type.baseName)}*';
  } else if (type.isEnum) {
    return _getClassName(namespace, type.baseName);
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
  } else if (type.baseName == 'Map') {
    return 'FlValue*';
  } else {
    throw Exception('Unknown type ${type.baseName}');
  }
}

String _getLocalType(String namespace, TypeDeclaration type) {
  if (type.isEnum ||
      type.baseName == 'void' ||
      type.baseName == 'bool' ||
      type.baseName == 'int' ||
      type.baseName == 'double') {
    return _getType(namespace, type);
  } else if (type.isClass) {
    return 'g_autoptr(${_getClassName(namespace, type.baseName)})';
  } else if (type.baseName == 'List' || type.baseName == 'Map') {
    return 'g_autoptr(FlValue)';
  } else if (type.baseName == 'String') {
    return 'g_autofree gchar*';
  } else {
    throw Exception('Unknown type ${type.baseName}');
  }
}

String? _getClear(NamedType namedType, String variableName) {
  final TypeDeclaration type = namedType.type;

  if (type.isClass) {
    return 'g_clear_object(&$variableName)';
  } else if (type.baseName == 'List' || type.baseName == 'Map') {
    return 'g_clear_pointer(&$variableName, fl_value_unref)';
  } else if (type.baseName == 'String') {
    return 'g_clear_pointer(&$variableName, g_free)';
  } else {
    return null;
  }
}

String _getDefaultValue(String namespace, TypeDeclaration type) {
  if (type.isClass) {
    return 'nullptr';
  } else if (type.isEnum) {
    final String enumName = _getClassName(namespace, type.baseName);
    return 'static_cast<$enumName>(0)';
  } else if (type.baseName == 'List' || type.baseName == 'Map') {
    return 'nullptr';
  } else if (type.baseName == 'void') {
    return '';
  } else if (type.baseName == 'bool') {
    return 'FALSE';
  } else if (type.baseName == 'int') {
    return '0';
  } else if (type.baseName == 'double') {
    return '0.0';
  } else if (type.baseName == 'String') {
    return 'nullptr';
  } else {
    throw Exception('Unknown type ${type.baseName}');
  }
}

String _referenceValue(NamedType namedType, String variableName) {
  final TypeDeclaration type = namedType.type;

  if (type.isClass || type.baseName == 'List' || type.baseName == 'Map') {
    return 'g_object_ref($variableName)';
  } else if (type.baseName == 'String') {
    return 'g_strdup($variableName)';
  } else {
    return variableName;
  }
}

String _makeFlValue(
    String namespace, TypeDeclaration type, String variableName) {
  if (type.isClass) {
    return 'fl_value_new_custom_object(0, G_OBJECT($variableName))';
  } else if (type.isEnum) {
    return 'fl_value_new_int($variableName)';
  } else if (type.baseName == 'List' || type.baseName == 'Map') {
    return 'fl_value_ref($variableName)';
  } else if (type.baseName == 'bool') {
    return 'fl_value_new_bool($variableName)';
  } else if (type.baseName == 'int') {
    return 'fl_value_new_int($variableName)';
  } else if (type.baseName == 'double') {
    return 'fl_value_new_double($variableName)';
  } else if (type.baseName == 'String') {
    return 'fl_value_new_string($variableName)';
  } else {
    throw Exception('Unknown type ${type.baseName}');
  }
}

String _fromFlValue(
    String namespace, TypeDeclaration type, String variableName) {
  if (type.isClass) {
    final String castMacro = _getClassCastMacro(namespace, type.baseName);
    return '$castMacro(fl_value_get_custom_value_object($variableName))';
  } else if (type.isEnum) {
    final String enumName = _getClassName(namespace, type.baseName);
    return 'static_cast<$enumName>(fl_value_get_int($variableName))';
  } else if (type.baseName == 'List' || type.baseName == 'Map') {
    return variableName;
  } else if (type.baseName == 'bool') {
    return 'fl_value_get_bool($variableName)';
  } else if (type.baseName == 'int') {
    return 'fl_value_get_int($variableName)';
  } else if (type.baseName == 'double') {
    return 'fl_value_get_double($variableName)';
  } else if (type.baseName == 'String') {
    return 'fl_value_get_string($variableName)';
  } else {
    throw Exception('Unknown type ${type.baseName}');
  }
}

String _getFlValueType(TypeDeclaration type) {
  if (type.isClass) {
    return 'FL_VALUE_TYPE_CUSTOM';
  } else if (type.isEnum) {
    return 'FL_VALUE_TYPE_INT';
  } else if (type.baseName == 'List') {
    return 'FL_VALUE_TYPE_LIST';
  } else if (type.baseName == 'Map') {
    return 'FL_VALUE_TYPE_MAP';
  } else if (type.baseName == 'bool') {
    return 'FL_VALUE_TYPE_BOOL';
  } else if (type.baseName == 'int') {
    return 'FL_VALUE_TYPE_INT';
  } else if (type.baseName == 'double') {
    return 'FL_VALUE_TYPE_DOUBLE';
  } else if (type.baseName == 'String') {
    return 'FL_VALUE_TYPE_STRING';
  } else {
    throw Exception('Unknown type ${type.baseName}');
  }
}
