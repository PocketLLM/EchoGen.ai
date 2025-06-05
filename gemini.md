Gemini Developer API
Get a Gemini API Key
Get a Gemini API key and make your first API request in minutes.

Python
JavaScript
Go
Java
REST

import { GoogleGenAI } from "@google/genai";

const ai = new GoogleGenAI({ apiKey: "YOUR_API_KEY" });

async function main() {
  const response = await ai.models.generateContent({
    model: "gemini-2.0-flash",
    contents: "Explain how AI works in a few words",
  });
  console.log(response.text);
}

await main();
Gemini API quickstart

This quickstart shows you how to install our libraries and make your first Gemini API request.

Note: All our code snippets (except for direct REST calls) require and use Google Gen AI SDK, a new set of libraries we have been rolling out since late 2024. You can find out more about Google GenAI SDK and our previous libraries at our Libraries page.
Before you begin
You need a Gemini API key. If you don't already have one, you can get it for free in Google AI Studio.

Install the Google GenAI SDK
Python
JavaScript
Go
Java
Apps Script
Using Node.js v18+, install the Google Gen AI SDK for TypeScript and JavaScript using the following npm command:


npm install @google/genai
Make your first request
Use the generateContent method to send a request to the Gemini API.

Python
JavaScript
Go
Java
Apps Script
REST

import { GoogleGenAI } from "@google/genai";

const ai = new GoogleGenAI({ apiKey: "YOUR_API_KEY" });

async function main() {
  const response = await ai.models.generateContent({
    model: "gemini-2.0-flash",
    contents: "Explain how AI works in a few words",
  });
  console.log(response.text);
}

main();
Make your first request
Use the generateContent method to send a request to the Gemini API.

Python
JavaScript
Go
Java
Apps Script
REST

curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$YOUR_API_KEY" \
  -H 'Content-Type: application/json' \
  -X POST \
  -d '{
    "contents": [
      {
        "parts": [
          {
            "text": "Explain how AI works in a few words"
          }
        ]
      }
    ]
  }'

  OpenAI compatibility

Gemini models are accessible using the OpenAI libraries (Python and TypeScript / Javascript) along with the REST API, by updating three lines of code and using your Gemini API key. If you aren't already using the OpenAI libraries, we recommend that you call the Gemini API directly.

Python
JavaScript
REST

curl "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer GEMINI_API_KEY" \
-d '{
    "model": "gemini-2.0-flash",
    "messages": [
        {"role": "user", "content": "Explain to me how AI works"}
    ]
    }'
What changed? Just three lines!

api_key="GEMINI_API_KEY": Replace "GEMINI_API_KEY" with your actual Gemini API key, which you can get in Google AI Studio.

base_url="https://generativelanguage.googleapis.com/v1beta/openai/": This tells the OpenAI library to send requests to the Gemini API endpoint instead of the default URL.

model="gemini-2.0-flash": Choose a compatible Gemini model

Thinking
Gemini 2.5 models are trained to think through complex problems, leading to significantly improved reasoning. The Gemini API comes with a "thinking budget" parameter which gives fine grain control over how much the model will think.

Unlike the Gemini API, the OpenAI API offers three levels of thinking control: "low", "medium", and "high", which behind the scenes we map to 1K, 8K, and 24K thinking token budgets.

If you want to disable thinking, you can set the reasoning effort to "none".

Python
JavaScript
REST

curl "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer GEMINI_API_KEY" \
-d '{
    "model": "gemini-2.5-flash-preview-05-20",
    "reasoning_effort": "low",
    "messages": [
        {"role": "user", "content": "Explain to me how AI works"}
      ]
    }'
Streaming
The Gemini API supports streaming responses.

Python
JavaScript
REST

curl "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer GEMINI_API_KEY" \
-d '{
    "model": "gemini-2.0-flash",
    "messages": [
        {"role": "user", "content": "Explain to me how AI works"}
    ],
    "stream": true
  }'
Function calling
Function calling makes it easier for you to get structured data outputs from generative models and is supported in the Gemini API.

Python
JavaScript
REST

curl "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer GEMINI_API_KEY" \
-d '{
  "model": "gemini-2.0-flash",
  "messages": [
    {
      "role": "user",
      "content": "What'\''s the weather like in Chicago today?"
    }
  ],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "get_weather",
        "description": "Get the current weather in a given location",
        "parameters": {
          "type": "object",
          "properties": {
            "location": {
              "type": "string",
              "description": "The city and state, e.g. Chicago, IL"
            },
            "unit": {
              "type": "string",
              "enum": ["celsius", "fahrenheit"]
            }
          },
          "required": ["location"]
        }
      }
    }
  ],
  "tool_choice": "auto"
}'
Image understanding
Gemini models are natively multimodal and provide best in class performance on many common vision tasks.

Python
JavaScript
REST

