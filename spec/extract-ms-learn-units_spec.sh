#!/bin/zsh

eval "$(shellspec - -c) exit 1"
# Copyright (C) 2026 Jim Chen <Jim@ChenJ.im>, licensed under GPL-3.0-or-later
#
# BDD test suite for extract-ms-learn-units.zsh covering argument parsing,
# learning path and module URL extraction, exclusion rules, and error handling.

Include spec/spec_helper.sh

Describe 'extract-ms-learn-units.zsh'
  setup() {
    setup_test_env
  }

  cleanup() {
    cleanup_test_env
  }

  Before 'setup'
  After 'cleanup'

  Describe 'Argument parsing and help'
    It 'should output usage and exit 0 when --help is passed'
      When run script "$SHELLSPEC_PROJECT_ROOT/extract-ms-learn-units.zsh" "--help"
      The status should be success
      The output should include "Usage:"
    End

    It 'should output usage and exit 0 when -h is passed'
      When run script "$SHELLSPEC_PROJECT_ROOT/extract-ms-learn-units.zsh" "-h"
      The status should be success
      The output should include "Usage:"
    End

    It 'should fail and display error when no arguments are provided'
      When run script "$SHELLSPEC_PROJECT_ROOT/extract-ms-learn-units.zsh"
      The status should be failure
      The stderr should include "At least one Learning Path or Module URL is required."
      The output should include "Usage:"
    End

    It 'should warn on unknown options and continue processing'
      Mock curl
        echo '<html><a href="1-unit-test">Unit Test</a></html>'
      End
      When run script "$SHELLSPEC_PROJECT_ROOT/extract-ms-learn-units.zsh" "--unknown-flag" "https://learn.microsoft.com/en-us/training/modules/test-module"
      The status should be success
      The stderr should include "Unknown option ignored: --unknown-flag"
      The output should include "https://learn.microsoft.com/en-us/training/modules/test-module/1-unit-test"
    End
  End

  Describe 'URL processing and extraction'
    Mock curl
      case "$*" in
        *"/training/paths/test-path"*)
          echo '<html><a href="../../modules/test-mod-1/">Mod 1</a><a href="modules/test-mod-2/">Mod 2</a></html>'
          ;;
        *"/training/modules/test-mod-1"*)
          echo '<html><a href="1-introduction">Intro</a><a href="2-core-concept">Core Concept</a><a href="3-summary">Summary</a></html>'
          ;;
        *"/training/modules/test-mod-2"*)
          echo '<html><a href="1-advanced-topic">Advanced</a><a href="2-knowledge-check">Quiz</a></html>'
          ;;
        *"/training/modules/direct-module"*)
          echo '<html><a href="1-unit-one">Unit 1</a><a href="2-unit-two">Unit 2</a></html>'
          ;;
        *"/training/modules/fail-module"*)
          return 1
          ;;
        *)
          return 1
          ;;
      esac
    End

    It 'should extract unit URLs from a learning path while filtering out intro, summary, and knowledge checks'
      When run script "$SHELLSPEC_PROJECT_ROOT/extract-ms-learn-units.zsh" "https://learn.microsoft.com/zh-tw/training/paths/test-path"
      The status should be success
      The output should include "https://learn.microsoft.com/zh-tw/training/modules/test-mod-1/2-core-concept"
      The output should include "https://learn.microsoft.com/zh-tw/training/modules/test-mod-2/1-advanced-topic"
      The output should not include "1-introduction"
      The output should not include "3-summary"
      The output should not include "2-knowledge-check"
    End

    It 'should extract unit URLs directly from a module URL'
      When run script "$SHELLSPEC_PROJECT_ROOT/extract-ms-learn-units.zsh" "https://learn.microsoft.com/en-us/training/modules/direct-module"
      The status should be success
      The output should include "https://learn.microsoft.com/en-us/training/modules/direct-module/1-unit-one"
      The output should include "https://learn.microsoft.com/en-us/training/modules/direct-module/2-unit-two"
    End

    It 'should handle verbose mode properly'
      When run script "$SHELLSPEC_PROJECT_ROOT/extract-ms-learn-units.zsh" "-v" "https://learn.microsoft.com/en-us/training/modules/direct-module"
      The status should be success
      The stderr should include "[debug] Processing input URL:"
      The output should include "https://learn.microsoft.com/en-us/training/modules/direct-module/1-unit-one"
    End

    It 'should warn on unrecognized URL formats'
      When run script "$SHELLSPEC_PROJECT_ROOT/extract-ms-learn-units.zsh" "https://learn.microsoft.com/en-us/training/docs/other-page"
      The status should be success
      The stderr should include "Unrecognized URL format"
    End

    It 'should warn when failing to download a module page'
      When run script "$SHELLSPEC_PROJECT_ROOT/extract-ms-learn-units.zsh" "https://learn.microsoft.com/en-us/training/modules/fail-module"
      The status should be success
      The stderr should include "Failed to download module URL:"
    End

    It 'should save HTML dump files when --dump-dir is specified'
      When run script "$SHELLSPEC_PROJECT_ROOT/extract-ms-learn-units.zsh" "--dump-dir" "html_dumps" "https://learn.microsoft.com/en-us/training/modules/direct-module"
      The status should be success
      The file "html_dumps/direct-module.html" should be exist
      The output should include "https://learn.microsoft.com/en-us/training/modules/direct-module/1-unit-one"
      The output should include "https://learn.microsoft.com/en-us/training/modules/direct-module/2-unit-two"
    End
  End
End
