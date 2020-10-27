fs = 44100;
T = 1;
f0 = ones(fs * T, 1) * 440;
amplitudes = logspace(1, 0.001, fs*T)';


n_frequencies = 100;
n_frames = 100;
low_mag = 0;
high_mag = 127;

window_size = 257;

midictrl = mididevice('VMini');
while true
    msgs = midireceive(midictrl);
    for i=1:numel(msgs)
        msg = msgs(i);
        type = msg.Type;

        if type == midimsgtype.NoteOn && msg.Velocity > 0
            vel = msg.Velocity;
            note = msg.Note;
            
            freq = note2freq(note);
            f0 = ones(fs * T, 1) * freq;
            harmonics = make_harmonics(n_harmonics, fs, T);
            add_sound = additive(fs * T, fs, amplitudes, harmonics, f0);
            magnitudes = make_magnitudes(low_mag, high_mag, n_frames, n_frequencies);
            sub_sound = subtractive(fs * T, window_size, magnitudes)' * noisesc;
            soundsc(add_sound + sub_sound(1:fs * T), fs);
        elseif type == midimsgtype.ControlChange
            knob = msg.CCNumber;
            val = msg.CCValue; 
            
            if knob == 14
                n_harmonics = ceil(val / 5) + 1;
            elseif knob == 15
                noisesc = val / 127;
            elseif knob == 16
                low_mag = val;
            elseif knob == 17
                high_mag = val;
            end
        end
    end
end

function harms = make_harmonics(n_harmonics, fs, T)
    harms = repmat(linspace(300, 0, n_harmonics), fs*T, 1);
    harms(:, 1) = 250;
    if n_harmonics >= 8
        harms(:, 8) = 250;
    end
end

function mags = make_magnitudes(mag_low, mag_high, n_frames, n_frequencies)
    
    magnitudes = zeros(n_frames, n_frequencies);
    filterbands = linspace(mag_low, mag_high, n_frames);
    for i=1:n_frames
        magnitudes(i, :) = sin(linspace(0, filterbands(i), n_frequencies));
    end

    mags = 0.5 * magnitudes.^4.0;
end

function freq = note2freq(note)
    freqA = 440;
    noteA = 69;
    freq = freqA * 2.^((note-noteA)/12);
end