bash -c '
  base64_image=$(base64 -i "Path/to/agi/image.jpeg");
  curl "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer GEMINI_API_KEY" \
    -d "{
      \"model\": \"gemini-2.0-flash\",
      \"messages\": [
        {
          \"role\": \"user\",
          \"content\": [
            { \"type\": \"text\", \"text\": \"What is in this image?\" },
            {
              \"type\": \"image_url\",
              \"image_url\": { \"url\": \"data:image/jpeg;base64,${base64_image}\" }
            }
          ]
        }
      ]
    }"
'
Generate an image
Note: Image generation is only available in the paid tier.
Generate an image:

Python
JavaScript
REST

curl "https://generativelanguage.googleapis.com/v1beta/openai/images/generations" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer GEMINI_API_KEY" \
  -d '{
        "model": "imagen-3.0-generate-002",
        "prompt": "a portrait of a sheepadoodle wearing a cape",
        "response_format": "b64_json",
        "n": 1,
      }'
Audio understanding
Analyze audio input:

Python
JavaScript
REST
Note: If you get an Argument list too long error, the encoding of your audio file might be too long for curl.

bash -c '
  base64_audio=$(base64 -i "/path/to/your/audio/file.wav");
  curl "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer GEMINI_API_KEY" \
    -d "{
      \"model\": \"gemini-2.0-flash\",
      \"messages\": [
        {
          \"role\": \"user\",
          \"content\": [
            { \"type\": \"text\", \"text\": \"Transcribe this audio file.\" },
            {
              \"type\": \"input_audio\",
              \"input_audio\": {
                \"data\": \"${base64_audio}\",
                \"format\": \"wav\"
              }
            }
          ]
        }
      ]
    }"
'
Structured output
Gemini models can output JSON objects in any structure you define.

Python
JavaScript

from pydantic import BaseModel
from openai import OpenAI

client = OpenAI(
    api_key="GEMINI_API_KEY",
    base_url="https://generativelanguage.googleapis.com/v1beta/openai/"
)

class CalendarEvent(BaseModel):
    name: str
    date: str
    participants: list[str]

completion = client.beta.chat.completions.parse(
    model="gemini-2.0-flash",
    messages=[
        {"role": "system", "content": "Extract the event information."},
        {"role": "user", "content": "John and Susan are going to an AI conference on Friday."},
    ],
    response_format=CalendarEvent,
)

print(completion.choices[0].message.parsed)
Embeddings
Text embeddings measure the relatedness of text strings and can be generated using the Gemini API.

Python
JavaScript
REST

curl "https://generativelanguage.googleapis.com/v1beta/openai/embeddings" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer GEMINI_API_KEY" \
-d '{
    "input": "Your text string goes here",
    "model": "text-embedding-004"
  }'
extra_body
There are several features supported by Gemini that are not available in OpenAI models but can be enabled using the extra_body field.

extra_body features

safety_settings	Corresponds to Gemini's SafetySetting.
cached_content	Corresponds to Gemini's GenerateContentRequest.cached_content.
cached_content
Here's an example of using extra_body to set cached_content:

Python

from openai import OpenAI

client = OpenAI(
    api_key=MY_API_KEY,
    base_url="https://generativelanguage.googleapis.com/v1beta/"
)

stream = client.chat.completions.create(
    model="gemini-2.5-pro-preview-03-25",
    n=1,
    messages=[
        {
            "role": "user",
            "content": "Summarize the video"
        }
    ],
    stream=True,
    stream_options={'include_usage': True},
    extra_body={
        'extra_body':
        {
            'google': {
              'cached_content': "cachedContents/0000aaaa1111bbbb2222cccc3333dddd4444eeee"
          }
        }
    }
)

for chunk in stream:
    print(chunk)
    print(chunk.usage.to_dict())
List models
Get a list of available Gemini models:

Python
JavaScript
REST

curl https://generativelanguage.googleapis.com/v1beta/openai/models \
-H "Authorization: Bearer GEMINI_API_KEY"
Retrieve a model
Retrieve a Gemini model:

Python
JavaScript
REST

curl https://generativelanguage.googleapis.com/v1beta/openai/models/gemini-2.0-flash \
-H "Authorization: Bearer GEMINI_API_KEY"
Text generation

The Gemini API can generate text output from various inputs, including text, images, video, and audio, leveraging Gemini models.

Here's a basic example that takes a single text input:

Python
JavaScript
Go
REST
Apps Script

curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY" \
  -H 'Content-Type: application/json' \
  -X POST \
  -d '{
    "contents": [
      {
        "parts": [
          {
            "text": "How does AI work?"
          }
        ]
      }
    ]
  }'

System instructions and configurations
You can guide the behavior of Gemini models with system instructions. To do so, pass a GenerateContentConfig object.

Python
JavaScript
Go
REST
Apps Script

curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{
    "system_instruction": {
      "parts": [
        {
          "text": "You are a cat. Your name is Neko."
        }
      ]
    },
    "contents": [
      {
        "parts": [
          {
            "text": "Hello there"
          }
        ]
      }
    ]
  }'
