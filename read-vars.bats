#!/usr/bin/env bats

setup() {
  cd "$(dirname "$BATS_TEST_FILENAME")"
}

@test "Exit with error when no parameters provided" {
  run ./read-vars.sh
  [[ "$status" -ne 0 ]]
}

@test "Display help information with -h flag" {
  run ./read-vars.sh -h
  [[ "$status" -eq 0 ]] &&
  [[ "$output" == "Usage:"* ]]
}

@test "Read value and generate export command" {
  run ./read-vars.sh -c TEST_VAR <<< "Test Value"
  [[ "$status" -eq 0 ]] &&
  [[ "$output" == "export TEST_VAR=Test\ Value" ]]
}

@test "Don't generate export command when variable is set" {
  export TEST_VAR="Already Set"
  run ./read-vars.sh -c TEST_VAR <<< "New Value"
  [[ "$status" -eq 0 ]] &&
  [[ -z "$output" ]]
}

@test "Generate export command if variable is set but not exported" {
  TEST_VAR="Not Exported"
  run ./read-vars.sh -c TEST_VAR <<< "New Value"
  [[ "$status" -eq 0 ]] &&
  [[ "$output" == "export TEST_VAR=New\ Value" ]]
}

@test "Generate export commands for multiple variables" {
  run ./read-vars.sh -c VAR1 VAR2 <<< $'Value1\nValue2'
  [[ "$status" -eq 0 ]] &&
  [[ "$output" == $'export VAR1=Value1\nexport VAR2=Value2' ]]
}
