%%% Run our RT response model - log-likelihood drift diffusion model
%% loglikelihoodRT(RT,latentvalue,params, inputs, generate)

%%%%%%%%
%%% Campbell, Brown & Breakspear - Started Tuesday 25/05/2021 completed 11/11/2021 :-)
% simple instance of DriftDiffussion decisions model for estimatign
% reaction time based on some perceptual model parameter(s).
%%% For reference: Ratcliff, R., Smith, P. L., Brown, S. D. & McKoon, G. Diffusion Decision Model: Current Issues and History. Trends Cogn Sci 20, 260Ð281 (2016). 

%%% Runs an estimation of reaction times (in seconds) in iterative steps:
%%% step 1) minimisation with starting parameters, v & k
%%%         needs the observed RT, the trail conditions (inputs) and the
%%%         perceptual model "latent value" zero-centred between -1:1 
% % for HGF we add more layers of perceptual model parameters by linear combination (here just form layer 3 and 2)
%        [fit.p_prc.mu_0(3); fit.traj.mu(:,3)] = volatilty (level 3)
%        [fit.p_prc.mu_0(2); fit.traj.mu(:,2)] = posterior expectation of prob SR match

%%% step 2) then feed participant's minimised parameters back LL to generate RT
%%% next return to step 1) but with new starting points = get group-average for minimised parameters v 7 k
%%% step 2 generates data with next output of previous step's minimised parameters from these group-average starting point then gen steps

%%% separately need to plot things:
% fitting indiviudal from arbitrary start point -> plot both - ball park fit?
%  group average optimised parameters to then run another set of optimising
%  with these new start points
%  plot again as per paper figures -> do we get the effects of interest in  our new RT?
% check Q-Q plots for comparision of fit for the whole group in one glance:
% Y= estimated, X=real 
% % plot real RT vs generated RT

%%%%%%%%
clear

% % % ----------------turn things on /off --------------------- % % %
disp('Are we starting from scratch?')
disp('')
StartingFromScratch =input('1= running minimisation from set starting points for v & k; if 0 will run with mean v and k from run1:  ') ;
disp('')
%StartingFromScratch = 0; % 1= running minimisation from set starting points for v & k; if 0 will run with mean v and k from run1

savestuff =1 ; % save things? 1 if yes % check things aren't overwritten
getGroupMeans = 1; % overall means for conditions
plotGroupmeans = 1;

% % % --------------------------------------------------------- % % %


% filepaths and datasets
fname_RTdata_in = 'DataIn_n28.mat'; % trial and RT info
fname_Pmod_in = 'HGFvsRW_logRT_n28.mat'; % HGF and RW perceptual models (need for 'latent parameters') NB: Percmod(ss).fit(mm).c_prc.model will return the model name from the HGF toolbox
path_newmodels = '/Users/mejc110/OneDrive - The University of Newcastle/MATLAB/2019-20 rerun SRCpredict_HGFmodelling/NewResponseModelling';
cd(path_newmodels) % make sure i'm starting in the right directory

%%% change this file name to avoid overriding 
dir_out_name = '2021-11-09_Figs_outputs_RW_HGF_c5'; 
%%%
fname_out = 'LL_RT_outputs.mat';
prev_run = strcat(dir_out_name , '1/LL_RT_outputs.mat') ;


% Get the things: real RT data, trail info and perceptual model
load(fname_RTdata_in)
load(fname_Pmod_in)

%% Choose which percept model you want 1=HGF 2=RW
% within the variable Percmod loaded with fname_Pmod_in each person has 2 models, in the structure (Percmod(1).fit)
fname_base = {'LL_HGF', 'LL_RW'}; % {'LL_HGF'}; %{'LL_HGF', 'LL_RW'};
percmods = {'LL_HGF', 'LL_RW'}; % {'HGF'}; % {'HGF', 'RW' };

% set starting values for v and k

start_v = 6; % mean drift rate
start_k = 1; % threshold for response

