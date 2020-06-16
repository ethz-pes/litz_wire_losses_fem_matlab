function run_comsol()

close('all')
addpath('utils')

% param
I_coil = 100.0;

% load model
model = mphload('model.mph');

% set current
model.param.set('I_coil', I_coil);

% solve the model
model.sol('sol1').runAll;

% extract the integrals
[A_coil, V_coil] = mphglobal(model, {'A_coil', 'V_coil'});
[J_square, H_square, W_tot] = mphglobal(model, {'J_square', 'H_square', 'W_tot'});

% compute the RMS values
J_rms = sqrt(J_square./V_coil);
H_rms = sqrt(H_square./V_coil);

% scale the integrals
J_rms_norm = J_rms./I_coil;
H_rms_norm = H_rms./I_coil;
W_tot_norm = W_tot./(I_coil.^2);

% display the results
fprintf('Geometry\n')
fprintf('    A_coil = %.6f mm2\n', 1e6.*A_coil)
fprintf('    V_coil = %.6f cm3\n', 1e6.*V_coil)
fprintf('Raw\n')
fprintf('    I_coil = %.6f A\n', I_coil)
fprintf('    J_rms = %.6f A/mm2\n', 1e-6.*J_rms)
fprintf('    H_rms = %.6f A/mm\n', 1e-3.*H_rms)
fprintf('    W_tot = %.6f uJ\n', 1e6.*W_tot)
fprintf('Normalized\n')
fprintf('    J_rms_norm = %.6f 1/mm2\n', 1e-6.*J_rms_norm)
fprintf('    H_rms_norm = %.6f 1/mm\n', 1e-3.*H_rms_norm)
fprintf('    W_tot_norm = %.6f uJ/A2\n', 1e6.*W_tot_norm)

end