function [Y,Y_pf,Y_df,H] = delay_doppler_in_out(X,X_pf,X_df,w,G,n_rx,n_tx)
    % Function that applies OTFS input-output relations for the MIMO case

    % Dimensions of the frame X
    N = size(X, 1);
    M = size(X, 2);
    
    % Identity Matrix:
    Im = eye(M);
    % FFT Matrix:
    Fn = dftmtx(N);
    Fn = Fn/norm(Fn);
    % Permutation Matrix   (4.33):
    P = interleaver_matrix(M,N);
     
     % Delay-Doppler channel matrix (eq. 8.14)
    H = kron(Im,Fn);
    H = pagemtimes(H,pagemtimes(pagemtimes(P.',G),P));
    H = pagemtimes(H,kron(Im,Fn'));
    % AWGN vector in Delay-Doppler (eq. 8.15)
    z = pagemtimes(kron(Im,Fn),pagemtimes(P.',w));
    % Transmitted symbol vectors (eq.8.10)
    x = reshape(X,N*M,1,n_tx);
    x_pf = reshape(X_pf,N*M,1,n_tx);
    x_df = reshape(X_df,N*M,1,n_tx);
    % Concatenation of the x for each transmitter
    x_mimo = reshape(x,N*M*n_tx,1);
    x_pf_mimo = reshape(x_pf,N*M*n_tx,1);
    x_df_mimo = reshape(x_df,N*M*n_tx,1);
    % Delay-Doppler MIMO channel matrix (eq. 8.16)
    H_mimo = zeros(N*M*n_rx,N*M*n_tx);
    for i = 1:n_rx
      for j = 1:n_tx
        H_mimo(N*M*(i-1)+1:N*M*i,N*M*(j-1)+1:N*M*j) = H(:,:,i,j);
      end
    end
    % Concatenation of the z for each receiver
    z_mimo = reshape(z,N*M*n_rx,1);
    % Concatenation of the y for each receiver (eq. 8.16)
    y_mimo = H_mimo*x_mimo+z_mimo;
    y_pf_mimo = H_mimo*x_pf_mimo+z_mimo;
    y_df_mimo = H_mimo*x_df_mimo+z_mimo;
    
    % Received symbol vectors (eq. 8.17)
    y = reshape(y_mimo,N*M,n_rx);
    y_pf = reshape(y_pf_mimo,N*M,n_rx);
    y_df = reshape(y_df_mimo,N*M,n_rx);
    % Determine the output frames
    Y = zeros(N,M,n_rx);
    Y_pf = zeros(N,M,n_rx);
    Y_df = zeros(N,M,n_rx);
    for r = 1 : n_rx
        Y(:,:,r) = reshape(y(:,r),N,M);
        Y_pf(:,:,r) = reshape(y_pf(:,r),N,M);
        Y_df(:,:,r) = reshape(y_df(:,r),N,M);
    end
end
