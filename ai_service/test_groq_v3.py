import asyncio
import os
from groq import AsyncGroq

async def main():
    api_key = os.environ.get("GROQ_API_KEY")
    client = AsyncGroq(api_key=api_key)
    with open("record.wav", "rb") as f:
        audio_data = f.read()
    
    # Try with whisper-large-v3-turbo
    response = await client.audio.transcriptions.create(
        file=("record.wav", audio_data),
        model="whisper-large-v3-turbo",
        prompt="Arabic Egyptian dialect. انا عايز كرتونة لبن",
        language="ar",
        temperature=0.0,
        response_format="json"
    )
    print("Transcription v3 turbo with prompt:", response.text)

if __name__ == "__main__":
    asyncio.run(main())