The GenerateContentConfig object also lets you override default generation parameters, such as temperature.

Python
JavaScript
Go
REST
Apps Script

curl https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY \
  -H 'Content-Type: application/json' \
  -X POST \
  -d '{
    "contents": [
      {
        "parts": [
          {
            "text": "Explain how AI works"
          }
        ]
      }
    ],
    "generationConfig": {
      "stopSequences": [
        "Title"
      ],
      "temperature": 1.0,
      "maxOutputTokens": 800,
      "topP": 0.8,
      "topK": 10
    }
  }'
Refer to the GenerateContentConfig in our API reference for a complete list of configurable parameters and their descriptions.

Multimodal inputs
The Gemini API supports multimodal inputs, allowing you to combine text with media files. The following example demonstrates providing an image:

Python
JavaScript
Go
REST
Apps Script

# Use a temporary file to hold the base64 encoded image data
TEMP_B64=$(mktemp)
trap 'rm -f "$TEMP_B64"' EXIT
base64 $B64FLAGS $IMG_PATH > "$TEMP_B64"

# Use a temporary file to hold the JSON payload
TEMP_JSON=$(mktemp)
trap 'rm -f "$TEMP_JSON"' EXIT

cat > "$TEMP_JSON" << EOF
{
  "contents": [
    {
      "parts": [
        {
          "text": "Tell me about this instrument"
        },
        {
          "inline_data": {
            "mime_type": "image/jpeg",
            "data": "$(cat "$TEMP_B64")"
          }
        }
      ]
    }
  ]
}
EOF

curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY" \
  -H 'Content-Type: application/json' \
  -X POST \
  -d "@$TEMP_JSON"
For alternative methods of providing images and more advanced image processing, see our image understanding guide. The API also supports document, video, and audio inputs and understanding.

Streaming responses
By default, the model returns a response only after the entire generation process is complete.

For more fluid interactions, use streaming to receive GenerateContentResponse instances incrementally as they're generated.

Python
JavaScript
Go
REST
Apps Script

curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:streamGenerateContent?alt=sse&key=${GEMINI_API_KEY}" \
  -H 'Content-Type: application/json' \
  --no-buffer \
  -d '{
    "contents": [
      {
        "parts": [
          {
            "text": "Explain how AI works"
          }
        ]
      }
    ]
  }'
Multi-turn conversations (Chat)
Our SDKs provide functionality to collect multiple rounds of prompts and responses into a chat, giving you an easy way to keep track of the conversation history.

Note: Chat functionality is only implemented as part of the SDKs. Behind the scenes, it still uses the generateContent API. For multi-turn conversations, the full conversation history is sent to the model with each follow-up turn.
Python
JavaScript
Go
REST
Apps Script

curl https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY \
  -H 'Content-Type: application/json' \
  -X POST \
  -d '{
    "contents": [
      {
        "role": "user",
        "parts": [
          {
            "text": "Hello"
          }
        ]
      },
      {
        "role": "model",
        "parts": [
          {
            "text": "Great to meet you. What would you like to know?"
          }
        ]
      },
      {
        "role": "user",
        "parts": [
          {
            "text": "I have two dogs in my house. How many paws are in my house?"
          }
        ]
      }
    ]
  }'
Streaming can also be used for multi-turn conversations.

Python
JavaScript
Go
REST
Apps Script

curl https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:streamGenerateContent?alt=sse&key=$GEMINI_API_KEY \
  -H 'Content-Type: application/json' \
  -X POST \
  -d '{
    "contents": [
      {
        "role": "user",
        "parts": [
          {
            "text": "Hello"
          }
        ]
      },
      {
        "role": "model",
        "parts": [
          {
            "text": "Great to meet you. What would you like to know?"
          }
        ]
      },
      {
        "role": "user",
        "parts": [
          {
            "text": "I have two dogs in my house. How many paws are in my house?"
          }
        ]
      }
    ]
  }'
Supported models
All models in the Gemini family support text generation. To learn more about the models and their capabilities, visit the Models page.

Best practices
Prompting tips
For basic text generation, a zero-shot prompt often suffices without needing examples, system instructions or specific formatting.

For more tailored outputs:

Use System instructions to guide the model.
Provide few example inputs and outputs to guide the model. This is often referred to as few-shot prompting.
Consider fine-tuning for advanced use cases.
Consult our prompt engineering guide for more tips.
Speech generation (text-to-speech)

The Gemini API can transform text input into single speaker or multi-speaker audio using native text-to-speech (TTS) generation capabilities. Text-to-speech (TTS) generation is controllable, meaning you can use natural language to structure interactions and guide the style, accent, pace, and tone of the audio.

