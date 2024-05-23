function [X,X_pf,X_df] = generate_frame_fullguard(N, M, mod_size,n_tx,l_max,k_max)
% Generation of OTFS frames in Single-User MIMO case in fullguard mode

% Definition of k_max and l_max among all paths
% max_multi = max(abs(P_channel),[],2);
% k_vec = [];
% l_vec = [];
% for r = 1 : n_rx
%     for t = 1 : n_tx
%             k_test = max_multi(3,:,r,t);
%             l_test = max_multi(2,:,r,t);
% 
%             k_vec = [k_vec;k_test];
%             l_vec = [l_vec;l_test];
%     end
% end
% k_max = max(k_vec);
% l_max = max(l_vec);

% Number of guard symbols (replacing overhead definition (cap.7) into cap.8)
%Ng = (2*l_max+1)*(2*k_max)*n_tx - 1;        %moderate doppler spread channel estimation (book definition)
Ng = N*(1+2*l_max)-1;                        %fullguard

% Number of information symbols in one frame
N_syms_per_frame = N*M-(Ng+1);

% Number of information bits in one frame
N_bits_per_frame = N_syms_per_frame * log2(mod_size);

% Generation of random bits
tx_info_bits = randi([0,1], N_bits_per_frame, 1);
% tx_info_bits = [0; 0; 0; 1; 1; 1; 1; 0; 0; 0; 0; 1; 1; 1; 1; 0];

% QAM modulation:
%qammod -> QAM modulation onto signal tx_info_bits; M -> number of bits per symbol (4->16QAM); 'InputType'-> signal in bits
tx_info_symbols = qammod(tx_info_bits, mod_size, 'gray', 'InputType', 'bit');

% Generation of Empty Frames (one for each TX)
% X -> Data + Pilot
X = zeros(N,M,n_tx);
% PF -> Pilot
X_pf = zeros(N,M,n_tx);
% DF -> Data
X_df = zeros(N,M,n_tx);
% Pilots separated by 2*k_max (same delay) -> moderate spread case
np = zeros(n_tx,1);
np_temp = 0;
for t = 1 : n_tx
    % Pilot placement
    mp = round(M/2);
    % np(t) = np_temp+2*k_max+1;
    np(t) = np_temp+2*k_max+1;
    np_temp = np(t); 
    X(np(t),mp,t) = 15*t;                         %15*t arbitrary value
    X_pf(np(t),mp,t) = 15*t;
    % Data placement
    symb1 = tx_info_symbols(1:N*(mp-l_max-1));              
    X(:,1:mp-l_max-1,t) = reshape(symb1, N, mp-l_max-1);      %left part of frame (data)
    X_df(:,1:mp-l_max-1,t) = reshape(symb1, N, mp-l_max-1);
    symb2 = tx_info_symbols(N*(mp-l_max-1)+1:(N*M)-Ng-1);
    X(:,mp+l_max+1:M,t) = reshape(symb2,N,[]);                %right part of frame (data)
    X_df(:,mp+l_max+1:M,t) = reshape(symb2,N,[]);
end
end

