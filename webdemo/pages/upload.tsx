import { useState, useCallback } from 'react';
import type { NextPage } from 'next';

const API_URL = process.env.NEXT_PUBLIC_API_URL;

const Upload: NextPage = () => {
  const [isUploading, setIsUploading] = useState(false);
  const [uploadStatus, setUploadStatus] = useState<string>('');
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [isDragging, setIsDragging] = useState(false);
  const [provider, setProvider] = useState<'ollama' | 'tencent'>('ollama');
  const [apiKey, setApiKey] = useState<string>('');

  const handleDragEnter = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(true);
  }, []);

  const handleDragLeave = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(false);
  }, []);

  const handleDragOver = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
  }, []);

  const handleDrop = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(false);

    const file = e.dataTransfer.files?.[0];
    if (file && file.type === 'application/pdf') {
      setSelectedFile(file);
      setUploadStatus('');
    } else {
      setSelectedFile(null);
      setUploadStatus('请选择 PDF 文件');
    }
  }, []);

  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file && file.type === 'application/pdf') {
      setSelectedFile(file);
      setUploadStatus('');
    } else {
      setSelectedFile(null);
      setUploadStatus('请选择 PDF 文件');
    }
  };

  const handleUpload = async () => {
    if (!selectedFile) {
      setUploadStatus('请先选择文件');
      return;
    }

    if (provider === 'tencent' && !apiKey.trim()) {
      setUploadStatus('请输入 API Key');
      return;
    }

    setIsUploading(true);
    setUploadStatus('正在分析 PDF 并进行翻译，可能耗时 10 分钟，请勿关闭页面，请勿刷新页面。翻译完成后会自动下载到本地文件夹。');

    try {
      const formData = new FormData();
      formData.append('file', selectedFile);
      formData.append('provider', provider);
      if (provider === 'tencent') {
        formData.append('api_key', apiKey);
      }
      
      const response = await fetch(`${API_URL}/rebuild_pdf`, {
        method: 'POST',
        body: formData,
      });

      if (!response.ok) {
        throw new Error(`上传失败: ${response.statusText}`);
      }

      if (response.headers.get('content-type') !== 'application/pdf') {
        const errorText = await response.text();
        throw new Error(`响应类型错误: ${errorText}`);
      }

      // 下载翻译后的 PDF
      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      // 根据原始文件名生成翻译后的文件名
      const originalName = selectedFile.name;
      const translatedName = originalName.replace('.pdf', '_translated.pdf');
      a.download = translatedName;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);

      setUploadStatus('文件处理成功，已下载至本地！');
    } catch (error) {
      console.error('上传错误:', error);
      setUploadStatus(`上传失败: ${error instanceof Error ? error.message : '未知错误'}`);
    } finally {
      setIsUploading(false);
    }
  };

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex flex-col space-y-4">
        <h1 className="text-2xl font-bold text-center mb-8">翻译 PDF 文件</h1>
        
        {/* 添加翻译模型选择 */}
        <div className="flex flex-col space-y-4 p-4 bg-gray-50 rounded-lg">
          <div className="flex items-center space-x-4">
            <span className="text-gray-700">选择翻译模型：</span>
            <select
              value={provider}
              onChange={(e) => setProvider(e.target.value as 'ollama' | 'tencent')}
              className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="ollama">本地模型 (Ollama)</option>
              <option value="tencent">在线模型 (腾讯云 Deepseek R1)</option>
            </select>
          </div>

          {provider === 'tencent' && (
            <div className="flex items-center space-x-4">
              <span className="text-gray-700">API Key：</span>
              <input
                type="password"
                value={apiKey}
                onChange={(e) => setApiKey(e.target.value)}
                placeholder="请输入腾讯云 API Key"
                className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>
          )}
        </div>

        {/* 原有的文件上传区域和其他内容保持不变 */}
        <p>
          使用须知：1、对电子版 PDF 识别较好，扫描的 PDF 可能效果较差。2、第一次上传 PDF 文件耗时可能长达几分钟。
        </p>

        {/* 拖拽上传区域 */}
        <div
          className={`w-full p-8 border-2 border-dashed rounded-lg transition-colors duration-200 ease-in-out
            ${isDragging 
              ? 'border-indigo-500 bg-indigo-50' 
              : 'border-gray-300 hover:border-indigo-400'
            }`}
          onDragEnter={handleDragEnter}
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          onDrop={handleDrop}
          style={{ minHeight: '400px' }}
        >
          <div className="flex flex-col items-center justify-center h-full space-y-4">
            <svg 
              className={`w-16 h-16 ${isDragging ? 'text-indigo-500' : 'text-gray-400'}`}
              fill="none" 
              stroke="currentColor" 
              viewBox="0 0 24 24"
            >
              <path 
                strokeLinecap="round" 
                strokeLinejoin="round" 
                strokeWidth={2} 
                d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" 
              />
            </svg>
            <div className="text-lg text-gray-600">
              {isDragging ? '松开鼠标上传文件' : '拖拽 PDF 文件到这里，或者'}
            </div>
            <input
              type="file"
              accept=".pdf"
              onChange={handleFileSelect}
              className="hidden"
              id="file-upload"
            />
            <label
              htmlFor="file-upload"
              className="px-4 py-2 text-sm font-medium text-white bg-indigo-600 rounded-md hover:bg-indigo-700 cursor-pointer"
            >
              选择文件
            </label>
            {selectedFile && (
              <div className="text-sm text-gray-600 mt-2">
                已选择: {selectedFile.name}
              </div>
            )}
            
            <div className="flex items-center space-x-2 mt-4">
              <span className="text-xl text-gray-500">或者点击这里使用</span>
              <button
                onClick={async () => {
                  try {
                    const response = await fetch('/sample_ikang.pdf');
                    const blob = await response.blob();
                    const file = new File([blob], 'sample_ikang.pdf', { type: 'application/pdf' });
                    setSelectedFile(file);
                    setUploadStatus('');
                  } catch (error) {
                    console.error('加载示例文件失败:', error);
                    setUploadStatus('加载示例文件失败');
                  }
                }}
                className="text-2xl text-indigo-600 hover:text-indigo-800 underline"
              >
                示例 PDF ikang
              </button>
              {/* <button
                onClick={async () => {
                  try {
                    const response = await fetch('/sample_hkuszh.pdf');
                    const blob = await response.blob();
                    const file = new File([blob], 'sample_hkuszh.pdf', { type: 'application/pdf' });
                    setSelectedFile(file);
                    setUploadStatus('');
                  } catch (error) {
                    console.error('加载示例文件失败:', error);
                    setUploadStatus('加载示例文件失败');
                  }
                }}
                className="text-2xl text-indigo-600 hover:text-indigo-800 underline"
              >
                示例 PDF HKUSZH
              </button> */}
            </div>

            {selectedFile && (
              <div className="text-sm text-gray-600 mt-2">
                已选择: {selectedFile.name}
              </div>
            )}
          </div>
        </div>

        {/* 上传按钮 */}
        <div className="flex justify-center">
          <button
            onClick={handleUpload}
            disabled={!selectedFile || isUploading}
            className={`px-8 py-3 rounded-md text-white font-medium
              ${!selectedFile || isUploading
                ? 'bg-gray-400 cursor-not-allowed'
                : 'bg-indigo-600 hover:bg-indigo-700'
              }
              focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500`}
          >
            {isUploading ? '处理中...' : '开始翻译'}
          </button>
        </div>

        {/* 状态提示 */}
        {uploadStatus && (
          <div className={`mt-4 p-4 rounded-md text-center ${
            uploadStatus.includes('成功')
              ? 'bg-green-50 text-green-700'
              : uploadStatus.includes('正在分析 PDF 并进行翻译，可能耗时 10 分钟，请勿关闭页面，请勿刷新页面')
                ? 'bg-blue-50 text-blue-700'
                : 'bg-red-50 text-red-700'
          }`}>
            {uploadStatus}
          </div>
        )}
      </div>
    </div>
  );
};

export default Upload;