The TTS capability differs from speech generation provided through the Live API, which is designed for interactive, unstructured audio, and multimodal inputs and outputs. While the Live API excels in dynamic conversational contexts, TTS through the Gemini API is tailored for scenarios that require exact text recitation with fine-grained control over style and sound, such as podcast or audiobook generation.

This guide shows you how to generate single-speaker and multi-speaker audio from text.

Preview: Native text-to-speech (TTS) is in Preview.
Before you begin
Ensure you use a Gemini 2.5 model variant with native text-to-speech (TTS) capabilities, as listed in the Supported models section. For optimal results, consider which model best fits your specific use case.

You may find it useful to test the Gemini 2.5 TTS models in AI Studio before you start building.

Note: TTS models accept text-only inputs and produce audio-only outputs. For a complete list of restrictions specific to TTS models, review the Limitations section.
Single-speaker text-to-speech
To convert text to single-speaker audio, set the response modality to "audio", and pass a SpeechConfig object with VoiceConfig set. You'll need to choose a voice name from the prebuilt output voices.

This example saves the output audio from the model in a wave file:

Python
JavaScript
REST

curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent?key=${GEMINI_API_KEY:?Please set GEMINI_API_KEY}" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
        "contents": [{
          "parts":[{
            "text": "Say cheerfully: Have a wonderful day!"
          }]
        }],
        "generationConfig": {
          "responseModalities": ["AUDIO"],
          "speechConfig": {
            "voiceConfig": {
              "prebuiltVoiceConfig": {
                "voiceName": "Kore"
              }
            }
          }
        },
        "model": "gemini-2.5-flash-preview-tts",
    }' | jq -r '.candidates[0].content.parts[0].inlineData.data' | \
          base64 --decode >out.pcm
# You may need to install ffmpeg.
ffmpeg -f s16le -ar 24000 -ac 1 -i out.pcm out.wav
Multi-speaker text-to-speech
For multi-speaker audio, you'll need a MultiSpeakerVoiceConfig object with each speaker (up to 2) configured as a SpeakerVoiceConfig. You'll need to define each speaker with the same names used in the prompt:

Python
JavaScript
REST

curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent?key=${GEMINI_API_KEY:?Please set GEMINI_API_KEY}" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
  "contents": [{
    "parts":[{
      "text": "TTS the following conversation between Joe and Jane:
                Joe: Hows it going today Jane?
                Jane: Not too bad, how about you?"
    }]
  }],
  "generationConfig": {
    "responseModalities": ["AUDIO"],
    "speechConfig": {
      "multiSpeakerVoiceConfig": {
        "speakerVoiceConfigs": [{
            "speaker": "Joe",
            "voiceConfig": {
              "prebuiltVoiceConfig": {
                "voiceName": "Kore"
              }
            }
          }, {
            "speaker": "Jane",
            "voiceConfig": {
              "prebuiltVoiceConfig": {
                "voiceName": "Puck"
              }
            }
          }]
      }
    }
  },
  "model": "gemini-2.5-flash-preview-tts",
}' | jq -r '.candidates[0].content.parts[0].inlineData.data' | \
    base64 --decode > out.pcm
# You may need to install ffmpeg.
ffmpeg -f s16le -ar 24000 -ac 1 -i out.pcm out.wav
Streaming
You can also use streaming to get the output audio from the model, instead of saving to a wave file as shown in the single- and multi-speaker examples.

Streaming returns parts of the response as they generate, creating a more fluid response. The audio will begin to play automatically once the response begins.

Python

from google import genai
from google.genai import types
import pyaudio # You'll need to install PyAudio

client = genai.Client(api_key="GEMINI_API_KEY")

# ... response code

stream = pya.open(
         format=FORMAT,
         channels=CHANNELS,
         rate=RECEIVE_SAMPLE_RATE,
         output=True)

def play_audio(chunks):
   chunk: Blob
   for chunk in chunks:
      stream.write(chunk.data)
Controlling speech style with prompts
You can control style, tone, accent, and pace using natural language prompts for both single- and multi-speaker TTS. For example, in a single-speaker prompt, you can say:


Say in an spooky whisper:
"By the pricking of my thumbs...
Something wicked this way comes"
In a multi-speaker prompt, provide the model with each speaker's name and corresponding transcript. You can also provide guidance for each speaker individually:


Make Speaker1 sound tired and bored, and Speaker2 sound excited and happy:

Speaker1: So... what's on the agenda today?
Speaker2: You're never going to guess!
Try using a voice option that corresponds to the style or emotion you want to convey, to emphasize it even more. In the previous prompt, for example, Enceladus's breathiness might emphasize "tired" and "bored", while Puck's upbeat tone could complement "excited" and "happy".

Generating a prompt to convert to audio
The TTS models only output audio, but you can use other models to generate a transcript first, then pass that transcript to the TTS model to read aloud.

Python
JavaScript

from google import genai
from google.genai import types

client = genai.Client(api_key="GEMINI_API_KEY")

