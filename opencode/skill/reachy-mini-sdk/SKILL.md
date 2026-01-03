---
name: reachy-mini-sdk
description: Comprehensive guide for programming Reachy Mini robot using Python SDK v1.2.6. Use when working with Reachy Mini robot control, motion programming, sensor access, audio/video processing, or building AI applications. Covers movement control (head, antennas, body), camera/microphone access, motion recording/playback, coordinate systems, and Hugging Face integration. Essential for robotics development, AI experimentation, and interactive applications.
license: MIT
compatibility: opencode
---

# Reachy Mini SDK Programming Guide

Expert guidance for programming Reachy Mini - an open-source expressive desktop humanoid robot. This skill provides comprehensive knowledge of the Python SDK v1.2.6 for movement control, sensor access, and AI application development.

## When to Use This Skill

Use this skill when:

- Writing code to control Reachy Mini robot
- Building AI applications for Reachy Mini
- Creating interactive behaviors or demos
- Accessing cameras, microphones, or IMU sensors
- Recording and replaying robot motions
- Integrating with Hugging Face models
- Deploying apps to Hugging Face Spaces
- Troubleshooting Reachy Mini SDK issues
- Converting between coordinate systems

## Core Concepts

### Robot Architecture

**Hardware Overview:**

- **Head**: 6-DOF Stewart platform (pitch, roll, yaw + XYZ translation)
- **Antennas**: 2 servos for expressive movements
- **Body**: Single rotation servo (360° yaw)
- **Camera**: USB camera in head
- **Microphone**: USB microphone
- **IMU**: Inertial Measurement Unit (Wireless version only)
- **Speaker**: Audio output

**Software Architecture:**

- **Daemon**: Background service (FastAPI) handling hardware communication
- **SDK**: Python library for high-level control
- **Media Backend**: Handles camera/audio (OpenCV/GStreamer/WebRTC)

### Installation Requirements

Read `references/installation.md` for complete setup instructions covering:

- Virtual environment setup
- Package installation (uv or pip)
- Platform-specific configuration (Wireless/Lite/Simulation)
- GStreamer setup for remote control
- USB permissions (Linux)

## SDK Fundamentals

### Connection Patterns

**Local connection (same machine as robot):**

```python
from reachy_mini import ReachyMini

with ReachyMini() as mini:
    # Your code here
```

**Remote connection (controlling from another computer):**

```python
from reachy_mini import ReachyMini

with ReachyMini(localhost_only=False) as mini:
    # Your code here
```

**Media backend selection:**

- `media_backend="default"` - OpenCV + Sounddevice (recommended)
- `media_backend="gstreamer"` - GStreamer for both camera and audio
- `media_backend="webrtc"` - Automatic for remote connections

### Movement Control

Read `references/movement_control.md` for detailed movement programming:

**High-level control (goto_target):**

- Smooth interpolated movements
- Control head, antennas, body_yaw simultaneously
- Multiple interpolation methods (linear, minjerk, ease, cartoon)
- Safety limits enforced automatically

**Low-level control (set_target):**

- Direct position setting without interpolation
- For high-frequency control (e.g., joystick tracking)
- User responsible for safety limits

**Coordinate systems:**

- Head: Cartesian (X, Y, Z) + Orientation (roll, pitch, yaw)
- Antennas: Joint angles in radians
- Body: Yaw angle in radians

### Sensor Access

Read `references/sensors.md` for complete sensor documentation:

**Camera:**

- Get frames as numpy arrays (height, width, 3)
- Configure backend based on setup (local/remote)
- Real-time video streaming

**Audio:**

- Record: `get_audio_sample()` - 16kHz, 2-channel
- Playback: `push_audio_sample()` - Non-blocking
- Resample if needed using scipy

**IMU (Wireless only):**

- 3-axis accelerometer and gyroscope
- Orientation estimation
- Motion detection

### Motion Recording

**Record and replay motions:**

```python
mini.start_recording()
# Move robot or execute commands
motion = mini.stop_recording()

# Save for later
motion.save("my_motion.pkl")

# Replay
motion.play()
```

## Common Patterns

### Basic Movement Example