% and offset to 'catch the bollocks' within 'loglikelihoodRT.m'
offset = 0.05 ;
c = 0.5; % must be between 0 and 1 = value for weighing the combination of 2 hgf latent values... 
% tried c=0.5, 0.1, 0.9

%% if you've already run previous iteration of minimisation
% choose parameters from which to generate data: params b,v,k,minT now put into a structure by "rm_chooseparams2minise.m" function, keeping b & minT constant, so just give it v and k where:
% what to minimise v and k
if StartingFromScratch
        dir_out = [dir_out_name, '1'];
    if ~isdir(dir_out)
        mkdir(dir_out)
    end
    
elseif ~StartingFromScratch % save in new dir (and below load previous run

    dir_out = [dir_out_name, '2'];
    if ~isdir(dir_out)
        mkdir(dir_out)
    end
end

% % % ---------------------------------------------- % % %


tic
for mm = 1:length(percmods) % loop through RW and HGF perceptual models to get 'latentvalue' vector for each Pp
    if ~StartingFromScratch
        % if 2nd iteration
        load(prev_run)
        prevRespMod = RespMod; %rename so that next model is saved separately
        for ss = 1:length(data.ID)
            all_v(ss,1) = (RespMod(ss).model(mm).v);
            all_k(ss,1) = (RespMod(ss).model(mm).k);
        end
        mean_v = mean(all_v);
        mean_k = mean(all_k);
        disp('using group mean v & k ')
        disp(strcat('v=', num2str(mean_v), '  and k=', num2str(mean_k)))
    end
    for ss=1:length(data.ID)
        
        RT = data.responses(:,1,ss) ; %  col1 = RT ; second col = log RT;  col3 = delta logRT
        RT= RT/1000;
        inputs = data.inputs(:,1,ss); % inputs = whether the trial is 0=mismatch or 1=match
        inputs = (inputs*2)-1; % (change so now -1 = mismatch and 1 = match)
        
        RespMod(ss).real_RT = RT; % gathering everything in one structure
        RespMod(ss).inputs = inputs;
        RespMod(ss).model(mm).namePercepMod = percmods{mm};
        
        %% Get the "latent values" from the perceptual models = estimates for SRC match/mismatch
        %% latentvalue is a 400-vector of the percept model's latent value. I assume it's zero-centred, so that it takes values between -1 and +1.
        if mm == 1 % (hgf)
            % getting 2 parameters from HGF perceptual model
            mu2 = Percmod(ss).fit(mm).traj.mu(:,2); %mu2 posterior expectation of the match/mismatch
            mu3 = Percmod(ss).fit(mm).traj.mu(:,3); %volatility estimate  %from 'tapas_hgf_binary_plotTraj.m' [r.p_prc.mu_0(l-j+1); r.traj.mu(:,l-j+1)]
            % adding step to rescale values between [0,1] with function "rescale" B = rescale(A) scales the entries of an array to the interval [0,1].
            mu2 = rescale(mu2);
            mu3 = rescale(mu3);
            
            latentvalue(:,1) = mu2;
            latentvalue(:,2) = mu3;
            % latent_value = linear combination of the 2 HGF latent values... c goes from 0-1; 0=weighing latent(1) (same as original); make c greater than zero -> volatiilty (latent(2) can influence the mdoel
            % latent vlaue = (1-c).*latentvalue(1) + c*latentvalue(2)
            latentvalue = ((1-c).*latentvalue(:,1)) + (c*latentvalue(:,2));
            latentvalue = latentvalue-0.5; % adjusted -0.5 -> original values are between 0 and 1

        elseif mm == 2 % (RW)
            latentvalue = (Percmod(ss).fit(mm).traj.v)-0.5; % adjusted -0.5 -> original values are between 0 and 1
        end
        RespMod(ss).model(mm).latentvalue = latentvalue; 
        if StartingFromScratch % = 1; % running minimisation from set starting points for v & k
            params = [start_v, start_k]; %% = [v,k] starting points that the LL will then minimise
        else
            params = [mean_v, mean_k];
        end
        
        
        %% Step 1: Minimise v & k params
        % 1. optimise parameters with fminsearch =Multidimensional unconstrained nonlinear minimization (Nelder-Mead). (set when generate =0)
        disp('Step 1 minimising')
        
        generate = 0 ; % start by not generating data - but minimising parameters 1st
        disp(strcat('Running MLE minimising for ss: ' , num2str(ss)))
        
        %  [output_value, output_vector] = loglikelihoodRT(RT,latentvalue,params, inputs, generate)
        MLEparams = fminsearch(@(x) rm_rm_chooseparams2minise(x,RT,latentvalue,inputs, offset, generate), params); % Note rm_chooseparams2minise.m function fixes params.b at 0.
        RespMod(ss).model(mm).v = MLEparams(1);
        RespMod(ss).model(mm).k = MLEparams(2);
        
        %% Step 2: then Generate wiht minimised v and k
        % 2.  estimate RT values InverseGaussian with the parameters set in 'rm_chooseparams2minise' (set by generate = 1)
        
        generate=1; % Generate some data
        LLrt = rm_rm_chooseparams2minise(MLEparams,RT,latentvalue,inputs, offset, generate);
        RespMod(ss).model(mm).LL_RT = LLrt; %#ok<*SAGROW> <<-- suprress Matlab warning for 'pre allocating' blah blah
        % will be a vector 400x1 of 'generated' RT data
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % % PLOT HISTO FOR EACH SUBJECT
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('plotting RT and estimate RT')
        set_edges=0.15:0.05:1.01; % set defined edges for the hitogram bins so that distributions are comparable
        figure
        subplot(2,1,1)
        bar(set_edges,histc(RT(isfinite(RT)),set_edges))
        xlabel(strcat('Real RTs for ss', num2str(ss)))
        subplot(2,1,2)
        bar(set_edges,histc(LLrt,set_edges)) % RT predicted by Loglikelihood
        xlabel(strcat('Generated RTs for ss', num2str(ss)))
        
        cd(dir_out)
        fname_fig1 = strcat('ss', num2str(ss), percmods{mm}, '_realVgenerated_RT' ,  '.fig');
        savefig(fname_fig1)
        close(gcf)
        disp('figures saved')
        cd ..  %go back to main dir
        
        
        disp(['done for participant number ' num2str(ss)])
        disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DONE 1 P ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
        
    end% ss loop
end% i loop (perceptual models)
runtime = toc/60;

    disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Saving for this model ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

    %% save stuff
    if savestuff
        cd(dir_out)
        
        disp('generated RTs saved')
        save(fname_out,'RespMod') %
        
        cd ..  %go back to main dir
                
        % save([fname_base{mm}, '_outputs.mat'],'RespMod') % save([fname_base{1}, '_params.mat'], 'params');
        %%% will need to change {mm} to {i} if running this with more than one percept model for 'latent value'
    end

disp(['~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ALL DONE (in ' ,num2str(runtime),  'mins) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'])


%%%%%%%%%%%%%%%%%%%%%%%%%%
% % CALCULATE SUBJECT OVERALL MEAN RT & PLOT
%%%%%%%%%%%%%%%%%%%%%%%%%%
 for ss=1:length(data.ID) % gather data for all subjects
    for mm = 1:length(percmods)
    RT_means(ss,mm) = nanmean(RespMod(ss).model(mm).LL_RT); % percmod = HGF
    end
    
    RT_means(ss,(length(percmods)+1)) = nanmean(RespMod(ss).real_RT); % lastone is always real RT
   
 end

for ss=1:length(data.ID) % gather data for all subjects
    for mm = 1:length(percmods)
    RT_means(ss,mm) = nanmean(RespMod(ss).model(mm).LL_RT); % percmod = HGF
    end
    
    RT_means(ss,(length(percmods)+1)) = nanmean(RespMod(ss).real_RT); % lastone is always real RT
   
 end

figure
hold on
bar(RT_means)
if length(percmods) ==1
    legend('LL hgf', 'real')
else
    legend('LL hgf', 'LL rw', 'real')
end
ylabel('RT (seconds) ')
xlabel('subjects n=28')
cd(dir_out)
savefig(strcat('CompareGenVsRealRTs_',date, '.fig'))
disp('******** simple summary figure saved of overall means ********')

%%%%%%%%%%%%%%%%%%%%%%%%%%
% % CALCULATE GROUP MEANS
%%%%%%%%%%%%%%%%%%%%%%%%%%
if getGroupMeans
    cd(path_newmodels)
    % made index of conditions for all subjects with this /NewResponseModelling/scriptsforsummarising/IndexConditions.m
    load('IndexOfConditions.mat')
    %          match: [200×28 double]
    %       mismatch: [200×28 double]
    %          probs: [80×5×28 double]
    %        p1match: [8×28 double] %      p1mismatch: [72×28 double]
    %        p3match: [24×28 double] %     p3mismatch: [56×28 double]
    %        p5match: [40×28 double] %     p5mismatch: [40×28 double]
    %        p7match: [56×28 double] %     p7mismatch: [24×28 double]
    %        p9match: [72×28 double] %     p9mismatch: [8×28 double]
    
    
    for ss=1:length(data.ID) % gather generated data for all subjects
        
        %trial type/condition indexes for this pp
        idx_matc = index.match(:,ss);
        idx_mism = index.mismatch(:,ss);
        idx_p1 = index.probs(:,1,ss);
        idx_p3 = index.probs(:,2,ss);
        idx_p5 = index.probs(:,3,ss);
        idx_p7 = index.probs(:,4,ss);
        idx_p9 = index.probs(:,5,ss);
        idx_matc_p1 = index.p1match(:,ss);
        idx_matc_p3 = index.p3match(:,ss);
        idx_matc_p5 = index.p5match(:,ss);
        idx_matc_p7 = index.p7match(:,ss);
        idx_matc_p9 = index.p9match(:,ss);
        idx_mism_p1 = index.p1mismatch(:,ss);
        idx_mism_p3 = index.p3mismatch(:,ss);
        idx_mism_p5 = index.p5mismatch(:,ss);
        idx_mism_p7 = index.p7mismatch(:,ss);
        idx_mism_p9 = index.p9mismatch(:,ss);
        
        for mm = 1:length(percmods)
            RT = RespMod(ss).model(mm).LL_RT;
            
            % means by SRC = 28x2 matrix
            means(mm).bySRC(ss,1) = nanmean(RT(idx_matc));
            means(mm).bySRC(ss,2) = nanmean(RT(idx_mism));
            % means by prob  = 28 x 5 matrix
            means(mm).byprob(ss,1) = nanmean(RT(idx_p1));
            means(mm).byprob(ss,2) = nanmean(RT(idx_p3));
            means(mm).byprob(ss,3) = nanmean(RT(idx_p5));
            means(mm).byprob(ss,4) = nanmean(RT(idx_p7));
            means(mm).byprob(ss,5) = nanmean(RT(idx_p9));
            
            % means by 2x5 conds = pp, cols = 5 prob levels
            means(mm).by2x5.mismatch(ss,1) = nanmean(RT(idx_mism_p1));
            means(mm).by2x5.mismatch(ss,2) = nanmean(RT(idx_mism_p3));
            means(mm).by2x5.mismatch(ss,3) = nanmean(RT(idx_mism_p5));
            means(mm).by2x5.mismatch(ss,4) = nanmean(RT(idx_mism_p7));
            means(mm).by2x5.mismatch(ss,5) = nanmean(RT(idx_mism_p9));
            
            means(mm).by2x5.match(ss,1) = nanmean(RT(idx_matc_p1));
            means(mm).by2x5.match(ss,2) = nanmean(RT(idx_matc_p3));
            means(mm).by2x5.match(ss,3) = nanmean(RT(idx_matc_p5));
            means(mm).by2x5.match(ss,4) = nanmean(RT(idx_matc_p7));
            means(mm).by2x5.match(ss,5) = nanmean(RT(idx_matc_p9));
        end %mm loop
        
        mm=length(percmods)+1; % put real RT's in together as last set
        RT = RespMod(ss).real_RT;
        
        % means by SRC = 28x2 matrix
        means(mm).bySRC(ss,1) = nanmean(RT(idx_matc));
        means(mm).bySRC(ss,2) = nanmean(RT(idx_mism));
        % means by prob  = 28 x 5 matrix
        means(mm).byprob(ss,1) = nanmean(RT(idx_p1));
        means(mm).byprob(ss,2) = nanmean(RT(idx_p3));
        means(mm).byprob(ss,3) = nanmean(RT(idx_p5));
        means(mm).byprob(ss,4) = nanmean(RT(idx_p7));
        means(mm).byprob(ss,5) = nanmean(RT(idx_p9));
        
        % means by 2x5 conds = pp, cols = 5 prob levels
        means(mm).by2x5.mismatch(ss,1) = nanmean(RT(idx_mism_p1));
        means(mm).by2x5.mismatch(ss,2) = nanmean(RT(idx_mism_p3));
        means(mm).by2x5.mismatch(ss,3) = nanmean(RT(idx_mism_p5));
        means(mm).by2x5.mismatch(ss,4) = nanmean(RT(idx_mism_p7));
        means(mm).by2x5.mismatch(ss,5) = nanmean(RT(idx_mism_p9));
        
        means(mm).by2x5.match(ss,1) = nanmean(RT(idx_matc_p1));
        means(mm).by2x5.match(ss,2) = nanmean(RT(idx_matc_p3));
        means(mm).by2x5.match(ss,3) = nanmean(RT(idx_matc_p5));
        means(mm).by2x5.match(ss,4) = nanmean(RT(idx_matc_p7));
        means(mm).by2x5.match(ss,5) = nanmean(RT(idx_matc_p9));
    end %ss loop
cd(dir_out)
save('meanRTs_genVreal.mat', 'means') 
disp('******** Calculated means by conditions ********')
end %end if for calculating means


%%%%%%%%%%%%%%%%%%%%%%%%%%
% % PLOT GROUP MEANS
%%%%%%%%%%%%%%%%%%%%%%%%%%
if plotGroupmeans
    cd(path_newmodels)   
    % % plotting 2x5 for the generated data and the real data from the 'means' structure calculated above
    
    % cd(dir_out)    
    %load(LL_RT_outputs) %= RespMod
    
    nPp = 28;
    x=[0.1, 0.3, 0.5, 0.7, 0.9]'; % probability conditions
    figure
    hold on
    if length(percmods) ==1
        names_subplots = {'Generated RT from LL HGF', 'Real RT data' };
    else
        names_subplots = {'Generated RT from LL HGF', 'Generated RT from LL RW', 'Real RT data' };
    end
    for mm =1:(length(percmods)+1) % hgf, rw, and then 3 = real
        
        % rows = probs, cols = match, mismatch
        m_RTs(:,1) = mean(means(mm).by2x5.match)';
        m_RTs(:,2) = mean(means(mm).by2x5.mismatch)';
        sem_RTs(:,1) = (std(means(mm).by2x5.match)./(sqrt(nPp)));
        sem_RTs(:,2) = (std(means(mm).by2x5.mismatch)./(sqrt(nPp)));
        
        subplot(1,3,mm) 
        
        er = errorbar([x,x],m_RTs,sem_RTs);    %errorbar([x,x],means,sem)
        er(1).Color = 'b';
        er(2).Color = 'r';
        xlim([0 1])
        ylim([0.34 0.45])
        xlabel('Probability of SR match')
        ylabel('mean RT (seconds) +/-SEM')
        title(names_subplots{mm})
        legend('match', 'mismatch')
        set(gca,'Xtick',0.1:0.2:0.9)
        set(gca,'XtickLabel',[0.1, 0.3, 0.5, 0.7, 0.9])
        
        
    end
    cd (dir_out)
    savefig(strcat('meansplotSEM_5x2_realVgenerated_RT_',date, '.fig'))
%%%%%%%%
    
end % end if plotting means


%%%%%%%%%% new plots of main effects
    
   % % %    % % %    % % %    % % %    