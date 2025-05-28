# @makeform/video

video upload widget that extends `@makeform/upload` widgets to show video preview.

We only support H.264-encoded videos in an MP4 container to ensure compatibility with the browser’s built-in player.


## Format Hint

For browser playback compatibility, we limit video formats to following:

    Please upload a video file with the .mp4 extension, using the MP4 container, encoded with H.264 (avc1) for video and MP3, AAC, or FLAC for audio.

this hint can be used with "video-format-hint" i18n token ( check the `i18n` object in `src/index.ls` ):

    meta: {
      config: { note: ["video-format-hint"] }
    }


## License

MIT
