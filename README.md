# dotfiles

## Setup on a new machine

After cloning the repo, register the git filter for the YouTube Music config. This prevents the `url` field (which tracks the last played song) from being committed:

```sh
git config filter.yt-music-config.clean "jq --tab 'del(.url)'"
git config filter.yt-music-config.smudge cat
git config filter.yt-music-config.required true
```

`jq` must be installed for this to work.
