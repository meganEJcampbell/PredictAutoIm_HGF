%% extract from P the details I need for HGF
% inputs: (binary values)
% one vector per subject for 400 trials with 1= match, 0 = mismatch
% "" for stimulus type: 1=open, 0=close


% responses: (continuous values)
% one vector per subject for 400 trials
% 1. RT (ms)   % in ms with any early responses (less than 150ms) nanned
% 2. logRT 
% 3. then get  mean logRT by condition and calculate
%    delta log RT for response modelling

%%% added summary tables for JASP and xcl -> .txt and tab-deliminated
clear all

fname_in = 'P_Alln28.mat'; 
load(fname_in);

fname_out = 'data_n28.mat';
% checked for 'data_n30.mat' missing responses with 'count missing RT by cond.m' and 
% excluding 3 participants with more than 20% missing: P08 & P16, P28


%Pinclude = [1:7, 9:15, 17:30]; % P28 was already excluded  from P_Alln30.mat
Pinclude = 1:length(P); 
nparticipants = length(Pinclude); 

ntrials = 400;
data.responses = nan(ntrials, 3, nparticipants); % 400x3x30
data.notes_responses = 'cols: 1.keyRT, 2.logRT, 3. deltalogRT';
data.inputs = nan(ntrials, 3, nparticipants); % 400x3x30
data.notes_inputs = 'cols: 1.SRC 1=match , 2.video, 3. cue, 1=open';
data.ID = extractfield(P(Pinclude), 'ID')';



% get details out of P and into arrays/matrix

for ss = 1:length(Pinclude)
    
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    disp(['Getting data from ID ', P(Pinclude(ss)).ID , ' & ss number ' , num2str(ss)])
    
    CONDSRC = extractfield(P(Pinclude(ss)).trial,'cond')';
    KEYRT = extractfield(P(Pinclude(ss)).trial,'keyRT')'; % already in ms
    PROB = extractfield(P(Pinclude(ss)).trial,'probability')';
    %% index
    % get matching/mismatching trials   
        % note cond code first number = cue, second number = video; so 11 = open cue and open video
    idx_21 = find(CONDSRC == 21);
    idx_12 = find(CONDSRC == 12);
    idx_mism = union(idx_21,idx_12);
   
    idx_22 = find(CONDSRC == 22);
    idx_11 = find(CONDSRC == 11);
    idx_matc = union(idx_22, idx_11);
                          
   %% inputs as binary list 0/1s for HGF 
    idx_Opvid = union(idx_21, idx_11); % open video trials
    idx_OpCue = union(idx_12, idx_11); % open cue trials
    
    binary_SRC = zeros(400,1);
    binary_OCvid = zeros(400,1);
    binary_OCcue = zeros(400,1);
    
    binary_SRC(idx_matc) =1; % 1 = match ; 0 = mismatch
    
    binary_OCvid(idx_Opvid) = 1; %1=open
    binary_OCcue(idx_OpCue)= 1;
    
