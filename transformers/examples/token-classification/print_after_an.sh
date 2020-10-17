{\rtf1\ansi\ansicpg1252\cocoartf2513
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 #!/bin/bash\
\
export MAIN_DIR=/home/tapuz/language_distancing/transformers/examples/token-classification\
\
echo START_ PRINT\
languages=(\
  english\
  german\
  dutch\
  spanish\
  portugese\
  french\
  polish\
  hungarian\
  finnish\
)\
\
cd $MAIN_DIR #0\
#echo "0 Moved to dir: `pwd`"\
\
for language_from in "$\{languages[@]\}"; do\
\
  if [ -d $language_from ]; then\
    cd $language_from #1\
    #echo "Moved to dir: `pwd`"\
\
    for language_to in "$\{languages[@]\}"; do\
      if [ -d $language_to ]; then\
        cd $language_to #2\
        echo "Moved to dir: `pwd`"\
        prerun_dir="postagger-$\{language_from\}-$\{language_to\}-model-prerun"\
\
        cd $prerun_dir #3\
        #echo "Moved to dir: `pwd`"\
              #echo "prerun $\{language_to\}"\
        #cat test_results.txt | grep eval_f1\
        cd ../ #3\
\
        afterrun_dir="postagger-$\{language_from\}-$\{language_to\}-model-afterrun"\
        cd $afterrun_dir #3\
        #echo "Moved to dir: `pwd`"\
              #echo "afterrun $\{language_to\}"\
        cat test_results.txt | grep eval_f1\
        cd ../ #3\
        cd ../ #2\
\
      fi\
    done\
\
    cd ../ #1\
  fi\
done}