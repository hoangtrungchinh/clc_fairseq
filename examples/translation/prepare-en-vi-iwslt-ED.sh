#!/usr/bin/env bash
#
# Adapted from https://github.com/facebookresearch/MIXER/blob/master/prepareData.sh

echo 'Cloning Moses github repository (for tokenization scripts)...'
git clone https://github.com/moses-smt/mosesdecoder.git

echo 'Cloning Subword NMT repository (for BPE pre-processing)...'
git clone https://github.com/rsennrich/subword-nmt.git

SCRIPTS=mosesdecoder/scripts
TOKENIZER=$SCRIPTS/tokenizer/tokenizer.perl
LC=$SCRIPTS/tokenizer/lowercase.perl
CLEAN=$SCRIPTS/training/clean-corpus-n.perl
BPEROOT=subword-nmt/subword_nmt
BPE_TOKENS=10000

URL=https://github.com/hoangtrungchinh/clc_data/raw/master/en_vi_iwslt.tar.gz
GZ=en_vi_iwslt.tar.gz

prefix=ed-iwslt-
src=en
tgt=vi
lang=en-vi
prep=$prefix"tokenized.en-vi"
tmp=$prefix"$prep/tmp"
orig=$prefix"orig"

mkdir -p $orig $tmp $prep

echo "Downloading data from ${URL}..."
cd $orig
wget $URL

if [ -f $GZ ]; then
    echo "Data successfully downloaded."
else
    echo "Data not successfully downloaded."
    exit
fi

mkdir $lang
tar -xvf $GZ -C $lang
cd ..





echo "pre-processing train data..."
for l in $src $tgt; do
    f=train.$l.dual
    tok=train.tags.$lang.tok.$l

    cat $orig/$lang/$f | \
    perl $TOKENIZER -threads 8 -l $l > $tmp/$tok
    echo ""
done
# ==> replace abbreviations
# ==> create 2 file: "train.tags.en-vi.tok.vi" and "train.tags.en-vi.tok.en"
# pre-processing train data...
# Tokenizer Version 1.1
# Language: en
# Number of threads: 8

# Tokenizer Version 1.1
# Language: vi
# Number of threads: 8
# WARNING: No known abbreviations for language 'vi', attempting fall-back to English version...
#

perl $CLEAN -ratio 1.5 $tmp/train.tags.$lang.tok $src $tgt $tmp/train.tags.$lang.clean 1 175
# ==>
# ==> create 2 file: "train.tags.en-vi.clean.vi" and "train.tags.en-vi.clean.en"
# clean-corpus.perl: processing ed-iwslt-ed-iwslt-tokenized.en-vi/tmp/train.tags.en-vi.tok.en & .vi to ed-iwslt-ed-iwslt-tokenized.en-vi/tmp/train.tags.en-vi.clean, cutoff 1-175, ratio 1.5
# ..........(100000).
# Input sentences: 117055  Output sentences:  18604


for l in $src $tgt; do
    perl $LC < $tmp/train.tags.$lang.clean.$l > $tmp/train.tags.$lang.$l
done
# ==> Lowercase and create 2 file "train.tags.en-vi.vi" and "train.tags.en-vi.en" in tmp folder



echo "pre-processing valid/test data..."
for l in $src $tgt; do
    f=IWSLT15.TED.tst2015.$lang.$l
    tok=test.tags.$lang.tok.$l

    cat $orig/$lang/$f | \
    perl $TOKENIZER -threads 8 -l $l > $tmp/$tok
    perl $LC < $tmp/$tok > $tmp/test.tags.$lang.$l
    echo ""
done
# ==>
# pre-processing valid/test data...
# Tokenizer Version 1.1
# Language: en
# Number of threads: 8

# Tokenizer Version 1.1
# Language: vi
# Number of threads: 8
# WARNING: No known abbreviations for language 'vi', attempting fall-back to English version...



echo "creating train, valid, test..."
for l in $src $tgt; do
    awk '{if (NR%23 == 0)  print $0; }' $tmp/train.tags.en-vi.$l > $tmp/valid.$l
    awk '{if (NR%23 != 0)  print $0; }' $tmp/train.tags.en-vi.$l > $tmp/train.$l
    cat $tmp/test.tags.en-vi.$l > $tmp/test.$l
done
# creating train, valid, test...

TRAIN=$tmp/train.en-vi
BPE_CODE=$prep/code
rm -f $TRAIN
for l in $src $tgt; do
    cat $tmp/train.$l >> $TRAIN
done
# ==> create train.en-vi, which contain 2 language sentences


