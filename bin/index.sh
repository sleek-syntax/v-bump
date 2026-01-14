#! /usr/bin/env bash

# functions
print_usage() {
  printf "

    ██╗   ██╗      ██████╗ ██╗   ██╗███╗   ███╗██████╗
    ██║   ██║      ██╔══██╗██║   ██║████╗ ████║██╔══██╗
    ██║   ██║█████╗██████╔╝██║   ██║██╔████╔██║██████╔╝
    ╚██╗ ██╔╝╚════╝██╔══██╗██║   ██║██║╚██╔╝██║██╔═══╝
     ╚████╔╝       ██████╔╝╚██████╔╝██║ ╚═╝ ██║██║
      ╚═══╝        ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚═╝

    ───────────────────────────────────────────────────
    Simple lightweight utility to manage versions
    in package.json files.
    ───────────────────────────────────────────────────

    COMMAND

      v-bump
      Bumps your version according to your arguments
      or git commit message.

    ARGUMENTS

      -s    Severity of bump: patch | minor | major
      -i    Increment amount (default: 1)
      -h    Show this help message

    EXAMPLES

      v-bump -s patch -i 1    1.0.0 → 1.0.1
      v-bump -s minor         1.4.9 → 1.5.0
      v-bump -s major         1.2.5 → 2.0.0

    ───────────────────────────────────────────────────

    "
}

validate_severity() {
    local severity="$1"
    local accepted_severity=("patch" "minor" "major")
    if [[ ! " ${accepted_severity[*]} " =~ " ${severity} " ]]; then
        echo "Error: Invalid severity '$severity'. Accepted values: patch, minor, major"
        exit 1
    fi
}

validate_increment() {
    local increment="$1"
    if [[ ! "$increment" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid increment '$increment'. Must be a positive integer."
        exit 1
    fi
}

# arguments extraction
severity_flag=''
increment_flag=''

while getopts 's:i:h' flag; do
  case "${flag}" in
    s) severity_flag="${OPTARG}" ;;
    i) increment_flag="${OPTARG}" ;;
    h) print_usage
       exit 0 ;;
  esac
done

# validate CLI arguments if provided
if [[ -n "$severity_flag" ]]; then
    validate_severity "$severity_flag"
fi

if [[ -n "$increment_flag" ]]; then
    validate_increment "$increment_flag"
else
    increment_flag=1
fi

# determine source of version instructions
if [[ -n "$severity_flag" && -n "$increment_flag" ]]; then
    echo "Bumping with args"
else
    echo "Bumping with git commit message"
    echo "Getting latest commit..."

    if ! commit=$(git log -1 --pretty=%B 2>/dev/null); then
        echo "Error: Not a git repository or no commits found."
        exit 1
    fi

    if [[ ! "$commit" =~ \[\[.+:.+\]\] ]]; then
        echo "Error: Commit message does not contain version instruction."
        echo "Expected format: [[severity:increment]] (e.g., [[patch:1]])"
        exit 1
    fi

    echo "Extracting the severity and increment from the commit..."
    command=${commit#*[[}
    severity_flag=${command%:*}
    increment_flag=${command#*:}
    increment_flag=${increment_flag%"]]"*}

    echo "Found severity: $severity_flag"
    echo "Found increment: $increment_flag"

    # validate parsed values
    validate_severity "$severity_flag"
    validate_increment "$increment_flag"
fi

# check for package.json
if [[ ! -f "package.json" ]]; then
    echo "Error: package.json not found in current directory."
    exit 1
fi

# get current package version from package.json
echo "Getting current version..."
if ! current=$(node --eval="process.stdout.write(require('./package.json').version)" 2>/dev/null); then
    echo "Error: Failed to read version from package.json. Is Node.js installed?"
    exit 1
fi

# extract the current version values
echo "Exploding current version..."
IFS='.' read -r -a versions <<< "$current"
majorcur=${versions[0]}
minorcur=${versions[1]}
patchcur=${versions[2]}

# set the version in package.json
echo "Bumping $severity_flag by $increment_flag..."
if [[ "$severity_flag" == "major" ]]; then
    majorcur=$((majorcur + increment_flag))
    minorcur=0
    patchcur=0
elif [[ "$severity_flag" == "minor" ]]; then
    minorcur=$((minorcur + increment_flag))
    patchcur=0
elif [[ "$severity_flag" == "patch" ]]; then
    patchcur=$((patchcur + increment_flag))
fi

newver="$majorcur.$minorcur.$patchcur"
if ! npm version "$newver" --commit-hooks false --git-tag-version false; then
    echo "Error: npm version command failed."
    exit 1
fi

echo "New version $newver is set"
exit 0
