module.exports =
  pkg:
    name: "@makeform/video", extend: {name: '@makeform/upload'}
    i18n:
      en:
        "檔案不支援": "Please upload a video file with the .mp4 extension, using the MP4 container, encoded with H.264 (avc1) for video and MP3, AAC, or FLAC for audio."
        "video-format-hint": "Please upload a video file with the .mp4 extension, using the MP4 container, encoded with H.264 (avc1) for video and MP3, AAC, or FLAC for audio."
      "zh-TW":
        "檔案不支援": "檔案格式不符：請上傳 .mp4 副檔名的影片(採 MP4 容器)，影片編碼需使用 H.264 (avc1)、音訊編碼需為 MP3、AAC 或 FLAC 其中一種。"
        "video-format-hint": "請上傳 .mp4 副檔名的影片(採 MP4 容器)，影片編碼需使用 H.264 (avc1)、音訊編碼需為 MP3、AAC 或 FLAC 其中一種。"
    dependencies: [
      {url: "https://cdn.jsdelivr.net/npm/mux.js@6.0.1/dist/mux.min.js"}
    ]

  init: ({ctx, root, parent, t}) ->
    {muxjs} = ctx
    partial-file = (file, start, end) ->
      (res, rej) <- new Promise _
      fr = new FileReader!
      /*
      # this uses partial file for muxjs
      # however, there are files that we need almost the whole file
      # for muxjs to correctly detect its codec.
      # before a better solution is found, we will use the whole file
      blob = file.slice start, end
      fr.onload = -> res fr.result
      fr.onerror = -> rej fr.error
      fr.readAsArrayBuffer blob
      */
      # below code loads the whole file
      fr.onload = -> res fr.result
      fr.onerror = -> rej fr.error
      fr.readAsArrayBuffer file

    is-supported = (file) ->
      Promise.resolve!
        .then -> partial-file file, 0, Math.min(file.size, 10 * 1024 * 1024)
        .then (buf) ->
          buf = new Uint8Array buf
          streams = muxjs.mp4.probe.tracks buf
          video = streams.filter(->it.type == \video).map(->it.codec)
          audio = streams.filter(->it.type == \audio).map(->it.codec)
          supported = if !(video.length or audio.length) => false
          else (
            !video.filter(-> !/avc1/.exec it).length and
            !audio.filter(-> !/mp3|mp4|flac|aac/.exec it).length
          )
          return {video, audio, supported, message: t("檔案不支援")}

    view = new ldview do
      root: root
      ctx: {}
      handler:
        "video":
          list: ({ctx}) ->
            file = ctx.file
            if Array.isArray(file) => file else if file => [file] else []
          view:
            handler:
              source: ({node,ctx}) -> node.setAttribute \src, ctx.url

    parent.ext {view, is-supported}
