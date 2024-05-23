function [g_i, k_i, l_i] = generate_channel_parameters(n_paths,l_max,k_max,n_rx,n_tx,mode)
% Function that generates channel parameters g_i, l_i, k_i

% TODO --> set a g_i minimum so that there are no replies that are too "low"
    
    % Generation of channel coefficients (Rayleigh fading) with uniform pdp
    g_i = sqrt(1/n_paths).*(sqrt(1/2) * (randn(n_paths,n_rx,n_tx)+1i*randn(n_paths,n_rx,n_tx)));
    % Standard generation of delay and doppler taps
    if mode == "normal"
        % Generation of delay taps uniformly from [0,l_max]
        l_i = randi([0,l_max],n_paths,n_rx,n_tx);
        l_i= l_i-min(l_i);
        % Generate Doppler taps (assuming uniform spectrum [-k_max,k_max])
        k_i = randi([-k_max,k_max],n_paths,n_rx,n_tx);
    % Generation of unique doppler and delay taps to prevent the overlap of two or more reply of the same pilot on the same receivers
    elseif mode =="unique"
        stop = 0;
        trial = 0;
        while stop == 0
            stop = 1;
            trial = trial+1;
            l_i = randi([0,l_max],n_paths,n_rx,n_tx);
            l_i= l_i-min(l_i);
            % Generation of Doppler taps (assuming uniform spectrum [-k_max,k_max])
            k_i = randi([-k_max,k_max],n_paths,n_rx,n_tx);
            for r = 1:n_rx
            for t = 1:n_tx
                arr = l_i(:,r,t);
                [~, w] = unique( arr, 'stable' );
                duplicate_indices = setdiff( 1:numel(arr), w );
                duplicate_check = ~isempty(duplicate_indices);
                if duplicate_check == 1
                    arr = l_i(:,r,t)-k_i(:,r,t);
                    [~, w] = unique( arr, 'stable' );
                    duplicate_indices = setdiff( 1:numel(arr), w );
                    duplicate_check = ~isempty(duplicate_indices);
                    if duplicate_check == 1
                        stop = 0;
                    end
                end
            end
            end
        end
    %disp(trial);
    end
end
