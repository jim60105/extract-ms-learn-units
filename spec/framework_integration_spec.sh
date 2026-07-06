#!/bin/zsh

eval "$(shellspec - -c) exit 1"
# Copyright (C) 2026 Jim Chen <Jim@ChenJ.im>, licensed under GPL-3.0-or-later
#
# Syntax validation for all Zsh scripts in the project

Include spec/spec_helper.sh

Describe 'Framework integration syntax checks'
  It 'should validate Zsh script syntax without errors'
    When call zsh -n "$SHELLSPEC_PROJECT_ROOT/extract-ms-learn-units.zsh"
    The status should be success
  End
End
