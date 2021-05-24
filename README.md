# asdf-linkerd ![Build](https://github.com/KazW/asdf-linkerd/workflows/Build/badge.svg) ![Lint](https://github.com/KazW/asdf-linkerd/workflows/Lint/badge.svg)

[linkerd](https://linkerd.io/2.10/reference/cli/) plugin for the [asdf version manager](https://asdf-vm.com).
Based on [this plugin](https://github.com/vaynerx/asdf-linkerd).

# Dependencies

- `bash`, `curl`, and `shasum` or `openssl`: generic POSIX utilities.
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add linkerd
# or
asdf plugin add linkerd https://github.com/KazW/asdf-linkerd.git
```

linkerd:

```shell
# Show all installable versions
asdf list-all linkerd

# Install specific version
asdf install linkerd latest

# Set a version globally (on your ~/.tool-versions file)
asdf global linkerd latest

# Now linkerd commands are available
linkerd --help
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/KazW/asdf-linkerd/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Kaz Walker](https://github.com/KazW/)
