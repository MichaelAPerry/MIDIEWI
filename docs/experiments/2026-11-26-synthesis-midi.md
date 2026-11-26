# 2026-11-26 DC02 synthesis via MIDI

## Setup and repeatability

Windows PowerShell 5.1 sent short WinMM messages to the USB MIDI output. FFmpeg 6.0 recorded the DC02 analog output through PreSonus Studio 68c inputs 1/2, stereo PCM at 44.1 kHz. The port map for this run was `OUT 1 USB MIDI`. Refresh it before running a probe.

```powershell
.\tools\windows-midi-probe.ps1 -Mode List
ffmpeg -nostdin -hide_banner -f dshow -audio_buffer_size 50 -i 'audio=Mic/Inst/Line In 1/2 (Studio 68c)' -t 48 -c:a pcm_s16le captures/synth-p0.wav
# In a second shell, after the recorder starts:
.\tools\windows-midi-probe.ps1 -Mode Synthesis -TestProgram 0 -OutputIndex 1 -Timestamp > captures/synth-p0.log
```

Repeat for programs 3 and 7. Use `ChannelMap` and `Refine` separately to measure channel response and isolate effects. The dedicated `sync` tone aligns host timestamps with WAV time. FFmpeg and WinMM timings fluctuate, so onset and release metrics are approximate and this setup does not measure absolute latency. NumPy 2.2.6 measures RMS, clipping, harmonic power, spectral centroid, 5 ms envelope blocks, release above −20 dB relative to the held RMS, and pitch in short Hann windows. The strongest detected pitch can jump to a harmonic on a glide or heavily reverberated patch.

```sh
python3 tools/synth-measure.py captures/synth-p0.wav captures/synth-p0.log
```

## Reference implementations

Dream's SAM2695 and 5504-MIDI-MIC references list modulation, effects sends and RPN 0–2. They describe several filter, envelope and vibrato settings as GS NRPNs, so absent responses to the standardized sound-controller CCs cannot exclude an internal filter/envelope or identify any processor. The comparison uses documented standard short messages. [SAM2695 MIDI section](https://docs.dream.fr/pdf/Serie2000/SAM_Datasheets/SAM2695.pdf) · [5504-MIDI-MIC firmware](https://docs.dream.fr/pdf/Serie5000/Firmwares/Firm5504-MIDI-MIC.pdf)
