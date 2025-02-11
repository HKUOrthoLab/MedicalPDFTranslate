

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import requests
import json
import os
import re
from openai import OpenAI
from typing import Optional

app = FastAPI()

# 配置 CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class TranslationRequest(BaseModel):
    text: str
    provider: Optional[str] = "ollama"  # 可选值：ollama, tencent
    api_key: Optional[str] = None

class TranslationResponse(BaseModel):
    translated_text: str

# 从环境变量获取 Ollama API URL，如果没有则使用默认值
#OLLAMA_API_URL = os.getenv('OLLAMA_API_URL', 'http://host.docker.internal:11434')
OLLAMA_API_URL = 'http://host.docker.internal:11434'

@app.post("/api/translate", response_model=TranslationResponse)
def translate(request: TranslationRequest):
    try:
        if request.provider == "tencent":
            if not request.api_key:
                raise HTTPException(status_code=400, detail="API key is required for Tencent Cloud")
            return translate_with_tencent(request.text, request.api_key)
        else:
            return translate_with_ollama(request.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def translate_with_ollama(text: str) -> TranslationResponse:
    try:
        prompt = f"你是一个翻译助手，你负责把中文翻译成英文。无论我发给你什么内容，只返回英文翻译结果，不要有任何其他解释。保留原始的文本结构和格式不要变，只做翻译，不要说多余的话。请翻译:\n{text}\n"
        
        # 调用 Ollama API
        response = requests.post(
            f"{OLLAMA_API_URL}/api/generate",
            json={
                "model": "deepseek-r1:1.5b",
                "prompt": prompt,
            },
            timeout=300
        )
        
        if response.status_code != 200:
            raise HTTPException(status_code=500, detail="Translation service error")
            
        # 处理响应
        translated_text = ""
        for line in response.text.splitlines():
            if line.strip():
                try:
                    data = json.loads(line)
                    if "response" in data:
                        translated_text += data["response"]
                except json.JSONDecodeError:
                    continue
        
        # 清理结果中的特殊标记
        cleaned_text = translated_text.strip()
        cleaned_text = re.sub(r'<think>.*?</think>\s*\n*', '', cleaned_text, flags=re.DOTALL)
                    
        return TranslationResponse(translated_text=cleaned_text.strip())
        
    except requests.Timeout:
        raise HTTPException(status_code=504, detail="Translation service timeout")
    except requests.ConnectionError:
        raise HTTPException(status_code=503, detail="Translation service unavailable")

def translate_with_tencent(text: str, api_key: str) -> TranslationResponse:
    try:
        client = OpenAI(
            api_key=api_key,
            base_url="https://api.lkeap.cloud.tencent.com/v1",
        )
        
        prompt = f"你是一个翻译助手，你负责把中文翻译成英文。无论我发给你什么内容，只返回英文翻译结果，不要有任何其他解释。保留原始的文本结构和格式不要变，只做翻译，不要说多余的话。请翻译:\n{text}\n"
        
        chat_completion = client.chat.completions.create(
            model="deepseek-r1",
            messages=[
                {
                    "role": "user",
                    "content": prompt,
                }
            ],
            stream=False,
        )
        
        result = chat_completion.choices[0].message.content
        return TranslationResponse(translated_text=result.strip())
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Tencent translation error: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)