// importScripts("demuxer_mp4.js");
import MP4Demuxer from "./demuxer.mjs";

// Status UI. Messages are batched per animation frame.
let pendingStatus = null;

function setStatus(type, message) {
  if (pendingStatus) {
    pendingStatus[type] = message;
  } else {
    pendingStatus = { [type]: message };
    self.requestAnimationFrame(statusAnimationFrame);
  }
}

function statusAnimationFrame() {
  // self.postMessage(pendingStatus);
  pendingStatus = null;
}

// Rendering. Drawing is limited to once per animation frame.
let renderer = null;
let pendingFrame = null;

function renderFrame(frame) {
  if (!pendingFrame) {
    // Schedule rendering in the next animation frame.
    requestAnimationFrame(renderAnimationFrame);
  } else {
    // Close the current pending frame before replacing it.
    pendingFrame.close();
  }
  // Set or replace the pending frame.
  pendingFrame = frame;
}

function renderAnimationFrame() {
  renderer.draw(pendingFrame);
  // const data = renderer.canvas.getImageData();
  // console.log(data);
  pendingFrame = null;
}
// Startup.

var frames = [];
var chunks = [];

setInterval(async () => {
  if (frames.length > 0) {
    const frame = frames.shift();
    renderFrame(frame);
  }
}, 32);

function start({ dataUri, canvas }) {
  // Pick a renderer to use.
  renderer = new Canvas2DRenderer(canvas);
  // Set up a VideoDecoer.
  const decoder = new VideoDecoder({
    async output(frame) {
      frames.push(frame);
    },
    error(e) {
      console.log(e);
    },
  });

  // Fetch and demux the media data.
  var _config = null;

  var chunkCounter = 0;

  const demuxer = new MP4Demuxer(dataUri, {
    onConfig(config) {
      console.log(config);
      _config = config;
      setStatus(
        "decode",
        `${config.codec} @ ${config.codedWidth}x${config.codedHeight}`
      );
    },
    onChunk(chunk) {
      chunkCounter++;
      chunks.push(chunk);
      console.log("chunk", chunkCounter, chunk.data.length);
      console.log(chunks.length);
      // if (chunks.length == 239) {
      //   var index = 0;
      //   decoder.configure(_config);
      //   setInterval(async () => {
      //     index++;
      //     if (index > 238) {
      //       index = 0;
      //     }
      //     decoder.decode(chunks[index]);
      //   }, 32);
      // }
    },
    setStatus,
  });
}

function _decode(dataUri) {}

// Listen for the start request.
self.addEventListener("message", (message) => start(message.data), {
  once: true,
});

class Canvas2DRenderer {
  #canvas = null;
  #ctx = null;

  constructor(canvas) {
    this.#canvas = canvas;
    this.#ctx = canvas.getContext("2d", { willReadFrequently: true });
  }

  draw(frame) {
    this.#canvas.width = frame.displayWidth;
    this.#canvas.height = frame.displayHeight;
    this.#ctx.drawImage(frame, 0, 0, frame.displayWidth, frame.displayHeight);

    self.postMessage({
      pixels: this.#ctx.getImageData(
        0,
        0,
        frame.displayWidth,
        frame.displayHeight
      ).data,
      height: frame.displayHeight,
      width: frame.displayWidth,
    });
    frame.close();
  }
}
