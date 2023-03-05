module.exports =
  pkg:
    name: "@makeform/video", extend: {name: '@makeform/upload'}
    i18n:
      en:
        "檔案不支援": "file is not supported"
      "zh-TW":
        "檔案不支援": "檔案不支援"
    dependencies: [
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