echo "learn_bpe.py on ${TRAIN}..."
python3 $BPEROOT/learn_bpe.py -s $BPE_TOKENS < $TRAIN > $BPE_CODE
# learn_bpe.py on tokenized.en-vi/tmp/train.en-vi...


# python clc_fairseq/examples/translation/script_ed.py -i $orig/$lang/train.$src -o $orig/$lang/train2.$src
# cat $orig/$lang/train.$src > $orig/$lang/train.$src.bak
# cat $orig/$lang/train2.$src > $orig/$lang/train.$src

for L in $src $tgt; do
    for f in train.$L valid.$L test.$L; do
        echo "apply_bpe.py to ${f}..."
        python3 $BPEROOT/apply_bpe.py -c $BPE_CODE < $tmp/$f > $prep/$f
    done
done
# ==> create 6 file in tokenized.en-vi folder
# apply_bpe.py to train.en...
# apply_bpe.py to valid.en...
# apply_bpe.py to test.en...
# apply_bpe.py to train.vi...
# apply_bpe.py to valid.vi...
# apply_bpe.py to test.vi...


# Preprocess/binarize the data
TEXT=$prefix"tokenized.en-vi" \
&& fairseq-preprocess --source-lang en --target-lang vi \
    --trainpref $TEXT/train --validpref $TEXT/valid --testpref $TEXT/test \
    --destdir $prefix"data-bin/tokenized.en-vi" \
    --workers 20
# 2020-12-01 04:54:02 | INFO | fairseq_cli.preprocess | [en] Dictionary: 7864 types
# 2020-12-01 04:54:04 | INFO | fairseq_cli.preprocess | [en] ed-iwslt-tokenized.en-vi/train.en: 17796 sents, 1056375 tokens, 0.0% replaced by <unk>
# 2020-12-01 04:54:04 | INFO | fairseq_cli.preprocess | [en] Dictionary: 7864 types
# 2020-12-01 04:54:04 | INFO | fairseq_cli.preprocess | [en] ed-iwslt-tokenized.en-vi/valid.en: 808 sents, 49782 tokens, 0.0241% replaced by <unk>
# 2020-12-01 04:54:04 | INFO | fairseq_cli.preprocess | [en] Dictionary: 7864 types
# 2020-12-01 04:54:05 | INFO | fairseq_cli.preprocess | [en] ed-iwslt-tokenized.en-vi/test.en: 1080 sents, 26133 tokens, 0.0191% replaced by <unk>
# 2020-12-01 04:54:05 | INFO | fairseq_cli.preprocess | [vi] Dictionary: 4952 types
# 2020-12-01 04:54:06 | INFO | fairseq_cli.preprocess | [vi] ed-iwslt-tokenized.en-vi/train.vi: 17796 sents, 723197 tokens, 0.0% replaced by <unk>
# 2020-12-01 04:54:06 | INFO | fairseq_cli.preprocess | [vi] Dictionary: 4952 types
# 2020-12-01 04:54:07 | INFO | fairseq_cli.preprocess | [vi] ed-iwslt-tokenized.en-vi/valid.vi: 808 sents, 33725 tokens, 0.0682% replaced by <unk>
# 2020-12-01 04:54:07 | INFO | fairseq_cli.preprocess | [vi] Dictionary: 4952 types
# 2020-12-01 04:54:07 | INFO | fairseq_cli.preprocess | [vi] ed-iwslt-tokenized.en-vi/test.vi: 1080 sents, 28749 tokens, 1.51% replaced by <unk>
# 2020-12-01 04:54:07 | INFO | fairseq_cli.preprocess | Wrote preprocessed data to ed-iwslt-data-bin/tokenized.en-vi

# data-bin
# └── tokenized.en-vi
#     ├── dict.en.txt
#     ├── dict.vi.txt
#     ├── preprocess.log
#     ├── test.en-vi.en.bin
#     ├── test.en-vi.en.idx
#     ├── test.en-vi.vi.bin
#     ├── test.en-vi.vi.idx
#     ├── train.en-vi.en.bin
#     ├── train.en-vi.en.idx
#     ├── train.en-vi.vi.bin
#     ├── train.en-vi.vi.idx
#     ├── valid.en-vi.en.bin
#     ├── valid.en-vi.en.idx
#     ├── valid.en-vi.vi.bin
#     └── valid.en-vi.vi.idx



# TRAINING
# mkdir -p $prefix"checkpoints/fconv_wmt_en_vi"

