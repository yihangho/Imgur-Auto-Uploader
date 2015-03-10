# Imgur Auto-Uploader

Imgur Auto-Uploader is an application that watches some directories for new images, and upload them to Imgur.

## Installation

```
gem install imgur-auto-uploader
```

### Linux

We additionally need `xclip` or `xsel`. On Ubuntu, this can be installed with `sudo apt-get install xclip`.

### Windows

We need the `ffi` gem: `gem install ffi`.

## Configuration

1. You need an Imgur account. You also need to [register an application](https://api.imgur.com/oauth2/addclient) on Imgur to obtain your client ID and client secret. Under authorization, choose "OAuth2 authorization without a callback URL".

2. Create an album on Imgur to store all the images that will be uploaded.

3. Run `imgur-up config`. In the last step, select the album created in step 2.

## Running

Simply run `imgur-up watch [directories]`. For example, `imgur-up ~/Pictures/Meme ~/Pictures/Screenshot`.
