import os
import time

from magic_pdf.data.data_reader_writer import FileBasedDataWriter, FileBasedDataReader
from magic_pdf.data.dataset import PymuDocDataset
from magic_pdf.model.doc_analyze_by_custom_model import doc_analyze
from magic_pdf.config.enums import SupportedPdfParseMethod

def log_time(start_time, step_name):
    elapsed_time = time.time() - start_time
    print(f"[耗时统计] {step_name}: {elapsed_time:.2f} 秒")
    return time.time()

# 开始计时
total_start_time = time.time()

# args
pdf_file_name = "input/tj.pdf"  # replace with the real pdf path
name_without_suff = os.path.splitext(os.path.basename(pdf_file_name))[0]

# prepare env
local_image_dir, local_md_dir = "output/images", "output"
image_dir = str(os.path.basename(local_image_dir))

os.makedirs(local_image_dir, exist_ok=True)

image_writer, md_writer = FileBasedDataWriter(local_image_dir), FileBasedDataWriter(
    local_md_dir
)


# read bytes
reader1 = FileBasedDataReader("")
pdf_bytes = reader1.read(pdf_file_name)  # read the pdf content

# proc
## Create Dataset Instance
ds = PymuDocDataset(pdf_bytes)

## inference
if ds.classify() == SupportedPdfParseMethod.OCR:
    infer_result = ds.apply(doc_analyze, ocr=True)

    ## pipeline
    pipe_result = infer_result.pipe_ocr_mode(image_writer)

else:
    infer_result = ds.apply(doc_analyze, ocr=False)

    ## pipeline
    pipe_result = infer_result.pipe_txt_mode(image_writer)



### get model inference result
model_inference_result = infer_result.get_infer_res()

### get middle json
start_time = time.time()
middle_json_content = pipe_result.get_middle_json()
start_time = log_time(start_time, " get middle json")

### dump middle json
start_time = time.time()
pipe_result.dump_middle_json(md_writer, f'{name_without_suff}_middle.json')
start_time = log_time(start_time, "dump middle json ")