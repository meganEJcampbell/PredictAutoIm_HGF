%%%%% ~~~~ 1. setupHGF_2ndGo ~~~
% Fit model for different 'u'
% Simulate models given these optimal priors, with diff obos/perc models :
% hgf ? rw ?
% % originally run with HGF v4.10
% % update to V5.3 to have residuals diagnostic of model fit. 
% %% rerunning with log RT instead of delta logRT
clear all


path_data = '/Users/mejc110/Documents/MATLAB/SRCpredict_HGFmodelling/extractAll';
cd(path_data)
fname_in = 'data_n28.mat';
load(fname_in)

%path_functions = ('/Users/mejc110/Documents/MATLAB/SRCpredict_HGFmodelling/HGF_mejcEdited');
path_functions = ('/Users/mejc110/Documents/MATLAB/SRCpredict_HGFmodelling/HGF_v5-3');


addpath(genpath(path_functions))

% % in /HGF_mejcEdited' 'tapas_hgf_binary_config' >>>>> adjusted as per advice from Mathys,
% % c.ommu = [NaN, -4, -2]; c.omsa = [NaN, 1, 1];
% % in 


%fname_base = '_3levelHGF_SRC_DeltaLogRT';

%%% updated filename and dir name
fname_base = '_3levelHGF_SRC_LogRT';  %_DeltaLogRT'   %_gausRM'
fname_out = ['Group' fname_base '.mat'];
dir_data = ['/Users/mejc110/Documents/MATLAB/SRCpredict_HGFmodelling/extractAll' filesep 'rerun_HGFv5-3_n28_logRT']; %_gaussianRM

if ~isdir(dir_data) 
    mkdir(dir_data)
    
else
    disp([dir_data ' exists!'])
    flag = input('select option: 1:continue and overwrite OR 2:stop');
    if flag ==1
        disp('carrying on... ')
    elseif flag ==2
    return
    end
end

cd(dir_data)
for ss=1:length(data.ID)
   % for mm = 1:3
   mm=1;
     fname_hgf1 = strcat(data.ID(ss), fname_base, '_m', num2str(mm) ,  '.mat');
     fname_fig1 = strcat(data.ID(ss), fname_base, '_m', num2str(mm) , '.fig');
     
%      fname_hgf2 = strcat(data.ID(ss), fname_base, '_m', num2str(mm) ,  '.mat');
%      fname_fig2 = strcat(data.ID(ss), fname_base, '_m', num2str(mm) , '.fig');
%      
%      fname_hgf3 = strcat(data.ID(ss), fname_base, '_m', num2str(mm) ,  '.mat');
%      fname_fig3 = strcat(data.ID(ss), fname_base, '_m', num2str(mm) , '.fig');
%     
    % data structure matrixes with (trials x values x subjects)
    u = data.inputs(:,mm,ss) ; % if mm=1 binary vector for SRC 1 = match 0 =mismatch; if mm= 2, binary for open/close stimtypes; 
    r = data.responses(:,2,ss) ; % second col = log RT.
    %this third column = trials.delta_logRTs(:,ss); 
    %data.responses(:,3,ss); % col3 = delta logRT, col1 = RT (these RT's haven't
    %been cleaned of low outliers below 100ms)
    
    
    disp(strcat('%%%%  Fitting hgf for ss ', num2str(ss), ' ID', data.ID(ss), '%%%%'))
    
    hgf_fit = tapas_fitModel(r, u, 'tapas_hgf_binary_config_MC_SRCstudy', 'tapas_logrt_linear_binary_config', 'tapas_quasinewton_optim_config');
  %  hgf_fit = tapas_fitModel(r, u, 'tapas_hgf_binary_config_MC_SRCstudy', 'tapas_gaussian_obs_config' , 'tapas_quasinewton_optim_config');
   
    
    % % Note: tapas_hgf_binary_config_MC_SRCstudy.m = adjusted version, 
    % c.ommu = [NaN, -4, -2]; c.omsa = [NaN, 1, 1]  original is still in dir as tapas_hgf_binary_config.m
    % estimate model est = tapas_fitModel ([], u, 'tapas_hgf_binary_config?, 'tapas_bayes_optimal_binary_config');
    % responses, inputs, perceptual model response model, optimisation alogrithm
    
    %% plot things
    %plot of inputs only
%     scrsz = get(0,'ScreenSize');
%     outerpos = [0.2*scrsz(3),0.7*scrsz(4),0.8*scrsz(3),0.3*scrsz(4)];
%     figure('OuterPosition', outerpos)
%     plot(u, '.', 'Color', [0 0.8 1], 'MarkerSize', 11) %%% MEJC:  blue [0 0 1]; magenta [1 0 1] ; cyan [0 1 1]; purple[0.8 0 0.5]
%     xlabel('Trial number')
%     ylabel('Inputs "u" ') %%%
%     axis([1, 400, -0.1, 1.1])
%     set(gca,'Xtick',0:40:400) %%% MEJC: changed tick-marks from 50's to 40's = blocks (note 'gca' = get current axis handle)
%     set(gca,'XtickLabel',0:40:400)
%     title([char(data.ID(ss)),  ' match 1 vs mismatch 0'])


% plot trajectories as per demo/built in function
    tapas_hgf_binary_plotTraj(hgf_fit) % has been modified to have tickmarks at 40trials
    set(gca,'Xtick',0:40:400) %%% MEJC: changed tick-marks from 50's to 40's = blocks (note 'gca' = get current axis handle)
    set(gca,'XtickLabel',0:40:400)
     
    
    %% save things
    save(fname_hgf1{1}, 'hgf_fit')
    savefig(fname_fig1{1})
    %close figure
    close(gcf)
    
    Group{ss}.hgf_fit{mm} = hgf_fit;
   
   % end % if looping through multiple models
    disp(['... hgf for ss ' num2str(ss), ' saved'])
    disp('%%%%%%%%%%%%%%%%%%%~~~~~~~~~~%%%%%%%%%%%%%%%%%%%')
end % end subj loop
save(fname_out,'Group');

% collate model fit infor for whole group and get sumLME
% % 
% % load('Group_n28_RW_DELTA_logRT_2.mat')
% % for ss = 1:length(data.ID)
% %      fname_hgf1 = strcat(data.ID(ss), fname_base, '_m', num2str(mm) ,  '.mat');
% %      load(fname_hgf1{1})
% %      Group{ss}.hgf_fit{mm} = hgf_fit;
% %      all_LME(ss,1) =  hgf_fit.optim.LME;
% % end
% % 
% % 