import {breathGain, decode, voiceLevels, voices} from "./engine.mjs";

const el = id => document.getElementById(id);
const active = new Map();
const expression = new Map();
const recent = [];
let capture;
let audio;
let access;
let input;
let demoTimers = [];

function silence() {
  for (const group of active.values()) release(group);
  active.clear();
  expression.clear();
}

function release(group) {
  const now = audio.currentTime;
  group.gain.gain.setTargetAtTime(0, now, 0.015);
  for (const oscillator of group.oscillators) oscillator.stop(now + 0.12);
}

function setGain(group, value) {
  group.gain.gain.setTargetAtTime(0.15 * breathGain(value, Number(el("curve").value)),
                                 audio.currentTime, 0.025);
  const levels = voiceLevels(group.levels.length, value);
  group.levels.forEach((level, index) => {
    level.gain.setTargetAtTime(levels[index], audio.currentTime, 0.025);
  });
}

function receive(data, time, source) {
  const message = decode(data);
  if (capture?.running && capture.source === source) {
    const ms = Math.max(0, time - capture.start);
    capture.events.push({ms: +ms.toFixed(3), bytes: [...data]});
    if (capture.events.length >= 20000) finish();
  }
  recent.push(`${source} ${JSON.stringify(message)}`);
  if (recent.length > 16) recent.shift();
  el("log").textContent = recent.join("\n");
  if (!audio) return;
  const {channel, kind, note} = message;
  const key = `${source}:${channel}:${note}`;
  const lane = `${source}:${channel}`;
  if (kind === "cc" && message.controller === Number(el("cc").value)) {
    expression.set(lane, message.value);
    for (const group of active.values()) {
      if (group.lane === lane) setGain(group, message.value);
    }
  }
  if (kind !== "on" && kind !== "off") return;
  if (active.has(key)) {
    release(active.get(key));
    active.delete(key);
  }
  if (kind === "off") return;

  const divisions = Number(el("tuning").value);
  const intervals = el("chord").value === "single" ? [0] : divisions === 12 ? [0, 4, 7] : [0, 6, 11];
  const gain = audio.createGain();
  gain.gain.value = 0;
  gain.connect(audio.destination);
  const levels = [];
  const oscillators = voices(note, intervals, divisions).map(frequency => {
    const oscillator = audio.createOscillator();
    const level = audio.createGain();
    level.gain.value = 0;
    levels.push(level);
    oscillator.type = "triangle";
    oscillator.frequency.value = frequency;
    oscillator.connect(level).connect(gain);
    oscillator.start();
    return oscillator;
  });
  const group = {gain, levels, oscillators, lane};
  active.set(key, group);
  setGain(group, expression.get(lane) ?? message.velocity);
}

function selectInput() {
  if (input) input.onmidimessage = null;
  if (capture?.running && capture.source === "MIDI") finish();
  silence();
  input = access.inputs.get(el("ports").value);
  if (input) input.onmidimessage = event => receive(event.data, event.timeStamp, "MIDI");
}

function listInputs() {
  const previous = el("ports").value;
  el("ports").replaceChildren(new Option("Select an input", ""));
  for (const port of access.inputs.values()) el("ports").add(new Option(port.name, port.id));
  if (access.inputs.has(previous)) el("ports").value = previous;
  else selectInput();
}

el("connect").onclick = async () => {
  try {
    access = await navigator.requestMIDIAccess({sysex: false});
    access.onstatechange = listInputs;
    listInputs();
    el("status").textContent = access.inputs.size ? "Choose the instrument input." : "No MIDI inputs available.";
  } catch (error) {
    el("status").textContent = `MIDI unavailable: ${error.message}`;
  }
};
el("ports").onchange = selectInput;

async function startAudio() {
  audio ??= new AudioContext();
  await audio.resume();
  el("audio").textContent = "Audio enabled";
}
el("audio").onclick = startAudio;
el("demo").onclick = async () => {
  await startAudio();
  demoTimers.forEach(clearTimeout);
  silence();
  const cc = Number(el("cc").value);
  if (!Number.isInteger(cc) || cc < 0 || cc > 127) return;
  const demo = [[0, [0xb0, cc, 30]], [10, [0x90, 62, 85]],
                [220, [0xb0, cc, 65]], [480, [0xb0, cc, 115]],
                [850, [0x80, 62, 0]]];
  demoTimers = demo.map(([ms, data]) =>
    setTimeout(() => receive(data, performance.now(), "demo"), ms));
};

function finish() {
  capture.running = false;
  el("record").textContent = "Start capture";
  el("save").disabled = false;
  el("status").textContent = `Captured ${capture.events.length} ${capture.source} messages.`;
}
el("record").onclick = () => {
  if (capture?.running) return finish();
  capture = {source: input ? "MIDI" : "demo", exercise: el("exercise").value,
             running: true, start: performance.now(), events: []};
  el("status").textContent = `Recording ${capture.source}.`;
  el("record").textContent = "Stop capture";
  el("save").disabled = true;
};
el("save").onclick = () => {
  const {source, exercise, events} = capture;
  const blob = new Blob([JSON.stringify({source, exercise, events}, null, 2)], {type: "application/json"});
  const url = URL.createObjectURL(blob);
  const link = Object.assign(document.createElement("a"), {href: url, download: "midiewi-capture.json"});
  link.click();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
};
