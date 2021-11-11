function output_value = rm_chooseparams2minise(minstuff, RT,latentvalue, inputs, offset, generate)
%%% function to select out the bits we want to minimise with the
%%% loglikelihood function
% minstuff = parameters we want to minimise 
% latentvalue = parameter from perceptual model 
% inputs = SRC variable but made so 1 is match, and mismatch is -1
% generate is logicial to either generate estimates of RT or to search for minimised parameters
params.v = minstuff(1); %= mean drift rate.
params.k = minstuff(2); %= link between perceptual model 'laten value' and accumulator.
params.b = 1; %= threshold for response.  %<<<<<< maybe play with this; the amount of evidence needed depends on the 'uncertainty' 
params.minT = 0.2; %= offset of the RT distribution from zero, for motor time. was on 0.15;
% 205ms is a lowerbound from the real data taking all means for 2x5
% factorial and setting 

output_value = rm_loglikelihoodRT(RT,latentvalue,params,inputs, offset, generate);
end


