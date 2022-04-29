import os
import subprocess
from tqdm import tqdm
import time

def run_linux(input_command,verbose=False):
    """Runs string in bash and prints out the result. Returns output and error."""
    bashCommand = input_command # take the input command
    
    #core linux translation part here
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()
    
    #print and return the output
    if verbose:
        print(output.decode())
    return output, error


def cluster_resting_state(subject_number,source_number_rs):
    #set your subject and source numbers
    
    filename_rs = f"BETA_Subject{subject_number:03d}_Condition001_Source{source_number_rs:03d}.nii"
    
    #remove nans and threshold above zero
    nan_thr_output_file = filename_rs[:-4] + "_nan_thr.nii.gz"
    command_string_nan_thr = "fslmaths ./" + filename_rs + " -nan -thr 0 ./" + nan_thr_output_file 
    
    run_linux(command_string_nan_thr)
    
    #remove nans and threshold above zero
    kmeans_output_file = filename_rs[:-4] + "_kmeans.nii.gz"
    
    command_string_kmeans = "ThresholdImage 3 ./" + nan_thr_output_file + " ./" + kmeans_output_file +" Kmeans 10" 
    
    run_linux(command_string_kmeans)

def cluster_task_based(subject_number, tb_index):

    if tb_index not in [0, 1, 2, 3]:
        print("tb_index not valid, may only be 0,1,2,3")
        return
    
    filename_tb_language = f'/mnt/storage/neuroradiology/data/BIDS/sub-{subject_number:03d}/1stLevel_LANGUAGE_01/spmT_0001.nii'
    filename_tb_motor_foot = f'/mnt/storage/neuroradiology/data/BIDS/sub-{subject_number:03d}/1stLevel_MOTOR_foot/spmT_0001.nii'
    filename_tb_motor_hand = f'/mnt/storage/neuroradiology/data/BIDS/sub-{subject_number:03d}/1stLevel_MOTOR_hand/spmT_0001.nii'
    filename_tb_motor_tongue = f'/mnt/storage/neuroradiology/data/BIDS/sub-{subject_number:03d}/1stLevel_MOTOR_tongue/spmT_0001.nii'
    
    tb_templates = [filename_tb_language,
                    filename_tb_motor_foot,
                    filename_tb_motor_hand,
                    filename_tb_motor_tongue]
    
    filename_tb = tb_templates[tb_index]
    
    nan_thr_output_file = filename_tb[:-4] + "_nan_thr.nii.gz"
    command_string_nan_thr = "fslmaths " + filename_tb + " -nan -thr 0 " + nan_thr_output_file 
    
    run_linux(command_string_nan_thr)
    
    #remove nans and threshold above zero
    kmeans_output_file = filename_tb[:-4] + "_kmeans.nii.gz"
    
    command_string_kmeans = "ThresholdImage 3 " + nan_thr_output_file + " " + kmeans_output_file +" Kmeans 10" 
    
    run_linux(command_string_kmeans)
    return


tb_index_list = [0, 1, 2, 3]
rs_source_list = [159,160,161,162,137,138,17,18,19,20,9,10,11,12,33,34,13,14]

for subject_number in tqdm(range(1,101)):
    #run task based for all indices
    for tb_index in tb_index_list:
        cluster_task_based(subject_number,tb_index)
    
    #run rs for all the areas
    for rs_source in rs_source_list:
        cluster_resting_state(subject_number,rs_source)


