pp= 1; length(SRC.P);
cc = 10; % 10 conditions = columns in summary tables
%means(pp) = structure to put each subject's means in then save into one
%big matrix at the end...
means(pp).colheaders = 'prob.1, prob.3, prob.5, prob.7, prob.9';
means(pp).rows = '1. mismatch, 2.match';
means(pp).earlytrials = 0;

%matrices with all conds per person (separate for each measure)
RTKey_all = nan(2,5,pp); % 2 SRC x 5prob conds, 26 participants
RTflex_all = nan(2,5,pp);
RTflexV_all = nan(2,5,pp);

% data summary structure to get group means into single 2x5 matrix
summary.mean.RTkey = nan(2,5);
summary.mean.flexRT = nan(2,5);
summary.mean.flexV = nan(2,5);
summary.std.RTkey = nan(2,5);
summary.std.flexRT = nan(2,5);
summary.std.flexV = nan(2,5);
summary.headers = 'COLUMNS: prob.1, prob.3, prob.5, prob.7, prob.9; ROWS: 1mismatch, 2match';

%summary.colheaders = 'matchp1, matchp3, match5, matchp7, matchp9; mismatchp1, mismatchp3, mismatch5, mismatchp7, mismatchp9';

%%

for ss = 1:length(SRC.P)
    
    % ?? as per Jess' advice: idx_matrix = zeros(400,10); % preallocate zeros to a matrix of 400 trials x 10 conditions (SRC+probs)
    
    %% get trail by trail info/data (400,1)
    % extract field function -> get all the feilds into a vector
    
    % used 'fillinblanktraildetails.m' to make sure any empty feilds (e.g. in SRC.P.trial.flexRT = []
    % now has NaN
    
    PROB = extractfield(SRC.P(ss).trial,'probability')';
    
    CONDSRC = extractfield(SRC.P(ss).trial,'cond')';
    
    KEYRT = extractfield(SRC.P(ss).trial,'keyRT')';
    
    FLEXRT = extractfield(SRC.P(ss).trial,'flexRT')';%RT flex - time of peak flex measure
    
    FLEXV = extractfield(SRC.P(ss).trial,'flexV')';
    
    % get ride of any negative values in RT (early responses)
    counter=0;
    for ii = 1:length(KEYRT)
        if KEYRT(ii) < 0
            KEYRT(ii) = NaN;
            counter=counter+1;
        end
        means(ss).earlytrials = counter;
    end
    
    idx_nanRT = find(isnan(KEYRT));
    idx_nanflexRT = find(isnan(FLEXRT));
    idx_nanflexV = find(isnan(FLEXV));
    
    %% get matching/mismatching trials for each prob cond.
    idx_21 = find(CONDSRC == 21);
    idx_12 = find(CONDSRC == 12);
    idx_mism = union(idx_21,idx_12);
    
     idx_22 = find(CONDSRC == 22);
     idx_11 = find(CONDSRC == 11);
     idx_matc = union(idx_22, idx_11);
    
    idx_p1 = find(PROB == 0.1);
    idx_p3 = find(PROB == 0.3);
    idx_p5 = find(PROB == 0.5);
    idx_p7 = find(PROB == 0.7);
    idx_p9 = find(PROB == 0.9);
    
    idx_mism_p1 = find(ismember(idx_mism,idx_p1));
    idx_mism_p9 = find(ismember(idx_mism,idx_p9));
    idx_mism_p3 = find(ismember(idx_mism,idx_p3));
    idx_mism_p7 = find(ismember(idx_mism,idx_p7));
    idx_mism_p5 = find(ismember(idx_p5, idx_mism));
    
    idx_matc_p1 = find(ismember(idx_matc,idx_p1));
    idx_matc_p9 = find(ismember(idx_matc,idx_p9));
    idx_matc_p3 = find(ismember(idx_matc,idx_p3));
    idx_matc_p7 = find(ismember(idx_matc,idx_p7));
    idx_matc_p5 = find(ismember(idx_p5,idx_matc));
    
    %RTkeymismatch/match are temporary overwritten by next subject
    % mismatchSRC RTs for each P condition as fields within RTkey_mismatch
    % (differ in length)
    RTkey_mismatch.p1 = KEYRT(idx_mism_p1);
    RTkey_mismatch.p3 = KEYRT(idx_mism_p3);
    RTkey_mismatch.p5 = KEYRT(idx_mism_p5);
    RTkey_mismatch.p7 = KEYRT(idx_mism_p7);
    RTkey_mismatch.p9 = KEYRT(idx_mism_p9);
    
    %matchSRC RTs for each P condition as fields within RTkey_match
    % (differ in length)
    RTkey_match.p1 = KEYRT(idx_matc_p1);
    RTkey_match.p3 = KEYRT(idx_matc_p3);
    RTkey_match.p5 = KEYRT(idx_matc_p5);
    RTkey_match.p7 = KEYRT(idx_matc_p7);
    RTkey_match.p9 = KEYRT(idx_matc_p9);
%     
    %%%%%%%%%%%%%%%%%%%%%% Chunk not copied
    
%         % means(ss).RTkey = 2x5 matrix, with means for each subj
    means(ss).RTkey(1,1) = nanmean(RTkey_mismatch.p1(:)); % col1 = p1
    means(ss).RTkey(1,2) = nanmean(RTkey_mismatch.p3(:));
    means(ss).RTkey(1,3) = nanmean(RTkey_mismatch.p5(:));
    means(ss).RTkey(1,4) = nanmean(RTkey_mismatch.p7(:));
    means(ss).RTkey(1,5) = nanmean(RTkey_mismatch.p9(:)); %col5 = p9
    means(ss).RTkey(2,1) = nanmean(RTkey_match.p1(:)); % col1 = p1
    means(ss).RTkey(2,2) = nanmean(RTkey_match.p3(:));
    means(ss).RTkey(2,3) = nanmean(RTkey_match.p5(:));
    means(ss).RTkey(2,4) = nanmean(RTkey_match.p7(:));
    means(ss).RTkey(2,5) = nanmean(RTkey_match.p9(:)); %col5 = p9

%%%%%%%%%%%%%%
%%% ^^^ bits copied form averages.m in Preprocessing response data.
% load RTdata_n22.mat

RTs = data(1).responses(:,1);

%       cols    'prob.1, prob.3, prob.5, prob.7, prob.9'
%       rows    '1. mismatch, 2.match'
    RTmeans = means(1).RTkey; % 2x5
    m_mismp1 = RTmeans(1,1);
    m_mismp3 = RTmeans(1,2);
    m_mismp5 = RTmeans(1,3);
    m_mismp7 = RTmeans(1,4);
    m_mismp9 = RTmeans(1,5);
    
    m_matcp1 = RTmeans(2,1);
    m_matcp3 = RTmeans(2,2);
    m_matcp5 = RTmeans(2,3);
    m_matcp7 = RTmeans(2,4);
    m_matcp9 = RTmeans(2,5);
    
    % indexes of trial types from averages.m

    %     idx_mism_p1 = find(ismember(idx_mism,idx_p1));
%     idx_mism_p9 = find(ismember(idx_mism,idx_p9));
%     idx_mism_p3 = find(ismember(idx_mism,idx_p3));
%     idx_mism_p7 = find(ismember(idx_mism,idx_p7));
%     idx_mism_p5 = find(ismember(idx_mism,idx_p5));
%     
%     idx_matc_p1 = find(ismember(idx_matc,idx_p1));
%     idx_matc_p9 = find(ismember(idx_matc,idx_p9));
%     idx_matc_p3 = find(ismember(idx_matc,idx_p3));
%     idx_matc_p7 = find(ismember(idx_matc,idx_p7));
%     idx_matc_p5 = find(ismember(idx_matc,idx_p5));
delatRT = nan(400:1); %preallocate

for tt= 1:length(RTs) %400 trials . %%%%%%%%%%%%%%%%%%%%% <<<<-- something going wrong with a bunch of trials delta=0 which is ~impossible
    if ismember(tt, idx_mism_p1)
        deltaRT(tt,1) = RTs(tt,1) - m_mismp1;
    elseif ismember(tt, idx_mism_p9)
        deltaRT(tt,1) = RTs(tt,1) - m_mismp9;
    elseif ismember(tt, idx_mism_p3)
        delatRT(tt,1) = RTs(tt,1) - m_mismp3;
    elseif ismember(tt, idx_mism_p7)
        deltaRT(tt,1) = RTs(tt,1) - m_mismp7;
    elseif ismember(tt, idx_mism_p5)
        deltaRT(tt,1) = RTs(tt,1) - m_mismp5;
        
    elseif ismember(tt, idx_matc_p1)
        deltaRT(tt,1) = RTs(tt,1) - m_matcp1;
    elseif ismember(tt, idx_matc_p9)
        deltaRT(tt,1) = RTs(tt,1) - m_matcp9;  
    elseif ismember(tt, idx_matc_p3)
        deltaRT(tt,1) = RTs(tt,1) - m_matcp3;
    elseif ismember(tt, idx_matc_p7)
        deltaRT(tt,1) = RTs(tt,1) - m_matcp7;  
    else ismember(tt, idx_matc_p5)
        deltaRT(tt,1) = RTs(tt,1) - m_matcp5;    
    end
    tt
end