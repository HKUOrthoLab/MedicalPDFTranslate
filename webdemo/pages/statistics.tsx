import { useState, useEffect, useCallback } from 'react';
import type { NextPage } from 'next';
const API_URL = process.env.NEXT_PUBLIC_API_URL;

interface Translation {
  id: number;
  source_text: string;
  confirmed_translation: string | null;
  is_confirmed: boolean;
  return_original: boolean;
  total_frequency: number;  // 添加这行
  machine_translations: {
    text: string;
    frequency: number;
  }[];
}

interface PaginatedResponse {
  total: number;
  page: number;
  page_size: number;
  data: Translation[];
}


  
const Home: NextPage = () => {
  const [translations, setTranslations] = useState<PaginatedResponse | null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [isLoading, setIsLoading] = useState(true);
  const [editingTranslation, setEditingTranslation] = useState<Translation | null>(null);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState<number | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  // 添加筛选条件状态
  const [filters, setFilters] = useState({
    is_confirmed: '',
    return_original: '',
    sort_by: 'time'  // 默认按时间排序
  });

  // 修改 fetchTranslations 函数
  const fetchTranslations = useCallback(async () => {
    try {
      // 构建查询参数
      const params = new URLSearchParams({
        page: currentPage.toString(),
        sort_by: filters.sort_by
      });
      
      if (filters.is_confirmed !== '') {
        params.append('is_confirmed', filters.is_confirmed);
      }
      if (filters.return_original !== '') {
        params.append('return_original', filters.return_original);
      }
      const response = await fetch(`${API_URL}/translations?${params}`); 
      //const response = await fetch(`http://localhost:18180/translations?${params}`);
      const data = await response.json();
      setTranslations(data);
    } catch (error) {
      console.error('Error fetching translations:', error);
    } finally {
      setIsLoading(false);
    }
  }, [currentPage, filters]);

  useEffect(() => {
    fetchTranslations();
  }, [currentPage, filters, fetchTranslations]); // 添加所有依赖项

  // 首先定义更新数据的接口
  interface UpdateTranslationData {
    confirmed_translation: string | null;
    is_confirmed: boolean;
    return_original: boolean;
  }

  const handleUpdate = async (id: number, data: UpdateTranslationData) => {
    setIsSubmitting(true);
    try {
      console.log('[Update] Sending request:', { id, data });

      const response = await fetch(`${API_URL}/translations/${id}`, {
      //const response = await fetch(`http://localhost:18180/translations/${id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json'
        },
        body: JSON.stringify(data),
      });

      const responseText = await response.text();
      console.log('[Update] Response text:', responseText);

      // 尝试解析响应
      let responseData;
      try {
        responseData = JSON.parse(responseText);
      } catch {
        throw new Error('Invalid JSON response from server');
      }

      if (!response.ok) {
        throw new Error(`Failed to update translation: ${responseData.error || 'Unknown error'}`);
      }

      console.log('[Update] Success:', responseData);
      await fetchTranslations();
      setEditingTranslation(null);
    } catch (error) {
      console.error('[Update] Error details:', error);
      alert(error instanceof Error ? error.message : 'Failed to update translation');
    } finally {
      setIsSubmitting(false);
    }
  };

  // 修改 handleDelete 函数
  const handleDelete = async (id: number) => {
    setIsSubmitting(true);
    try {
      const response = await fetch(`${API_URL}/translations/${id}`, {
      //const response = await fetch(`http://localhost:18180/translations/${id}`, {
        method: 'DELETE',
        headers: {
          'accept': 'application/json'
        }
      });

      const responseText = await response.text();
      console.log('[Delete] Response text:', responseText);

      if (!response.ok) {
        throw new Error('Failed to delete translation');
      }

      await fetchTranslations();
      setShowDeleteConfirm(null);
    } catch (error) {
      console.error('Error deleting translation:', error);
      alert('Failed to delete translation');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900"></div>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-8 py-8 max-w-[90%]">
      <h1 className="text-3xl font-bold mb-6">统计与审核管理</h1>
      <p className="mb-4">
        此页面显示了所有翻译记录。您可以编辑、删除或审核记录。
        1、已审核：审核完成的记录会在之后的翻译过程中作为标准答案输出。未审核的记录会在之后的过程中作为备选答案输出。
        2、不要翻译直接返回原文输出吗：如果您认为原文不需要翻译成英文，您可以选择不要翻译直接返回原文输出。
        3、原文是英文和数字的情况会直接输出原文，不会调用大模型
      </p>
      
      {/* 添加筛选条件区域 */}
      <div className="mb-6 p-4 bg-white shadow-md rounded-lg">
        <div className="flex items-center space-x-4">
          <div className="flex items-center">
            <label className="mr-2 text-sm font-medium text-gray-700">审核状态:</label>
            <select
              value={filters.is_confirmed}
              onChange={(e) => setFilters(prev => ({ ...prev, is_confirmed: e.target.value }))}
              className="rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            >
              <option value="">全部</option>
              <option value="true">已审核</option>
              <option value="false">待审核</option>
            </select>
          </div>
          
          <div className="flex items-center">
            <label className="mr-2 text-sm font-medium text-gray-700">返回原文:</label>
            <select
              value={filters.return_original}
              onChange={(e) => setFilters(prev => ({ ...prev, return_original: e.target.value }))}
              className="rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            >
              <option value="">全部</option>
              <option value="true">是</option>
              <option value="false">否</option>
            </select>
          </div>

          <div className="flex items-center">
                <label className="mr-2 text-sm font-medium text-gray-700">排序方式:</label>
                <select
                value={filters.sort_by}
                onChange={(e) => setFilters(prev => ({ ...prev, sort_by: e.target.value }))}
                className="rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                >
                <option value="time">按时间</option>
                <option value="frequency">按频率</option>
                </select>
          </div>
          
          <button
            onClick={() => {
              setCurrentPage(1);  // 重置页码
              fetchTranslations();
            }}
            className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
          >
            查询
          </button>
        </div>
      </div>

      {/* 原有的表格和其他内容 */}
      <div className="overflow-x-auto bg-white shadow-md rounded-lg">
        <table className="min-w-full table-auto">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">未翻译原文</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">不要翻译直接返回原文输出吗</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">人工确认翻译结果</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">机器翻译结果列表</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">机器翻译总次数</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">状态</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">操作</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {translations && translations.data && translations.data.map((translation) => (
              <tr key={translation.id} className="hover:bg-gray-50">
                <td className="px-6 py-4 text-sm text-gray-900 whitespace-pre-wrap min-w-[400px] max-w-md">
                    {translation.source_text}
                </td>

                <td className="px-6 py-4 whitespace-nowrap">
                  <span
                    className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                      translation.return_original
                        ? 'bg-blue-100 text-blue-800'
                        : 'bg-gray-100 text-gray-800'
                    }`}
                  >
                    {translation.return_original ? 'Yes' : 'No'}
                  </span>
                </td>

                <td className="px-6 py-4 text-sm text-gray-500 whitespace-pre-wrap min-w-[400px] max-w-md">
                  {translation.confirmed_translation || 'Not confirmed'}
                </td>



                <td className="px-6 py-4 text-sm text-gray-500">
                    <ul>
                        {translation.machine_translations.map((mt, idx) => (
                            <li key={idx} className="mb-1 flex items-center gap-2">
                                <button
                                    onClick={() => handleUpdate(translation.id, {
                                        confirmed_translation: mt.text,
                                        is_confirmed: true,
                                        return_original: translation.return_original
                                    })}
                                    className="flex-shrink-0 px-2 py-1 text-xs bg-blue-500 text-white rounded hover:bg-green-600 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2"
                                >
                                👈 采纳
                                </button>
                                <div className="flex-grow text-left">
                                    {mt.text} <span className="text-xs text-gray-400">(freq: {mt.frequency})</span>
                                </div>
                            </li>
                        ))}
                    </ul>
                </td>

                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  <span className="ml-2 px-2 py-1 text-xs bg-gray-100 text-gray-600 rounded-full">
                     {translation.total_frequency} 次
                  </span>
                </td>

                <td className="px-6 py-4 whitespace-nowrap">
                  <span
                    className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                      translation.is_confirmed
                        ? 'bg-green-100 text-green-800'
                        : 'bg-yellow-100 text-yellow-800'
                    }`}
                  >
                    {translation.is_confirmed ? '已审核' : '待审核'}
                  </span>
                </td>



                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <button
                    onClick={() => setEditingTranslation(translation)}
                    className="text-indigo-600 hover:text-indigo-900 mr-4"
                  >
                    Edit
                  </button>
                  <button
                    onClick={() => setShowDeleteConfirm(translation.id)}
                    className="text-red-600 hover:text-red-900"
                  >
                    Delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {translations && (
        <div className="mt-4 flex items-center justify-between">
          <div className="text-sm text-gray-700">
            Showing page {translations.page} of {Math.ceil(translations.total / translations.page_size)}
          </div>
          <div className="flex space-x-2">
            <button
              onClick={() => setCurrentPage(prev => Math.max(1, prev - 1))}
              disabled={currentPage === 1}
              className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Previous
            </button>
            <button
              onClick={() => setCurrentPage(prev => prev + 1)}
              disabled={translations.page * translations.page_size >= translations.total}
              className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Next
            </button>
          </div>
        </div>
      )}

      {/* Edit Modal */}
      {editingTranslation && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full">
          <div className="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium leading-6 text-gray-900">Edit Translation</h3>
              <div className="mt-2 space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">Confirmed Translation</label>
                  <textarea
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                    rows={3}
                    value={editingTranslation.confirmed_translation || ''}
                    onChange={(e) => setEditingTranslation({
                      ...editingTranslation,
                      confirmed_translation: e.target.value
                    })}
                  />
                </div>
                <div className="flex items-center">
                  <input
                    type="checkbox"
                    className="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
                    checked={editingTranslation.is_confirmed}
                    onChange={(e) => setEditingTranslation({
                      ...editingTranslation,
                      is_confirmed: e.target.checked
                    })}
                  />
                  <label className="ml-2 block text-sm text-gray-900">Mark as confirmed</label>
                </div>
                <div className="flex items-center">
                  <input
                    type="checkbox"
                    className="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
                    checked={editingTranslation.return_original}
                    onChange={(e) => setEditingTranslation({
                      ...editingTranslation,
                      return_original: e.target.checked
                    })}
                  />
                  <label className="ml-2 block text-sm text-gray-900">Return original</label>
                </div>
              </div>
              <div className="mt-4 flex justify-end space-x-3">
                <button
                  onClick={() => setEditingTranslation(null)}
                  className="px-4 py-2 bg-white border border-gray-300 rounded-md font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                >
                  Cancel
                </button>
                <button
                  onClick={() => handleUpdate(editingTranslation.id, {
                    confirmed_translation: editingTranslation.confirmed_translation,
                    is_confirmed: editingTranslation.is_confirmed,
                    return_original: editingTranslation.return_original
                  })}
                  disabled={isSubmitting}
                  className="px-4 py-2 bg-indigo-600 border border-transparent rounded-md font-medium text-white hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isSubmitting ? 'Saving...' : 'Save'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {showDeleteConfirm !== null && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full">
          <div className="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium leading-6 text-gray-900">Confirm Delete</h3>
              <div className="mt-2">
                <p className="text-sm text-gray-500">Are you sure you want to delete this translation? This action cannot be undone.</p>
              </div>
              <div className="mt-4 flex justify-end space-x-3">
                <button
                  onClick={() => setShowDeleteConfirm(null)}
                  className="px-4 py-2 bg-white border border-gray-300 rounded-md font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                >
                  Cancel
                </button>
                <button
                  onClick={() => handleDelete(showDeleteConfirm)}
                  disabled={isSubmitting}
                  className="px-4 py-2 bg-red-600 border border-transparent rounded-md font-medium text-white hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isSubmitting ? 'Deleting...' : 'Delete'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Home;