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
    this.copyrightHeader,
    this.headerOutPath,
  });

  /// The path to the header that will get placed in the source filed (example:
  /// "foo.h").
  final String? headerIncludePath;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// The path to the output header file location.
  final String? headerOutPath;

  /// Creates a [LinuxOptions] from a Map representation where:
  /// `x = LinuxOptions.fromMap(x.toMap())`.
  static LinuxOptions fromMap(Map<String, Object> map) {
    return LinuxOptions(
      headerIncludePath: map['header'] as String?,
      copyrightHeader: map['copyrightHeader'] as Iterable<String>?,
      headerOutPath: map['linuxHeaderOut'] as String?,
    );
  }

  /// Converts a [LinuxOptions] to a Map representation where:
  /// `x = LinuxOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (headerIncludePath != null) 'header': headerIncludePath!,
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
    indent.writeln('$_commentPrefix Generated class from Pigeon.');
  }

  @override
  void writeEnum(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Enum anEnum, {
    required String dartPackageName,
  }) {
    indent.newln();
    addDocumentationComments(
        indent, anEnum.documentationComments, _docCommentSpec);
    indent.write('typedef enum ');
    indent.addScoped('{', '} ${anEnum.name};', () {
      enumerate(anEnum.members, (int index, final EnumMember member) {
        addDocumentationComments(
            indent, member.documentationComments, _docCommentSpec);
        indent.writeln(
            '${member.name} = $index${index == anEnum.members.length - 1 ? '' : ','}');
      });
    });
  }

  @override
  void writeGeneralUtilities(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
  }

  @override
  void writeDataClass(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Class klass, {
    required String dartPackageName,
  }) {
  }

  @override
  void writeFlutterApi(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
  }

  @override
  void writeHostApi(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
  }

  @override
  void writeCloseNamespace(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
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
  }) {
  }

  @override
  void writeGeneralUtilities(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
  }

  @override
  void writeDataClass(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Class klass, {
    required String dartPackageName,
  }) {
  }

  @override
  void writeClassEncode(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefintion, {
    required String dartPackageName,
  }) {
  }

  @override
  void writeClassDecode(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
  }

  @override
  void writeFlutterApi(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
  }

  @override
  void writeHostApi(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
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
