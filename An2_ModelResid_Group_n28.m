% step 3.... residuals (unexplained variance)
% the smaller the RMSE, the better,

%dir_data = ['/Users/mejc110/Documents/MATLAB/SRCpredict_HGFmodelling/extractAll' filesep 'rerun_HGFv5-3_n28'];
dir_data = ['/Users/mejc110/Documents/MATLAB/SRCpredict_HGFmodelling/extractAll' filesep 'rerun_HGFv5-3_n28_logRT']; %_gaussianRM

cd(dir_data)
load('data_n28.mat')

% load('Group_n28_RW_DELTA_logRT_2.mat')
 % load('Group_n28__3levelHGF_SRC_DeltaLogRT.mat')
%load('Group_n_28_HGF_vsRW.mat')
load ('Group_n28_HGFvsRW_logRT.mat')
fname_out = 'Group_LME_RMSE_hgfVrw_n28_logRT.mat';
for ss = 1:length(data.ID)
      
     all_LME(ss,1) =  Group{ss}.hgf_fit{1}.optim.LME;
     
     all_LME(ss,2) =  Group{ss}.RWfit{1}.optim.LME;
     
     % Root Mean Squared Error
    residuals = Group{ss}.hgf_fit{1}.optim.res; % = actual - predicted ; actual = hgf_fit.
    all_RMSE(ss,1) = sqrt(nanmean((residuals.^2))); % square-root of (mean of squared-error)
    residuals = Group{ss}.RWfit{1}.optim.res; % = actual - predicted ; actual = hgf_fit.
    all_RMSE(ss,2) = sqrt(nanmean((residuals.^2))); % square-root of (mean of squared-error)
       
     
end
save(fname_out, 'all_RMSE', 'all_LME')

% So, lower is better for BIC

load('Group_n28_HGFvsRW_logRT.mat')
for ss = 1:28  %length(data.ID)

all_BIC(ss,1) =  Group{1}.hgf_fit{1}.optim.BIC;
all_BIC(ss,2) =  Group{1}.RWfit{1}.optim.BIC;


end
fname_out2 = 'Group_BIC_hgfVrw_n28_logRT.mat';
save(fname_out2, 'all_BIC')