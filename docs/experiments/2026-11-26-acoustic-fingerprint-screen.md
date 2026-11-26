# 2026-11-26 Acoustic fingerprint screen

Can the existing original-style DC02 line recordings discriminate a known Dream synth? I screened the ten bank-0/0 C4 patches against two public music recordings attributed by their recorders to SAM2695 devices. The references do not give isolated notes with known program, bank, velocity, controller state or effects settings. They are useful for testing the specificity of harmonic similarity. [DC02 capture](2026-11-26-usb-midi-output.md) · [MIDI-Guy SAM2695 recording](https://www.youtube.com/watch?v=nxCGTBradRw) · [DreamBlaster S2 recording](https://www.youtube.com/watch?v=L36-k3zRvtM)

## Method

1. Download the public references as Opus format 251 with yt-dlp 2026.11.23. Keep reference audio and EWI line recordings local.
2. Use FFmpeg 7.0.2 to decode channel 1 only and resample to 22,050 Hz float PCM (`-af 'pan=mono|c0=c0' -ar 22050 -f f32le`).
3. Read the first ten Note On events (MIDI note 60, velocity 90) from the EWI catalog log. Align the first to 2.10 s as in the catalog experiment, apply relative host timestamps, and use a 180 ms window starting 40 ms after each aligned onset.
4. Step through each reference in 180 ms windows at 20 ms intervals. With NumPy 2.2.6, apply Hann and compute one-sided FFT bin power. Integrate within ±10 Hz of each of the first 12 harmonics of 261.6256 Hz. Retain reference windows with at least 85% of non-DC-region power (excluding the first five bins) in those bands, RMS ≥ 0.01 FS, and normalized fundamental amplitude ≥ 0.25. This only screens C4-like spectra. It can also select non-C4 notes with appropriate harmonics or a mixture.
5. Take square roots of the 12 band powers and L2-normalize. Report maximum cosine similarity to each reference for each EWI voice. This discards gain, phase and attack shape. Overlapping windows are correlated.

## Observations

The 1,633 s MIDI-Guy recording yielded 11 windows. The 5,780 s S2 recording yielded 162. Time is the start of the best reference window, in video seconds.

| EWI program | MIDI-Guy time | Similarity | S2 time | Similarity |
| --- | ---: | ---: | ---: | ---: |
| 0 | 298.98 | 0.810 | 3949.02 | 0.998 |
| 1 | 86.62 | 0.800 | 1821.58 | 0.895 |
| 2 | 298.98 | 0.873 | 4917.54 | 0.990 |
| 3 | 298.98 | 0.711 | 4919.60 | 0.908 |
| 4 | 298.98 | 0.803 | 4919.60 | 0.986 |
| 5 | 1488.16 | 0.759 | 902.02 | 0.824 |
| 6 | 86.66 | 0.859 | 3939.86 | 0.904 |
| 7 | 298.98 | 0.487 | 538.32 | 0.952 |
| 8 | 298.98 | 0.919 | 4873.04 | 0.986 |
| 9 | 86.60 | 0.734 | 771.46 | 0.940 |

S2 gives the higher maximum on every EWI patch, despite both comparators being reported as the same silicon. It also supplies nearly 15 times as many eligible windows. Six distinct EWI programs select the identical MIDI-Guy window. Even a cosine near 0.998 can reflect a common tone shape or a larger search pool. There is no different-silicon negative control in this screen. These scores provide no processor attribution and do not distinguish custom voicing from shared sample content.

The published SAM2695 voice map describes a full GM bank, whereas our unit produced ten sounding programs in the tested bank, silence on tested channel-10 percussion, and unchanged responses for the tested alternate-bank selections. That weighs against transparent pass-through to the stock SAM2695 map. A translation or filter in the product, or a different sound bank on another chip, remains possible. A useful next acoustic comparator would give isolated matching notes across multiple pitches and velocities, with patch mapping and effects documented. Attack and loop alignment would then test sample ancestry independently of processor identity. [SAM2695 voice map](https://docs.dream.fr/pdf/Serie2000/SAM_Datasheets/SAM2695.pdf)
