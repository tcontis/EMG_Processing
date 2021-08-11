function snr_est = estimate_snr(data, fs, show_plot)
    % estimate_snr.m Estimates signal-to-noise ratio from data using
    % thresholding of the data envelope
    % Inputs:
    %   data        : Desired data for which to estimate snr
    %   fs          : Frequency in Hz at which data was sampled
    %   show_plot   : If true, shows rectified data, baseline, and data
    %                 envelope used for thresholding
    % Outputs:
    %   snr_est     : Estimated SNR
    
    % If only two arguments supplied, assume user does not want plot
    if nargin < 3
        show_plot = false;
    end
    
    %% Remove DC component from data anad rectify
    [B_highpass, A_highpass] = butter(4, 1/(0.5*fs), 'high'); % 4th order highpass filter @ 1Hz
    data_filt = filtfilt(B_highpass, A_highpass, data);
    data_rect = abs(data_filt);
    %% Find baseline magnitude to separate signal from noise
    [B_lowpass, A_lowpass] = butter(4, 1/(0.5*fs), 'low'); % 4th order lowpass filter @ 1Hz
    data_envelope = filtfilt(B_lowpass, A_lowpass, data_rect);
    
    % Use thresholding of envelope to determine signal and noise
    baseline = rms(data_envelope);
    signal_indices = data_envelope > baseline;
    noise_indices = data_envelope < baseline;
    
    snr_est = rms(data_rect(signal_indices))^2/rms(data_rect(noise_indices))^2;
    
    if show_plot
        figure;
        plot(data_rect, 'color', 'cyan')
        hold on
        plot(data_envelope, 'color', 'magenta')
        yline(baseline, 'color', 'black')
        legend(["Rectified Data","Data Envelope","Baseline"])
        title("SNR Estimate: " + snr_est);
        ylabel("Magnitude (V)")
        xlabel("Time (s)")
    end
end

