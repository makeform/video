module.exports =
  pkg:
    name: "@makeform/video", extend: {name: '@makeform/upload'}
    i18n:
      en:
        "檔案不支援": "file format: Please upload a video file in mp4 format with h.264 encoding."
      "zh-TW":
        "檔案不支援": "檔案格式不符：請上傳使用 mp4 格式，並且採用 h.264 編碼的影片檔。"
    dependencies: [
      {url: "https://cdn.jsdelivr.net/npm/mux.js@6.0.1/dist/mux.min.js"}
    ]

  init: ({ctx, root, parent, t}) ->
    {muxjs} = ctx
    partial-file = (file, start, end) ->
      (res, rej) <- new Promise _
      fr = new FileReader!
      /*
      blob = file.slice start, end
      fr.onload = -> res fr.result
      fr.onerror = -> rej fr.error
      fr.readAsArrayBuffer blob
      */
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
          supported = false
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
