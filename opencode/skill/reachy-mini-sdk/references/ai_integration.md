# AI Integration Reference

Guide to integrating AI models and deploying apps with Reachy Mini.

## Hugging Face Integration

Reachy Mini is deeply integrated with Hugging Face ecosystem.

### Pre-built Apps

**Available on robot dashboard:**

- **Conversation App**: Talk with LLMs
- **Radio**: Listen to radio stations
- **Hand Tracker**: Follow hand movements in real-time

**One-click installation** from Hugging Face Spaces.

### Deploying Custom Apps

**App structure:**

```
my_reachy_app/
├── app.py              # Main application (Gradio/Streamlit)
├── requirements.txt    # Dependencies
├── Dockerfile         # Optional: custom environment
└── README.md          # App documentation
```

**Basic app template:**

```python
# app.py
import gradio as gr
from reachy_mini import ReachyMini
import numpy as np

def make_robot_wave():
    with ReachyMini(localhost_only=False) as mini:
        # Wave sequence
        for _ in range(3):
            mini.goto_target(
                antennas=np.deg2rad([45, -45]),
                duration=0.5
            )
            mini.goto_target(
                antennas=np.deg2rad([-45, 45]),
                duration=0.5
            )
        mini.goto_target(antennas=[0, 0], duration=0.5)
    return "Wave complete!"

# Gradio interface
with gr.Blocks() as demo:
    gr.Markdown("# Reachy Mini Wave App")
    button = gr.Button("Make Robot Wave")
    output = gr.Textbox(label="Status")
    button.click(make_robot_wave, outputs=output)

if __name__ == "__main__":
    demo.launch(server_name="0.0.0.0", server_port=7860)
```

**requirements.txt:**

```
reachy-mini>=1.2.0
gradio>=4.0.0
numpy
```

## LLM Integration Patterns

### Conversational Interface

**Basic chat with vision:**

```python
from transformers import pipeline
import numpy as np

# Initialize LLM
chatbot = pipeline("text-generation", model="meta-llama/Llama-2-7b-chat-hf")

with ReachyMini(media_backend="default") as mini:
    # Get camera frame
    frame = mini.media.get_frame()

    # Describe what robot sees (use vision model)
    vision_model = pipeline("image-to-text")
    description = vision_model(frame)[0]['generated_text']

    # Chat based on what it sees
    prompt = f"I see: {description}. What should I say?"
    response = chatbot(prompt, max_length=100)[0]['generated_text']

    # Speak response (TTS)
    tts = pipeline("text-to-speech")
    audio = tts(response)
    mini.media.push_audio_sample(audio["audio"])
```

### Multimodal Applications

**Vision + Language:**

```python
from transformers import BlipProcessor, BlipForConditionalGeneration
from PIL import Image
import cv2

# Load vision-language model
processor = BlipProcessor.from_pretrained("Salesforce/blip-image-captioning-base")
model = BlipForConditionalGeneration.from_pretrained("Salesforce/blip-image-captioning-base")

with ReachyMini(media_backend="default") as mini:
    # Capture image
    frame = mini.media.get_frame()
    image = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))

    # Generate caption
    inputs = processor(image, return_tensors="pt")
    outputs = model.generate(**inputs)
    caption = processor.decode(outputs[0], skip_special_tokens=True)

    print(f"Robot sees: {caption}")

    # React based on caption
    if "person" in caption.lower():
        # Wave at person
        mini.goto_target(
            antennas=np.deg2rad([45, 45]),
            duration=0.5
        )
```

## Real-Time AI Applications

### Object Detection

```python
from transformers import pipeline
import cv2

detector = pipeline("object-detection", model="facebook/detr-resnet-50")

with ReachyMini(media_backend="default") as mini:
    while True:
        frame = mini.media.get_frame()
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

        # Detect objects
        results = detector(frame_rgb)

        # React to detections
        for obj in results:
            if obj['label'] == 'person' and obj['score'] > 0.9:
                # Look at person (simplified)
                mini.goto_target(
                    head=create_head_pose(z=5, mm=True),
                    antennas=np.deg2rad([30, 30]),
                    duration=0.5
                )
                break

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
```

### Speech-to-Action

