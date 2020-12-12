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
REM_NON_PRINT_CHAR=$SCRIPTS/tokenizer/remove-non-printing-char.perl
NORM_PUNC=$SCRIPTS/tokenizer/normalize-punctuation.perl

URL=https://github.com/hoangtrungchinh/clc_data/raw/master/en_vi_iwslt.tar.gz
GZ=en_vi_iwslt.tar.gz

prefix=clc-
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
    f=train.$l
    cat $orig/$lang/$f | \
        perl $NORM_PUNC $l | \
        perl $REM_NON_PRINT_CHAR | \
        perl $TOKENIZER -threads 8 -a -l $l >> $tmp/train.tags.$lang.tok.$l
done

echo "pre-processing test data..."
for l in $src $tgt; do
    cat $orig/$lang/$f | \
    perl $TOKENIZER -threads 8 -a -l $l > $tmp/test.$l
    echo ""
done

echo "splitting train and valid..."
for l in $src $tgt; do
    awk '{if (NR%100 == 0)  print $0; }' $tmp/train.tags.$lang.tok.$l > $tmp/valid.$l
    awk '{if (NR%100 != 0)  print $0; }' $tmp/train.tags.$lang.tok.$l > $tmp/train.$l
done

TRAIN=$tmp/train.en-vi
BPE_CODE=$prep/code
rm -f $TRAIN
for l in $src $tgt; do
    cat $tmp/train.$l >> $TRAIN
done

echo "learn_bpe.py on ${TRAIN}..."
python $BPEROOT/learn_bpe.py -s $BPE_TOKENS < $TRAIN > $BPE_CODE

for L in $src $tgt; do
    for f in train.$L valid.$L test.$L; do
        echo "apply_bpe.py to ${f}..."
        python $BPEROOT/apply_bpe.py -c $BPE_CODE < $tmp/$f > $tmp/bpe.$f
    done
done

perl $CLEAN -ratio 1.5 $tmp/bpe.train $src $tgt $prep/train 1 250
perl $CLEAN -ratio 1.5 $tmp/bpe.valid $src $tgt $prep/valid 1 250

for L in $src $tgt; do
    cp $tmp/bpe.test.$L $prep/test.$L
done