%     %save txt files for each subject - read into hgf
%     fid = fopen([char(data.ID(ss)), '_list_cues.txt'], 'wb');
%     fwrite(fid,binary_OCcue)
%     fid = fopen([char(data.ID(ss)), '_list_stims.txt'], 'wb');
%     fwrite(fid,binary_OCvid)
%     fid = fopen([char(data.ID(ss)), '_list_SRC.txt'], 'wb');
%     fwrite(fid,binary_SRC) 
    
    % add to data structure 
    
    % data.inputs(tt,1,ss) = match/mismatch
    data.inputs(:,1,ss) = binary_SRC; 
    % data.inputs(tt,2,ss) = video open/close % stimulus
    data.inputs(:,2,ss) = binary_OCvid; 
    % data.inputs(tt,3,ss) = cued action open/close
    data.inputs(:,3,ss) = binary_OCcue; 
    
    %% responses
    % clean out early responses 
    for cc=1:length(KEYRT)
        if KEYRT(cc) <0
            KEYRT(cc) = nan;
            cc=cc+1;
        elseif KEYRT(cc) <150.0 % less than 150ms
            KEYRT(cc) = nan;
            cc=cc+1;
        else
            cc=cc+1;
        end
    end
   
    data.responses(:,1,ss) = KEYRT; % RT (ms)
    data.responses(:,2,ss) = log(KEYRT); % log RT
    
    %% Need Delta Log RT 
    % get mean logRT by condition to get delta-logRT for each
    idx_p1 = find(PROB == 0.1);
    idx_p3 = find(PROB == 0.3);
    idx_p5 = find(PROB == 0.5);
    idx_p7 = find(PROB == 0.7);
    idx_p9 = find(PROB == 0.9);
    
    %%% notes for indexing with ismember:  output will be length(indx_1); was making a mistake using 'find' with 'ismember' rather just use 'ismember' to
    %%% get an logical array (1s&0s) then use that to get the index i want...  ii= idx_1(ismember(idx_1, idx_2))
    
    
    idx_mism_p1 = idx_mism(ismember(idx_mism,idx_p1));
    idx_mism_p9 = idx_mism(ismember(idx_mism,idx_p9));
    idx_mism_p3 = idx_mism(ismember(idx_mism,idx_p3));
    idx_mism_p7 = idx_mism(ismember(idx_mism,idx_p7));
    idx_mism_p5 = idx_mism(ismember(idx_mism, idx_p5));
    
    idx_matc_p1 = idx_matc(ismember(idx_matc,idx_p1));
    idx_matc_p9 = idx_matc(ismember(idx_matc,idx_p9));
    idx_matc_p3 = idx_matc(ismember(idx_matc,idx_p3));
    idx_matc_p7 = idx_matc(ismember(idx_matc,idx_p7));
    idx_matc_p5 = idx_matc(ismember(idx_matc,idx_p5));
    
      % means(ss).RTkey = 2x5 matrix, with means for each subj
    means(ss).RTkey(1,1) = nanmean(KEYRT(idx_mism_p1)); % col1 = p1
    means(ss).RTkey(1,2) = nanmean(KEYRT(idx_mism_p3));
    means(ss).RTkey(1,3) = nanmean(KEYRT(idx_mism_p5));
    means(ss).RTkey(1,4) = nanmean(KEYRT(idx_mism_p7));
    means(ss).RTkey(1,5) = nanmean(KEYRT(idx_mism_p9)); %col5 = p9
    
    means(ss).RTkey(2,1) = nanmean(KEYRT(idx_matc_p1)); % col1 = p1
    means(ss).RTkey(2,2) = nanmean(KEYRT(idx_matc_p3));
    means(ss).RTkey(2,3) = nanmean(KEYRT(idx_matc_p5));
    means(ss).RTkey(2,4) = nanmean(KEYRT(idx_matc_p7));
    means(ss).RTkey(2,5) = nanmean(KEYRT(idx_matc_p9)); %col5 = p9
    
    
    %RTkeymismatch/match are temporary 
    logRTs= data.responses(:,2,ss); % log RT
    logRTkey_mismatch.p1 = logRTs(idx_mism_p1);
    logRTkey_mismatch.p3 = logRTs(idx_mism_p3);
    logRTkey_mismatch.p5 = logRTs(idx_mism_p5);
    logRTkey_mismatch.p7 = logRTs(idx_mism_p7);
    logRTkey_mismatch.p9 = logRTs(idx_mism_p9);
    
    %matchSRC RTs for each P condition as fields within RTkey_match
    % (differ in length)
    logRTkey_match.p1 = logRTs(idx_matc_p1);
    logRTkey_match.p3 = logRTs(idx_matc_p3);
    logRTkey_match.p5 = logRTs(idx_matc_p5);
    logRTkey_match.p7 = logRTs(idx_matc_p7);
    logRTkey_match.p9 = logRTs(idx_matc_p9);
    
  % means(ss).RTkey = 2x5 matrix, with means for each subj
    means(ss).logRT(1,1) = nanmean(logRTkey_mismatch.p1(:)); % col1 = p1
    means(ss).logRT(1,2) = nanmean(logRTkey_mismatch.p3(:));
    means(ss).logRT(1,3) = nanmean(logRTkey_mismatch.p5(:));
    means(ss).logRT(1,4) = nanmean(logRTkey_mismatch.p7(:));
    means(ss).logRT(1,5) = nanmean(logRTkey_mismatch.p9(:)); %col5 = p9
    means(ss).logRT(2,1) = nanmean(logRTkey_match.p1(:)); % col1 = p1
    means(ss).logRT(2,2) = nanmean(logRTkey_match.p3(:));
    means(ss).logRT(2,3) = nanmean(logRTkey_match.p5(:));
    means(ss).logRT(2,4) = nanmean(logRTkey_match.p7(:));
    means(ss).logRT(2,5) = nanmean(logRTkey_match.p9(:)); %col5 = p9
    
    logRTmeans = means(ss).logRT; % 2x5
    m_mismp1 = logRTmeans(1,1);
    m_mismp3 = logRTmeans(1,2);
    m_mismp5 = logRTmeans(1,3);
    m_mismp7 = logRTmeans(1,4);
    m_mismp9 = logRTmeans(1,5);
    
    m_matcp1 = logRTmeans(2,1);
    m_matcp3 = logRTmeans(2,2);
    m_matcp5 = logRTmeans(2,3);
    m_matcp7 = logRTmeans(2,4);
    m_matcp9 = logRTmeans(2,5);
    
    
        deltalogRT = nan(400:1); %preallocate
    
    for tt= 1:ntrials %400 trials . 
        if ismember(tt, idx_mism_p1)
            deltalogRT(tt,1) = logRTs(tt,1) - m_mismp1;
        elseif ismember(tt, idx_mism_p9)
            deltalogRT(tt,1) = logRTs(tt,1) - m_mismp9;
        elseif ismember(tt, idx_mism_p3)
            deltalogRT(tt,1) = logRTs(tt,1) - m_mismp3;
        elseif ismember(tt, idx_mism_p7)
            deltalogRT(tt,1) = logRTs(tt,1) - m_mismp7;
        elseif ismember(tt, idx_mism_p5)
            deltalogRT(tt,1) = logRTs(tt,1) - m_mismp5;
            
        elseif ismember(tt, idx_matc_p1)
            deltalogRT(tt,1) = logRTs(tt,1) - m_matcp1;
        elseif ismember(tt, idx_matc_p9)
            deltalogRT(tt,1) = logRTs(tt,1) - m_matcp9;
        elseif ismember(tt, idx_matc_p3)
            deltalogRT(tt,1) = logRTs(tt,1) - m_matcp3;
        elseif ismember(tt, idx_matc_p7)
            deltalogRT(tt,1) = logRTs(tt,1) - m_matcp7;
        elseif ismember(tt, idx_matc_p5)
            deltalogRT(tt,1) = logRTs(tt,1) - m_matcp5;
        else
            disp(['something weird on trial : ' , num2str(tt), num2str(ss)])
        end
        
    end
    
    data.responses(:,3,ss) = (deltalogRT); % log RT
    
    

    disp([num2str(ss), ' done.'])
    
