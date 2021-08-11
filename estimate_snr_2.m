function snr_est = estimate_snr_2(data, fs, show_plot)
    % estimate_snr_2.m Estimates signal-to-noise ratio from data using
    % data envelope as estimate of the signal
    % Inputs:
    %   data        : Desired data for which to estimate snr
    %   fs          : Frequency in Hz at which data was sampled
    %   show_plot   : If true, shows rectified data, baseline, and data
    %                 envelope used for thresholding
    % Outputs:
    %   snr_est     : Estimated SNR, magnitude (NOT dB)
    
    % If only two arguments supplied, assume user does not want plot
    if nargin < 3
        show_plot = false;
    end
    
    %% Remove DC component from data and rectify
    [B_highpass, A_highpass] = butter(4, 1/(0.5*fs), 'high'); % 4th order highpass filter @ 1Hz
    data_filt = filtfilt(B_highpass, A_highpass, data);
    data_rect = abs(data_filt);
    %% Find baseline magnitude to separate signal from noise
    [B_lowpass, A_lowpass] = butter(4, 1.5/(0.5*fs), 'low'); % 4th order lowpass filter @ 1.5Hz
    data_envelope = filtfilt(B_lowpass, A_lowpass, data_rect);
    
    % data = signal + noise;
    signal_est = data_envelope;
    noise_est = data_rect - data_envelope; % Noise = Data - Signal
    snr_est = db2mag(snr(signal_est, noise_est));
    
    if show_plot
        figure;
        plot(data_rect, 'color', 'red')
        hold on
        plot(noise_est, 'color', 'blue')
        plot(signal_est, 'color', 'green', 'LineWidth', 2)
        legend(["Rectified Data","Noise Estimate", "Signal Estimate",])
        title("SNR Estimate: " + snr_est);
        ylabel("Magnitude (V)")
        xlabel("Time (s)")
    end
end