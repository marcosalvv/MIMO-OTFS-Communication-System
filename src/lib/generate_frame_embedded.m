function [X,X_pf,X_df,l_p,k_p] = generate_frame_embedded(N,M,mod_size,n_tx,l_max,k_max,x_p
% Function that generates an embedded Pilot-Aided frame for Channel Estimation of the MIMO-OTFS system (moderate doppler spread case)
% Frame structure based on the paper "Embedded Pilot-Aided Channel Estimation for OTFS in Delay–Doppler Channels"

    % Number of guard symbols in one frame
    Ng = (2*l_max+1)*(2*k_max)*n_tx - 1;  
    % Number of information symbols in one frame
    N_syms_per_frame = N*M-(Ng+n_tx);
    % Number of information bits in one frame
    N_bits_per_frame = N_syms_per_frame * log2(mod_size);
    % Generation of random bits
    tx_info_bits = randi([0,1], N_bits_per_frame, 1);
    % QAM modulation:
    % qammod -> QAM modulation on the signal tx_info_bits; M -> Number of bits per symbol (4->16QAM); 'InputType'-> signal in bit
    tx_info_symbols = qammod(tx_info_bits, mod_size, 'gray', 'InputType', 'bit');
    % Doppler tap of all pilots
    k_p = round(N/2);
    % Delay tap of the first pilot
    l_p1 = round(M/n_tx);  
    
    % Initialization
    % Delay tap for all pilot
    l_p = zeros(1,n_tx);
    % Frames with Data + Pilot
    X = zeros(N,M,n_tx);
    % Frames with only pilots
    X_pf = zeros(N,M,n_tx);
    % Frames with only data
    X_df = zeros(N,M,n_tx);
    % Boolean frames to mask the guard symbols from the data
    X_bool = true(N,M,n_tx);
    for t = 1 : n_tx
        % Delay tap for all pilot
        l_p(t) = l_p1+(t-1)*(l_max+1);
        % Boolean array to indicate the presence of guard symbols, on which information symbols must not be placed
        X_bool((k_p-2*k_max):(k_p+2*k_max),(l_p1-l_max):(l_p1+(n_tx*l_max)+n_tx-1),t) = false;
        % Place information symbols in the frame
        i_symb = 1;
        for j = 1:M
            for i = 1:N
                if X_bool(i,j,t)
                    X(i,j,t) = tx_info_symbols(i_symb);
                    i_symb = i_symb+1;
                end
            end
        end
        % Define a frame with only Data (optional)
        X_df(:,:,t) = X(:,:,t);
        % Define a frame with only the pilot (optional)
        X_pf(k_p,l_p(t),t) = x_p;
        % Place the pilot in the frame (data+pilot)
        X(k_p,l_p(t),t) = x_p;
    end
end
