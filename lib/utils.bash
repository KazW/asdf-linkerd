#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/linkerd/linkerd2"
TOOL_NAME="linkerd"
TOOL_TEST="linkerd --help"

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/stable-.*' | cut -d/ -f3- |
    sed 's/^stable-//'
}

list_all_versions() {
  list_github_tags
}

get_platform () {
  local platform="$(uname | tr '[:upper:]' '[:lower:]')"

  case "$platform" in
    linux|darwin|freebsd) ;;
    *)
      fail "Platform '${platform}' not supported!"
      ;;
  esac

  echo -n ${platform}
}

get_arch () {
  local arch=""

  case "$(uname -m)" in
    x86_64|amd64) arch="amd64"; ;;
    i686|i386) arch="386"; ;;
    armv6l|armv7l) arch="armv6l"; ;;
    aarch64|arm64) arch="arm64"; ;;
    ppc64le) arch="ppc64le"; ;;
    *)
      fail "Arch '$(uname -m)' not supported!"
      ;;
  esac

  echo -n $arch
}

get_download_url() {
  local version platform arch bin_file
  version="$1"
  platform=$(get_platform)
  arch=$(get_arch)
  if ["$platform" == "darwin"] && [ "$arch" != "arm64" ]
  then
    bin_file="linkerd2-cli-stable-${version}-${platform}"
  else
    bin_file="linkerd2-cli-stable-${version}-${platform}-${arch}"
  fi

  echo "$GH_REPO/releases/download/stable-${version}/${bin_file}"
}

checksumbin=$(command -v openssl) || checksumbin=$(command -v shasum) || {
  fail "Failed to find checksum binary. Please install openssl or shasum."
}

validate_checksum() {
  local filename version url SHA
  version="$1"
  filename="$2"
  url=$(get_download_url $version)

  echo -n "* Validating checksum... "
  SHA=$(curl "${curl_opts[@]}" "${url}.sha256")

  case $checksumbin in
    *openssl)
      checksum=$($checksumbin dgst -sha256 "${filename}" | sed -e 's/^.* //')
      ;;
    *shasum)
      checksum=$($checksumbin -a256 "${filename}" | sed -e 's/^.* //')
      ;;
  esac

  if [ "$checksum" != "$SHA" ]; then
    rm -f $filename
    fail "Checksum validation failed!"
  fi
  echo "Passed!"
}

download_release() {
  local version filename platform arch bin_file url
  version="$1"
  filename="$2"
  url=$(get_download_url $version)

  echo -n "* Downloading $TOOL_NAME release $version... "
  curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
  echo "Done!"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="$3"

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
  fi

  (
    local bin_path="$install_path/bin"
    local tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"

    mkdir -p "$bin_path"
    cp "$ASDF_DOWNLOAD_PATH/$TOOL_NAME-$version" "$bin_path/$tool_cmd"

    test -x "$bin_path/$tool_cmd" || fail "Expected $bin_path/$tool_cmd to be executable."

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error ocurred while installing $TOOL_NAME $version."
  )
}
