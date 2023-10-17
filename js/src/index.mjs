import { createWeb3Modal, defaultWagmiConfig } from "@web3modal/wagmi";

import { mainnet, arbitrum } from "@wagmi/core/chains";
import { watchAccount, disconnect, getAccount } from "@wagmi/core";
import MP4Demuxer from "./demuxer.mjs";
import { SiweMessage } from "siwe";
import { signMessage } from "@wagmi/core";

// 1. Define constants
const projectId = "4981f85de0414a5c8dbb5fe6b44e90d7";

// 2. Create wagmiConfig
const metadata = {
  name: "Web3Modal",
  description: "Web3Modal Example",
  url: "https://web3modal.com",
  icons: ["https://avatars.githubusercontent.com/u/37784886"],
};

const domain = window.location.host;
const origin = window.location.origin;
const BACKEND_ADDR = "https://api-dev.mittaria.io";

////////////////////////////////////////////////////////////////////////
async function createSiweMessage(address, statement) {
  const res = await fetch(`${BACKEND_ADDR}/nonce`);

  const message = new SiweMessage({
    domain,
    address,
    statement,
    uri: origin,
    version: "1",
    chainId: "1",
    nonce: (await res.text()).nonce,
  });
  return message.prepareMessage();
}

window.signInWithEthereum = async function signInWithEthereum(callback) {
  if (!getAccount().isConnected) {
    alert("Please connect your wallet first.");
    await modal.open();
    return;
  }
  console.log("signing in with ethereum", getAccount().address);
  const message = await createSiweMessage(
    getAccount().address,
    "Sign in with Ethereum to the app."
  );
  const signature = await signMessage({ message });

  const res = await fetch(`${BACKEND_ADDR}/me`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ message, signature }),
  });
  callback(await res.text());
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
  window.accountChangedCallback(getAccount().address)
  watchAccount((account) => {
    if (account.isConnected) {
      window.accountChangedCallback(account.address);
    } else {
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
const canvas = document.createElement("canvas");
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
  // decoder.ondequeue = (ev) => {
  //   console.log("decoder has been dequeued", ev);
  // }
  // decoder.reset();
  // decoder.flush().then(() => console.log("decoder has been flushed"));
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

window.loadVideoChunks = async (url, onDone) => {
  const demuxer = new MP4Demuxer(url, {
    onConfig(config) {
      _config = config;
    },
    onChunk(chunk) {
      _chunks.push(chunk);
      console.log(chunk);
      if (_chunks.length == 239) {
        onDone();
      }
    },
    setStatus,
  });
};

window.decodeFrames = async (onFrame) => {
  const decoder = new VideoDecoder({
    async output(frame) {
      const { pixels, height, width } = renderer.draw(frame);
      onFrame(pixels, width, height);
      frame.close();
    },
    error(e) {
      console.log(e);
    },
  });

  let currentFrame = 0;
  decoder.configure(_config);

  setInterval(async () => {
    if (currentFrame > 238) {
      currentFrame = 0;
      await decoder.flush();
      decoder.reset();
      decoder.configure(_config);
    }

    decoder.decode(_chunks[currentFrame]);
    currentFrame++;
  }, 32);
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
