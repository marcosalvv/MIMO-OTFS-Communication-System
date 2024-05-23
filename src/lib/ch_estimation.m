function [path_stim,k_stim,l_stim,g_stim_abs,g_stim,Y_stim] = ch_estimation(N,M,n_rx,n_tx,Y,th,l_max,k_max,kp,lp_vec,xp)
Z = exp((2 * pi * 1j)/(N * M));
xp = xp*ones(1,n_tx);

% Logic Matrix
b = zeros(N,M,n_rx,n_tx);
abs_frame = zeros(N,M,n_rx);
for j_r = 1 : n_rx
    abs_frame(:,:,j_r) = abs(Y(:,:,j_r));
end

% Computation of b matrix
for i_r = 1 : n_rx
    for i_t = 1 : n_tx
        for elle = 0 : l_max
            for kappa = -k_max : k_max
                if abs_frame(kp+kappa,lp_vec(i_t)+elle,i_r) >= th
                    b(kp+kappa,lp_vec(i_t)+elle,i_r,i_t) = 1;
                end
            end
        end
    end
end

% Logic Matrix Indexes
idx_k = cell(n_rx,n_tx);
idx_l = cell(n_rx,n_tx);
for r = 1 : n_rx
    for t = 1 : n_tx
        [idx_k{r,t},idx_l{r,t}] = find(b(:,:,r,t)==1);
    end
end

% Estimated Number of Paths
path_stim = zeros(1,n_rx,n_tx);
for r = 1 :n_rx
    for t = 1 : n_tx
        path_stim(:,r,t) = sum(sum(b(:,:,r,t)));
    end
end
path_stim = max(max(path_stim));

% Estimated Gain
% Frame creation with the various gains at all points of the estimation of the "submatrix" (pointless?)
g_temp = zeros(N,M,n_rx);
for i_r = 1 : n_rx
    for i_t = 1 : n_tx
        for elle = 0 : l_max
            for kappa = -k_max : k_max
                g_temp(kp+kappa,lp_vec(i_t)+elle,i_r) = Y(kp+kappa,lp_vec(i_t)+elle,i_r)/(xp(i_t)*Z^(kappa*lp_vec(i_t)));
            end
        end
    end
end

% Gain Estimation (check)
g_stim = zeros(path_stim,n_rx,n_tx);
for r = 1 : n_rx
 for t = 1 : n_tx
    k_t = idx_k{r,t};
    l_t = idx_l{r,t};
    for a = 1 : path_stim
        g_stim(a,r,t) = g_temp(k_t(a),l_t(a),r);
    end
 end
end

% Estimated Gain (absolute value)
g_stim_abs = zeros(path_stim,n_rx,n_tx);
for r = 1 : n_rx
 for t = 1 : n_tx
    k_t = idx_k{r,t};
    l_t = idx_l{r,t};
    for a = 1 : path_stim
        g_stim_abs(a,r,t) = abs_frame(k_t(a),l_t(a),r)/xp(t);
    end
 end
end

% Delay Estimation
l_stim = zeros(path_stim,n_rx,n_tx);
for r = 1 : n_rx
    for t = 1 : n_tx
        l_t = idx_l{r,t};
        for a = 1 : path_stim
            l_stim(a,r,t) = l_t(a)-lp_vec(t);
        end
    end
end
% Doppler Estimation 
k_stim = zeros(path_stim,n_rx,n_tx);
for r = 1 : n_rx
    for t = 1 : n_tx
        k_t = idx_k{r,t};
        for a = 1 : path_stim
            k_stim(a,r,t) = k_t(a)-kp;
        end
    end
end
% Frame recreation
Y_stim = zeros(N,M,n_rx);
%g_stim_abs = abs(g_stim);
for r = 1 : n_rx
    for t = 1 : n_tx
        k_t = idx_k{r,t};
        l_t = idx_l{r,t};
        for a = 1 : path_stim
            Y_stim(k_t(a),l_t(a),r) = xp(t)*g_stim_abs(a,r,t);
        end
    end
end

end
