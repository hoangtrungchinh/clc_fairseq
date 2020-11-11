# HOW TO USE
# python3 api.py
# or
# export FLASK_RUN_PORT=6000
# set FLASK_APP=api
# flask run

# http://127.0.0.1:6000/clc_fairseq
# {
#     "src_str":"I went to the cinema"
# }

import flask
from flask import request, jsonify
import time
app = flask.Flask(__name__)
# app.config["DEBUG"] = True


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
