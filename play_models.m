MODEL = 'violin';
fs = 44100;
buffer_size = 10000;

MIDIA0 = 21;
MIDIC8 = 108;

config_file = strcat('models/', MODEL, '/operative_config-0.gin');
ckpt = strcat('models/', MODEL, '/ckpt');

ddsp_models = py.importlib.import_module('ddsp.training.models');
np = py.importlib.import_module('numpy');
gin = py.importlib.import_module('gin');
gin.unlock_config();
gin.parse_config_file(config_file, pyargs('skip_unknown', true));
model = ddsp_models.Autoencoder();
model.restore(ckpt);

loudness = np.array(py.list({py.list({1})}));
f0 = np.array(py.list({py.list({1000})}));
f0_conf = np.array(py.list({py.list({1})}));
feats = py.dict(pyargs('loudness_db',loudness,'f0_hz',f0,'f0_confidence',f0_conf));

n_harmonics = 60;
notes_playing = zeros(MIDIC8, 1);
phases = zeros(MIDIC8, n_harmonics);


midictrl = mididevice('VMini');

disp('Starting Loop');
while true
    msgs = midireceive(midictrl);
    for i=1:numel(msgs)
        msg = msgs(i);
        type = msg.Type;
        if type == midimsgtype.NoteOn && msg.Velocity > 0
            notes_playing(msg.Note) = true;
            phases(msg.Note, :) = 0;
        elseif type == midimsgtype.NoteOff
            notes_playing(msg.Note) = false;
        end
    end
    
    sound_acc = zeros(buffer_size, 1);
    current_notes = find(notes_playing);
    for i=1:numel(current_notes)
        note = current_notes(i);
        freq = note2freq(note);
        f0 = np.array(py.list({py.list({freq})}));
        loudness = np.array(py.list({py.list({1})}));
        feats = py.dict(pyargs('loudness_db',loudness,'f0_hz',f0,'f0_confidence',f0_conf));
        b = model(feats, pyargs('training', false));
        
        % plug generated controls back into python synth
        %audio_gen = model.get_audio_from_outputs(b);
        %audio_python = nparray2mat(audio_gen.numpy());
        
        amps = nparray2mat(b{'amps'}.numpy());      
        harmonics = squeeze(nparray2mat(b{'harmonic_distribution'}.numpy()));
        magnitudes = squeeze(nparray2mat(b{'noise_magnitudes'}.numpy()));
        f0_hz = squeeze(nparray2mat(b{'f0_hz'}.numpy()));
        [add_sound, phase] = additive(buffer_size, fs, amps', harmonics, f0_hz', phases(note, :));
        phases(note, :) = phase;
        sub_sound = subtractive(buffer_size, 10, magnitudes);
        sound_acc = sound_acc + add_sound + sub_sound(1:buffer_size)';
    end
    soundsc(sound_acc, fs);
end

function freq = note2freq(note)
    freqA = 440;
    noteA = 69;
    freq = freqA * 2.^((note-noteA)/12);
end


