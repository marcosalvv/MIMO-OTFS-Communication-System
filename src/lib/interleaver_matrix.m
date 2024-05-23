function P = interleaver_matrix(M,N)
% Function that determines the row-column interleaver matrix P (eq. 4.33)

    P=zeros(N*M,N*M);
    for j=1:N
        for i=1:M
            E=zeros(M,N);
            E(i,j)=1;
            P((j-1)*M+1:j*M,(i-1)*N+1:i*N)=E;
        end
    end
end
