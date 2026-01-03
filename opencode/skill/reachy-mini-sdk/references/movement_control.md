# Movement Control Reference

Comprehensive guide to controlling Reachy Mini's movements using the Python SDK.

## Movement Hierarchy

Reachy Mini has three main controllable parts:

1. **Head**: 6-DOF Stewart platform (X, Y, Z position + roll, pitch, yaw orientation)
2. **Antennas**: 2 servos for expressive movements
3. **Body**: Single rotation servo (360° yaw)

## Control Methods

### High-Level Control: goto_target()

**Smooth, interpolated movements with safety checks.**

```python
mini.goto_target(
    head=head_pose,        # HeadPose object or None
    antennas=[left, right],  # List of 2 floats (radians) or None
    body_yaw=angle,          # Float (radians) or None
    duration=1.0,            # Movement duration in seconds
    method="minjerk"         # Interpolation method
)
```

**Parameters:**

- `head`: HeadPose object (use `create_head_pose()`)
- `antennas`: [left_angle, right_angle] in radians
- `body_yaw`: Body rotation in radians
- `duration`: Time to complete movement (seconds)
- `method`: Interpolation method

**Interpolation Methods:**

- `"linear"`: Constant velocity
- `"minjerk"`: Smooth acceleration/deceleration (default, most natural)
- `"ease"`: Ease in/out
- `"cartoon"`: Exaggerated, cartoon-like motion

**Example:**

```python
from reachy_mini import ReachyMini
from reachy_mini.utils import create_head_pose
import numpy as np

with ReachyMini() as mini:
    # Move everything simultaneously
    mini.goto_target(
        head=create_head_pose(z=10, roll=15, degrees=True, mm=True),
        antennas=np.deg2rad([45, -45]),
        body_yaw=np.deg2rad(30),
        duration=2.0,
        method="minjerk"
    )
```

### Low-Level Control: set_target()

**Direct position setting without interpolation.**

```python
mini.set_target(
    head=head_pose,
    antennas=[left, right],
    body_yaw=angle
)
```

**Use Cases:**

- High-frequency control (>30 Hz)
- Joystick tracking
- Real-time trajectory following
- Custom interpolation

**Important:**

- No automatic interpolation
- User responsible for smooth movements
- Safety limits still enforced
- Faster execution than goto_target()

**Example:**

```python
import time

# High-frequency control loop
for t in np.linspace(0, 2*np.pi, 100):
    head_pose = create_head_pose(
        z=5*np.sin(t),
        roll=10*np.cos(t),
        mm=True,
        degrees=True
    )
    mini.set_target(head=head_pose)
    time.sleep(0.01)  # 100 Hz control
```

## Head Control

### Coordinate System

**Head position:**

- **X**: Forward/backward (mm)
- **Y**: Left/right (mm)
- **Z**: Up/down (mm)
- Origin: Center of head platform in neutral position

**Head orientation:**

- **Roll**: Rotation around forward axis (degrees or radians)
- **Pitch**: Nod up/down (degrees or radians)
- **Yaw**: Turn left/right (degrees or radians)

### Creating Head Poses

**Using create_head_pose():**

```python
from reachy_mini.utils import create_head_pose

# Position only (Z-axis up, 10mm)
pose = create_head_pose(z=10, mm=True)

# Orientation only (roll 15°)
pose = create_head_pose(roll=15, degrees=True)

# Combined position and orientation
pose = create_head_pose(
    x=5, y=-3, z=10,      # Position in mm
    roll=15, pitch=10, yaw=-5,  # Orientation in degrees
    mm=True,
    degrees=True
)

# Using radians and meters (default)
pose = create_head_pose(
    z=0.010,  # 10mm in meters
    roll=0.26,  # ~15 degrees in radians
    mm=False,
    degrees=False
)
```

**HeadPose object:**

```python
pose.position  # numpy array [x, y, z]
pose.orientation  # numpy array [roll, pitch, yaw]
```

### Head Movement Limits

**Position limits (approximate):**

- X: ±10 mm
- Y: ±10 mm
- Z: ±15 mm

**Orientation limits (approximate):**

- Roll: ±20°
- Pitch: ±20°
- Yaw: ±20°

**SDK enforces limits automatically.**

### Head Movement Examples

**Look up:**

```python
mini.goto_target(
    head=create_head_pose(z=10, mm=True),
    duration=1.0
)
```

**Tilt head:**

```python
mini.goto_target(
    head=create_head_pose(roll=15, degrees=True),
    duration=1.0
)
```

**Nod (pitch):**

```python
# Nod down
mini.goto_target(
    head=create_head_pose(pitch=-15, degrees=True),
    duration=0.5
)
# Nod up
mini.goto_target(
    head=create_head_pose(pitch=15, degrees=True),
    duration=0.5
)
# Return to neutral
mini.goto_target(
    head=create_head_pose(pitch=0, degrees=True),
    duration=0.5
)
```

**Shake head (yaw):**

```python
for _ in range(2):
    mini.goto_target(head=create_head_pose(yaw=20, degrees=True), duration=0.3)
    mini.goto_target(head=create_head_pose(yaw=-20, degrees=True), duration=0.3)
mini.goto_target(head=create_head_pose(yaw=0, degrees=True), duration=0.3)
```

## Antenna Control

### Coordinate System

**Antenna angles:**

