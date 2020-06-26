clear all


%load('data_n30.mat')
load('P_Alln30.mat'); 
load('data_n28.mat');
all_logRT = squeeze(data.responses(:,3,:));

nPp = length(data.ID);
%preallocate
count_missing = zeros(2,5,nPp);
perc_missing = zeros(2,5,nPp);
for ss = 1:nPp
   
    CONDSRC = data.inputs(:,1,ss); % 1 = match; 0 = mismatch 
    
    PROB = extractfield(P(ss).trial,'probability')';
    %% indexing

    idx_mism = find(CONDSRC == 0);
    idx_matc = find(CONDSRC == 1);

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
    
    
    % 5x2: row 1 = mism, row 2 = match
    count_missing(1,1,ss) = sum(isnan(all_logRT(idx_mism_p1,ss)));
    count_missing(1,2,ss) = sum(isnan(all_logRT(idx_mism_p3,ss)));
    count_missing(1,3,ss) = sum(isnan(all_logRT(idx_mism_p5,ss)));
    count_missing(1,4,ss) = sum(isnan(all_logRT(idx_mism_p7,ss)));
    count_missing(1,5,ss) = sum(isnan(all_logRT(idx_mism_p9,ss)));

    count_missing(2,1,ss) = sum(isnan(all_logRT(idx_matc_p1,ss)));
    count_missing(2,2,ss) = sum(isnan(all_logRT(idx_matc_p3,ss)));
    count_missing(2,3,ss) = sum(isnan(all_logRT(idx_matc_p5,ss)));
    count_missing(2,4,ss) = sum(isnan(all_logRT(idx_matc_p7,ss)));
    count_missing(2,5,ss) = sum(isnan(all_logRT(idx_matc_p9,ss)));
    
    
    %quick rearrange to view in xcel sanity check
    missing(ss,1) = sum(isnan(all_logRT(idx_mism_p1,ss)));
    missing(ss,2) = sum(isnan(all_logRT(idx_mism_p3,ss)));
    missing(ss,3) = sum(isnan(all_logRT(idx_mism_p5,ss)));
    missing(ss,4) = sum(isnan(all_logRT(idx_mism_p7,ss)));
    missing(ss,5) = sum(isnan(all_logRT(idx_mism_p9,ss)));

    missing(ss,6) = sum(isnan(all_logRT(idx_matc_p1,ss)));
    missing(ss,7) = sum(isnan(all_logRT(idx_matc_p3,ss)));
    missing(ss,8) = sum(isnan(all_logRT(idx_matc_p5,ss)));
    missing(ss,9) = sum(isnan(all_logRT(idx_matc_p7,ss)));
    missing(ss,10) = sum(isnan(all_logRT(idx_matc_p9,ss)));
end

save('count_missingRT_n28.mat', 'count_missing', 'missing')

nTs_percond(1,1) = length(idx_mism_p1);
nTs_percond(1,2) = length(idx_mism_p3);
nTs_percond(1,3) = length(idx_mism_p5);
nTs_percond(1,4) = length(idx_mism_p7);
nTs_percond(1,5) = length(idx_mism_p9);


nTs_percond(2,1) = length(idx_matc_p1);
nTs_percond(2,2) = length(idx_matc_p3);
nTs_percond(2,3) = length(idx_matc_p5);
nTs_percond(2,4) = length(idx_matc_p7);
nTs_percond(2,5) = length(idx_matc_p9);

perc_missing = (count_missing ./ nTs_percond)*100;
save('percent_missingRT_n28.mat', 'perc_missing')


