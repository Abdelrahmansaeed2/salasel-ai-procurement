import asyncio
import os
import sys
from groq import AsyncGroq

async def main():
    api_key = os.environ.get("GROQ_API_KEY")
    client = AsyncGroq(api_key=api_key)
    with open("record.wav", "rb") as f:
        audio_data = f.read()
    
    response = await client.audio.transcriptions.create(
        file=("record.wav", audio_data),
        model="whisper-large-v3-turbo",
        temperature=0.0,
        response_format="json"
    )
    print("Transcription:", response.text)

if __name__ == "__main__":
    asyncio.run(main())