- Radians (default)
- Positive: Antenna points outward
- Negative: Antenna points inward
- Range: approximately ±1.5 radians (±86°)

**Index:**

- `antennas[0]`: Left antenna
- `antennas[1]`: Right antenna

### Antenna Movement Examples

**Happy (antennas up and out):**

```python
mini.goto_target(
    antennas=np.deg2rad([45, 45]),
    duration=0.5
)
```

**Sad (antennas down):**

```python
mini.goto_target(
    antennas=np.deg2rad([-30, -30]),
    duration=0.5
)
```

**Curious (one up, one down):**

```python
mini.goto_target(
    antennas=np.deg2rad([45, -45]),
    duration=0.5
)
```

**Wiggle:**

```python
for _ in range(3):
    mini.goto_target(antennas=np.deg2rad([30, -30]), duration=0.2)
    mini.goto_target(antennas=np.deg2rad([-30, 30]), duration=0.2)
mini.goto_target(antennas=[0, 0], duration=0.3)
```

**Neutral position:**

```python
mini.goto_target(antennas=[0.0, 0.0], duration=0.5)
```

## Body Control

### Coordinate System

**Body yaw:**

- Radians (default)
- Positive: Counter-clockwise rotation (viewed from above)
- Negative: Clockwise rotation
- Full 360° rotation possible

### Body Movement Examples

**Turn 90° right:**

```python
mini.goto_target(
    body_yaw=np.deg2rad(-90),
    duration=2.0
)
```

**Turn 180° (turn around):**

```python
mini.goto_target(
    body_yaw=np.deg2rad(180),
    duration=3.0
)
```

**Return to front:**

```python
mini.goto_target(
    body_yaw=0.0,
    duration=2.0
)
```

**Scanning motion:**

```python
# Scan left to right
for angle in [-60, -30, 0, 30, 60, 0]:
    mini.goto_target(
        body_yaw=np.deg2rad(angle),
        duration=1.0
    )
    time.sleep(0.5)
```

## Combined Movements

### Coordinated Motion

**All actuators move simultaneously:**

```python
mini.goto_target(
    head=create_head_pose(z=10, roll=15, degrees=True, mm=True),
    antennas=np.deg2rad([45, 45]),
    body_yaw=np.deg2rad(30),
    duration=2.0
)
```

### Sequential Movements

**One movement at a time:**

```python
# Look up
mini.goto_target(
    head=create_head_pose(z=10, mm=True),
    duration=1.0
)

# Then raise antennas
mini.goto_target(
    antennas=np.deg2rad([45, 45]),
    duration=0.5
)

# Then turn body
mini.goto_target(
    body_yaw=np.deg2rad(45),
    duration=1.5
)
```

### Complex Behaviors

**Greeting sequence:**

```python
def greet():
    # Look at person
    mini.goto_target(
        head=create_head_pose(z=5, mm=True),
        duration=0.5
    )

    # Antennas up (happy)
    mini.goto_target(
        antennas=np.deg2rad([45, 45]),
        duration=0.5
    )

    # Nod twice
    for _ in range(2):
        mini.goto_target(
            head=create_head_pose(z=5, pitch=-10, mm=True, degrees=True),
            duration=0.3
        )
        mini.goto_target(
            head=create_head_pose(z=5, pitch=10, mm=True, degrees=True),
            duration=0.3
        )

    # Return to neutral
    mini.goto_target(
        head=create_head_pose(z=0, pitch=0, mm=True, degrees=True),
        antennas=[0, 0],
        duration=0.5
    )

greet()
```

## Best Practices

### Duration Selection

- **Fast movements**: 0.3-0.5 seconds
- **Normal movements**: 0.5-1.0 seconds
- **Slow movements**: 1.0-2.0 seconds
- **Body rotations**: 1.5-3.0 seconds (large movements)

### Smooth Motion

1. **Use appropriate durations** - Too fast = jerky
2. **Use "minjerk" interpolation** - Most natural
3. **Test incrementally** - Start slow, increase speed
4. **Combine movements** - More efficient than sequential

### Safety

1. **SDK enforces limits** - Don't disable
2. **Test in simulation first** - Validate behavior
3. **Gradual changes** - Avoid sudden large movements
4. **Monitor robot** - Watch for unusual sounds/movements

### Performance

1. **Use set_target()** for high-frequency control
2. **Batch movements** - Combine when possible
3. **Avoid blocking** - Use async patterns for complex behaviors
4. **Check daemon health** - Ensure responsive communication

## Utility Functions

**Angle conversions:**

```python
import numpy as np

# Degrees to radians
angle_rad = np.deg2rad(45)

# Radians to degrees
angle_deg = np.rad2deg(angle_rad)
```

**Creating arrays:**

```python
# Antenna positions
left_right = [np.deg2rad(45), np.deg2rad(-45)]

# Zero positions
neutral = [0.0, 0.0]
```

## Troubleshooting

**Movements jerky:**

- Increase duration
- Use "minjerk" method
- Check for competing processes

**Robot doesn't move:**

- Verify daemon is running
- Check connection
- Ensure safety limits not violated
- Verify power supply

**Unexpected positions:**

- Check coordinate system (degrees/radians, mm/meters)
- Verify parameter order
- Use create_head_pose() helper

**Slow response:**

- Check network latency (wireless)
- Reduce movement frequency
- Optimize code logic
