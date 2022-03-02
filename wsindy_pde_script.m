%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; 
clear all; 
close all;

% Select pde data to load
% 1: Inviscid Burgers
% 2: Korteweg-de Vries
% 3: Kuramoto Sivashinsky
% 4: Nonlinear Schrodinger’s
% 5: Sine-Gordon (available on request)
% 6: Reaction-diffusion system (available on request)
% 7: 2D Navier-Stokes (available on request)
% 8: ??????????
pde_num = 1;
pde_names = {'burgers.mat','KdV.mat','KS.mat','NLS.mat',...
             'Sine_Gordon.mat','rxn_diff.mat','Nav_Stokes.mat',...
             'porous.mat'};
load(['datasets/',pde_names{pde_num}])

U_obs = U_exact;
xs_obs = xs;
dims = size(U_obs{1});
dim = length(dims);
n = length(U_obs);

%% Subsample data (if desired)

coarsen_data = [ones(dim,2) dims']; 
% coarsen_data(:,2) = 2;
%%% set row d to [i inc f] to subsample dth coordinate to start at index i,
%%% end at index f, and skip every inc gridpoint. e.g:
%%% coarsen_data(:,2) = 2; coarsens spatiotemporal grid by factor of 2 in each coordinate

[xs_obs,U_obs] = subsamp(xs_obs,U_obs,coarsen_data,dims);
% Get updates dimensions of observed data
dims = cellfun(@(x) length(x), xs_obs);

%% Add noise

sigma_NR = 0.5;         % signal-to-noise ratio
noise_dist = 0;         % 0 = white noise, 1 = uniform
noise_alg = 0;          % 0 = additive noise, 1 = multiplicative noise
rng('shuffle');
rng_seed = rng().Seed;
 
rng(rng_seed);
[U_obs,noise,snr,sigma] = gen_noise(U_obs,sigma_NR,noise_dist,noise_alg,rng_seed,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set hyperparameters 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------- weak discretization

% m_x = 20;
% m_t = 12;
s_x = floor(length(xs{1})/50);
s_t = floor(length(xs{end})/50);
phi_class = 1;
tau = 10^-10;
tauhat = 0;
toggle_scale = 2;

%---------------- regularized least squares solve

lambda = 10.^(linspace(-4,0,50));
gamma = 0;

%---------------- model library

% max_dx = 4;
% max_dt = 1;
% polys = 0:3;
% trigs = [1];
% use_all_dt = 0;
% use_cross_dx = 0;
% 
% true_nz_weights={[]}; 
% lhs= [1 0 0 2];
% custom_add = [];
% custom_remove = [];

%---------------- find test function hyperparameters from tau,tauhat

if tauhat >0
    [m_x,m_t,p_x,p_t,sig_est,corners_all] = findcorners(U_obs,xs,tau,tauhat,max_dx,max_dt,phi_class);
    tols = [-p_x -p_t];
else
    tols = [tau tau];
end

%% Find dynamics

[W,G,b,M,lambda_hat, tags_pde_G,lib_list_G, true_nz_weights,resid,dW,its_all,thrs_EL,ET_wsindy,tags_pde,lib_list,pdx_list,lhs_ind, Cfs_x,Cfs_t,dx,dt,p_x,p_t,sub_inds,scales,M_full,Theta_pdx] = ... 
    wsindy_pde_fun(U_obs,xs,lambda,gamma,true_nz_weights,lhs,max_dx,max_dt,polys,trigs,custom_add,custom_remove,use_all_pt,use_cross_dx,...
                    toggle_scale,m_x,m_t,s_x,s_t,tols,phi_class);

%% Display results

print_loc = 1;
toggle_plot_basis_fcn = 1; 
toggle_plot_sol = 1; 
toggle_plot_loss = 1; 

if print_loc~=0
    print_results(W,G,resid,dW,print_loc,dims,polys,trigs,max_dx,max_dt,lambda_hat,gamma,lhs_ind,tags_pde,m_x,m_t,p_x,p_t,s_x,s_t,scales,ET_wsindy,its_all)
end

if toggle_plot_basis_fcn
    figure(1);
    plot_basis_fcn(Cfs_x,Cfs_t,m_x,dx,m_t,dt,max_dx,max_dt,pdx_list,[],scales(end-nstates:end));
end

if and(toggle_plot_sol,dim==2)
    figure(2);clf;set(gcf,'units','normalized','outerposition',[0.4 0 0.3 0.45])
    surf(xs{1},xs{2},U_obs{1}', 'EdgeColor','none')
    view([15 55])
    xlabel('$x$','interpreter','latex','fontsize',14)
    ylabel('$t$','interpreter','latex','fontsize',14)
    set(gca, 'TickLabelInterpreter','latex','fontsize',14)
end

if length(lambda)>1 && toggle_plot_loss
    figure(3);clf;set(gcf,'units','normalized','outerposition',[0.7 0 0.3 0.45])
    loglog(thrs_EL(2,:),thrs_EL(1,:),'o-')
    xlabel('$\lambda$','interpreter','latex','fontsize',14)
    ylabel('$\mathcal{L}$','interpreter','latex','fontsize',14)
    set(gca, 'TickLabelInterpreter','latex','fontsize',14)
end
