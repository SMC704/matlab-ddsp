ddsp_models = py.importlib.import_module('ddsp.training.models');
np = py.importlib.import_module('numpy');
gin = py.importlib.import_module('gin');
gin.unlock_config();
gin.parse_config_file('operative_config-0.gin', pyargs('skip_unknown', true));
model = ddsp_models.Autoencoder();
model.restore('ckpt-38100');

loudness = np.array(py.list({py.list({1})}));
f0 = np.array(py.list({py.list({440})}));
f0_conf = np.array(py.list({py.list({1})}));
feats = py.dict(pyargs('loudness_db',loudness,'f0_hz',f0,'f0_confidence',f0_conf));

b = model(feats, pyargs('training', false));
audio_gen = model.get_audio_from_outputs(b);
audio_np = audio_gen.numpy();
audio_matlab = double(py.array.array('d',py.numpy.nditer(audio_np)));
soundsc(audio_matlab(1:16000), 16000);