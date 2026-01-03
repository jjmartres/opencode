# API Quick Reference

Fast reference for common Reachy Mini SDK operations.

## Connection

```python
from reachy_mini import ReachyMini

# Local
with ReachyMini() as mini:
    pass

# Remote
with ReachyMini(localhost_only=False) as mini:
    pass

# With media backend
with ReachyMini(media_backend="default") as mini:
    pass
```

## Head Movement

```python
from reachy_mini.utils import create_head_pose
import numpy as np

# Look up
mini.goto_target(
    head=create_head_pose(z=10, mm=True),
    duration=1.0
)

# Tilt head
mini.goto_target(
    head=create_head_pose(roll=15, degrees=True),
    duration=1.0
)

# Nod
mini.goto_target(
    head=create_head_pose(pitch=-15, degrees=True),
    duration=0.5
)

# Shake head
mini.goto_target(
    head=create_head_pose(yaw=20, degrees=True),
    duration=0.3
)

# Combined
mini.goto_target(
    head=create_head_pose(
        x=5, y=-3, z=10,
        roll=15, pitch=10, yaw=-5,
        mm=True, degrees=True
    ),
    duration=2.0
)
```

## Antennas

```python
# Happy (up)
mini.goto_target(antennas=np.deg2rad([45, 45]), duration=0.5)

# Sad (down)
mini.goto_target(antennas=np.deg2rad([-30, -30]), duration=0.5)

# Curious (asymmetric)
mini.goto_target(antennas=np.deg2rad([45, -45]), duration=0.5)

# Neutral
mini.goto_target(antennas=[0.0, 0.0], duration=0.5)

# Wiggle
for _ in range(3):
    mini.goto_target(antennas=np.deg2rad([30, -30]), duration=0.2)
    mini.goto_target(antennas=np.deg2rad([-30, 30]), duration=0.2)
```

## Body Rotation

```python
# Turn right 90°
mini.goto_target(body_yaw=np.deg2rad(-90), duration=2.0)

# Turn left 90°
mini.goto_target(body_yaw=np.deg2rad(90), duration=2.0)

# Turn around (180°)
mini.goto_target(body_yaw=np.deg2rad(180), duration=3.0)

# Return to front
mini.goto_target(body_yaw=0.0, duration=2.0)
```

## Combined Movement

```python
# Move everything
mini.goto_target(
    head=create_head_pose(z=10, roll=15, degrees=True, mm=True),
    antennas=np.deg2rad([45, 45]),
    body_yaw=np.deg2rad(30),
    duration=2.0,
    method="minjerk"
)
```

## Camera

```python
# Get frame
frame = mini.media.get_frame()  # numpy (H, W, 3), uint8, BGR

# Display
import cv2
cv2.imshow("Camera", frame)
cv2.waitKey(0)

# Save
cv2.imwrite("frame.jpg", frame)

# RGB conversion
frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
```

## Microphone

```python
# Record
samples = mini.media.get_audio_sample()  # (N, 2), float32, 16kHz

# Get properties
rate = mini.media.get_input_audio_samplerate()  # 16000
channels = mini.media.get_input_channels()  # 2

# Play (non-blocking)
mini.media.push_audio_sample(samples)

# Convert to mono
samples_mono = samples.mean(axis=1)
```

## Motion Recording

```python
# Record
mini.start_recording()
# ... perform movements ...
motion = mini.stop_recording()

# Save
motion.save("my_motion.pkl")

# Load
from reachy_mini import Motion
motion = Motion.load("my_motion.pkl")

# Play
motion.play()
```

## IMU (Wireless only)

```python
# Get data
if hasattr(mini, 'imu'):
    data = mini.imu.get_data()
    accel = data.acceleration  # [x, y, z] m/s²
    gyro = data.gyroscope      # [x, y, z] rad/s
    orient = data.orientation  # [roll, pitch, yaw] radians
```

## AI Integration

```python
# Object detection
from transformers import pipeline
detector = pipeline("object-detection")
results = detector(frame_rgb)

# Speech recognition
recognizer = pipeline("automatic-speech-recognition")
result = recognizer(samples_mono, sampling_rate=16000)
text = result['text']

# Text-to-speech
tts = pipeline("text-to-speech")
audio = tts("Hello world")
mini.media.push_audio_sample(audio["audio"])

# Image captioning
from transformers import BlipProcessor, BlipForConditionalGeneration
processor = BlipProcessor.from_pretrained("Salesforce/blip-image-captioning-base")
model = BlipForConditionalGeneration.from_pretrained("Salesforce/blip-image-captioning-base")
inputs = processor(image, return_tensors="pt")
outputs = model.generate(**inputs)
caption = processor.decode(outputs[0], skip_special_tokens=True)
```

## Error Handling

```python
try:
    with ReachyMini(localhost_only=False) as mini:
        mini.goto_target(antennas=[0.5, 0.5], duration=1.0)
except ConnectionError:
    print("Cannot connect to robot")
except Exception as e:
    print(f"Error: {e}")
```

## Interpolation Methods

```python
# Linear (constant velocity)
mini.goto_target(..., method="linear")

# Minimum jerk (smooth, natural)
mini.goto_target(..., method="minjerk")

# Ease in/out
mini.goto_target(..., method="ease")

# Cartoon (exaggerated)
mini.goto_target(..., method="cartoon")
```

## Utility Functions

```python
# Angle conversions
angle_rad = np.deg2rad(45)
angle_deg = np.rad2deg(angle_rad)

# Time delays
import time
time.sleep(1.0)

# Array creation
left_right = [np.deg2rad(45), np.deg2rad(-45)]
neutral = [0.0, 0.0]
```

## Common Behaviors

```python
# Greet
def greet():
    mini.goto_target(
        head=create_head_pose(z=5, mm=True),
        antennas=np.deg2rad([45, 45]),
        duration=0.5
    )
    for _ in range(2):
        mini.goto_target(head=create_head_pose(pitch=-10, degrees=True), duration=0.3)
        mini.goto_target(head=create_head_pose(pitch=10, degrees=True), duration=0.3)

# Scan environment
def scan():
    for angle in [-60, -30, 0, 30, 60, 0]:
        mini.goto_target(
            body_yaw=np.deg2rad(angle),
            head=create_head_pose(z=5, mm=True),
            duration=1.0
        )
        time.sleep(0.5)

# Express happiness
def happy():
    mini.goto_target(
        head=create_head_pose(z=8, roll=10, mm=True, degrees=True),
        antennas=np.deg2rad([45, 45]),
        duration=0.5
    )
```

## Platform Detection

```python
import platform

system = platform.system()
if system == "Linux":
    # Raspberry Pi or Linux PC
    pass
elif system == "Darwin":
    # macOS
    pass
elif system == "Windows":
    # Windows
    pass
```

## Media Backend Selection

```python
# Auto-detect
with ReachyMini() as mini:  # Uses best backend for platform

# Force specific backend
with ReachyMini(media_backend="default") as mini:  # OpenCV
with ReachyMini(media_backend="gstreamer") as mini:  # GStreamer
with ReachyMini(media_backend="webrtc") as mini:  # WebRTC (remote)
```

## Performance Tips

1. Use `set_target()` for high-frequency control (>30 Hz)
2. Batch movements with `goto_target()` for efficiency
3. Use appropriate durations (0.5-2.0s typically)
4. Choose "minjerk" for most natural motion
5. Test in simulation first
6. Monitor network latency for remote control
