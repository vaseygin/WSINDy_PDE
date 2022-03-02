% ======================================================================
%> @brief Subsamples data U_obs and coordinates xs_obs according to coarsen_data
%>
%> @param xs_obs spatial locations of data as cell array of shape (1,D+1) so xs_obs{D} is grid points in last dimension D and xs_obs{D+1} is in time
%> @param U_obs Observed data as cell array with shape (1,n) for data with n state variables
%> @param coarsen_data Instructions on how to subsample, array of shape (D,3) coarsen_data(i,:) = [start_idx, increment, end_idx]
%> @param dims dimensions of single variable of U_obs (assumed all same shape)
%>
%> @retval xs_obs coarsened spatial grid
%> @retval U_obs coarsened data
% ======================================================================
function [xs_obs,U_obs] = subsamp(xs_obs,U_obs,coarsen_data,dims)
    if ~and(all(reshape(coarsen_data(:,1:2)==1,[],1)),...
            all(coarsen_data(:,end)==dims'))
        nstates = length(U_obs);
        dim = length(size(U_obs{1}));
        inds = cell(1,dim);
        for j=1:dim
            N = length(xs_obs{j});
            inds{j} = coarsen_data(j,1):coarsen_data(j,2):coarsen_data(j,3);
            xs_obs{j} = xs_obs{j}(inds{j});
        end
        for j=1:nstates
            U_obs{j} = U_obs{j}(inds{:});
        end
    end

end