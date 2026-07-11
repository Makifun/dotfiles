# dotfiles

## Setup on a new machine

After cloning the repo, register the git filter for the YouTube Music config. This prevents the `url` field (which tracks the last played song) from being committed:

```sh
git config filter.yt-music-config.clean "jq --tab 'del(.url)'"
git config filter.yt-music-config.smudge cat
git config filter.yt-music-config.required true
```

`jq` must be installed for this to work.

Also register the git filter for the KDE Plasma desktop config. This prevents desktop icon positions, screen mappings, and wallpaper paths from being committed:

```sh
git config filter.strip-plasma-positions.clean "grep -Ev '^(positions|screenMapping|Image|changedPositions)='"
git config filter.strip-plasma-positions.smudge cat
git config filter.strip-plasma-positions.required true
```
