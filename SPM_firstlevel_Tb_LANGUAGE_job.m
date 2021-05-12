%% Add necessary folders and paths
addpath("E:\Neuroradiology\conn20b\conn"); %CONN
addpath("E:\Neuroradiology\spm12\spm12"); % SPM

BIDS_DIR = 'E:\Neuroradiology\data\BIDS\';
DATA_DIR = 'E:\Neuroradiology\data\';

%% Make the necessary folder structure
cd(BIDS_DIR)
subfolders = dir('sub*');
tic
for i = 1:size(subfolders,1)
        % Make first level analysis folder structure before continuing
        sub_name = subfolders(i).name;
        SUB_DIR = strcat(BIDS_DIR,sub_name,'\');
        firstlevel_DIR= strcat(SUB_DIR,'1stLevel');
        mkdir(firstlevel_DIR);

    %% SPM part, inital variables

    matlabbatch{1}.spm.stats.fmri_spec.dir = {firstlevel_DIR};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 0.72;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
    %% Defining the scans to process

    % Defining the cell string that has to be fed into the spm.stats.fmri_spec.sess.scans part of matlabbatch
    N_volumes = 316;
    cell_of_scans = {};

    for N = 1:N_volumes
        file_string = strcat(SUB_DIR, 'func\swau',sub_name,'_tfMRI_LANGUAGE_LR.nii,',num2str(N));
        scan = {file_string};
        cell_of_scans = [cell_of_scans;scan];
    end

    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cell_of_scans;

    %% Defining Conditions
    %Condition1- MATH
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'Math';
    %Onsets, extract from EV folder

    EV_folder = strcat(SUB_DIR,'func\', sub_name,'_LANGUAGE_EVs'); %navigate to folder that has EVs
    cd(EV_folder)

    math = readtable('math.txt');                               %LOAD MATH EV FILE

    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = math.Var1; %onsets
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = math.Var2; %durations

    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).orth = 1;
    %Condition2- Story
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = 'Story';

    story = readtable('story.txt');                           %LOAD STORY EV FILE
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = story.Var1; %onsets
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = story.Var2; %durations

    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).orth = 1;

    %% Define model and estimate model
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 1;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));

    %% Define Contrasts
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Math-Story-01'; % Contrast name
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [-1 1]; % Set contrast
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;

%     %% Show results
%     matlabbatch{4}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
%     matlabbatch{4}.spm.stats.results.conspec.titlestr = '';
%     matlabbatch{4}.spm.stats.results.conspec.contrasts = Inf;
%     matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'FDR';
%     matlabbatch{4}.spm.stats.results.conspec.thresh = 0.05;
%     matlabbatch{4}.spm.stats.results.conspec.extent = 10;
%     matlabbatch{4}.spm.stats.results.conspec.conjunction = 1;
%     matlabbatch{4}.spm.stats.results.conspec.mask.none = 1;
%     matlabbatch{4}.spm.stats.results.units = 1;
%     matlabbatch{4}.spm.stats.results.export{1}.ps = true;
%% Run job

    spm_jobman('run',matlabbatch)
    clear matlabbatch
end


toc