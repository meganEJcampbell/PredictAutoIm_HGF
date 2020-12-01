# PredictAutoIm_HGF
This repo includes the analysis code for an experiment on automatic imitation behaviour under different conditions of predictability. Analysis focuses on computational modelling of precision weighted learning to provide insight into the behavioural effects (reaction time differences between congruent and incongruent trials), and comparing Rescorla-Wagner (RW) to hierachical perceptual-response models that incorporate beliefs about levels of uncertainty (Hierachical Gaussain Filter). HGF implemented with TAPAS toolbox: see https://github.com/translationalneuromodeling/tapas 

For the experimental paradigm task scripts see: "PredictAutoIm_Exptask" :-) 
The dataset of reaction times from a study using this task with 28 healthy adult participants is available as a matlab file in this repository in the extractAll_RTdata.zip 


## Analysis scripts: perceptual/learning models on log-reaction time 
Requires:
  1) MATLAB2018+  
  2) TAPAS toolbox version, HGF version 5-3 used for RW and HGF  
  3) SPM12 for spm_bms "bayesian model selection" used in An1_HGF2_model_comparision.m
  
Two sets of scripts here:
1) SRC1_data*.m = data prep. Starting from raw log files, to raw RT checked for missing trials, and trial orders, to logRT as inputs for HGF/RW.
* Output provided in 'extractAll_RTdata.zip'; the directory where these scripts were run with the outputs for summary data scripts (but not raw log files)
The file 'P_Alln28.mat' contains a structure 'P' with fields 'trial' and 'ID' for each participant. Within 'trial' there is the details of each trial: 'probabilty', 'cond', 'btrial', 'block', 'keyRT' (see the task scripts for definition of these trial variables).
The reaction times from this trial log structure have been organised as matrices of 'responses' and 'inputs' for entering into the HGF within the file 'data_n28.mat'. 

2) An1_HGF*.m = HGF modelling
   An1_RW1_setup_modelfit.m = Rescorla-Wagner
   An2_*.m = model comparision and evidence

* Output for the analysis run on the data referenced above (see 'data_n28.mat') is in the 'run_HGFv5-3_n28_logRT.zip' subject-wise outputs includes .fig of individual's parameter trajectories across trials.


