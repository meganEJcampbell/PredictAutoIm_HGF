# PredictAutoIm_HGF
This repo includes the analysis code for an experiment on automatic imitation behaviour under different conditions of predictability. Analysis focuses on computational modelling of precision weighted learning to provide insight into the behavioural effects (reaction time differences between congruent and incongruent trials), and comparing Rescorla-Wagner (RW) to hierachical perceptual-response models that incorporate beliefs about levels of uncertainty (Hierachical Gaussain Filter). HGF implemented with TAPAS toolbox: see https://github.com/translationalneuromodeling/tapas 

For the experimental paradigm task scripts see: PredictAutoIm_Exptask :-) 

## Analysis scripts: summary statistics on reaction time and modelling on log-change-in-reaction time 
  1) MATLAB2018+  2) TAPAS toolbox version, HGF version 5-3 used for RW and HGF  3) SPM12 for smp_bms "bayesian model selection" used in An1_HGF2_model_comparision.m
  
SRC1_data... .m = data prep: going from raw log files, to raw RT checked for missing trials, and trial orders, to delata-logRT as inputs for HGF/RW.
with the extractAll_RTdata.zip = directory where these scripts were run with the outputs for summary data scripts (but not raw log files) = .mat and .txt files and .png / .fig for figures
