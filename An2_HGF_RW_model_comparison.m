%%% Model Comparision %%%
%Fri 17th January 2020 Megan Campbell

%%% use after running HGF1_seup_modelfit.m & RW1_setup_modelfit.m

% requires the hgf_fit & rw_fit structures for each subject -> grouped into the
% structure
%   Group{ss}.hgf_fit{mm}.y
%                        .u
%                        .ign
%                        .irr
%                        .c_prc
%                        .c_obs
%                        .c_opt
%                        .optim.AIC
%                              .BIC
%                              .LME <--- use 'log model evidence' for model comparison
%                        .p_prc
%                        .p_obs
%                        .traj


% % load('Group_n28_RW_logRT_2.mat')
% % Group2 = Group;
% % load('Group_3levelHGF_SRC_LogRT.mat') %< var called Group with HGF in; 
% % % now add rw details
% % for ii = 1:length(Group)
% %     Group{ii}.RWfit{1} = Group2{ii}.RWfit{1}
% % end
% % save('Group_n28_HGFvsRW_logRT.mat', 'Group')


%% load things and preallocate structures
clear 
%load('Group_n_28_HGF_vsRW.mat')
load ('Group_n28_HGFvsRW_logRT.mat')


fname_lme ='groupLME_n28_HGFs_vs_RW_logRT.mat';
%fname_lme ='groupLME_n28_HGFs_vs_RW.mat';
%fname_bms = 'BMS_HGFvRW_n28.mat';
fname_bms = 'BMS_HGFvRW_logRT_n28.mat';

fname_base ={ '_3levelHGF_SRC_LogRT', '_RW_SRC_LogRT'};  %_DeltaLogRT'   %_gausRM'
dir_data = ['/Users/mejc110/Documents/MATLAB/SRCpredict_HGFmodelling/extractAll' filesep 'rerun_HGFv5-3_n28_logRT']; %_gaussianRM


m = 2; % models within hgf_fit structure or hard code number of models being compared
s = 28; % 

% preallocate:
groupLME = nan(s,m); %col per model

for ss = 1:s
    groupLME(ss,1) = Group{ss}.hgf_fit{1}.optim.LME; % HGF with SRC binary inputs, and delta-logRT responses 
    groupLME(ss,2) = Group{ss}.RWfit{1}.optim.LME; % Rescorla-Wagner with SRC binary inputs, and delta-logRT responses 
end
groupLME(:,3) = groupLME(:,1)-groupLME(:,2);
save(fname_lme, 'groupLME')
figure
bar(groupLME(:,1)-groupLME(:,2))
title('LME difference + = select HGF')% plot LME difference -> hgf minus rw
figure
bar(groupLME)
% sum LME for all subjects by model -> fixed effects comparison
sumLME = sum(groupLME);
 
% convert LME to bayes factor: exp(LMEm1-LMEm2) 
% random fx comparison use spm_BMS.m (spm toolbox function)
% Bayesian model selection for group studiese
% FORMAT [alpha,exp_r,xp,pxp,bor] = spm_BMS (lme, Nsamp, do_plot, sampling, ecp, alpha0)

% pspm_init %scr_init % spm_BMS.m need PsPM toolbox for some stats functions 'src_inti' turns on PSPM settings
% % lme12 = groupLME(:,1:2); %array of LME models x subjects; rows: subjects columns: models (1..Nk)
% % lme23 = groupLME(:,2:3);
% % lme13(:,1) = groupLME(:,1);
% % lme13(:,2) = groupLME(:,3);

%%% For example, an exceedance probability of 95% for a particular model means that one has 
%%% 95% confidence that this model has a greater posterior probability than any other model tested (Stephan et al., 2009b).

% all inputs after lme are optional - defaults will be set
Nsamp = 1e6; %number of samples used to compute exceedance probabilities (default: 1e6)
do_plot = 1; %plot things yes/no
sampling = 1; % use sampling to compute exact alpha
ecp = 1; % calculated protected exceedence prob
alpha0 = ones(1,2);

lme = groupLME(:,1:2); % hgf1 (src) vs RW (src)
[alpha,exp_r,xp,pxp,bor] = spm_BMS (lme, Nsamp, do_plot, sampling, ecp, alpha0);

bms2.alpha = alpha;
bms2.exp_r = exp_r;
bms2.xp = xp;
bms2.pxp = pxp;
bms2.bor = bor;

save(fname_bms,'bms2')

% lme = lme23; % hgf2 (stim) vs RW(src)
% [alpha,exp_r,xp,pxp,bor] = spm_BMS (lme, Nsamp, do_plot, sampling, ecp, alpha0);
% 
% hgf2v3.alpha = alpha;
% hgf2v3.exp_r = exp_r;
% hgf2v3.xp = xp;
% hgf2v3.pxp = pxp;
% hgf2v3.bor = bor;
% save(fname2v3,'hgf2v3')


% try bms for 3 models in one go
% % % % alpha = [1 1 1]; % set alpha to 1's 
% % % % [alpha,exp_r,xp,pxp,bor] = spm_BMS (groupLME, Nsamp, do_plot, 0, ecp, alpha); % set sampleing to 0 = can't use that for more than 2 models
% % % % hgf1_2_rw1.alpha = alpha;
% % % % hgf1_2_rw1.exp_r = exp_r;
% % % % hgf1_2_rw1.xp = xp;
% % % % hgf1_2_rw1.pxp = pxp;
% % % % hgf1_2_rw1.bor = bor;
% % % % save(fnamehgf1_2_rw1,'hgf1_2_rw1')


%%%%%%%%% NOTES %%%%%%%
% NOTES ON BMS for HGF: spm_BMS used in my ?HGF2_model_comparison.m?
% % % Two figures output from VBA BMS process of HGF model comparison: 
% % % 1st is Dirichlet plot??Probability Density Function (PDF) of Dirichlet distribution? output form spm_Dpdf.m
%  See http://en.wikipedia.org/wiki/Dirichlet_distribution
% 
% % % Second is F over alpha-1 output from spm_BMS_F.m:
% Compute two lower bounds on model evidence p(y|r) for group BMS
% 
% FORMAT [F_samp,F_bound] = spm_BMS_smpl_me (alpha,lme,alpha0)
% 
% INPUT:
% alpha     parameters of p(r|y)
% lme       array of log model evidences 
%              rows:    subjects
%              columns: models (1..Nk)
% alpha0    priors of p(r)
% 
% OUTPUT:
% F_samp  -  sampling estimate of <ln p(y_n|r>
% F_bound -  lower bound on lower bound of <ln p(y_n|r>
% 
% REFERENCE: See appendix in
% Stephan KE, Penny WD, Daunizeau J, Moran RJ, Friston KJ
% Bayesian Model Selection for Group Studies. NeuroImage (under review)

%


% Model quality:
%     LME (more is better)
%     AIC (less is better)
%     BIC (less is better)
