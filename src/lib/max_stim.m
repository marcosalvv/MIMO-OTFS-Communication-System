function [k_max_stim,l_max_stim] = max_stim(k_stim,l_stim,n_tx)
% Function that determines the maximum doppler and maximum delay among the k and l estiamted
k_vec = [];
l_vec = [];
for i = 1 : n_tx
    % Maximum value for the single cell of k_stim
    k_temp = k_stim{1,i};
    k_max = max(abs(k_temp));
    k_max = max(k_max);
    k_vec = [k_vec;k_max];
    % Maximum value for the single cell of l_stim
    l_temp = l_stim{1,i};
    l_max = max(l_temp);
    l_max = max(l_max);
    l_vec = [l_vec;l_max];
end
k_max_stim = max(k_vec);
l_max_stim = max(l_vec);
end

