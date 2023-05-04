#!/bin/bash

# Strubloid:Linux:Tests

#help-create-test() {
#cat << EOF
#Usage: b-test-create-rule -c <number-of-suites> -t <type-of-tests [Rule|Fields]>
#
#-h, -help,          --help               Display help
#-c, -count,        --count               Set the quantity of Suites to create in this build
#-t, -type,          --type               Set the type of Suite, this will generate on Tests/[Type-of-Suite]
#
#EOF
#
#}
#
## This will be creating new tests in blocworx
#function create-test() {
#
#  # Getting the current branch ID
#  CurrentBranchName=$(git branch --show-current | grep -Po 'BLCXT?-[0-9]*.*')
#
#  # Getting the BLCXT-[0-9]+
#  BlocworxBranchNumber=$(git branch --show-current | grep -Po 'BLCXT?-[0-9]*')
#
#  # Getting the current integer of the blocworx branch
#  BlocworxCurrentNumber=$(git branch --show-current | grep -Po 'BLCXT?-[0-9]*' | grep -Po '[0-9]*' | awk '{ print $1}')
#
#  # This will return the lower case text after BLCXT-15-populate-part-of-field => populate-part-of-field
#  BranchNameIgnoringJiraTicket=$(git branch --show-current | grep -Po '(BLCXT?-[0-9]*)(.*)' | grep -Po '(-[a-zA-Z].*)' | grep -Po '([a-zA-Z].*)')
#
#  # This will create the destination folder name under Tests/[type]/TestDestinationName
#  TestDestinationName=$(echo "$BranchNameIgnoringJiraTicket" | sed -r 's/(-)([a-z])/\U\2/g')
#
#  ## Step 2: checking for arguments
#  options=$(getopt -l "help,count:,type:" -o "hc:t:" -a -- "$@")
#
#  # If no arguments follow this option, then the positional parameters are unset. Otherwise, the positional parameters
#  # are set to the arguments, even if some of them begin with a ‘-’.
#  eval set -- "$options"
#
#  while true; do
#    case $1 in
#    -h | --help)
#      help-create-test
#      return 0
#      ;;
#    -c | --count)
#      count="$2"
#      ;;
#    -t | --type)
#      type="$2"
#      ;;
#    --)
#      shift
#      break
#      ;;
#    esac
#    shift
#  done
#
#  ## Step 1: showing the data that we can get it
#  echo "======================================================================================="
#  echo "Blocworx Test Builder "
#  echo "V1.0"
#  echo "Creating: Rule"
#  echo "======================================================================================="
#  echo "[Current Branch Name]: $CurrentBranchName"
#  echo "[Blocworx Branch Number]: $BlocworxBranchNumber"
#  echo "[Current Number]: $BlocworxCurrentNumber"
#  echo "[Test Basename]: $TestDestinationName"
#  echo "======================================================================================="
#
#  ## Step 2: checking if was passed or not the count
#  if [[ -z "$count" ]]; then
#    read -p "How many tests : " count
#  fi
#
#  ## Step 3: checking if was passed or not the type
#  if [[ -z "$type" ]]; then
#    read -p "Test Type [Rules|Fields] : " type
#  fi
#  type=$(echo "$type" | sed -r 's/(^)([a-z])/\U\2/g')
#
#  ## Step 5: creating a new folder if does not exist
#  TestFolder="Tests/$type/$TestDestinationName"
#  if [ ! -d "$TestFolder" ]
#  then
#      mkdir -p "$TestFolder"
#  fi
#
#  # step 6: defining test suite folder
#  TestSuiteFolder="TestSuites/"
#
#  ## Step 6: printing the count, type and new generated folder
#  echo "[Suite Type] $type"
#  echo "[Test Count] $count"
#  echo "[Test folder]: $TestFolder"
#  echo "======================================================================================="
#
#  ## Creating test suite
#  printf "[Test Suite]"
#  TestSuiteFullPath="${TestSuiteFolder}/${BlocworxBranchNumber}-suite.test.ts"
#  printf "\n = $TestSuiteFullPath"
#  printf "\n = touch: \t"
#  printf "" > "$TestSuiteFullPath" &&  printf "DONE"
#  printf "\n = generate: \t"
#
#  EscapedTestSuiteFullPath=$(echo "$TestSuiteFullPath" | sed -r 's/\//\\\//g')
#  TestDestinationName=$(echo "$TestDestinationName" | sed -r 's/(^)([a-z])/\U\2/g')
#
#  ## Step 7: creating the test suite file
#  for ((line = 1; line <= "$count"; line++)); do
#
#    ## Making sure that the first letter is uppercase
#    ClassTestDestinationName="${TestDestinationName}$line"
#
#    ## this will fix 01,02,03...09.
#    if [ "$line" -lt "10" ]; then
#      line="0$line"
#    fi
#    FromArgument="${TestFolder}/$line-case.test"
#
#    if [ "$line" -eq "1" ]; then
#      echo "import SuiteConfiguration from \"src/Blocworx/SuiteConfiguration.interface\";" >> "$TestSuiteFullPath"
#      echo "import BlocworxTestSuite from \"src/Blocworx/BlocworxTestSuite\";" >> "$TestSuiteFullPath"
#    fi
#
#    echo "import $ClassTestDestinationName from \"${FromArgument}\";" >> "$TestSuiteFullPath"
#
#    if [ "$line" -eq "$count" ]; then
#      printf "\n/**\n * @group blocworx-live\n */" >> "$TestSuiteFullPath"
#
#      printf "\ndescribe('$BlocworxBranchNumber', () => {" >> "$TestSuiteFullPath"
#      printf "\n\ttry" >> "$TestSuiteFullPath"
#      printf "\n\t{" >> "$TestSuiteFullPath"
#
#      printf "\n\t\tlet allTests : SuiteConfiguration[] = [{" >> "$TestSuiteFullPath"
#      for ((testsInSuite = 1; testsInSuite <= "$count"; testsInSuite++)); do
#
#        InstanceName="${TestDestinationName}$testsInSuite"
#
#        printf "\n\t\t\tinstance: new $InstanceName()," >> "$TestSuiteFullPath"
#        printf "\n\t\t\tname: 'rename-me'" >> "$TestSuiteFullPath"
#        if [ "$testsInSuite" -ne "$count" ]; then
#          printf "\n\t\t},{" >> "$TestSuiteFullPath"
#        fi
#      done
#      printf "\n\t\t}];" >> "$TestSuiteFullPath"
#      printf "\n\t\tnew BlocworxTestSuite(allTests).runAll();" >> "$TestSuiteFullPath"
#      printf "" >> "$TestSuiteFullPath"
#
#      printf "\n\t} catch ( e ) {" >> "$TestSuiteFullPath"
#      printf "\n\t\tconsole.log(e)" >> "$TestSuiteFullPath"
#      printf "\n\t}" >> "$TestSuiteFullPath"
#      printf "\n});" >> "$TestSuiteFullPath"
#    fi
#  done
#  printf "DONE\n\n"
#
#  ## Step 8: creating all tests in Tests/[type]/
#  for ((i = 1; i <= "$count"; i++)); do
#
#    ## Making sure that the first letter is uppercase
#    ClassTestDestinationName="${TestDestinationName}$i"
#
### loading the default test data
#DefaultTest=$(cat << END
#import BlocworxTests from "src/Blocworx/BlocworxTests";
#import BlocworxDefaults from "../blocworx-tests/src/Blocworx/BlocworxDefaults";
#import BlocworxActions from "src/Blocworx/BlocworxActions";
#
#/**
# * This is the main class that does all the tests for our BlocworxTests cases
# */
#export default class RenameClassName extends BlocworxTests {
#
#    /**
#     * This validates this test
#     *
#     * @param page
#     * @param browser
#     */
#    public static validate = async (page, browser) => {
#
#        // step 1: access the page
#        await BlocworxDefaults.goTo(page, BlocworxActions.getPageUrl(
#            'module/rules-test/bloc/7137'
#        ));
#    }
#
#    public testCase = async (page, browser) => {
#        await RenameClassName.validate(page, browser);
#    }
#}
#END
#)
#
#    ## this will fix 01,02,03...09.
#    if [ "$i" -lt "10" ]; then
#      i="0$i"
#    fi
#
#    ## Setting the path for the
#    TestFullPath="${TestFolder}/$i-case.test.ts"
#
#    ## Escaped the / to become \/, so a regex in the sed works
#    EscapedTestFullPath=$(echo "$TestFullPath" | sed -r 's/\//\\\//g')
#    ImportDeclarationTest=$(echo "$EscapedTestFullPath" | sed -r "s/\.ts//g")
#    printf "[Test]"
#    printf "\n = $TestFullPath"
#    printf "\n = touch: \t"
#    touch "$TestFullPath" && printf "DONE"
#    printf "\n = copy: \t"
#    echo "$DefaultTest" > "$TestFullPath" && printf "DONE"
#    printf "\n = Format: \t"
#    sed -i -e "s/RenameClassName/$ClassTestDestinationName/g" "$TestFullPath"
#    printf "DONE\n"
#
#  done
#
#}
