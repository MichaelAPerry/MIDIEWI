export function decode(data) {
  const [status, a, b] = data;
  if (status === undefined || status >= 0xf0) return {kind: "other"};
  const channel = (status & 15) + 1;
  switch (status & 240) {
    case 0x80: return {channel, kind: "off", note: a, velocity: b};
    case 0x90: return {channel, kind: b ? "on" : "off", note: a, velocity: b};
    case 0xb0: return {channel, kind: "cc", controller: a, value: b};
    case 0xd0: return {channel, kind: "pressure", value: a};
    case 0xe0: return {channel, kind: "bend", value: (b << 7) + a - 8192};
    default: return {channel, kind: "other"};
  }
}

export function voices(note, intervals, divisions) {
  return intervals.map(step => 440 * 2 ** ((note - 69) / 12 + step / divisions));
}

export function breathGain(value, exponent) {
  return (Math.max(0, Math.min(127, value)) / 127) ** exponent;
}

// Fade from the played note into its harmony as breath rises.
export function voiceLevels(count, value) {
  const blend = breathGain(value, 1);
  const harmonyLevel = blend / count;
  return Array.from({length: count}, (_, index) =>
    index === 0 ? 1 - blend + harmonyLevel : harmonyLevel);
}
