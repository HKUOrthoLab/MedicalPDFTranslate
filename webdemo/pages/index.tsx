// lab-home/pages/tools/translate/index.tsx

import { FC, useState, useEffect} from 'react';
import Head from 'next/head';

const API_URL = process.env.NEXT_PUBLIC_API_URL;
//const API_URL = 'http://localhost:18180';

//const ONLINE_API_URL = process.env.NEXT_PUBLIC_ONLINE_API_URL; // 在线模型 API

const ONLINE_API_URL = process.env.NEXT_APP_ONLINE_API_URL;
const APP_API_KEY= process.env.NEXT_APP_API_ONLINE_KEY;


type ModelType = 'local' | 'online';
type Provider = 'groq' | 'deepseek';

type LocalModel = {
  id: string;
  name: string;
  type: 'local';
};

type OnlineModel = {
  id: string;
  name: string;
  provider: Provider;
  type: 'online';
};

// API 响应的模型类型
interface ApiModel {
  id: string;
  name: string;
  provider: Provider;
}

interface ApiResponse {
  models: ApiModel[];
}

type Model = LocalModel | OnlineModel;

// 本地模型列表
const LOCAL_MODELS: LocalModel[] = [
  { 
    id: 'deepseek:14b', 
    name: 'Deepseek R1 14B (Local)', 
    type: 'local',
  }
];

const TranslatePage: FC = () => {
  const [modelType, setModelType] = useState<ModelType>('local');
  const [onlineModels, setOnlineModels] = useState<OnlineModel[]>([]);
  const [selectedModel, setSelectedModel] = useState<Model>(LOCAL_MODELS[0]);
  const [isLoadingModels, setIsLoadingModels] = useState(false);
  const [modelError, setModelError] = useState('');
  
  const [inputText, setInputText] = useState('');
  const [outputText, setOutputText] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  // 获取在线模型列表
  useEffect(() => {
    const fetchOnlineModels = async () => {
      if (modelType === 'online' && onlineModels.length === 0) {
        setIsLoadingModels(true);
        setModelError('');
        
        try {
          const response = await fetch(`${ONLINE_API_URL}/models`, {
            headers: {
              'X-API-Key': APP_API_KEY,
            },
          });

          if (!response.ok) {
            throw new Error('获取模型列表失败');
          }

          const data = await response.json() as ApiResponse;
          const models: OnlineModel[] = data.models.map((model) => ({
            ...model,
            type: 'online' as const,
          }));
          
          setOnlineModels(models);
          
          // 如果是首次加载在线模型，自动选择第一个
          if (models.length > 0 && modelType === 'online') {
            setSelectedModel(models[0]);
          }
        } catch (err) {
          setModelError(err instanceof Error ? err.message : '获取模型列表失败');
        } finally {
          setIsLoadingModels(false);
        }
      }
    };

    fetchOnlineModels();
  }, [modelType, onlineModels.length]); 

  // 处理模型类型变更
  const handleModelTypeChange = (type: ModelType) => {
    setModelType(type);
    if (type === 'local') {
      setSelectedModel(LOCAL_MODELS[0]);
    } else if (onlineModels.length > 0) {
      setSelectedModel(onlineModels[0]);
    }
  };

  const handleTranslate = async () => {
    if (!inputText.trim()) {
      setError('请输入需要翻译的文本');
      return;
    }

    setIsLoading(true);
    setError('');

    try {
      const apiUrl = selectedModel.type === 'local' ? API_URL : ONLINE_API_URL;
      
      const response = await fetch(`${apiUrl}/translate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': APP_API_KEY,
        },
        body: JSON.stringify({ 
          text: inputText,
          model: selectedModel.id,
          provider: (selectedModel as OnlineModel).provider // 仅对在线模型添加provider
        }),
      });

      if (!response.ok) {
        throw new Error('翻译服务出错');
      }

      const data = await response.json();
      setOutputText(data.translated_text);
    } catch (err) {
      setError(err instanceof Error ? err.message : '翻译失败，请稍后重试');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="container mx-auto min-h-screen ">
      <Head>
        <title>医疗报告翻译 - Scoli+ Lab</title>
        <meta name="description" content="中英文本翻译工具" />
      </Head>

      <main className="flex-1 mx-auto px-4 py-8">
        <h1 className="text-3xl font-bold text-gray-800 mb-6 text-center">
          翻译医疗文本
        </h1>

        {/* 控制区域 */}
        <div className="flex items-end gap-4 mb-6">
          {/* 模型类型选择 */}
          <div className="flex-grow max-w-xs">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              选择模型类型
            </label>
            <select
              value={modelType}
              onChange={(e) => handleModelTypeChange(e.target.value as ModelType)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg
                focus:ring-2 focus:ring-blue-500 focus:border-blue-500 
                bg-white shadow-sm"
            >
              <option value="local">本地模型</option>
              <option value="online">在线模型</option>
            </select>
          </div>

          {/* 具体模型选择（仅在线模型时显示） */}
          {modelType === 'online' && (
            <div className="flex-grow max-w-xs">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                选择在线模型
              </label>
              <select
                value={selectedModel.id}
                onChange={(e) => {
                  const model = onlineModels.find(m => m.id === e.target.value);
                  if (model) setSelectedModel(model);
                }}
                disabled={isLoadingModels}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg
                  focus:ring-2 focus:ring-blue-500 focus:border-blue-500 
                  bg-white shadow-sm disabled:bg-gray-100"
              >
                {isLoadingModels ? (
                  <option>加载中...</option>
                ) : (
                  onlineModels.map((model) => (
                    <option key={model.id} value={model.id}>
                      {model.name}
                    </option>
                  ))
                )}
              </select>
            </div>
          )}

          {/* 翻译按钮 */}
          <div>
            <button
              onClick={handleTranslate}
              disabled={isLoading || isLoadingModels}
              className={`
                px-8 py-2 rounded-lg text-white font-medium
                transition duration-150 ease-in-out
                ${(isLoading || isLoadingModels)
                  ? 'bg-gray-400 cursor-not-allowed'
                  : 'bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2'
                }
              `}
            >
              {isLoading ? '翻译中...' : '翻译'}
            </button>
          </div>
        </div>

        {/* 错误信息 */}
        {(error || modelError) && (
          <div className="mb-4 text-red-600">
            {error || modelError}
          </div>
        )}

        {/* 文本框区域 */}
        <div className="grid md:grid-cols-2 gap-6">
          {/* 输入区域 */}
          <div className="space-y-2">
            <label 
              htmlFor="input" 
              className="block text-sm font-medium text-gray-700"
            >
              输入文本
            </label>
            <textarea
              id="input"
              value={inputText}
              onChange={(e) => setInputText(e.target.value)}
              className="w-full h-[calc(100vh-400px)] md:h-[600px] p-4 
                border border-gray-300 rounded-lg
                focus:ring-2 focus:ring-blue-500 focus:border-blue-500 
                resize-none bg-white shadow-sm"
              placeholder="请输入需要翻译的中文文本..."
            />
          </div>
  
          {/* 输出区域 */}
          <div className="space-y-2">
            <label 
              htmlFor="output" 
              className="block text-sm font-medium text-gray-700"
            >
              翻译结果
            </label>
            <textarea
              id="output"
              value={outputText}
              readOnly
              className="w-full h-[calc(100vh-400px)] md:h-[600px] p-4 
                border border-gray-300 rounded-lg
                bg-gray-50 resize-none shadow-sm"
              placeholder="翻译结果将显示在这里..."
            />
          </div>
        </div>
      </main>

    </div>
  );
};
export default TranslatePage;