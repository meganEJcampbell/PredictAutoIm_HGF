%% bayes optimal priors
clear all
fname_in = 'data_n30.mat';
load(fname_in)

path_functions = ('/Users/mejc110/Documents/MATLAB/SRCpredict_HGFmodelling/HGF_v5-3');
addpath(genpath(path_functions))


for ss=1%:length(data.ID)
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    disp(['Pp ' num2str(ss) ' ID ' data.ID{ss}])
    disp('_________________')
     u = data.inputs(:,1,ss) ; % clc binary vector for SRC 1 = match 0 =mismatch
  
     bopars = tapas_fitModel([],... % empty no responses here just inputs
                             u,... % binary inputs from task 
                             'tapas_hgf_binary_config_MC_SRCstudy', ... % 'tapas_hgf_binary_config',...  %Perceptual Model     % where you can muck about with the values...
                             'tapas_bayes_optimal_binary_config',...  % Response Model % 'tapas_bayes_optimal_binary_config' for binary inputs = your observation model. This determines the Bayes optimal perceptual parameters (given your current priors, so choose them wide and loose to let the inputs influence the result). You can then use the optimal parameters as your new prior means for the perceptual parameters.
                             'tapas_quasinewton_optim_config');  %optimisation algorithm%
%    
    
    all(ss).bopars = bopars;
    
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
end

%save(['bayesopt_params_n30_' date '.mat'], 'all')