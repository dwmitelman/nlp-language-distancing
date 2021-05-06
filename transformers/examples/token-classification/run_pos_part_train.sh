#!/bin/bash

export MAX_LENGTH=200
export OUTPUT_DIR=postagger-model
export TRAINED_DIR=postagger-model-copy
export BATCH_SIZE=32
export NUM_EPOCHS=3
export SAVE_STEPS=750
export SEED=1
export BERT_MODEL=bert-base-multilingual-cased
export MAIN_DIR=/home/tapuz/language_distancing/transformers/examples/token-classification

echo START_RUNING
languages=(
  english
  ger man
  dutch
  spanish
  portugese
  french
  polish
  hungarian
  finnish
)

declare -A pairs_train=(
  [english]="https://raw.githubusercontent.com/UniversalDependencies/UD_English-EWT/master/en_ewt-ud-train.conllu"
  [german]="https://raw.githubusercontent.com/UniversalDependencies/UD_German-GSD/master/de_gsd-ud-train.conllu"
  [dutch]="https://raw.githubusercontent.com/UniversalDependencies/UD_Dutch-Alpino/master/nl_alpino-ud-train.conllu"
  [spanish]="https://raw.githubusercontent.com/UniversalDependencies/UD_Spanish-AnCora/master/es_ancora-ud-train.conllu"
  [portugese]="https://raw.githubusercontent.com/UniversalDependencies/UD_Portuguese-GSD/master/pt_gsd-ud-train.conllu"
  [french]="https://raw.githubusercontent.com/UniversalDependencies/UD_French-GSD/master/fr_gsd-ud-train.conllu"
  [polish]="https://raw.githubusercontent.com/UniversalDependencies/UD_Polish-PDB/master/pl_pdb-ud-train.conllu"
  [hungarian]="https://raw.githubusercontent.com/UniversalDependencies/UD_Hungarian-Szeged/master/hu_szeged-ud-train.conllu"
  [finnish]="https://raw.githubusercontent.com/UniversalDependencies/UD_Finnish-FTB/master/fi_ftb-ud-train.conllu"
)

declare -A pairs_dev=(
  [english]="https://raw.githubusercontent.com/UniversalDependencies/UD_English-EWT/master/en_ewt-ud-dev.conllu"
  [german]="https://raw.githubusercontent.com/UniversalDependencies/UD_German-GSD/master/de_gsd-ud-dev.conllu"
  [dutch]="https://raw.githubusercontent.com/UniversalDependencies/UD_Dutch-Alpino/master/nl_alpino-ud-dev.conllu"
  [spanish]="https://raw.githubusercontent.com/UniversalDependencies/UD_Spanish-AnCora/master/es_ancora-ud-dev.conllu"
  [portugese]="https://raw.githubusercontent.com/UniversalDependencies/UD_Portuguese-GSD/master/pt_gsd-ud-dev.conllu"
  [french]="https://raw.githubusercontent.com/UniversalDependencies/UD_French-GSD/master/fr_gsd-ud-dev.conllu"
  [polish]="https://raw.githubusercontent.com/UniversalDependencies/UD_Polish-PDB/master/pl_pdb-ud-dev.conllu"
  [hungarian]="https://raw.githubusercontent.com/UniversalDependencies/UD_Hungarian-Szeged/master/hu_szeged-ud-dev.conllu"
  [finnish]="https://raw.githubusercontent.com/UniversalDependencies/UD_Finnish-FTB/master/fi_ftb-ud-dev.conllu"
)

