// Copyright (C) 2022-2023 Intel Corporation
// SPDX-License-Identifier: BSD-3-Clause
//
// external_test.dart
// Unit tests for external modules
//
// 2022 January 7
// Author: Max Korbel <max.korbel@intel.com>

import 'dart:io';
import 'package:rohd/rohd.dart';
import 'package:test/test.dart';

class MyExternalModule extends ExternalSystemVerilogModule {
  MyExternalModule(Logic a, {int width = 2, int depth = 5})
      : super(
            definitionName: 'external_module_name',
            parameters: {'WIDTH': '$width', 'DEPTH': '$depth'}) {
    addInput('a', a, width: width);
    addOutput('b', width: width);
  }
}

class MyExternalModuleNoParams extends ExternalSystemVerilogModule {
  MyExternalModuleNoParams(Logic a)
      : super(definitionName: 'external_module_name_no_params') {
    addInput('a', a);
    addOutput('b');
  }
}

class TopModule extends Module {
  TopModule(Logic a, Logic c) {
    a = addInput('a', a, width: a.width);
    c = addInput('c', c);
    MyExternalModule(a);
    MyExternalModuleNoParams(c);
  }
}

void main() {
  test('instantiate', () async {
    final mod = TopModule(Logic(width: 2), Logic());
    await mod.build();
    final sv = mod.generateSynth();
    File('my_instance.sv').writeAsStringSync(sv);
    expect(
        sv,
        contains(
            'external_module_name #(.WIDTH(2)) external_module(.a(a),.b(b));'));
  });
}
