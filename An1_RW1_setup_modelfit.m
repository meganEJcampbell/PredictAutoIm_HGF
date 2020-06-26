%%%%% ~~~~ 1. setup_RW ~~~
% Fit model for different 'u'

% SET UP A RESCORLA WAGNER MODEL TO COMPARE TO HGF+deltaLOGRT


clear

load('data_n28.mat')

%%% rerun for log RT not deltalogRT - fname_base ={ '_3levelHGF_SRC_LogRT', '_RW_SRC_LogRT'}
fname_groupmat = 'Group_n28_RW_logRT_2.mat';
%fname_groupmat = 'Group_n28_RW_DELTA_logRT_2.mat'; % at suffix 2 -> send go at RW; because in first go I'm not sure that tapas_unitsq_smg is an appropriate respons model, becuase myr esponse aran't binary...
%%% adding third model (inputs (:,3) = cue type
% for Delta log RTs load 'trials_by_subject' trials structure
%load('Group_n22_2HGFs.mat')% load info from first two models and add third
%dir_data = ['/Users/mejc110/Documents/MATLAB/SRCpredict_HGFmodelling/extractAll' filesep 'rerun_HGFv5-3_n28'];
dir_data = ['/Users/mejc110/Documents/MATLAB/SRCpredict_HGFmodelling/extractAll' filesep 'rerun_HGFv5-3_n28_logRT']; %_gaussianRM

fname_base = '_RW_SRC_LogRT';  %_DeltaLogRT'   %_gausRM'

cd(dir_data)

for ss=1:length(data.ID)
    for mm = 1 %:3
     fname_rw1 = strcat(data.ID(ss), fname_base,'_m', num2str(mm) ,  '.mat');
     fname_fig1 = strcat(data.ID(ss), fname_base,'_m', num2str(mm) , '.fig');
%     
    % data structure matrixes with (trials x values x subjects)
    u = data.inputs(:,mm,ss) ; % if mm= 2, binary for open/close stimtypes; if mm=1 binary vector for SRC 1 = match 0 =mismatch
    r = data.responses(:,2,ss) ; %col 2 = logRT <<<<<<<<,------- edited here
    
    %data.responses(:,3,ss)   %this third column = trials.delta_logRTs(:,ss); 
    %data.responses(:,2,ss); % col2 = logRT, col1 = RT (these RT's haven't
    %been cleaned of low outliers below 100ms)
    
    % filepath for tapas functions:
%from demo - sim w a different perc model: est1a = tapas_fitModel(sim.y, sim.u, ''tapas_rw_binary_config'', ''tapas_unitsq_sgm_config'', ''tapas_quasinewton_optim_config'')
% note from perc model config unit square sigmoid observation model for binary responses <<<< I'm not using binary responses 
%    
    disp(strcat('%%%%  Fitting RW for ss ', num2str(ss), ' ID', data.ID(ss), '%%%%'))
    
  
    %est = tapas_fitModel(r, u);
    % p = est.p_prc.p
    % % tapas_rw_binary(est, p) %where est is the structure generated by tapas_fitModel and p is the parameter vector in native space;
    % % ^^^ this only made an output structure of nans
    %%example est = tapas_fitModel(responses, inputs); tapas_rw_binary_plotTraj(est);
    RWfit = tapas_fitModel(r, u, 'tapas_rw_binary_config', 'tapas_gaussian_obs_config'); % response model: gaussian obs = continous responses
    %%% YAY this works and looks sensible in plots! Winning! 
    
    
    %  RWfit = tapas_fitModel(est.y, est.u, 'tapas_rw_binary_config', 'tapas_unitsq_sgm_config', 'tapas_quasinewton_optim_config');
    %       ^^^ issue with resp model being for binary responses       ^^^^
    % % % this give errors -> tapas_fitModel( r, u, 'tapas_rw_binary_config', 'tapas_logrt_linear_binary_config');
    
    
    %% plot things
    %plot of inputs only
    tapas_rw_binary_plotTraj(RWfit)
%     scrsz = get(0,'ScreenSize');
%     outerpos = [0.2*scrsz(3),0.7*scrsz(4),0.8*scrsz(3),0.3*scrsz(4)];
%     figure('OuterPosition', outerpos)
%     plot(u, '.', 'Color', [0 0.8 1], 'MarkerSize', 11) %%% MEJC:  blue [0 0 1]; magenta [1 0 1] ; cyan [0 1 1]; purple[0.8 0 0.5]
%     xlabel('Trial number')
%     ylabel('Inputs "u" ') %%%
%     axis([1, 400, -0.1, 1.1])
    set(gca,'Xtick',0:40:400) %%% MEJC: changed tick-marks from 50's to 40's = blocks (note 'gca' = get current axis handle)
    set(gca,'XtickLabel',0:40:400)
%     title([char(data.ID(ss)),  ' match 1 vs mismatch 0'])


% plot trajectories as per demo/built in function
   %  tapas_hgf_binary_plotTraj(RWfit) % has been modified to have tickmarks at 40trials

     
    
    %% save things
    save(fname_rw1{1}, 'RWfit')
    savefig(fname_fig1{1})
    %close figure
    close(gcf)
    
    Group{ss}.RWfit{mm} = RWfit;
    
    end
    disp(['... RW for ss ' num2str(ss), ' saved'])
    disp('%%%%%%%%%%%%%%%%%%%~~~~~~~~~~%%%%%%%%%%%%%%%%%%%')
end


 save(fname_groupmat,'Group');

 
%% mucking about getting raw learning rates to eyeball things
% %     for ss = 1:length(Group)
% %         wt_m3_l1(:,ss) = Group{ss}.hgf_fit{3}.traj.wt(:,1);
% %     end
% %  plot(wt_m3_l1); plot(mean(wt_m3_l1'), 'k', 'LineWidth', 2);