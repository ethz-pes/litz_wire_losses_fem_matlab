function run_winding_fem()
% Extract the required parameters from a COMSOL FEM simulation.
%
%    In this example, a simple circular air winding realized with litz wire is considered
%
%    This example is composed of two files:
%        - run_winding_fem.m - extract the winding geometry, energy and field patterns from FEM
%        - run_winding_circuit.m - extract the winding equivalent circuit  (losses and inductance)
%
%    The following properties are extracted:
%        - winding cross section and volume
%        - energy in the system
%        - current density and magnetic field in the winding
%
%    The extracted properties are normalized with respect to the number of turns.
%    The extracted properties are normalized with respect to the current.
%
%    (c) 2016-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

close('all')
addpath('utils')

%% param

% test current in the winding (scaled aftwerwards)
I_winding = 10;

% number of turns of the winding (scaled aftwerwards)
N_winding = 10;

% conductivity of the winding (does not have any impact)
sigma_winding = 4e7;

%% run

% load the COMSOL model
model = mphload('data/winding.mph');

% extract the parameters
winding = extract_fem(model, I_winding, N_winding, sigma_winding);

% save the parameters
save('data/winding.mat', '-struct', 'winding')

end

function winding = extract_fem(model, I_winding, N_winding, sigma_winding)
%  Extract the parameters (geometry, energy, and field patterns) from a COMSOL FEM model.
%
%    Parameters:
%        model (model): COMSOL model
%        I_winding (float): test current in the winding
%        N_winding (integer): number of turns of the winding
%        sigma_winding (float): conductivity of the winding
%
%    Returns:
%        winding (struct): extracted parameters

% set current and turns
model.param.set('I_winding', I_winding);
model.param.set('N_winding', N_winding);
model.param.set('sigma_winding', sigma_winding);

% solve the model
model.sol('sol1').runAll;

% extract the geometry
[A_winding, V_winding] = mphglobal(model, {'A_winding', 'V_winding'});

% extract the following integral:
%     - J_square = int_winding(J^2 dV)
%     - H_square = int_winding(H^2 dV)
%     - W_tot = int_all(0.5*B*H dV)
[J_square, H_square, W_tot] = mphglobal(model, {'J_square', 'H_square', 'W_tot'});

% compute the spatial RMS values of the field patterns
J_rms = sqrt(J_square./V_winding);
H_rms = sqrt(H_square./V_winding);

% scale the integrals (number of turns and current)
J_rms_norm = J_rms./(N_winding.*I_winding);
H_rms_norm = H_rms./(N_winding.*I_winding);
W_tot_norm = W_tot./(N_winding.^2.*I_winding.^2);

% display results
fprintf('Geometry\n')
fprintf('    A_winding = %.6f mm2\n', 1e6.*A_winding)
fprintf('    V_winding = %.6f cm3\n', 1e6.*V_winding)
fprintf('Raw\n')
fprintf('    I_winding = %.6f A\n', I_winding)
fprintf('    J_rms = %.6f A/mm2\n', 1e-6.*J_rms)
fprintf('    H_rms = %.6f A/mm\n', 1e-3.*H_rms)
fprintf('    W_tot = %.6f uJ\n', 1e6.*W_tot)
fprintf('Normalized\n')
fprintf('    J_rms_norm = %.6f 1/mm2\n', 1e-6.*J_rms_norm)
fprintf('    H_rms_norm = %.6f 1/mm\n', 1e-3.*H_rms_norm)
fprintf('    W_tot_norm = %.6f uJ/A2\n', 1e6.*W_tot_norm)

% assign data
winding.A_winding = A_winding;
winding.V_winding = V_winding;
winding.J_rms_norm = J_rms_norm;
winding.H_rms_norm = H_rms_norm;
winding.W_tot_norm = W_tot_norm;

end