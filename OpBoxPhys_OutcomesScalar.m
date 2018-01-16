function [summary] = OpBoxPhys_OutcomesScalar(psdx, freqs)

% % Summary values based on PowerSpec
% percentile = 0.95;
% [edge_freq, freqs, psd_data] = SpectralEdgeFreq(data.analog', data.Fs, percentile);
% summary.edge_freq = edge_freq;

[freq_bands] = EEGFreqBands();
band_names = fieldnames(freq_bands);

% sum_psd = sum(psd_data);

for i_band = 1:numel(band_names)
    band_name = band_names{i_band};
    freq_min = freq_bands.(band_name)(1);
    freq_max = freq_bands.(band_name)(end);
    
    mask_freqs = freq_min < freqs & freqs <= freq_max;
    
    summary.(band_name) = sum(psdx(mask_freqs));
end
summary.total = sum(psdx);

summary.delta_total = summary.delta ./ summary.total;
summary.deltatheta_alphabeta = (summary.delta + summary.theta) ./ (summary.alpha + summary.beta);
summary.deltatheta_gamma = (summary.delta + summary.theta) ./ summary.gamma;
summary.deltatheta = summary.delta + summary.theta;
summary.deltathetaalpha = summary.delta + summary.theta + summary.alpha;
summary.betagamma = summary.beta + summary.gamma + summary.high_gamma;
summary.deltathetaalpha_beta = summary.deltathetaalpha ./ summary.beta;
summary.deltathetaalpha_gamma = summary.deltathetaalpha  ./ (summary.gamma + summary.high_gamma);
summary.deltathetaalpha_lowgamma = summary.deltathetaalpha  ./ summary.gamma;
summary.deltathetaalpha_betagamma = summary.deltathetaalpha ./ summary.betagamma;
summary.deltathetaalphabeta_gamma = (summary.delta + summary.theta + summary.alpha + summary.beta) ./ (summary.gamma + summary.high_gamma);

% summary.psdx = psdx;
% summary.freqs = freqs;
