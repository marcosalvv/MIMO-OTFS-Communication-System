function G = time_in_out(n_tx,n_rx,g_i,l_i,k_i,N,M,n_paths,l_max)
% Function that creates the input-ouput relations in the time domain

% Zero padding length
l_zp = l_max;
z = exp((2 * pi * 1i)/(N * M));
% Discrete-time equivalent channel (eq. 8.5)
g_bar = zeros(l_max+1,N*(M+l_zp),n_rx,n_tx); 
for r = 1 : n_rx
  for t = 1 : n_tx
    for q = 0 : N*(M+l_zp)-1
      for i = 1 : n_paths
    g_bar(l_i(i,r,t)+1,q+1,r,t) = g_bar(l_i(i,r,t)+1,q+1,r,t)+g_i(i,r,t)*z^((q-l_i(i,r,t))*k_i(i,r,t));        
      end
    end
  end
end

% Time domain channel matrix  (eq. 8.7)
G = zeros(N*M,N*M,n_rx,n_tx);
for r = 1 : n_rx
  for t = 1 : n_tx
    for n=0:N-1
      for m=0:M-1
        for elle=0:l_max
          if m>=elle
          G(m+n*M+1,m+n*M-elle+1,r,t)=g_bar(elle+1,m+n*M+l_zp+1,r,t);
          end
        end
      end
    end
  end
end

% % Delay-time MIMO channel matrix (eq. 8.9)
% G_mimo = zeros(N*M*n_rx,N*M*n_tx);
% for i = 1:n_rx
% for j = 1:n_tx
%     G_mimo(N*M*(i-1)+1:N*M*i,N*M*(j-1)+1:N*M*j) = G(:,:,i,j);
% end
% end

% % Transmitted symbol vectors (eq.8.10)
% x = reshape(pagetranspose(X),N*M,1,n_tx);
% s = P*kron(Im,Fn')*x;
% s_mimo = reshape(s,N*M*n_tx,1);
% % Concatenation of the z for each receiver
% w_mimo = reshape(w,N*M*n_rx,1);
% r_mimo = G_mimo*s_mimo+w_mimo;
end

