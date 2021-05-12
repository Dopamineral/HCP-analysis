%% Define directory structure
%Necessary addpaths
addpath("E:\Neuroradiology\scripts")

%Necessary directories
DATA_DIR = "E:\Neuroradiology\data\";
BIDS_DIR = "E:\Neuroradiology\data\BIDS\";
HCP_DIR = "E:\Neuroradiology\data\HCP\";

%% Select which folders to convert
%Select ZIP files in datafolder that you want to unzip into the HCP folder
cd(DATA_DIR)
[files,path] = uigetfile('.zip','MultiSelect','on');

tic
%Unzip file into HCP folder structure (and delete the original zip file.)
for i = 1:size(files,2)
    
    disp("Unzipping: " + files{i})
    
    file = files{i};
    %unzips everything into one subject file, easy to extract later on.
    unzip(file,HCP_DIR) 
    %delete(file)
    toc
end

%% Select the Files to continue using for the analysis

cd(HCP_DIR)
subject_dirs = dir();
sub_dirs = subject_dirs(3:end);


tic
patient_data = table();

% %Check which sub folders already exist in BIDS DIR so new files get added instead of
% %overwritten. Commented out for now because below loop just creates sub
% folders out of the HCP folder structure.

cd(BIDS_DIR)
% bids_sub_dirs = dir('sub-*');
% N_present = size(bids_sub_dirs,1);

for i = 1:(length(sub_dirs))
    %saving info into table
    patient_data.id = sub_dirs(i).name;
    %Creating BIDS structure in BIDS_DIR
    cd(BIDS_DIR)
    
    sub_foldername = "sub-" + num2str(i,'%02.f'); %make bids subject identifier
    patient_data.sub_id = sub_foldername;
    
    disp("Creating BIDS for: " + sub_foldername)
    
    mkdir(sub_foldername)
    cd(sub_foldername)
    mkdir("anat") %anatomical folder
    bids_anat_dir = BIDS_DIR + sub_foldername + "\" + "anat\";
    mkdir("func") %functional folder
    bids_func_dir = BIDS_DIR + sub_foldername + "\" + "func\";
    
    
    %% Selecting relevant files from MNI folders and copying it into BIDS format
    %anatomical
    anatomical_folder = HCP_DIR + sub_dirs(i).name +"\MNINonLinear\";
    anatomical_file = "T1w_restore_brain.nii.gz";
    file = anatomical_folder+anatomical_file;
    new_file = bids_anat_dir + sub_foldername + "_" + anatomical_file;
    copyfile(file, new_file)
    gunzip(new_file)
    delete(new_file)

    %tb_motor
    tb_motor_folder = HCP_DIR + sub_dirs(i).name +"\MNINonLinear\Results\tfMRI_MOTOR_LR\";
    tb_motor_file = "tfMRI_MOTOR_LR.nii.gz";
    ev_folder_motor = HCP_DIR + sub_dirs(i).name +"\MNINonLinear\Results\tfMRI_MOTOR_LR\EVs\";
    file = tb_motor_folder+tb_motor_file;
    new_file = bids_func_dir + sub_foldername + "_" + tb_motor_file;
    copyfile(file, new_file)
    copyfile(ev_folder_motor, (bids_func_dir + sub_foldername + "_MOTOR_EVs\"))
    gunzip(new_file)
    delete(new_file)
    
    %tb_language
    tb_language_folder = HCP_DIR + sub_dirs(i).name +"\MNINonLinear\Results\tfMRI_LANGUAGE_LR\";
    tb_language_file = "tfMRI_LANGUAGE_LR.nii.gz";
    ev_folder_language = HCP_DIR + sub_dirs(i).name +"\MNINonLinear\Results\tfMRI_LANGUAGE_LR\EVs";
    file = tb_language_folder+tb_language_file;
    new_file = bids_func_dir + sub_foldername + "_" + tb_language_file;
    copyfile(file, new_file);
    copyfile(ev_folder_language, (bids_func_dir + sub_foldername + "_LANGUAGE_EVs\"));
    gunzip(new_file)
    delete(new_file)
    
    %resting_state
    rest_folder = HCP_DIR + sub_dirs(i).name +"\MNINonLinear\Results\rfMRI_REST1_LR\";
    rest_file = "rfMRI_REST1_LR.nii.gz";
    file = rest_folder+rest_file;
    new_file = bids_func_dir + sub_foldername + "_" + rest_file;
    copyfile(file, new_file)
    gunzip(new_file)
    delete(new_file)
    
end
cd(BIDS_DIR)
writetable(patient_data,"patient_data.csv")
toc