transcript = client.models.generate_content(
   model="gemini-2.0-flash",
   contents="""Generate a short transcript around 100 words that reads
            like it was clipped from a podcast by excited herpetologists.
            The hosts names are Dr. Anya and Liam.""").text

response = client.models.generate_content(
   model="gemini-2.5-flash-preview-tts",
   contents=transcript,
   config=types.GenerateContentConfig(
      response_modalities=["AUDIO"],
      speech_config=types.SpeechConfig(
         multi_speaker_voice_config=types.MultiSpeakerVoiceConfig(
            speaker_voice_configs=[
               types.SpeakerVoiceConfig(
                  speaker='Dr. Anya',
                  voice_config=types.VoiceConfig(
                     prebuilt_voice_config=types.PrebuiltVoiceConfig(
                        voice_name='Kore',
                     )
                  )
               ),
               types.SpeakerVoiceConfig(
                  speaker='Liam',
                  voice_config=types.VoiceConfig(
                     prebuilt_voice_config=types.PrebuiltVoiceConfig(
                        voice_name='Puck',
                     )
                  )
               ),
            ]
         )
      )
   )
)

# ...Code to stream or save the output
Voice options
TTS models support the following 30 voice options in the voice_name field:

Zephyr -- Bright	Puck -- Upbeat	Charon -- Informative
Kore -- Firm	Fenrir -- Excitable	Leda -- Youthful
Orus -- Firm	Aoede -- Breezy	Callirrhoe -- Easy-going
Autonoe -- Bright	Enceladus -- Breathy	Iapetus -- Clear
Umbriel -- Easy-going	Algieba -- Smooth	Despina -- Smooth
Erinome -- Clear	Algenib -- Gravelly	Rasalgethi -- Informative
Laomedeia -- Upbeat	Achernar -- Soft	Alnilam -- Firm
Schedar -- Even	Gacrux -- Mature	Pulcherrima -- Forward
Achird -- Friendly	Zubenelgenubi -- Casual	Vindemiatrix -- Gentle
Sadachbia -- Lively	Sadaltager -- Knowledgeable	Sulafat -- Warm
You can hear all the voice options in AI Studio.

Supported languages
The TTS models detect the input language automatically. They support the following 24 languages:

Language	BCP-47 Code	Language	BCP-47 Code
Arabic (Egyptian)	ar-EG	German (Germany)	de-DE
English (US)	en-US	Spanish (US)	es-US
French (France)	fr-FR	Hindi (India)	hi-IN
Indonesian (Indonesia)	id-ID	Italian (Italy)	it-IT
Japanese (Japan)	ja-JP	Korean (Korea)	ko-KR
Portuguese (Brazil)	pt-BR	Russian (Russia)	ru-RU
Dutch (Netherlands)	nl-NL	Polish (Poland)	pl-PL
Thai (Thailand)	th-TH	Turkish (Turkey)	tr-TR
Vietnamese (Vietnam)	vi-VN	Romanian (Romania)	ro-RO
Ukrainian (Ukraine)	uk-UA	Bengali (Bangladesh)	bn-BD
English (India)	en-IN & hi-IN bundle	Marathi (India)	mr-IN
Tamil (India)	ta-IN	Telugu (India)	te-IN
Supported models
Model	Single speaker	Multispeaker
Gemini 2.5 Flash Preview TTS	✔️	✔️
Gemini 2.5 Pro Preview TTS	✔️	✔️
Limitations
TTS models can only receive text inputs and generate audio outputs.
A TTS session has a context window limit of 32k tokens.
Review Languages section for language support.
What's next


----
speech/ podcast gen models
----
gemini-2.5- flash-preview-fts
gemini-2.5-pro-preview-tts

#!/bin/bash
set -e -E

GEMINI_API_KEY="$GEMINI_API_KEY"
MODEL_ID="gemini-2.5-flash-preview-tts"
GENERATE_CONTENT_API="streamGenerateContent"

cat << EOF > request.json
{
    "contents": [
      {
        "role": "user",
        "parts": [
          {
            "text": "Read aloud in a warm, welcoming tone\nSpeaker 1: Hello! We're excited to show you our native speech capabilities\nSpeaker 2: Where you can direct a voice, create realistic dialog, and so much more. Edit these placeholders to get started."
          },
        ]
      },
    ],
    "generationConfig": {
      "responseModalities": ["audio", ],
      "temperature": 1.25,
      "speech_config": {
        "multi_speaker_voice_config": {
          "speaker_voice_configs": [
            {
              "speaker": "ral;f",
              "voice_config": {
                "prebuilt_voice_config": {
                  "voice_name": "Zephyr"
                }
              }
            },
            {
              "speaker": "calf",
              "voice_config": {
                "prebuilt_voice_config": {
                  "voice_name": "Puck"
                }
              }
            },
          ]
        },
      },
    },
}
EOF

