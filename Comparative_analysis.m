%% Add relevant paths
%% Add necessary folders and paths
addpath("E:\Neuroradiology\scripts\")
addpath("E:\Neuroradiology\conn20b\conn"); %CONN
addpath("E:\Neuroradiology\spm12\spm12"); % SPM
addpath('E:\Neuroradiology\externalfunctions') %external functions

BIDS_DIR = 'E:\Neuroradiology\data\BIDS\';
DATA_DIR = 'E:\Neuroradiology\data\';


%%
N_subjects = 10;

for ii = 1:N_subjects
sub_id = num2str(ii,'%02.f');
    
%% Defining the file paths.
%brain masks
mask_tb_language = niftiread(strcat('E:\Neuroradiology\data\BIDS\sub-',sub_id,'\func\art_mask_ausub-',sub_id,'_tfMRI_LANGUAGE_LR.nii'));
mask_tb_motor = niftiread(strcat('E:\Neuroradiology\data\BIDS\sub-',sub_id,'\func\art_mask_ausub-',sub_id,'_tfMRI_MOTOR_LR.nii'));
mask_rs = niftiread(strcat('E:\Neuroradiology\data\BIDS\sub-',sub_id,'\func\art_mask_ausub-',sub_id,'_rfMRI_REST1_LR.nii'));


%tb files
file_tb_language_t = strcat('E:\Neuroradiology\data\BIDS\sub-',sub_id,'\1stLevel\spmT_0001.nii');
file_tb_motor_t = strcat('E:\Neuroradiology\data\BIDS\sub-',sub_id,'\1stLevel_MOTOR\spmT_0001.nii');

%rs files - language
file_rs_ifg_l_p = strcat('E:\Neuroradiology\data\resting_state\results\firstlevel\SBC_01\pFDR_corr_Subject0',sub_id,'_Condition001_Source027.nii');
file_rs_ifg_r_p = strcat('E:\Neuroradiology\data\resting_state\results\firstlevel\SBC_01\pFDR_corr_Subject0',sub_id,'_Condition001_Source028.nii');
file_rs_pstg_l_p = strcat('E:\Neuroradiology\data\resting_state\results\firstlevel\SBC_01\pFDR_corr_Subject0',sub_id,'_Condition001_Source029.nii');
file_rs_pstg_r_p = strcat('E:\Neuroradiology\data\resting_state\results\firstlevel\SBC_01\pFDR_corr_Subject0',sub_id,'_Condition001_Source030.nii');

% rs files -  motor
file_rs_senslat_l_p = strcat('E:\Neuroradiology\data\resting_state\results\firstlevel\SBC_01\pFDR_corr_Subject0',sub_id,'_Condition001_Source005.nii');
file_rs_senslat_r_p = strcat('E:\Neuroradiology\data\resting_state\results\firstlevel\SBC_01\pFDR_corr_Subject0',sub_id,'_Condition001_Source006.nii');
file_rs_senssup_p = strcat('E:\Neuroradiology\data\resting_state\results\firstlevel\SBC_01\pFDR_corr_Subject0',sub_id,'_Condition001_Source007.nii');


%Loading all the volumes into matlab
V_tb_language_t = niftiread(file_tb_language_t); %tb files
nifti_info = niftiinfo(file_tb_language_t)
V_tb_motor_t = niftiread(file_tb_motor_t);

V_rs_ifg_l_p = niftiread(file_rs_ifg_l_p); %rs language files
V_rs_ifg_r_p = niftiread(file_rs_ifg_r_p);
V_rs_pstg_l_p =niftiread(file_rs_pstg_l_p);
V_rs_pstg_r_p =niftiread(file_rs_pstg_r_p);

V_rs_senslat_l_p =niftiread(file_rs_senslat_l_p); % rs motor files
V_rs_senslat_r_p =niftiread(file_rs_senslat_r_p);
V_rs_senssup_p = niftiread(file_rs_senssup_p);

%% Convert tb_t maps to FDR corrected P-maps
% At the first-level, the degrees of freedom is specified as the number of time points minus the number of regressors;
% http://andysbrainblog.blogspot.com/2013/07/a-reader-writes-basic-fmri-questions.html
% number of regressors come from the denoising step: 5 + 5 + 12 + 3 + 2 = 27
% Number of timepoints
%   Language = 316 timepoints
%   Motor = 284 timepoints
% DOF_Language = 316 - 27 = 289
% DOF_motor = 284 - 27 = 257
% t->z. subtracting the mean and dividing by std.
V_tb_language_z =  spm_t2z(V_tb_language_t,289);
V_tb_motor_z = spm_t2z(V_tb_motor_t,257);

% apply brain mask to the volumes before changing the values.
V_tb_language_z(~logical(mask_tb_language)) = nan;
V_tb_motor_z(~logical(mask_tb_motor)) = nan;

% convert z to p
V_tb_language_p_uncorrected = spm_z2p(V_tb_language_z);
V_tb_motor_p_uncorrected = spm_z2p(V_tb_motor_z);

% convert z score to fdr corrected p score
[h, crit_p, adj_ci_cvrg, adj_p] = fdr_bh(V_tb_language_p_uncorrected);
V_tb_language_p = adj_p;
[h, crit_p, adj_ci_cvrg, adj_p] = fdr_bh(V_tb_motor_p_uncorrected);
V_tb_motor_p = adj_p;
% 
% %plot to see what's going on
% figure; volshow(V_tb_motor_p <0.05,'Renderer','MaximumIntensityProjection')
% figure; volshow(V_tb_language_p <0.05','Renderer','MaximumIntensityProjection')
% % figure; volshow(V_rs_ifg_l_p <0.05,'Renderer','MaximumIntensityProjection')
% figure;histogram(V_tb_language_p);title('Language')
% figure;histogram(V_tb_motor_p);title('Language')
% figure;histogram(V_rs_ifg_l_p);title('resting state')


output_matrix_lang = single(V_tb_language_p < 0.05);
nifti_info.Filename = 'E:\Neuroradiology\scripts\tb_lang_p_test.nii'
niftiwrite(output_matrix_lang,'tb_lang_p_test.nii',nifti_info);

output_matrix_motor = single(V_tb_motor_p < 0.05);
nifti_info.Filename = 'E:\Neuroradiology\scripts\tb_motor_p_test.nii'
niftiwrite(output_matrix_motor,'tb_motor_p_test.nii',nifti_info);


%% thresholding the p-maps
p_threshold = 0.001; % this should be fine since the p value maps are already fdr corrected.


%% Make Hemispheres data
L_hemi_bounds_x = 1:45;
R_hemi_bounds_x = 46:91;% X Values higher than 45 are R hemisphere

R_V_tb = V_tb(R_hemi_bounds_x,:,:);
R_V_rs_ifg_r = V_rs_ifg_r(R_hemi_bounds_x,:,:);
R_V_rs_ifg_l = V_rs_ifg_l(R_hemi_bounds_x,:,:);
R_V_rs_pstg_r = V_rs_pstg_r(R_hemi_bounds_x,:,:);
R_V_rs_pstg_l = V_rs_pstg_l(R_hemi_bounds_x,:,:);

L_V_tb = V_tb(L_hemi_bounds_x,:,:);
L_V_rs_ifg_r = V_rs_ifg_r(L_hemi_bounds_x,:,:);
L_V_rs_ifg_l = V_rs_ifg_l(L_hemi_bounds_x,:,:);
L_V_rs_pstg_r = V_rs_pstg_r(L_hemi_bounds_x,:,:);
L_V_rs_pstg_l = V_rs_pstg_l(L_hemi_bounds_x,:,:);

%% Comparative Metrics
    % BILATERAL
data_bilateral.subject(ii) = ii;
data_bilateral.hemisphere(ii) = "Bilateral";
%IFG R
[data_bilateral.jac_ifgr(ii), data_bilateral.dice_ifgr(ii), data_bilateral.relvol_ifgr(ii) ] = metrics(V_tb,V_rs_ifg_r);
%IFG L
[data_bilateral.jac_ifgl(ii), data_bilateral.dice_ifgl(ii), data_bilateral.relvol_ifgl(ii) ] = metrics(V_tb,V_rs_ifg_l);
%pSTG R
[data_bilateral.jac_pstgr(ii), data_bilateral.dice_pstgr(ii), data_bilateral.relvol_pstgr(ii) ] = metrics(V_tb,V_rs_pstg_r);
%PSTG L
[data_bilateral.jac_pstgl(ii), data_bilateral.dice_pstgl(ii), data_bilateral.relvol_pstgl(ii) ] = metrics(V_tb,V_rs_pstg_l);




% RIGHT HEMI
data_righthemi.subject(ii) = ii;
data_righthemi.hemisphere(ii) = "Right";
%IFG R
[data_righthemi.jac_ifgr(ii), data_righthemi.dice_ifgr(ii), data_righthemi.relvol_ifgr(ii) ] = metrics(R_V_tb,R_V_rs_ifg_r);
%IFG L
[data_righthemi.jac_ifgl(ii), data_righthemi.dice_ifgl(ii), data_righthemi.relvol_ifgl(ii) ] = metrics(R_V_tb,R_V_rs_ifg_l);
%pSTG R
[data_righthemi.jac_pstgr(ii), data_righthemi.dice_pstgr(ii), data_righthemi.relvol_pstgr(ii) ] = metrics(R_V_tb,R_V_rs_pstg_r);
%PSTG L
[data_righthemi.jac_pstgl(ii), data_righthemi.dice_pstgl(ii), data_righthemi.relvol_pstgl(ii) ] = metrics(R_V_tb,R_V_rs_pstg_l);


data_lefthemi.subject(ii) = ii;
data_lefthemi.hemisphere(ii) = "Left";

% LEFT HEMI
%IFG R
[data_lefthemi.jac_ifgr(ii), data_lefthemi.dice_ifgr(ii), data_lefthemi.relvol_ifgr(ii) ] = metrics(L_V_tb,L_V_rs_ifg_r);
%IFG L
[data_lefthemi.jac_ifgl(ii), data_lefthemi.dice_ifgl(ii), data_lefthemi.relvol_ifgl(ii) ] = metrics(L_V_tb,L_V_rs_ifg_l);
%pSTG R
[data_lefthemi.jac_pstgr(ii), data_lefthemi.dice_pstgr(ii), data_lefthemi.relvol_pstgr(ii) ] = metrics(L_V_tb,L_V_rs_pstg_r);
%PSTG L
[data_lefthemi.jac_pstgl(ii), data_lefthemi.dice_pstgl(ii), data_lefthemi.relvol_pstgl(ii) ] = metrics(L_V_tb,L_V_rs_pstg_l);


end

masterdata = [data_lefthemi; data_bilateral; data_righthemi];

%% Trying to add violinplots based on github repo download
%literally just download the githun repo, and addpath to it. Boom done.
addpath('E:\Neuroradiology\externalfunctions\Violinplot-Matlab-master')
violinplot([masterdata.dice_ifgr,masterdata.dice_ifgl,masterdata.dice_pstgr,masterdata.dice_pstgl])

%% plot data
%think about how you want to visualize this first.

