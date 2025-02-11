import Link from 'next/link';

const Layout: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  return (
    <div className='min-h-screen flex flex-col bg-white'>
      <nav className="bg-blue-800 text-white p-4">
        <div className="container mx-auto flex space-x-4">
          <Link href="/" className="hover:text-gray-300">
            翻译文本
          </Link>
          <Link href="/upload" className="hover:text-gray-300">
            翻译PDF文件
          </Link>
          <Link href="/statistics" className="hover:text-gray-300">
            统计管理
          </Link>
        </div>
      </nav>
      <main className="flex-1">{children}</main>
    </div>
  );
};

export default Layout;