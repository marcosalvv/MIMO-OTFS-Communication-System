% MIMO-OTFS
% Matlab Code that generates a system model MIMO-OTFS with Nt transmitters and Nr receivers
% based on "Delay-Doppler Communications: Principles and Applications" by Yi Hong, Tharaj Thaj and Emanuele Viterbo
clc
clear
close all
addpath(genpath("lib"));

%% Parameters
% Number of transmitter
n_tx = 4;
% Number of receiver
n_rx = 4;
% Modulation size:
mod_size = 4;
% Number of propagation paths
n_paths=4;
% Maximum normalized delay and Doppler spread
l_max=4;
k_max=3;                        
% Number of Doppler bins (timeslots):
% Full Guard --> N = 6*k_max+2 (caso n_tx = 2)
N = (n_tx+1)*(2*k_max)+n_tx;                                
% Number of delay bins (subcarriers):
% Full Guard --> M >> 2*l_max+1
M = N+n_tx;
% Pilot gain
x_p = 15;    
% Random seed for reproducibility of results
seed = 45;   
%% Exe
rng(seed)
% Generate channel parameters
[g_i, k_i, l_i] = generate_channel_parameters(n_paths,l_max,k_max,n_rx,n_tx,"unique");
% AWGN vector in time domain
w = randn(N*M,1,n_rx)+randn(N*M,1,n_rx)*1i;

% Representation Delay-Doppler impulse channel response 
% h_dd = zeros(N,M,n_rx,n_tx);
% for r = 1 : n_rx
%   for t = 1 : n_tx
%     for i = 1 : n_paths
%     h_dd(k_i(i,r,t)+(N/2),l_i(i,r,t)+1,r,t) = g_i(i,r,t);
%     end
%   end
% end

% Frame Generation --> Embedded Pilot-Aided Frame 
[X,X_pf,X_df,l_p,k_p] = generate_frame_embedded(N,M,mod_size,n_tx,l_max,k_max,x_p);

% Frame Generation --> Fullguard (single-user)
%[X,X_pf,X_df] = generate_frame_fullguard(N,M,mod_size,n_tx,l_max,k_max);

% Delay-time input output
G = time_in_out(n_tx,n_rx,g_i,l_i,k_i,N,M,n_paths,l_max);
% Delay-Doppler input output
[Y,Y_pf,Y_df,H] = delay_doppler_in_out(X,X_pf,X_df,w,G,n_rx,n_tx);
% Channel Estimation
th = 8;             %Threshold channel estimation
% [path_stim,k_stim,l_stim,g_stim_abs,g_stim,Y_stim] = ch_estimation(N,M,n_rx,n_tx,Y_pf,th,l_max,k_max,k_p,l_p,x_p);

%% Plot
% Subplot dimensions
row_plot_tx = ceil(sqrt(n_tx)/2);
col_plot_tx = floor(sqrt(n_tx)*2);
row_plot_rx = ceil(sqrt(n_rx)/2);
col_plot_rx = floor(sqrt(n_rx)*2);


% % Plot channel response
for r = 1 : n_rx
     figure
     for t = 1 : n_tx
         subplot(row_plot_tx,col_plot_tx,t)
         grid on
         bar3(abs(h_dd(:,:,r,t)))
         ylabel('Doppler');
         xlabel('Delay');
         title("h_{dd}("+ r +"," + t +")")
     end
end
 
% % Plot input frames
% Plot Data + Pilot
figure
for t = 1 : n_tx
    subplot(row_plot_tx,col_plot_tx,t)
    grid on
    bar3(abs(X(:,:,t)));
    ylabel('Doppler');
    xlabel('Delay');
    title("Input Frame TX"+t);
end
% % Plot Pilot
figure
for t = 1 : n_tx
     subplot(row_plot_tx,col_plot_tx,t)
     grid on
     bar3(abs(X_pf(:,:,t)));
     ylabel('Doppler');
     xlabel('Delay');
     title("Input Pilot TX"+t);
end
% Plot Data
figure
for t = 1 : n_tx
     subplot(row_plot_tx,col_plot_tx,t)
     grid on
     bar3(abs(X_df(:,:,t)));
     ylabel('Doppler');
     xlabel('Delay');
     title("Input Data TX"+t);
end
 
% % Plot submatrices G
for r = 1 : n_rx
     figure
     for t = 1 : n_tx
         subplot(row_plot_tx,col_plot_tx,t)
         grid on
         bar3(abs(G(:,:,r,t)))
         ylabel('Time');
         xlabel('Delay');
         title("G_{"+r+t+"}");
     end
end
 
% % Plot submatrices H
for r = 1 : n_rx
     figure
     for t = 1 : n_tx
         subplot(row_plot_tx,col_plot_tx,t)
         grid on
         bar3(abs(H(:,:,r,t)))
         ylabel('Doppler');
         xlabel('Delay');
         title("H_{"+r+t+"}");
     end
end

% Plot degli output frames
% Output Data + Pilot
figure
for r = 1 : n_rx
    subplot(row_plot_rx,col_plot_rx,r)
    bar3(abs(Y(:,:,r)))
    grid on
    ylabel('Doppler');
    xlabel('Delay');
    title("Output Frame RX"+r);
end
% Output Pilot
figure
for r = 1 : n_rx
     subplot(row_plot_rx,col_plot_rx,r)
     bar3(abs(Y_pf(:,:,r)))
     grid on
     ylabel('Doppler');
     xlabel('Delay');
     title("Output Pilot RX"+r);
end
% Output Data
figure
for r = 1 : n_rx
     subplot(row_plot_rx,col_plot_rx,r)
     bar3(abs(Y_df(:,:,r)))
     grid on
     ylabel('Doppler');
     xlabel('Delay');
     title("Ouput Data RX"+r);
end

%Plot Estimation
for r = 1 : n_rx
     figure
     subplot(1,2,1)
     bar3(abs(Y_pf(:,:,r)))
     grid on
     ylabel('Doppler');
     xlabel('Delay');
     title("Ouput Frame RX"+r);
     subplot(1,2,2)
     bar3(abs(Y_stim(:,:,r)));
     grid on
     ylabel('Doppler');
     xlabel('Delay');
     title("Estimated Frame RX"+r);
end
