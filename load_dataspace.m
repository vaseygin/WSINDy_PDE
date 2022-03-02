function [s_x, s_t, phi_class, tau, tauhat, toggle_scale, ...
    max_dx, max_dt, polys, trigs, use_all_dt, use_cross_dx, ...
    custom_add, custom_remove] = load_dataspace(filename, xs_obs)

    load(filename);

    %---------------- weak discretization

    % THESE (provided by .mat) GET OVERWRITTEN BY findcorners
    % m_x = min(10,floor((length(xs_obs{1})-1)/2));
    % m_t = min(10,floor((length(xs_obs{end})-1)/2));
    
    % If variable not loaded from .mat, use default values
    if ~exist('s_x','var')
        disp("Default x_s being used")
        s_x = max(floor(length(xs_obs{1})/25),1);
    end
    if ~exist('s_t','var')
        disp("Default x_t being used")
        s_t = max(floor(length(xs_obs{end})/25),1);
    end
    if ~exist('phi_class','var')
        disp("Default phi_class being used")
        phi_class = 1;
    end
    if ~exist('tau','var')
        disp("Default tau being used")
        tau = 10^-10;
    end
    if ~exist('tauhat','var')
        disp("Default tauhat being used")
        tauhat = 2; 
    end
    if ~exist('toggle_scale','var')
        disp("Default toggle_scale being used")
        toggle_scale = 2;
    end

    %---------------- model library

    % These are the default values enforced in load_dataspace
    if ~exist('max_dx','var')
        disp("Default max_dx being used")
        max_dx = 6;
    end
    if ~exist('max_dt','var')
        disp("Default max_dt being used")
        max_dt = 1;
    end
    if ~exist('polys','var')
        disp("Default polys being used")
        polys = 0:6;
    end
    if ~exist('trigs','var')
        disp("Default trigs being used")
        trigs = [];
    end
    if ~exist('use_all_dt','var')
        disp("Default use_all_dt being used")
        use_all_dt = 0;
    end
    if ~exist('use_cross_dx','var')
        disp("Default use_cross_dx being used")
        use_cross_dx = 0;
    end
    if ~exist('custom_add','var')
        disp("Default custom_add being used")
        custom_add = [];
    end
    if ~exist('custom_remove','var')
        disp("Default custom_remove being used")
        custom_remove = [];
    end
end