%% Define directory structure
%Necessary addpaths
addpath("/home/robert/Documents/research/Neurorad/HCP-analysis")

%Necessary directories, make sure diractories have "/" at the end
DATA_DIR = "/mnt/storage/neuroradiology/data/";
BIDS_DIR = "/mnt/storage/neuroradiology/data/BIDS/";
HCP_DIR = "/mnt/storage/neuroradiology/data/HCP/";
ZIP_DIR = "/mnt/storage/neuroradiology/data/ZIP/";

%check if ZIP, HCP and BIDS dirs exist, if not, create them and prompt user
if ~exist(ZIP_DIR)
    disp("No original files are found, please copy the original HCP zip files to the zip dir that is now being created")
    mkdir(ZIP_DIR)
end

if ~exist(BIDS_DIR)
    disp("BIDS folder does not exist, creating now")
    mkdir(BIDS_DIR)
end

if ~exist(HCP_DIR)
    disp("HCP folder does not exist, creating now")
    mkdir(HCP_DIR)
end


%% Select which folders to convert
%Select ZIP files in ZIP dir that you want to unzip into the HCP dir
cd(ZIP_DIR)
[files,path] = uigetfile('.zip','MultiSelect','on');

tic
time_now = 0;
%Unzip file into HCP folder structure
for i = 1:size(files,2)

    disp("Unzipping: " + files{i} + " time: " + time_now)
    
    file = files{i};
    %unzips everything into one subject file, used to structure 'BIDS
    %like'structure for further analysis

    %try to unzip the file, if it doesn't work, go to next and document
    %file name in an unzip error log
    try
        unzip(file,HCP_DIR)

    catch  
        disp('Error unzipping file, writing filename to unzip_log')
        unzip_log_file = fopen(DATA_DIR+"unzip_error_log.txt",'a');
        fprintf(unzip_log_file,'Error unzipping: %s \n',files{i});
        fclose(unzip_log_file);
    
    end
    time_now = toc;
end

%% Select the Files to continue using for the analysis

cd(HCP_DIR)
subject_dirs = dir();
sub_dirs = subject_dirs(3:end);
sub_table = struct2table(sub_dirs);

%Generating bids_ids for each patient and creating lookuptable to use
for i = 1:(size(sub_table,1))
    %saving info into table
    patient_data.id = sub_table.name{i};
    sub_table.bids_id(i) = "sub-" + num2str(i,'%03.f'); %make bids subject identifier
    sub_table.hcp_id(i) = convertCharsToStrings(sub_table.name{i});
end

writetable(sub_table,DATA_DIR+"sub_table")


for i = 1:(size(sub_table,1))

    %Creating BIDS structure in BIDS_DIR
    cd(BIDS_DIR)
    
    patient_data.sub_id = sub_table.bids_id{i};
    % Check if HCP folder exists, if not, add to error log: 
    % if so, check if BIDS folder exists, if so skip, if not make folder
    % and continue
    if ~exist(HCP_DIR+sub_table.hcp_id(i))
      
        disp('error finding ' + HCP_DIR+sub_table.hcp_id(i) + ' logging and continuing with next file')
        unzip_log_file = fopen(DATA_DIR+"unzip_error_log.txt",'a');
        fprintf(unzip_log_file,'Error finding: %s \n',HCP_DIR+sub_table.hcp_id(i));
        fclose(unzip_log_file);
        continue %skip to next file in for loop
    end
    
    %make sub folder name for bids dir
    sub_foldername = sub_table.bids_id(i);

    if exist(BIDS_DIR+sub_foldername)
        disp(sub_foldername + " already exists, continuing")
        continue
    end 

    disp("Creating BIDS for: " + sub_foldername)
    
    %Create BIDS like folder structure
    mkdir(sub_foldername)
    cd(sub_foldername)
    mkdir("anat") %anatomical folder
    bids_anat_dir = BIDS_DIR + sub_foldername + "/" + "anat/";
    mkdir("func") %functional folder
    bids_func_dir = BIDS_DIR + sub_foldername + "/" + "func/";
    
    
    %% Selecting relevant files from HCP folders and copying it into BIDS format
    tic
    disp('extracting anatomical files for ' + sub_foldername)
    %anatomical
    anatomical_folder = HCP_DIR + sub_dirs(i).name +"/MNINonLinear/";
    anatomical_file = "T1w_restore_brain.nii.gz";
    file = anatomical_folder+anatomical_file;
    new_file = bids_anat_dir + sub_foldername + "_" + anatomical_file;
    copyfile(file, new_file)
    gunzip(new_file)
    delete(new_file) %deletes the zip file in the BIDS dir, doesn't touch HCP don't worry

    disp('extracting tb func files for ' + sub_foldername)

    %tb_motor
    tb_motor_folder = HCP_DIR + sub_dirs(i).name +"/MNINonLinear/Results/tfMRI_MOTOR_LR/";
    tb_motor_file = "tfMRI_MOTOR_LR.nii.gz";
    ev_folder_motor = HCP_DIR + sub_dirs(i).name +"/MNINonLinear/Results/tfMRI_MOTOR_LR/EVs/";
    file = tb_motor_folder+tb_motor_file;
    new_file = bids_func_dir + sub_foldername + "_" + tb_motor_file;
    copyfile(file, new_file)
    copyfile(ev_folder_motor, (bids_func_dir + sub_foldername + "_MOTOR_EVs/"))
    gunzip(new_file)
    delete(new_file)
    
    %tb_language
    tb_language_folder = HCP_DIR + sub_dirs(i).name +"/MNINonLinear/Results/tfMRI_LANGUAGE_LR/";
    tb_language_file = "tfMRI_LANGUAGE_LR.nii.gz";
    ev_folder_language = HCP_DIR + sub_dirs(i).name +"/MNINonLinear/Results/tfMRI_LANGUAGE_LR/EVs";
    file = tb_language_folder+tb_language_file;
    new_file = bids_func_dir + sub_foldername + "_" + tb_language_file;
    copyfile(file, new_file);
    copyfile(ev_folder_language, (bids_func_dir + sub_foldername + "_LANGUAGE_EVs/"));
    gunzip(new_file)
    delete(new_file)
    
    disp('extracting rs func files for ' + sub_foldername)

    %resting_state
    rest_folder = HCP_DIR + sub_dirs(i).name +"/MNINonLinear/Results/rfMRI_REST1_LR/";
    rest_file = "rfMRI_REST1_LR.nii.gz";
    file = rest_folder+rest_file;
    new_file = bids_func_dir + sub_foldername + "_" + rest_file;
    copyfile(file, new_file)
    gunzip(new_file)
    delete(new_file)
    
    disp("processing time: " + toc + " s")
    
end