curl \
-X POST \
-H "Content-Type: application/json" \
"https://generativelanguage.googleapis.com/v1beta/models/${MODEL_ID}:${GENERATE_CONTENT_API}?key=${GEMINI_API_KEY}" -d '@request.json'

!pip install -U -q "google-genai>=1.16.1"

# Gemini TTS


### Setup your API key for Using AIStudio


from google.colab import userdata

GOOGLE_API_KEY=userdata.get('GOOGLE_AI_STUDIO')

### Initialize SDK client


from google import genai
from google.genai import types

client = genai.Client(
    api_key=GOOGLE_API_KEY,
    )

### Initialize SDK client


from google import genai
from google.genai import types
from google.genai.types import GenerateContentConfig, Tool
from IPython.display import display, HTML, Markdown
import io
import json
import re

### Getting a list of models

for model in client.models.list(config={'query_base':True}):
    if 'tts' in model.name:
        print(model)

## Basic Genrate Text

response = client.models.generate_content(
    model="gemini-2.0-flash-exp",
    contents="What is the origin of 'TTS'?"
)

Markdown(response.text)

# response.candidates

## Basic TTS - Single Voice

from google import genai
from google.genai import types
import wave
import os
import base64
import struct


from IPython.display import Audio, display

# Set up the wave file to save the output:
def wave_file(filename, pcm, channels=1, rate=24000, sample_width=2):
   print(f"\nWriting audio file with parameters:")
   print(f"Channels: {channels}")
   print(f"Sample rate: {rate}")
   print(f"Sample width: {sample_width}")
   print(f"Data length: {len(pcm)} bytes")

   with wave.open(filename, "wb") as wf:
      wf.setnchannels(channels)
      wf.setsampwidth(sample_width)
      wf.setframerate(rate)
      wf.writeframes(pcm)

PROMPT = "Say excitedly: Thats right Gemini now has Text to speech!"

VOICE = 'Kore'

client = genai.Client(api_key=GOOGLE_API_KEY)

response = client.models.generate_content(
   model="gemini-2.5-flash-preview-tts",
   contents=PROMPT,
   config=types.GenerateContentConfig(
      response_modalities=["audio"],
      speech_config=types.SpeechConfig(
         voice_config=types.VoiceConfig(
            prebuilt_voice_config=types.PrebuiltVoiceConfig(
               voice_name=VOICE,
            )
         )
      ),
   )
)

# Debug the response structure
print("\nResponse structure:")
print(f"Number of candidates: {len(response.candidates)}")
print(f"Content parts: {len(response.candidates[0].content.parts)}")
print(f"Part type: {type(response.candidates[0].content.parts[0])}")

data = response.candidates[0].content.parts[0].inline_data.data

# decoded_data = base64.b64decode(data)

response.usage_metadata

rate = 24000
file_name = f'single_voice_out.wav'

print(f"\nSaving sample rate: {rate}")
wave_file(file_name, data, rate=rate)

audio_file_path = '/content/single_voice_out.wav'
display(Audio(audio_file_path))

response.usage_metadata

### Put it together as a function

def generate_tts(PROMPT, VOICE, file_name):

    client = genai.Client(api_key=GOOGLE_API_KEY)

    response = client.models.generate_content(
    model="gemini-2.5-flash-preview-tts",
    contents=PROMPT,
    config=types.GenerateContentConfig(
        response_modalities=["audio"],
        speech_config=types.SpeechConfig(
            voice_config=types.VoiceConfig(
                prebuilt_voice_config=types.PrebuiltVoiceConfig(
                voice_name=VOICE,
                )
            )
        ),
    )
    )

    data = response.candidates[0].content.parts[0].inline_data.data
    # set the sample rate
    rate = 24000
    file_name = f'{file_name}.wav'

    print(f"\nSaving sample rate: {rate}")
    wave_file(file_name, data, rate=rate)

    return file_name


PROMPT = "whisper softly: Thats right. Gemini now has Text to speech!"
VOICE = 'Leda'
FILENAME = "leda_01"

audio_file_path = generate_tts(PROMPT, VOICE, FILENAME)

display(Audio(audio_file_path))

PROMPT = "lauging and giggling: Thats right. Gemini now has Text to speech!"
VOICE = 'Charon'
FILENAME = "charon_01"

audio_file_path = generate_tts(PROMPT, VOICE, FILENAME)

display(Audio(audio_file_path))

PROMPT = "stern and angrily: No more excuses you can now use Gemini TTS!"
VOICE = 'Charon'
FILENAME = "charon_02"

audio_file_path = generate_tts(PROMPT, VOICE, FILENAME)

display(Audio(audio_file_path))

## Make a multi speaker podcast

transcript = client.models.generate_content(
   model="gemini-2.0-flash",
   contents="""Generate a short transcript around 200 words that reads
            like it was taken from a podcast by an expert of bringing back extinct animals(Jenny)
            and podcast host (David). They are talking about Jenny's team bringing back the wooly mamoth.
            The presenters will ocasionally interupt each other with their passion
            The presenters names are Jenny and David.""").text

