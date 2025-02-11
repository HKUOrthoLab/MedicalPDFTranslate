

interface PDFViewerProps {
  file: string;
}

const PDFViewer: React.FC<PDFViewerProps> = ({ file }) => {
  return (
    <div className="pdf-container">
      <iframe
        src={file}
        style={{
          width: '100%',
          height: 'calc(100vh - 250px)',
          border: 'none',
        }}
        title="PDF Viewer"
      />
    </div>
  );
};

export default PDFViewer;