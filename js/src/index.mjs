import { createWeb3Modal, defaultWagmiConfig } from "@web3modal/wagmi";

import { mainnet, arbitrum } from "@wagmi/core/chains";
import { watchAccount, disconnect, getAccount } from "@wagmi/core";
import MP4Demuxer from "./demuxer.mjs";

// 1. Define constants
const projectId = "4981f85de0414a5c8dbb5fe6b44e90d7";

// 2. Create wagmiConfig
const metadata = {
  name: "Web3Modal",
  description: "Web3Modal Example",
  url: "https://web3modal.com",
  icons: ["https://avatars.githubusercontent.com/u/37784886"],
};

const chains = [mainnet, arbitrum];
const wagmiConfig = defaultWagmiConfig({ chains, projectId, metadata });

// 3. Create modal
const modal = createWeb3Modal({ wagmiConfig, projectId, chains });

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
    // frame.close();
    return {
      pixels: this.#ctx.getImageData(
        0,
        0,
        frame.displayWidth,
        frame.displayHeight
      ).data,
      height: frame.displayHeight,
      width: frame.displayWidth,
    };
  }
}

window.connect = async function connect() {
  if (getAccount().isConnected) {
    await disconnect();
    modal.open();
  } else {
    modal.open();
  }
};

window.disconnect = async function disconnect() {
  await disconnect();
};

window.init = () => {
  // listening for account changes
  watchAccount((account) => {
    if (account.isConnected) {
      eval({ name: "onAccountChanged", address: account.address });
      window.accountChangedCallback(account.address);
    } else {
      eval({ name: "onAccountChanged", address: null });
      window.accountChangedCallback(null);
    }
  });
};

window.playBgMusic = function playBgMusic() {
  console.log("playBgMusic from bundle");
  document.getElementById("bg-player").play();
};

window.pauseBgMusic = function pauseBgMusic() {
  console.log("pauseBgMusic from bundle");
  document.getElementById("bg-player").pause();
};

window.toggleMusic = function toggleMusic() {
  console.log("toggleMusic from bundle");
  const player = document.getElementById("bg-player");
  if (player.volume === 0) {
    player.volume = 1;
  } else {
    player.volume = 0;
  }
};

let _chunks = [];
let _frames = [];
let _config = null;
const canvas = document.getElementById("video-decoder");
const renderer = new Canvas2DRenderer(canvas);
let decoder;

let _onFrameCallback;

window.loadVideo = async (url, onFrameCallback, onDone) => {
  _onFrameCallback = onFrameCallback;
  decoder = new VideoDecoder({
    async output(frame) {
      if (_frames.length < 239) {
        _frames.push(frame);
        // const frame = _frames.shift();
        // frame.close();
      }
      if (_frames.length == 239) {
        onDone();
      }
      // const { pixels, height, width } = renderer.draw(frame);
      // // frame.close();
      // _onFrameCallback(pixels, width, height);
    },
    error(e) {
      console.log(e);
    },
  });
  const { chunks, config } = await getVideoChunks(url, decoder);
  _chunks = chunks;
  _config = config;
};

// let currentFrame = 0;

// window.decodeNextFrame = () => {
//   currentFrame++;
//   if (currentFrame >= chunks.length) {
//     currentFrame = 0;
//   }
//   decoder.decode(chunks[currentFrame]);
// };

// Frame sequences:
// 1-100 is idle
// 101-138 is the rotation
window.decodeFrameByIndex = (index) => {
  if (_frames.length == 239) {
    const { pixels, height, width } = renderer.draw(_frames[index]);
    // frame.close();
    _onFrameCallback(pixels, width, height);
    return;
  }
  decoder.decode(_chunks[index]);
};

async function getVideoChunks(url, decoder) {
  var chunks = [];
  var _config = null;

  return new Promise((resolve, reject) => {
    const demuxer = new MP4Demuxer(url, {
      onConfig(config) {
        _config = config;
        decoder.configure(config);
      },
      onChunk(chunk) {
        decoder.decode(chunk);
        chunks.push(chunk);
        if (chunks.length == 239) {
          resolve({ chunks, config: _config });
        }
      },
      setStatus,
    });
  });
}

function setStatus(type, message) {
  console.log(type, message);
}
