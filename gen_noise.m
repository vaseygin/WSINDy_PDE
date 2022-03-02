% ======================================================================
%> @brief  Add noise to data per variable in U_exact
%>
%> @param U_exact Observed data as cell array with shape (1,n) for data with n state variables
%> @param sigma_NR desired signal-to-noise ratio
%> @param noise_dist Either 0 or 1. 0 = white noise, 1 = uniform
%> @param noise_alg Either 0 or 1. 0 = additive noise, 1 = multiplicative noise 
%> @param rng_seed seed for the MATLAB random number generator
%> @param toggle_disp if true print info about noise
%>
%> @retval U_obs cell array with new data with added noise
%> @retval noise cell array of noise added to original U_exact
%> @retval snr resulting signal-to-noise ratio
%> @retval sigma variance of nosie SHOULD THIS BE A CELL ARRAY?
% ======================================================================
function [U_obs,noise,snr,sigma] = gen_noise(U_exact,sigma_NR,noise_dist,noise_alg,rng_seed,toggle_disp)

    n = length(U_exact);
    rng(rng_seed);

    if sigma_NR>0
        U_obs = cell(n,1);
        stdvs = zeros(1,n);
        noise = cell(1,n);
        snr = zeros(1,n);
        % Introduce noise per variable 
        for k=1:n
            stdvs(k) = rms(U_exact{k}(:))^2;
        end
        for j=1:n
            [U_obs{j},noise{j},snr(j),sigma] = add_noise(U_exact{j},stdvs(j),sigma_NR,noise_dist,noise_alg);
            if toggle_disp
                disp(['[SNR sigma] = ',num2str([snr(j) sigma])]); 
            end
        end
    else
        U_obs = U_exact;
        noise = [];
        snr = 0;
        sigma = 0;
    end

end

% ======================================================================
%> @brief Add noise to data in given variable U_exact
%>
%> @param U_exact Observed data of single variable in time
%> @param stdev standard deviation of noise
%> @param noise_dist Either 0 or 1. 0 = white noise, 1 = uniform
%> @param noise_alg Either 0 or 1. 0 = additive noise, 1 = multiplicative noise
%>
%> @retval U U_exact with noise
%> @retval noise noise added to U_exact
%> @retval snr resulting signal-to-noise ratio
%> @retval sigma variance of noise
% ======================================================================
function [U,noise,snr,sigma] = add_noise(U_exact,stdv,sigma_NR,noise_dist,noise_alg)

    dims = size(U_exact);
    if noise_dist == 0 % white noise
        sigma = sigma_NR*sqrt(stdv);
        noise = normrnd(0,sigma,dims);
    elseif noise_dist == 1 % uniform noise
        sigma = (3*sigma_NR^2*stdv)^(1/2);
        noise = 2*sigma*rand(dims)-sigma;
    end    
    if noise_alg == 0 % additive
        U = U_exact + noise;
    elseif noise_alg == 1 % multiplicative
        U = U_exact.*(1 + noise);
    end
    snr = norm(U(:)-U_exact(:))/norm(U_exact(:));
    
end