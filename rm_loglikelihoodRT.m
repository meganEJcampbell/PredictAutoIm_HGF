function value_out = rm_loglikelihoodRT(RT,latentvalue,params, inputs, offset, generate)

%"value_out" depends on whether you select 'generate' or not. 
%   If 'generate' is on you'll get a vector with 'generated' RT estimated based on the Drift Difussion model herein
%   If 'generate' is off, you'll just get back the minimised parameters.

% "RT" is a 400-vector of response times (in secs). Not log response times.
% "latentvalue" is a 400-vector of the RW model's latent value. I assume it's zero-centred, so that it takes values between -1 and +1.
% "params" is a cell array with elements:
%    params.v = mean drift rate.
%    params.b = threshold for response.
%    params.k = link between latent value (perceptual model) and accumulator.
%    params.minT = offset of the RT distribution from zero, for motor time.
% "inputs" = u in hgf world but 1 = match, -1 = mismatch


 % SB: This is the link from percep model to the RT. At the moment, it is a very simple link based on the idea that stronger
 % expectations lead to faster drift rates. We can explore others easily, after we make this work.
           
trialdriftrate = (params.v + params.k .* (latentvalue) .* inputs); 

% % ! need trial specific detail for experiment... faster or slower dependant on the expectation/certaintiy about
% wants happening %%% - MB: the trial-drift rate should be smaller - how to do this? First go brute force hard-code it to be lower...

mu = params.b ./ trialdriftrate;  %%%% <<<<< 
lambda = params.b.^2;

if ~generate  %if 0 not gonna generate RT data but will return minimised parameters
    densities = pdf('InverseGaussian', RT-params.minT, mu, lambda);
   % vector_out =  densities;

% ~generate  %if 0 not gonna generate RT data
    
    densities(isnan(RT)) = 0;
    % Model the data as  mixture between the real RT model (above)
    % and a uniform random response on the interval [0,5sec] (say).
    % This is important to deal with a problem related to estimating
    % distributions with a parameter-dependent lower bound, using ML.
    %densities = 0.95.*densities + 0.05 .* (1) ; % catch the bollocks . 
     densities = 0.95.*densities + offset .* (1) ; % catch the bollocks . %<<<<<<<< add back this make this a variable 'offset = 0.05' 

    % Return the sum of the log densities.
    value_out = -(log(sum(densities)));
    disp('LL =')
    disp(value_out)
    disp(params)
    
    
else %if we want to generate data
    densities = random('InverseGaussian', mu, lambda) + params.minT;
    value_out =  densities +offset; % Generated RTs 



end

%