# CUDA_VISIBLE_DEVICES=0 fairseq-train $prefix"data-bin/tokenized.en-vi" \
#     --arch transformer --share-decoder-input-output-embed \
#     --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0.0 \
#     --lr 5e-4 --lr-scheduler inverse_sqrt --warmup-updates 400 \
#     --dropout 0.3 --weight-decay 0.0001 \
#     --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
#     --max-tokens 4096 \
#     --eval-bleu \
#     --eval-bleu-args '{"beam": 5, "max_len_a": 1.2, "max_len_b": 10}' \
#     --eval-bleu-detok moses \
#     --eval-bleu-remove-bpe \
#     --eval-bleu-print-samples \
#     --best-checkpoint-metric bleu --maximize-best-checkpoint-metric \
#     --save-dir $prefix"checkpoints/fconv_wmt_en_vi"

    # --max-epoch 1 \

# --arch
# Possible choices: transformer, transformer_iwslt_de_en, transformer_wmt_en_de, transformer_vaswani_wmt_en_de_big, transformer_vaswani_wmt_en_fr_big, transformer_wmt_en_de_big, transformer_wmt_en_de_big_t2t, multilingual_transformer, multilingual_transformer_iwslt_de_en, fconv, fconv_iwslt_de_en, fconv_wmt_en_ro, fconv_wmt_en_de, fconv_wmt_en_fr, nonautoregressive_transformer, nonautoregressive_transformer_wmt_en_de, nacrf_transformer, iterative_nonautoregressive_transformer, iterative_nonautoregressive_transformer_wmt_en_de, cmlm_transformer, cmlm_transformer_wmt_en_de, levenshtein_transformer, levenshtein_transformer_wmt_en_de, levenshtein_transformer_vaswani_wmt_en_de_big, levenshtein_transformer_wmt_en_de_big, insertion_transformer, bart_large, bart_base, mbart_large, mbart_base, mbart_base_wmt20, lstm, lstm_wiseman_iwslt_de_en, lstm_luong_wmt_en_de, transformer_lm, transformer_lm_big, transformer_lm_baevski_wiki103, transformer_lm_wiki103, transformer_lm_baevski_gbw, transformer_lm_gbw, transformer_lm_gpt, transformer_lm_gpt2_small, transformer_lm_gpt2_medium, transformer_lm_gpt2_big, transformer_align, transformer_wmt_en_de_big_align, hf_gpt2, hf_gpt2_medium, hf_gpt2_large, hf_gpt2_xl, transformer_from_pretrained_xlm, lightconv, lightconv_iwslt_de_en, lightconv_wmt_en_de, lightconv_wmt_en_de_big, lightconv_wmt_en_fr_big, lightconv_wmt_zh_en_big, lightconv_lm, lightconv_lm_gbw, fconv_self_att, fconv_self_att_wp, fconv_lm, fconv_lm_dauphin_wikitext103, fconv_lm_dauphin_gbw, lstm_lm, roberta, roberta_base, roberta_large, xlm, masked_lm, bert_base, bert_large, xlm_base, s2t_berard, s2t_berard_256_3_3, s2t_berard_512_3_2, s2t_berard_512_5_3, s2t_transformer, s2t_transformer_s, s2t_transformer_sp, s2t_transformer_m, s2t_transformer_mp, s2t_transformer_l, s2t_transformer_lp, wav2vec, wav2vec2, wav2vec_ctc, wav2vec_seq2seq, dummy_model, transformer_lm_megatron, transformer_lm_megatron_11b, transformer_iwslt_de_en_pipeline_parallel, transformer_wmt_en_de_big_pipeline_parallel, model_parallel_roberta, model_parallel_roberta_base, model_parallel_roberta_large

# --optimizer
# Possible choices: adafactor, sgd, adadelta, adagrad, nag, lamb, adam, adamax

# --clip-norm
# clip threshold of gradients, Default: 25.0

# --lr
# learning rate for the first N epochs; all epochs >N using LR_N (note: this may be interpreted differently depending on –lr-scheduler), Default: 0.25

# --criterion
# Possible choices: ctc, sentence_prediction, adaptive_loss, composite_loss, cross_entropy, legacy_masked_lm_loss, label_smoothed_cross_entropy, label_smoothed_cross_entropy_with_alignment, wav2vec, masked_lm, sentence_ranking, nat_loss, vocab_parallel_cross_entropy, Default: “cross_entropy”

# --max-tokens
# maximum number of tokens in a batch

# --maximize-best-checkpoint-metric
# select the largest metric value for saving “best” checkpoints, Default: False



# fairseq-interactive data-bin/tokenized.en-vi --path checkpoints/checkpoint_best.pt --beam 5
# ==>









