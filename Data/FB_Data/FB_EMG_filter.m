% Import data and convert to array format
data_table = removevars(readtable('1.csv'));
data_table = [array2table(time2num(table2array(data_table(:,1)),"seconds")) data_table(:,2:4)];
data = table2array(data_table);

t = data(:,1);
emg = data(:,4);
fs = 1/(t(2)-t(1));
L = length(emg);

figure;

subplot(3,2,1)
mag = abs(fft(emg));
ff = (fs/L)*(0:L/2-1);
plot(ff', mag2db(movmean(mag(1:L/2),1)))
grid on
title("FFT of Raw EMG Data");
xlabel("freq (Hz)")
ylabel("mag (dB)");

subplot(3,2,2)
plot(t, emg);
grid on
title("Raw EMG Data")


% highpass directly modifies data
ftarget1 = 20;
[B1, A1] = butter(4, ftarget1/(0.5*fs), 'high'); % 4th order highpass filter
ftarget2 = 60;
Q = 60/(60.05-59.95);
[B3, A3] = iirnotch(ftarget2/(0.5*fs), (ftarget2/((0.5*fs)*Q)));
emg = filtfilt(B3, A3, emg);
emg_filt = filtfilt(B1, A1, emg);
emg_rect = abs(emg_filt);

ftarget3 = 1;
[B2, A2] = butter(4, ftarget3/(0.5*fs)); % 4th order lowpass filter
emg_smooth = filtfilt(B2, A2, emg_rect); 



%t_window = 1; % in seconds
%N = fs*t_window;
%emg_smooth=sliding_rms(emg_rect, N);

subplot(3,2,3)
mag = abs(fft(emg_filt));
ff = (fs/L)*(0:L/2-1);
plot(ff', mag2db(movmean(mag(1:L/2),1)))
grid on
title("FFT of Filtered EMG Data");
xlabel("freq (Hz)");
ylabel("mag (dB)");

subplot(3,2,4)
plot(t, emg_filt);
grid on
title("Filtered EMG Data")

subplot(3,2,5)
mag = abs(fft(emg_smooth));
ff = (fs/L)*(0:L/2-1);
plot(ff', mag2db(movmean(mag(1:L/2),1)))
grid on
title("FFT of Rectified and Smoothed EMG Data");
xlabel("freq (Hz)")
ylabel("mag (dB)");

subplot(3,2,6)
plot(t, emg_smooth);
grid on
title("Rectified and Smoothed EMG Data")