```python
from reachy_mini import ReachyMini
from reachy_mini.utils import create_head_pose
import numpy as np

with ReachyMini() as mini:
    # Move head, antennas, and body together
    mini.goto_target(
        head=create_head_pose(z=10, roll=15, degrees=True, mm=True),
        antennas=np.deg2rad([45, 45]),
        body_yaw=np.deg2rad(30),
        duration=2.0,
        method="minjerk"
    )
```

### Camera Access Example

```python
from reachy_mini import ReachyMini

with ReachyMini(media_backend="default") as mini:
    frame = mini.media.get_frame()
    # frame is numpy array (height, width, 3), dtype uint8
```

### Audio Recording Example

```python
from reachy_mini import ReachyMini
from scipy.signal import resample
import time

with ReachyMini(media_backend="default") as mini:
    # Record
    samples = mini.media.get_audio_sample()

    # Resample if needed
    input_rate = mini.media.get_input_audio_samplerate()
    output_rate = mini.media.get_output_audio_samplerate()
    samples = resample(samples, output_rate * len(samples) / input_rate)

    # Play (non-blocking)
    mini.media.push_audio_sample(samples)
    time.sleep(len(samples) / output_rate)
```

## AI Integration

Read `references/ai_integration.md` for comprehensive AI usage:

**Hugging Face Integration:**

- Pre-built apps: Conversation, Radio, Hand Tracker
- One-click installation from robot dashboard
- Deploy custom apps to Hugging Face Spaces

**LLM Integration:**

- Use SDK with any LLM (OpenAI, Anthropic, Hugging Face)
- Combine vision (camera) + audio (microphone) for multimodal
- Real-time conversational interfaces

**Example app structure:**

- FastAPI backend communicating with robot
- Gradio or Streamlit frontend
- Environment variables for configuration
- Docker deployment to HF Spaces

## Platform-Specific Notes

**Reachy Mini (Wireless):**

- Runs onboard Raspberry Pi 4
- Includes IMU sensor
- Battery powered, WiFi connection
- Use `localhost_only=False` from remote computer

**Reachy Mini Lite:**

- USB connection to computer
- No IMU
- Wall powered
- Use `localhost_only=True`

**Simulation:**

- MuJoCo-based simulation
- No hardware required
- Perfect for prototyping
- Same SDK API

## Safety and Best Practices

1. **Always use context manager** (`with ReachyMini() as mini:`)
2. **Respect safety limits** - SDK enforces them automatically
3. **Handle exceptions** - Robot communication can fail
4. **Test in simulation first** - Validate behavior safely
5. **Gradual movements** - Use appropriate durations
6. **Check daemon health** - Ensure daemon is running
7. **Resource cleanup** - Context manager handles this

## Troubleshooting

Common issues and solutions:

**Connection fails:**

- Verify daemon is running
- Check network connectivity (wireless)
- Verify USB connection (lite)
- Check firewall settings

**Movements jerky:**

- Increase duration parameter
- Use "minjerk" interpolation method
- Check for competing processes

**No camera/audio:**

- Verify media_backend selection
- Check GStreamer installation (remote)
- Test USB connections
- Restart daemon

**Permission denied (Linux):**

- Add user to dialout group
- Apply udev rules
- Reboot after changes

## Resources

### references/installation.md

Complete installation guide for all platforms with troubleshooting.

### references/movement_control.md

Detailed movement programming including coordinate systems, interpolation methods, and advanced control patterns.

### references/sensors.md

Comprehensive sensor access documentation for camera, microphone, and IMU.

### references/ai_integration.md

Guide to integrating AI models, building apps, and deploying to Hugging Face.

### references/api_quick_reference.md

Quick reference card for common SDK operations.

## Code Quality Standards

When generating code:

1. **Use context managers** for robot connection
2. **Add type hints** for clarity
3. **Include docstrings** (Google Style)
4. **Handle exceptions** appropriately
5. **Use meaningful variable names**
6. **Comment complex logic**
7. **Follow PEP 8** style guidelines
8. **Test incrementally** - build up complexity

## Version Information

This skill is based on:

- Reachy Mini SDK v1.2.6
- Python 3.8+
- Source: https://github.com/pollen-robotics/reachy_mini/tree/1.2.6

## Getting Help

- Official Documentation: GitHub repository
- Community: Discord server
- Issue Tracker: GitHub Issues
- Hugging Face Hub: hf.co/reachy-mini
