function [snrd, filtered_data] = process_raw_emg(data, fs, show_plot)
    L = length(data);
    if nargin < 3
        show_plot = false;
    end
    
    %% Step 1: Filter out DC and low-frequency noise (20Hz)
    [B_highpass, A_highpass] = butter(4, 20/(0.5*fs), 'high'); % 4th order highpass filter @ 20Hz
    data_filt = filtfilt(B_highpass, A_highpass, data);
    
    %% Step 2: Filter out artifacts
    
    % Frequency tolerances based on number of samples:
    tol = fs/L;
    fft_mag = abs(fft(data_filt));
    ff = tol*(1:L/2-1); % Only first half of data matters
    plot(ff, fft_mag(1:L/2-1));
    out = isoutlier(fft_mag(1:L/2-1), 'movmean', (L/2)/20);
    freqs = ff(out);
    for freq_index = 1:length(freqs)
        f = freqs(freq_index);
        if abs(f-60) <= 10*tol
            fprintf("Local spike at %8.4f Hz : Maybe Powerline Noise \n", f);
        else
            fprintf("Local spike at %8.4f Hz \n", f)
        end
        
    end 
    
    hold on
    plot(ff(out), fft_mag(out), 'o')
    %% Step 3: Rectify
    data_rect = abs(data_filt);
    
    %% Step 4: Find baseline magnitude to separate signal from noise
    [B_lowpass, A_lowpass] = butter(4, 1/(0.5*fs), 'low'); % 4th order lowpass filter @ 1Hz
    data_envelope = filtfilt(B_lowpass, A_lowpass, data_rect);
    
    baseline = rms(data_envelope);
    signal_indices = data_envelope > baseline;
    noise_indices = data_envelope < baseline;
    
    if show_plot
    
        figure;
        plot(data_rect, 'color', 'cyan')
        hold on
        plot(data_envelope, 'color', 'magenta')
        yline(baseline)
        legend(["Rectified Data","Data Envelope","Baseline"]);
    end
    snrd = rms(data_rect(signal_indices))^2/rms(data_rect(noise_indices))^2;
    filtered_data = data_filt;
end