declare -A pairs_test=(
  [english]="https://raw.githubusercontent.com/UniversalDependencies/UD_English-EWT/master/en_ewt-ud-test.conllu"
  [german]="https://raw.githubusercontent.com/UniversalDependencies/UD_German-GSD/master/de_gsd-ud-test.conllu"
  [dutch]="https://raw.githubusercontent.com/UniversalDependencies/UD_Dutch-Alpino/master/nl_alpino-ud-test.conllu"
  [spanish]="https://raw.githubusercontent.com/UniversalDependencies/UD_Spanish-AnCora/master/es_ancora-ud-test.conllu"
  [portugese]="https://raw.githubusercontent.com/UniversalDependencies/UD_Portuguese-GSD/master/pt_gsd-ud-test.conllu"
  [french]="https://raw.githubusercontent.com/UniversalDependencies/UD_French-GSD/master/fr_gsd-ud-test.conllu"
  [polish]="https://raw.githubusercontent.com/UniversalDependencies/UD_Polish-PDB/master/pl_pdb-ud-test.conllu"
  [hungarian]="https://raw.githubusercontent.com/UniversalDependencies/UD_Hungarian-Szeged/master/hu_szeged-ud-test.conllu"
  [finnish]="https://raw.githubusercontent.com/UniversalDependencies/UD_Finnish-FTB/master/fi_ftb-ud-test.conllu"
)

for language_from in "${languages[@]}"; do

  cd $MAIN_DIR

  if [ -d $language_from ]; then
    rm -rf $language_from
    echo "DELETED dir $language_from"
  fi

  mkdir $language_from
  echo "CREATED dir $language_from"
  cd $language_from
  echo "Moved to dir: `pwd`"

  train_link="${pairs_train[$language_from]}"
  dev_link="${pairs_dev[$language_from]}"
  test_link="${pairs_test[$language_from]}"
  curl -L -o train.txt $train_link
  curl -L -o dev.txt $dev_link
  curl -L -o test.txt $test_link

  mkdir $OUTPUT_DIR

  python3 $MAIN_DIR/run_ner.py
  --task_type POS
  --data_dir .
  --model_name_or_path $BERT_MODEL
  --output_dir $OUTPUT_DIR
  --max_seq_length  $MAX_LENGTH
  --num_train_epochs $NUM_EPOCHS
  --per_gpu_train_batch_size $BATCH_SIZE
  --save_steps $SAVE_STEPS
  --seed $SEED
  --overwrite_cache
  --do_train
  --do_predict
  --part_train 0

  echo "Finished training for language $\{language_from\}"

  for language_to in "${languages[@]}"; do
      cd "${MAIN_DIR}/${language_from}"

      if [ -d $language_to ]; then
        rm -rf $language_to
        echo "DELETED TRAINED DIR!"
      fi
      mkdir $language_to

      cp $OUTPUT_DIR "${language_to}/${TRAINED_DIR}" -br

      cd "${MAIN_DIR}/${language_from}/${language_to}"

      rm -f train.txt
      echo "DELETED train.txt"
      rm -f test.txt
      echo "DELETED test.txt"

      train_link="${pairs_dev[$language_to]}"  # THIS IS NOT A MISTAKE, WE TRAIN WITH A SMALL BATCH OF DEV DATA!
      test_link="${pairs_test[$language_to]}"

      curl -L -o train.txt $train_link
      curl -L -o test.txt $test_link

      tested_dir="postagger-${language_from}-${language_to}-model"

      python3 $MAIN_DIR/run_ner.py
      --task_type POS
      --data_dir .
      --output_dir "${tested_dir}-prerun"
      --model_name_or_path $TRAINED_DIR
      --max_seq_length  $MAX_LENGTH
      --num_train_epochs $NUM_EPOCHS
      --per_gpu_train_batch_size $BATCH_SIZE
      --save_steps $SAVE_STEPS
      --seed $SEED
      --overwrite_cache
      --do_predict
      --part_train 0

      python3 $MAIN_DIR/run_ner.py
      --task_type POS
      --data_dir .
      --output_dir "${tested_dir}-afterrun"
      --model_name_or_path $TRAINED_DIR
      --max_seq_length  $MAX_LENGTH
      --num_train_epochs $NUM_EPOCHS
      --per_gpu_train_batch_size $BATCH_SIZE
      --save_steps $SAVE_STEPS
      --seed $SEED
      --overwrite_cache
      --do_train
      --do_predict
      --part_train 1
  done
done}