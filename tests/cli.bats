#!/usr/bin/env bats

setup_file() {
    [ -e "/tmp/notesium-test-corpus" ] && exit 1
    run mkdir /tmp/notesium-test-corpus
    export NOTESIUM_DIR="/tmp/notesium-test-corpus"
    export PATH="$(realpath $BATS_TEST_DIRNAME/../):$PATH"
}

teardown_file() {
    run rmdir /tmp/notesium-test-corpus
}

@test "cli: print usage if no arguments specified" {
    run notesium
    echo "$output"
    [ $status -eq 1 ]
    [ "${lines[0]}" == 'Usage: notesium COMMAND [OPTIONS]' ]
}

@test "cli: print usage if -h --help help" {
    run notesium -h
    echo "$output"
    [ $status -eq 1 ]
    [ "${lines[0]}" == 'Usage: notesium COMMAND [OPTIONS]' ]

    run notesium --help
    echo "$output"
    [ $status -eq 1 ]
    [ "${lines[0]}" == 'Usage: notesium COMMAND [OPTIONS]' ]

    run notesium help
    echo "$output"
    [ $status -eq 1 ]
    [ "${lines[0]}" == 'Usage: notesium COMMAND [OPTIONS]' ]
}

@test "cli: version command sniff" {
    run notesium -v
    echo "$output"
    [ $status -eq 0 ]

    run notesium --version
    echo "$output"
    [ $status -eq 0 ]

    run notesium version
    echo "$output"
    [ $status -eq 0 ]

    run notesium version --verbose
    echo "$output"
    [ $status -eq 0 ]
}

@test "cli: version command sniff check" {
    [ "$TEST_VERSION_CHECK" ] || skip "TEST_VERSION_CHECK not set"

    run notesium version --check
    echo "$output"
    [ $status -eq 0 ]

    run notesium version --check --verbose
    echo "$output"
    [ $status -eq 0 ]
}

@test "cli: unrecognized command fatal error" {
    run notesium foo
    echo "$output"
    [ $status -eq 1 ]
    [[ "${lines[0]}" =~ 'unrecognized command: foo' ]]
}

@test "cli: unrecognized command option fatal error" {
    run notesium new --foo
    echo "$output"
    [ $status -eq 1 ]
    [[ "${lines[0]}" =~ 'unrecognized option: --foo' ]]
}

@test "cli: unrecognized option fatal error" {
    run notesium --foo
    echo "$output"
    [ $status -eq 1 ]
    [[ "${lines[0]}" =~ 'unrecognized option: --foo' ]]
}

@test "cli: home error if NOTESIUM_DIR does not exist" {
    export NOTESIUM_DIR="/tmp/notesium-test-foo"
    run notesium home
    echo "$output"
    [ $status -eq 1 ]
    [[ "${lines[0]}" =~ "NOTESIUM_DIR does not exist: $NOTESIUM_DIR" ]]
}

@test "cli: home prints default NOTESIUM_DIR if not set" {
    [ -e "$HOME/notes" ] || skip "$HOME/notes does not exist"
    unset NOTESIUM_DIR
    run notesium home
    echo "$output"
    [ $status -eq 0 ]
    [ "${lines[0]}" == "$(realpath $HOME/notes)" ]
}

@test "cli: home prints NOTESIUM_DIR upon successful verification" {
    run notesium home
    echo "$output"
    [ $status -eq 0 ]
    [ "${lines[0]}" == "/tmp/notesium-test-corpus" ]
}