end % subject loop

data.means = means;
data.notes_means = '2x5 matrix per Pp: row 1 = mismatch, row 2 = match; cols = 5 probs ';


  save(fname_out, 'data')
 %%%%
 
 RT_table=zeros(28,10);
 logRT_table = zeros(28,10); 
 for s=1:28
     
     RT_table(s,1:5) = data.means(s).RTkey(1,:); %mismatch
     RT_table(s,6:10) = data.means(s).RTkey(2,:); %match
     
     logRT_table(s,1:5) = data.means(s).logRT(1,:); %mismatch
     logRT_table(s,6:10) = data.means(s).logRT(2,:); %match
 end
 
 dlmwrite('RT_table_n28.txt',RT_table,'delimiter','\t','precision',4)
 dlmwrite('logRT_table_n28.txt',logRT_table,'delimiter','\t','precision',4)
 %elements delimited by the tab character, using a precision of 6 significant digits
 
 MismCost = zeros(28,5);
 MismCost(:,1) = RT_table(:,6)-RT_table(:,1); % (match p1 - mismatch p1)
 MismCost(:,2) = RT_table(:,7)-RT_table(:,2); %
 MismCost(:,3) = RT_table(:,8)-RT_table(:,3); %
 MismCost(:,4) = RT_table(:,9)-RT_table(:,4); % 
 MismCost(:,5) = RT_table(:,10)-RT_table(:,5); % 
 
 dlmwrite('MismCost_table_n28.txt', MismCost ,'delimiter','\t','precision',4)
  
 
 
save(['Tables_', fname_out], 'RT_table', 'logRT_table', 'MismCost')


%%% checking the block order to get out exemplar participants for trajectory figures.

probs = nan(400,28);

for ss = 1:length(P) 
 probs(:,ss) = extractfield(P(ss).trial,'probability')';
    
end

