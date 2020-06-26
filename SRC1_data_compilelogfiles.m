%%% getting all RT data /trial logs into one structure with arranged as trials 1:400 not blocks


clear all

dir_data =  '/Users/mejc110/Documents/MATLAB/HGF_PhD_pupil/DATA_raw/';
fname_logs = '_SRCpredict'; % add PID prefix and .mat/.txt suffix later on
fname_out = 'P_Alln28.mat'; 
%logs are all in Pp
%folders.
% matdir = [dir_data, ppID , '.mat'];
% txtdir = [dir_data, ];

participants = {
                    'P01'
                    'P02'
                     'P03'
                     'P04' % - no eye data
                     'P05'
                     'P06' % - missing eeg/eye data
                     'P07'
                  %   'P08' %%% 20%+ missing RTs!
                     'P09' %- turned on late eeg recording missing (heart/flex data)
                     'P10'
                     'P11'
                     'P12'
                     'P13'
                     'P14'
                     'P15'
                  %   'P16'%%% 20%+ missing RTs!
                     'P17'
                     'P18' 
                     'P19' % no eeg recording (heart/flex data)
                     'P20'  %- missing data pupil/eye
                     'P21'
                     'P22'
                     'P23'
                     'P24'
                     'P25'
                     'P26'
                     'P27'
               %      'P28' %only ran 6 blocks. missing all data from last 4 include RT.
                     'P29'
                     'P30'
                     'P31'
    };

blockprob = [.1 .3 .5 .7 .9];


%% NOTES
% E.data - data matrix of entire session
% Columns of E: 1 = heartrate; 2 = flex; 3 = raw trigger signal; 4 =
% timestamps (in ms); 5 = single triggers; 6 = filtered data; 7 = IBI with
% NaNs; 8 = constant IBI;


%% IMPORT 'SIGNAL' DATA AND ADD TIMESTAMPS; CREATE SINGLE TIMEPOINT TRIGGERS


for pp = 1:length(participants)
   
    dir_logs = [dir_data, participants{pp} , filesep];   % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 
    %% LOAD MAT FILE INTO BLOCK STRUCTURE
    % cond key:
    % 12 - open/close mismatch
    % 21 - close/open mismatch
    % 22 - close/close match
    % 11 - open/open match
    disp(['Loading MAT file for: ' participants{pp}]);
    
     load([dir_logs , participants{pp}, fname_logs, '.mat']);
    trialn = 1;
    for bb = 1:10 %for each block
        for tt = 1:40 %for each trial
            P(pp).trial(trialn).probability=block(bb).match;
            P(pp).trial(trialn).cond=block(bb).trial(tt).cond;
            P(pp).trial(trialn).btrial=tt;
            P(pp).trial(trialn).block=bb;
            P(pp).trial(trialn).keyRT=block(bb).trial(tt).RT; % in ms with any early responses (less than 150ms) nanned
            trialn = trialn+1;
        end
    end
    P(pp).ID = participants{pp};
    
end

save(fname_out, 'P')


    
    
    