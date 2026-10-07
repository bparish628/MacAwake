# MacAwake

A menu bar app that keeps your Mac awake.

Click the cup in the menu bar to toggle it on. Choose how long it stays on: indefinitely, 15, 30, or 45 minutes, or 1, 4, 8, or 12 hours. When the time runs out it turns itself off.

MacAwake adds itself as a login item the first time it runs, so it starts with your Mac. It always starts in the off state. You can turn off launch at login under Settings.

## Build and install

Requires macOS 14 or later and the Swift toolchain (Xcode Command Line Tools is enough).

```sh
scripts/build.sh            # builds build/MacAwake.app (universal, ad-hoc signed)
scripts/build.sh --install  # also copies it to /Applications and launches it
```

## How it works

While on, MacAwake holds an IOKit power assertion, the same mechanism `caffeinate` uses. With "Keep display on" enabled (the default) it prevents display sleep. Disabled, it only prevents idle system sleep. Run `pmset -g assertions` to see it.

## License

MIT. See [LICENSE](LICENSE).