```python
from transformers import pipeline

# Speech recognition
recognizer = pipeline("automatic-speech-recognition", model="openai/whisper-base")

with ReachyMini(media_backend="default") as mini:
    # Listen
    audio = mini.media.get_audio_sample()
    audio_mono = audio.mean(axis=1) if audio.shape[1] == 2 else audio.squeeze()

    # Recognize
    result = recognizer(audio_mono, sampling_rate=16000)
    command = result['text'].lower()

    # Execute command
    if "wave" in command:
        # Wave sequence
        for _ in range(2):
            mini.goto_target(antennas=np.deg2rad([45, -45]), duration=0.3)
            mini.goto_target(antennas=np.deg2rad([-45, 45]), duration=0.3)
    elif "nod" in command:
        # Nod sequence
        for _ in range(2):
            mini.goto_target(head=create_head_pose(pitch=-10, degrees=True), duration=0.3)
            mini.goto_target(head=create_head_pose(pitch=10, degrees=True), duration=0.3)
```

## App Development Best Practices

### Environment Variables

```python
import os

# Configuration via environment variables
ROBOT_IP = os.getenv("REACHY_IP", "localhost")
USE_REMOTE = os.getenv("REACHY_REMOTE", "false").lower() == "true"

with ReachyMini(localhost_only=not USE_REMOTE) as mini:
    # Your code
```

### Error Handling

```python
def safe_robot_action(action_func):
    try:
        with ReachyMini(localhost_only=False) as mini:
            return action_func(mini)
    except ConnectionError:
        return "Error: Cannot connect to robot"
    except Exception as e:
        return f"Error: {str(e)}"

# Usage
def my_action(mini):
    mini.goto_target(antennas=[0.5, 0.5], duration=1.0)
    return "Success!"

result = safe_robot_action(my_action)
```

### Resource Management

```python
# Use context managers
with ReachyMini() as mini:
    # Robot automatically disconnects when done
    mini.goto_target(...)

# For long-running apps, manage connection carefully
class RobotController:
    def __init__(self):
        self.mini = None

    def connect(self):
        self.mini = ReachyMini(localhost_only=False)
        self.mini.__enter__()

    def disconnect(self):
        if self.mini:
            self.mini.__exit__(None, None, None)

    def move(self, **kwargs):
        if self.mini:
            self.mini.goto_target(**kwargs)
```

## Example Apps

### Emotion Detector

```python
import gradio as gr
from transformers import pipeline
import cv2

emotion_classifier = pipeline("image-classification", model="dima806/facial_emotions_image_detection")

def detect_emotion_and_react():
    with ReachyMini(media_backend="default") as mini:
        # Capture frame
        frame = mini.media.get_frame()
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

        # Detect emotion
        result = emotion_classifier(frame_rgb)[0]
        emotion = result['label']

        # React to emotion
        if emotion == "happy":
            mini.goto_target(antennas=np.deg2rad([45, 45]), duration=0.5)
        elif emotion == "sad":
            mini.goto_target(antennas=np.deg2rad([-30, -30]), duration=0.5)

        return f"Detected: {emotion}"

with gr.Blocks() as demo:
    gr.Markdown("# Emotion Detector")
    button = gr.Button("Detect Emotion")
    output = gr.Textbox()
    button.click(detect_emotion_and_react, outputs=output)

demo.launch()
```

### Voice Assistant

```python
from transformers import pipeline
import numpy as np

asr = pipeline("automatic-speech-recognition")
tts = pipeline("text-to-speech")
llm = pipeline("text-generation")

def voice_assistant():
    with ReachyMini(media_backend="default") as mini:
        # Listen
        audio_in = mini.media.get_audio_sample()
        text = asr(audio_in.mean(axis=1), sampling_rate=16000)['text']

        # Think (LLM)
        response = llm(text, max_length=100)[0]['generated_text']

        # Speak
        audio_out = tts(response)
        mini.media.push_audio_sample(audio_out["audio"])

        # Express
        mini.goto_target(
            antennas=np.deg2rad([30, 30]),
            duration=0.5
        )
```

## Deployment Checklist

- [ ] Test locally first
- [ ] Add error handling
- [ ] Use environment variables
- [ ] Include requirements.txt
- [ ] Write README with usage
- [ ] Test with `localhost_only=False`
- [ ] Add loading indicators
- [ ] Handle network issues
- [ ] Include example inputs
- [ ] Add logs for debugging
