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





# ==>
# raise MissingConfigException(
# hydra.errors.MissingConfigException: Primary config directory not found.

import flask
from flask import request, jsonify
import time
app = flask.Flask(__name__)
app.config["DEBUG"] = True


import fastBPE
from fairseq.models.transformer import TransformerModel
model = TransformerModel.from_pretrained(
  'example_model_en_fr/wmt14.en-fr.fconv-py',
  checkpoint_file='model.pt',
  bpe='subword_nmt',
  bpe_codes = 'example_model_en_fr/wmt14.en-fr.fconv-py/bpecodes'
)
# model.translate('Hallo Welt!')

@app.route('/clc_fairseq', methods=['POST'])
def translate():
  start_time = time.time()
  src_str = request.json['src_str']
  res =  model.translate(src_str)
  return jsonify({'time': time.time() - start_time, 'res': res}), 200



app.run()





# fairseq-generate wmt14.en-fr.fconv-py \
#     --path model.pt \
#     --batch-size 128 --beam 5
# ==>
# hydra.errors.MissingConfigException: Primary config directory not found.
# Check that the config directory '/home/chinh/fairseq/fairseq/config' exists and readable