print(f"Transcript: {transcript}")

response = client.models.generate_content(
   model="gemini-2.5-flash-preview-tts",
   contents=transcript,
   config=types.GenerateContentConfig(
      response_modalities=["AUDIO"],
      speech_config=types.SpeechConfig(
         multi_speaker_voice_config=types.MultiSpeakerVoiceConfig(
            speaker_voice_configs=[
               types.SpeakerVoiceConfig(
                  speaker='Jenny',
                  voice_config=types.VoiceConfig(
                     prebuilt_voice_config=types.PrebuiltVoiceConfig(
                        voice_name='Kore',
                     )
                  )
               ),
               types.SpeakerVoiceConfig(
                  speaker='David',
                  voice_config=types.VoiceConfig(
                     prebuilt_voice_config=types.PrebuiltVoiceConfig(
                        voice_name='Puck',
                     )
                  )
               ),
            ]
         )
      )
   )
)

data = response.candidates[0].content.parts[0].inline_data.data


# set the sample rate
rate = 24000
file_name = f'multi_01.wav'

print(f"\nSaving sample rate: {rate}")
wave_file(file_name, data, rate=rate)

display(Audio(file_name))

Speech generation (text-to-speech)

The Gemini API can transform text input into single speaker or multi-speaker audio using native text-to-speech (TTS) generation capabilities. Text-to-speech (TTS) generation is controllable, meaning you can use natural language to structure interactions and guide the style, accent, pace, and tone of the audio.

The TTS capability differs from speech generation provided through the Live API, which is designed for interactive, unstructured audio, and multimodal inputs and outputs. While the Live API excels in dynamic conversational contexts, TTS through the Gemini API is tailored for scenarios that require exact text recitation with fine-grained control over style and sound, such as podcast or audiobook generation.

This guide shows you how to generate single-speaker and multi-speaker audio from text.

Preview: Native text-to-speech (TTS) is in Preview.
Before you begin
Ensure you use a Gemini 2.5 model variant with native text-to-speech (TTS) capabilities, as listed in the Supported models section. For optimal results, consider which model best fits your specific use case.

You may find it useful to test the Gemini 2.5 TTS models in AI Studio before you start building.

Note: TTS models accept text-only inputs and produce audio-only outputs. For a complete list of restrictions specific to TTS models, review the Limitations section.
Single-speaker text-to-speech
To convert text to single-speaker audio, set the response modality to "audio", and pass a SpeechConfig object with VoiceConfig set. You'll need to choose a voice name from the prebuilt output voices.

This example saves the output audio from the model in a wave file:

Python
JavaScript
REST

curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent?key=${GEMINI_API_KEY:?Please set GEMINI_API_KEY}" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
        "contents": [{
          "parts":[{
            "text": "Say cheerfully: Have a wonderful day!"
          }]
        }],
        "generationConfig": {
          "responseModalities": ["AUDIO"],
          "speechConfig": {
            "voiceConfig": {
              "prebuiltVoiceConfig": {
                "voiceName": "Kore"
              }
            }
          }
        },
        "model": "gemini-2.5-flash-preview-tts",
    }' | jq -r '.candidates[0].content.parts[0].inlineData.data' | \
          base64 --decode >out.pcm
# You may need to install ffmpeg.
ffmpeg -f s16le -ar 24000 -ac 1 -i out.pcm out.wav
Multi-speaker text-to-speech
For multi-speaker audio, you'll need a MultiSpeakerVoiceConfig object with each speaker (up to 2) configured as a SpeakerVoiceConfig. You'll need to define each speaker with the same names used in the prompt:

Python
JavaScript
REST

curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent?key=${GEMINI_API_KEY:?Please set GEMINI_API_KEY}" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
  "contents": [{
    "parts":[{
      "text": "TTS the following conversation between Joe and Jane:
                Joe: Hows it going today Jane?
                Jane: Not too bad, how about you?"
    }]
  }],
  "generationConfig": {
    "responseModalities": ["AUDIO"],
    "speechConfig": {
      "multiSpeakerVoiceConfig": {
        "speakerVoiceConfigs": [{
            "speaker": "Joe",
            "voiceConfig": {
              "prebuiltVoiceConfig": {
                "voiceName": "Kore"
              }
            }
          }, {
            "speaker": "Jane",
            "voiceConfig": {
              "prebuiltVoiceConfig": {
                "voiceName": "Puck"
              }
            }
          }]
      }
    }
  },
  "model": "gemini-2.5-flash-preview-tts",
}' | jq -r '.candidates[0].content.parts[0].inlineData.data' | \
    base64 --decode > out.pcm
# You may need to install ffmpeg.
ffmpeg -f s16le -ar 24000 -ac 1 -i out.pcm out.wav
Streaming
You can also use streaming to get the output audio from the model, instead of saving to a wave file as shown in the single- and multi-speaker examples.

