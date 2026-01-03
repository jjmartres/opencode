# Reachy Mini SDK Installation Guide

Complete installation instructions for all platforms and configurations.

## Prerequisites

- **Python**: 3.12 or later
- **Operating System**: Linux, macOS, or Windows
- **Hardware**: Reachy Mini (Wireless or Lite) or simulation environment

## Installation Methods

### Method 1: Using uv (Recommended)

**Fastest installation (10-100x faster than pip):**

1. Install uv:

```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows (PowerShell)
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

2. Create virtual environment:

```bash
uv venv reachy-env
```

3. Activate environment:

```bash
# Linux/macOS
source reachy-env/bin/activate

# Windows
reachy-env\Scripts\activate
```

4. Install SDK:

```bash
uv pip install reachy-mini
```

### Method 2: Using pip

1. Create virtual environment:

```bash
python -m venv reachy-env
```

2. Activate environment:

```bash
# Linux/macOS
source reachy-env/bin/activate

# Windows
reachy-env\Scripts\activate
```

3. Install SDK:

```bash
pip install reachy-mini
```

## Platform-Specific Setup

### Reachy Mini Wireless

**Requirements:**

- WiFi network connection to robot
- GStreamer (for remote control from computer)

**GStreamer Installation:**

**macOS:**

```bash
brew install gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav
```

**Ubuntu/Debian:**

```bash
sudo apt-get install -y \
    gstreamer1.0-tools gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly gstreamer1.0-libav
```

**Windows:**
Download and install from https://gstreamer.freedesktop.org/download/

### Reachy Mini Lite

**Requirements:**

- USB connection to robot
- Serial port permissions (Linux only)

**Linux USB Permissions:**

```bash
# Create udev rules
echo 'SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55d3", MODE="0666", GROUP="dialout"
SUBSYSTEM=="tty", ATTRS{idVendor}=="38fb", ATTRS{idProduct}=="1001", MODE="0666", GROUP="dialout"' \
| sudo tee /etc/udev/rules.d/99-reachy-mini.rules

# Reload rules
sudo udevadm control --reload-rules && sudo udevadm trigger

# Add user to dialout group
sudo usermod -aG dialout $USER

# Reboot required
sudo reboot
```

### Simulation

**Requirements:**

- MuJoCo physics engine
- No hardware needed

**Installation:**

```bash
uv pip install reachy-mini[simulation]
# or
pip install reachy-mini[simulation]
```

## Verification

**Test installation:**

```python
from reachy_mini import ReachyMini

# This should not raise any import errors
print("Reachy Mini SDK imported successfully!")
```

**Check version:**

```python
import reachy_mini
print(f"SDK Version: {reachy_mini.__version__}")
```

## Development Installation

**For SDK contributors:**

```bash
# Clone repository
git clone https://github.com/pollen-robotics/reachy_mini.git
cd reachy_mini

# Install in editable mode with dev dependencies
uv pip install -e ".[dev]"
# or
pip install -e ".[dev]"
```

## Troubleshooting

### Import Errors

**Problem**: `ModuleNotFoundError: No module named 'reachy_mini'`

**Solution**:

- Ensure virtual environment is activated
- Reinstall: `uv pip install --force-reinstall reachy-mini`
- Check Python version: `python --version` (must be 3.8+)

### Permission Denied (Linux)

**Problem**: Cannot access serial port

**Solution**:

- Follow USB permissions setup above
- Verify user in dialout group: `groups`
- Reboot system

### GStreamer Not Found

**Problem**: Media backend fails to initialize

**Solution**:

- Install GStreamer (see platform-specific instructions)
- Verify installation: `gst-launch-1.0 --version`
- Use "default" media backend if GStreamer unavailable

### Network Connection Issues (Wireless)

**Problem**: Cannot connect to robot

**Solution**:

- Verify robot WiFi is on
- Check robot IP address
- Test ping: `ping <robot-ip>`
- Ensure firewall allows connection
- Use `localhost_only=False` in SDK constructor

## Additional Dependencies

### For AI Applications

```bash
uv pip install reachy-mini[ai]
# Includes: transformers, torch, etc.
```

### For Full Installation

```bash
uv pip install reachy-mini[full]
# Includes all optional dependencies
```

## Next Steps

After successful installation:

1. Start the daemon (see Quickstart Guide)
2. Run your first program
3. Explore SDK examples
4. Build your first AI application
