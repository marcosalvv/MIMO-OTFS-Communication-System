function [k_max,l_max] = max_delay_doppler(k_i,l_i,n_tx)
% Definition of k_max and l_max among all paths

max_li_multi = max(l_i);
max_ki_multi = max(abs(k_i));
k_vector = [];
l_vector = [];
for t = 1 : n_tx
    k_test = max(max_ki_multi(:,:,t));
    l_test = max(max_li_multi(:,:,t));

    k_vector = [k_vector;k_test];
    l_vector = [l_vector;l_test];
end
k_max = max(k_vector);
l_max = max(l_vector);

end

