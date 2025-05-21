from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from dotenv import load_dotenv
import base64
import openai
import os

app = FastAPI()

# .env 파일 로드
load_dotenv()

# 환경 변수에서 API 키 가져오기
openai.api_key = os.getenv("OPENAI_API_KEY")

@app.post("/upload/photo")
async def upload_photo(photo: UploadFile = File(...)):
    # 이미지 파일 읽기 및 base64 인코딩
    image_data = await photo.read()
    base64_image = base64.b64encode(image_data).decode('utf-8')

    # Vision API 요청 (chat.completions.create 방식 사용)
    response = openai.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": "이 이미지를 1줄 에서 2줄 분량으로 설명해줘."},
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/jpeg;base64,{base64_image}"
                        }
                    }
                ]
            }
        ],
        max_tokens=200
    )

    description = response.choices[0].message.content.strip()

    return JSONResponse(content={
        "status": "success",
        "message": "사진 설명 생성 완료",
        "data": {
            "photo_id": "photo_20250413_123456",
            "description": description
        }
    })
