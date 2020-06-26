%%%%% ~~~~ 1. setupHGF_2ndGo ~~~
% Fit model for different 'u'
% Simulate models given these optimal priors, with diff obos/perc models :
% hgf ? rw ?
% % originally run with HGF v4.10
% % update to V5.3 to have residuals diagnostic of model fit. 
%%% in newer version can assess residuals after model fit
% use 'tapas_fit_plotResidualDiagnostics' to plot things
% calculate an overall estimate of residuals per subject with Root Mean-Square Error (RMSE)
% sqrt(immse(values))


% 
clear
%% set variables and directories

%path_functions = ('/Users/mejc110/Documents/MATLAB/SRCpredict_HGFmodelling/HGF_mejcEdited');
path_functions = ('/Users/mejc110/Documents/MATLAB/SRCpredict_HGFmodelling/HGF_v5-3');
addpath(genpath(path_functions))

fname_in = 'data_n28.mat';
%fname_base = {'_3levelHGF_SRC_DeltaLogRT', '_2_RWfit_DELTA_logRT'};
%%% running on logRT instead of delta 
fname_base ={ '_3levelHGF_SRC_LogRT', '_RW_SRC_LogRT'};  %_DeltaLogRT'   %_gausRM'

%fname_group = ['Group_n30_' ,fname_base '.mat']; % the hgf_fit structure for all subjects and all models 
load(fname_in)
fname_out = 'Residuals_RMSE_n28.mat';
dir_data = '/Users/mejc110/Documents/MATLAB/SRCpredict_HGFmodelling/extractAll/rerun_HGFv5-3_n28_logRT/';
dir_figsout = 'Residuals_Plots';

n_Pp = 30; % no.participants

%% preallocate things

RMSE = nan(n_Pp,1);

for ss=1:length(data.ID)
    %for mm = 1:3
    for mm = 1:2 %:
    cd(dir_data)
    
    fname_hgf1 = strcat(data.ID(ss), fname_base{mm}, '_m1' ,  '.mat');
    load(fname_hgf1{1}); 
    
    fname_fig1 = strcat(data.ID(ss), fname_base{mm}, '_ResDiagPlot' ,  '.fig');
    
    if mm == 1
        tapas_fit_plotResidualDiagnostics(hgf_fit)
    elseif mm==2
        tapas_fit_plotResidualDiagnostics(RWfit)
    end
    cd(dir_figsout);
    savefig(fname_fig1{1})
    %close figure
    close(gcf)
 
    
    predicted = hgf_fit.optim.yhat;
    residuals = hgf_fit.optim.res; % = actual - predicted ; actual = hgf_fit.y
    
    % Root Mean Squared Error
    RMSE(ss) = sqrt(nanmean((residuals.^2))); % square-root of (mean of squared-error)
    % As the square root of a variance, RMSE can be interpreted as the standard deviation of the unexplained variance, 
    % and has the useful property of being in the same units as the response variable. 
    %>>>>>> Lower values of RMSE indicate better fit. <<<<< 
    % RMSE is a good measure of how accurately the model predicts the response, and it is the most important criterion for fit if the main purpose of the model is prediction.
   
    
    
    end % if looping through multiple models
    disp(['... residuals diagnostic plot saved for ss ' num2str(ss), ' saved'])
end % end subj loop



save(fname_out,'RMSE');