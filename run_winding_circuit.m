function run_winding_circuit()
% Compute the equivalent circuit of a litz wire winding (inductance and resistance).
%
%    This example is composed of two files:
%        - a simple circular air winding realized with litz wire is considered.
%        - run_winding_fem.m - extract the winding geometry, energy and field patterns from FEM
%        - run_winding_circuit.m - extract the winding equivalent circuit  (losses and inductance)
%
%    The following properties are computed:
%        - the inductance
%        - the frequency-dependent winding resistance
%
%    (c) 2016-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

close('all')
addpath('utils')

%% param

% load the FEM data
winding = load('data/winding.mat');

% winding geometry
winding.d_litz = 71e-6; % stranding diameter
winding.N_litz = 500; % number of strands per turn
winding.N_turn = 10; % number of turns

% winding conductivity
winding.T_vec = [20 46 72 98 124 150]; % temperature vector
winding.sigma_vec = 1e7.*[5.800 5.262 4.816 4.439 4.117 3.839]; % conductivity vector

% operating condition
T = 80.0; % average winding temperature
f = logspace(log10(10e3), log10(100e6), 1000); % operating frequencies

%% run

% get the winding para
[L, R] = get_winding_litz(winding, T, f);
Z = R+1i.*2.*pi.*f.*L;

%% plot the results

figure()

subplot(1,3,1)
loglog(f, 1e3.*real(Z))
xlabel('f [Hz]')
ylabel('R [mOhm]')
title('Resistance')

subplot(1,3,2)
loglog(f, imag(Z))
xlabel('f [Hz]')
ylabel('X [Ohm]')
title('Reactance')

subplot(1,3,3)
semilogx(f, imag(Z)./real(Z))
xlabel('f [Hz]')
ylabel('Q [1]')
title('Quality Factor')

end