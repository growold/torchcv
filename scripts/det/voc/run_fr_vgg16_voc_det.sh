#!/usr/bin/env bash

# check the enviroment info
nvidia-smi
PYTHON="python"

export PYTHONPATH="/home/donny/Projects/TorchCV":$PYTHONPATH

cd ../../../

DATA_DIR="/home/donny/DataSet/VOC07_DET"
MODEL_NAME="faster_rcnn"
LOSS_TYPE="fr_loss"
CHECKPOINTS_NAME="fr_vgg16_voc_det"$2
PRETRAINED_MODEL="./pretrained_models/faster_rcnn_vgg16_caffe_pretrained.pth"
HYPES_FILE='hypes/det/voc/fr_vgg16_voc_det.json'

LOG_DIR="./log/det/voc/"
LOG_FILE="${LOG_DIR}${CHECKPOINTS_NAME}.log"

if [[ ! -d ${LOG_DIR} ]]; then
    echo ${LOG_DIR}" not exists!!!"
    mkdir -p ${LOG_DIR}
fi

if [[ "$1"x == "train"x ]]; then
  ${PYTHON} -u main.py --hypes ${HYPES_FILE} --phase train --log_to_file n --gpu 0 --cudnn n \
                       --data_dir ${DATA_DIR} --loss_type ${LOSS_TYPE} --model_name ${MODEL_NAME} \
                       --checkpoints_name ${CHECKPOINTS_NAME} --pretrained ${PRETRAINED_MODEL}  2>&1 | tee ${LOG_FILE}

elif [[ "$1"x == "resume"x ]]; then
  ${PYTHON} -u main.py --hypes ${HYPES_FILE} --phase train --log_to_file n --gpu 0 --cudnn n \
                       --data_dir ${DATA_DIR} --loss_type ${LOSS_TYPE} --model_name ${MODEL_NAME} \
                       --resume_continue y --resume ./checkpoints/cityscapes/${CHECKPOINTS_NAME}_latest.pth \
                       --checkpoints_name ${CHECKPOINTS_NAME} --pretrained ${PRETRAINED_MODEL}  2>&1 | tee -a ${LOG_FILE}

elif [[ "$1"x == "debug"x ]]; then
  ${PYTHON} -u main.py --hypes ${HYPES_FILE} --phase debug --gpu 0 --log_to_file n  2>&1 | tee ${LOG_FILE}

elif [[ "$1"x == "val"x ]]; then
  ${PYTHON} -u main.py --hypes ${HYPES_FILE} --phase test --log_to_file n --model_name ${MODEL_NAME} \
                       --phase test --gpu 0 --resume ./checkpoints/cityscapes/${CHECKPOINTS_NAME}_latest.pth \
                       --test_dir ${DATA_DIR}/val/image --out_dir val  2>&1 | tee -a ${LOG_FILE}
  cd metrics/det/
  ${PYTHON} -u voc_evaluator.py --hypes "../../../"${HYPES_FILE} \
                                --json_dir ../../../out/results/voc/test_dir/${CHECKPOINTS_NAME}/val/label \
                                --gt_dir ${DATA_DIR}/val/label  2>&1 | tee -a "../../"${LOG_FILE}

else
  echo "$1"x" is invalid..."
fi
