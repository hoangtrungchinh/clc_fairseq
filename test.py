# MODEL_DIR=wmt14.en-fr.fconv-py
# fairseq-interactive \
#     --path $MODEL_DIR/model.pt $MODEL_DIR \
#     --beam 5 --source-lang en --target-lang fr \
#     --tokenizer moses \
#     --bpe subword_nmt \
#     --bpe-codes $MODEL_DIR/bpecodes
# ==>
# hydra.errors.MissingConfigException: Primary config directory not found.
# Check that the config directory '/home/chinh/fairseq/fairseq/config' exists and readable



# from fairseq.models.transformer import TransformerModel
# zh2en = TransformerModel.from_pretrained(
#   '/path/to/checkpoints',
#   checkpoint_file='checkpoint_best.pt',
#   data_name_or_path='data-bin/wmt17_zh_en_full',
#   bpe='subword_nmt',
#   bpe_codes='data-bin/wmt17_zh_en_full/zh.code'
# )



# python3 setup.py build_ext --inplace



# from fairseq.models.transformer import TransformerModel
# model = TransformerModel.from_pretrained(
#   'checkpoints',
#   checkpoint_file='checkpoint_best.pt',
#   bpe='subword_nmt',
#   bpe_codes = 'tokenized.en-vi/code'
# )
# print(model.translate('she'))




# from fairseq.models.transformer import TransformerModel
# model = TransformerModel.from_pretrained(
#   'example_model_en_fr/wmt14.en-fr.fconv-py',
#   checkpoint_file='model.pt',
#   bpe='subword_nmt',
#   bpe_codes = 'example_model_en_fr/wmt14.en-fr.fconv-py/bpecodes'
# )
# print(model.translate('she is going to school'))

import flask

app = flask.Flask(__name__)
app.config["DEBUG"] = True


@app.route('/', methods=['GET'])
def home():
    return "<h1>Distant Reading Archive</h1><p>This site is a prototype API for distant reading of science fiction novels.</p>"

app.run()









# import re
# import nltk
# import underthesea

# SPACE_NORMALIZER = re.compile(r"\s+")
# def tokenize_line(line):
#     line = SPACE_NORMALIZER.sub(" ", line)
#     line = line.strip()
#     return line.split()

# def tokenize_line_vi(line):
#     line = SPACE_NORMALIZER.sub(" ", line)
#     line = line.strip()
#     return nltk.word_tokenize(line)

# def tokenize_line_underthesea(line):
#     line = SPACE_NORMALIZER.sub(" ", line)
#     line = line.strip()
#     return underthesea.word_tokenize(line)

# tk=tokenize_line_underthesea("bà ta là một đảng viên đã đóng đảng phí đầy đủ .")
# print(tk)
# tk=tokenize_line_underthesea("Chàng trai 9X Quảng Trị khởi nghiệp từ nấm sò")
# print(tk)