Streaming returns parts of the response as they generate, creating a more fluid response. The audio will begin to play automatically once the response begins.

Python

from google import genai
from google.genai import types
import pyaudio # You'll need to install PyAudio

client = genai.Client(api_key="GEMINI_API_KEY")

# ... response code

stream = pya.open(
         format=FORMAT,
         channels=CHANNELS,
         rate=RECEIVE_SAMPLE_RATE,
         output=True)

def play_audio(chunks):
   chunk: Blob
   for chunk in chunks:
      stream.write(chunk.data)
Controlling speech style with prompts
You can control style, tone, accent, and pace using natural language prompts for both single- and multi-speaker TTS. For example, in a single-speaker prompt, you can say:


Say in an spooky whisper:
"By the pricking of my thumbs...
Something wicked this way comes"
In a multi-speaker prompt, provide the model with each speaker's name and corresponding transcript. You can also provide guidance for each speaker individually:


Make Speaker1 sound tired and bored, and Speaker2 sound excited and happy:

Speaker1: So... what's on the agenda today?
Speaker2: You're never going to guess!
Try using a voice option that corresponds to the style or emotion you want to convey, to emphasize it even more. In the previous prompt, for example, Enceladus's breathiness might emphasize "tired" and "bored", while Puck's upbeat tone could complement "excited" and "happy".

Generating a prompt to convert to audio
The TTS models only output audio, but you can use other models to generate a transcript first, then pass that transcript to the TTS model to read aloud.

Python
JavaScript

import { GoogleGenAI } from "@google/genai";

const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

async function main() {

const transcript = await ai.models.generateContent({
   model: "gemini-2.0-flash",
   contents: "Generate a short transcript around 100 words that reads like it was clipped from a podcast by excited herpetologists. The hosts names are Dr. Anya and Liam.",
   })

const response = await ai.models.generateContent({
   model: "gemini-2.5-flash-preview-tts",
   contents: transcript,
   config: {
      responseModalities: ['AUDIO'],
      speechConfig: {
         multiSpeakerVoiceConfig: {
            speakerVoiceConfigs: [
                   {
                     speaker: "Dr. Anya",
                     voiceConfig: {
                        prebuiltVoiceConfig: {voiceName: "Kore"},
                     }
                  },
                  {
                     speaker: "Liam",
                     voiceConfig: {
                        prebuiltVoiceConfig: {voiceName: "Puck"},
                    }
                  }
                ]
              }
            }
      }
  });
}
// ..JavaScript code for exporting .wav file for output audio

await main();
Voice options
TTS models support the following 30 voice options in the voice_name field:

Zephyr -- Bright	Puck -- Upbeat	Charon -- Informative
Kore -- Firm	Fenrir -- Excitable	Leda -- Youthful
Orus -- Firm	Aoede -- Breezy	Callirrhoe -- Easy-going
Autonoe -- Bright	Enceladus -- Breathy	Iapetus -- Clear
Umbriel -- Easy-going	Algieba -- Smooth	Despina -- Smooth
Erinome -- Clear	Algenib -- Gravelly	Rasalgethi -- Informative
Laomedeia -- Upbeat	Achernar -- Soft	Alnilam -- Firm
Schedar -- Even	Gacrux -- Mature	Pulcherrima -- Forward
Achird -- Friendly	Zubenelgenubi -- Casual	Vindemiatrix -- Gentle
Sadachbia -- Lively	Sadaltager -- Knowledgeable	Sulafat -- Warm
You can hear all the voice options in AI Studio.

Supported languages
The TTS models detect the input language automatically. They support the following 24 languages:

Language	BCP-47 Code	Language	BCP-47 Code
Arabic (Egyptian)	ar-EG	German (Germany)	de-DE
English (US)	en-US	Spanish (US)	es-US
French (France)	fr-FR	Hindi (India)	hi-IN
Indonesian (Indonesia)	id-ID	Italian (Italy)	it-IT
Japanese (Japan)	ja-JP	Korean (Korea)	ko-KR
Portuguese (Brazil)	pt-BR	Russian (Russia)	ru-RU
Dutch (Netherlands)	nl-NL	Polish (Poland)	pl-PL
Thai (Thailand)	th-TH	Turkish (Turkey)	tr-TR
Vietnamese (Vietnam)	vi-VN	Romanian (Romania)	ro-RO
Ukrainian (Ukraine)	uk-UA	Bengali (Bangladesh)	bn-BD
English (India)	en-IN & hi-IN bundle	Marathi (India)	mr-IN
Tamil (India)	ta-IN	Telugu (India)	te-IN
Supported models
Model	Single speaker	Multispeaker
Gemini 2.5 Flash Preview TTS	✔️	✔️
Gemini 2.5 Pro Preview TTS	✔️	✔️
Limitations
TTS models can only receive text inputs and generate audio outputs.
A TTS session has a context window limit of 32k tokens.
Review Languages section for language support.