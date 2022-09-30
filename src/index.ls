module.exports =
  pkg:
    name: "@makeform/video", extend: {name: '@makeform/upload', dom: "overwrite"}
    i18n:
      en:
        "未命名的影片": "unnamed video"
        "上傳": "upload"
        "上傳中": "uploading"
        "尚未上傳影片": "no file uploaded yet"
        "檔案大小": "File Size"
        "上傳時間": "Upload Time"
        "檔案不支援": "file is not supported"
      "zh-TW":
        "未命名的影片": "未命名的影片"
        "上傳": "上傳"
        "上傳中": "上傳中"
        "尚未上傳影片": "尚未上傳影片"
        "檔案大小": "檔案大小"
        "上傳時間": "上傳時間"
        "檔案不支援": "檔案不支援"
    dependencies: [
      {url: "https://cdn.jsdelivr.net/npm/moment@2.29.1/moment.min.js", async: false}
      {url: "https://cdn.jsdelivr.net/npm/moment-timezone@0.5.34/builds/moment-timezone-with-data.min.js"}
      {url: "https://cdn.jsdelivr.net/npm/mux.js@6.0.1/dist/mux.min.js"}
    ]

  init: ({ctx, root, parent}) ->
    {muxjs} = ctx

    is-supported = (file) ->
      (res, rej) <- new Promise _
      try
        fr = new FileReader!
        fr.onload = ->
          buf = new Uint8Array fr.result
          streams = muxjs.mp4.probe.tracks buf
          video = streams
            .filter -> it.type == \video
            .map -> it.codec
          audio = streams
            .filter -> it.type == \audio
            .map -> it.codec
          if !(video.length or audio.length) => supported = false
          else
            supported = (
              !video.filter(-> !/avc1/.exec it).length and
              !audio.filter(-> !/mp3|mp4|flac|aac/.exec it).length
            )
          res {video, audio, supported}
        fr.readAsArrayBuffer(file)
      catch e
        rej e
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
