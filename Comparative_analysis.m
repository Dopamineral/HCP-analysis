N_subjects = 5
data_bilateral = table();
data_righthemi = table();
data_lefthemi = table();

for i = 1:N_subjects
sub_id = num2str(i,'%02.f');
    
%% Loading all the files needed
file_tb = strcat('E:\Neuroradiology\data\BIDS\sub-',sub_id,'\1stLevel\p_output.nii');
file_rs_ifg_l_p = strcat('E:\Neuroradiology\data\resting_state\results\firstlevel\SBC_03\pFDR_corr_Subject0',sub_id,'_Condition001_Source027.nii');
file_rs_ifg_l_corr = strcat('E:\Neuroradiology\data\resting_state\results\firstlevel\SBC_03\corr_Subject0',sub_id,'_Condition001_Source027.nii');
file_rs_ifg_r_p = strcat('E:\Neuroradiology\data\resting_state\results\firstlevel\SBC_03\pFDR_corr_Subject0',sub_id,'_Condition001_Source028.nii');
file_rs_ifg_r_corr = strcat('E:\Neuroradiology\data\resting_state\results\firstlevel\SBC_03\corr_Subject0',sub_id,'_Condition001_Source028.nii');
file_rs_pstg_l_p = strcat('E:\Neuroradiology\data\resting_state\results\firstlevel\SBC_03\pFDR_corr_Subject0',sub_id,'_Condition001_Source029.nii');
file_rs_pstg_l_corr = strcat('E:\Neuroradiology\data\resting_state\results\firstlevel\SBC_03\corr_Subject0',sub_id,'_Condition001_Source029.nii');
file_rs_pstg_r_p = strcat('E:\Neuroradiology\data\resting_state\results\firstlevel\SBC_03\pFDR_corr_Subject0',sub_id,'_Condition001_Source030.nii');
file_rs_pstg_r_corr = strcat('E:\Neuroradiology\data\resting_state\results\firstlevel\SBC_03\corr_Subject0',sub_id,'_Condition001_Source030.nii');

%Loading all the volumes
V_tb = niftiread(file_tb);
V_rs_ifg_r_p = niftiread(file_rs_ifg_r_p);
V_rs_ifg_r_corr = niftiread(file_rs_ifg_r_corr);
V_rs_ifg_l_p = niftiread(file_rs_ifg_l_p);
V_rs_ifg_l_corr = niftiread(file_rs_ifg_l_corr);
V_rs_pstg_r_p = niftiread(file_rs_pstg_r_p);
V_rs_pstg_r_corr = niftiread(file_rs_pstg_r_corr);
V_rs_pstg_l_p = niftiread(file_rs_pstg_l_p);
V_rs_pstg_l_corr = niftiread(file_rs_pstg_l_corr);

%% thresholding the rs corr volume based on fdr p-map
p_threshold = 0.001;

%IFG R
idx = V_rs_ifg_r_p < p_threshold;
V_rs_ifg_r = idx.*V_rs_ifg_r_corr;
V_rs_ifg_r(V_rs_ifg_r == 0) = NaN;

% IFG L
idx = V_rs_ifg_l_p < p_threshold;
V_rs_ifg_l = idx.*V_rs_ifg_l_corr;
V_rs_ifg_l(V_rs_ifg_l == 0) = NaN;

%pSTG R
idx = V_rs_pstg_r_p < p_threshold;
V_rs_pstg_r = idx.*V_rs_pstg_r_corr;
V_rs_pstg_r(V_rs_pstg_r == 0) = NaN;

%pSTG L
idx = V_rs_pstg_l_p < p_threshold;
V_rs_pstg_l = idx.*V_rs_pstg_l_corr;
V_rs_pstg_l(V_rs_pstg_l == 0) = NaN;

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

%IFG R
[data_bilateral.jac_ifgr(i), data_bilateral.dice_ifgr(i), data_bilateral.relvol_ifgr(i) ] = metrics(V_tb,V_rs_ifg_r);
%IFG L
[data_bilateral.jac_ifgl(i), data_bilateral.dice_ifgl(i), data_bilateral.relvol_ifgl(i) ] = metrics(V_tb,V_rs_ifg_l);
%pSTG R
[data_bilateral.jac_pstgr(i), data_bilateral.dice_pstgr(i), data_bilateral.relvol_pstgr(i) ] = metrics(V_tb,V_rs_pstg_r);
%PSTG L
[data_bilateral.jac_pstgl(i), data_bilateral.dice_pstgl(i), data_bilateral.relvol_pstgl(i) ] = metrics(V_tb,V_rs_pstg_l);
    

% RIGHT HEMI

%IFG R
[data_righthemi.jac_ifgr(i), data_righthemi.dice_ifgr(i), data_righthemi.relvol_ifgr(i) ] = metrics(R_V_tb,R_V_rs_ifg_r);
%IFG L
[data_righthemi.jac_ifgl(i), data_righthemi.dice_ifgl(i), data_righthemi.relvol_ifgl(i) ] = metrics(R_V_tb,R_V_rs_ifg_l);
%pSTG R
[data_righthemi.jac_pstgr(i), data_righthemi.dice_pstgr(i), data_righthemi.relvol_pstgr(i) ] = metrics(R_V_tb,R_V_rs_pstg_r);
%PSTG L
[data_righthemi.jac_pstgl(i), data_righthemi.dice_pstgl(i), data_righthemi.relvol_pstgl(i) ] = metrics(R_V_tb,R_V_rs_pstg_l);
    

% LEFT HEMI
%IFG R
[data_lefthemi.jac_ifgr(i), data_lefthemi.dice_ifgr(i), data_lefthemi.relvol_ifgr(i) ] = metrics(L_V_tb,L_V_rs_ifg_r);
%IFG L
[data_lefthemi.jac_ifgl(i), data_lefthemi.dice_ifgl(i), data_lefthemi.relvol_ifgl(i) ] = metrics(L_V_tb,L_V_rs_ifg_l);
%pSTG R
[data_lefthemi.jac_pstgr(i), data_lefthemi.dice_pstgr(i), data_lefthemi.relvol_pstgr(i) ] = metrics(L_V_tb,L_V_rs_pstg_r);
%PSTG L
[data_lefthemi.jac_pstgl(i), data_lefthemi.dice_pstgl(i), data_lefthemi.relvol_pstgl(i) ] = metrics(L_V_tb,L_V_rs_pstg_l);

end

writetable(data_bilateral,'data_bilateral.csv')
writetable(data_lefthemi,'data_lefthemi.csv')
writetable(data_righthemi,'data_righthemi.csv')
